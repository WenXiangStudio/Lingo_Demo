import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../core/utils/text_normalizer.dart';
import '../../../data/ai/ai_service.dart';
import '../../../data/providers.dart';
import '../../lists/providers/list_provider.dart';
import '../../review_center/providers/review_center_provider.dart';

class ParsedWord {
  final String english;
  final String chineseMeanings;
  final String? pronunciation;
  final String? exampleSentence;
  final String? scenarioExample;
  final String? scenarioTranslation;

  const ParsedWord({
    required this.english,
    required this.chineseMeanings,
    this.pronunciation,
    this.exampleSentence,
    this.scenarioExample,
    this.scenarioTranslation,
  });
}

class ImportState {
  final String? fileName;
  final List<ParsedWord> previewWords;
  final String listName;
  final int listSize;
  final double passThreshold;
  final bool isImporting;
  final String? error;
  final bool showAllPreview;
  final bool genScenarios;
  final int scenariosDone;
  final int scenariosTotal;

  const ImportState({
    this.fileName,
    this.previewWords = const [],
    this.listName = '',
    this.listSize = 30,
    this.passThreshold = AppConstants.defaultPassThreshold,
    this.isImporting = false,
    this.error,
    this.showAllPreview = false,
    this.genScenarios = false,
    this.scenariosDone = 0,
    this.scenariosTotal = 0,
  });

  ImportState copyWith({
    String? fileName,
    List<ParsedWord>? previewWords,
    String? listName,
    int? listSize,
    double? passThreshold,
    bool? isImporting,
    String? error,
    bool? showAllPreview,
    bool? genScenarios,
    int? scenariosDone,
    int? scenariosTotal,
    bool clearFileName = false,
    bool clearError = false,
  }) {
    return ImportState(
      fileName: clearFileName ? null : (fileName ?? this.fileName),
      previewWords: previewWords ?? this.previewWords,
      listName: listName ?? this.listName,
      listSize: listSize ?? this.listSize,
      passThreshold: passThreshold ?? this.passThreshold,
      isImporting: isImporting ?? this.isImporting,
      error: clearError ? null : (error ?? this.error),
      showAllPreview: showAllPreview ?? this.showAllPreview,
      genScenarios: genScenarios ?? this.genScenarios,
      scenariosDone: scenariosDone ?? this.scenariosDone,
      scenariosTotal: scenariosTotal ?? this.scenariosTotal,
    );
  }

  int get wordCount => previewWords.length;
  int get listCount => (wordCount / listSize).ceil();
  List<ParsedWord> get displayedWords =>
      showAllPreview ? previewWords : previewWords.take(10).toList();
}

final importStateProvider = StateNotifierProvider<ImportNotifier, ImportState>((
  ref,
) {
  return ImportNotifier(ref);
});

class ImportNotifier extends StateNotifier<ImportState> {
  final Ref _ref;

  ImportNotifier(this._ref) : super(const ImportState());

  void updateListName(String name) {
    state = state.copyWith(listName: name);
  }

  void updatePassThreshold(double value) {
    state = state.copyWith(passThreshold: value);
  }

  void updateListSize(int value) {
    state = state.copyWith(listSize: value);
  }

  void toggleShowAllPreview() {
    state = state.copyWith(showAllPreview: !state.showAllPreview);
  }

