import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../tts_provider.dart';

enum Qwen3ExampleAudioValidationFailure {
  invalidWav,
  unexpectedFormat,
  tooShort,
  silent,
}

/// Qwen3 example sentences are intentionally not constrained to the legacy
/// 48 kHz word profile. They must still be a real, audible PCM WAV before a
/// batch job can place them in the durable cache or an upload package.
class Qwen3ExampleAudioValidationException implements Exception {
  final Qwen3ExampleAudioValidationFailure failure;

  const Qwen3ExampleAudioValidationException(this.failure);

  @override
  String toString() => 'qwen3_example_audio_${failure.name}';
}

/// Adapter for the non-realtime Qwen3-TTS Flash API.
///
/// This intentionally uses the multimodal-generation endpoint instead of the
/// Qwen-Audio-TTS SpeechSynthesizer endpoint used by [QwenTtsAdapter]. The
/// two APIs have different request formats and must remain separate so the
/// approved word-audio profile is never changed by a sentence-audio preset.
class Qwen3TtsAdapter implements MeteredTtsProvider {
  /// Internal TTS profile identifier. It is deliberately distinct from
  /// `qwen`, so its cached audio can never collide with word WAV files.
  static const String flashKaterinaProviderId = 'qwen3_flash_katerina';

  static const String flashModel = 'qwen3-tts-flash';
  static const String flashVoice = 'Katerina';

  /// Fixed delivery direction for the English example-sentence preset.
  ///
  /// This is deliberately part of the preset instead of a user-editable
  /// field. Changing it changes synthesized audio, so it must be paired with
  /// a new example-audio cache profile version.
  static const String flashKaterinaInstruction =
      '清晰自然的英式发音，语速适中，语调流畅有起伏，节奏连贯，适合英语句子朗读。';
  static const String audioMimeType = 'audio/wav';
  static const String cacheFileExtension = 'wav';
  static const Duration minimumExampleAudioDuration = Duration(
    milliseconds: 250,
  );
  static const int _minimumAudiblePcmSample = 64;

  static const String _endpoint =
      '/api/v1/services/aigc/multimodal-generation/generation';

  final String _model;
  final String _voice;
  final Dio _dio;
  final Dio _downloadDio;

  Qwen3TtsAdapter({
    required String apiKey,
    String baseUrl = '',
    String workspaceId = '',
    String model = flashModel,
    String voice = flashVoice,
  }) : _model = model,
       _voice = voice,
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
  String get providerName => 'Qwen3 TTS Flash';

  /// Resolves either of the officially supported DashScope base hosts.
  ///
  /// Existing installations keep their Beijing Workspace URL for the legacy
  /// word profile. When no base URL is saved, Qwen3-TTS may use DashScope's
  /// standard API host directly; a saved workspace ID is preferred when one
  /// is available.
  static String resolveBaseUrl(String baseUrl, String workspaceId) {
    var normalized = baseUrl.trim();
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    if (normalized.isEmpty) {
      final workspace = workspaceId.trim();
      return workspace.isEmpty
          ? 'https://dashscope.aliyuncs.com'
          : 'https://$workspace.cn-beijing.maas.aliyuncs.com';
    }

    if (normalized.endsWith(_endpoint)) {
      return normalized.substring(0, normalized.length - _endpoint.length);
    }
    if (normalized.endsWith('/api/v1')) {
      return normalized.substring(0, normalized.length - '/api/v1'.length);
    }
    return normalized;
  }

  static Map<String, dynamic> buildPayload({
    required String text,
    String model = flashModel,
    String voice = flashVoice,
    String language = 'en',
  }) {
    return {
      'model': model,
      'input': {
        'text': text,
        'voice': voice,
        'language_type': languageTypeFor(language),
        'instruction': flashKaterinaInstruction,
      },
    };
  }

  static String languageTypeFor(String language) {
    return switch (language.trim().toLowerCase()) {
      'zh' || 'zh-cn' || 'chinese' => 'Chinese',
      'en' || 'en-us' || 'en-gb' || 'english' => 'English',
      'de' || 'german' => 'German',
      'it' || 'italian' => 'Italian',
      'pt' || 'portuguese' => 'Portuguese',
      'es' || 'spanish' => 'Spanish',
      'ja' || 'japanese' => 'Japanese',
      'ko' || 'korean' => 'Korean',
      'fr' || 'french' => 'French',
      'ru' || 'russian' => 'Russian',
      _ => 'Auto',
    };
  }

