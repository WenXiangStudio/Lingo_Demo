class NarrationTargetAlternative {
  const NarrationTargetAlternative({
    required this.text,
    required this.difference,
  });

  final String text;
  final String difference;

  factory NarrationTargetAlternative.fromJson(Map<String, dynamic> json) {
    return NarrationTargetAlternative(
      text: _string(json['text']),
      difference: _string(json['difference']),
    );
  }

  Map<String, dynamic> toJson() => {'text': text, 'difference': difference};
}

class NarrationTargetDraft {
  const NarrationTargetDraft({
    required this.recommended,
    this.alternatives = const [],
    this.conflictDetected = false,
    this.conflictMessage = '',
    this.needsUserConfirmation = false,
  });

  final String recommended;
  final List<NarrationTargetAlternative> alternatives;
  final bool conflictDetected;
  final String conflictMessage;
  final bool needsUserConfirmation;

  bool get hasChineseExplanations => _allChineseExplanations([
    for (final item in alternatives) item.difference,
    conflictMessage,
  ]);

  factory NarrationTargetDraft.fromJson(Map<String, dynamic> json) {
    return NarrationTargetDraft(
      recommended: _string(json['recommended']),
      alternatives: _maps(json['alternatives'])
          .map(NarrationTargetAlternative.fromJson)
          .where((item) => item.text.isNotEmpty)
          .take(2)
          .toList(growable: false),
      conflictDetected: _boolean(json['conflict_detected']),
      conflictMessage: _string(json['conflict_message']),
      needsUserConfirmation: _boolean(json['needs_user_confirmation']),
    );
  }

  Map<String, dynamic> toJson() => {
    'recommended': recommended,
    'alternatives': alternatives.map((item) => item.toJson()).toList(),
    'conflict_detected': conflictDetected,
    'conflict_message': conflictMessage,
    'needs_user_confirmation': needsUserConfirmation,
  };
}

class NarrationDifference {
  const NarrationDifference({
    required this.original,
    required this.corrected,
    required this.type,
    required this.reason,
  });

  final String original;
  final String corrected;
  final String type;
  final String reason;

  factory NarrationDifference.fromJson(Map<String, dynamic> json) {
    return NarrationDifference(
      original: _string(json['original']),
      corrected: _string(json['corrected']),
      type: _enumValue(json['type'], const {
        'chinese_substitute',
        'grammar',
        'addition',
        'deletion',
        'naturalness',
      }, 'grammar'),
      reason: _string(json['reason']),
    );
  }

  Map<String, dynamic> toJson() => {
    'original': original,
    'corrected': corrected,
    'type': type,
    'reason': reason,
  };
}

class NarrationSentencePair {
  const NarrationSentencePair({
    required this.original,
    required this.corrected,
    this.differences = const [],
  });

  final String original;
  final String corrected;
  final List<NarrationDifference> differences;

  factory NarrationSentencePair.fromJson(Map<String, dynamic> json) {
    return NarrationSentencePair(
      original: _string(json['original']),
      corrected: _string(json['corrected']),
      differences: _maps(
        json['differences'],
      ).map(NarrationDifference.fromJson).toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
    'original': original,
    'corrected': corrected,
    'differences': differences.map((item) => item.toJson()).toList(),
  };
}

class NarrationErrorItem {
  const NarrationErrorItem({
    required this.grade,
    required this.original,
    required this.issue,
    required this.correction,
    required this.reason,
    this.sentenceIndex,
  });

  final String grade;
  final String original;
  final String issue;
  final String correction;
  final String reason;
  final int? sentenceIndex;

  factory NarrationErrorItem.fromJson(Map<String, dynamic> json) {
    return NarrationErrorItem(
      grade: _enumValue(json['grade'], const {'A', 'B', 'C'}, 'B'),
      original: _string(json['original']),
      issue: _string(json['issue']),
      correction: _string(json['correction']),
      reason: _string(json['reason']),
      sentenceIndex: _nullableInt(json['sentence_index']),
    );
  }

  Map<String, dynamic> toJson() => {
    'grade': grade,
    'original': original,
    'issue': issue,
    'correction': correction,
    'reason': reason,
    if (sentenceIndex != null) 'sentence_index': sentenceIndex,
  };
}

class NarrationCollectedWord {
  const NarrationCollectedWord({
    required this.stableKey,
    required this.chinese,
    required this.english,
    required this.partOfSpeech,
    required this.category,
    this.note = '',
  });

  final String stableKey;
  final String chinese;
  final String english;
  final String partOfSpeech;
  final String category;
  final String note;

