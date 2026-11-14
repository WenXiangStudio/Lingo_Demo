import '../models/ai_models.dart';
import '../models/narration_ai_models.dart';

abstract class AiProvider {
  String get providerName;

  String get modelName;

  AiUsage? get lastUsage;

  Future<List<Collocation>> generateCollocations(
    List<String> words, {
    Map<String, String> targetMeanings = const {},
  });

  /// Selects only safe wrong options from a locally supplied candidate pool.
  /// This is called in batches while content is generated, then cached for
  /// later attempts; it is never called while the learner taps an option.
  Future<List<CollocationOptionValidation>> validateCollocationOptions(
    List<CollocationOptionRequest> requests,
  );

  Future<List<AiSentence>> generateSentences(List<String> words);

  /// Checks a non-exact free-text cloze answer. Exact target-word matches are
  /// handled locally and do not invoke this method.
  Future<FillAnswerEvaluation> evaluateFillAnswer({
    required String sentenceWithBlank,
    required String targetWord,
    required String userAnswer,
  });

  /// Generate idioms or proverbs (俗语谚语) that incorporate the given words.
  /// Returns the same shape as sentences — English content + Chinese.
  Future<List<AiSentence>> generateIdioms(List<String> words);

  Future<Dialogue> generateDialogue(List<String> words, String scenario);

  Future<InteractiveDialogueStart> startInteractiveDialogue(
    List<String> words,
    String scenario,
  );

  Future<InteractiveDialogueTurn> continueInteractiveDialogue({
    required List<String> words,
    required String scenario,
    required List<InteractiveDialogueMessage> history,
    required String userReply,
    required List<String> usedWords,
    String? grammarContext,
  });

  Future<WordStory> generateWordStory(List<String> words);

  /// Generate ONE scenario example sentence for a single word.
  /// Each call is fully isolated — no context leaks between words.
  Future<String> generateScenario(String word, String meaning);

  Future<NarrationTargetDraft> generateNarrationTarget({
    required String transcript,
    required String chineseTranslation,
    required String accent,
    required String register,
    bool? thinkingEnabled,
  });

  Future<NarrationAnalysis> analyseNarration({
    required String rawTranscript,
    required String cleanedTranscript,
    required String chineseTranslation,
    required String targetEnglish,
    required String accent,
    required String register,
    required List<Map<String, dynamic>> existingLearningItems,
    bool? thinkingEnabled,
  });
}

class AiUsage {
  final int inputTokens;
  final int outputTokens;

  const AiUsage({required this.inputTokens, required this.outputTokens});

  int get totalTokens => inputTokens + outputTokens;
}

/// Thrown when the provider stopped generating because the output token budget
/// ran out. Reasoning tokens are billed against the same budget, so a reasoning
/// model can exhaust it before any JSON is produced.
class AiOutputTruncatedException implements Exception {
  const AiOutputTruncatedException({this.outputTokens});

  /// Reported completion tokens, when the provider returned usage data.
  final int? outputTokens;

  @override
  String toString() =>
      'AiOutputTruncatedException: AI output stopped at the token limit'
      '${outputTokens == null ? '' : ' ($outputTokens tokens)'}';
}

/// The types of AI providers supported.
enum AiProviderType {
  claude,
  openai,
  deepseek,
  kimi,
  glm;

  String get displayName {
    switch (this) {
      case AiProviderType.claude:
        return 'Claude (Anthropic)';
      case AiProviderType.openai:
        return 'GPT (OpenAI)';
      case AiProviderType.deepseek:
        return 'DeepSeek';
      case AiProviderType.kimi:
        return 'Kimi (Moonshot)';
      case AiProviderType.glm:
        return 'GLM (Zhipu)';
    }
  }

  static AiProviderType fromString(String s) {
    return AiProviderType.values.firstWhere(
      (t) => t.name == s,
      orElse: () => AiProviderType.claude,
    );
  }
}
