import 'dart:convert';

import 'package:dio/dio.dart';

import '../ai_provider.dart';
import '../prompts.dart';
import '../../models/ai_models.dart';
import '../../models/narration_ai_models.dart';

class ClaudeAdapter implements AiProvider {
  /// Narration analysis returns a large nested JSON payload, and extended
  /// thinking tokens are drawn from the same budget as the visible answer.
  static const int _narrationTargetMaxTokens = 4096;
  static const int _narrationAnalysisMaxTokens = 16384;

  /// Anthropic model output limits vary, so keep the escalation conservative.
  static const int _maxRetryMaxTokens = 32768;

  /// Long transcripts plus thinking can exceed the default receive timeout.
  static const Duration _narrationReceiveTimeout = Duration(seconds: 300);

  /// Claude does not honour `thinkingEnabled`. Anthropic's extended thinking
  /// requires `temperature == 1`, while these prompts pin 0.2/0.1, so toggling
  /// it would silently change output style instead of isolating one variable.
  /// The narration UI states this limitation.
  final String _model;
  final Dio _dio;
  AiUsage? _lastUsage;

  ClaudeAdapter({
    required String apiKey,
    String baseUrl = 'https://api.anthropic.com',
    String model = 'claude-sonnet-4-6',
    Dio? dio,
  }) : _model = model,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               headers: {
                 'x-api-key': apiKey,
                 'Content-Type': 'application/json',
                 'anthropic-version': '2023-06-01',
               },
               connectTimeout: const Duration(seconds: 30),
               receiveTimeout: const Duration(seconds: 120),
             ),
           );

  @override
  String get providerName => 'Claude';

  @override
  String get modelName => _model;

  @override
  AiUsage? get lastUsage => _lastUsage;

  @override
  Future<List<Collocation>> generateCollocations(
    List<String> words, {
    Map<String, String> targetMeanings = const {},
  }) async {
    final prompt = AiPrompts.collocationsPrompt(
      words,
      targetMeanings: targetMeanings,
    );
    final json = await _callClaude(prompt);
    final results = (json as List).cast<Map<String, dynamic>>();
    final collocations = <Collocation>[];
    for (final entry in results) {
      final sourceWord = entry['word'] as String? ?? '';
      for (final c in (entry['collocations'] as List)) {
        collocations.add(
          Collocation.fromJson({
            ...(c as Map<String, dynamic>),
            'word': sourceWord,
          }),
        );
      }
    }
    return collocations;
  }

  @override
  Future<List<CollocationOptionValidation>> validateCollocationOptions(
    List<CollocationOptionRequest> requests,
  ) async {
    if (requests.isEmpty) return const [];
    final json = await _callClaude(
      AiPrompts.collocationOptionValidationPrompt(requests),
      retryOnInvalidJson: false,
    );
    return (json as List)
        .whereType<Map>()
        .map(
          (item) => CollocationOptionValidation.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<AiSentence>> generateSentences(List<String> words) async {
    final prompt = AiPrompts.sentencesPrompt(words);
    final json = await _callClaude(prompt);
    final results = (json as List).cast<Map<String, dynamic>>();
    final sentences = <AiSentence>[];
    for (final entry in results) {
      final sourceWord = entry['word'] as String? ?? '';
      for (final s in (entry['sentences'] as List)) {
        sentences.add(
          AiSentence.fromJson({
            ...(s as Map<String, dynamic>),
            'word': sourceWord,
          }),
        );
      }
    }
    return sentences;
  }

  @override
  Future<FillAnswerEvaluation> evaluateFillAnswer({
    required String sentenceWithBlank,
    required String targetWord,
    required String userAnswer,
  }) async {
    final json = await _callClaude(
      AiPrompts.fillAnswerEvaluationPrompt(
        sentenceWithBlank: sentenceWithBlank,
        targetWord: targetWord,
        userAnswer: userAnswer,
      ),
    );
    return FillAnswerEvaluation.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<List<AiSentence>> generateIdioms(List<String> words) async {
    final prompt = AiPrompts.idiomsPrompt(words);
    final json = await _callClaude(prompt);
    final results = (json as List).cast<Map<String, dynamic>>();
    final idioms = <AiSentence>[];
    for (final entry in results) {
      final sourceWord = entry['word'] as String? ?? '';
      for (final s in (entry['sentences'] as List)) {
        idioms.add(
          AiSentence.fromJson({
            ...(s as Map<String, dynamic>),
            'word': sourceWord,
          }),
        );
      }
    }
    return idioms;
  }

  @override
  Future<Dialogue> generateDialogue(List<String> words, String scenario) async {
    final prompt = AiPrompts.dialoguePrompt(words, scenario);
    final json = await _callClaude(prompt);
    final map = json as Map<String, dynamic>;
    return Dialogue(
      title: map['title'] as String,
      lines: (map['lines'] as List).map((l) {
        final m = l as Map<String, dynamic>;
        return DialogueLine(
          speaker: m['speaker'] as String,
          english: m['english'] as String,
          chineseTranslation: m['chinese_translation'] as String,
        );
      }).toList(),
    );
  }

  @override
  Future<InteractiveDialogueStart> startInteractiveDialogue(
    List<String> words,
    String scenario,
  ) async {
    final prompt = AiPrompts.interactiveDialogueStartPrompt(words, scenario);
    final json = await _callClaude(prompt);
    return InteractiveDialogueStart.fromJson(json as Map<String, dynamic>);
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
    final prompt = AiPrompts.interactiveDialogueTurnPrompt(
      words: words,
      scenario: scenario,
      history: history.map((message) => message.toPromptJson()).toList(),
      userReply: userReply,
      usedWords: usedWords,
      grammarContext: grammarContext,
    );
    final json = await _callClaude(prompt);
    return InteractiveDialogueTurn.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<WordStory> generateWordStory(List<String> words) async {
    final prompt = AiPrompts.wordStoryPrompt(words);
    final json = await _callClaude(prompt);
    return WordStory.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<String> generateScenario(String word, String meaning) async {
    final prompt = AiPrompts.scenarioPrompt(word, meaning);
    final json = await _callClaude(prompt);
    return (json as List).first as String;
  }

  @override
  Future<NarrationTargetDraft> generateNarrationTarget({
    required String transcript,
    required String chineseTranslation,
    required String accent,
    required String register,
    bool? thinkingEnabled,
  }) async {
    final prompt = AiPrompts.narrationTargetPrompt(
      transcript: transcript,
      chineseTranslation: chineseTranslation,
      accent: accent,
      register: register,
    );
    final json = await _callClaude(
      prompt,
      temperature: 0.2,
      maxTokens: _narrationTargetMaxTokens,
      receiveTimeout: _narrationReceiveTimeout,
    );
    var result = NarrationTargetDraft.fromJson(
      Map<String, dynamic>.from(json as Map),
    );
    if (!result.hasChineseExplanations) {
      final firstUsage = _lastUsage;
      final retryJson = await _callClaude(
        '$prompt\n\nLANGUAGE CORRECTION: Your previous JSON used English explanatory prose. Regenerate the complete JSON. Every explanatory field specified by the mandatory output-language contract must contain Simplified Chinese. Keep only the English expressions and source spans in English.',
        temperature: 0.1,
        maxTokens: _narrationTargetMaxTokens,
        receiveTimeout: _narrationReceiveTimeout,
      );
      _lastUsage = _combineUsage(firstUsage, _lastUsage);
      result = NarrationTargetDraft.fromJson(
        Map<String, dynamic>.from(retryJson as Map),
      );
      if (!result.hasChineseExplanations) {
        throw const FormatException(
          'AI target explanations were not returned in Simplified Chinese.',
        );
      }
    }
    return result;
  }

  @override
  Future<NarrationAnalysis> analyseNarration({
    required String rawTranscript,
    required String cleanedTranscript,
    required String chineseTranslation,
    required String targetEnglish,
    required String accent,
    required String register,
    required List<Map<String, dynamic>> existingLearningItems,
    bool? thinkingEnabled,
  }) async {
    final prompt = AiPrompts.narrationAnalysisPrompt(
      rawTranscript: rawTranscript,
      cleanedTranscript: cleanedTranscript,
      chineseTranslation: chineseTranslation,
      targetEnglish: targetEnglish,
      accent: accent,
      register: register,
      existingLearningItems: existingLearningItems,
    );
    final json = await _callClaude(
      prompt,
      temperature: 0.2,
      maxTokens: _narrationAnalysisMaxTokens,
      receiveTimeout: _narrationReceiveTimeout,
    );
    var result = NarrationAnalysis.fromJson(
      Map<String, dynamic>.from(json as Map),
    );
    if (!result.hasChineseExplanations) {
      final firstUsage = _lastUsage;
      final retryJson = await _callClaude(
        '$prompt\n\nLANGUAGE CORRECTION: Your previous JSON used English explanatory prose. Regenerate the complete JSON. Every explanatory, diagnostic, reason, note, knowledge and self-check field specified by the mandatory output-language contract must contain Simplified Chinese. Keep only English expressions, source spans, stable keys and exact evidence in English.',
        temperature: 0.1,
        maxTokens: _narrationAnalysisMaxTokens,
        receiveTimeout: _narrationReceiveTimeout,
      );
      _lastUsage = _combineUsage(firstUsage, _lastUsage);
      result = NarrationAnalysis.fromJson(
        Map<String, dynamic>.from(retryJson as Map),
      );
      if (!result.hasChineseExplanations) {
        throw const FormatException(
          'AI analysis explanations were not returned in Simplified Chinese.',
        );
      }
    }
    return result;
  }

  Future<dynamic> _callClaude(
    String userPrompt, {
    bool isRetry = false,
    bool retryOnInvalidJson = true,
    double temperature = 0.7,
    int maxTokens = 4096,
    Duration? receiveTimeout,
    bool budgetEscalated = false,
  }) async {
    final response = await _dio.post(
      '/v1/messages',
      data: {
        'model': _model,
        'max_tokens': maxTokens,
        'temperature': temperature,
        'messages': [
          {'role': 'user', 'content': userPrompt},
        ],
      },
      options: receiveTimeout == null
          ? null
          : Options(receiveTimeout: receiveTimeout),
    );
    _lastUsage = _parseUsage(response.data['usage']);
    final usage = _lastUsage;
    final data = response.data;
    final stopReason = data is Map ? data['stop_reason'] : null;
    if (stopReason == 'max_tokens') {
      final grown = maxTokens * 2;
      if (!budgetEscalated && grown <= _maxRetryMaxTokens) {
        // Extended thinking shares the output budget; retry once with more room
        // before giving up on the whole narration flow.
        final result = await _callClaude(
          userPrompt,
          isRetry: isRetry,
          retryOnInvalidJson: retryOnInvalidJson,
          temperature: temperature,
          maxTokens: grown,
          receiveTimeout: receiveTimeout,
          budgetEscalated: true,
        );
        _lastUsage = _combineUsage(usage, _lastUsage);
        return result;
      }
      throw AiOutputTruncatedException(outputTokens: usage?.outputTokens);
    }
    try {
      return _extractJson(_responseText(response.data));
    } on FormatException {
      if (isRetry || !retryOnInvalidJson) rethrow;
      final result = await _callClaude(
        '$userPrompt\n\nIMPORTANT: Your previous response was empty or malformed. Return only one complete valid JSON value, with no markdown or explanation.',
        isRetry: true,
        temperature: temperature,
        maxTokens: maxTokens,
        receiveTimeout: receiveTimeout,
      );
      _lastUsage = _combineUsage(usage, _lastUsage);
      return result;
    }
  }

  String _responseText(Object? responseData) {
    if (responseData is! Map) return '';
    final content = responseData['content'];
    if (content is! List) return '';
    return content
        .whereType<Map>()
        .where((block) => block['type'] == 'text')
        .map((block) => block['text'] as String? ?? '')
        .join('\n');
  }

  AiUsage? _combineUsage(AiUsage? first, AiUsage? second) {
    if (first == null) return second;
    if (second == null) return first;
    return AiUsage(
      inputTokens: first.inputTokens + second.inputTokens,
      outputTokens: first.outputTokens + second.outputTokens,
    );
  }

  AiUsage? _parseUsage(Object? raw) {
    if (raw is! Map) return null;
    final inputTokens = raw['input_tokens'];
    final outputTokens = raw['output_tokens'];
    final input = inputTokens is num ? inputTokens.toInt() : 0;
    final output = outputTokens is num ? outputTokens.toInt() : 0;
    if (input == 0 && output == 0) return null;
    return AiUsage(inputTokens: input, outputTokens: output);
  }

  dynamic _extractJson(String content) {
    String cleaned = content.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();
    if (cleaned.isEmpty) {
      throw const FormatException('AI returned an empty response.');
    }
    try {
      return jsonDecode(cleaned);
    } on FormatException {
      final objectStart = cleaned.indexOf('{');
      final arrayStart = cleaned.indexOf('[');
      final starts = [objectStart, arrayStart].where((index) => index >= 0);
      if (starts.isNotEmpty) {
        final start = starts.reduce((a, b) => a < b ? a : b);
        final end = [
          cleaned.lastIndexOf('}'),
          cleaned.lastIndexOf(']'),
        ].reduce((a, b) => a > b ? a : b);
        if (end > start) {
          return jsonDecode(cleaned.substring(start, end + 1));
        }
      }
      throw const FormatException(
        'AI returned incomplete or non-JSON content.',
      );
    }
  }
}
