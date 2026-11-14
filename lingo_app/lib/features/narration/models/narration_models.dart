import '../../../data/models/narration_ai_models.dart';

enum NarrationTranscriptConfidence {
  high,
  medium,
  low;

  static NarrationTranscriptConfidence fromCode(String value) {
    return values.firstWhere(
      (item) => item.name == value,
      orElse: () => NarrationTranscriptConfidence.medium,
    );
  }
}

enum NarrationSessionStatus {
  transcriptReview,
  translation,
  targetReview,
  analysed,
  confirmed;

  static NarrationSessionStatus fromCode(String value) {
    return values.firstWhere(
      (item) => item.name == value,
      orElse: () => NarrationSessionStatus.transcriptReview,
    );
  }
}

class NarrationUncertainSegment {
  const NarrationUncertainSegment({
    required this.text,
    required this.reason,
    this.resolved = false,
  });

  final String text;
  final String reason;
  final bool resolved;

  factory NarrationUncertainSegment.fromJson(Map<String, dynamic> json) {
    return NarrationUncertainSegment(
      text: json['text']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      resolved: json['resolved'] == true || json['resolved'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'reason': reason,
    'resolved': resolved,
  };
}

class NarrationSession {
  const NarrationSession({
    required this.id,
    required this.status,
    required this.rawTranscript,
    required this.transcriptConfidence,
    required this.translationConfirmed,
    required this.targetConfirmed,
    required this.finalConfirmed,
    required this.audioRetained,
    required this.accent,
    required this.register,
    required this.createdAt,
    required this.updatedAt,
    this.thinkingEnabled = true,
    this.analysisDurationMs,
    this.cleanedTranscript,
    this.uncertainSegments = const [],
    this.chineseTranslation,
    this.targetEnglish,
    this.targetAlternatives = const [],
    this.normalizedTranscript,
    this.analysis,
    this.correctedExpression,
    this.finalExpression,
    this.audioPath,
  });

  final int id;
  final NarrationSessionStatus status;
  final String rawTranscript;
  final String? cleanedTranscript;
  final NarrationTranscriptConfidence transcriptConfidence;
  final List<NarrationUncertainSegment> uncertainSegments;
  final String? chineseTranslation;
  final bool translationConfirmed;
  final String? targetEnglish;
  final List<NarrationTargetAlternative> targetAlternatives;
  final bool targetConfirmed;
  final String? normalizedTranscript;
  final NarrationAnalysis? analysis;
  final String? correctedExpression;
  final String? finalExpression;
  final bool finalConfirmed;
  final String? audioPath;
  final bool audioRetained;
  final String accent;
  final String register;

  /// Whether the cloud model was allowed to reason for this session.
  final bool thinkingEnabled;

  /// Wall-clock duration of the analysis call, for before/after comparison.
  final int? analysisDurationMs;
  final DateTime createdAt;
  final DateTime updatedAt;
}

enum NarrationLearningItemType {
  word,
  knowledge;

  static NarrationLearningItemType fromCode(String value) {
    return values.firstWhere(
      (item) => item.name == value,
      orElse: () => NarrationLearningItemType.word,
    );
  }
}

enum NarrationMasteryState {
  newlyAdded('new'),
  reviewing('reviewing'),
  pendingVerification('pending_verification'),
  mastered('mastered'),
  suspectedForgotten('suspected_forgotten'),
  stable('stable'),
  needsRevalidation('needs_revalidation');

  const NarrationMasteryState(this.code);

  final String code;

  static NarrationMasteryState fromCode(String value) {
    return values.firstWhere(
      (item) => item.code == value,
      orElse: () => NarrationMasteryState.newlyAdded,
    );
  }
}

enum NarrationQueueState {
  active,
  lowFrequency,
  sleeping,
  removed;

  String get code => switch (this) {
    NarrationQueueState.lowFrequency => 'low_frequency',
    _ => name,
  };

  static NarrationQueueState fromCode(String value) {
    return switch (value) {
      'low_frequency' => NarrationQueueState.lowFrequency,
      'sleeping' => NarrationQueueState.sleeping,
      'removed' => NarrationQueueState.removed,
      _ => NarrationQueueState.active,
    };
  }
}

class NarrationLearningItem {
  const NarrationLearningItem({
    required this.id,
    required this.type,
    required this.stableKey,
    required this.english,
    required this.chinese,
    required this.partOfSpeech,
    required this.classification,
    required this.knowledgeLevel,
    required this.explanation,
    required this.reviewRequired,
    required this.firstSeenAt,
    required this.lastSeenAt,
    required this.occurrenceCount,
    required this.masteryState,
    required this.reviewPassCount,
    required this.recognitionPassed,
    required this.applicationPassed,
    required this.realUseSuccessCount,
    required this.realUseFailureCount,
    required this.reviewIntervalIndex,
    required this.queueState,
    required this.userConfirmed,
    required this.notes,
    this.nextReviewAt,
    this.lastTriggerAt,
    this.lastFailureAt,
  });

  final int id;
  final NarrationLearningItemType type;
  final String stableKey;
  final String english;
  final String chinese;
  final String partOfSpeech;
  final String classification;
  final String knowledgeLevel;
  final String explanation;
  final bool reviewRequired;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;
  final int occurrenceCount;
  final NarrationMasteryState masteryState;
  final int reviewPassCount;
  final bool recognitionPassed;
  final bool applicationPassed;
  final int realUseSuccessCount;
  final int realUseFailureCount;
  final DateTime? nextReviewAt;
  final int reviewIntervalIndex;
  final DateTime? lastTriggerAt;
  final DateTime? lastFailureAt;
  final NarrationQueueState queueState;
  final bool userConfirmed;
  final String notes;

  String get reviewLayer {
    if (!recognitionPassed) return 'recognition';
    if (!applicationPassed) return 'application';
    return reviewPassCount.isEven ? 'recognition' : 'application';
  }

  Map<String, dynamic> toAiSummary() => {
    'item_type': type.name,
    'stable_key': stableKey,
    'english': english,
    'chinese': chinese,
    'knowledge_level': knowledgeLevel,
    'mastery_state': masteryState.code,
  };
}

class NarrationProgressPoint {
  const NarrationProgressPoint({
    required this.sessionId,
    required this.createdAt,
    required this.errorACount,
    required this.errorBCount,
    required this.errorCCount,
    required this.collectedWordCount,
    required this.coreKnowledgeCount,
    required this.realUseSuccessCount,
    required this.realUseFailureCount,
    required this.englishWordCount,
    required this.sentenceCount,
    required this.chineseSubstituteCount,
    required this.complexity,
  });

  final int sessionId;
  final DateTime createdAt;
  final int errorACount;
  final int errorBCount;
  final int errorCCount;
  final int collectedWordCount;
  final int coreKnowledgeCount;
  final int realUseSuccessCount;
  final int realUseFailureCount;
  final int englishWordCount;
  final int sentenceCount;
  final int chineseSubstituteCount;
  final double complexity;

  int get totalErrors => errorACount + errorBCount + errorCCount;
}

class NarrationDashboardSummary {
  const NarrationDashboardSummary({
    required this.sessionCount,
    required this.wordCount,
    required this.knowledgeCount,
    required this.dueCount,
    required this.masteredCount,
    required this.realUseSuccessCount,
  });

  final int sessionCount;
  final int wordCount;
  final int knowledgeCount;
  final int dueCount;
  final int masteredCount;
  final int realUseSuccessCount;
}
