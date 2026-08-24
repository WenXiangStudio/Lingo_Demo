import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:lingo_app/core/services/remote_word_audio_client.dart';
import 'package:lingo_app/core/services/tts_adapters/qwen_tts_adapter.dart';

void main() {
  Uint8List wavBytes() => Uint8List.fromList(const [
    0x52,
    0x49,
    0x46,
    0x46,
    0x24,
    0x00,
    0x00,
    0x00,
    0x57,
    0x41,
    0x56,
    0x45,
    0x66,
    0x6d,
    0x74,
    0x20,
  ]);

  group('RemoteWordAudioClient', () {
    test('normalizes the configured base URL and builds a stable WAV URL', () {
      final client = RemoteWordAudioClient(
        baseUrl: ' http://203.0.113.10/audio/ ',
        request: (_) async =>
            RemoteWordAudioResponse(statusCode: 200, bytes: wavBytes()),
      );

      final lowercaseKey = RemoteWordAudioClient.audioKeyFor('extension');
      expect(RemoteWordAudioClient.audioKeyFor(' Extension '), lowercaseKey);
      expect(client.baseUrl, 'http://203.0.113.10/audio');
      expect(
        client.buildAudioUri('Extension').toString(),
        'http://203.0.113.10/audio/v1/en/$lowercaseKey.wav',
      );
      expect(
        RemoteWordAudioClient.audioKeyProfileVersion,
        QwenTtsAdapter.wordCacheProfileVersion,
      );
      expect(
        RemoteWordAudioClient.audioKeyProfileVersion,
        'qwen-word-wav-48k-british-v2',
      );
    });

    test('returns only a valid WAV response', () async {
      final expected = wavBytes();
      final client = RemoteWordAudioClient(
        baseUrl: 'https://audio.example.test/audio',
        request: (_) async => RemoteWordAudioResponse(
          statusCode: 200,
          bytes: expected,
          contentType: 'audio/wav',
        ),
      );

      expect(await client.fetch('pronunciation'), expected);
    });

    test('probes static WAV presence with typed outcomes', () async {
      final uploaded = RemoteWordAudioClient(
        baseUrl: 'https://audio.example.test/audio',
        request: (_) async =>
            RemoteWordAudioResponse(statusCode: 200, bytes: wavBytes()),
        probeRequest: (_) async =>
            RemoteWordAudioResponse(statusCode: 206, bytes: wavBytes()),
      );
      final missing = RemoteWordAudioClient(
        baseUrl: 'https://audio.example.test/audio',
        request: (_) async =>
            RemoteWordAudioResponse(statusCode: 200, bytes: wavBytes()),
        probeRequest: (_) async =>
            RemoteWordAudioResponse(statusCode: 404, bytes: Uint8List(0)),
      );
      final malformed = RemoteWordAudioClient(
        baseUrl: 'https://audio.example.test/audio',
        request: (_) async =>
            RemoteWordAudioResponse(statusCode: 200, bytes: wavBytes()),
        probeRequest: (_) async =>
            RemoteWordAudioResponse(statusCode: 200, bytes: Uint8List(0)),
      );

      expect(await uploaded.probe('pronunciation'), isNull);
      expect(await missing.probe('missing'), RemoteWordAudioFailure.notFound);
      expect(
        await malformed.probe('malformed'),
        RemoteWordAudioFailure.invalidAudio,
      );
    });

    test(
      'maps missing, malformed, and timed-out responses to typed errors',
      () async {
        final missing = RemoteWordAudioClient(
          baseUrl: 'https://audio.example.test/audio',
          request: (_) async =>
              RemoteWordAudioResponse(statusCode: 404, bytes: Uint8List(0)),
        );
        final malformed = RemoteWordAudioClient(
          baseUrl: 'https://audio.example.test/audio',
          request: (_) async => RemoteWordAudioResponse(
            statusCode: 200,
            bytes: Uint8List.fromList(const [1, 2, 3]),
          ),
        );
        final timedOut = RemoteWordAudioClient(
          baseUrl: 'https://audio.example.test/audio',
          request: (_) => throw TimeoutException('test timeout'),
        );

        final notFound = isA<RemoteWordAudioException>().having(
          (error) => error.failure,
          'failure',
          RemoteWordAudioFailure.notFound,
        );
        final invalidAudio = isA<RemoteWordAudioException>().having(
          (error) => error.failure,
          'failure',
          RemoteWordAudioFailure.invalidAudio,
        );
        final timeout = isA<RemoteWordAudioException>().having(
          (error) => error.failure,
          'failure',
          RemoteWordAudioFailure.timeout,
        );

        await expectLater(missing.fetch('missing'), throwsA(notFound));
        await expectLater(malformed.fetch('malformed'), throwsA(invalidAudio));
        await expectLater(timedOut.fetch('slow'), throwsA(timeout));
      },
    );

    test('rejects an absent or non-HTTP server address', () {
      expect(
        () => RemoteWordAudioClient.normalizeBaseUrl(''),
        throwsA(
          isA<RemoteWordAudioException>().having(
            (error) => error.failure,
            'failure',
            RemoteWordAudioFailure.notConfigured,
          ),
        ),
      );
      expect(
        () => RemoteWordAudioClient.normalizeBaseUrl('ftp://audio.example'),
        throwsA(
          isA<RemoteWordAudioException>().having(
            (error) => error.failure,
            'failure',
            RemoteWordAudioFailure.invalidUrl,
          ),
        ),
      );
    });
  });
}
