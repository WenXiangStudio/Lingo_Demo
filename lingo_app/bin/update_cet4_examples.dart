import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';

class ExampleEntry {
  final int index;
  final String word;
  final String englishExample;
  final String chineseTranslation;
  final String sourceFile;

  const ExampleEntry({
    required this.index,
    required this.word,
    required this.englishExample,
    required this.chineseTranslation,
    required this.sourceFile,
  });
}

class RangeSpec {
  final int start;
  final int end;

  const RangeSpec(this.start, this.end);
}

void main(List<String> args) {
  final examplesDir = Directory(args.isNotEmpty ? args[0] : r'D:\word_dict\例句');
  final sourceCsv = File(r'D:\LingoDemo\word_books\CET4.csv');
  final assetCsv = File(r'D:\LingoDemo\lingo_app\assets\word_books\CET4.csv');

  if (!examplesDir.existsSync()) {
    _fail('Examples directory not found: ${examplesDir.path}');
  }
  if (!sourceCsv.existsSync()) {
    _fail('Source CSV not found: ${sourceCsv.path}');
  }

  final sourceRows = _readCsv(sourceCsv);
  final entries = _readExampleEntries(examplesDir);
  _validateEntries(entries, sourceRows);

  final outputRows = <List<String>>[
    [
      'english',
      'chinese_meanings',
      'pronunciation',
      'scenario_example',
      'scenario_translation',
    ],
  ];

  final dataRows = sourceRows.skip(1).toList();
  for (var i = 0; i < dataRows.length; i++) {
    final row = dataRows[i];
    final entry = entries[i];
    outputRows.add([
      row[_columnIndex(sourceRows, 'english')],
      row[_columnIndex(sourceRows, 'chinese_meanings')],
      row[_columnIndex(sourceRows, 'pronunciation')],
      entry.englishExample,
      entry.chineseTranslation,
    ]);
  }

  final csv = const ListToCsvConverter(eol: '\r\n').convert(outputRows);
  sourceCsv.writeAsStringSync(csv, encoding: utf8);
  assetCsv.writeAsStringSync(csv, encoding: utf8);

  stdout.writeln('Updated CET4 examples successfully.');
  stdout.writeln('Rows: ${dataRows.length}');
  stdout.writeln('Source: ${sourceCsv.path}');
  stdout.writeln('Asset: ${assetCsv.path}');
}

List<List<String>> _readCsv(File file) {
  final content = file.readAsStringSync(encoding: utf8);
  final normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final rows = const CsvToListConverter(eol: '\n').convert(normalized);
  if (rows.isEmpty) _fail('CSV is empty: ${file.path}');
  return rows
      .map((row) => row.map((cell) => cell.toString()).toList())
      .toList();
}

int _columnIndex(List<List<String>> rows, String name) {
  final header = rows.first.map((c) => c.trim().toLowerCase()).toList();
  final index = header.indexOf(name);
  if (index < 0) _fail('Missing required CSV column: $name');
  return index;
}

List<ExampleEntry> _readExampleEntries(Directory dir) {
  final files =
      dir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.toLowerCase().endsWith('.md'))
          .toList()
        ..sort((a, b) => _rangeFor(a).start.compareTo(_rangeFor(b).start));

  final entries = <ExampleEntry>[];
  for (final file in files) {
    final range = _rangeFor(file);
    final lines = file.readAsLinesSync(encoding: utf8);
    final numbered = lines.any((line) => _numberedHeader.hasMatch(line));
    final parsed = numbered
        ? _parseNumberedFile(file, range, lines)
        : _parseTripletFile(file, range, lines);
    entries.addAll(parsed);
  }
  entries.sort((a, b) => a.index.compareTo(b.index));
  return entries;
}

RangeSpec _rangeFor(File file) {
  final name = file.uri.pathSegments.last;
  final match = RegExp(r'第(\d+)~(\d+)').firstMatch(name);
  if (match == null) {
    _fail('Could not read range from file name: $name');
  }
  return RangeSpec(int.parse(match.group(1)!), int.parse(match.group(2)!));
}

final _numberedHeader = RegExp(r'^\s*(\d+)\.\s+(.+?)\s*$');

