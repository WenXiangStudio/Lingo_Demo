class Collocation {
  final String english;
  final String chineseTranslation;
  final String collocationType; // e.g. "adjective + noun", "verb + noun"

  const Collocation({
    required this.english,
    required this.chineseTranslation,
    required this.collocationType,
  });

  factory Collocation.fromJson(Map<String, dynamic> json) {
    return Collocation(
      english: json['english'] as String,
      chineseTranslation: json['chinese_translation'] as String,
      collocationType: json['collocation_type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'english': english,
    'chinese_translation': chineseTranslation,
    'collocation_type': collocationType,
  };
}

class AiSentence {
  final String english;
  final String chineseTranslation;
  final String source; // e.g. "example", "dialogue", "phrase"

  const AiSentence({
    required this.english,
    required this.chineseTranslation,
    required this.source,
  });

  factory AiSentence.fromJson(Map<String, dynamic> json) {
    return AiSentence(
      english: json['english'] as String,
      chineseTranslation: json['chinese_translation'] as String,
      source: json['source'] as String? ?? 'example',
    );
  }

  Map<String, dynamic> toJson() => {
    'english': english,
    'chinese_translation': chineseTranslation,
    'source': source,
  };
}

class Dialogue {
  final String title;
  final List<DialogueLine> lines;

  const Dialogue({required this.title, required this.lines});
}

class DialogueLine {
  final String speaker;
  final String english;
  final String chineseTranslation;

  const DialogueLine({
    required this.speaker,
    required this.english,
    required this.chineseTranslation,
  });
}

class WordStory {
  final String title;
  final String english;
  final String chineseTranslation;
  final List<WordStoryAlignment> translationAlignments;

  const WordStory({
    required this.title,
    required this.english,
    required this.chineseTranslation,
    this.translationAlignments = const [],
  });

  factory WordStory.fromJson(Map<String, dynamic> json) {
    return WordStory(
      title: json['title'] as String,
      english: json['english'] as String,
      chineseTranslation: json['chinese_translation'] as String,
      translationAlignments: _parseTranslationAlignments(
        json['translation_alignments'],
      ),
    );
  }

  static List<WordStoryAlignment> _parseTranslationAlignments(Object? raw) {
    if (raw is! List) return const [];

    final alignments = <WordStoryAlignment>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        final alignment = WordStoryAlignment.tryParse(item);
        if (alignment != null) alignments.add(alignment);
      } else if (item is Map) {
        final alignment = WordStoryAlignment.tryParse(
          Map<String, dynamic>.from(item),
        );
        if (alignment != null) alignments.add(alignment);
      }
    }
    return List.unmodifiable(alignments);
  }
}

class WordStoryAlignment {
  final String word;
  final String chineseSpan;

  const WordStoryAlignment({required this.word, required this.chineseSpan});

  static WordStoryAlignment? tryParse(Map<String, dynamic> json) {
    final word = (json['word'] as String? ?? '').trim();
    final chineseSpan = (json['chinese_span'] as String? ?? '').trim();
    if (word.isEmpty || chineseSpan.isEmpty) return null;
    return WordStoryAlignment(word: word, chineseSpan: chineseSpan);
  }
}
