import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../tts_provider.dart';

enum QwenWordAudioValidationFailure {
  invalidWav,
  unexpectedFormat,
  tooShort,
  silent,
}

/// Thrown when Qwen returned a syntactically valid response that is not a
/// usable word-pronunciation WAV. This is deliberately distinct from an HTTP
/// failure so batch staging can retry it with a terminal prosody boundary.
class QwenWordAudioValidationException implements Exception {
  final QwenWordAudioValidationFailure failure;

  const QwenWordAudioValidationException(this.failure);

  @override
  String toString() => 'qwen_word_audio_${failure.name}';
}

/// Alibaba Cloud Bailian Qwen-Audio-TTS non-streaming adapter.
///
/// The SpeechSynthesizer endpoint returns a temporary audio URL. The adapter
/// downloads that URL before returning so callers can persist a stable local
/// cache entry rather than depending on the 24-hour remote URL.
class QwenTtsAdapter implements MeteredTtsProvider {
  static const String wordModel = 'qwen-audio-3.0-tts-plus';
  static const String wordVoice = 'qwen-audio-3.0-tts-plus-loongdeanliu';
  static const String wordInstruction = '清晰自然的英式发音，语速适中，语调平稳，适合英语单词朗读';

  /// Preserve the approved source quality. These files are staged on the
  /// developer machine and then served as static WAVs by Lighthouse.
  static const String wordAudioFormat = 'wav';
  static const String wordAudioMimeType = 'audio/wav';
  static const String wordCacheFileExtension = 'wav';
  static const String wordCacheProfileVersion = 'qwen-word-wav-48k-british-v2';
  static const int wordSampleRate = 48000;
  static const int wordVolume = 50;
  static const double wordRate = 1.0;
  static const double wordPitch = 1.0;
  static const int wordSeed = 0;

  /// A word response shorter than this cannot contain a useful pronunciation.
  /// This value remains well below the shortest normal staged word response.
  static const Duration minimumWordAudioDuration = Duration(milliseconds: 200);
  static const int _minimumAudiblePcmSample = 64;

  /// A recovery form for a bare English word when the upstream synthesizer
  /// rejects the unpunctuated input. The spoken word is unchanged; the period
  /// only supplies a terminal prosody boundary.
  static String? bareEnglishWordFallbackText(
    String text, {
    String language = 'en',
  }) {
    if (language.trim().toLowerCase() != 'en') return null;
    final normalized = text.trim();
    if (!RegExp(r"^[A-Za-z]+(?:[ '\-][A-Za-z]+)*$").hasMatch(normalized)) {
      return null;
    }
    return '$normalized.';
  }

  final String _model;
  final String _voice;
  final String _audioFormat;
  final int _sampleRate;
  final int _volume;
  final double _rate;
  final double _pitch;
  final int _seed;
  final String? _instruction;
  final Dio _dio;
  final Dio _downloadDio;

  QwenTtsAdapter({
    required String apiKey,
    required String workspaceId,
    String baseUrl = '',
    String model = wordModel,
    String voice = wordVoice,
    String audioFormat = wordAudioFormat,
    int sampleRate = wordSampleRate,
    int volume = wordVolume,
    double rate = wordRate,
    double pitch = wordPitch,
    int seed = wordSeed,
    String? instruction,
  }) : _model = model,
       _voice = voice,
       _audioFormat = audioFormat,
       _sampleRate = sampleRate,
       _volume = volume,
       _rate = rate,
       _pitch = pitch,
       _seed = seed,
       _instruction = _normalizeInstruction(instruction),
       _dio = Dio(
         BaseOptions(
           baseUrl: resolveBaseUrl(baseUrl, workspaceId),
           headers: {
             'Authorization': 'Bearer ${apiKey.trim()}',
             'Content-Type': 'application/json',
           },
           connectTimeout: const Duration(seconds: 15),
           receiveTimeout: const Duration(seconds: 180),
         ),
       ),
       _downloadDio = Dio(
         BaseOptions(
           connectTimeout: const Duration(seconds: 15),
           receiveTimeout: const Duration(seconds: 180),
         ),
       );

  @override
  String get providerName => 'Qwen Audio TTS';

