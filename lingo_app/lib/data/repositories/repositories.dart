import 'package:drift/drift.dart' show Insertable, Value;

import '../database/app_database.dart';
import '../../core/utils/text_normalizer.dart';
import '../../core/utils/shuffle_helper.dart';

class WordRepository {
  final AppDatabase _db;

  WordRepository(this._db);

  Future<List<Word>> getAllWords() => _db.getAllWords();
  Future<Word?> getWord(int id) => _db.getWord(id);
  Future<int> insertWord(Insertable<Word> word) => _db.insertWord(word);
  Future<void> deleteWord(int id) => _db.deleteWord(id);
  Future<List<Word>> searchWords(String query) => _db.searchWords(query);

  Future<void> updateScenarioExample(int id, String example) {
    return _db.updateWord(id, WordsCompanion(scenarioExample: Value(example)));
  }

  Future<int> insertWordSimple({
    required String english,
    required String chineseMeanings,
    String? pronunciation,
    String? exampleSentence,
    String? scenarioExample,
    String? scenarioTranslation,
  }) {
    return _db.insertWord(
      WordsCompanion(
        english: Value(TextNormalizer.normalizeQuotes(english)),
        chineseMeanings: Value(TextNormalizer.normalizeQuotes(chineseMeanings)),
        pronunciation: Value.absentIfNull(
          pronunciation == null
              ? null
              : TextNormalizer.normalizeQuotes(pronunciation),
        ),
        exampleSentence: Value.absentIfNull(
          exampleSentence == null
              ? null
              : TextNormalizer.normalizeQuotes(exampleSentence),
        ),
        scenarioExample: Value.absentIfNull(
          scenarioExample == null
              ? null
              : TextNormalizer.normalizeQuotes(scenarioExample),
        ),
        scenarioTranslation: Value.absentIfNull(
          scenarioTranslation == null
              ? null
              : TextNormalizer.normalizeQuotes(scenarioTranslation),
        ),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}

class WordListRepository {
  final AppDatabase _db;

  WordListRepository(this._db);

  Future<List<WordList>> getAllLists() => _db.getAllLists();
  Future<WordList?> getList(int id) => _db.getList(id);
  Future<void> deleteList(int id) => _db.deleteList(id);
  Future<void> markListPassed(int id, bool passed) =>
      _db.markListPassed(id, passed);

  Future<int> createList({
    required String name,
    required List<int> wordIds,
    int? bookId,
    List<int>? sortOrders,
    double passThreshold = 0.75,
  }) async {
    final listId = await _db.insertList(
      WordListsCompanion(
        name: Value(name),
        bookId: Value(bookId),
        passThreshold: Value(passThreshold),
        wordCount: Value(wordIds.length),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    final orders = sortOrders ?? List.generate(wordIds.length, (i) => i);
    await _db.addWordsToList(listId, wordIds, orders);
    return listId;
  }

  Future<List<Word>> getWordsForList(int listId) => _db.getWordsForList(listId);

  Future<List<Word>> getWordsForLists(List<int> listIds) =>
      _db.getWordsForLists(listIds);

  Future<List<Word>> getChoiceDistractorWordsForList(int listId) async {
    final listWords = await _db.getWordsForList(listId);
    final listWordIds = listWords.map((w) => w.id).toSet();
    final allWords = await _db.getAllWords();
    return allWords.where((w) => !listWordIds.contains(w.id)).toList();
  }

  Future<int> getWordCountForList(int listId) =>
      _db.getWordCountForList(listId);

  Future<void> shuffleList(int listId, List<int> newOrder) =>
      _db.updateSortOrders(listId, newOrder);

  /// Returns all lists that have been passed (available for Phase 2).
  Future<List<WordList>> getPassedLists() async {
    final all = await _db.getAllLists();
    return all.where((l) => l.isPassed).toList();
  }

  // ─── Word Books ──────────────────────────────────────────────────────────

  Future<int> createBook(String name, int totalWords) => _db.insertBook(
    WordBooksCompanion(
      name: Value(name),
      totalWords: Value(totalWords),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    ),
  );

  Future<List<WordBook>> getAllBooks() => _db.getAllBooks();

  Future<List<WordList>> getListsForBook(int bookId) =>
      _db.getListsForBook(bookId);

  Future<int?> getBookIdForList(int listId) async {
    final list = await _db.getList(listId);
    return list?.bookId;
  }

  /// Reset whole-book word order: collect all words across all lists in the
  /// book, shuffle globally, then redistribute back to the same lists in the
  /// same sizes. Used by the dangerous "词序重置" button.
  Future<void> resetBookWordOrder(int bookId) async {
    final lists = await _db.getListsForBook(bookId);
    if (lists.isEmpty) return;

    final perListWordIds = <int, List<int>>{};
    final pool = <int>[];
    for (final list in lists) {
      final words = await _db.getWordsForList(list.id);
      final ids = words.map((w) => w.id).toList();
      perListWordIds[list.id] = ids;
      pool.addAll(ids);
    }
    if (pool.isEmpty) return;

    final shuffledIdx = ShuffleHelper.generateShuffledIndices(pool.length);
    final shuffledPool = [for (final i in shuffledIdx) pool[i]];

    var cursor = 0;
    for (final list in lists) {
      final originalCount = perListWordIds[list.id]!.length;
      final slice = shuffledPool.sublist(cursor, cursor + originalCount);
      cursor += originalCount;
      await _db.replaceListWords(list.id, slice);
    }
  }
}

class PracticeRepository {
  final AppDatabase _db;

  PracticeRepository(this._db);

  Future<int> createSession({
    required int listId,
    required String mode,
    required int totalCount,
    required int correctCount,
    required double accuracy,
    int? startedAt,
    int? finishedAt,
    String? sessionKind,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final resolvedKind =
        sessionKind ??
        (mode.startsWith('deep_')
            ? PracticeSessionKind.aiLearning
            : PracticeSessionKind.memorization);
    return _db.insertSession(
      PracticeSessionsCompanion(
        listId: Value(listId),
        mode: Value(mode),
        sessionKind: Value(resolvedKind),
        totalCount: Value(totalCount),
        correctCount: Value(correctCount),
        accuracy: Value(accuracy),
        startedAt: Value(startedAt ?? now),
        finishedAt: Value(finishedAt ?? now),
      ),
    );
  }

  Future<PracticeSession?> getSession(int id) => _db.getSession(id);

  Future<List<PracticeSession>> getSessionsForList(int listId) =>
      _db.getSessionsForList(listId);

  Future<List<PracticeSession>> getAllSessions() => _db.getAllSessions();

  Future<List<PracticeSession>> getMemorizationSessionsForList(int listId) =>
      _db.getMemorizationSessionsForList(listId);

  Future<void> recordAnswers(List<PracticeAnswersCompanion> answers) =>
      _db.insertAnswers(answers);

  Future<int> correctCountForSession(int sessionId) =>
      _db.correctAnswerCountForSession(sessionId);

  Future<void> recordErrorWord(int wordId, int listId) =>
      _db.recordError(wordId, listId);

  Future<List<Word>> getErrorWordsForList(int listId) =>
      _db.getErrorWordsForList(listId);

  Future<List<ErrorWordWithCount>> getErrorWordsWithCounts(int listId) =>
      _db.getErrorWordsWithCounts(listId);

  Future<List<ReviewWordStat>> getReviewWordStats({int? bookId}) =>
      _db.getReviewWordStats(bookId: bookId);

  Future<void> resolveErrorWords(
    List<int> wordIds, {
    int? bookId,
    int? listId,
  }) => _db.resolveErrorWords(wordIds, bookId: bookId, listId: listId);

  Future<void> markWordForgotten(int wordId, int listId) =>
      _db.markWordForgotten(wordId, listId);

  Future<void> markWordCueMemory(int wordId, int listId) =>
      _db.markWordCueMemory(wordId, listId);

  Future<List<Word>> getForgottenWordsForList(int listId) =>
      _db.getForgottenWordsForList(listId);

  Future<List<Word>> getCueMemoryWordsForList(int listId) =>
      _db.getCueMemoryWordsForList(listId);

  Future<void> clearForgottenStatus(int wordId, int listId) =>
      _db.clearForgottenStatus(wordId, listId);

  Future<Set<int>> getForgottenWordIdsForList(int listId) async {
    final words = await _db.getForgottenWordsForList(listId);
    return words.map((w) => w.id).toSet();
  }

  Future<Set<int>> getCueMemoryWordIdsForList(int listId) async {
    final words = await _db.getCueMemoryWordsForList(listId);
    return words.map((w) => w.id).toSet();
  }

  Future<void> clearForgottenStatusForWords(
    List<int> wordIds,
    int listId,
  ) async {
    for (final id in wordIds) {
      await _db.clearForgottenStatus(id, listId);
    }
  }

  Future<void> clearForgottenStatusForWordsInScope(
    List<int> wordIds, {
    int? bookId,
  }) => _db.clearForgottenStatusForWordsInScope(wordIds, bookId: bookId);
}

class LearningActivityRepository {
  final AppDatabase _db;

  LearningActivityRepository(this._db);

  Future<int> startActivity({
    required String activityType,
    String? subtype,
    List<int> listIds = const [],
    List<int> wordIds = const [],
    int? startedAt,
  }) => _db.startActivity(
    activityType: activityType,
    subtype: subtype,
    listIds: listIds,
    wordIds: wordIds,
    startedAt: startedAt,
  );

  Future<void> completeActivity(
    int activityId, {
    String? subtype,
    int? questionCount,
    int? correctCount,
    double? accuracy,
    int? turnCount,
    int? targetWordUseCount,
    double? naturalnessAverage,
    double? contextFitAverage,
    int? skillRunCount,
    int? involvedWordCount,
    List<int> wordIds = const [],
    List<int> errorWordIds = const [],
    Map<int, int> wordUsageCounts = const {},
    int? finishedAt,
  }) => _db.completeActivity(
    activityId,
    subtype: subtype,
    questionCount: questionCount,
    correctCount: correctCount,
    accuracy: accuracy,
    turnCount: turnCount,
    targetWordUseCount: targetWordUseCount,
    naturalnessAverage: naturalnessAverage,
    contextFitAverage: contextFitAverage,
    skillRunCount: skillRunCount,
    involvedWordCount: involvedWordCount,
    wordIds: wordIds,
    errorWordIds: errorWordIds,
    wordUsageCounts: wordUsageCounts,
    finishedAt: finishedAt,
  );

  Future<void> abandonActivity(int activityId, {int? finishedAt}) =>
      _db.abandonActivity(activityId, finishedAt: finishedAt);

  Future<LearningActivityRecord?> getActivity(int id) => _db.getActivity(id);

  Future<List<LearningActivityRecord>> getActivitiesForDay(
    DateTime day, {
    int? bookId,
    List<int>? listIds,
    bool completedOnly = true,
  }) => _db.getActivitiesForDay(
    day,
    bookId: bookId,
    listIds: listIds,
    completedOnly: completedOnly,
  );

  Future<List<DailyListReview>> getDailyListReview(
    DateTime day, {
    int? bookId,
  }) => _db.getDailyListReview(day, bookId: bookId);

  Future<DailyAiSummary> getDailyAiSummary(DateTime day, {int? bookId}) =>
      _db.getDailyAiSummary(day, bookId: bookId);
}

class SettingsRepository {
  final AppDatabase _db;

  SettingsRepository(this._db);

  Future<String?> getString(String key) => _db.getSetting(key);

  Future<void> setString(String key, String value) =>
      _db.setSetting(key, value);

  Future<double?> getDouble(String key) async {
    final s = await _db.getSetting(key);
    return s != null ? double.tryParse(s) : null;
  }

  Future<void> setDouble(String key, double value) =>
      _db.setSetting(key, value.toString());

  Future<int?> getInt(String key) async {
    final s = await _db.getSetting(key);
    return s != null ? int.tryParse(s) : null;
  }

  Future<void> setInt(String key, int value) =>
      _db.setSetting(key, value.toString());

  // Convenience methods for known settings keys
  static const String keyPassThreshold = 'pass_threshold';
  static const String keyDefaultListSize = 'default_list_size';
  static const String keyAiProvider = 'ai_provider';
  static const String keyAiApiKey = 'ai_api_key';
  static const String keyAiBaseUrl = 'ai_base_url';
  static const String keyAiModel = 'ai_model';
  static const String keyAiCollocationOptionValidationEnabled =
      'ai_collocation_option_validation_enabled';
  static const String keyAiThinkingEnabled = 'ai_thinking_enabled';
  static const String keyAiLastProvider = 'ai_usage_last_provider';
  static const String keyAiLastModel = 'ai_usage_last_model';
  static const String keyAiLastInputTokens = 'ai_usage_last_input_tokens';
  static const String keyAiLastOutputTokens = 'ai_usage_last_output_tokens';
  static const String keyAiTotalInputTokens = 'ai_usage_total_input_tokens';
  static const String keyAiTotalOutputTokens = 'ai_usage_total_output_tokens';
  static const String keyLanguageToolEnabled = 'language_tool_enabled';
  static const String keyLanguageToolBaseUrl = 'language_tool_base_url';

  Future<double> getPassThreshold() async =>
      (await getDouble(keyPassThreshold)) ?? 0.75;

  Future<void> setPassThreshold(double value) =>
      setDouble(keyPassThreshold, value);

  Future<int> getDefaultListSize() async =>
      (await getInt(keyDefaultListSize)) ?? 30;

  Future<void> setDefaultListSize(int value) =>
      setInt(keyDefaultListSize, value);

  Future<String?> getAiProvider() => getString(keyAiProvider);

  Future<void> setAiProvider(String value) => setString(keyAiProvider, value);

  Future<String?> getAiApiKey() => getString(keyAiApiKey);

  Future<void> setAiApiKey(String value) => setString(keyAiApiKey, value);

  Future<String?> getAiBaseUrl() => getString(keyAiBaseUrl);

  Future<void> setAiBaseUrl(String value) => setString(keyAiBaseUrl, value);

  Future<String?> getAiModel() => getString(keyAiModel);

  Future<void> setAiModel(String value) => setString(keyAiModel, value);

  /// Defaults to true so existing users keep the current verified-choice flow.
  Future<bool> getAiCollocationOptionValidationEnabled() async {
    final value = await getString(keyAiCollocationOptionValidationEnabled);
    return value != 'false';
  }

  Future<void> setAiCollocationOptionValidationEnabled(bool value) => setString(
    keyAiCollocationOptionValidationEnabled,
    value ? 'true' : 'false',
  );

  /// Defaults to true so the cloud model keeps its reasoning behaviour unless
  /// the learner explicitly turns it off to compare outputs.
  Future<bool> getAiThinkingEnabled() async {
    final value = await getString(keyAiThinkingEnabled);
    return value != 'false';
  }

  Future<void> setAiThinkingEnabled(bool value) =>
      setString(keyAiThinkingEnabled, value ? 'true' : 'false');

  Future<void> recordAiUsage({
    required String provider,
    required String model,
    required int inputTokens,
    required int outputTokens,
  }) async {
    await setString(keyAiLastProvider, provider);
    await setString(keyAiLastModel, model);
    await setInt(keyAiLastInputTokens, inputTokens);
    await setInt(keyAiLastOutputTokens, outputTokens);
    final totalInput = (await getInt(keyAiTotalInputTokens) ?? 0) + inputTokens;
    final totalOutput =
        (await getInt(keyAiTotalOutputTokens) ?? 0) + outputTokens;
    await setInt(keyAiTotalInputTokens, totalInput);
    await setInt(keyAiTotalOutputTokens, totalOutput);
  }

  Future<AiUsageSummary> getAiUsageSummary() async {
    return AiUsageSummary(
      lastProvider: await getString(keyAiLastProvider),
      lastModel: await getString(keyAiLastModel),
      lastInputTokens: await getInt(keyAiLastInputTokens) ?? 0,
      lastOutputTokens: await getInt(keyAiLastOutputTokens) ?? 0,
      totalInputTokens: await getInt(keyAiTotalInputTokens) ?? 0,
      totalOutputTokens: await getInt(keyAiTotalOutputTokens) ?? 0,
    );
  }

  Future<bool> getLanguageToolEnabled() async {
    final value = await getString(keyLanguageToolEnabled);
    return value != 'false';
  }

  Future<void> setLanguageToolEnabled(bool value) =>
      setString(keyLanguageToolEnabled, value ? 'true' : 'false');

  Future<String?> getLanguageToolBaseUrl() => getString(keyLanguageToolBaseUrl);

  Future<void> setLanguageToolBaseUrl(String value) =>
      setString(keyLanguageToolBaseUrl, value);

  static const String keyAppLanguage = 'app_language';
  static const String keyReviewDataResetNotice = 'review_data_reset_notice';
  static const String keyTtsProvider = 'tts_provider';
  static const String keyTtsSpeed = 'tts_speed';
  static const String keyTtsModelVersion = 'tts_model_version';
  static const String keyTtsApiKey = 'tts_api_key';
  static const String keyTtsBaseUrl = 'tts_base_url';
  static const String keyTtsModel = 'tts_model';
  static const String keyTtsVoice = 'tts_voice';
  static const String keyRemoteWordAudioBaseUrl = 'remote_word_audio_base_url';
  static const String keyWordAudioPlaybackSource = 'word_audio_playback_source';
  static const String keyExampleAudioPlaybackSource =
      'example_audio_playback_source';

  Future<String?> getAppLanguage() => getString(keyAppLanguage);

  Future<void> setAppLanguage(String value) => setString(keyAppLanguage, value);

  Future<bool> getReviewDataResetNotice() async =>
      (await getString(keyReviewDataResetNotice)) == 'true';

  Future<void> clearReviewDataResetNotice() =>
      setString(keyReviewDataResetNotice, 'false');

  Future<String?> getTtsProvider() => getString(keyTtsProvider);

  Future<void> setTtsProvider(String value) => setString(keyTtsProvider, value);

  Future<String?> getTtsApiKey() => getString(keyTtsApiKey);

  Future<void> setTtsApiKey(String value) => setString(keyTtsApiKey, value);

  Future<String?> getTtsBaseUrl() => getString(keyTtsBaseUrl);

  Future<void> setTtsBaseUrl(String value) => setString(keyTtsBaseUrl, value);

  Future<String?> getTtsModel() => getString(keyTtsModel);

  Future<void> setTtsModel(String value) => setString(keyTtsModel, value);

  Future<String?> getTtsVoice() => getString(keyTtsVoice);

  Future<void> setTtsVoice(String value) => setString(keyTtsVoice, value);

  Future<double> getTtsSpeed() async => (await getDouble(keyTtsSpeed)) ?? 0.6;

  Future<void> setTtsSpeed(double value) => setDouble(keyTtsSpeed, value);

  Future<String?> getTtsModelVersion() => getString(keyTtsModelVersion);

  Future<void> setTtsModelVersion(String value) =>
      setString(keyTtsModelVersion, value);
}

class AiUsageSummary {
  final String? lastProvider;
  final String? lastModel;
  final int lastInputTokens;
  final int lastOutputTokens;
  final int totalInputTokens;
  final int totalOutputTokens;

  const AiUsageSummary({
    required this.lastProvider,
    required this.lastModel,
    required this.lastInputTokens,
    required this.lastOutputTokens,
    required this.totalInputTokens,
    required this.totalOutputTokens,
  });

  bool get hasUsage =>
      lastInputTokens > 0 ||
      lastOutputTokens > 0 ||
      totalInputTokens > 0 ||
      totalOutputTokens > 0;
}

class TtsUsageSummary {
  final int apiCalls;
  final int chargedCharacters;
  final int audioBytes;
  final int failedCalls;

  const TtsUsageSummary({
    required this.apiCalls,
    required this.chargedCharacters,
    required this.audioBytes,
    required this.failedCalls,
  });
}

class TtsRepository {
  final AppDatabase _db;

  TtsRepository(this._db);

  Future<void> insertUsageRecord({
    required String provider,
    required String action,
    required String text,
    required String language,
    required String status,
    String? model,
    String? voice,
    String? resourceId,
    int? chargedCharacters,
    int? audioBytes,
    int? durationMs,
    String? requestId,
    String? logId,
    String? errorMessage,
  }) {
    return _db
        .insertTtsUsageRecord(
          TtsUsageRecordsCompanion(
            provider: Value(provider),
            action: Value(action),
            textValue: Value(text),
            language: Value(language),
            model: Value.absentIfNull(model),
            voice: Value.absentIfNull(voice),
            resourceId: Value.absentIfNull(resourceId),
            chargedCharacters: Value.absentIfNull(chargedCharacters),
            audioBytes: Value.absentIfNull(audioBytes),
            durationMs: Value.absentIfNull(durationMs),
            requestId: Value.absentIfNull(requestId),
            logId: Value.absentIfNull(logId),
            status: Value(status),
            errorMessage: Value.absentIfNull(errorMessage),
            createdAt: Value(DateTime.now().millisecondsSinceEpoch),
          ),
        )
        .then((_) {});
  }

  Future<void> upsertCacheRecord({
    required String provider,
    required String language,
    required String text,
    required String cacheKey,
    required String status,
    String? cachePath,
    String? errorMessage,
    int? audioBytes,
    int? chargedCharacters,
  }) {
    return _db.upsertTtsCacheRecord(
      provider: provider,
      language: language,
      text: text,
      cacheKey: cacheKey,
      status: status,
      cachePath: cachePath,
      errorMessage: errorMessage,
      audioBytes: audioBytes,
      chargedCharacters: chargedCharacters,
    );
  }

  Future<void> deleteCacheRecord(int id) => _db.deleteTtsCacheRecord(id);

  Future<List<TtsUsageRecord>> getRecentUsageRecords({
    String provider = 'doubao',
    int limit = 20,
  }) {
    return _db.getRecentTtsUsageRecords(provider, limit);
  }

  Future<TtsUsageSummary> getUsageSummary({String provider = 'doubao'}) async {
    final records = await _db.getAllTtsUsageRecords(provider);
    var apiCalls = 0;
    var failedCalls = 0;
    var chargedCharacters = 0;
    var audioBytes = 0;
    for (final record in records) {
      if (record.status == 'success') {
        apiCalls++;
        chargedCharacters += record.chargedCharacters ?? 0;
        audioBytes += record.audioBytes ?? 0;
      } else {
        failedCalls++;
      }
    }
    return TtsUsageSummary(
      apiCalls: apiCalls,
      chargedCharacters: chargedCharacters,
      audioBytes: audioBytes,
      failedCalls: failedCalls,
    );
  }

  Future<List<TtsCacheRecord>> getCacheRecords({
    String provider = 'doubao',
    String language = 'en',
  }) {
    return _db.getTtsCacheRecords(provider, language);
  }
}

class AiContentRepository {
  final AppDatabase _db;

  AiContentRepository(this._db);

  Future<AiContentData?> getContent(int wordId, String contentType) =>
      _db.getAiContent(wordId, contentType);

  Future<void> upsertContent({
    required int wordId,
    required String contentType,
    required String englishContent,
    required String chineseTranslation,
  }) {
    return _db.upsertAiContent(
      AiContentCompanion(
        wordId: Value(wordId),
        contentType: Value(contentType),
        englishContent: Value(englishContent),
        chineseTranslation: Value(chineseTranslation),
        generatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
