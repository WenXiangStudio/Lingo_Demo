import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
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

  @override
  String get tableName => 'list_words';

  @override
  List<String> get customConstraints => ['UNIQUE(list_id, word_id)'];
}

class PracticeSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get listId => integer().references(WordLists, #id)();
  TextColumn get mode => text().withLength(min: 1, max: 20)();
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
  final int errorCount;
  final int forgottenCount;
  final bool isErrorActive;
  final bool isForgottenActive;

  const ReviewWordStat({
    required this.word,
    required this.errorCount,
    required this.forgottenCount,
    required this.isErrorActive,
    required this.isForgottenActive,
  });
}

class _ReviewWordStatBuilder {
  final Word word;
  int errorCount = 0;
  int forgottenCount = 0;
  bool isErrorActive = false;
  bool isForgottenActive = false;

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
    TtsUsageRecords,
    TtsCacheRecords,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

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
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      if (Platform.isAndroid || Platform.isIOS) {
        final dbFolder = await getApplicationDocumentsDirectory();
        final file = File(p.join(dbFolder.path, 'lingo.db'));
        return NativeDatabase.createInBackground(file);
      }
      // Windows/macOS/Linux desktop: persist to file
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

  // ─── Forgotten Words ──────────────────────────────────────────────────────

  Future<void> markWordForgotten(int wordId, int listId) async {
    final existing = await (select(listWords)
          ..where((t) => t.wordId.equals(wordId) & t.listId.equals(listId)))
        .getSingleOrNull();
    if (existing == null) return;
    await (update(listWords)
          ..where((t) => t.wordId.equals(wordId) & t.listId.equals(listId)))
        .write(
      ListWordsCompanion(
        isForgotten: const Value(true),
        forgottenCount: Value(existing.forgottenCount + 1),
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
          ..where(errorWords.listId.equals(listId) & errorWords.isResolved.equals(false))
          ..orderBy([OrderingTerm.desc(errorWords.errorCount)]);
    return query.map((row) => row.readTable(words)).get();
  }

  Future<List<ErrorWordWithCount>> getErrorWordsWithCounts(int listId) {
    final query =
        select(
            errorWords,
          ).join([innerJoin(words, words.id.equalsExp(errorWords.wordId))])
          ..where(errorWords.listId.equals(listId) & errorWords.isResolved.equals(false))
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

    final stats = statsByWordId.values
        .map(
          (builder) => ReviewWordStat(
            word: builder.word,
            errorCount: builder.errorCount,
            forgottenCount: builder.forgottenCount,
            isErrorActive: builder.isErrorActive,
            isForgottenActive: builder.isForgottenActive,
          ),
        )
        .toList();

    stats.sort((a, b) => a.word.english.toLowerCase().compareTo(
          b.word.english.toLowerCase(),
        ));
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
    final query = select(listWords).join([
      innerJoin(words, words.id.equalsExp(listWords.wordId)),
      innerJoin(wordLists, wordLists.id.equalsExp(listWords.listId)),
    ])
      ..where(
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
      final query = select(listWords).join([
        innerJoin(wordLists, wordLists.id.equalsExp(listWords.listId)),
      ]);
      if (bookId != null) {
        query.where(wordLists.bookId.equals(bookId));
      }
      final rows = await query
          .map((row) => row.readTable(listWords))
          .get();
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
    final rows = await query.map((row) => row.readTable(listWords).listId).get();
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

  Future<void> upsertTtsCacheRecord(Insertable<TtsCacheRecord> record) async {
    await into(ttsCacheRecords).insertOnConflictUpdate(record);
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
