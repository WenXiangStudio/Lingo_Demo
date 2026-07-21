class Collocation {
  /// The target word returned by the model for this collocation.
  ///
  /// Older cached entries do not contain it, so callers must still tolerate an
  /// empty value and fall back to matching the English phrase.
  final String sourceWord;
  final String english;
  final String chineseTranslation;
  final String collocationType; // e.g. "adjective + noun", "verb + noun"

  const Collocation({
    this.sourceWord = '',
    required this.english,
    required this.chineseTranslation,
    required this.collocationType,
  });

  factory Collocation.fromJson(Map<String, dynamic> json) {
    return Collocation(
      sourceWord: (json['word'] ?? json['source_word'] ?? '') as String,
      english: json['english'] as String,
      chineseTranslation: json['chinese_translation'] as String,
      collocationType: json['collocation_type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    if (sourceWord.isNotEmpty) 'word': sourceWord,
    'english': english,
    'chinese_translation': chineseTranslation,
    'collocation_type': collocationType,
  };
}

class AiSentence {
  /// The target word returned by the model for this example.
  final String sourceWord;
  final String english;
  final String chineseTranslation;
  final String source; // e.g. "example", "dialogue", "phrase"

  const AiSentence({
    this.sourceWord = '',
    required this.english,
    required this.chineseTranslation,
    required this.source,
  });

  factory AiSentence.fromJson(Map<String, dynamic> json) {
    return AiSentence(
      sourceWord: (json['word'] ?? json['source_word'] ?? '') as String,
      english: json['english'] as String,
      chineseTranslation: json['chinese_translation'] as String,
      source: json['source'] as String? ?? 'example',
    );
  }

  Map<String, dynamic> toJson() => {
    if (sourceWord.isNotEmpty) 'word': sourceWord,
    'english': english,
    'chinese_translation': chineseTranslation,
    'source': source,
  };
}

/// A bounded, batchable request for safe multiple-choice distractors.
///
/// Candidate words are selected locally from the permitted word-book pools.
/// The AI may only approve words from that list, so it cannot silently add an
/// unrelated target word to the question.
class CollocationOptionRequest {
  final int wordId;
  final String targetWord;
  final String collocation;
  final String displayText;
  final List<String> candidateWords;

  const CollocationOptionRequest({
    required this.wordId,
    required this.targetWord,
    required this.collocation,
    required this.displayText,
    required this.candidateWords,
  });

  Map<String, dynamic> toPromptJson() => {
    'word_id': wordId,
    'target_word': targetWord,
    'collocation': collocation,
    'blanked_collocation': displayText,
    'candidate_words': candidateWords,
  };
}

class CollocationOptionValidation {
  final int wordId;
  final List<String> distractors;

  const CollocationOptionValidation({
    required this.wordId,
    this.distractors = const [],
  });

  factory CollocationOptionValidation.fromJson(Map<String, dynamic> json) {
    final rawId = json['word_id'];
    return CollocationOptionValidation(
      wordId: rawId is num ? rawId.toInt() : int.tryParse('$rawId') ?? -1,
      distractors: _stringList(json['distractors']),
    );
  }
}

/// Result of checking a non-exact free-text cloze answer.
///
/// An acceptable alternative is linguistically valid, but it does not prove
/// that the learner recalled the target word for this exercise.
class FillAnswerEvaluation {
  final bool isAcceptableAlternative;
  final String feedback;

  const FillAnswerEvaluation({
    required this.isAcceptableAlternative,
    this.feedback = '',
  });

  factory FillAnswerEvaluation.fromJson(Map<String, dynamic> json) {
    return FillAnswerEvaluation(
      isAcceptableAlternative:
          json['is_acceptable_alternative'] == true ||
          json['classification'] == 'acceptable_alternative',
      feedback: json['feedback'] as String? ?? '',
    );
  }
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

class InteractiveDialogueStart {
  final String title;
  final String aiRole;
  final String userRole;
  final String openingLine;
  final String openingTranslation;
  final List<String> suggestedTargetWords;

  const InteractiveDialogueStart({
    required this.title,
    required this.aiRole,
    required this.userRole,
    required this.openingLine,
    required this.openingTranslation,
    this.suggestedTargetWords = const [],
  });

  factory InteractiveDialogueStart.fromJson(Map<String, dynamic> json) {
    return InteractiveDialogueStart(
      title: json['title'] as String? ?? '',
      aiRole: json['ai_role'] as String? ?? 'AI',
      userRole: json['user_role'] as String? ?? 'You',
      openingLine: json['opening_line'] as String? ?? '',
      openingTranslation: json['opening_translation'] as String? ?? '',
      suggestedTargetWords: _stringList(json['suggested_target_words']),
    );
  }
}

class InteractiveDialogueMessage {
  final String speaker;
  final String english;
  final String chineseTranslation;
  final bool isUser;

  const InteractiveDialogueMessage({
    required this.speaker,
    required this.english,
    required this.chineseTranslation,
    required this.isUser,
  });

  Map<String, dynamic> toPromptJson() => {
    'speaker': speaker,
    'role': isUser ? 'user' : 'ai',
    'english': english,
  };
}

class InteractiveDialogueTurn {
  final String aiReply;
  final String aiTranslation;
  final String userTranslation;
  final InteractiveDialogueFeedback feedback;

  const InteractiveDialogueTurn({
    required this.aiReply,
    required this.aiTranslation,
    required this.userTranslation,
    required this.feedback,
  });

  factory InteractiveDialogueTurn.fromJson(Map<String, dynamic> json) {
    return InteractiveDialogueTurn(
      aiReply: json['ai_reply'] as String? ?? '',
      aiTranslation: json['ai_translation'] as String? ?? '',
      userTranslation: json['user_translation'] as String? ?? '',
      feedback: InteractiveDialogueFeedback.fromJson(
        (json['feedback'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      ),
    );
  }
}

class InteractiveDialogueFeedback {
  final List<String> usedWords;
  final List<String> missedOpportunityWords;
  final List<String> nextTargetWords;
  final int naturalnessScore;
  final int contextFitScore;
  final String correction;
  final String betterVersion;
  final String chineseExplanation;

  const InteractiveDialogueFeedback({
    this.usedWords = const [],
    this.missedOpportunityWords = const [],
    this.nextTargetWords = const [],
    this.naturalnessScore = 0,
    this.contextFitScore = 0,
    this.correction = '',
    this.betterVersion = '',
    this.chineseExplanation = '',
  });

  factory InteractiveDialogueFeedback.fromJson(Map<String, dynamic> json) {
    return InteractiveDialogueFeedback(
      usedWords: _stringList(json['used_words']),
      missedOpportunityWords: _stringList(json['missed_opportunity_words']),
      nextTargetWords: _stringList(json['next_target_words']),
      naturalnessScore: _intInRange(json['naturalness_score'], min: 0, max: 5),
      contextFitScore: _intInRange(json['context_fit_score'], min: 0, max: 5),
      correction: json['correction'] as String? ?? '',
      betterVersion: json['better_version'] as String? ?? '',
      chineseExplanation: json['chinese_explanation'] as String? ?? '',
    );
  }
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

List<String> _stringList(Object? raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<String>()
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
}

int _intInRange(Object? raw, {required int min, required int max}) {
  final value = raw is num ? raw.toInt() : min;
  if (value < min) return min;
  if (value > max) return max;
  return value;
}