  factory NarrationCollectedWord.fromJson(Map<String, dynamic> json) {
    final english = _string(json['english']);
    return NarrationCollectedWord(
      stableKey: _normaliseKey(_string(json['stable_key']), fallback: english),
      chinese: _string(json['chinese']),
      english: english,
      partOfSpeech: _string(json['part_of_speech']),
      category: _enumValue(json['category'], const {
        'word',
        'phrase',
        'function_word',
        'proper_noun',
        'number',
        'time',
      }, 'word'),
      note: _string(json['note']),
    );
  }

  Map<String, dynamic> toJson() => {
    'stable_key': stableKey,
    'chinese': chinese,
    'english': english,
    'part_of_speech': partOfSpeech,
    'category': category,
    'note': note,
  };
}

class NarrationKnowledgePoint {
  const NarrationKnowledgePoint({
    required this.stableKey,
    required this.title,
    required this.explanation,
    required this.level,
    required this.source,
    required this.reviewRequired,
    this.errorGrade = '',
  });

  final String stableKey;
  final String title;
  final String explanation;
  final String level;
  final String source;
  final bool reviewRequired;
  final String errorGrade;

  factory NarrationKnowledgePoint.fromJson(Map<String, dynamic> json) {
    final title = _string(json['title']);
    final level = _enumValue(json['level'], const {
      'core',
      'related',
      'extended',
    }, 'core');
    return NarrationKnowledgePoint(
      stableKey: _normaliseKey(_string(json['stable_key']), fallback: title),
      title: title,
      explanation: _string(json['explanation']),
      level: level,
      source: _enumValue(json['source'], const {
        'error',
        'word',
        'optimisation',
      }, 'error'),
      reviewRequired: json.containsKey('review_required')
          ? _boolean(json['review_required'])
          : level == 'core',
      errorGrade: _string(json['error_grade']).toUpperCase(),
    );
  }

  Map<String, dynamic> toJson() => {
    'stable_key': stableKey,
    'title': title,
    'explanation': explanation,
    'level': level,
    'source': source,
    'review_required': reviewRequired,
    'error_grade': errorGrade,
  };
}

class NarrationSpeechFeature {
  const NarrationSpeechFeature({
    required this.type,
    required this.example,
    required this.note,
  });

  final String type;
  final String example;
  final String note;

  factory NarrationSpeechFeature.fromJson(Map<String, dynamic> json) {
    return NarrationSpeechFeature(
      type: _string(json['type']),
      example: _string(json['example']),
      note: _string(json['note']),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'example': example,
    'note': note,
  };
}

class NarrationVariant {
  const NarrationVariant({required this.text, required this.difference});

  final String text;
  final String difference;

  factory NarrationVariant.fromJson(Map<String, dynamic> json) {
    return NarrationVariant(
      text: _string(json['text']),
      difference: _string(json['difference']),
    );
  }

  Map<String, dynamic> toJson() => {'text': text, 'difference': difference};
}

class NarrationSelfCheckItem {
  const NarrationSelfCheckItem({
    required this.key,
    required this.passed,
    required this.detail,
  });

  final String key;
  final bool passed;
  final String detail;

  factory NarrationSelfCheckItem.fromJson(Map<String, dynamic> json) {
    return NarrationSelfCheckItem(
      key: _enumValue(json['key'], const {
        'semantics',
        'form',
        'naturalness',
        'consistency',
        'style',
      }, 'form'),
      passed: _boolean(json['passed']),
      detail: _string(json['detail']),
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'passed': passed,
    'detail': detail,
  };
}

class NarrationSelfCheckReport {
  const NarrationSelfCheckReport({
    required this.iterations,
    required this.needsUserConfirmation,
    this.checks = const [],
    this.modifications = const [],
    this.uncertainties = const [],
    this.targetDifference = '',
    this.naturalnessBasis = '',
  });

  final int iterations;
  final bool needsUserConfirmation;
  final List<NarrationSelfCheckItem> checks;
  final List<String> modifications;
  final List<String> uncertainties;
  final String targetDifference;
  final String naturalnessBasis;

  factory NarrationSelfCheckReport.fromJson(Map<String, dynamic> json) {
    return NarrationSelfCheckReport(
      iterations: _integer(json['iterations'], fallback: 1).clamp(1, 3),
      needsUserConfirmation: _boolean(json['needs_user_confirmation']),
      checks: _maps(
        json['checks'],
      ).map(NarrationSelfCheckItem.fromJson).toList(growable: false),
      modifications: _strings(json['modifications']),
      uncertainties: _strings(json['uncertainties']),
      targetDifference: _string(json['target_difference']),
      naturalnessBasis: _string(json['naturalness_basis']),
    );
  }

