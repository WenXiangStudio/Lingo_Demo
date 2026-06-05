import 'package:drift/drift.dart';

class WordLists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  BoolColumn get isPassed => boolean().withDefault(const Constant(false))();
  RealColumn get passThreshold =>
      real().withDefault(const Constant(0.75))();
  IntColumn get wordCount => integer().withDefault(const Constant(0))();
  BoolColumn get isShuffled => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();

  @override
  String get tableName => 'word_lists';
}
