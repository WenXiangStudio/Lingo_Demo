import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuiltInWordBook {
  final String name;
  final String assetPath;
  final int wordCount;

  const BuiltInWordBook({
    required this.name,
    required this.assetPath,
    required this.wordCount,
  });
}

final builtInWordBooksProvider = FutureProvider<List<BuiltInWordBook>>((ref) async {
  const defs = [
    ('CET-4', 'assets/word_books/CET4.csv'),
    ('CET-6', 'assets/word_books/CET6.csv'),
    ('考研', 'assets/word_books/KAOYAN.csv'),
  ];

  final books = <BuiltInWordBook>[];
  for (final (name, assetPath) in defs) {
    try {
      final content = await rootBundle.loadString(assetPath);
      final normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
      final rows = const CsvToListConverter(eol: '\n').convert(normalized);
      if (rows.isEmpty) continue;

      final header = rows.first.map((c) => c.toString().trim().toLowerCase()).toList();
      final englishIdx = header.indexOf('english');
      final chineseIdx = header.indexOf('chinese_meanings');
      if (englishIdx == -1 || chineseIdx == -1) continue;

      int count = 0;
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length <= englishIdx || row.length <= chineseIdx) continue;
        final english = row[englishIdx].toString().trim();
        final chinese = row[chineseIdx].toString().trim();
        if (english.isNotEmpty && chinese.isNotEmpty) count++;
      }

      books.add(BuiltInWordBook(name: name, assetPath: assetPath, wordCount: count));
    } catch (e) {
      // If one book fails, still try the rest
      print('BuiltInBooks: failed to load $name ($assetPath): $e');
    }
  }
  return books;
});
