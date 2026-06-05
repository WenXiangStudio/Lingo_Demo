import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../tts_provider.dart';

/// Doubao TTS adapter for Volcano Engine's streaming HTTP API.
class DoubaoTtsAdapter implements MeteredTtsProvider {
  final String _model;
  final String _voice;
  final Dio _dio;

  DoubaoTtsAdapter({
    required String apiKey,
    required String baseUrl,
    String model = 'seed-tts-2.0-standard',
    String voice = 'zh_female_tiexinnvsheng_mars_bigtts',
    String resourceId = 'seed-tts-2.0',
  }) : _model = _normalizeModel(model),
       _voice = voice.trim().isNotEmpty
           ? voice.trim()
           : 'zh_female_tiexinnvsheng_mars_bigtts',
       _dio = Dio(
         BaseOptions(
           baseUrl: _normalizeBaseUrl(baseUrl),
           headers: {
             'X-Api-Key': apiKey.trim(),
             'X-Api-Resource-Id': _normalizeResourceId(resourceId),
             'Content-Type': 'application/json',
             'Accept': 'text/event-stream',
           },
           connectTimeout: const Duration(seconds: 15),
           receiveTimeout: const Duration(seconds: 90),
         ),
       );

  @override
  String get providerName => 'Doubao TTS';

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
    final stopwatch = Stopwatch()..start();
    final requestId = _requestId();
    final audio = BytesBuilder(copy: false);
    int? chargedCharacters;

    late final Response<ResponseBody> response;
    try {
      response = await _dio.post<ResponseBody>(
        '/api/v3/tts/unidirectional/sse',
        data: {
          'user': {'uid': 'lingo_app'},
          'namespace': 'BidirectionalTTS',
          'req_params': {
            'text': text,
            'speaker': _voice,
            'model': _model,
            'audio_params': {'format': 'mp3', 'sample_rate': 24000},
          },
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'X-Api-Request-Id': requestId,
            'X-Control-Require-Usage-Tokens-Return': 'text_words',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(await _formatDioException(e));
    }

    final body = response.data;
    if (body == null) {
      throw Exception('Doubao TTS: empty response');
    }

    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      final errorBody = await _readResponseBody(body);
      throw Exception(
        'Doubao TTS HTTP $statusCode: ${_extractErrorMessage(errorBody)}',
      );
    }

    final lines = body.stream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    final eventLines = <String>[];

    await for (final line in lines) {
      if (line.isEmpty) {
        chargedCharacters ??= _handleEvent(eventLines, audio);
        eventLines.clear();
        continue;
      }
      eventLines.add(line);
    }

    if (eventLines.isNotEmpty) {
      chargedCharacters ??= _handleEvent(eventLines, audio);
    }

    stopwatch.stop();
    final bytes = audio.takeBytes();
    if (bytes.isEmpty) {
      throw Exception('Doubao TTS: no audio data returned');
    }
    return TtsSynthesisResult(
      audioBytes: bytes,
      chargedCharacters: chargedCharacters,
      requestId: requestId,
      logId: response.headers.value('X-Tt-Logid'),
      durationMs: stopwatch.elapsedMilliseconds,
    );
  }

  int? _handleEvent(List<String> lines, BytesBuilder audio) {
    String? dataLine;
    for (final line in lines) {
      if (line.startsWith('data:')) {
        dataLine = line.substring(5).trimLeft();
      }
    }
    if (dataLine == null || dataLine.isEmpty) return null;

    final decoded = jsonDecode(dataLine);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final code = decoded['code'];
    final message = (decoded['message'] ?? '').toString();

    if (code is num && code.toInt() != 0 && code.toInt() != 20000000) {
      throw Exception(
        'Doubao TTS: ${message.isEmpty ? 'request failed' : message}',
      );
    }

    final chunk = decoded['data'];
    if (chunk is String && chunk.isNotEmpty) {
      audio.add(base64Decode(chunk));
    }

    final usage = decoded['usage'];
    if (usage is Map<String, dynamic>) {
      final textWords = usage['text_words'];
      if (textWords is num) return textWords.toInt();
      if (textWords is String) return int.tryParse(textWords);
    }
    return null;
  }

  Future<String> _formatDioException(DioException error) async {
    final statusCode = error.response?.statusCode;
    final bodyText = await _responseDataToText(error.response?.data);
    final detail = _extractErrorMessage(bodyText);
    if (statusCode != null) {
      return 'Doubao TTS HTTP $statusCode: $detail';
    }
    final message = error.message;
    if (message != null && message.trim().isNotEmpty) {
      return 'Doubao TTS: ${message.trim()}';
    }
    return 'Doubao TTS request failed';
  }

  Future<String> _responseDataToText(Object? data) async {
    if (data == null) return '';
    if (data is ResponseBody) return _readResponseBody(data);
    if (data is String) return data;
    if (data is List<int>) return utf8.decode(data, allowMalformed: true);
    return data.toString();
  }

  Future<String> _readResponseBody(ResponseBody body) {
    return body.stream.cast<List<int>>().transform(utf8.decoder).join();
  }

  String _extractErrorMessage(String bodyText) {
    final trimmed = bodyText.trim();
    if (trimmed.isEmpty) return 'request failed';

    for (final line in const LineSplitter().convert(trimmed)) {
      if (!line.startsWith('data:')) continue;
      final message = _messageFromJson(line.substring(5).trimLeft());
      if (message != null) return message;
    }

    final message = _messageFromJson(trimmed);
    if (message != null) return message;
    return trimmed.length > 500 ? '${trimmed.substring(0, 500)}...' : trimmed;
  }

  String? _messageFromJson(String text) {
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) {
        for (final key in ['message', 'msg', 'error']) {
          final value = decoded[key];
          if (value != null && value.toString().trim().isNotEmpty) {
            return value.toString().trim();
          }
        }
      }
    } catch (_) {}
    return null;
  }

  String _requestId() {
    final random = Random();
    final now = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    final suffix = random.nextInt(0x7fffffff).toRadixString(16);
    return 'lingo-$now-$suffix';
  }

  static String _normalizeBaseUrl(String value) {
    var trimmed = value.trim();
    if (trimmed.isEmpty) return 'https://openspeech.bytedance.com';
    while (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    for (final suffix in [
      '/api/v3/tts/unidirectional/sse',
      '/api/v3/tts/unidirectional',
    ]) {
      if (trimmed.endsWith(suffix)) {
        return trimmed.substring(0, trimmed.length - suffix.length);
      }
    }
    return trimmed;
  }

  static String _normalizeModel(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || !RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(trimmed)) {
      return 'seed-tts-2.0-standard';
    }
    return trimmed;
  }

  static String _normalizeResourceId(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || !RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(trimmed)) {
      return 'seed-tts-2.0';
    }
    return trimmed;
  }
}
