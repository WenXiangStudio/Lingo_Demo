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
  Future<List<Collocation>> generateCollocations(List<String> words) async {
    final prompt = AiPrompts.collocationsPrompt(words);
    final json = await _callClaude(prompt);
    final results = (json as List).cast<Map<String, dynamic>>();
    final collocations = <Collocation>[];
    for (final entry in results) {
      for (final c in (entry['collocations'] as List)) {
        collocations.add(Collocation.fromJson(c as Map<String, dynamic>));
      }
    }
    return collocations;
  }

  @override
  Future<List<AiSentence>> generateSentences(List<String> words) async {
    final prompt = AiPrompts.sentencesPrompt(words);
    final json = await _callClaude(prompt);
    final results = (json as List).cast<Map<String, dynamic>>();
    final sentences = <AiSentence>[];
    for (final entry in results) {
      for (final s in (entry['sentences'] as List)) {
        sentences.add(AiSentence.fromJson(s as Map<String, dynamic>));
      }
    }
    return sentences;
  }

  @override
  Future<List<AiSentence>> generateIdioms(List<String> words) async {
    final prompt = AiPrompts.idiomsPrompt(words);
    final json = await _callClaude(prompt);
    final results = (json as List).cast<Map<String, dynamic>>();
    final idioms = <AiSentence>[];
    for (final entry in results) {
      for (final s in (entry['sentences'] as List)) {
        idioms.add(AiSentence.fromJson(s as Map<String, dynamic>));
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

  Future<dynamic> _callClaude(String userPrompt) async {
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
    final content = response.data['content'] as List;
    final text = content
        .where((c) => c['type'] == 'text')
        .map((c) => c['text'] as String)
        .join('\n');
    return jsonDecode(text);
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
}
