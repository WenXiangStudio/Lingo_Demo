import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../tts_provider.dart';

class OpenAiTtsAdapter implements TtsProvider {
  final String _model;
  final String _voice;
  final Dio _dio;

  OpenAiTtsAdapter({
    required String apiKey,
    String model = 'tts-1',
    String voice = 'alloy',
  })  : _model = model,
        _voice = voice,
        _dio = Dio(BaseOptions(
          baseUrl: 'https://api.openai.com',
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 60),
        ));

  @override
  String get providerName => 'OpenAI TTS';

  @override
  Future<Uint8List> synthesize(String text, {String language = 'en'}) async {
    final voice = language == 'zh' ? 'echo' : _voice;
    final response = await _dio.post(
      '/v1/audio/speech',
      data: {
        'model': _model,
        'input': text,
        'voice': voice,
        'response_format': 'mp3',
        'speed': 1.0,
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data as List<int>);
  }
}
