import 'text_normalizer.dart';

class AnswerChecker {
  AnswerChecker._();

  static final RegExp _meaningPrefixPattern = RegExp(
    r'^(?:[a-z]+(?:&[a-z]+)*\.?[\s·,，、:：/-]*)+',
    caseSensitive: false,
  );

  static String normalizeMeaningKey(String value) {
    final normalized = TextNormalizer.normalizeQuotes(value)
        .replaceAll('；', ';')
        .replaceAll(RegExp(r'\s+'), '')
        .trim()
        .toLowerCase();
    return _stripMeaningPrefix(normalized);
  }

  static String _stripMeaningPrefix(String value) {
    var result = value;
    while (true) {
      final match = _meaningPrefixPattern.firstMatch(result);
      if (match == null || match.end == 0) break;
      final stripped = result.substring(match.end);
      if (stripped.isEmpty || !_looksLikeMeaningText(stripped)) break;
      result = stripped;
    }
    return result;
  }

  static bool _looksLikeMeaningText(String value) {
    if (value.isEmpty) return false;
    return value.runes.first > 0x7f;
  }

  /// Parse stored Chinese meanings into a list of individual meanings.
  /// e.g. "n.苹果；v.挑选" → ["n.苹果", "v.挑选"]
  static List<String> parseMeanings(String chineseMeanings) {
    return TextNormalizer.normalizeQuotes(chineseMeanings)
        .split(RegExp(r'[；;]'))
        .map((m) => m.trim())
        .where((m) => m.isNotEmpty)
        .toList();
  }

  /// Check if user input matches any acceptable meaning.
  /// The input is trimmed and compared case-insensitively.
  /// Any ONE meaning match → correct.
  static bool isAnswerCorrect(String userInput, String correctMeanings) {
    final meanings = parseMeanings(correctMeanings);
    final normalized = normalizeMeaningKey(userInput);
    if (normalized.isEmpty) return false;

    return meanings.any((meaning) {
      return normalizeMeaningKey(meaning) == normalized;
    });
  }

  /// Shared fill-in grading rule.
  /// Any single correct Chinese meaning should count as correct.
  static bool isFillAnswerCorrect(String userInput, String correctMeanings) {
    return isAnswerCorrect(userInput, correctMeanings);
  }

  /// Compare whole answer strings after normalization.
  /// Use this for choice-style options where the displayed option text should
  /// match the stored answer as a complete unit.
  static bool isChoiceAnswerCorrect(String selectedOption, String correctAnswer) {
    final selected = normalizeMeaningKey(selectedOption);
    if (selected.isEmpty) return false;
    return selected == normalizeMeaningKey(correctAnswer);
  }

  /// Find which meanings the user did NOT type (for fill-in-the-blank feedback).
  static List<String> missingMeanings(
    String userInput,
    String correctMeanings,
  ) {
    final meanings = parseMeanings(correctMeanings);
    final normalized = normalizeMeaningKey(userInput);

    return meanings.where((m) {
      final normalizedMeaning = normalizeMeaningKey(m);
      return normalizedMeaning != normalized &&
          !normalized.contains(normalizedMeaning);
    }).toList();
  }
}
