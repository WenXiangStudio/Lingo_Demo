import 'dart:convert';

import 'package:dio/dio.dart';

import '../ai_provider.dart';
import '../prompts.dart';
import '../../models/ai_models.dart';

class ClaudeAdapter implements AiProvider {
  final String _model;
  final Dio _dio;
  AiUsage? _lastUsage;

  ClaudeAdapter({
    required String apiKey,
    String baseUrl = 'https://api.anthropic.com',
    String model = 'claude-sonnet-4-6',
  }) : _model = model,
       _dio = Dio(
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

  Future<dynamic> _callClaude(
    String userPrompt, {
    bool isRetry = false,
    bool retryOnInvalidJson = true,
  }) async {
    final response = await _dio.post(
      '/v1/messages',
      data: {
        'model': _model,
        'max_tokens': 4096,
        'temperature': 0.7,
        'messages': [
          {'role': 'user', 'content': userPrompt},
        ],
      },
    );
    _lastUsage = _parseUsage(response.data['usage']);
    final usage = _lastUsage;
    try {
      return _extractJson(_responseText(response.data));
    } on FormatException {
      if (isRetry || !retryOnInvalidJson) rethrow;
      final result = await _callClaude(
        '$userPrompt\n\nIMPORTANT: Your previous response was empty or malformed. Return only one complete valid JSON value, with no markdown or explanation.',
        isRetry: true,
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