  Map<String, dynamic> toJson() => {
    'iterations': iterations,
    'needs_user_confirmation': needsUserConfirmation,
    'checks': checks.map((item) => item.toJson()).toList(),
    'modifications': modifications,
    'uncertainties': uncertainties,
    'target_difference': targetDifference,
    'naturalness_basis': naturalnessBasis,
  };
}

class NarrationMetrics {
  const NarrationMetrics({
    this.englishWordCount = 0,
    this.sentenceCount = 0,
    this.chineseSubstituteCount = 0,
    this.errorACount = 0,
    this.errorBCount = 0,
    this.errorCCount = 0,
    this.complexity = 0,
  });

  final int englishWordCount;
  final int sentenceCount;
  final int chineseSubstituteCount;
  final int errorACount;
  final int errorBCount;
  final int errorCCount;
  final double complexity;

  factory NarrationMetrics.fromJson(Map<String, dynamic> json) {
    return NarrationMetrics(
      englishWordCount: _integer(json['english_word_count']),
      sentenceCount: _integer(json['sentence_count']),
      chineseSubstituteCount: _integer(json['chinese_substitute_count']),
      errorACount: _integer(json['error_a_count']),
      errorBCount: _integer(json['error_b_count']),
      errorCCount: _integer(json['error_c_count']),
      complexity: _double(json['complexity']),
    );
  }

  NarrationMetrics reconcile({
    required String transcript,
    required List<NarrationErrorItem> errors,
    required int collectedWordCount,
  }) {
    final inferredWords = RegExp(
      r"\b[A-Za-z]+(?:['’-][A-Za-z]+)?\b",
    ).allMatches(transcript).length;
    final inferredSentences = transcript
        .split(RegExp(r'[.!?。！？]+'))
        .where((part) => part.trim().isNotEmpty)
        .length;
    int countGrade(String grade) =>
        errors.where((item) => item.grade == grade).length;
    return NarrationMetrics(
      englishWordCount: englishWordCount > 0 ? englishWordCount : inferredWords,
      sentenceCount: sentenceCount > 0 ? sentenceCount : inferredSentences,
      chineseSubstituteCount: chineseSubstituteCount > 0
          ? chineseSubstituteCount
          : collectedWordCount,
      errorACount: countGrade('A'),
      errorBCount: countGrade('B'),
      errorCCount: countGrade('C'),
      complexity: complexity.clamp(0, 100),
    );
  }

  Map<String, dynamic> toJson() => {
    'english_word_count': englishWordCount,
    'sentence_count': sentenceCount,
    'chinese_substitute_count': chineseSubstituteCount,
    'error_a_count': errorACount,
    'error_b_count': errorBCount,
    'error_c_count': errorCCount,
    'complexity': complexity,
  };
}

class NarrationRealUsageEvent {
  const NarrationRealUsageEvent({
    required this.itemType,
    required this.stableKey,
    required this.outcome,
    required this.evidence,
    this.guided = false,
  });

  final String itemType;
  final String stableKey;
  final String outcome;
  final String evidence;
  final bool guided;

  factory NarrationRealUsageEvent.fromJson(Map<String, dynamic> json) {
    return NarrationRealUsageEvent(
      itemType: _enumValue(json['item_type'], const {
        'word',
        'knowledge',
      }, 'word'),
      stableKey: _normaliseKey(_string(json['stable_key'])),
      outcome: _enumValue(json['outcome'], const {
        'success',
        'failure',
      }, 'success'),
      evidence: _string(json['evidence']),
      guided: _boolean(json['guided']),
    );
  }

  Map<String, dynamic> toJson() => {
    'item_type': itemType,
    'stable_key': stableKey,
    'outcome': outcome,
    'evidence': evidence,
    'guided': guided,
  };
}

class NarrationAnalysis {
  const NarrationAnalysis({
    required this.normalizedTranscript,
    required this.correctedExpression,
    required this.selfCheck,
    required this.metrics,
    this.sentencePairs = const [],
    this.errors = const [],
    this.collectedWords = const [],
    this.knowledgePoints = const [],
    this.speechFeatures = const [],
    this.acceptableVariants = const [],
    this.realUsageEvents = const [],
  });

  final String normalizedTranscript;
  final List<NarrationSentencePair> sentencePairs;
  final List<NarrationErrorItem> errors;
  final List<NarrationCollectedWord> collectedWords;
  final List<NarrationKnowledgePoint> knowledgePoints;
  final List<NarrationSpeechFeature> speechFeatures;
  final String correctedExpression;
  final List<NarrationVariant> acceptableVariants;
  final NarrationSelfCheckReport selfCheck;
  final NarrationMetrics metrics;
  final List<NarrationRealUsageEvent> realUsageEvents;

