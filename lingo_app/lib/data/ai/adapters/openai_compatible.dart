import 'dart:convert';

import 'package:dio/dio.dart';

import '../ai_provider.dart';
import '../prompts.dart';
import '../../models/ai_models.dart';

/// Base adapter for OpenAI-compatible APIs (DeepSeek, Kimi, GLM, etc.).
class OpenAICompatibleAdapter implements AiProvider {
  final String _name;
  final String _model;
  final Dio _dio;
  AiUsage? _lastUsage;

  OpenAICompatibleAdapter({
    required String name,
    required String baseUrl,
    required String apiKey,
    required String model,
  }) : _name = name,
       _model = model,
       _dio = Dio(
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
  Future<List<Collocation>> generateCollocations(List<String> words) async {
    final prompt = AiPrompts.collocationsPrompt(words);
    final json = await _callAi(prompt);
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
    final json = await _callAi(prompt);
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
    final json = await _callAi(prompt);
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

  Future<dynamic> _callAi(String userPrompt) async {
    final response = await _dio.post(
      '/v1/chat/completions',
      data: {
        'model': _model,
        'messages': [
          {'role': 'user', 'content': userPrompt},
        ],
        'temperature': 0.7,
        'max_tokens': 4096,
      },
    );
    _lastUsage = _parseUsage(response.data['usage']);
    final content = response.data['choices'][0]['message']['content'] as String;
    return _extractJson(content);
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
    return jsonDecode(cleaned);
  }
}
