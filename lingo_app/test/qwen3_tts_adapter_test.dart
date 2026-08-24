import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:lingo_app/core/services/tts_adapters/qwen3_tts_adapter.dart';
import 'package:lingo_app/core/services/tts_adapters/qwen_tts_adapter.dart';

Uint8List _pcmWav({
  int sampleRate = 24000,
  int durationMilliseconds = 300,
  int amplitude = 1200,
}) {
  const channels = 1;
  const bitsPerSample = 16;
  final sampleCount = sampleRate * durationMilliseconds ~/ 1000;
  final dataLength = sampleCount * channels * bitsPerSample ~/ 8;
  final bytes = Uint8List(44 + dataLength);
  final data = ByteData.sublistView(bytes);
  bytes.setRange(0, 4, const [0x52, 0x49, 0x46, 0x46]);
  data.setUint32(4, bytes.length - 8, Endian.little);
  bytes.setRange(8, 12, const [0x57, 0x41, 0x56, 0x45]);
  bytes.setRange(12, 16, const [0x66, 0x6d, 0x74, 0x20]);
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, channels, Endian.little);
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, sampleRate * channels * bitsPerSample ~/ 8, Endian.little);
  data.setUint16(32, channels * bitsPerSample ~/ 8, Endian.little);
  data.setUint16(34, bitsPerSample, Endian.little);
  bytes.setRange(36, 40, const [0x64, 0x61, 0x74, 0x61]);
  data.setUint32(40, dataLength, Endian.little);
  for (var offset = 44; offset < bytes.length; offset += 2) {
    data.setInt16(offset, amplitude, Endian.little);
  }
  return bytes;
}

void main() {
  group('Qwen3 TTS Flash Katerina preset', () {
    test(
      'uses the selected stable model, system voice, instruction, and English hint',
      () {
        final payload = Qwen3TtsAdapter.buildPayload(text: 'Example sentence.');

        expect(payload['model'], Qwen3TtsAdapter.flashModel);
        expect(payload['model'], 'qwen3-tts-flash');
        expect(payload['input'], {
          'text': 'Example sentence.',
          'voice': Qwen3TtsAdapter.flashVoice,
          'language_type': 'English',
          'instruction': Qwen3TtsAdapter.flashKaterinaInstruction,
        });
        expect(Qwen3TtsAdapter.flashVoice, 'Katerina');
        expect(
          Qwen3TtsAdapter.flashKaterinaInstruction,
          '清晰自然的英式发音，语速适中，语调流畅有起伏，节奏连贯，适合英语句子朗读。',
        );
      },
    );

    test('maps supported language codes to the API language_type values', () {
      expect(Qwen3TtsAdapter.languageTypeFor('en'), 'English');
      expect(Qwen3TtsAdapter.languageTypeFor('zh-CN'), 'Chinese');
      expect(Qwen3TtsAdapter.languageTypeFor('fr'), 'French');
      expect(Qwen3TtsAdapter.languageTypeFor('unknown'), 'Auto');
    });

    test('normalizes DashScope and Workspace endpoint inputs', () {
      expect(
        Qwen3TtsAdapter.resolveBaseUrl('', ''),
        'https://dashscope.aliyuncs.com',
      );
      expect(
        Qwen3TtsAdapter.resolveBaseUrl('', 'workspace-id'),
        'https://workspace-id.cn-beijing.maas.aliyuncs.com',
      );
      expect(
        Qwen3TtsAdapter.resolveBaseUrl(
          'https://dashscope.aliyuncs.com/api/v1',
          '',
        ),
        'https://dashscope.aliyuncs.com',
      );
      expect(
        Qwen3TtsAdapter.resolveBaseUrl(
          'https://dashscope.aliyuncs.com/api/v1/services/aigc/'
              'multimodal-generation/generation',
          '',
        ),
        'https://dashscope.aliyuncs.com',
      );
    });

    test(
      'downloads the returned non-realtime audio URL and records metadata',
      () async {
        final audio = _pcmWav();
        final requests = <Map<String, dynamic>>[];
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final baseUrl = 'http://${server.address.address}:${server.port}';
        final subscription = server.listen((request) {
          unawaited(() async {
            if (request.uri.path ==
                '/api/v1/services/aigc/multimodal-generation/generation') {
              final body = await utf8.decoder.bind(request).join();
              requests.add(jsonDecode(body) as Map<String, dynamic>);
              request.response.headers.contentType = ContentType.json;
              request.response.write(
                jsonEncode({
                  'request_id': 'request-123',
                  'usage': {'characters': 17},
                  'output': {
                    'audio': {'url': '$baseUrl/audio.wav'},
                  },
                }),
              );
            } else if (request.uri.path == '/audio.wav') {
              request.response.headers.contentType = ContentType(
                'audio',
                'wav',
              );
              request.response.add(audio);
            } else {
              request.response.statusCode = HttpStatus.notFound;
            }
            await request.response.close();
          }());
        });
        addTearDown(() async {
          await subscription.cancel();
          await server.close(force: true);
        });

        final adapter = Qwen3TtsAdapter(apiKey: 'test-key', baseUrl: baseUrl);
        final result = await adapter.synthesizeWithMetadata(
          'A short example.',
          language: 'en',
        );

        expect(requests, hasLength(1));
        expect(requests.single['model'], 'qwen3-tts-flash');
        expect(requests.single['input'], {
          'text': 'A short example.',
          'voice': 'Katerina',
          'language_type': 'English',
          'instruction': Qwen3TtsAdapter.flashKaterinaInstruction,
        });
        expect(result.audioBytes, audio);
        expect(result.requestId, 'request-123');
        expect(result.chargedCharacters, 17);
        expect(result.durationMs, greaterThanOrEqualTo(0));
      },
    );
  });

  test('does not alter the approved legacy Qwen word preset constants', () {
    expect(QwenTtsAdapter.wordModel, 'qwen-audio-3.0-tts-plus');
    expect(QwenTtsAdapter.wordVoice, 'qwen-audio-3.0-tts-plus-loongdeanliu');
    expect(QwenTtsAdapter.wordAudioFormat, 'wav');
    expect(QwenTtsAdapter.wordSampleRate, 48000);
  });
}
