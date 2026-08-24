import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:lingo_app/core/services/tts_adapters/tencent_tts_adapter.dart';

Uint8List _pcmWav({
  int sampleRate = TencentTtsAdapter.weWinnySampleRate,
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
  const fixedTime = 1772784000; // 2026-03-06T08:00:00Z

  test('builds the documented fixed WeWinny TextToVoice payload', () {
    expect(
      TencentTtsAdapter.buildPayload(
        text: 'Please close the window before you leave.',
        sessionId: 'offline-session-1',
      ),
      {
        'Text': 'Please close the window before you leave.',
        'SessionId': 'offline-session-1',
        'ModelType': 1,
        'VoiceType': 501009,
        'PrimaryLanguage': 2,
        'SampleRate': 24000,
        'Codec': 'wav',
        'Volume': 0,
        'Speed': 0,
      },
    );
  });

  test('builds the WeJack 16 kHz payload without changing the default', () {
    expect(
      TencentTtsAdapter.buildPayload(
        text: 'A WeJack example.',
        sessionId: 'offline-wejack-1',
        voiceType: TencentTtsAdapter.weJackVoiceType,
        sampleRate: TencentTtsAdapter.weJackSampleRate,
      ),
      {
        'Text': 'A WeJack example.',
        'SessionId': 'offline-wejack-1',
        'ModelType': 1,
        'VoiceType': 101050,
        'PrimaryLanguage': 2,
        'SampleRate': 16000,
        'Codec': 'wav',
        'Volume': 0,
        'Speed': 0,
      },
    );
  });

  test('creates a TC3 canonical request without exposing the SecretKey', () {
    final signature = TencentTtsAdapter.buildTc3Authorization(
      secretId: 'test-secret-id',
      secretKey: 'test-secret-key',
      endpoint: Uri.parse('https://tts.tencentcloudapi.com/'),
      timestampSeconds: fixedTime,
      payload: '{"Text":"test"}',
    );

    expect(signature.credentialScope, '2026-03-06/tts/tc3_request');
    expect(signature.signedHeaders, 'content-type;host;x-tc-action');
    expect(
      signature.canonicalRequest,
      contains('content-type:application/json; charset=utf-8\n'),
    );
    expect(
      signature.canonicalRequest,
      contains('host:tts.tencentcloudapi.com\n'),
    );
    expect(signature.canonicalRequest, contains('x-tc-action:texttovoice\n'));
    expect(
      signature.authorization,
      startsWith(
        'TC3-HMAC-SHA256 Credential=test-secret-id/2026-03-06/tts/tc3_request, ',
      ),
    );
    expect(signature.authorization, isNot(contains('test-secret-key')));
    expect(signature.canonicalRequest, isNot(contains('test-secret-key')));
    expect(signature.stringToSign, isNot(contains('test-secret-key')));
  });

  test(
    'sends signed WeWinny JSON to a local server and decodes Base64 WAV',
    () async {
      final audio = _pcmWav();
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final received = <String, String>{};
      String? receivedBody;
      final subscription = server.listen((request) {
        unawaited(() async {
          receivedBody = await utf8.decoder.bind(request).join();
          for (final name in [
            'authorization',
            'content-type',
            'host',
            'x-tc-action',
            'x-tc-version',
            'x-tc-timestamp',
            'x-tc-region',
          ]) {
            received[name] = request.headers.value(name) ?? '';
          }
          request.response.headers.contentType = ContentType.json;
          request.response.write(
            jsonEncode({
              'Response': {
                'RequestId': 'local-request-123',
                'Audio': base64Encode(audio),
              },
            }),
          );
          await request.response.close();
        }());
      });
      addTearDown(() async {
        await subscription.cancel();
        await server.close(force: true);
      });

      final adapter = TencentTtsAdapter(
        secretId: 'test-secret-id',
        secretKey: 'test-secret-key',
        endpoint: 'http://${server.address.address}:${server.port}/',
        clock: () =>
            DateTime.fromMillisecondsSinceEpoch(fixedTime * 1000, isUtc: true),
        sessionIdFactory: () => 'offline-session-1',
      );
      final result = await adapter.synthesizeWithMetadata(
        'A short English example.',
        language: 'en',
      );

      final expectedPayload = jsonEncode({
        'Text': 'A short English example.',
        'SessionId': 'offline-session-1',
        'ModelType': 1,
        'VoiceType': 501009,
        'PrimaryLanguage': 2,
        'SampleRate': 24000,
        'Codec': 'wav',
        'Volume': 0,
        'Speed': 0,
      });
      expect(receivedBody, expectedPayload);
      expect(jsonDecode(receivedBody!), jsonDecode(expectedPayload));
      expect(received['content-type'], startsWith('application/json'));
      expect(received['host'], '${server.address.address}:${server.port}');
      expect(received['x-tc-action'], TencentTtsAdapter.action);
      expect(received['x-tc-version'], TencentTtsAdapter.apiVersion);
      expect(received['x-tc-timestamp'], fixedTime.toString());
      expect(received['x-tc-region'], TencentTtsAdapter.defaultRegion);
      expect(
        received['authorization'],
        startsWith('TC3-HMAC-SHA256 Credential='),
      );
      expect(received['authorization'], isNot(contains('test-secret-key')));
      expect(result.audioBytes, audio);
      expect(result.requestId, 'local-request-123');
      expect(result.durationMs, greaterThanOrEqualTo(0));
    },
  );

  test(
    'treats a Tencent business error in an HTTP 200 response as terminal',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final subscription = server.listen((request) {
        unawaited(() async {
          await request.drain<void>();
          request.response.headers.contentType = ContentType.json;
          request.response.write(
            jsonEncode({
              'Response': {
                'RequestId': 'local-request-error',
                'Error': {
                  'Code': 'AuthFailure.SignatureFailure',
                  'Message': 'signature rejected by local test',
                },
              },
            }),
          );
          await request.response.close();
        }());
      });
      addTearDown(() async {
        await subscription.cancel();
        await server.close(force: true);
      });

      final adapter = TencentTtsAdapter(
        secretId: 'test-secret-id',
        secretKey: 'test-secret-key',
        endpoint: 'http://${server.address.address}:${server.port}/',
        sessionIdFactory: () => 'offline-session-2',
      );

      await expectLater(
        adapter.synthesize('A short English example.'),
        throwsA(
          isA<TencentTtsException>()
              .having(
                (error) => error.code,
                'code',
                'AuthFailure.SignatureFailure',
              )
              .having(
                (error) => error.requestId,
                'requestId',
                'local-request-error',
              )
              .having((error) => error.isRetryable, 'isRetryable', isFalse),
        ),
      );
    },
  );

  test('rejects malformed, wrong-rate, short, and silent WeWinny WAVs', () {
    expect(
      TencentTtsAdapter.weWinnyAudioValidationFailure(Uint8List.fromList([1])),
      TencentWeWinnyAudioValidationFailure.invalidWav,
    );
    expect(
      TencentTtsAdapter.weWinnyAudioValidationFailure(
        _pcmWav(sampleRate: 16000),
      ),
      TencentWeWinnyAudioValidationFailure.unexpectedFormat,
    );
    expect(
      TencentTtsAdapter.weWinnyAudioValidationFailure(
        _pcmWav(durationMilliseconds: 100),
      ),
      TencentWeWinnyAudioValidationFailure.tooShort,
    );
    expect(
      TencentTtsAdapter.weWinnyAudioValidationFailure(_pcmWav(amplitude: 0)),
      TencentWeWinnyAudioValidationFailure.silent,
    );
  });

  test(
    'accepts a valid WeJack 16 kHz WAV and rejects 24 kHz for that profile',
    () {
      expect(
        TencentTtsAdapter.audioValidationFailure(
          _pcmWav(sampleRate: TencentTtsAdapter.weJackSampleRate),
          expectedSampleRate: TencentTtsAdapter.weJackSampleRate,
        ),
        isNull,
      );
      expect(
        TencentTtsAdapter.audioValidationFailure(
          _pcmWav(),
          expectedSampleRate: TencentTtsAdapter.weJackSampleRate,
        ),
        TencentWeWinnyAudioValidationFailure.unexpectedFormat,
      );
    },
  );

  test('reads only credential presence from an injectable environment map', () {
    const configured = {
      TencentTtsAdapter.secretIdEnvironmentKey: 'id',
      TencentTtsAdapter.secretKeyEnvironmentKey: 'key',
    };
    expect(TencentTtsAdapter.hasEnvironmentCredentials(configured), isTrue);
    expect(TencentTtsAdapter.environmentCredentialPresence(configured), {
      TencentTtsAdapter.secretIdEnvironmentKey: true,
      TencentTtsAdapter.secretKeyEnvironmentKey: true,
    });
    expect(TencentTtsAdapter.hasEnvironmentCredentials(const {}), isFalse);
  });
}
