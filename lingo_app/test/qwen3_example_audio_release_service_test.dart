import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:lingo_app/core/services/remote_example_audio_client.dart';
import 'package:lingo_app/core/services/tts_service.dart';
import 'package:lingo_app/core/services/word_audio_release_service.dart';
import 'package:lingo_app/data/database/app_database.dart';
import 'package:lingo_app/data/repositories/repositories.dart';

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

const _config = WordAudioReleaseTtsConfig(
  apiKey: 'test-key',
  baseUrl: 'http://127.0.0.1',
  model: 'qwen3-tts-flash',
  voice: 'Katerina',
  resourceId: 'test-workspace',
);

TtsPreCacheResult _emptySynthesis() => const TtsPreCacheResult(
  total: 0,
  success: 0,
  skipped: 0,
  failed: 0,
  apiCalls: 0,
  chargedCharacters: 0,
  audioBytes: 0,
  cancelled: false,
  failedItems: [],
);

void main() {
  late Directory tempDir;
  late File script;

  setUp(() async {
    tempDir = await Directory.current.createTemp('qwen3_example_release_test_');
    script = File(p.join(tempDir.path, 'publisher.ps1'));
    await script.writeAsString('# test publisher');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<void> stage(String text) async {
    final cache = Directory(p.join(tempDir.path, 'lingo_tts_cache'));
    await cache.create(recursive: true);
    final file = File(
      p.join(cache.path, RemoteExampleAudioClient.audioFileNameFor(text)),
    );
    await file.writeAsBytes(_pcmWav(), flush: true);
  }

  Future<void> stageLegacy(String text) async {
    final cache = Directory(p.join(tempDir.path, 'lingo_tts_cache'));
    await cache.create(recursive: true);
    final file = File(
      p.join(
        cache.path,
        RemoteExampleAudioClient.audioFileNameFor(
          text,
          profileVersion: RemoteExampleAudioClient.legacyAudioKeyProfileVersion,
        ),
      ),
    );
    await file.writeAsBytes(_pcmWav(), flush: true);
  }

  WordAudioReleaseService service({WordAudioReleasePublisher? publisher}) {
    return WordAudioReleaseService.qwen3Examples(
      dataDirProvider: () async => tempDir,
      isWindows: () => true,
      synthesis:
          ({
            required WordAudioReleaseTtsConfig config,
            required List<TtsPreCacheItem> items,
            required int maxRetries,
            bool Function()? shouldCancel,
            void Function(TtsPreCacheProgress progress)? onProgress,
          }) async => _emptySynthesis(),
      publisher: publisher,
      publisherScriptLocator: () async => script,
    );
  }

  const targets = [
    WordAudioReleaseListTarget(listNumber: 4, listId: 4, listName: 'List 4'),
  ];

  const examples = [
    WordAudioReleaseItem(
      text: 'A gardener waters the flowers before sunrise.',
      listName: 'List 4',
      listId: 4,
    ),
    WordAudioReleaseItem(
      text: 'Please close the window before you leave.',
      listName: 'List 4',
      listId: 4,
    ),
  ];

  test('uses a separate stable key and /examples server package profile', () {
    const text = 'Please close the window before you leave.';
    final fileName = RemoteExampleAudioClient.audioFileNameFor(text);

    expect(
      RemoteExampleAudioClient.audioKeyProfileVersion,
      'qwen3-tts-flash-katerina-british-instruction-example-v2',
    );
    expect(fileName, matches(RegExp(r'^qwen3-example-[a-f0-9]{64}\.wav$')));
    expect(
      RemoteExampleAudioClient.audioKeyFor(text),
      isNot(RemoteExampleAudioClient.audioKeyFor('$text!')),
    );
    final client = RemoteExampleAudioClient(
      baseUrl: 'https://audio.example.test/audio',
      request: (_) => throw UnimplementedError(),
      probeRequest: (_) => throw UnimplementedError(),
    );
    expect(
      client.buildAudioUri(text).toString(),
      'https://audio.example.test/audio/v1/en/examples/$fileName',
    );
    final legacyFileName = RemoteExampleAudioClient.audioFileNameFor(
      text,
      profileVersion: RemoteExampleAudioClient.legacyAudioKeyProfileVersion,
    );
    expect(legacyFileName, isNot(fileName));
    expect(RemoteExampleAudioClient.audioFileNamesFor(text), [
      fileName,
      legacyFileName,
    ]);
  });

  test(
    'recognizes a validated v1 Qwen3 cache after the v2 profile upgrade',
    () async {
      const text = 'Please close the window before you leave.';
      await stageLegacy(text);
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final tts = TtsService(
        settingsRepo: SettingsRepository(database),
        dataDirProvider: () async => tempDir,
      );

      final presence = await tts.getCachedAudioPresence(
        [text],
        provider: TtsService.qwen3FlashKaterinaProvider,
        lang: 'en',
      );

      expect(presence, {text: true});
    },
  );

  test(
    'finds a v1 example on the server after the v2 key returns 404',
    () async {
      const text = 'Please close the window before you leave.';
      final requestedFiles = <String>[];
      final legacyFileName = RemoteExampleAudioClient.audioFileNameFor(
        text,
        profileVersion: RemoteExampleAudioClient.legacyAudioKeyProfileVersion,
      );
      final client = RemoteExampleAudioClient(
        baseUrl: 'https://audio.example.test/audio',
        request: (_) => throw UnimplementedError(),
        probeRequest: (url) async {
          requestedFiles.add(url.pathSegments.last);
          return RemoteExampleAudioResponse(
            statusCode: url.pathSegments.last == legacyFileName ? 200 : 404,
            bytes: url.pathSegments.last == legacyFileName
                ? _pcmWav()
                : Uint8List(0),
          );
        },
      );

      expect(await client.probe(text), isNull);
      expect(requestedFiles, RemoteExampleAudioClient.audioFileNamesFor(text));
    },
  );

  test(
    'reuses a validated v1 Qwen3 cache when packaging an example List',
    () async {
      for (final item in examples) {
        await stageLegacy(item.text);
      }
      final release = service();

      final plan = await release.createPlan(lists: targets, items: examples);
      final package = await release.createPackage(plan);

      expect(plan.reusableWords, 2);
      expect(plan.normalCalls, 0);
      expect(
        package.fileNames,
        [
          for (final item in examples)
            RemoteExampleAudioClient.audioFileNameFor(
              item.text,
              profileVersion:
                  RemoteExampleAudioClient.legacyAudioKeyProfileVersion,
            ),
        ]..sort(),
      );
    },
  );

  test(
    'packages validated Qwen3 examples without touching word WAV names',
    () async {
      for (final item in examples) {
        await stage(item.text);
      }
      WordAudioPublisherInvocation? invocation;
      final release = service(
        publisher: (value) async {
          invocation = value;
          return const WordAudioPublisherResult(exitCode: 0, output: 'done');
        },
      );

      final plan = await release.createPlan(lists: targets, items: examples);
      final result = await release.run(
        confirmedPlan: plan,
        config: _config,
        publish: true,
      );
      final package = result.package!;
      final latest = await release.loadLatestPackage();

      expect(plan.totalWords, 2);
      expect(plan.normalCalls, 0);
      expect(result.status, WordAudioReleaseRunStatus.published);
      expect(
        p.basename(package.sourceDirectory.path),
        startsWith('lingo_example_audio_upload_v2_list4_'),
      );
      expect(
        package.fileNames,
        everyElement(matches(RegExp(r'^qwen3-example-[a-f0-9]{64}\.wav$'))),
      );
      expect(invocation, isNotNull);
      expect(invocation!.releaseKind, 'example');
      expect(latest, isNotNull);
      expect(latest!.fileNames, package.fileNames);
    },
  );
}