  static String resolveBaseUrl(String baseUrl, String workspaceId) {
    final workspace = workspaceId.trim();
    if (workspace.isEmpty) {
      throw ArgumentError.value(
        workspaceId,
        'workspaceId',
        'Qwen TTS requires a Workspace ID',
      );
    }

    var normalized = baseUrl.trim();
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    if (normalized.isEmpty ||
        normalized == 'https://dashscope.aliyuncs.com' ||
        normalized == 'https://dashscope.aliyuncs.com/api/v1') {
      return 'https://$workspace.cn-beijing.maas.aliyuncs.com';
    }
    const endpointPath = '/api/v1/services/audio/tts/SpeechSynthesizer';
    if (normalized.endsWith(endpointPath)) {
      normalized = normalized.substring(
        0,
        normalized.length - endpointPath.length,
      );
    } else if (normalized.endsWith('/api/v1')) {
      normalized = normalized.substring(0, normalized.length - 7);
    }
    return normalized;
  }

  static Map<String, dynamic> buildPayload({
    required String text,
    String model = wordModel,
    String voice = wordVoice,
    String audioFormat = wordAudioFormat,
    int sampleRate = wordSampleRate,
    int volume = wordVolume,
    double rate = wordRate,
    double pitch = wordPitch,
    int seed = wordSeed,
    String? language,
    String? instruction,
  }) {
    final input = <String, dynamic>{
      'text': text,
      'voice': voice,
      'format': audioFormat,
      'sample_rate': sampleRate,
      'volume': volume,
      'rate': rate,
      'pitch': pitch,
      'seed': seed,
    };
    final normalizedLanguage = language?.trim().toLowerCase() ?? '';
    if (normalizedLanguage.isNotEmpty) {
      input['language_hints'] = [normalizedLanguage];
    }
    final normalizedInstruction = _normalizeInstruction(instruction);
    if (normalizedInstruction != null) {
      input['instruction'] = normalizedInstruction;
    }
    return {'model': model, 'input': input};
  }

  static String? _normalizeInstruction(String? instruction) {
    final normalized = instruction?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }

  /// Returns a typed failure when [audioBytes] is not the fixed PCM WAV
  /// profile used for staged English words. A zero-amplitude WAV is a valid
  /// container but must never be treated as a successful pronunciation.
  static QwenWordAudioValidationFailure? wordAudioValidationFailure(
    Uint8List audioBytes,
  ) {
    if (audioBytes.length < 12 ||
        audioBytes[0] != 0x52 ||
        audioBytes[1] != 0x49 ||
        audioBytes[2] != 0x46 ||
        audioBytes[3] != 0x46 ||
        audioBytes[8] != 0x57 ||
        audioBytes[9] != 0x41 ||
        audioBytes[10] != 0x56 ||
        audioBytes[11] != 0x45) {
      return QwenWordAudioValidationFailure.invalidWav;
    }

    final data = ByteData.sublistView(audioBytes);
    var offset = 12;
    int? audioFormat;
    int? channels;
    int? sampleRate;
    int? byteRate;
    int? blockAlign;
    int? bitsPerSample;
    int? audioDataOffset;
    int? audioDataLength;

    while (offset + 8 <= audioBytes.length) {
      final chunkSize = data.getUint32(offset + 4, Endian.little);
      final chunkDataOffset = offset + 8;
      final isFmt =
          audioBytes[offset] == 0x66 &&
          audioBytes[offset + 1] == 0x6d &&
          audioBytes[offset + 2] == 0x74 &&
          audioBytes[offset + 3] == 0x20;
      final isData =
          audioBytes[offset] == 0x64 &&
          audioBytes[offset + 1] == 0x61 &&
          audioBytes[offset + 2] == 0x74 &&
          audioBytes[offset + 3] == 0x61;
      final availableChunkBytes = audioBytes.length - chunkDataOffset;

      if (isFmt) {
        if (chunkSize > availableChunkBytes) {
          return QwenWordAudioValidationFailure.invalidWav;
        }
        if (chunkSize < 16) {
          return QwenWordAudioValidationFailure.invalidWav;
        }
        audioFormat = data.getUint16(chunkDataOffset, Endian.little);
        channels = data.getUint16(chunkDataOffset + 2, Endian.little);
        sampleRate = data.getUint32(chunkDataOffset + 4, Endian.little);
        byteRate = data.getUint32(chunkDataOffset + 8, Endian.little);
        blockAlign = data.getUint16(chunkDataOffset + 12, Endian.little);
        bitsPerSample = data.getUint16(chunkDataOffset + 14, Endian.little);
      } else if (isData) {
        // Qwen emits streaming WAVs whose data length can be the RIFF
        // sentinel 0xFFFFFFFF. In a complete downloaded response, the bytes
        // remaining in the file are the authoritative data length.
        audioDataOffset = chunkDataOffset;
        audioDataLength = chunkSize > availableChunkBytes
            ? availableChunkBytes
            : chunkSize;
        break;
      } else if (chunkSize > availableChunkBytes) {
        return QwenWordAudioValidationFailure.invalidWav;
      }

      offset = chunkDataOffset + chunkSize + (chunkSize.isOdd ? 1 : 0);
    }

    if (audioFormat == null ||
        channels == null ||
        sampleRate == null ||
        byteRate == null ||
        blockAlign == null ||
        bitsPerSample == null ||
        audioDataOffset == null ||
        audioDataLength == null) {
      return QwenWordAudioValidationFailure.invalidWav;
    }

    const expectedChannels = 1;
    const expectedBitsPerSample = 16;
    const expectedAudioFormat = 1; // PCM
    final expectedBlockAlign = expectedChannels * expectedBitsPerSample ~/ 8;
    final expectedByteRate = wordSampleRate * expectedBlockAlign;
    if (audioFormat != expectedAudioFormat ||
        channels != expectedChannels ||
        sampleRate != wordSampleRate ||
        bitsPerSample != expectedBitsPerSample ||
        blockAlign != expectedBlockAlign ||
        byteRate != expectedByteRate ||
        audioDataLength % blockAlign != 0) {
      return QwenWordAudioValidationFailure.unexpectedFormat;
    }

    final minimumBytes =
        byteRate * minimumWordAudioDuration.inMilliseconds ~/ 1000;
    if (audioDataLength < minimumBytes) {
      return QwenWordAudioValidationFailure.tooShort;
    }

    final audioDataEnd = audioDataOffset + audioDataLength;
    for (
      var sampleOffset = audioDataOffset;
      sampleOffset + 1 < audioDataEnd;
      sampleOffset += 2
    ) {
      final sample = data.getInt16(sampleOffset, Endian.little);
      if (sample.abs() >= _minimumAudiblePcmSample) {
        return null;
      }
    }
    return QwenWordAudioValidationFailure.silent;
  }

