import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import '../../core/data_dir.dart';
import '../../core/utils/text_normalizer.dart';

part 'app_database.g.dart';

// ─── Table definitions ───────────────────────────────────────────────────────

class Words extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get english => text().withLength(min: 1, max: 500)();
  TextColumn get chineseMeanings => text().withLength(min: 1)();
  TextColumn get pronunciation => text().nullable()();
  TextColumn get exampleSentence => text().nullable()();
  TextColumn get scenarioExample => text().nullable()();
  TextColumn get scenarioTranslation => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  String get tableName => 'words';
}

class WordBooks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  IntColumn get totalWords => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();

  @override
  String get tableName => 'word_books';
}

class WordLists extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().nullable().references(WordBooks, #id)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  BoolColumn get isPassed => boolean().withDefault(const Constant(false))();
  RealColumn get passThreshold => real().withDefault(const Constant(0.75))();
  IntColumn get wordCount => integer().withDefault(const Constant(0))();
  BoolColumn get isShuffled => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();

  @override
  String get tableName => 'word_lists';
}

class ListWords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get listId => integer().references(WordLists, #id)();
  IntColumn get wordId => integer().references(Words, #id)();
  IntColumn get sortOrder => integer()();
  BoolColumn get isForgotten => boolean().withDefault(const Constant(false))();
  IntColumn get forgottenCount => integer().withDefault(const Constant(0))();
  BoolColumn get isCueMemory => boolean().withDefault(const Constant(false))();
  IntColumn get cueMemoryCount => integer().withDefault(const Constant(0))();

  @override
  String get tableName => 'list_words';

  @override
  List<String> get customConstraints => ['UNIQUE(list_id, word_id)'];
}

class PracticeSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get listId => integer().references(WordLists, #id)();
  TextColumn get mode => text().withLength(min: 1, max: 20)();
  TextColumn get sessionKind => text()
      .withLength(min: 1, max: 30)
      .withDefault(const Constant(PracticeSessionKind.memorization))();
  IntColumn get totalCount => integer()();
  IntColumn get correctCount => integer()();
  RealColumn get accuracy => real()();
  IntColumn get startedAt => integer()();
  IntColumn get finishedAt => integer().nullable()();

  @override
  String get tableName => 'practice_sessions';
}

class PracticeAnswers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(PracticeSessions, #id)();
  IntColumn get wordId => integer().references(Words, #id)();
  BoolColumn get isCorrect => boolean()();
  TextColumn get userAnswer => text().nullable()();
  TextColumn get correctAnswer => text()();
  IntColumn get answeredAt => integer()();

  @override
  String get tableName => 'practice_answers';
}

class ErrorWords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get wordId => integer().references(Words, #id)();
  IntColumn get listId => integer().references(WordLists, #id)();
  IntColumn get errorCount => integer().withDefault(const Constant(1))();
  BoolColumn get isResolved => boolean().withDefault(const Constant(false))();
  IntColumn get nextRetestAt => integer().nullable()();
  IntColumn get createdAt => integer()();

  @override
  String get tableName => 'error_words';
}

class AiContent extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get wordId => integer().references(Words, #id)();
  TextColumn get contentType => text().withLength(min: 1, max: 20)();
  TextColumn get englishContent => text()();
  TextColumn get chineseTranslation => text()();
  IntColumn get generatedAt => integer()();

  @override
  String get tableName => 'ai_content';
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  String get tableName => 'settings';

  @override
  Set<Column> get primaryKey => {key};
}

class LearningActivityRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get activityType => text().withLength(min: 1, max: 30)();
  TextColumn get subtype => text().nullable()();
  TextColumn get status => text().withLength(min: 1, max: 20)();
  IntColumn get startedAt => integer()();
  IntColumn get finishedAt => integer().nullable()();
  IntColumn get questionCount => integer().withDefault(const Constant(0))();
  IntColumn get correctCount => integer().withDefault(const Constant(0))();
  RealColumn get accuracy => real().nullable()();
  IntColumn get turnCount => integer().withDefault(const Constant(0))();
  IntColumn get targetWordUseCount =>
      integer().withDefault(const Constant(0))();
  RealColumn get naturalnessAverage => real().nullable()();
  RealColumn get contextFitAverage => real().nullable()();
  IntColumn get skillRunCount => integer().withDefault(const Constant(0))();
  IntColumn get involvedWordCount => integer().withDefault(const Constant(0))();

  @override
  String get tableName => 'learning_activity_records';
}

class LearningActivityLists extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get activityId => integer().references(
    LearningActivityRecords,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get listId =>
      integer().references(WordLists, #id, onDelete: KeyAction.cascade)();

  @override
  String get tableName => 'learning_activity_lists';

  @override
  List<String> get customConstraints => ['UNIQUE(activity_id, list_id)'];
}

class LearningActivityWords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get activityId => integer().references(
    LearningActivityRecords,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get wordId =>
      integer().references(Words, #id, onDelete: KeyAction.cascade)();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  IntColumn get errorCount => integer().withDefault(const Constant(0))();

  @override
  String get tableName => 'learning_activity_words';

  @override
  List<String> get customConstraints => ['UNIQUE(activity_id, word_id)'];
}

class TtsUsageRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get provider => text()();
  TextColumn get action => text()();
  TextColumn get textValue => text().named('text')();
  TextColumn get language => text()();
  TextColumn get model => text().nullable()();
  TextColumn get voice => text().nullable()();
  TextColumn get resourceId => text().nullable()();
  IntColumn get chargedCharacters => integer().nullable()();
  IntColumn get audioBytes => integer().nullable()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get requestId => text().nullable()();
  TextColumn get logId => text().nullable()();
  TextColumn get status => text()();
  TextColumn get errorMessage => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  String get tableName => 'tts_usage_records';
}

class TtsCacheRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get provider => text()();
  TextColumn get language => text()();
  TextColumn get textValue => text().named('text')();
  TextColumn get cacheKey => text()();
  TextColumn get status => text()();
  TextColumn get cachePath => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  IntColumn get audioBytes => integer().nullable()();
  IntColumn get chargedCharacters => integer().nullable()();
  IntColumn get updatedAt => integer()();

  @override
  String get tableName => 'tts_cache_records';

  @override
  List<String> get customConstraints => ['UNIQUE(provider, language, text)'];
}

class NarrationSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get status => text()();
  TextColumn get rawTranscript => text()();
  TextColumn get cleanedTranscript => text().nullable()();
  TextColumn get transcriptConfidence =>
      text().withDefault(const Constant('medium'))();
  TextColumn get uncertainSegmentsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get chineseTranslation => text().nullable()();
  BoolColumn get translationConfirmed =>
      boolean().withDefault(const Constant(false))();
  TextColumn get targetEnglish => text().nullable()();
  TextColumn get targetAlternativesJson =>
      text().withDefault(const Constant('[]'))();
  BoolColumn get targetConfirmed =>
      boolean().withDefault(const Constant(false))();
  TextColumn get normalizedTranscript => text().nullable()();
  TextColumn get analysisJson => text().nullable()();
  TextColumn get correctedExpression => text().nullable()();
  TextColumn get finalExpression => text().nullable()();
  BoolColumn get finalConfirmed =>
      boolean().withDefault(const Constant(false))();
  TextColumn get audioPath => text().nullable()();
  BoolColumn get audioRetained =>
      boolean().withDefault(const Constant(false))();
  TextColumn get accent => text().withDefault(const Constant('british'))();
  TextColumn get speechRegister =>
      text().withDefault(const Constant('spoken'))();
  BoolColumn get thinkingEnabled =>
      boolean().withDefault(const Constant(true))();
  IntColumn get analysisDurationMs => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  String get tableName => 'narration_sessions';
}

class NarrationTranscriptionLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(
    NarrationSessions,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get rawTranscript => text()();
  TextColumn get correctedTranscript => text().nullable()();
  TextColumn get confidence => text()();
  TextColumn get uncertainSegmentsJson => text()();
  TextColumn get confirmationResult => text()();
  BoolColumn get rerecorded => boolean().withDefault(const Constant(false))();
  TextColumn get alignmentStatus => text().nullable()();
  TextColumn get manualCleanupJson => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  String get tableName => 'narration_transcription_logs';
}

class NarrationSelfCheckLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(
    NarrationSessions,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get reportJson => text()();
  IntColumn get iterationCount => integer()();
  BoolColumn get passed => boolean()();
  IntColumn get createdAt => integer()();

  @override
  String get tableName => 'narration_self_check_logs';
}

class NarrationFeedbackLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().nullable().references(
    NarrationSessions,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get learningItemId => integer().nullable()();
  TextColumn get stage => text()();
  TextColumn get originalJudgement => text()();
  TextColumn get systemExplanation => text().nullable()();
  TextColumn get userReason => text().nullable()();
  TextColumn get resolution => text()();
  TextColumn get customResult => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  String get tableName => 'narration_feedback_logs';
}

class NarrationLearningItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get itemType => text()();
  TextColumn get stableKey => text()();
  TextColumn get english => text()();
  TextColumn get chinese => text()();
  TextColumn get partOfSpeech => text().withDefault(const Constant(''))();
  TextColumn get classification => text().withDefault(const Constant(''))();
  TextColumn get knowledgeLevel => text().withDefault(const Constant(''))();
  TextColumn get explanation => text().withDefault(const Constant(''))();
  BoolColumn get reviewRequired =>
      boolean().withDefault(const Constant(true))();
  IntColumn get firstSeenAt => integer()();
  IntColumn get lastSeenAt => integer()();
  IntColumn get occurrenceCount => integer().withDefault(const Constant(1))();
  TextColumn get masteryState => text().withDefault(const Constant('new'))();
  IntColumn get reviewPassCount => integer().withDefault(const Constant(0))();
  BoolColumn get recognitionPassed =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get applicationPassed =>
      boolean().withDefault(const Constant(false))();
  IntColumn get realUseSuccessCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get realUseFailureCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get nextReviewAt => integer().nullable()();
  IntColumn get reviewIntervalIndex =>
      integer().withDefault(const Constant(0))();
  IntColumn get lastTriggerAt => integer().nullable()();
  IntColumn get lastFailureAt => integer().nullable()();
  TextColumn get queueState => text().withDefault(const Constant('active'))();
  BoolColumn get userConfirmed =>
      boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().withDefault(const Constant(''))();

  @override
  String get tableName => 'narration_learning_items';

  @override
  List<String> get customConstraints => ['UNIQUE(item_type, stable_key)'];
}

