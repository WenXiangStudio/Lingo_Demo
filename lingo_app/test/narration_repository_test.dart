import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lingo_app/data/database/app_database.dart';
import 'package:lingo_app/data/models/narration_ai_models.dart';
import 'package:lingo_app/data/repositories/narration_repository.dart';
import 'package:lingo_app/features/narration/models/narration_models.dart';

void main() {
  late AppDatabase database;
  late NarrationRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = NarrationRepository(database);
  });

  tearDown(() => database.close());

  test(
    'keeps raw transcript while confirming a cleaned working copy',
    () async {
      final id = await repository.createSession(
        rawTranscript: 'I I have an apple um.',
        cleanedTranscript: 'I I have an apple um.',
        confidence: NarrationTranscriptConfidence.medium,
      );

      await repository.confirmTranscript(
        sessionId: id,
        cleanedTranscript: 'I have an apple.',
        confidence: NarrationTranscriptConfidence.high,
      );

      final session = await repository.getSession(id);
      expect(session!.rawTranscript, 'I I have an apple um.');
      expect(session.cleanedTranscript, 'I have an apple.');
      expect(session.status, NarrationSessionStatus.translation);
    },
  );

  test('schema version 10 creates every narration data boundary', () async {
    expect(database.schemaVersion, 10);
    final rows = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name LIKE 'narration_%'",
        )
        .get();
    final names = rows.map((row) => row.read<String>('name')).toSet();
    expect(
      names,
      containsAll({
        'narration_sessions',
        'narration_transcription_logs',
        'narration_self_check_logs',
        'narration_feedback_logs',
        'narration_learning_items',
        'narration_learning_sources',
        'narration_review_records',
        'narration_progress_records',
        'narration_consent_records',
      }),
    );
  });

  test('only enters target review after a target draft exists', () async {
    final id = await repository.createSession(
      rawTranscript: 'This is my first recording.',
      cleanedTranscript: 'This is my first recording.',
      confidence: NarrationTranscriptConfidence.high,
    );
    await repository.confirmTranscript(
      sessionId: id,
      cleanedTranscript: 'This is my first recording.',
      confidence: NarrationTranscriptConfidence.high,
    );
    await repository.saveConfirmedTranslation(
      sessionId: id,
      chineseTranslation: '这是我的第一条录音。',
    );

    var session = await repository.getSession(id);
    expect(session!.status, NarrationSessionStatus.translation);
    expect(session.translationConfirmed, isTrue);
    expect(session.targetEnglish, isNull);

    await repository.saveTargetDraft(
      sessionId: id,
      target: const NarrationTargetDraft(
        recommended: 'This is my first recording.',
      ),
    );
    session = await repository.getSession(id);
    expect(session!.status, NarrationSessionStatus.targetReview);
    expect(session.targetEnglish, 'This is my first recording.');
  });

  test('merges learning entries and advances review state', () async {
    final firstId = await _confirmedSession(repository);
    await repository.confirmFinalExpression(
      sessionId: firstId,
      finalExpression: 'I have an apple.',
    );
    final secondId = await _confirmedSession(repository);
    await repository.confirmFinalExpression(
      sessionId: secondId,
      finalExpression: 'I bought an apple.',
    );

    final items = await repository.getLearningItems();
    final apple = items.singleWhere(
      (item) => item.type == NarrationLearningItemType.word,
    );
    final article = items.singleWhere(
      (item) => item.type == NarrationLearningItemType.knowledge,
    );
    expect(apple.stableKey, 'apple');
    expect(apple.occurrenceCount, 2);
    expect(article.occurrenceCount, 2);

    await repository.recordReview(
      itemId: apple.id,
      layer: 'recognition',
      passed: true,
      answer: 'apple',
    );
    await repository.recordReview(
      itemId: apple.id,
      layer: 'application',
      passed: true,
      answer: 'I ate an apple.',
    );
    final reviewed = (await repository.getLearningItems()).singleWhere(
      (item) => item.id == apple.id,
    );
    expect(reviewed.recognitionPassed, isTrue);
    expect(reviewed.applicationPassed, isTrue);
    expect(reviewed.masteryState, NarrationMasteryState.pendingVerification);
  });

  test('real-use success marks an existing item mastered', () async {
    final firstId = await _confirmedSession(repository);
    await repository.confirmFinalExpression(
      sessionId: firstId,
      finalExpression: 'I have an apple.',
    );

    final secondId = await _confirmedSession(
      repository,
      realUseEvents: const [
        NarrationRealUsageEvent(
          itemType: 'word',
          stableKey: 'apple',
          outcome: 'success',
          evidence: 'I bought an apple.',
        ),
      ],
    );
    await repository.confirmFinalExpression(
      sessionId: secondId,
      finalExpression: 'I bought an apple.',
    );

    final apple = (await repository.getLearningItems()).singleWhere(
      (item) => item.stableKey == 'apple',
    );
    expect(apple.masteryState, NarrationMasteryState.mastered);
    expect(apple.realUseSuccessCount, 1);
    expect(apple.queueState, NarrationQueueState.lowFrequency);
  });

  test('deletes every narration table for the user-control action', () async {
    final id = await _confirmedSession(repository);
    await repository.confirmFinalExpression(
      sessionId: id,
      finalExpression: 'I have an apple.',
    );
    await repository.recordConsent(
      consentType: 'narration_processing',
      granted: true,
    );

    await repository.deleteAllNarrationData();

    expect(await repository.getRecentSessions(), isEmpty);
    expect(await repository.getLearningItems(), isEmpty);
    expect(await repository.getProgress(), isEmpty);
    expect(await repository.hasGrantedConsent('narration_processing'), isFalse);
  });

  test('user objection and known-item confirmation are persisted', () async {
    final id = await _confirmedSession(repository);
    await repository.confirmFinalExpression(
      sessionId: id,
      finalExpression: 'I have an apple.',
    );
    final apple = (await repository.getLearningItems()).singleWhere(
      (item) => item.stableKey == 'apple',
    );

    await repository.markLearningItemKnown(apple.id);
    await repository.recordFeedback(
      sessionId: id,
      stage: 'error_analysis',
      originalJudgement: 'Wrong article',
      systemExplanation: 'English article rules apply.',
      userReason: 'I self-corrected immediately.',
      resolution: 'user_override',
    );

    final known = (await repository.getLearningItems()).singleWhere(
      (item) => item.id == apple.id,
    );
    final exported = await repository.exportJson();
    expect(known.userConfirmed, isTrue);
    expect(known.queueState, NarrationQueueState.lowFrequency);
    expect(exported, contains('user_override'));
    expect(exported, contains('user_confirmed_known'));
  });
}

