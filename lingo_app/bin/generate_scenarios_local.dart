// ignore_for_file: avoid_print

// Batch script: generate scenario_example sentences using local templates.
//
// Instant: no API calls, no network, zero cost.
// Deterministic: the same word always gets the same sentence.
//
// Usage:
//   dart run bin/generate_scenarios_local.dart <input.csv> [output.csv]

import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';

import 'package:lingo_app/data/ai/scenario_templates.dart';

void main(List<String> args) async {
  if (args.isEmpty || args.first == '--help') {
    print(
      'Usage: dart run bin/generate_scenarios_local.dart <input.csv> [output.csv]',
    );
    return;
  }

  final inputPath = args.first;
  final outputPath = args.length > 1
      ? args[1]
      : inputPath.replaceAll('.csv', '_with_scenarios.csv');

  final file = File(inputPath);
  if (!await file.exists()) {
    stderr.writeln('File not found: $inputPath');
    exit(1);
  }

  final content = await file.readAsString(encoding: utf8);
  final normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final rows = const CsvToListConverter(eol: '\n').convert(normalized);
  if (rows.isEmpty) {
    stderr.writeln('CSV is empty.');
    exit(1);
  }

  final header = rows.first.map((c) => c.toString().trim()).toList();
  final engIdx = header.indexWhere((h) => h.toLowerCase() == 'english');
  final chnIdx = header.indexWhere(
    (h) => h.toLowerCase() == 'chinese_meanings',
  );

  if (engIdx == -1 || chnIdx == -1) {
    stderr.writeln('CSV must have english and chinese_meanings columns.');
    exit(1);
  }

  final outHeader = List<String>.from(header);
  if (!outHeader.any((h) => h.toLowerCase() == 'scenario_example')) {
    outHeader.add('scenario_example');
  }

  final sink = File(outputPath).openWrite(encoding: utf8);
  const eol = '\r\n';
  sink.write(const ListToCsvConverter().convert([outHeader]));
  sink.write(eol);

  int done = 0;
  int empty = 0;

  for (var i = 1; i < rows.length; i++) {
    final row = rows[i];
    if (row.length <= engIdx || row.length <= chnIdx) continue;
    final english = row[engIdx].toString().trim();
    final chinese = row[chnIdx].toString().trim();
    if (english.isEmpty || chinese.isEmpty) continue;

    final scenario = generateScenarioExample(english, chinese);

    if (scenario.isNotEmpty) {
      done++;
    } else {
      empty++;
    }

    final newRow = List<String>.from(row.map((c) => c.toString().trim()));
    while (newRow.length < outHeader.length - 1) {
      newRow.add('');
    }
    newRow.add(scenario);
    sink.write(const ListToCsvConverter().convert([newRow]));
    sink.write(eol);
  }

  await sink.flush();
  await sink.close();

  print('Done: $outputPath');
  print('Generated: $done, Empty (unknown POS): $empty');
  print('Total: ${rows.length - 1} words');
}