class NarrationLearningSources extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get learningItemId => integer().references(
    NarrationLearningItems,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get sessionId => integer().references(
    NarrationSessions,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get sourceType => text()();
  TextColumn get errorGrade => text().nullable()();
  TextColumn get evidence => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  String get tableName => 'narration_learning_sources';

  @override
  List<String> get customConstraints => [
    'UNIQUE(learning_item_id, session_id, source_type)',
  ];
}

class NarrationReviewRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get learningItemId => integer().references(
    NarrationLearningItems,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get layer => text()();
  TextColumn get outcome => text()();
  BoolColumn get guided => boolean().withDefault(const Constant(false))();
  TextColumn get answer => text().nullable()();
  TextColumn get evidence => text().nullable()();
  IntColumn get reviewedAt => integer()();

  @override
  String get tableName => 'narration_review_records';
}

class NarrationProgressRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().unique().references(
    NarrationSessions,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get errorACount => integer()();
  IntColumn get errorBCount => integer()();
  IntColumn get errorCCount => integer()();
  IntColumn get collectedWordCount => integer()();
  IntColumn get coreKnowledgeCount => integer()();
  IntColumn get realUseSuccessCount => integer()();
  IntColumn get realUseFailureCount => integer()();
  IntColumn get englishWordCount => integer()();
  IntColumn get sentenceCount => integer()();
  IntColumn get chineseSubstituteCount => integer()();
  RealColumn get complexity => real()();
  IntColumn get createdAt => integer()();

  @override
  String get tableName => 'narration_progress_records';
}

class NarrationConsentRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get consentType => text()();
  TextColumn get policyVersion => text()();
  BoolColumn get granted => boolean()();
  IntColumn get createdAt => integer()();
  IntColumn get revokedAt => integer().nullable()();

  @override
  String get tableName => 'narration_consent_records';
}

abstract final class PracticeSessionKind {
  static const memorization = 'memorization';
  static const review = 'review';
  static const aiLearning = 'ai_learning';
}

abstract final class LearningActivityType {
  static const aiLearning = 'ai_learning';
  static const dialogue = 'dialogue';
  static const skill = 'skill';
}

abstract final class LearningActivityStatus {
  static const started = 'started';
  static const completed = 'completed';
  static const abandoned = 'abandoned';
}

// ─── Row data classes ────────────────────────────────────────────────────────

class WordListWithCount {
  final WordList wordList;
  final int totalWords;

  WordListWithCount({required this.wordList, required this.totalWords});
}

class ErrorWordWithCount {
  final Word word;
  final int errorCount;

  ErrorWordWithCount({required this.word, required this.errorCount});
}

class ReviewWordStat {
  final Word word;
  final int? cueMemoryListCreatedAt;
  final int? cueMemoryListId;
  final int? cueMemoryListSortOrder;
  final int errorCount;
  final int forgottenCount;
  final int cueMemoryCount;
  final bool isErrorActive;
  final bool isForgottenActive;
  final bool isCueMemoryActive;

  const ReviewWordStat({
    required this.word,
    this.cueMemoryListCreatedAt,
    this.cueMemoryListId,
    this.cueMemoryListSortOrder,
    required this.errorCount,
    required this.forgottenCount,
    required this.cueMemoryCount,
    required this.isErrorActive,
    required this.isForgottenActive,
    required this.isCueMemoryActive,
  });
}