  void toggleGenScenarios() {
    state = state.copyWith(genScenarios: !state.genScenarios);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> loadBuiltInBook(String assetPath, String name) async {
    try {
      final content = await rootBundle.loadString(assetPath);
      if (content.trim().isEmpty) {
        state = state.copyWith(error: 'Built-in word book is empty.');
        return;
      }

      final words = _parseCsv(content);
      if (words.isEmpty) {
        state = state.copyWith(error: 'No valid words found in $name.');
        return;
      }

      state = state.copyWith(
        fileName: name,
        previewWords: words,
        listName: name,
        showAllPreview: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to load $name: $e');
    }
  }

  Future<void> pickAndParseFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'json'],
        withData: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final filePath = file.path;
      if (filePath == null) {
        state = state.copyWith(error: 'Could not access file path.');
        return;
      }

      final fileName = file.name;
      final ext = fileName.split('.').last.toLowerCase();

      final content = await File(filePath).readAsString();
      if (content.trim().isEmpty) {
        state = state.copyWith(error: 'File is empty.');
        return;
      }

      List<ParsedWord> words;
      if (ext == 'csv') {
        words = _parseCsv(content);
      } else if (ext == 'json') {
        words = _parseJson(content);
      } else {
        state = state.copyWith(error: 'Unsupported file type: $ext');
        return;
      }

      if (words.isEmpty) {
        state = state.copyWith(error: 'No valid words found in file.');
        return;
      }

      final baseName = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
      state = state.copyWith(
        fileName: fileName,
        previewWords: words,
        listName: baseName,
        showAllPreview: false,
        clearError: true,
      );
    } on FormatException catch (e) {
      state = state.copyWith(error: 'Parse error: ${e.message}');
    } catch (e) {
      state = state.copyWith(error: 'Failed to read file: $e');
    }
  }

  List<ParsedWord> _parseCsv(String content) {
    // Normalize line endings — some files use \n, others \r\n.
    final normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final rows = const CsvToListConverter(eol: '\n').convert(normalized);
    if (rows.isEmpty) return [];

    final header = rows.first
        .map((c) => c.toString().trim().toLowerCase())
        .toList();
    final englishIdx = header.indexOf('english');
    final chineseIdx = header.indexOf('chinese_meanings');
    final pronunciationIdx = header.indexOf('pronunciation');
    final exampleIdx = header.indexOf('example_sentence');
    final scenarioIdx = header.indexOf('scenario_example');
    final scenarioTranslationIdx = header.indexOf('scenario_translation');

    if (englishIdx == -1 || chineseIdx == -1) {
      throw FormatException(
        'CSV must have "english" and "chinese_meanings" columns.',
      );
    }

    final words = <ParsedWord>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length <= englishIdx || row.length <= chineseIdx) continue;
      final english = row[englishIdx].toString().trim();
      final chinese = row[chineseIdx].toString().trim();
      if (english.isEmpty || chinese.isEmpty) continue;
      words.add(
        ParsedWord(
          english: TextNormalizer.normalizeQuotes(english),
          chineseMeanings: TextNormalizer.normalizeQuotes(chinese),
          pronunciation: pronunciationIdx >= 0 && row.length > pronunciationIdx
              ? TextNormalizer.normalizeQuotes(
                  row[pronunciationIdx].toString().trim(),
                )
              : null,
          exampleSentence: exampleIdx >= 0 && row.length > exampleIdx
              ? TextNormalizer.normalizeQuotes(
                  row[exampleIdx].toString().trim(),
                )
              : null,
          scenarioExample: scenarioIdx >= 0 && row.length > scenarioIdx
              ? TextNormalizer.normalizeQuotes(
                  row[scenarioIdx].toString().trim(),
                )
              : null,
          scenarioTranslation:
              scenarioTranslationIdx >= 0 && row.length > scenarioTranslationIdx
              ? TextNormalizer.normalizeQuotes(
                  row[scenarioTranslationIdx].toString().trim(),
                )
              : null,
        ),
      );
    }
    return words;
  }

  List<ParsedWord> _parseJson(String content) {
    final decoded = json.decode(content);
    if (decoded is! List) {
      throw const FormatException('JSON must be an array of word objects.');
    }

    final words = <ParsedWord>[];
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) continue;
      final english = item['english']?.toString().trim() ?? '';
      final chinese = item['chinese_meanings']?.toString().trim() ?? '';
      if (english.isEmpty || chinese.isEmpty) continue;
      final pronunciation = item['pronunciation']?.toString().trim();
      final exampleSentence = item['example_sentence']?.toString().trim();
      final scenarioExample = item['scenario_example']?.toString().trim();
      final scenarioTranslation = item['scenario_translation']
          ?.toString()
          .trim();
      words.add(
        ParsedWord(
          english: TextNormalizer.normalizeQuotes(english),
          chineseMeanings: TextNormalizer.normalizeQuotes(chinese),
          pronunciation: pronunciation == null
              ? null
              : TextNormalizer.normalizeQuotes(pronunciation),
          exampleSentence: exampleSentence == null
              ? null
              : TextNormalizer.normalizeQuotes(exampleSentence),
          scenarioExample: scenarioExample == null
              ? null
              : TextNormalizer.normalizeQuotes(scenarioExample),
          scenarioTranslation: scenarioTranslation == null
              ? null
              : TextNormalizer.normalizeQuotes(scenarioTranslation),
        ),
      );
    }
    return words;
  }

  Future<bool> executeImport() async {
    if (state.previewWords.isEmpty) return false;
    final listName = state.listName.trim();
    if (listName.isEmpty) {
      state = state.copyWith(error: 'Please enter a list name.');
      return false;
    }

    state = state.copyWith(isImporting: true, clearError: true);

    try {
      final wordRepo = _ref.read(wordRepositoryProvider);
      final listRepo = _ref.read(wordListRepositoryProvider);

      final wordIds = <int>[];
      for (final pw in state.previewWords) {
        final id = await wordRepo.insertWordSimple(
          english: pw.english,
          chineseMeanings: pw.chineseMeanings,
          pronunciation: pw.pronunciation,
          exampleSentence: pw.exampleSentence,
          scenarioExample: pw.scenarioExample,
          scenarioTranslation: pw.scenarioTranslation,
        );
        wordIds.add(id);
      }

      final listSize = state.listSize;
      final totalLists = (wordIds.length / listSize).ceil();

      // Create a word book to group all lists from this import
      final bookId = await listRepo.createBook(listName, wordIds.length);

      for (int i = 0; i < totalLists; i++) {
        final start = i * listSize;
        final end = (start + listSize).clamp(0, wordIds.length);
        final chunk = wordIds.sublist(start, end);
        final name = totalLists > 1
            ? '$listName (${i + 1}/$totalLists)'
            : listName;
        await listRepo.createList(
          name: name,
          wordIds: chunk,
          bookId: bookId,
          passThreshold: state.passThreshold,
        );
      }

      _ref.invalidate(listOverviewProvider);
      _ref.invalidate(reviewBooksProvider);
      _ref.invalidate(reviewCenterDataProvider);

      // Generate scenario examples via AI if requested
      if (state.genScenarios && wordIds.isNotEmpty) {
        await _generateScenarios(wordIds);
      }

      return true;
    } catch (e) {
      state = state.copyWith(isImporting: false, error: 'Import failed: $e');
      return false;
    }
  }

  Future<void> _generateScenarios(List<int> wordIds) async {
    state = state.copyWith(scenariosTotal: wordIds.length, scenariosDone: 0);

    try {
      final aiService = AiService(_ref.read(settingsRepositoryProvider));
      final provider = await aiService.getProvider();
      final wordRepo = _ref.read(wordRepositoryProvider);

      // One word per API call — full isolation, no context pollution
      for (var i = 0; i < wordIds.length; i++) {
        final word = await wordRepo.getWord(wordIds[i]);
        if (word == null) continue;

        try {
          final sentence = await provider.generateScenario(
            word.english,
            word.chineseMeanings,
          );
          if (sentence.isNotEmpty) {
            await wordRepo.updateScenarioExample(word.id, sentence);
          }
        } catch (_) {
          // Single word failure — skip and continue with next word
        }

        if (mounted) {
          state = state.copyWith(scenariosDone: i + 1);
        }
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(error: 'Scenarios: $e');
      }
    }
  }

  void reset() {
    state = const ImportState();
  }
}
