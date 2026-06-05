/// Batch script: generate scenario_example sentences for word book CSVs.
///
/// Usage:
///   dart run bin/generate_scenarios.dart <input.csv> [--apikey KEY] [--provider openai|deepseek|...] [--batch N]
///
/// The script reads a CSV with columns: english, chinese_meanings, pronunciation
/// and writes a new CSV with an added `scenario_example` column.
///
/// Requires an API key. Set DART_AI_API_KEY env var or pass --apikey.
/// Default provider: openai (gpt-4o-mini for cost efficiency).

import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';

String _prompt(String word, String meaning) =>
    'Write a natural English sentence using the word "$word" (meaning: $meaning). '
    'Keep it under 20 words, show everyday usage. '
    'Return ONLY a JSON array: ["<your sentence here>"]';

void main(List<String> args) async {
  if (args.isEmpty || args.first == '--help') {
    print('Usage: dart run bin/generate_scenarios.dart <input.csv> [--apikey KEY] [--provider openai|deepseek] [--batch 5]');
    print('Env: DART_AI_API_KEY');
    return;
  }

  final inputPath = args.first;
  final file = File(inputPath);
  if (!await file.exists()) {
    stderr.writeln('File not found: $inputPath');
    exit(1);
  }

  // Parse args
  String? apiKey = Platform.environment['DART_AI_API_KEY'];
  String provider = 'openai';

  for (var i = 1; i < args.length; i++) {
    if (args[i] == '--apikey' && i + 1 < args.length) {
      apiKey = args[++i];
    } else if (args[i] == '--provider' && i + 1 < args.length) {
      provider = args[++i];
    }
  }

  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln('API key required. Set DART_AI_API_KEY env var or pass --apikey.');
    exit(1);
  }

  // Read CSV
  final content = await file.readAsString();
  final rows = const CsvToListConverter().convert(content);
  if (rows.isEmpty) {
    stderr.writeln('CSV is empty.');
    exit(1);
  }

  final header = rows.first.map((c) => c.toString().trim().toLowerCase()).toList();
  final engIdx = header.indexOf('english');
  final chnIdx = header.indexOf('chinese_meanings');

  if (engIdx == -1 || chnIdx == -1) {
    stderr.writeln('CSV must have english and chinese_meanings columns.');
    exit(1);
  }

  // Extract words
  final words = <_WordEntry>[];
  for (var i = 1; i < rows.length; i++) {
    final row = rows[i];
    if (row.length <= engIdx || row.length <= chnIdx) continue;
    final eng = row[engIdx].toString().trim();
    final chn = row[chnIdx].toString().trim();
    if (eng.isEmpty || chn.isEmpty) continue;
    words.add(_WordEntry(eng, chn));
  }

  print('Loaded ${words.length} words from $inputPath');
  print('Provider: $provider (one word per call, full isolation)');

  // Get API config
  final (baseUrl, model) = _providerConfig(provider);

  // Process one word at a time — full isolation
  final outputPath = inputPath.replaceAll('.csv', '_with_scenarios.csv');
  final outputFile = File(outputPath);

  final scenarioIdx = header.indexOf('scenario_example');
  final newHeader = List<String>.from(rows.first.map((c) => c.toString().trim()));
  if (scenarioIdx == -1) {
    newHeader.add('scenario_example');
  }
  final sink = outputFile.openWrite();
  sink.writeln(const ListToCsvConverter().convert([newHeader]));

  for (var i = 0; i < words.length; i++) {
    final w = words[i];
    stdout.write('[${i + 1}/${words.length}] $w.english... ');

    String sentence = '';
    try {
      sentence = await _generateOne(w.english, w.chinese, baseUrl, model, apiKey);
      stdout.writeln(sentence);
    } catch (e) {
      stdout.writeln('ERROR: $e');
    }

    // Write row
    final originalRow = rows[i + 1];
    final newRow = List<String>.from(originalRow.map((c) => c.toString().trim()));
    while (newRow.length < newHeader.length - 1) {
      newRow.add('');
    }
    newRow.add(sentence);
    sink.writeln(const ListToCsvConverter().convert([newRow]));

    // Brief pause between calls
    await Future.delayed(const Duration(milliseconds: 50));
  }

  await sink.flush();
  await sink.close();
  print('Done! Output: $outputPath');
}

Future<String> _generateOne(
  String word,
  String meaning,
  String baseUrl,
  String model,
  String apiKey,
) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse('$baseUrl/v1/chat/completions'));
    request.headers.set('Authorization', 'Bearer $apiKey');
    request.headers.set('Content-Type', 'application/json');

    final prompt = _prompt(word, meaning);

    final body = jsonEncode({
      'model': model,
      'messages': [
        {'role': 'user', 'content': prompt},
      ],
      'temperature': 0.7,
      'max_tokens': 128,
    });

    request.add(utf8.encode(body));
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode != 200) {
      throw HttpException('HTTP ${response.statusCode}');
    }

    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final content =
        data['choices']?[0]?['message']?['content'] as String? ?? '';
    final json = _extractJson(content);
    return (json as List).first as String;
  } finally {
    client.close();
  }
}

dynamic _extractJson(String content) {
  String cleaned = content.trim();
  if (cleaned.startsWith('```json')) {
    cleaned = cleaned.substring(7);
  } else if (cleaned.startsWith('```')) {
    cleaned = cleaned.substring(3);
  }
  if (cleaned.endsWith('```')) {
    cleaned = cleaned.substring(0, cleaned.length - 3);
  }
  cleaned = cleaned.trim();
  return jsonDecode(cleaned);
}

(String baseUrl, String model) _providerConfig(String provider) {
  switch (provider) {
    case 'openai':
      return ('https://api.openai.com', 'gpt-4o-mini');
    case 'deepseek':
      return ('https://api.deepseek.com', 'deepseek-chat');
    case 'kimi':
      return ('https://api.moonshot.cn', 'moonshot-v1-8k');
    case 'glm':
      return ('https://open.bigmodel.cn/api/paas/v4', 'glm-4-flash');
    default:
      throw ArgumentError('Unknown provider: $provider. Use openai, deepseek, kimi, or glm.');
  }
}

class _WordEntry {
  final String english;
  final String chinese;
  const _WordEntry(this.english, this.chinese);
}
