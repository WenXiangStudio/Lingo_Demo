import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuiltInWordBook {
  final String nameKey;
  final String assetPath;
  final int wordCount;

  const BuiltInWordBook({
    required this.nameKey,
    required this.assetPath,
    required this.wordCount,
  });
}

final builtInWordBooksProvider = FutureProvider<List<BuiltInWordBook>>((
  ref,
) async {
  const defs = [
    ('book_cet4', 'assets/word_books/CET4.csv'),
    ('book_cet6', 'assets/word_books/CET6.csv'),
    ('book_kaoyan', 'assets/word_books/KAOYAN.csv'),
  ];

  final books = <BuiltInWordBook>[];
  for (final (nameKey, assetPath) in defs) {
    try {
      final content = await rootBundle.loadString(assetPath);
      final normalized = content
          .replaceAll('\r\n', '\n')
          .replaceAll('\r', '\n');
      final rows = const CsvToListConverter(eol: '\n').convert(normalized);
      if (rows.isEmpty) continue;

      final header = rows.first
          .map((c) => c.toString().trim().toLowerCase())
          .toList();
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

      books.add(
        BuiltInWordBook(
          nameKey: nameKey,
          assetPath: assetPath,
          wordCount: count,
        ),
      );
    } catch (e) {
      debugPrint('BuiltInBooks: failed to load $nameKey ($assetPath): $e');
    }
  }
  return books;
});