  bool get hasChineseExplanations => _allChineseExplanations([
    for (final pair in sentencePairs)
      for (final difference in pair.differences) difference.reason,
    for (final error in errors) ...[error.issue, error.reason],
    for (final word in collectedWords) ...[word.partOfSpeech, word.note],
    for (final point in knowledgePoints) ...[point.title, point.explanation],
    for (final feature in speechFeatures) ...[feature.type, feature.note],
    for (final variant in acceptableVariants) variant.difference,
    for (final check in selfCheck.checks) check.detail,
    ...selfCheck.modifications,
    ...selfCheck.uncertainties,
    selfCheck.targetDifference,
    selfCheck.naturalnessBasis,
  ]);

  factory NarrationAnalysis.fromJson(Map<String, dynamic> json) {
    final errors = _maps(
      json['errors'],
    ).map(NarrationErrorItem.fromJson).toList(growable: false);
    final words = _maps(json['collected_words'])
        .map(NarrationCollectedWord.fromJson)
        .where((item) => item.english.isNotEmpty && item.chinese.isNotEmpty)
        .toList(growable: false);
    final normalized = _string(json['normalized_transcript']);
    final rawMetrics = NarrationMetrics.fromJson(_map(json['metrics']));
    return NarrationAnalysis(
      normalizedTranscript: normalized,
      sentencePairs: _maps(
        json['sentence_pairs'],
      ).map(NarrationSentencePair.fromJson).toList(growable: false),
      errors: errors,
      collectedWords: words,
      knowledgePoints: _maps(json['knowledge_points'])
          .map(NarrationKnowledgePoint.fromJson)
          .where((item) => item.title.isNotEmpty)
          .toList(growable: false),
      speechFeatures: _maps(
        json['speech_features'],
      ).map(NarrationSpeechFeature.fromJson).toList(growable: false),
      correctedExpression: _string(json['corrected_expression']),
      acceptableVariants: _maps(json['acceptable_variants'])
          .map(NarrationVariant.fromJson)
          .where((item) => item.text.isNotEmpty)
          .take(2)
          .toList(growable: false),
      selfCheck: NarrationSelfCheckReport.fromJson(_map(json['self_check'])),
      metrics: rawMetrics.reconcile(
        transcript: normalized,
        errors: errors,
        collectedWordCount: words.length,
      ),
      realUsageEvents: _maps(json['real_usage_events'])
          .map(NarrationRealUsageEvent.fromJson)
          .where((item) => item.stableKey.isNotEmpty)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
    'normalized_transcript': normalizedTranscript,
    'sentence_pairs': sentencePairs.map((item) => item.toJson()).toList(),
    'errors': errors.map((item) => item.toJson()).toList(),
    'collected_words': collectedWords.map((item) => item.toJson()).toList(),
    'knowledge_points': knowledgePoints.map((item) => item.toJson()).toList(),
    'speech_features': speechFeatures.map((item) => item.toJson()).toList(),
    'corrected_expression': correctedExpression,
    'acceptable_variants': acceptableVariants
        .map((item) => item.toJson())
        .toList(),
    'self_check': selfCheck.toJson(),
    'metrics': metrics.toJson(),
    'real_usage_events': realUsageEvents.map((item) => item.toJson()).toList(),
  };
}

Map<String, dynamic> _map(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

List<Map<String, dynamic>> _maps(Object? value) {
  if (value is! List) return const [];
  return value.whereType<Map>().map(Map<String, dynamic>.from).toList();
}

List<String> _strings(Object? value) {
  if (value is! List) return const [];
  return value
      .map(_string)
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

bool _allChineseExplanations(Iterable<String> values) {
  final nonEmpty = values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty);
  return nonEmpty.every((value) => RegExp(r'[\u3400-\u9fff]').hasMatch(value));
}

String _string(Object? value) => value?.toString().trim() ?? '';

bool _boolean(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return const {'true', 'yes', '1'}.contains(_string(value).toLowerCase());
}

int _integer(Object? value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  return int.tryParse(_string(value)) ?? fallback;
}

int? _nullableInt(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(_string(value));
}

double _double(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(_string(value)) ?? 0;
}

String _enumValue(Object? value, Set<String> allowed, String fallback) {
  final text = _string(value);
  return allowed.contains(text) ? text : fallback;
}

String _normaliseKey(String value, {String fallback = ''}) {
  final source = value.isEmpty ? fallback : value;
  return source
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r"[^a-z0-9\u4e00-\u9fff]+"), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
}
