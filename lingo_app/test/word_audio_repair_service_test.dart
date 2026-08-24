import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:lingo_app/core/services/remote_word_audio_client.dart';
import 'package:lingo_app/core/services/tts_provider.dart';
import 'package:lingo_app/core/services/word_audio_repair_service.dart';

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

const _config = WordAudioRepairTtsConfig(
  apiKey: 'test-key',
  baseUrl: 'http://127.0.0.1',
  workspaceId: 'test-workspace',
);

void main() {
  late Directory tempDir;
  late Uint8List generatedBytes;
  late String sentText;
  late String sentInstruction;

  setUp(() async {
    tempDir = await Directory.current.createTemp('word_audio_repair_test_');
    generatedBytes = _pcmWav(amplitude: 2400);
    sentText = '';
    sentInstruction = '';
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  WordAudioRepairService service() {
    return WordAudioRepairService(
      dataDirProvider: () async => tempDir,
      synthesis:
          ({
            required config,
            required text,
            required instruction,
            required language,
          }) async {
            sentText = text;
            sentInstruction = instruction;
            return TtsSynthesisResult(
              audioBytes: generatedBytes,
              chargedCharacters: text.length,
              durationMs: 120,
            );
          },
    );
  }

  Future<File> writeCurrent(String word, Uint8List bytes) async {
    final cache = Directory(p.join(tempDir.path, 'lingo_tts_cache'));
    await cache.create(recursive: true);
    final file = File(
      p.join(cache.path, RemoteWordAudioClient.audioFileNameFor(word)),
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  test(
    'creates a reviewed one-word plan using the canonical v2 cache key',
    () async {
      final oldBytes = _pcmWav(amplitude: 1100);
      final target = await writeCurrent('Attribute', oldBytes);
      final repair = service();

      final plan = await repair.createPlan(
        const WordAudioRepairRequest(
          word: 'Attribute',
          partOfSpeech: 'noun',
          ipa: '/ˈætrɪbjuːt/',
        ),
      );

      expect(plan.word, 'Attribute');
      expect(plan.normalCalls, 1);
      expect(plan.maxAttempts, 3);
      expect(plan.hasExistingFile, isTrue);
      expect(plan.existingFileIsValid, isTrue);
      expect(plan.targetFile.path, target.path);
      expect(plan.instruction, contains('noun'));
      expect(plan.instruction, contains('/ˈætrɪbjuːt/'));
    },
  );

  test(
    'stages validated audio before it changes the formal local cache',
    () async {
      final oldBytes = _pcmWav(amplitude: 1100);
      final target = await writeCurrent('attribute', oldBytes);
      final repair = service();
      final plan = await repair.createPlan(
        const WordAudioRepairRequest(
          word: 'attribute',
          partOfSpeech: 'noun',
          ipa: '/ˈætrɪbjuːt/',
        ),
      );

      final staged = await repair.generateStagedAudio(plan, _config);

      expect(sentText, 'attribute');
      expect(sentInstruction, contains('noun'));
      expect(sentInstruction, contains('/ˈætrɪbjuːt/'));
      expect(await staged.stagedFile.exists(), isTrue);
      expect(await staged.auditFile.exists(), isTrue);
      expect(await target.readAsBytes(), orderedEquals(oldBytes));
      final audit = jsonDecode(await staged.auditFile.readAsString());
      expect(audit['scope'], 'local_cache_only');
      expect(audit['serverPublished'], isFalse);
    },
  );

  test('accepting a staged WAV retains a backup and can restore it', () async {
    final oldBytes = _pcmWav(amplitude: 1100);
    final target = await writeCurrent('attribute', oldBytes);
    final repair = service();
    final plan = await repair.createPlan(
      const WordAudioRepairRequest(
        word: 'attribute',
        note: 'Use the noun pronunciation with a clear opening vowel.',
      ),
    );
    final staged = await repair.generateStagedAudio(plan, _config);

    final applied = await repair.applyStagedAudio(staged);

    expect(applied.replacedExistingAudio, isTrue);
    expect(applied.backupFile, isNotNull);
    expect(await applied.backupFile!.exists(), isTrue);
    expect(await applied.backupFile!.readAsBytes(), orderedEquals(oldBytes));
    expect(await target.readAsBytes(), orderedEquals(generatedBytes));

    final restored = await repair.restorePreviousAudio(applied);

    expect(await restored.targetFile.readAsBytes(), orderedEquals(oldBytes));
    expect(restored.displacedRepairFile, isNotNull);
    expect(
      await restored.displacedRepairFile!.readAsBytes(),
      orderedEquals(generatedBytes),
    );
  });

  test(
    'does not accept an invalid staged file over a valid cache entry',
    () async {
      final oldBytes = _pcmWav(amplitude: 1100);
      final target = await writeCurrent('attribute', oldBytes);
      final repair = service();
      final plan = await repair.createPlan(
        const WordAudioRepairRequest(word: 'attribute'),
      );
      final staged = await repair.generateStagedAudio(plan, _config);
      await staged.stagedFile.writeAsBytes(const [1, 2, 3], flush: true);

      await expectLater(
        repair.applyStagedAudio(staged),
        throwsA(
          isA<WordAudioRepairException>().having(
            (error) => error.failure,
            'failure',
            WordAudioRepairFailure.stagedAudioMissing,
          ),
        ),
      );
      expect(await target.readAsBytes(), orderedEquals(oldBytes));
    },
  );
}
