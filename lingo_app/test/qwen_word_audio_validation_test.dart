import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lingo_app/core/services/remote_word_audio_client.dart';
import 'package:lingo_app/core/services/tts_adapters/qwen_tts_adapter.dart';
import 'package:lingo_app/core/services/tts_service.dart';
import 'package:lingo_app/data/database/app_database.dart';
import 'package:lingo_app/data/repositories/repositories.dart';

Uint8List _pcmWav({
  int durationMilliseconds = 250,
  int amplitude = 1600,
  bool streamingLengthHeader = false,
}) {
  const sampleRate = 48000;
  const channels = 1;
  const bitsPerSample = 16;
  final sampleCount = sampleRate * durationMilliseconds ~/ 1000;
  final dataLength = sampleCount * channels * bitsPerSample ~/ 8;
  final bytes = Uint8List(44 + dataLength);
  final data = ByteData.sublistView(bytes);

  const riff = [0x52, 0x49, 0x46, 0x46];
  const wave = [0x57, 0x41, 0x56, 0x45];
  const fmt = [0x66, 0x6d, 0x74, 0x20];
  const audioData = [0x64, 0x61, 0x74, 0x61];
  bytes.setRange(0, 4, riff);
  data.setUint32(
    4,
    streamingLengthHeader ? 0xffffffff : bytes.length - 8,
    Endian.little,
  );
  bytes.setRange(8, 12, wave);
  bytes.setRange(12, 16, fmt);
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, channels, Endian.little);
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, sampleRate * channels * bitsPerSample ~/ 8, Endian.little);
  data.setUint16(32, channels * bitsPerSample ~/ 8, Endian.little);
  data.setUint16(34, bitsPerSample, Endian.little);
  bytes.setRange(36, 40, audioData);
  data.setUint32(
    40,
    streamingLengthHeader ? 0xffffffff : dataLength,
    Endian.little,
  );
  for (var offset = 44; offset < bytes.length; offset += 2) {
    data.setInt16(offset, amplitude, Endian.little);
  }
  return bytes;
}

void main() {
  group('Qwen staged word WAV validation', () {
    test('accepts the approved non-silent PCM WAV profile', () {
      expect(QwenTtsAdapter.wordAudioValidationFailure(_pcmWav()), isNull);
    });

    test('accepts Qwen streaming WAV length sentinels', () {
      expect(
        QwenTtsAdapter.wordAudioValidationFailure(
          _pcmWav(streamingLengthHeader: true),
        ),
        isNull,
      );
    });

    test('rejects a valid WAV container with silent PCM samples', () {
      expect(
        QwenTtsAdapter.wordAudioValidationFailure(_pcmWav(amplitude: 0)),
        QwenWordAudioValidationFailure.silent,
      );
    });

    test('rejects an audible WAV that is too short for a word', () {
      expect(
        QwenTtsAdapter.wordAudioValidationFailure(
          _pcmWav(durationMilliseconds: 100),
        ),
        QwenWordAudioValidationFailure.tooShort,
      );
    });

    test('rejects malformed responses', () {
      expect(
        QwenTtsAdapter.wordAudioValidationFailure(Uint8List.fromList([1, 2])),
        QwenWordAudioValidationFailure.invalidWav,
      );
    });
  });

  group('Qwen staged cache validation', () {
    late Directory tempDir;
    late AppDatabase database;
    late TtsRepository repository;
    late TtsService service;

    setUp(() async {
      tempDir = await Directory.current.createTemp('qwen_word_audio_test_');
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = TtsRepository(database);
      service = TtsService(
        settingsRepo: SettingsRepository(database),
        ttsRepo: repository,
        dataDirProvider: () async => tempDir,
      );
    });

    tearDown(() async {
      await database.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'ignores an existing silent WAV without deleting it during a status check',
      () async {
        final cacheDir = Directory('${tempDir.path}/lingo_tts_cache');
        await cacheDir.create(recursive: true);
        final file = File(
          '${cacheDir.path}/${RemoteWordAudioClient.audioFileNameFor('pronounce')}',
        );
        await file.writeAsBytes(_pcmWav(amplitude: 0));

        final presence = await service.getCachedAudioPresence(
          ['pronounce'],
          provider: 'qwen',
          lang: 'en',
        );

        expect(presence['pronounce'], isFalse);
        expect(await file.exists(), isTrue);
      },
    );

    test('retries a silent Qwen response with a terminal boundary', () async {
      final requests = <String>[];
      final instructions = <String?>[];
      late HttpServer server;
      late String baseUrl;
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      baseUrl = 'http://${server.address.address}:${server.port}';
      final subscription = server.listen((request) {
        unawaited(() async {
          if (request.uri.path ==
              '/api/v1/services/audio/tts/SpeechSynthesizer') {
            final body = await utf8.decoder.bind(request).join();
            final payload = jsonDecode(body) as Map<String, dynamic>;
            final input = payload['input'] as Map<String, dynamic>;
            final text = input['text'] as String;
            requests.add(text);
            instructions.add(input['instruction'] as String?);
            final audioPath = text.endsWith('.') ? '/valid.wav' : '/silent.wav';
            request.response.headers.contentType = ContentType.json;
            request.response.write(
              jsonEncode({
                'output': {
                  'audio': {'url': '$baseUrl$audioPath'},
                },
                'usage': {'characters': text.length},
              }),
            );
          } else if (request.uri.path == '/silent.wav') {
            request.response.headers.contentType = ContentType('audio', 'wav');
            request.response.add(
              _pcmWav(amplitude: 0, streamingLengthHeader: true),
            );
          } else if (request.uri.path == '/valid.wav') {
            request.response.headers.contentType = ContentType('audio', 'wav');
            request.response.add(_pcmWav(streamingLengthHeader: true));
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

      final result = await service.preCacheCloudConfig(
        provider: 'qwen',
        apiKey: 'test-key',
        baseUrl: baseUrl,
        model: QwenTtsAdapter.wordModel,
        voice: QwenTtsAdapter.wordVoice,
        resourceId: 'test-workspace',
        items: const [TtsPreCacheItem(text: 'pronounce', listName: 'List 2')],
        maxRetries: 1,
      );

      expect(requests, ['pronounce', 'pronounce.']);
      expect(instructions, [
        QwenTtsAdapter.wordInstruction,
        QwenTtsAdapter.wordInstruction,
      ]);
      expect(result.success, 1);
      expect(result.failed, 0);
      expect(result.apiCalls, 2);
      final staged = File(
        '${tempDir.path}/lingo_tts_cache/${RemoteWordAudioClient.audioFileNameFor('pronounce')}',
      );
      expect(await staged.exists(), isTrue);
      expect(
        QwenTtsAdapter.wordAudioValidationFailure(await staged.readAsBytes()),
        isNull,
      );
    });
  });
}
