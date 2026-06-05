import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';

void main(List<String> args) {
  final dbFile = File(args.isNotEmpty ? args[0] : r'D:\LingoDemoData\lingo.db');
  final csvFile = File(r'D:\LingoDemo\lingo_app\assets\word_books\CET4.csv');
  final sqliteExe = File(r'D:\AndroidSDK\platform-tools\sqlite3.exe');

  if (!dbFile.existsSync()) _fail('Database not found: ${dbFile.path}');
  if (!csvFile.existsSync()) _fail('CSV not found: ${csvFile.path}');
  if (!sqliteExe.existsSync()) _fail('sqlite3 not found: ${sqliteExe.path}');

  final rows = _readCsv(csvFile);
  final dataRows = rows.skip(1).toList();
  final header = rows.first.map((c) => c.trim().toLowerCase()).toList();
  final englishIdx = _column(header, 'english');
  final chineseIdx = _column(header, 'chinese_meanings');
  final pronunciationIdx = _column(header, 'pronunciation');
  final scenarioIdx = _column(header, 'scenario_example');
  final translationIdx = _column(header, 'scenario_translation');

  _assertSingleCet4Book(sqliteExe, dbFile);

  final backup = File(
    r'D:\LingoDemoData\lingo.db.before-cet4-scenario-translation.bak',
  );
  dbFile.copySync(backup.path);

  final tableInfo = _sqlite(sqliteExe, dbFile, 'PRAGMA table_info(words);');
  final hasTranslationColumn = tableInfo.stdout
      .toString()
      .split('\n')
      .any((line) => line.split('|').contains('scenario_translation'));

  final sql = StringBuffer();
  sql.writeln('BEGIN TRANSACTION;');
  if (!hasTranslationColumn) {
    sql.writeln('ALTER TABLE words ADD COLUMN scenario_translation TEXT;');
  }
  for (var i = 0; i < dataRows.length; i++) {
    final row = dataRows[i];
    final id = i + 1;
    sql.writeln(
      'UPDATE words SET '
      'english=${_q(row[englishIdx])}, '
      'chinese_meanings=${_q(row[chineseIdx])}, '
      'pronunciation=${_q(row[pronunciationIdx])}, '
      'scenario_example=${_q(row[scenarioIdx])}, '
      'scenario_translation=${_q(row[translationIdx])} '
      'WHERE id=$id;',
    );
  }

  for (final row in dataRows) {
    sql.writeln(
      'UPDATE words SET '
      'scenario_example=${_q(row[scenarioIdx])}, '
      'scenario_translation=${_q(row[translationIdx])} '
      'WHERE id>${dataRows.length} '
      'AND english=${_q(row[englishIdx])} '
      'AND chinese_meanings=${_q(row[chineseIdx])};',
    );
  }
  sql.writeln('PRAGMA user_version = 5;');
  sql.writeln('COMMIT;');

  final sqlFile = File(r'D:\tmp\lingo_cet4_sync.sql');
  sqlFile.writeAsStringSync(sql.toString(), encoding: utf8);
  final result = Process.runSync(sqliteExe.path, [
    dbFile.path,
    '.read ${sqlFile.path}',
  ]);
  if (result.exitCode != 0) {
    _fail('sqlite update failed:\n${result.stderr}');
  }

  stdout.writeln('Database synchronized.');
  stdout.writeln('Updated primary CET4 rows: ${dataRows.length}');
  stdout.writeln('Backup: ${backup.path}');
}

List<List<String>> _readCsv(File file) {
  final content = file.readAsStringSync(encoding: utf8);
  final normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  return const CsvToListConverter(eol: '\n')
      .convert(normalized)
      .map((row) => row.map((cell) => cell.toString()).toList())
      .toList();
}

int _column(List<String> header, String name) {
  final index = header.indexOf(name);
  if (index < 0) _fail('Missing CSV column: $name');
  return index;
}

void _assertSingleCet4Book(File sqliteExe, File dbFile) {
  final result = _sqlite(
    sqliteExe,
    dbFile,
    "SELECT COUNT(*) || '|' || IFNULL(MIN(name), '') FROM word_books;",
  );
  final value = result.stdout.toString().trim();
  if (value != '1|CET-4') {
    _fail('Database is not the expected single CET-4 book: $value');
  }
}

ProcessResult _sqlite(File sqliteExe, File dbFile, String sql) {
  final result = Process.runSync(sqliteExe.path, [dbFile.path, sql]);
  if (result.exitCode != 0) {
    _fail('sqlite failed:\n${result.stderr}');
  }
  return result;
}

String _q(String value) => "'${value.replaceAll("'", "''")}'";

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}
