import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lingo_app/core/i18n/app_strings.dart';
import 'package:lingo_app/core/services/tts_adapters/qwen_tts_adapter.dart';
import 'package:lingo_app/core/services/tts_service.dart';
import 'package:lingo_app/core/utils/answer_checker.dart';
import 'package:lingo_app/core/utils/text_normalizer.dart';
import 'package:lingo_app/data/database/app_database.dart';
import 'package:lingo_app/data/repositories/repositories.dart';

void main() {
  group('AppStrings.get', () {
    test('returns English translation', () {
      expect(AppStrings.get('settings', 'en'), 'Settings');
      expect(AppStrings.get('save', 'en'), 'Save');
    });

    test('returns Chinese translation', () {
      expect(AppStrings.get('settings', 'zh'), '设置');
      expect(AppStrings.get('save', 'zh'), '保存');
    });

    test('translates built-in word book names', () {
      expect(AppStrings.get('book_kaoyan', 'en'), 'Postgraduate Entrance Exam');
      expect(AppStrings.get('book_kaoyan', 'zh'), '考研');
    });

    test('falls back to English when language missing', () {
      expect(AppStrings.get('settings', 'fr'), 'Settings');
    });

    test('falls back to the key when key missing', () {
      expect(AppStrings.get('no_such_key', 'en'), 'no_such_key');
    });

    test('interpolates params with {name} placeholders', () {
      expect(
        AppStrings.get('n_words', 'en', params: {'count': '7'}),
        '7 words',
      );
      expect(AppStrings.get('n_words', 'zh', params: {'count': '7'}), '7 个单词');
    });
  });

  group('TextNormalizer', () {
    test('normalizes curly quote and apostrophe variants', () {
      expect(
        TextNormalizer.normalizeQuotes('“Don’t” and ‘can’t’'),
        '"Don\'t" and \'can\'t\'',
      );
      expect(
        TextNormalizer.normalizeQuotes('＂quote＂ ＇mark＇'),
        '"quote" \'mark\'',
      );
    });
  });

  group('AnswerChecker', () {
    test('compares meanings after quote and separator normalization', () {
      expect(AnswerChecker.isAnswerCorrect('don’t', "don't"), isTrue);
      expect(AnswerChecker.isAnswerCorrect('装满', '装满;盛满'), isTrue);
      expect(AnswerChecker.isFillAnswerCorrect('盛满', '装满;盛满'), isTrue);
      expect(AnswerChecker.isAnswerCorrect(' v. 装满 ', 'v.装满；占满'), isTrue);
      expect(AnswerChecker.isAnswerCorrect('微小的', 'adj. 微小的'), isTrue);
      expect(AnswerChecker.missingMeanings('don’t', "don't；can't"), ["can't"]);
    });
  });

  group('QwenTtsAdapter word profile', () {
    test('resolves the Beijing workspace endpoint', () {
      expect(
        QwenTtsAdapter.resolveBaseUrl('', 'workspace-id'),
        'https://workspace-id.cn-beijing.maas.aliyuncs.com',
      );
      expect(
        QwenTtsAdapter.resolveBaseUrl(
          'https://workspace-id.cn-beijing.maas.aliyuncs.com/api/v1/services/audio/tts/SpeechSynthesizer',
          'workspace-id',
        ),
        'https://workspace-id.cn-beijing.maas.aliyuncs.com',
      );
      expect(
        QwenTtsAdapter.resolveBaseUrl(
          'https://dashscope.aliyuncs.com/',
          'workspace-id',
        ),
        'https://workspace-id.cn-beijing.maas.aliyuncs.com',
      );
    });

    test('rejects a missing Workspace ID', () {
      expect(
        () => QwenTtsAdapter.resolveBaseUrl('', '  '),
        throwsArgumentError,
      );
    });

    test('builds the fixed English word payload', () {
      final payload = QwenTtsAdapter.buildPayload(
        text: 'pronunciation',
        language: 'en',
        instruction: QwenTtsAdapter.wordInstruction,
      );
      final input = payload['input'] as Map<String, dynamic>;

      expect(payload['model'], QwenTtsAdapter.wordModel);
      expect(input['voice'], QwenTtsAdapter.wordVoice);
      expect(QwenTtsAdapter.wordVoice, 'qwen-audio-3.0-tts-plus-loongdeanliu');
      expect(input['format'], 'wav');
      expect(input['sample_rate'], 48000);
      expect(input['volume'], 50);
      expect(input['rate'], 1.0);
      expect(input['pitch'], 1.0);
      expect(input['seed'], 0);
      expect(input['language_hints'], ['en']);
      expect(input['instruction'], QwenTtsAdapter.wordInstruction);
      expect(
        QwenTtsAdapter.wordCacheProfileVersion,
        'qwen-word-wav-48k-british-v2',
      );
      expect(QwenTtsAdapter.wordAudioMimeType, 'audio/wav');
      expect(QwenTtsAdapter.wordCacheFileExtension, 'wav');
    });

    test('omits a missing or blank instruction for unrelated Qwen use', () {
      final missing = QwenTtsAdapter.buildPayload(text: 'A full sentence.');
      final blank = QwenTtsAdapter.buildPayload(
        text: 'A full sentence.',
        instruction: '   ',
      );

      expect(missing['input'], isNot(contains('instruction')));
      expect(blank['input'], isNot(contains('instruction')));
    });

    test('adds a terminal boundary only for a bare English word', () {
      expect(
        QwenTtsAdapter.bareEnglishWordFallbackText('extension'),
        'extension.',
      );
      expect(
        QwenTtsAdapter.bareEnglishWordFallbackText('ice cream'),
        'ice cream.',
      );
      expect(QwenTtsAdapter.bareEnglishWordFallbackText('already.'), isNull);
      expect(
        QwenTtsAdapter.bareEnglishWordFallbackText('扩展', language: 'zh'),
        isNull,
      );
    });
  });

  group('Word audio playback source', () {
    test('defaults to remote WAV and accepts only the direct TTS value', () {
      expect(
        TtsService.normalizeWordPlaybackSource(null),
        TtsService.remoteWordPlaybackSource,
      );
      expect(
        TtsService.normalizeWordPlaybackSource('configured_tts'),
        TtsService.configuredTtsWordPlaybackSource,
      );
      expect(
        TtsService.normalizeWordPlaybackSource('unexpected'),
        TtsService.remoteWordPlaybackSource,
      );
    });
  });

  group('TTS cache records', () {
    late AppDatabase database;
    late TtsRepository repository;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = TtsRepository(database);
    });

    tearDown(() => database.close());

    test('updates a failed record when the same word is retried', () async {
      await repository.upsertCacheRecord(
        provider: 'qwen',
        language: 'en',
        text: 'extension',
        cacheKey: 'first-key',
        status: 'failed',
        errorMessage: 'temporary service error',
      );
      await repository.upsertCacheRecord(
        provider: 'qwen',
        language: 'en',
        text: 'extension',
        cacheKey: 'second-key',
        status: 'cached',
        cachePath: 'D:/LingoDemoData/lingo_tts_cache/extension.wav',
        audioBytes: 1024,
        chargedCharacters: 9,
      );

      final records = await repository.getCacheRecords(
        provider: 'qwen',
        language: 'en',
      );

      expect(records, hasLength(1));
      expect(records.single.textValue, 'extension');
      expect(records.single.status, 'cached');
      expect(records.single.cacheKey, 'second-key');
      expect(records.single.errorMessage, isNull);
      expect(records.single.audioBytes, 1024);
    });
  });

  group('TTS cache quota', () {
    late Directory tempDir;
    late AppDatabase database;
    late TtsRepository repository;
    late TtsService service;

    setUp(() async {
      tempDir = await Directory.current.createTemp('tts_cache_quota_test_');
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

    test('prunes the least recently used Qwen audio and its record', () async {
      final cacheDir = Directory('${tempDir.path}/lingo_tts_cache');
      await cacheDir.create(recursive: true);
      final oldest = File('${cacheDir.path}/old-qwen-en.wav');
      final newest = File('${cacheDir.path}/new-qwen-en.wav');
      await oldest.writeAsBytes(List<int>.filled(80, 1));
      await newest.writeAsBytes(List<int>.filled(80, 2));
      await oldest.setLastModified(
        DateTime.now().subtract(const Duration(days: 1)),
      );

      await repository.upsertCacheRecord(
        provider: 'qwen',
        language: 'en',
        text: 'old',
        cacheKey: 'old-key',
        status: 'cached',
        cachePath: oldest.path,
        audioBytes: 80,
      );
      await repository.upsertCacheRecord(
        provider: 'qwen',
        language: 'en',
        text: 'new',
        cacheKey: 'new-key',
        status: 'cached',
        cachePath: newest.path,
        audioBytes: 80,
      );

      final result = await service.enforceCacheLimit(limitBytes: 120);

      expect(result.beforeBytes, 160);
      expect(result.afterBytes, 80);
      expect(result.removedFiles, 1);
      expect(result.removedRecords, 1);
      expect(await oldest.exists(), isFalse);
      expect(await newest.exists(), isTrue);
      final records = await repository.getCacheRecords(
        provider: 'qwen',
        language: 'en',
      );
      expect(records.map((record) => record.textValue), ['new']);
    });
  });
}