Future<int> _confirmedSession(
  NarrationRepository repository, {
  List<NarrationRealUsageEvent> realUseEvents = const [],
}) async {
  final id = await repository.createSession(
    rawTranscript: 'I have a 苹果.',
    cleanedTranscript: 'I have a 苹果.',
    confidence: NarrationTranscriptConfidence.high,
  );
  await repository.confirmTranscript(
    sessionId: id,
    cleanedTranscript: 'I have a 苹果.',
    confidence: NarrationTranscriptConfidence.high,
  );
  await repository.saveConfirmedTranslation(
    sessionId: id,
    chineseTranslation: '我有一个苹果。',
  );
  await repository.confirmTarget(
    sessionId: id,
    targetEnglish: 'I have an apple.',
  );
  await repository.saveAnalysis(
    sessionId: id,
    analysis: NarrationAnalysis(
      normalizedTranscript: 'I have a 苹果.',
      correctedExpression: 'I have an apple.',
      collectedWords: const [
        NarrationCollectedWord(
          stableKey: 'apple',
          chinese: '苹果',
          english: 'apple',
          partOfSpeech: 'noun',
          category: 'word',
        ),
      ],
      knowledgePoints: const [
        NarrationKnowledgePoint(
          stableKey: 'articles_a_an',
          title: 'a/an',
          explanation: 'Use an before a vowel sound.',
          level: 'core',
          source: 'error',
          reviewRequired: true,
          errorGrade: 'B',
        ),
      ],
      errors: const [
        NarrationErrorItem(
          grade: 'B',
          original: 'a 苹果',
          issue: 'Wrong article',
          correction: 'an apple',
          reason: 'Apple begins with a vowel sound.',
        ),
      ],
      selfCheck: const NarrationSelfCheckReport(
        iterations: 1,
        needsUserConfirmation: false,
      ),
      metrics: const NarrationMetrics(
        englishWordCount: 3,
        sentenceCount: 1,
        chineseSubstituteCount: 1,
        errorBCount: 1,
      ),
      realUsageEvents: realUseEvents,
    ),
  );
  return id;
}
