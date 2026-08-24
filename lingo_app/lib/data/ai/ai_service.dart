import '../repositories/repositories.dart';
import '../models/ai_models.dart';
import 'ai_provider.dart';
import 'adapters/claude_adapter.dart';
import 'adapters/openai_compatible.dart';

class AiService {
  final SettingsRepository _settingsRepo;
  AiProvider? _cached;

  AiService(this._settingsRepo);

  Future<AiProvider> getProvider() async {
    if (_cached != null) return _cached!;

    final type = await _settingsRepo.getAiProvider();
    final apiKey = await _settingsRepo.getAiApiKey();
    final baseUrl = await _settingsRepo.getAiBaseUrl();
    final model = await _settingsRepo.getAiModel();

    if (apiKey == null || apiKey.isEmpty) {
      throw AiException('Please configure your AI API key in Settings.');
    }

    final providerType = AiProviderType.fromString(type ?? 'claude');
    _cached = _UsageTrackingAiProvider(
      _createProvider(providerType, apiKey, baseUrl: baseUrl, model: model),
      _settingsRepo,
    );
    return _cached!;
  }

  AiProvider _createProvider(
    AiProviderType type,
    String apiKey, {
    String? baseUrl,
    String? model,
  }) {
    switch (type) {
      case AiProviderType.claude:
        return ClaudeAdapter(
          apiKey: apiKey,
          baseUrl: (baseUrl != null && baseUrl.isNotEmpty)
              ? baseUrl
              : 'https://api.anthropic.com',
          model: (model != null && model.isNotEmpty)
              ? model
              : 'claude-sonnet-4-6',
        );
      case AiProviderType.openai:
        return OpenAICompatibleAdapter(
          name: 'OpenAI',
          baseUrl: (baseUrl != null && baseUrl.isNotEmpty)
              ? baseUrl
              : 'https://api.openai.com',
          apiKey: apiKey,
          model: (model != null && model.isNotEmpty) ? model : 'gpt-4o',
        );
      case AiProviderType.deepseek:
        return OpenAICompatibleAdapter(
          name: 'DeepSeek',
          baseUrl: (baseUrl != null && baseUrl.isNotEmpty)
              ? baseUrl
              : 'https://api.deepseek.com',
          apiKey: apiKey,
          model: (model != null && model.isNotEmpty) ? model : 'deepseek-chat',
          useJsonObjectForCollocationValidation: true,
        );
      case AiProviderType.kimi:
        return OpenAICompatibleAdapter(
          name: 'Kimi',
          baseUrl: (baseUrl != null && baseUrl.isNotEmpty)
              ? baseUrl
              : 'https://api.moonshot.cn',
          apiKey: apiKey,
          model: (model != null && model.isNotEmpty) ? model : 'moonshot-v1-8k',
        );
      case AiProviderType.glm:
        return OpenAICompatibleAdapter(
          name: 'GLM',
          baseUrl: (baseUrl != null && baseUrl.isNotEmpty)
              ? baseUrl
              : 'https://open.bigmodel.cn/api/paas/v4',
          apiKey: apiKey,
          model: (model != null && model.isNotEmpty) ? model : 'glm-4-flash',
        );
    }
  }

  void clearCache() {
    _cached = null;
  }
}

class _UsageTrackingAiProvider implements AiProvider {
  final AiProvider _inner;
  final SettingsRepository _settingsRepo;

  _UsageTrackingAiProvider(this._inner, this._settingsRepo);

  @override
  String get providerName => _inner.providerName;

  @override
  String get modelName => _inner.modelName;

  @override
  AiUsage? get lastUsage => _inner.lastUsage;

  @override
  Future<List<Collocation>> generateCollocations(
    List<String> words, {
    Map<String, String> targetMeanings = const {},
  }) async {
    final result = await _inner.generateCollocations(
      words,
      targetMeanings: targetMeanings,
    );
    await _recordLastUsage();
    return result;
  }

  @override
  Future<List<CollocationOptionValidation>> validateCollocationOptions(
    List<CollocationOptionRequest> requests,
  ) async {
    final result = await _inner.validateCollocationOptions(requests);
    await _recordLastUsage();
    return result;
  }

  @override
  Future<List<AiSentence>> generateSentences(List<String> words) async {
    final result = await _inner.generateSentences(words);
    await _recordLastUsage();
    return result;
  }

  @override
  Future<FillAnswerEvaluation> evaluateFillAnswer({
    required String sentenceWithBlank,
    required String targetWord,
    required String userAnswer,
  }) async {
    final result = await _inner.evaluateFillAnswer(
      sentenceWithBlank: sentenceWithBlank,
      targetWord: targetWord,
      userAnswer: userAnswer,
    );
    await _recordLastUsage();
    return result;
  }

  @override
  Future<List<AiSentence>> generateIdioms(List<String> words) async {
    final result = await _inner.generateIdioms(words);
    await _recordLastUsage();
    return result;
  }

  @override
  Future<Dialogue> generateDialogue(List<String> words, String scenario) async {
    final result = await _inner.generateDialogue(words, scenario);
    await _recordLastUsage();
    return result;
  }

  @override
  Future<InteractiveDialogueStart> startInteractiveDialogue(
    List<String> words,
    String scenario,
  ) async {
    final result = await _inner.startInteractiveDialogue(words, scenario);
    await _recordLastUsage();
    return result;
  }

  @override
  Future<InteractiveDialogueTurn> continueInteractiveDialogue({
    required List<String> words,
    required String scenario,
    required List<InteractiveDialogueMessage> history,
    required String userReply,
    required List<String> usedWords,
    String? grammarContext,
  }) async {
    final result = await _inner.continueInteractiveDialogue(
      words: words,
      scenario: scenario,
      history: history,
      userReply: userReply,
      usedWords: usedWords,
      grammarContext: grammarContext,
    );
    await _recordLastUsage();
    return result;
  }

  @override
  Future<WordStory> generateWordStory(List<String> words) async {
    final result = await _inner.generateWordStory(words);
    await _recordLastUsage();
    return result;
  }

  @override
  Future<String> generateScenario(String word, String meaning) async {
    final result = await _inner.generateScenario(word, meaning);
    await _recordLastUsage();
    return result;
  }

  Future<void> _recordLastUsage() async {
    final usage = _inner.lastUsage;
    if (usage == null) return;
    await _settingsRepo.recordAiUsage(
      provider: providerName,
      model: modelName,
      inputTokens: usage.inputTokens,
      outputTokens: usage.outputTokens,
    );
  }
}

class AiException implements Exception {
  final String message;
  const AiException(this.message);

  @override
  String toString() => 'AiException: $message';
}
