import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:lingo_app/core/services/remote_example_audio_client.dart';
import 'package:lingo_app/core/services/tts_adapters/tencent_tts_adapter.dart';
import 'package:lingo_app/core/services/tts_service.dart';
import 'package:lingo_app/core/services/word_audio_release_service.dart';

Uint8List _pcmWav() {
  const sampleRate = 24000;
  const durationMilliseconds = 300;
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
    data.setInt16(offset, 1200, Endian.little);
  }
  return bytes;
}

const _targets = [
  WordAudioReleaseListTarget(listNumber: 4, listId: 4, listName: 'List 4'),
];

const _examples = [
  WordAudioReleaseItem(
    text: 'Please close the window before you leave.',
    listName: 'List 4',
    listId: 4,
  ),
];

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
    tempDir = await Directory.current.createTemp(
      'tencent_wewinny_release_test_',
    );
    script = File(p.join(tempDir.path, 'publisher.ps1'));
    await script.writeAsString('# local test publisher');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  WordAudioReleaseService service({WordAudioReleasePublisher? publisher}) {
    return WordAudioReleaseService.tencentWeWinnyExamples(
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

  Future<void> stageTencent(String text) async {
    final cache = Directory(p.join(tempDir.path, 'lingo_tts_cache'));
    await cache.create(recursive: true);
    final file = File(
      p.join(
        cache.path,
        RemoteExampleAudioProfile.tencentWeWinny.audioFileNameFor(text),
      ),
    );
    await file.writeAsBytes(_pcmWav(), flush: true);
  }

  Future<void> stageWeJack(String text) async {
    final cache = Directory(p.join(tempDir.path, 'lingo_tts_cache'));
    await cache.create(recursive: true);
    final file = File(
      p.join(
        cache.path,
        RemoteExampleAudioProfile.tencentWeJack.audioFileNameFor(text),
      ),
    );
    final bytes = _pcmWav();
    final data = ByteData.sublistView(bytes);
    data.setUint32(24, TencentTtsAdapter.weJackSampleRate, Endian.little);
    data.setUint32(28, TencentTtsAdapter.weJackSampleRate * 2, Endian.little);
    await file.writeAsBytes(bytes, flush: true);
  }

  test('uses an independent Tencent profile, filename, and safe config', () {
    const text = 'Please close the window before you leave.';
    final tencentFile = RemoteExampleAudioProfile.tencentWeWinny
        .audioFileNameFor(text);
    final qwenFile = RemoteExampleAudioClient.audioFileNameFor(text);
    const config = WordAudioReleaseTtsConfig.tencentWeWinny();

    expect(
      RemoteExampleAudioProfile.tencentWeWinny.audioKeyProfileVersion,
      'tencent-text-to-voice-wewinny-501009-en-wav-24k-example-v1',
    );
    expect(
      tencentFile,
      matches(RegExp(r'^tencent-wewinny-example-[a-f0-9]{64}\.wav$')),
    );
    expect(tencentFile, isNot(qwenFile));
    expect(config.apiKey, isEmpty);
    expect(config.baseUrl, 'https://tts.tencentcloudapi.com/');
    expect(config.model, 'TextToVoice');
    expect(config.voice, '501009');
    expect(config.resourceId, 'ap-guangzhou');
  });

  test(
    'packages only Tencent-prefix WAVs and invokes tencent_example',
    () async {
      await stageTencent(_examples.single.text);
      WordAudioPublisherInvocation? invocation;
      final release = service(
        publisher: (value) async {
          invocation = value;
          return const WordAudioPublisherResult(exitCode: 0, output: 'done');
        },
      );

      final plan = await release.createPlan(lists: _targets, items: _examples);
      final result = await release.run(
        confirmedPlan: plan,
        config: const WordAudioReleaseTtsConfig.tencentWeWinny(),
        publish: true,
      );

      expect(plan.normalCalls, 0);
      expect(result.status, WordAudioReleaseRunStatus.published);
      expect(
        p.basename(result.package!.sourceDirectory.path),
        startsWith('lingo_tencent_wewinny_example_audio_upload_v2_list4_'),
      );
      expect(
        result.package!.fileNames.single,
        matches(RegExp(r'^tencent-wewinny-example-[a-f0-9]{64}\.wav$')),
      );
      expect(invocation, isNotNull);
      expect(invocation!.releaseKind, 'tencent_example');
    },
  );

  test('does not treat a Qwen3 example file as a Tencent cache hit', () async {
    final cache = Directory(p.join(tempDir.path, 'lingo_tts_cache'));
    await cache.create(recursive: true);
    final qwenFile = File(
      p.join(
        cache.path,
        RemoteExampleAudioClient.audioFileNameFor(_examples.single.text),
      ),
    );
    await qwenFile.writeAsBytes(_pcmWav(), flush: true);

    final plan = await service().createPlan(lists: _targets, items: _examples);

    expect(plan.reusableWords, 0);
    expect(plan.normalCalls, 1);
    expect(
      TtsService.tencentWeWinnyProvider,
      WordAudioReleaseProfile.tencentWeWinnyExamples.ttsProvider,
    );
  });

  test(
    'mixed WeJack profile reuses WeWinny and accepts new WeJack files',
    () async {
      await stageTencent(_examples.single.text);
      final release = WordAudioReleaseService.tencentWeJackExamples(
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
        publisher: (_) async =>
            const WordAudioPublisherResult(exitCode: 0, output: 'done'),
        publisherScriptLocator: () async => script,
      );
      final plan = await release.createPlan(lists: _targets, items: _examples);
      expect(plan.reusableWords, 1);
      expect(plan.normalCalls, 0);
      expect(
        WordAudioReleaseProfile.tencentWeJackExamples.fileNamePattern.hasMatch(
          RemoteExampleAudioProfile.tencentWeWinny.audioFileNameFor(
            _examples.single.text,
          ),
        ),
        isTrue,
      );
      await stageWeJack('A different example.');
      expect(
        WordAudioReleaseProfile.tencentWeJackExamples.isValidAudio(
          await File(
            p.join(
              tempDir.path,
              'lingo_tts_cache',
              RemoteExampleAudioProfile.tencentWeJack.audioFileNameFor(
                'A different example.',
              ),
            ),
          ).readAsBytes(),
        ),
        isTrue,
      );
    },
  );
}