class DailyWordReview {
  final Word word;
  final int answerCount;
  final int correctCount;
  final int incorrectCount;
  final bool? latestCorrect;
  final int? latestAnsweredAt;

  const DailyWordReview({
    required this.word,
    required this.answerCount,
    required this.correctCount,
    required this.incorrectCount,
    required this.latestCorrect,
    required this.latestAnsweredAt,
  });

  bool? get latestResult => latestCorrect;
}

class DailyListReview {
  final WordList list;
  final int practiceCount;
  final int coveredWordCount;
  final int totalWordCount;
  final int correctCount;
  final int totalAnswerCount;
  final double accuracy;
  final PracticeSession? latestSession;
  final bool metPassThreshold;
  final List<DailyWordReview> words;

  const DailyListReview({
    required this.list,
    required this.practiceCount,
    required this.coveredWordCount,
    required this.totalWordCount,
    required this.correctCount,
    required this.totalAnswerCount,
    required this.accuracy,
    required this.latestSession,
    required this.metPassThreshold,
    required this.words,
  });

  double get weightedAccuracy => accuracy;
  PracticeSession? get recentResult => latestSession;
  bool get passed => metPassThreshold;
}

class ActivityWordAggregate {
  final Word word;
  final int usageCount;
  final int errorCount;

  const ActivityWordAggregate({
    required this.word,
    required this.usageCount,
    required this.errorCount,
  });
}

class DailyAiSummary {
  final List<LearningActivityRecord> activities;
  final List<ActivityWordAggregate> focusWords;

  const DailyAiSummary({required this.activities, required this.focusWords});

  List<LearningActivityRecord> ofType(String type) =>
      activities.where((activity) => activity.activityType == type).toList();

  int completedCount(String type) => ofType(type).length;

  int involvedWordCount(String type) => ofType(
    type,
  ).fold<int>(0, (sum, activity) => sum + activity.involvedWordCount);

  int get aiLearningQuestionCount => ofType(
    LearningActivityType.aiLearning,
  ).fold<int>(0, (sum, activity) => sum + activity.questionCount);

  int get aiLearningCorrectCount => ofType(
    LearningActivityType.aiLearning,
  ).fold<int>(0, (sum, activity) => sum + activity.correctCount);

  double get aiLearningAccuracy => aiLearningQuestionCount == 0
      ? 0
      : aiLearningCorrectCount / aiLearningQuestionCount;

  Map<String, int> get aiLearningModes =>
      _subtypeCounts(LearningActivityType.aiLearning);

  int get dialogueTurnCount => ofType(
    LearningActivityType.dialogue,
  ).fold<int>(0, (sum, activity) => sum + activity.turnCount);

  int get dialogueTargetWordUseCount => ofType(
    LearningActivityType.dialogue,
  ).fold<int>(0, (sum, activity) => sum + activity.targetWordUseCount);

  double? get dialogueNaturalnessAverage => _averageMetric(
    ofType(
      LearningActivityType.dialogue,
    ).map((activity) => activity.naturalnessAverage),
  );

  double? get dialogueContextFitAverage => _averageMetric(
    ofType(
      LearningActivityType.dialogue,
    ).map((activity) => activity.contextFitAverage),
  );

  int get skillRunCount => ofType(
    LearningActivityType.skill,
  ).fold<int>(0, (sum, activity) => sum + activity.skillRunCount);

  Map<String, int> get skillDistribution =>
      _subtypeCounts(LearningActivityType.skill);

  Map<String, int> _subtypeCounts(String type) {
    final counts = <String, int>{};
    for (final activity in ofType(type)) {
      final key = activity.subtype ?? '';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  double? _averageMetric(Iterable<double?> values) {
    final present = values.whereType<double>().toList();
    if (present.isEmpty) return null;
    return present.reduce((a, b) => a + b) / present.length;
  }
}

class _ReviewWordStatBuilder {
  final Word word;
  int? cueMemoryListCreatedAt;
  int? cueMemoryListId;
  int? cueMemoryListSortOrder;
  int errorCount = 0;
  int forgottenCount = 0;
  int cueMemoryCount = 0;
  bool isErrorActive = false;
  bool isForgottenActive = false;
  bool isCueMemoryActive = false;

  _ReviewWordStatBuilder(this.word);
}

class _ReviewErrorRow {
  final int id;
  final int listId;
  final Word word;
  final int errorCount;
  final bool isResolved;

  _ReviewErrorRow({
    required this.id,
    required this.listId,
    required this.word,
    required this.errorCount,
    required this.isResolved,
  });
}

class _ReviewForgottenRow {
  final int id;
  final Word word;
  final int forgottenCount;
  final bool isForgotten;

  _ReviewForgottenRow({
    required this.id,
    required this.word,
    required this.forgottenCount,
    required this.isForgotten,
  });
}

class _ReviewCueMemoryRow {
  final int id;
  final Word word;
  final int listCreatedAt;
  final int listId;
  final int listSortOrder;
  final int cueMemoryCount;
  final bool isCueMemory;

  _ReviewCueMemoryRow({
    required this.id,
    required this.word,
    required this.listCreatedAt,
    required this.listId,
    required this.listSortOrder,
    required this.cueMemoryCount,
    required this.isCueMemory,
  });
}

class _DailyWordBuilder {
  final Word word;
  int answerCount = 0;
  int correctCount = 0;
  int incorrectCount = 0;
  bool? latestCorrect;
  int? latestAnsweredAt;

  _DailyWordBuilder(this.word);

  DailyWordReview toStat() => DailyWordReview(
    word: word,
    answerCount: answerCount,
    correctCount: correctCount,
    incorrectCount: incorrectCount,
    latestCorrect: latestCorrect,
    latestAnsweredAt: latestAnsweredAt,
  );
}

// ─── Database ────────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [
    Words,
    WordBooks,
    WordLists,
    ListWords,
    PracticeSessions,
    PracticeAnswers,
    ErrorWords,
    AiContent,
    Settings,
    LearningActivityRecords,
    LearningActivityLists,
    LearningActivityWords,
    TtsUsageRecords,
    TtsCacheRecords,
    NarrationSessions,
    NarrationTranscriptionLogs,
    NarrationSelfCheckLogs,
    NarrationFeedbackLogs,
    NarrationLearningItems,
    NarrationLearningSources,
    NarrationReviewRecords,
    NarrationProgressRecords,
    NarrationConsentRecords,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Creates an isolated database for repository tests.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, int from, int to) async {
      if (from < 3) {
        await m.addColumn(words, words.scenarioExample);
      }
      if (from < 4) {
        await m.createTable(ttsUsageRecords);
        await m.createTable(ttsCacheRecords);
      }
      if (from < 5) {
        final hasScenarioTranslation = await _tableHasColumn(
          m.database,
          'words',
          'scenario_translation',
        );
        if (!hasScenarioTranslation) {
          await m.addColumn(words, words.scenarioTranslation);
        }
      }
      if (from < 6) {
        await m.addColumn(listWords, listWords.forgottenCount);
        await m.addColumn(errorWords, errorWords.isResolved);
      }
      if (from < 7) {
        await m.addColumn(practiceSessions, practiceSessions.sessionKind);
        await m.createTable(learningActivityRecords);
        await m.createTable(learningActivityLists);
        await m.createTable(learningActivityWords);

        // Intentionally reset legacy review/progress data. Drift wraps the
        // whole version upgrade in one transaction, so a failure rolls back
        // both the schema changes and this destructive cleanup.
        await m.database.customStatement('DELETE FROM practice_answers');
        await m.database.customStatement('DELETE FROM practice_sessions');
        await m.database.customStatement('DELETE FROM error_words');
        await m.database.customStatement(
          'UPDATE list_words SET is_forgotten = 0, forgotten_count = 0',
        );
        await m.database.customStatement('UPDATE word_lists SET is_passed = 0');
        await m.database.customStatement('''
INSERT INTO settings (`key`, value) VALUES ('review_data_reset_notice', 'true')
ON CONFLICT(`key`) DO UPDATE SET value = excluded.value
''');
      }
      if (from < 8) {
        await m.addColumn(listWords, listWords.isCueMemory);
        await m.addColumn(listWords, listWords.cueMemoryCount);
      }
      if (from < 9) {
        await m.createTable(narrationSessions);
        await m.createTable(narrationTranscriptionLogs);
        await m.createTable(narrationSelfCheckLogs);
        await m.createTable(narrationFeedbackLogs);
        await m.createTable(narrationLearningItems);
        await m.createTable(narrationLearningSources);
        await m.createTable(narrationReviewRecords);
        await m.createTable(narrationProgressRecords);
        await m.createTable(narrationConsentRecords);
      }
      if (from < 10) {
        // Additive only: existing narration rows keep reasoning on, which
        // matches how they were produced.
        await m.addColumn(narrationSessions, narrationSessions.thinkingEnabled);
        await m.addColumn(
          narrationSessions,
          narrationSessions.analysisDurationMs,
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getLingoDataDir();
      final file = File(p.join(dbFolder.path, 'lingo.db'));
      return NativeDatabase.createInBackground(file);
    });
  }

