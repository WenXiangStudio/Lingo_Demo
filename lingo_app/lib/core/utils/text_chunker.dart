/// Splits long free-form text into bounded chunks for TTS synthesis.
///
/// Cloud TTS providers have per-request text limits, and very long single
/// requests are slower to first audio. This mirrors the sentence-accumulation
/// approach originally used for Supertonic long-form synthesis: split
/// paragraphs into sentences, then accumulate whole sentences up to a bounded
/// chunk length.
class TextChunker {
  static const int defaultMaxChars = 500;
  static const int defaultMinChars = 100;

  /// Split paragraph-like input into bounded chunks.
  ///
  /// Sentences are kept whole when possible; a sentence longer than
  /// [maxChars] is split at phrase/word boundaries no earlier than
  /// [minChars] into the chunk.
  static List<String> split(
    String text, {
    int maxChars = defaultMaxChars,
    int minChars = defaultMinChars,
  }) {
    if (maxChars < 10) {
      throw ArgumentError.value(maxChars, 'maxChars', 'must be at least 10');
    }

    final normalized = text.trim();
    if (normalized.isEmpty) return const [];

    final chunks = <String>[];
    final paragraphs = normalized
        .split(RegExp(r'\n\s*\n+'))
        .map((p) => p.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((p) => p.isNotEmpty);

    for (final paragraph in paragraphs) {
      var currentChunk = '';
      for (final sentence in splitSentences(paragraph)) {
        if (sentence.length > maxChars) {
          if (currentChunk.isNotEmpty) {
            chunks.add(currentChunk);
            currentChunk = '';
          }
          chunks.addAll(
            _splitOverlongSentence(
              sentence,
              maxChars: maxChars,
              minChars: minChars,
            ),
          );
          continue;
        }

        final candidate = currentChunk.isEmpty
            ? sentence
            : '$currentChunk $sentence';
        if (candidate.length <= maxChars) {
          currentChunk = candidate;
        } else {
          if (currentChunk.isNotEmpty) chunks.add(currentChunk);
          currentChunk = sentence;
        }
      }
      if (currentChunk.isNotEmpty) chunks.add(currentChunk);
    }
    return chunks;
  }

  /// Split [paragraph] into sentences at terminal punctuation, protecting
  /// common abbreviations and single-initial dots from being treated as
  /// sentence boundaries.
  static List<String> splitSentences(String paragraph) {
    final sentences = <String>[];
    var start = 0;
    var i = 0;
    while (i < paragraph.length) {
      final char = paragraph[i];
      final isBoundary = '.!?。!?'.contains(char);
      if (!isBoundary || _isProtectedSentenceDot(paragraph, i)) {
        i++;
        continue;
      }

      final next = i + 1;
      final canSplit =
          next >= paragraph.length || RegExp(r'\s').hasMatch(paragraph[next]);
      if (!canSplit) {
        i++;
        continue;
      }

      final sentence = paragraph.substring(start, next).trim();
      if (sentence.isNotEmpty) sentences.add(sentence);
      start = next;
      while (start < paragraph.length &&
          RegExp(r'\s').hasMatch(paragraph[start])) {
        start++;
      }
      i = start;
    }

    final tail = paragraph.substring(start).trim();
    if (tail.isNotEmpty) sentences.add(tail);
    return sentences;
  }

  static bool _isProtectedSentenceDot(String text, int index) {
    if (text[index] != '.') return false;
    var start = index - 1;
    while (start >= 0 && !RegExp(r'\s').hasMatch(text[start])) {
      start--;
    }
    final token = text.substring(start + 1, index);
    final lower = token.toLowerCase();
    const abbreviations = {
      'mr',
      'mrs',
      'ms',
      'dr',
      'prof',
      'sr',
      'jr',
      'st',
      'vs',
      'etc',
      'e.g',
      'i.e',
      'ph.d',
    };
    return abbreviations.contains(lower) || RegExp(r'^[A-Z]$').hasMatch(token);
  }

  static List<String> _splitOverlongSentence(
    String sentence, {
    required int maxChars,
    required int minChars,
  }) {
    final chunks = <String>[];
    var start = 0;
    while (start < sentence.length) {
      while (start < sentence.length && sentence[start] == ' ') {
        start++;
      }
      if (start >= sentence.length) break;

      var end = (start + maxChars).clamp(0, sentence.length);
      if (end < sentence.length) {
        final phraseBoundary = _lastBoundary(sentence, start, end, ',,::');
        final wordBoundary = sentence.lastIndexOf(' ', end);

        if (phraseBoundary >= start + minChars) {
          end = phraseBoundary;
        } else if (wordBoundary >= start + minChars) {
          end = wordBoundary;
        }
      }

      final chunk = sentence.substring(start, end).trim();
      if (chunk.isNotEmpty) chunks.add(chunk);
      start = end;
    }
    return chunks;
  }

  static int _lastBoundary(
    String text,
    int start,
    int end,
    String boundaryChars,
  ) {
    for (var i = end - 1; i > start; i--) {
      if (boundaryChars.contains(text[i])) return i + 1;
    }
    return -1;
  }
}
