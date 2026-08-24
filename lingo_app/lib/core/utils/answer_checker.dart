import 'text_normalizer.dart';

class AnswerChecker {
  AnswerChecker._();

  static final RegExp _meaningPrefixPattern = RegExp(
    r'^(?:[a-z]+(?:&[a-z]+)*\.?[\s·,，、:：/-]*)+',
    caseSensitive: false,
  );
  static final RegExp _regionalMeaningPrefixPattern = RegExp(
    r'^(?:(?:\(|（|\[|【)\s*(?:英|美)\s*(?:\)|）|\]|】)\s*)+',
  );

  static String normalizeMeaningKey(String value) {
    final normalized = TextNormalizer.normalizeQuotes(
      value,
    ).replaceAll('；', ';').replaceAll(RegExp(r'\s+'), '').trim().toLowerCase();
    return _stripMeaningPrefix(normalized);
  }

  static String _stripMeaningPrefix(String value) {
    var result = value;
    while (true) {
      final regionalMatch = _regionalMeaningPrefixPattern.firstMatch(result);
      if (regionalMatch != null && regionalMatch.end > 0) {
        final stripped = result.substring(regionalMatch.end);
        if (stripped.isNotEmpty && _looksLikeMeaningText(stripped)) {
          result = stripped;
          continue;
        }
      }

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

  /// Parse stored Chinese meanings into independently acceptable meanings.
  /// e.g. "停止，放弃；离开，辞" → ["停止", "放弃", "离开", "辞"]
  static List<String> parseMeanings(String chineseMeanings) {
    return _splitMeaningParts(chineseMeanings);
  }

  /// Parse a learner's fill-in answer using the same separators as stored
  /// meanings. Each part must be an independently acceptable meaning.
  static List<String> parseFillAnswerParts(String userInput) {
    return _splitMeaningParts(userInput);
  }

  static List<String> _splitMeaningParts(String value) {
    return TextNormalizer.normalizeQuotes(value)
        .split(RegExp(r'[；;，,]'))
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
  /// A single correct Chinese meaning passes. When the learner enters several
  /// meanings separated by commas or semicolons, every entered meaning must be
  /// one of the stored meanings; ordering does not matter.
  static bool isFillAnswerCorrect(String userInput, String correctMeanings) {
    final answerParts = parseFillAnswerParts(userInput);
    if (answerParts.isEmpty) return false;

    final accepted = parseMeanings(
      correctMeanings,
    ).map(normalizeMeaningKey).where((meaning) => meaning.isNotEmpty).toSet();
    return answerParts.every(
      (part) => accepted.contains(normalizeMeaningKey(part)),
    );
  }

  /// Return the learner-entered fill-in parts that do not match a stored
  /// meaning. The UI uses these values to identify precisely what was wrong.
  static List<String> invalidFillAnswerParts(
    String userInput,
    String correctMeanings,
  ) {
    final accepted = parseMeanings(
      correctMeanings,
    ).map(normalizeMeaningKey).where((meaning) => meaning.isNotEmpty).toSet();
    return parseFillAnswerParts(
      userInput,
    ).where((part) => !accepted.contains(normalizeMeaningKey(part))).toList();
  }

  /// Compare whole answer strings after normalization.
  /// Use this for choice-style options where the displayed option text should
  /// match the stored answer as a complete unit.
  static bool isChoiceAnswerCorrect(
    String selectedOption,
    String correctAnswer,
  ) {
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
    final entered = parseFillAnswerParts(
      userInput,
    ).map(normalizeMeaningKey).where((meaning) => meaning.isNotEmpty).toSet();

    return meanings.where((m) {
      final normalizedMeaning = normalizeMeaningKey(m);
      return !entered.contains(normalizedMeaning);
    }).toList();
  }
}