  // ─── Words ───────────────────────────────────────────────────────────────

  static Future<bool> _tableHasColumn(
    GeneratedDatabase database,
    String tableName,
    String columnName,
  ) async {
    final rows = await database
        .customSelect('PRAGMA table_info($tableName);')
        .get();
    return rows.any((row) => row.read<String>('name') == columnName);
  }

  Future<List<Word>> getAllWords() => select(words).get();

  Future<Word?> getWord(int id) =>
      (select(words)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertWord(Insertable<Word> word) => into(words).insert(word);

  Future<void> updateWord(int id, Insertable<Word> word) =>
      (update(words)..where((t) => t.id.equals(id))).write(word);

  Future<void> deleteWord(int id) =>
      (delete(words)..where((t) => t.id.equals(id))).go();

  Future<List<Word>> searchWords(String query) {
    final normalizedQuery = TextNormalizer.normalizeQuotes(query.toLowerCase());
    return (select(words)..where(
          (t) =>
              t.english.lower().like('%$normalizedQuery%') |
              t.chineseMeanings.lower().like('%$normalizedQuery%'),
        ))
        .get();
  }

  // ─── Word Books ──────────────────────────────────────────────────────────

  Future<int> insertBook(Insertable<WordBook> book) =>
      into(wordBooks).insert(book);

  Future<List<WordBook>> getAllBooks() => select(wordBooks).get();

  Future<WordBook?> getBook(int id) =>
      (select(wordBooks)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<WordList>> getListsForBook(int bookId) {
    final query = select(wordLists)
      ..where((t) => t.bookId.equals(bookId))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.get();
  }

  Future<List<int>> getListIdsForBook(int bookId) async {
    final lists = await getListsForBook(bookId);
    return lists.map((l) => l.id).toList();
  }

  // ─── Word Lists ──────────────────────────────────────────────────────────

  Future<List<WordList>> getAllLists() {
    final query = select(wordLists)
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.get();
  }

  Future<WordList?> getList(int id) =>
      (select(wordLists)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertList(Insertable<WordList> list) =>
      into(wordLists).insert(list);

  Future<void> updateList(int id, Insertable<WordList> list) =>
      (update(wordLists)..where((t) => t.id.equals(id))).write(list);

  Future<void> deleteList(int id) async {
    await transaction(() async {
      await (delete(listWords)..where((t) => t.listId.equals(id))).go();
      await (delete(wordLists)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<void> markListPassed(int id, bool passed) =>
      (update(wordLists)..where((t) => t.id.equals(id))).write(
        WordListsCompanion(isPassed: Value(passed)),
      );

  // ─── List Words ──────────────────────────────────────────────────────────

  Future<List<Word>> getWordsForList(int listId) {
    final query =
        select(
            listWords,
          ).join([innerJoin(words, words.id.equalsExp(listWords.wordId))])
          ..where(listWords.listId.equals(listId))
          ..orderBy([OrderingTerm.asc(listWords.sortOrder)]);
    return query.map((row) => row.readTable(words)).get();
  }

  Future<List<Word>> getWordsForLists(List<int> listIds) {
    if (listIds.isEmpty) return Future.value(const []);
    final query =
        select(
            listWords,
          ).join([innerJoin(words, words.id.equalsExp(listWords.wordId))])
          ..where(listWords.listId.isIn(listIds))
          ..orderBy([
            OrderingTerm.asc(listWords.listId),
            OrderingTerm.asc(listWords.sortOrder),
          ]);
    return query.map((row) => row.readTable(words)).get();
  }

  Future<int> getWordCountForList(int listId) {
    final inner = selectOnly(listWords)
      ..addColumns([listWords.id])
      ..where(listWords.listId.equals(listId));
    return inner.map((r) => r.read(listWords.id)).get().then((l) => l.length);
  }

  Future<void> addWordsToList(
    int listId,
    List<int> wordIds,
    List<int> sortOrders,
  ) async {
    await transaction(() async {
      for (var i = 0; i < wordIds.length; i++) {
        await into(listWords).insert(
          ListWordsCompanion(
            listId: Value(listId),
            wordId: Value(wordIds[i]),
            sortOrder: Value(sortOrders[i]),
          ),
        );
      }
      final count = wordIds.length;
      await (update(wordLists)..where((t) => t.id.equals(listId))).write(
        WordListsCompanion(wordCount: Value(count)),
      );
    });
  }

  Future<void> updateSortOrders(int listId, List<int> newOrder) async {
    await transaction(() async {
      final rows =
          await (select(listWords)
                ..where((t) => t.listId.equals(listId))
                ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
              .get();
      for (var i = 0; i < rows.length; i++) {
        await (update(listWords)..where((t) => t.id.equals(rows[i].id))).write(
          ListWordsCompanion(sortOrder: Value(newOrder[i])),
        );
      }
      await (update(wordLists)..where((t) => t.id.equals(listId))).write(
        const WordListsCompanion(isShuffled: Value(true)),
      );
    });
  }

  /// Replaces the entire ListWords membership for [listId] with [wordIds].
  /// Used by whole-book "词序重置" — wipes the existing list_words rows for
  /// this list and re-inserts in the supplied order. Preserves the list's
  /// passed/threshold/created metadata.
  Future<void> replaceListWords(int listId, List<int> wordIds) async {
    await transaction(() async {
      await (delete(listWords)..where((t) => t.listId.equals(listId))).go();
      for (var i = 0; i < wordIds.length; i++) {
        await into(listWords).insert(
          ListWordsCompanion(
            listId: Value(listId),
            wordId: Value(wordIds[i]),
            sortOrder: Value(i),
          ),
        );
      }
      await (update(wordLists)..where((t) => t.id.equals(listId))).write(
        WordListsCompanion(
          wordCount: Value(wordIds.length),
          isShuffled: const Value(true),
          isPassed: const Value(false),
        ),
      );
    });
  }

  // ─── Practice Sessions ───────────────────────────────────────────────────

  Future<int> insertSession(Insertable<PracticeSession> session) =>
      into(practiceSessions).insert(session);

  Future<PracticeSession?> getSession(int id) => (select(
    practiceSessions,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<PracticeSession>> getSessionsForList(int listId) {
    final query = select(practiceSessions)
      ..where((t) => t.listId.equals(listId))
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    return query.get();
  }

  Future<List<PracticeSession>> getAllSessions() {
    final query = select(practiceSessions)
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    return query.get();
  }

  Future<List<PracticeSession>> getSessionsByIds(List<int> ids) {
    final query = select(practiceSessions)
      ..where((t) => t.id.isIn(ids))
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    return query.get();
  }

  // ─── Practice Answers ────────────────────────────────────────────────────

  Future<void> insertAnswers(List<PracticeAnswersCompanion> answers) =>
      batch((b) {
        for (final a in answers) {
          b.insert(practiceAnswers, a);
        }
      });

  Future<int> correctAnswerCountForSession(int sessionId) {
    final inner = selectOnly(practiceAnswers)
      ..addColumns([practiceAnswers.id])
      ..where(
        practiceAnswers.sessionId.equals(sessionId) &
            practiceAnswers.isCorrect.equals(true),
      );
    return inner
        .map((r) => r.read(practiceAnswers.id))
        .get()
        .then((l) => l.length);
  }

  Future<List<PracticeSession>> getMemorizationSessionsForList(int listId) {
    final query = select(practiceSessions)
      ..where(
        (t) =>
            t.listId.equals(listId) &
            t.sessionKind.equals(PracticeSessionKind.memorization),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    return query.get();
  }

  // ─── Learning activities ────────────────────────────────────────────────

  Future<int> startActivity({
    required String activityType,
    String? subtype,
    List<int> listIds = const [],
    List<int> wordIds = const [],
    int? startedAt,
  }) async {
    return transaction(() async {
      final id = await into(learningActivityRecords).insert(
        LearningActivityRecordsCompanion(
          activityType: Value(activityType),
          subtype: Value.absentIfNull(subtype),
          status: const Value(LearningActivityStatus.started),
          startedAt: Value(startedAt ?? DateTime.now().millisecondsSinceEpoch),
          involvedWordCount: Value(wordIds.toSet().length),
        ),
      );
      for (final listId in listIds.toSet()) {
        await into(learningActivityLists).insert(
          LearningActivityListsCompanion(
            activityId: Value(id),
            listId: Value(listId),
          ),
        );
      }
      for (final wordId in wordIds.toSet()) {
        await into(learningActivityWords).insert(
          LearningActivityWordsCompanion(
            activityId: Value(id),
            wordId: Value(wordId),
          ),
        );
      }
      return id;
    });
  }

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
  }) async {
    await transaction(() async {
      final rows =
          await (select(learningActivityRecords)..where(
                (t) =>
                    t.id.equals(activityId) &
                    t.status.equals(LearningActivityStatus.started),
              ))
              .get();
      if (rows.isEmpty) return;
      final allWordIds = <int>{
        ...wordIds,
        ...wordUsageCounts.keys,
        ...errorWordIds,
      };
      final existingWordRows = await (select(
        learningActivityWords,
      )..where((t) => t.activityId.equals(activityId))).get();
      allWordIds.addAll(existingWordRows.map((row) => row.wordId));
      await (update(
        learningActivityRecords,
      )..where((t) => t.id.equals(activityId))).write(
        LearningActivityRecordsCompanion(
          subtype: Value.absentIfNull(subtype),
          status: const Value(LearningActivityStatus.completed),
          finishedAt: Value(
            finishedAt ?? DateTime.now().millisecondsSinceEpoch,
          ),
          questionCount: Value.absentIfNull(questionCount),
          correctCount: Value.absentIfNull(correctCount),
          accuracy: Value.absentIfNull(accuracy),
          turnCount: Value.absentIfNull(turnCount),
          targetWordUseCount: Value.absentIfNull(targetWordUseCount),
          naturalnessAverage: Value.absentIfNull(naturalnessAverage),
          contextFitAverage: Value.absentIfNull(contextFitAverage),
          skillRunCount: Value.absentIfNull(skillRunCount),
          involvedWordCount: Value.absentIfNull(
            involvedWordCount ?? allWordIds.length,
          ),
        ),
      );
      for (final wordId in allWordIds) {
        final existing =
            await (select(learningActivityWords)..where(
                  (t) =>
                      t.activityId.equals(activityId) & t.wordId.equals(wordId),
                ))
                .getSingleOrNull();
        final usage = wordUsageCounts[wordId] ?? 0;
        final errors = errorWordIds.contains(wordId) ? 1 : 0;
        if (existing == null) {
          await into(learningActivityWords).insert(
            LearningActivityWordsCompanion(
              activityId: Value(activityId),
              wordId: Value(wordId),
              usageCount: Value(usage),
              errorCount: Value(errors),
            ),
          );
        } else {
          await (update(
            learningActivityWords,
          )..where((t) => t.id.equals(existing.id))).write(
            LearningActivityWordsCompanion(
              usageCount: Value(usage),
              errorCount: Value(errors),
            ),
          );
        }
      }
    });
  }

  Future<void> abandonActivity(int activityId, {int? finishedAt}) async {
    await (update(learningActivityRecords)..where(
          (t) =>
              t.id.equals(activityId) &
              t.status.equals(LearningActivityStatus.started),
        ))
        .write(
          LearningActivityRecordsCompanion(
            status: const Value(LearningActivityStatus.abandoned),
            finishedAt: Value(
              finishedAt ?? DateTime.now().millisecondsSinceEpoch,
            ),
          ),
        );
  }

  Future<LearningActivityRecord?> getActivity(int id) => (select(
    learningActivityRecords,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<LearningActivityRecord>> getActivitiesForDay(
    DateTime day, {
    int? bookId,
    List<int>? listIds,
    bool completedOnly = true,
  }) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final records =
        await (select(learningActivityRecords)
              ..where((t) {
                final finished = t.finishedAt;
                final dateFilter =
                    finished.isBiggerOrEqualValue(
                      start.millisecondsSinceEpoch,
                    ) &
                    finished.isSmallerThanValue(end.millisecondsSinceEpoch);
                return (completedOnly
                        ? t.status.equals(LearningActivityStatus.completed)
                        : const Constant(true)) &
                    dateFilter;
              })
              ..orderBy([(t) => OrderingTerm.asc(t.finishedAt)]))
            .get();
    if (records.isEmpty ||
        (bookId == null && (listIds == null || listIds.isEmpty))) {
      return records;
    }
    final allowedLists = <int>{...?listIds};
    if (bookId != null) {
      final bookLists = await (select(
        wordLists,
      )..where((t) => t.bookId.equals(bookId))).get();
      allowedLists.addAll(bookLists.map((list) => list.id));
    }
    if (allowedLists.isEmpty) return const [];
    final links = await (select(
      learningActivityLists,
    )..where((t) => t.listId.isIn(allowedLists))).get();
    final linkedIds = links.map((link) => link.activityId).toSet();
    return records.where((record) => linkedIds.contains(record.id)).toList();
  }

  Future<List<DailyListReview>> getDailyListReview(
    DateTime day, {
    int? bookId,
  }) async {
    final lists = await getAllLists();
    final filtered = bookId == null
        ? lists
        : lists.where((list) => list.bookId == bookId).toList();
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final sessions =
        await (select(practiceSessions)..where(
              (t) =>
                  t.sessionKind.equals(PracticeSessionKind.memorization) &
                  t.finishedAt.isBiggerOrEqualValue(
                    start.millisecondsSinceEpoch,
                  ) &
                  t.finishedAt.isSmallerThanValue(end.millisecondsSinceEpoch),
            ))
            .get();
    final answers = await select(practiceAnswers).get();
    final answersBySession = <int, List<PracticeAnswer>>{};
    for (final answer in answers) {
      answersBySession.putIfAbsent(answer.sessionId, () => []).add(answer);
    }
    final result = <DailyListReview>[];
    for (final list in filtered) {
      final listSessions = sessions.where((s) => s.listId == list.id).toList();
      listSessions.sort(
        (a, b) => (b.finishedAt ?? b.startedAt).compareTo(
          a.finishedAt ?? a.startedAt,
        ),
      );
      final listWords = await getWordsForList(list.id);
      final wordMap = <int, _DailyWordBuilder>{};
      for (final word in listWords) {
        wordMap[word.id] = _DailyWordBuilder(word);
      }
      var correct = 0;
      var total = 0;
      for (final session in listSessions) {
        for (final answer in answersBySession[session.id] ?? const []) {
          final builder = wordMap[answer.wordId];
          if (builder == null) continue;
          builder.answerCount++;
          if (answer.isCorrect) {
            correct++;
            builder.correctCount++;
          } else {
            builder.incorrectCount++;
          }
          total++;
          if (builder.latestAnsweredAt == null ||
              answer.answeredAt > builder.latestAnsweredAt!) {
            builder.latestAnsweredAt = answer.answeredAt;
            builder.latestCorrect = answer.isCorrect;
          }
        }
      }
      final dailyWords =
          wordMap.values
              .where((builder) => builder.answerCount > 0)
              .map((builder) => builder.toStat())
              .toList()
            ..sort((a, b) => a.word.english.compareTo(b.word.english));
      result.add(
        DailyListReview(
          list: list,
          practiceCount: listSessions.length,
          coveredWordCount: dailyWords.length,
          totalWordCount: list.wordCount,
          correctCount: correct,
          totalAnswerCount: total,
          accuracy: total == 0 ? 0 : correct / total,
          latestSession: listSessions.isEmpty ? null : listSessions.first,
          metPassThreshold: total > 0 && correct / total >= list.passThreshold,
          words: dailyWords,
        ),
      );
    }
    return result;
  }

  Future<DailyAiSummary> getDailyAiSummary(DateTime day, {int? bookId}) async {
    final activities = await getActivitiesForDay(day, bookId: bookId);
    if (activities.isEmpty) {
      return const DailyAiSummary(activities: [], focusWords: []);
    }
    final ids = activities.map((activity) => activity.id).toSet();
    final wordRows = await (select(
      learningActivityWords,
    )..where((t) => t.activityId.isIn(ids))).get();
    final aggregates = <int, (int usage, int errors)>{};
    for (final row in wordRows) {
      if (row.usageCount == 0 && row.errorCount == 0) continue;
      final current = aggregates[row.wordId] ?? (0, 0);
      aggregates[row.wordId] = (
        current.$1 + row.usageCount,
        current.$2 + row.errorCount,
      );
    }
    final words = await getAllWords();
    final focusWords = <ActivityWordAggregate>[];
    for (final entry in aggregates.entries) {
      final word = words
          .where((candidate) => candidate.id == entry.key)
          .firstOrNull;
      if (word == null) continue;
      focusWords.add(
        ActivityWordAggregate(
          word: word,
          usageCount: entry.value.$1,
          errorCount: entry.value.$2,
        ),
      );
    }
    focusWords.sort((a, b) {
      final errorCmp = b.errorCount.compareTo(a.errorCount);
      if (errorCmp != 0) return errorCmp;
      return b.usageCount.compareTo(a.usageCount);
    });
    return DailyAiSummary(activities: activities, focusWords: focusWords);
  }

  // ─── Forgotten Words ──────────────────────────────────────────────────────

  Future<void> markWordForgotten(int wordId, int listId) async {
    final existing =
        await (select(listWords)
              ..where((t) => t.wordId.equals(wordId) & t.listId.equals(listId)))
            .getSingleOrNull();
    if (existing == null) return;
    await (update(
      listWords,
    )..where((t) => t.wordId.equals(wordId) & t.listId.equals(listId))).write(
      ListWordsCompanion(
        isForgotten: const Value(true),
        forgottenCount: Value(
          existing.forgottenCount + (existing.isForgotten ? 0 : 1),
        ),
      ),
    );
  }

  Future<List<Word>> getForgottenWordsForList(int listId) {
    final query =
        select(
          listWords,
        ).join([innerJoin(words, words.id.equalsExp(listWords.wordId))])..where(
          listWords.listId.equals(listId) & listWords.isForgotten.equals(true),
        );
    return query.map((row) => row.readTable(words)).get();
  }

  Future<void> clearForgottenStatus(int wordId, int listId) async {
    await (update(listWords)
          ..where((t) => t.wordId.equals(wordId) & t.listId.equals(listId)))
        .write(const ListWordsCompanion(isForgotten: Value(false)));
  }

  // ─── Cue Memory Words ────────────────────────────────────────────────────

  Future<void> markWordCueMemory(int wordId, int listId) async {
    final existing =
        await (select(listWords)
              ..where((t) => t.wordId.equals(wordId) & t.listId.equals(listId)))
            .getSingleOrNull();
    if (existing == null) return;
    await (update(
      listWords,
    )..where((t) => t.wordId.equals(wordId) & t.listId.equals(listId))).write(
      ListWordsCompanion(
        isCueMemory: const Value(true),
        cueMemoryCount: Value(
          existing.cueMemoryCount + (existing.isCueMemory ? 0 : 1),
        ),
      ),
    );
  }

  Future<List<Word>> getCueMemoryWordsForList(int listId) {
    final query =
        select(
          listWords,
        ).join([innerJoin(words, words.id.equalsExp(listWords.wordId))])..where(
          listWords.listId.equals(listId) & listWords.isCueMemory.equals(true),
        );
    return query.map((row) => row.readTable(words)).get();
  }

  // ─── Error Words ─────────────────────────────────────────────────────────

  Future<void> recordError(int wordId, int listId) async {
    final existing =
        await (select(errorWords)
              ..where((t) => t.wordId.equals(wordId) & t.listId.equals(listId)))
            .getSingleOrNull();
    if (existing != null) {
      await (update(errorWords)..where((t) => t.id.equals(existing.id))).write(
        ErrorWordsCompanion(
          errorCount: Value(existing.errorCount + 1),
          isResolved: const Value(false),
        ),
      );
    } else {
      await into(errorWords).insert(
        ErrorWordsCompanion(
          wordId: Value(wordId),
          listId: Value(listId),
          errorCount: const Value(1),
          isResolved: const Value(false),
          createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
    }
  }

  Future<List<Word>> getErrorWordsForList(int listId) {
    final query =
        select(
            errorWords,
          ).join([innerJoin(words, words.id.equalsExp(errorWords.wordId))])
          ..where(
            errorWords.listId.equals(listId) &
                errorWords.isResolved.equals(false),
          )
          ..orderBy([OrderingTerm.desc(errorWords.errorCount)]);
    return query.map((row) => row.readTable(words)).get();
  }

  Future<List<ErrorWordWithCount>> getErrorWordsWithCounts(int listId) {
    final query =
        select(
            errorWords,
          ).join([innerJoin(words, words.id.equalsExp(errorWords.wordId))])
          ..where(
            errorWords.listId.equals(listId) &
                errorWords.isResolved.equals(false),
          )
          ..orderBy([OrderingTerm.desc(errorWords.errorCount)]);
    return query.map((row) {
      return ErrorWordWithCount(
        word: row.readTable(words),
        errorCount: row.readTable(errorWords).errorCount,
      );
    }).get();
  }

  Future<List<ReviewWordStat>> getReviewWordStats({int? bookId}) async {
    final errorRows = await _selectReviewErrorRows(bookId: bookId);
    final forgottenRows = await _selectReviewForgottenRows(bookId: bookId);
    final cueMemoryRows = await _selectReviewCueMemoryRows(bookId: bookId);

    final statsByWordId = <int, _ReviewWordStatBuilder>{};

    for (final row in errorRows) {
      final builder = statsByWordId.putIfAbsent(
        row.word.id,
        () => _ReviewWordStatBuilder(row.word),
      );
      builder.errorCount += row.errorCount;
      builder.isErrorActive = builder.isErrorActive || !row.isResolved;
    }

    for (final row in forgottenRows) {
      final builder = statsByWordId.putIfAbsent(
        row.word.id,
        () => _ReviewWordStatBuilder(row.word),
      );
      builder.forgottenCount += row.forgottenCount;
      builder.isForgottenActive = builder.isForgottenActive || row.isForgotten;
    }

    for (final row in cueMemoryRows) {
      final builder = statsByWordId.putIfAbsent(
        row.word.id,
        () => _ReviewWordStatBuilder(row.word),
      );
      final shouldUsePosition =
          builder.cueMemoryListCreatedAt == null ||
          row.listCreatedAt < builder.cueMemoryListCreatedAt! ||
          (row.listCreatedAt == builder.cueMemoryListCreatedAt &&
              (row.listId < builder.cueMemoryListId! ||
                  (row.listId == builder.cueMemoryListId &&
                      row.listSortOrder < builder.cueMemoryListSortOrder!)));
      if (shouldUsePosition) {
        builder.cueMemoryListCreatedAt = row.listCreatedAt;
        builder.cueMemoryListId = row.listId;
        builder.cueMemoryListSortOrder = row.listSortOrder;
      }
      builder.cueMemoryCount += row.cueMemoryCount;
      builder.isCueMemoryActive = builder.isCueMemoryActive || row.isCueMemory;
    }

    final stats = statsByWordId.values
        .map(
          (builder) => ReviewWordStat(
            word: builder.word,
            cueMemoryListCreatedAt: builder.cueMemoryListCreatedAt,
            cueMemoryListId: builder.cueMemoryListId,
            cueMemoryListSortOrder: builder.cueMemoryListSortOrder,
            errorCount: builder.errorCount,
            forgottenCount: builder.forgottenCount,
            cueMemoryCount: builder.cueMemoryCount,
            isErrorActive: builder.isErrorActive,
            isForgottenActive: builder.isForgottenActive,
            isCueMemoryActive: builder.isCueMemoryActive,
          ),
        )
        .toList();

    stats.sort(
      (a, b) =>
          a.word.english.toLowerCase().compareTo(b.word.english.toLowerCase()),
    );
    return stats;
  }

  Future<List<_ReviewErrorRow>> _selectReviewErrorRows({int? bookId}) async {
    final query = select(errorWords).join([
      innerJoin(words, words.id.equalsExp(errorWords.wordId)),
      innerJoin(wordLists, wordLists.id.equalsExp(errorWords.listId)),
    ]);
    if (bookId != null) {
      query.where(wordLists.bookId.equals(bookId));
    }
    return query.map((row) {
      final errorWord = row.readTable(errorWords);
      return _ReviewErrorRow(
        id: errorWord.id,
        listId: errorWord.listId,
        word: row.readTable(words),
        errorCount: errorWord.errorCount,
        isResolved: errorWord.isResolved,
      );
    }).get();
  }

  Future<List<_ReviewForgottenRow>> _selectReviewForgottenRows({
    int? bookId,
  }) async {
    final query =
        select(listWords).join([
          innerJoin(words, words.id.equalsExp(listWords.wordId)),
          innerJoin(wordLists, wordLists.id.equalsExp(listWords.listId)),
        ])..where(
          listWords.isForgotten.equals(true) |
              listWords.forgottenCount.isBiggerThanValue(0),
        );
    if (bookId != null) {
      query.where(wordLists.bookId.equals(bookId));
    }
    return query.map((row) {
      final listWord = row.readTable(listWords);
      return _ReviewForgottenRow(
        id: listWord.id,
        word: row.readTable(words),
        forgottenCount: listWord.forgottenCount,
        isForgotten: listWord.isForgotten,
      );
    }).get();
  }

  Future<List<_ReviewCueMemoryRow>> _selectReviewCueMemoryRows({
    int? bookId,
  }) async {
    final query =
        select(listWords).join([
          innerJoin(words, words.id.equalsExp(listWords.wordId)),
          innerJoin(wordLists, wordLists.id.equalsExp(listWords.listId)),
        ])..where(
          listWords.isCueMemory.equals(true) |
              listWords.cueMemoryCount.isBiggerThanValue(0),
        );
    if (bookId != null) {
      query.where(wordLists.bookId.equals(bookId));
    }
    return query.map((row) {
      final listWord = row.readTable(listWords);
      return _ReviewCueMemoryRow(
        id: listWord.id,
        word: row.readTable(words),
        listCreatedAt: row.readTable(wordLists).createdAt,
        listId: listWord.listId,
        listSortOrder: listWord.sortOrder,
        cueMemoryCount: listWord.cueMemoryCount,
        isCueMemory: listWord.isCueMemory,
      );
    }).get();
  }

  Future<void> resolveErrorWords(
    List<int> wordIds, {
    int? bookId,
    int? listId,
  }) async {
    if (wordIds.isEmpty) return;
    await transaction(() async {
      final rows = await _selectReviewErrorRows(bookId: bookId);
      for (final row in rows) {
        if (!wordIds.contains(row.word.id) ||
            row.isResolved ||
            (listId != null && row.listId != listId)) {
          continue;
        }
        await (update(errorWords)..where((t) => t.id.equals(row.id))).write(
          const ErrorWordsCompanion(isResolved: Value(true)),
        );
      }
    });
  }

  Future<void> clearForgottenStatusForWordsInScope(
    List<int> wordIds, {
    int? bookId,
  }) async {
    if (wordIds.isEmpty) return;
    await transaction(() async {
      final query = select(
        listWords,
      ).join([innerJoin(wordLists, wordLists.id.equalsExp(listWords.listId))]);
      if (bookId != null) {
        query.where(wordLists.bookId.equals(bookId));
      }
      final rows = await query.map((row) => row.readTable(listWords)).get();
      for (final row in rows) {
        if (!wordIds.contains(row.wordId) || !row.isForgotten) continue;
        await (update(listWords)..where((t) => t.id.equals(row.id))).write(
          const ListWordsCompanion(isForgotten: Value(false)),
        );
      }
    });
  }

  Future<List<int>> getListIdsContainingWordsInScope(
    List<int> wordIds, {
    int? bookId,
  }) async {
    if (wordIds.isEmpty) return const [];
    final query = select(listWords).join([
      innerJoin(wordLists, wordLists.id.equalsExp(listWords.listId)),
    ])..where(listWords.wordId.isIn(wordIds));
    if (bookId != null) {
      query.where(wordLists.bookId.equals(bookId));
    }
    final rows = await query
        .map((row) => row.readTable(listWords).listId)
        .get();
    return rows.toSet().toList();
  }

  // ─── AI Content ──────────────────────────────────────────────────────────

  Future<AiContentData?> getAiContent(int wordId, String contentType) =>
      (select(aiContent)..where(
            (t) => t.wordId.equals(wordId) & t.contentType.equals(contentType),
          ))
          .getSingleOrNull();

  Future<void> upsertAiContent(AiContentCompanion content) async {
    final existing =
        await (select(aiContent)..where(
              (t) =>
                  t.wordId.equals(content.wordId.value) &
                  t.contentType.equals(content.contentType.value),
            ))
            .getSingleOrNull();
    if (existing != null) {
      await (update(
        aiContent,
      )..where((t) => t.id.equals(existing.id))).write(content);
    } else {
      await into(aiContent).insert(content);
    }
  }

  // ─── Settings ────────────────────────────────────────────────────────────

  Future<String?> getSetting(String key) {
    return (select(
      settings,
    )..where((t) => t.key.equals(key))).map((r) => r.value).getSingleOrNull();
  }

  Future<void> setSetting(String key, String value) async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion(key: Value(key), value: Value(value)),
    );
  }

  // ─── TTS usage/cache records ───────────────────────────────────────────────

  Future<int> insertTtsUsageRecord(Insertable<TtsUsageRecord> record) {
    return into(ttsUsageRecords).insert(record);
  }

  Future<List<TtsUsageRecord>> getRecentTtsUsageRecords(
    String provider,
    int limit,
  ) {
    final query = select(ttsUsageRecords)
      ..where((t) => t.provider.equals(provider))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit);
    return query.get();
  }

  Future<List<TtsUsageRecord>> getAllTtsUsageRecords(String provider) {
    final query = select(ttsUsageRecords)
      ..where((t) => t.provider.equals(provider));
    return query.get();
  }

  /// Upsert by the cache table's natural key rather than [id].
  ///
  /// [insertOnConflictUpdate] targets Drift's primary key (`id`), while this
  /// table deliberately de-duplicates rows by `(provider, language, text)`.
  /// Use SQLite's explicit conflict target so failed words can be retried and
  /// their cache record updated without raising a unique-constraint error.
  Future<void> upsertTtsCacheRecord({
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
    return customStatement(
      '''
INSERT INTO tts_cache_records (
  provider, language, text, cache_key, status, cache_path, error_message,
  audio_bytes, charged_characters, updated_at
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
ON CONFLICT(provider, language, text) DO UPDATE SET
  cache_key = excluded.cache_key,
  status = excluded.status,
  cache_path = excluded.cache_path,
  error_message = excluded.error_message,
  audio_bytes = excluded.audio_bytes,
  charged_characters = excluded.charged_characters,
  updated_at = excluded.updated_at
''',
      [
        provider,
        language,
        text,
        cacheKey,
        status,
        cachePath,
        errorMessage,
        audioBytes,
        chargedCharacters,
        DateTime.now().millisecondsSinceEpoch,
      ],
    );
  }

  Future<void> deleteTtsCacheRecord(int id) async {
    await (delete(ttsCacheRecords)..where((t) => t.id.equals(id))).go();
  }

  Future<List<TtsCacheRecord>> getTtsCacheRecords(
    String provider,
    String language,
  ) {
    final query = select(ttsCacheRecords)
      ..where((t) => t.provider.equals(provider) & t.language.equals(language));
    return query.get();
  }
}
