class TextNormalizer {
  TextNormalizer._();

  static String normalizeQuotes(String value) {
    if (value.isEmpty) return value;
    return value
        .replaceAll('\u2018', "'")
        .replaceAll('\u2019', "'")
        .replaceAll('\u201B', "'")
        .replaceAll('\u2032', "'")
        .replaceAll('\uFF07', "'")
        .replaceAll('\u201C', '"')
        .replaceAll('\u201D', '"')
        .replaceAll('\u2033', '"')
        .replaceAll('\uFF02', '"');
  }
}