  @override
  Future<Uint8List> synthesize(String text, {String language = 'en'}) async {
    final result = await synthesizeWithMetadata(text, language: language);
    return result.audioBytes;
  }

  @override
  Future<TtsSynthesisResult> synthesizeWithMetadata(
    String text, {
    String language = 'en',
  }) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) {
      throw Exception('Qwen TTS: text is empty');
    }

    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/services/audio/tts/SpeechSynthesizer',
        data: buildPayload(
          text: normalizedText,
          model: _model,
          voice: _voice,
          audioFormat: _audioFormat,
          sampleRate: _sampleRate,
          volume: _volume,
          rate: _rate,
          pitch: _pitch,
          seed: _seed,
          language: language,
          instruction: _instruction,
        ),
      );
      final data = response.data;
      final output = data?['output'];
      final audio = output is Map<String, dynamic> ? output['audio'] : null;
      final audioUrl = audio is Map<String, dynamic> ? audio['url'] : null;
      if (audioUrl is! String || audioUrl.trim().isEmpty) {
        throw Exception(_apiError(data, 'response has no audio URL'));
      }

      final audioResponse = await _downloadDio.get<List<int>>(
        audioUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final rawBytes = audioResponse.data;
      if (rawBytes == null || rawBytes.isEmpty) {
        throw Exception('Qwen TTS: downloaded audio is empty');
      }

      final audioBytes = Uint8List.fromList(rawBytes);
      final validationFailure = wordAudioValidationFailure(audioBytes);
      if (validationFailure != null) {
        throw QwenWordAudioValidationException(validationFailure);
      }

      stopwatch.stop();
      final usage = data?['usage'];
      final characters = usage is Map<String, dynamic>
          ? usage['characters']
          : null;
      return TtsSynthesisResult(
        audioBytes: audioBytes,
        chargedCharacters: characters is num ? characters.toInt() : null,
        requestId: data?['request_id']?.toString(),
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } on DioException catch (error) {
      stopwatch.stop();
      throw Exception(_dioError(error));
    }
  }

  static String _apiError(Map<String, dynamic>? data, String fallback) {
    if (data != null) {
      for (final key in const ['message', 'code', 'error_message']) {
        final value = data[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return 'Qwen TTS: ${value.toString().trim()}';
        }
      }
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        for (final key in const ['message', 'code']) {
          final value = error[key];
          if (value != null && value.toString().trim().isNotEmpty) {
            return 'Qwen TTS: ${value.toString().trim()}';
          }
        }
      }
    }
    return 'Qwen TTS: $fallback';
  }

  static String _dioError(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    final detail = data is Map<String, dynamic>
        ? _apiError(data, error.message ?? 'request failed')
        : (error.message ?? 'request failed');
    return status == null
        ? 'Qwen TTS: $detail'
        : 'Qwen TTS HTTP $status: $detail';
  }
}