List<ExampleEntry> _parseNumberedFile(
  File file,
  RangeSpec range,
  List<String> lines,
) {
  final entries = <ExampleEntry>[];
  for (var i = 0; i < lines.length; i++) {
    final headerMatch = _numberedHeader.firstMatch(lines[i]);
    if (headerMatch == null) continue;

    final localNo = int.parse(headerMatch.group(1)!);
    final word = _cleanWord(headerMatch.group(2)!);
    final index = range.start + localNo - 1;

    final body = <String>[];
    var j = i + 1;
    while (j < lines.length && !_numberedHeader.hasMatch(lines[j])) {
      final line = lines[j].trim();
      if (line.isNotEmpty && line != '---') {
        body.add(_cleanBodyLine(line));
      }
      j++;
    }
    final example = _extractExampleBody(body, file, localNo);
    if (example == null) {
      _fail('Incomplete entry $localNo in ${file.path}');
    }
    entries.add(
      ExampleEntry(
        index: index,
        word: word,
        englishExample: example.$1,
        chineseTranslation: example.$2,
        sourceFile: file.uri.pathSegments.last,
      ),
    );
  }
  _validateRangeCount(file, range, entries.length);
  return entries;
}

(String, String)? _extractExampleBody(
  List<String> body,
  File file,
  int localNo,
) {
  if (body.length >= 2) return (body[0], body[1]);
  if (body.length != 1) return null;

  final slashMatch = RegExp(r'^(.+?)\s+/\s+(.+)$').firstMatch(body.single);
  if (slashMatch == null) return null;
  final english = slashMatch.group(1)!.trim();
  final chinese = slashMatch.group(2)!.trim();
  if (english.isEmpty || chinese.isEmpty) return null;
  return (english, chinese);
}

List<ExampleEntry> _parseTripletFile(
  File file,
  RangeSpec range,
  List<String> lines,
) {
  final nonEmpty = lines
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty && line != '---')
      .toList();
  if (nonEmpty.length % 3 != 0) {
    _fail('Triplet file has ${nonEmpty.length} non-empty lines: ${file.path}');
  }

  final entries = <ExampleEntry>[];
  for (var i = 0; i < nonEmpty.length; i += 3) {
    final index = range.start + (i ~/ 3);
    entries.add(
      ExampleEntry(
        index: index,
        word: _cleanWord(nonEmpty[i]),
        englishExample: _cleanBodyLine(nonEmpty[i + 1]),
        chineseTranslation: _cleanBodyLine(nonEmpty[i + 2]),
        sourceFile: file.uri.pathSegments.last,
      ),
    );
  }
  _validateRangeCount(file, range, entries.length);
  return entries;
}

void _validateRangeCount(File file, RangeSpec range, int count) {
  final expected = range.end - range.start + 1;
  if (count != expected) {
    _fail(
      '${file.uri.pathSegments.last} has $count entries, expected $expected.',
    );
  }
}

String _cleanWord(String value) {
  var result = value.trim();
  result = result.replaceAll('**', '');
  result = result.replaceAll(RegExp(r'\s*[(（][^)）]*[)）]\s*$'), '');
  return _normalizeQuotes(result.trim());
}

String _cleanBodyLine(String value) {
  var result = value.trim();
  result = result.replaceFirst(RegExp(r'^-\s*'), '');
  result = result.replaceFirst(RegExp(r'^\*\*例句:\*\*\s*'), '');
  result = result.replaceFirst(RegExp(r'^\*\*中文:\*\*\s*'), '');
  result = result.replaceFirst(RegExp(r'^例句[:：]\s*'), '');
  result = result.replaceFirst(RegExp(r'^中文[:：]\s*'), '');
  result = result.replaceAll('**', '');
  return _normalizeQuotes(result.trim());
}

String _normalizeQuotes(String value) {
  return value
      .replaceAll(RegExp('[‘’‛′＇]'), "'")
      .replaceAll(RegExp('[“”″＂]'), '"');
}

void _validateEntries(
  List<ExampleEntry> entries,
  List<List<String>> sourceRows,
) {
  final expectedCount = sourceRows.length - 1;
  if (entries.length != expectedCount) {
    _fail('Parsed ${entries.length} examples, expected $expectedCount.');
  }

  final englishIndex = _columnIndex(sourceRows, 'english');
  final issues = <String>[];
  for (var i = 0; i < entries.length; i++) {
    final expectedIndex = i + 1;
    final entry = entries[i];
    final csvWord = sourceRows[i + 1][englishIndex];
    if (entry.index != expectedIndex || entry.word != csvWord) {
      issues.add(
        '#$expectedIndex: file=${entry.sourceFile}, parsed=${entry.index} '
        '${entry.word}, csv=$csvWord',
      );
    }
    if (entry.englishExample.isEmpty || entry.chineseTranslation.isEmpty) {
      issues.add('#$expectedIndex: empty example or translation');
    }
  }

  if (issues.isNotEmpty) {
    stderr.writeln('Validation failed: ${issues.length} issue(s).');
    for (final issue in issues.take(50)) {
      stderr.writeln(issue);
    }
    _fail('CET4 example fragments do not match source CSV order.');
  }
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}
