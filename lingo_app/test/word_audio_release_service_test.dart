import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:lingo_app/core/services/remote_word_audio_client.dart';
import 'package:lingo_app/core/services/tts_service.dart';
import 'package:lingo_app/core/services/word_audio_release_service.dart';

Uint8List _pcmWav({int durationMilliseconds = 250, int amplitude = 1600}) {
  const sampleRate = 48000;
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
  model: 'test-model',
  voice: 'test-voice',
  resourceId: 'test-workspace',
);

TtsPreCacheResult _synthesisResult({int failed = 0}) {
  return TtsPreCacheResult(
    total: 1,
    success: failed == 0 ? 1 : 0,
    skipped: 0,
    failed: failed,
    apiCalls: failed == 0 ? 1 : 3,
    chargedCharacters: 0,
    audioBytes: 0,
    cancelled: false,
    failedItems: const [],
  );
}

void main() {
  late Directory tempDir;
  late File script;

  setUp(() async {
    tempDir = await Directory.current.createTemp('word_audio_release_test_');
    script = File(p.join(tempDir.path, 'publisher.ps1'));
    await script.writeAsString('# test publisher');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<void> stage(String word) async {
    final cache = Directory(p.join(tempDir.path, 'lingo_tts_cache'));
    await cache.create(recursive: true);
    final file = File(
      p.join(cache.path, RemoteWordAudioClient.audioFileNameFor(word)),
    );
    await file.writeAsBytes(_pcmWav(), flush: true);
  }

  WordAudioReleaseService service({
    required WordAudioReleaseSynthesis synthesis,
    WordAudioReleasePublisher? publisher,
    bool isWindows = true,
  }) {
    return WordAudioReleaseService(
      dataDirProvider: () async => tempDir,
      isWindows: () => isWindows,
      synthesis: synthesis,
      publisher: publisher,
      publisherScriptLocator: () async => script,
    );
  }

  Future<TtsPreCacheResult> noOpSynthesis({
    required WordAudioReleaseTtsConfig config,
    required List<TtsPreCacheItem> items,
    required int maxRetries,
    bool Function()? shouldCancel,
    void Function(TtsPreCacheProgress progress)? onProgress,
  }) async => _synthesisResult();

  List<WordAudioReleaseItem> items() => const [
    WordAudioReleaseItem(text: 'alpha', listName: 'List 4', listId: 4),
    WordAudioReleaseItem(text: 'bravo', listName: 'List 4', listId: 4),
    WordAudioReleaseItem(text: 'charlie', listName: 'List 4', listId: 4),
  ];

  List<WordAudioReleaseListTarget> targets({
    int listNumber = 4,
    int listId = 4,
    String listName = 'List 4',
  }) => [
    WordAudioReleaseListTarget(
      listNumber: listNumber,
      listId: listId,
      listName: listName,
    ),
  ];

  test(
    'plans exact normal calls and three-attempt maximum from valid cache',
    () async {
      await stage('alpha');
      final release = service(synthesis: noOpSynthesis);

      final plan = await release.createPlan(lists: targets(), items: items());

      expect(plan.totalWords, 3);
      expect(plan.reusableWords, 1);
      expect(plan.normalCalls, 2);
      expect(plan.maxAttempts, 6);
      expect(plan.pendingItems.map((item) => item.text), ['bravo', 'charlie']);
    },
  );

  test(
    'releases multiple Lists as one deduplicated package and publisher run',
    () async {
      for (final word in ['alpha', 'bravo', 'charlie']) {
        await stage(word);
      }
      WordAudioPublisherInvocation? invocation;
      final release = service(
        synthesis: noOpSynthesis,
        publisher: (value) async {
          invocation = value;
          return const WordAudioPublisherResult(exitCode: 0, output: 'done');
        },
      );
      final plan = await release.createPlan(
        lists: [
          ...targets(),
          ...targets(listNumber: 5, listId: 5, listName: 'List 5'),
        ],
        items: const [
          WordAudioReleaseItem(text: 'alpha', listName: 'List 4', listId: 4),
          WordAudioReleaseItem(text: 'bravo', listName: 'List 4', listId: 4),
          WordAudioReleaseItem(text: 'bravo', listName: 'List 5', listId: 5),
          WordAudioReleaseItem(text: 'charlie', listName: 'List 5', listId: 5),
        ],
      );

      expect(plan.listNumbers, [4, 5]);
      expect(plan.totalWords, 3);
      expect(plan.normalCalls, 0);
      expect(plan.maxAttempts, 0);

      final result = await release.run(
        confirmedPlan: plan,
        config: _config,
        publish: true,
      );
      final recovered = await release.loadLatestPackage();

      expect(result.status, WordAudioReleaseRunStatus.published);
      expect(result.package!.listNumbers, [4, 5]);
      expect(result.package!.expectedCount, 3);
      expect(
        p.basename(result.package!.sourceDirectory.path),
        startsWith('lingo_word_audio_upload_v2_batch4-5-n2_'),
      );
      expect(invocation, isNotNull);
      expect(invocation!.listNumber, 4);
      expect(invocation!.expectedCount, 3);
      expect(recovered!.listNumbers, [4, 5]);
    },
  );

  test(
    'packages only canonical validated WAV files with ZIP and report',
    () async {
      for (final item in items()) {
        await stage(item.text);
      }
      final release = service(synthesis: noOpSynthesis);
      final plan = await release.createPlan(lists: targets(), items: items());

      final package = await release.createPackage(plan);
      final sourceFiles = await package.sourceDirectory.list().toList();
      final zip = ZipDecoder().decodeBytes(
        await package.archiveFile.readAsBytes(),
      );

      expect(plan.isReadyForPackaging, isTrue);
      expect(sourceFiles.whereType<File>(), hasLength(3));
      expect(
        sourceFiles.whereType<File>().map((file) => p.basename(file.path)),
        everyElement(matches(RegExp(r'^[a-f0-9]{64}\.wav$'))),
      );
      expect(zip.numberOfFiles(), 3);
      expect(await package.reportFile.exists(), isTrue);
      expect(await release.loadLatestPackage(), isNotNull);
    },
  );

  test('uses compact Windows-safe package names for a 72-List batch', () async {
    final batchTargets = [
      for (var listNumber = 81; listNumber <= 152; listNumber++)
        WordAudioReleaseListTarget(
          listNumber: listNumber,
          listId: listNumber,
          listName: 'List $listNumber',
        ),
    ];
    final batchItems = [
      for (final target in batchTargets)
        WordAudioReleaseItem(
          text: 'word${target.listNumber}',
          listName: target.listName,
          listId: target.listId,
        ),
    ];
    for (final item in batchItems) {
      await stage(item.text);
    }
    final release = service(synthesis: noOpSynthesis);
    final plan = await release.createPlan(
      lists: batchTargets,
      items: batchItems,
    );

    final package = await release.createPackage(plan);
    final sourceName = p.basename(package.sourceDirectory.path);
    final archiveName = p.basename(package.archiveFile.path);
    final reportName = p.basename(package.reportFile.path);

    expect(plan.listNumbers, List<int>.generate(72, (index) => index + 81));
    expect(package.expectedCount, 72);
    expect(
      sourceName,
      startsWith('lingo_word_audio_upload_v2_batch81-152-n72_'),
    );
    expect(
      reportName,
      startsWith('lingo_word_audio_release_v2_batch81-152-n72_'),
    );
    expect(sourceName.length, lessThanOrEqualTo(255));
    expect(archiveName.length, lessThanOrEqualTo(255));
    expect(reportName.length, lessThanOrEqualTo(255));
    expect(await package.sourceDirectory.exists(), isTrue);
    expect(await package.archiveFile.exists(), isTrue);
    expect(await package.reportFile.exists(), isTrue);
  });

  test('does not publish when synthesis reports a failed word', () async {
    var publisherCalls = 0;
    final release = service(
      synthesis:
          ({
            required WordAudioReleaseTtsConfig config,
            required List<TtsPreCacheItem> items,
            required int maxRetries,
            bool Function()? shouldCancel,
            void Function(TtsPreCacheProgress progress)? onProgress,
          }) async => _synthesisResult(failed: 1),
      publisher: (invocation) async {
        publisherCalls++;
        return const WordAudioPublisherResult(
          exitCode: 0,
          output: 'unexpected',
        );
      },
    );
    final plan = await release.createPlan(lists: targets(), items: items());

    final result = await release.run(
      confirmedPlan: plan,
      config: _config,
      publish: true,
    );

    expect(result.status, WordAudioReleaseRunStatus.synthesisFailed);
    expect(publisherCalls, 0);
    expect(result.package, isNull);
  });

  test('recognizes a non-interactive sudo password prompt', () {
    final release = service(synthesis: noOpSynthesis);

    expect(
      release.isInteractiveSudoRequired(
        const WordAudioPublisherResult(
          exitCode: 1,
          output:
              'sudo: a password is required\n'
              'sudo: a terminal is required to read the password\n',
        ),
      ),
      isTrue,
    );
  });

  test(
    'keeps the last valid package recoverable after a later failed run',
    () async {
      for (final item in items()) {
        await stage(item.text);
      }
      final release = service(
        synthesis:
            ({
              required WordAudioReleaseTtsConfig config,
              required List<TtsPreCacheItem> items,
              required int maxRetries,
              bool Function()? shouldCancel,
              void Function(TtsPreCacheProgress progress)? onProgress,
            }) async => _synthesisResult(failed: 1),
      );
      final priorPlan = await release.createPlan(
        lists: targets(),
        items: items(),
      );
      final priorPackage = await release.createPackage(priorPlan);
      final laterPlan = await release.createPlan(
        lists: targets(listNumber: 5, listId: 5, listName: 'List 5'),
        items: const [
          WordAudioReleaseItem(text: 'delta', listName: 'List 5', listId: 5),
        ],
      );

      final result = await release.run(
        confirmedPlan: laterPlan,
        config: _config,
        publish: true,
      );
      final recovered = await release.loadLatestPackage();

      expect(result.status, WordAudioReleaseRunStatus.synthesisFailed);
      expect(recovered, isNotNull);
      expect(
        recovered!.sourceDirectory.path,
        priorPackage.sourceDirectory.path,
      );
    },
  );

  test(
    'refuses a release run outside Windows before synthesis or publish',
    () async {
      var synthesisCalls = 0;
      var publisherCalls = 0;
      final release = service(
        isWindows: false,
        synthesis:
            ({
              required WordAudioReleaseTtsConfig config,
              required List<TtsPreCacheItem> items,
              required int maxRetries,
              bool Function()? shouldCancel,
              void Function(TtsPreCacheProgress progress)? onProgress,
            }) async {
              synthesisCalls++;
              return _synthesisResult();
            },
        publisher: (invocation) async {
          publisherCalls++;
          return const WordAudioPublisherResult(
            exitCode: 0,
            output: 'unexpected',
          );
        },
      );
      final plan = await release.createPlan(lists: targets(), items: items());

      await expectLater(
        release.run(confirmedPlan: plan, config: _config, publish: true),
        throwsA(isA<WordAudioReleaseUnsupportedPlatformException>()),
      );
      expect(synthesisCalls, 0);
      expect(publisherCalls, 0);
    },
  );
}
