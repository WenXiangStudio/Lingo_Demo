import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../ai_provider.dart';
import '../prompts.dart';
import '../../models/ai_models.dart';
import '../../models/narration_ai_models.dart';

/// Base adapter for OpenAI-compatible APIs (DeepSeek, Kimi, GLM, etc.).
class OpenAICompatibleAdapter implements AiProvider {
  /// Narration calls are much larger than the rest of the app's requests.
  /// Reasoning tokens are billed against `max_tokens`, so the budget must leave
  /// room for thinking *and* the full JSON payload.
  static const int _narrationTargetMaxTokens = 4096;
  static const int _narrationAnalysisMaxTokens = 16384;
  static const int _maxRetryMaxTokens = 65536;

  /// A reasoning model can spend minutes on a long transcript. The default
  /// 120s receive timeout is not enough for the analysis prompt.
  static const Duration _narrationReceiveTimeout = Duration(seconds: 300);

  final String _name;
  final String _model;
  final bool _useJsonObjectForCollocationValidation;
  final bool _supportsThinkingToggle;
  final bool _thinkingEnabled;
  final Dio _dio;
  AiUsage? _lastUsage;

  OpenAICompatibleAdapter({
    required String name,
    required String baseUrl,
    required String apiKey,
    required String model,
    bool useJsonObjectForCollocationValidation = false,
    bool supportsThinkingToggle = false,
    bool thinkingEnabled = true,
    Dio? dio,
  }) : _name = name,
       _model = model,
       _useJsonObjectForCollocationValidation =
           useJsonObjectForCollocationValidation,
       _supportsThinkingToggle = supportsThinkingToggle,
       _thinkingEnabled = thinkingEnabled,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               headers: {
                 'Authorization': 'Bearer $apiKey',
                 'Content-Type': 'application/json',
               },
               connectTimeout: const Duration(seconds: 30),
               receiveTimeout: const Duration(seconds: 120),
             ),
           );

  @override
  String get providerName => _name;

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
    final json = await _callAi(prompt);
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
    final useJsonObject = _useJsonObjectForCollocationValidation;
    final json = await _callAi(
      AiPrompts.collocationOptionValidationPrompt(
        requests,
        jsonObjectWrapper: useJsonObject,
      ),
      retryOnInvalidJson: false,
      responseFormat: useJsonObject ? const {'type': 'json_object'} : null,
      temperature: useJsonObject ? 0.1 : null,
      maxTokens: useJsonObject ? 1024 : null,
      structuredOutputLabel: useJsonObject
          ? 'collocation_option_validation'
          : null,
    );
    final items = useJsonObject ? _jsonObjectItems(json) : json;
    return (items as List)
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
    final json = await _callAi(prompt);
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
    final json = await _callAi(
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
    final json = await _callAi(prompt);
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
    final json = await _callAi(prompt);
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
    final json = await _callAi(prompt);
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
    final json = await _callAi(prompt);
    return InteractiveDialogueTurn.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<WordStory> generateWordStory(List<String> words) async {
    final prompt = AiPrompts.wordStoryPrompt(words);
    final json = await _callAi(prompt);
    return WordStory.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<String> generateScenario(String word, String meaning) async {
    final prompt = AiPrompts.scenarioPrompt(word, meaning);
    final json = await _callAi(prompt);
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
    final json = await _callAi(
      prompt,
      temperature: 0.2,
      maxTokens: _narrationTargetMaxTokens,
      receiveTimeout: _narrationReceiveTimeout,
      thinkingEnabled: thinkingEnabled,
    );
    var result = NarrationTargetDraft.fromJson(
      Map<String, dynamic>.from(json as Map),
    );
    if (!result.hasChineseExplanations) {
      final firstUsage = _lastUsage;
      final retryJson = await _callAi(
        '$prompt\n\nLANGUAGE CORRECTION: Your previous JSON used English explanatory prose. Regenerate the complete JSON. Every explanatory field specified by the mandatory output-language contract must contain Simplified Chinese. Keep only the English expressions and source spans in English.',
        temperature: 0.1,
        maxTokens: _narrationTargetMaxTokens,
        receiveTimeout: _narrationReceiveTimeout,
        thinkingEnabled: thinkingEnabled,
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
    final json = await _callAi(
      prompt,
      temperature: 0.2,
      maxTokens: _narrationAnalysisMaxTokens,
      receiveTimeout: _narrationReceiveTimeout,
      thinkingEnabled: thinkingEnabled,
    );
    var result = NarrationAnalysis.fromJson(
      Map<String, dynamic>.from(json as Map),
    );
    if (!result.hasChineseExplanations) {
      final firstUsage = _lastUsage;
      final retryJson = await _callAi(
        '$prompt\n\nLANGUAGE CORRECTION: Your previous JSON used English explanatory prose. Regenerate the complete JSON. Every explanatory, diagnostic, reason, note, knowledge and self-check field specified by the mandatory output-language contract must contain Simplified Chinese. Keep only English expressions, source spans, stable keys and exact evidence in English.',
        temperature: 0.1,
        maxTokens: _narrationAnalysisMaxTokens,
        receiveTimeout: _narrationReceiveTimeout,
        thinkingEnabled: thinkingEnabled,
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

  Future<dynamic> _callAi(
    String userPrompt, {
    bool isRetry = false,
    bool retryOnInvalidJson = true,
    Map<String, dynamic>? responseFormat,
    double? temperature,
    int? maxTokens,
    Duration? receiveTimeout,
    String? structuredOutputLabel,
    bool budgetEscalated = false,
    bool? thinkingEnabled,
  }) async {
    final budget = maxTokens ?? 4096;
    final requestData = <String, dynamic>{
      'model': _model,
      'messages': [
        {'role': 'user', 'content': userPrompt},
      ],
      'temperature': temperature ?? 0.7,
      'max_tokens': budget,
    };
    if (responseFormat != null) {
      requestData['response_format'] = responseFormat;
    }
    // Only send the field when the model is known to support it. Reasoning is
    // on by default, so "enabled" sends nothing and other vendors are untouched.
    final thinking = thinkingEnabled ?? _thinkingEnabled;
    if (_supportsThinkingToggle && !thinking) {
      requestData['thinking'] = {'type': 'disabled'};
    }
    late final Response<dynamic> response;
    try {
      response = await _dio.post(
        '/v1/chat/completions',
        data: requestData,
        options: receiveTimeout == null
            ? null
            : Options(receiveTimeout: receiveTimeout),
      );
    } on DioException catch (error, stackTrace) {
      if (structuredOutputLabel != null) {
        developer.log(
          '$structuredOutputLabel request failed. '
          'provider=$_name model=$_model failure_type=${error.type.name} '
          'http_status=${error.response?.statusCode ?? 'none'}',
          name: 'LingoDemo.AI',
          level: 900,
          stackTrace: stackTrace,
        );
      }
      rethrow;
    }
    _lastUsage = _parseUsage(response.data['usage']);
    final usage = _lastUsage;
    if (_finishReason(response.data) == 'length') {
      final grown = budget * 2;
      if (!budgetEscalated && grown <= _maxRetryMaxTokens) {
        // The output budget ran out before any usable answer was produced,
        // which reasoning tokens commonly cause. Retry once with more room
        // instead of failing the whole narration flow.
        developer.log(
          '${structuredOutputLabel ?? 'request'} hit max_tokens=$budget '
          '(completion=${usage?.outputTokens ?? 'unknown'} tokens). '
          'Retrying once with max_tokens=$grown.',
          name: 'LingoDemo.AI',
          level: 900,
        );
        final result = await _callAi(
          userPrompt,
          isRetry: isRetry,
          retryOnInvalidJson: retryOnInvalidJson,
          responseFormat: responseFormat,
          temperature: temperature,
          maxTokens: grown,
          receiveTimeout: receiveTimeout,
          structuredOutputLabel: structuredOutputLabel,
          budgetEscalated: true,
          thinkingEnabled: thinkingEnabled,
        );
        _lastUsage = _combineUsage(usage, _lastUsage);
        return result;
      }
      throw AiOutputTruncatedException(outputTokens: usage?.outputTokens);
    }
    try {
      return _extractJson(_responseText(response.data));
    } on FormatException catch (error, stackTrace) {
      if (structuredOutputLabel != null) {
        developer.log(
          '$structuredOutputLabel returned unusable structured output. '
          '${_structuredOutputDiagnostic(response.data)}',
          name: 'LingoDemo.AI',
          level: 900,
          error: error,
          stackTrace: stackTrace,
        );
      }
      if (isRetry || !retryOnInvalidJson) rethrow;
      final result = await _callAi(
        '$userPrompt\n\nIMPORTANT: Your previous response was empty or malformed. Return only one complete valid JSON value, with no markdown or explanation.',
        isRetry: true,
        retryOnInvalidJson: retryOnInvalidJson,
        responseFormat: responseFormat,
        temperature: temperature,
        maxTokens: budget,
        receiveTimeout: receiveTimeout,
        structuredOutputLabel: structuredOutputLabel,
        thinkingEnabled: thinkingEnabled,
      );
      _lastUsage = _combineUsage(usage, _lastUsage);
      return result;
    }
  }

  String? _finishReason(Object? responseData) {
    if (responseData is! Map) return null;
    final choices = responseData['choices'];
    if (choices is! List || choices.isEmpty || choices.first is! Map) {
      return null;
    }
    final reason = (choices.first as Map)['finish_reason'];
    return reason is String ? reason : null;
  }

  List<dynamic> _jsonObjectItems(dynamic json) {
    if (json is Map && json['items'] is List) {
      return List<dynamic>.from(json['items'] as List);
    }
    developer.log(
      'collocation_option_validation returned an unexpected JSON shape. '
      'provider=$_name model=$_model top_level_type=${json.runtimeType}',
      name: 'LingoDemo.AI',
      level: 900,
    );
    throw const FormatException('AI returned a JSON object without items.');
  }

  String _structuredOutputDiagnostic(Object? responseData) {
    if (responseData is! Map) {
      return 'provider=$_name model=$_model response_type=${responseData.runtimeType}';
    }
    final choices = responseData['choices'];
    final choice = choices is List && choices.isNotEmpty && choices.first is Map
        ? choices.first as Map
        : null;
    final message = choice?['message'];
    final content = message is Map ? message['content'] : null;
    final reasoningContent = message is Map
        ? message['reasoning_content']
        : null;
    final contentLength = content is String ? content.length : 0;
    final reasoningLength = reasoningContent is String
        ? reasoningContent.length
        : 0;
    return 'provider=$_name model=$_model '
        'finish_reason=${choice?['finish_reason'] ?? 'missing'} '
        'content_type=${content.runtimeType} content_chars=$contentLength '
        'reasoning_chars=$reasoningLength';
  }

  String _responseText(Object? responseData) {
    if (responseData is! Map) return '';
    final choices = responseData['choices'];
    if (choices is! List || choices.isEmpty || choices.first is! Map) return '';
    final message = (choices.first as Map)['message'];
    if (message is! Map) return '';
    final content = message['content'];
    if (content is String) return content;
    if (content is! List) return '';
    return content
        .whereType<Map>()
        .map((part) => part['text'] as String? ?? '')
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
    final promptTokens = raw['prompt_tokens'];
    final completionTokens = raw['completion_tokens'];
    final input = promptTokens is num ? promptTokens.toInt() : 0;
    final output = completionTokens is num ? completionTokens.toInt() : 0;
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
