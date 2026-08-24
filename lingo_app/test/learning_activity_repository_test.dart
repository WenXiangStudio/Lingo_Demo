import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lingo_app/data/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('activity lifecycle only returns completed records for a day', () async {
    final bookId = await database.insertBook(
      WordBooksCompanion(
        name: const Value('Test Book'),
        totalWords: const Value(2),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    final listId = await database.insertList(
      WordListsCompanion(
        bookId: Value(bookId),
        name: const Value('List 1'),
        wordCount: const Value(2),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    final wordId = await database.insertWord(
      WordsCompanion(
        english: const Value('focus'),
        chineseMeanings: const Value('重点'),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    await database.addWordsToList(listId, [wordId], [0]);

    final started = await database.startActivity(
      activityType: LearningActivityType.aiLearning,
      subtype: 'deep_choice',
      listIds: [listId],
      wordIds: [wordId],
    );
    final abandoned = await database.startActivity(
      activityType: LearningActivityType.dialogue,
      listIds: [listId],
    );
    await database.abandonActivity(abandoned);
    await database.completeActivity(
      started,
      questionCount: 2,
      correctCount: 1,
      accuracy: 0.5,
      wordIds: [wordId],
      errorWordIds: [wordId],
      wordUsageCounts: {wordId: 2},
    );

    final activities = await database.getActivitiesForDay(DateTime.now());
    expect(activities.map((activity) => activity.id), contains(started));
    expect(
      activities.map((activity) => activity.id),
      isNot(contains(abandoned)),
    );
    final summary = await database.getDailyAiSummary(
      DateTime.now(),
      bookId: bookId,
    );
    expect(summary.aiLearningQuestionCount, 2);
    expect(summary.aiLearningCorrectCount, 1);
    expect(summary.focusWords.single.word.id, wordId);
    expect(summary.focusWords.single.errorCount, 1);
  });

  test(
    'memorization dashboard uses weighted answers and ignores AI sessions',
    () async {
      final listId = await database.insertList(
        WordListsCompanion(
          name: const Value('List 1'),
          wordCount: const Value(1),
          createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
      final wordId = await database.insertWord(
        WordsCompanion(
          english: const Value('word'),
          chineseMeanings: const Value('词'),
          createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
      await database.addWordsToList(listId, [wordId], [0]);
      final now = DateTime.now().millisecondsSinceEpoch;
      final ordinary = await database.insertSession(
        PracticeSessionsCompanion(
          listId: Value(listId),
          mode: const Value('choice'),
          sessionKind: const Value(PracticeSessionKind.memorization),
          totalCount: const Value(2),
          correctCount: const Value(1),
          accuracy: const Value(0.5),
          startedAt: Value(now),
          finishedAt: Value(now),
        ),
      );
      await database.insertAnswers([
        PracticeAnswersCompanion(
          sessionId: Value(ordinary),
          wordId: Value(wordId),
          isCorrect: const Value(true),
          correctAnswer: const Value('词'),
          answeredAt: Value(now),
        ),
        PracticeAnswersCompanion(
          sessionId: Value(ordinary),
          wordId: Value(wordId),
          isCorrect: const Value(false),
          correctAnswer: const Value('词'),
          answeredAt: Value(now + 1),
        ),
      ]);
      final ai = await database.insertSession(
        PracticeSessionsCompanion(
          listId: Value(listId),
          mode: const Value('deep_fill'),
          sessionKind: const Value(PracticeSessionKind.aiLearning),
          totalCount: const Value(1),
          correctCount: const Value(1),
          accuracy: const Value(1),
          startedAt: Value(now),
          finishedAt: Value(now),
        ),
      );
      await database.insertAnswers([
        PracticeAnswersCompanion(
          sessionId: Value(ai),
          wordId: Value(wordId),
          isCorrect: const Value(true),
          correctAnswer: const Value('词'),
          answeredAt: Value(now + 2),
        ),
      ]);

      final review = (await database.getDailyListReview(DateTime.now())).single;
      expect(review.practiceCount, 1);
      expect(review.totalAnswerCount, 2);
      expect(review.accuracy, 0.5);
      expect(review.coveredWordCount, 1);
    },
  );

  test('cue memory collection is separate from forgotten collection', () async {
    final listId = await database.insertList(
      WordListsCompanion(
        name: const Value('List 1'),
        wordCount: const Value(1),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    final wordId = await database.insertWord(
      WordsCompanion(
        english: const Value('recall'),
        chineseMeanings: const Value('回忆'),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    await database.addWordsToList(listId, [wordId], [0]);

    await database.markWordCueMemory(wordId, listId);
    await database.markWordCueMemory(wordId, listId);

    final stats = await database.getReviewWordStats();
    expect(stats, hasLength(1));
    expect(stats.single.isCueMemoryActive, isTrue);
    expect(stats.single.cueMemoryCount, 1);
    expect(stats.single.isForgottenActive, isFalse);
    expect(stats.single.forgottenCount, 0);
  });
}
