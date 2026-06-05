import '../../../data/database/app_database.dart';

enum SpeakingTokenStatus { correct, missing, extra, maybeWrong }

enum SpeakingPhase {
  loading,
  ready,
  recording,
  recognizing,
  feedback,
  finished,
  error,
}

class SpeakingPrompt {
  const SpeakingPrompt({required this.word, required this.referenceText});

  final Word word;
  final String referenceText;
}

class SpeakingTokenResult {
  const SpeakingTokenResult({
    required this.reference,
    required this.spoken,
    required this.status,
  });

  final String reference;
  final String? spoken;
  final SpeakingTokenStatus status;
}

class SpeakingAssessmentResult {
  const SpeakingAssessmentResult({
    required this.referenceText,
    required this.transcript,
    required this.tokens,
    required this.extraWords,
    required this.score,
  });

  final String referenceText;
  final String transcript;
  final List<SpeakingTokenResult> tokens;
  final List<String> extraWords;
  final double score;

  int get correctCount =>
      tokens.where((t) => t.status == SpeakingTokenStatus.correct).length;

  int get targetCount => tokens.length;

  bool get isPassed => score >= 80;
}

class SpeakingState {
  const SpeakingState({
    this.phase = SpeakingPhase.loading,
    this.listId,
    this.prompts = const [],
    this.currentIndex = 0,
    this.results = const [],
    this.currentTranscript = '',
    this.error,
    this.actionError,
    this.currentAudioPath,
  });

  final SpeakingPhase phase;
  final int? listId;
  final List<SpeakingPrompt> prompts;
  final int currentIndex;
  final List<SpeakingAssessmentResult> results;
  final String currentTranscript;
  final String? error;
  final String? actionError;
  final String? currentAudioPath;

  SpeakingPrompt? get currentPrompt =>
      currentIndex < prompts.length ? prompts[currentIndex] : null;

  int get totalQuestions => prompts.length;

  int get answeredCount => results.length;

  double get averageScore {
    if (results.isEmpty) return 0;
    final total = results.fold<double>(0, (sum, r) => sum + r.score);
    return total / results.length;
  }

  SpeakingState copyWith({
    SpeakingPhase? phase,
    int? listId,
    List<SpeakingPrompt>? prompts,
    int? currentIndex,
    List<SpeakingAssessmentResult>? results,
    String? currentTranscript,
    String? error,
    String? actionError,
    String? currentAudioPath,
    bool clearError = false,
    bool clearActionError = false,
    bool clearCurrentAudioPath = false,
  }) {
    return SpeakingState(
      phase: phase ?? this.phase,
      listId: listId ?? this.listId,
      prompts: prompts ?? this.prompts,
      currentIndex: currentIndex ?? this.currentIndex,
      results: results ?? this.results,
      currentTranscript: currentTranscript ?? this.currentTranscript,
      error: clearError ? null : error ?? this.error,
      actionError: clearActionError ? null : actionError ?? this.actionError,
      currentAudioPath: clearCurrentAudioPath
          ? null
          : currentAudioPath ?? this.currentAudioPath,
    );
  }
}