  /// Validates the flexible PCM WAV profile emitted by Qwen3-TTS Flash.
  ///
  /// The service does not expose a sample-rate setting for this endpoint, so
  /// unlike the fixed legacy word profile this deliberately accepts standard
  /// mono/stereo, 16-bit PCM WAVs from 8–96 kHz. It rejects containers that
  /// could not be played reliably or would result in an empty server object.
  static Qwen3ExampleAudioValidationFailure? exampleAudioValidationFailure(
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
      return Qwen3ExampleAudioValidationFailure.invalidWav;
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
      final availableChunkBytes = audioBytes.length - chunkDataOffset;
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

      if (isFmt) {
        if (chunkSize > availableChunkBytes || chunkSize < 16) {
          return Qwen3ExampleAudioValidationFailure.invalidWav;
        }
        audioFormat = data.getUint16(chunkDataOffset, Endian.little);
        channels = data.getUint16(chunkDataOffset + 2, Endian.little);
        sampleRate = data.getUint32(chunkDataOffset + 4, Endian.little);
        byteRate = data.getUint32(chunkDataOffset + 8, Endian.little);
        blockAlign = data.getUint16(chunkDataOffset + 12, Endian.little);
        bitsPerSample = data.getUint16(chunkDataOffset + 14, Endian.little);
      } else if (isData) {
        // A streaming WAV can use the 0xFFFFFFFF data-size sentinel. Once the
        // full temporary URL has been downloaded, the remaining bytes are the
        // authoritative payload size.
        audioDataOffset = chunkDataOffset;
        audioDataLength = chunkSize > availableChunkBytes
            ? availableChunkBytes
            : chunkSize;
        break;
      } else if (chunkSize > availableChunkBytes) {
        return Qwen3ExampleAudioValidationFailure.invalidWav;
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
      return Qwen3ExampleAudioValidationFailure.invalidWav;
    }

    const expectedAudioFormat = 1; // PCM
    const expectedBitsPerSample = 16;
    final expectedBlockAlign = channels * expectedBitsPerSample ~/ 8;
    final expectedByteRate = sampleRate * expectedBlockAlign;
    if (audioFormat != expectedAudioFormat ||
        channels < 1 ||
        channels > 2 ||
        sampleRate < 8000 ||
        sampleRate > 96000 ||
        bitsPerSample != expectedBitsPerSample ||
        blockAlign != expectedBlockAlign ||
        byteRate != expectedByteRate ||
        audioDataLength % blockAlign != 0) {
      return Qwen3ExampleAudioValidationFailure.unexpectedFormat;
    }

    final minimumBytes =
        byteRate * minimumExampleAudioDuration.inMilliseconds ~/ 1000;
    if (audioDataLength < minimumBytes) {
      return Qwen3ExampleAudioValidationFailure.tooShort;
    }

    final audioDataEnd = audioDataOffset + audioDataLength;
    for (
      var sampleOffset = audioDataOffset;
      sampleOffset + 1 < audioDataEnd;
      sampleOffset += 2
    ) {
      final sample = data.getInt16(sampleOffset, Endian.little);
      if (sample.abs() >= _minimumAudiblePcmSample) return null;
    }
    return Qwen3ExampleAudioValidationFailure.silent;
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
      throw Exception('Qwen3 TTS: text is empty');
    }

    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _endpoint,
        data: buildPayload(
          text: normalizedText,
          model: _model,
          voice: _voice,
          language: language,
        ),
      );
      final data = response.data;
      final audio = _audioFromResponse(data);
      final audioUrl = audio['url'];

      Uint8List audioBytes;
      if (audioUrl is String && audioUrl.trim().isNotEmpty) {
        final audioResponse = await _downloadDio.get<List<int>>(
          audioUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        final rawBytes = audioResponse.data;
        if (rawBytes == null || rawBytes.isEmpty) {
          throw Exception('Qwen3 TTS: downloaded audio is empty');
        }
        audioBytes = Uint8List.fromList(rawBytes);
      } else {
        final audioData = audio['data'];
        if (audioData is! String || audioData.trim().isEmpty) {
          throw Exception(_apiError(data, 'response has no audio data'));
        }
        audioBytes = _decodeAudioData(audioData);
        if (audioBytes.isEmpty) {
          throw Exception('Qwen3 TTS: decoded audio is empty');
        }
      }

      final validationFailure = exampleAudioValidationFailure(audioBytes);
      if (validationFailure != null) {
        throw Qwen3ExampleAudioValidationException(validationFailure);
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

  static Map<String, dynamic> _audioFromResponse(Map<String, dynamic>? data) {
    final output = data?['output'];
    if (output is! Map<String, dynamic>) return const {};
    final audio = output['audio'];
    return audio is Map<String, dynamic> ? audio : const {};
  }

  static Uint8List _decodeAudioData(String rawData) {
    final data = rawData.trim();
    final comma = data.indexOf(',');
    final base64Value = data.startsWith('data:') && comma >= 0
        ? data.substring(comma + 1)
        : data;
    try {
      return Uint8List.fromList(base64Decode(base64Value));
    } on FormatException {
      throw Exception('Qwen3 TTS: response audio data is not valid Base64');
    }
  }

  static String _apiError(Map<String, dynamic>? data, String fallback) {
    if (data != null) {
      for (final key in const ['message', 'code', 'error_message']) {
        final value = data[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return 'Qwen3 TTS: ${value.toString().trim()}';
        }
      }
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        for (final key in const ['message', 'code']) {
          final value = error[key];
          if (value != null && value.toString().trim().isNotEmpty) {
            return 'Qwen3 TTS: ${value.toString().trim()}';
          }
        }
      }
    }
    return 'Qwen3 TTS: $fallback';
  }

  static String _dioError(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    final detail = data is Map<String, dynamic>
        ? _apiError(data, error.message ?? 'request failed')
        : (error.message ?? 'request failed');
    return status == null
        ? 'Qwen3 TTS: $detail'
        : 'Qwen3 TTS HTTP $status: $detail';
  }
}
