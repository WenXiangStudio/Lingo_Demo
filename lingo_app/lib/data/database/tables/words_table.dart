import 'package:drift/drift.dart';

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
