import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../tts_provider.dart';

/// Qwen3 TTS adapter — calls Alibaba Cloud DashScope API.
class QwenTtsAdapter implements TtsProvider {
  final String _model;
  final String _voice;
  final Dio _dio;
  final Dio _downloadDio;

  QwenTtsAdapter({
    required String apiKey,
    required String baseUrl,
    String model = 'qwen3-tts-flash',
    String voice = 'Jennifer',
  })  : _model = model,
        _voice = voice,
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 60),
        )),
        _downloadDio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 60),
        ));

  @override
  String get providerName => 'Qwen3 TTS';

  @override
  Future<Uint8List> synthesize(String text, {String language = 'en'}) async {
    final langType = switch (language) {
      'zh' => 'Chinese',
      'en' => 'English',
      _ => 'Auto',
    };

    // Step 1: Request synthesis — returns an OSS audio URL
    final response = await _dio.post(
      '/api/v1/services/aigc/multimodal-generation/generation',
      data: {
        'model': _model,
        'input': {
          'text': text,
          'voice': _voice,
          'language_type': langType,
        },
        'parameters': {
          'response_format': 'mp3',
        },
      },
    );

    final audioUrl = response.data['output']['audio']['url'] as String;
    if (audioUrl.isEmpty) {
      throw Exception('Qwen TTS: no audio URL in response');
    }

    // Step 2: Download the audio from OSS
    final audioResponse = await _downloadDio.get(
      audioUrl,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(audioResponse.data as List<int>);
  }
}
