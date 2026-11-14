import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lingo_app/data/ai/adapters/claude_adapter.dart';
import 'package:lingo_app/data/ai/adapters/openai_compatible.dart';
import 'package:lingo_app/data/ai/ai_provider.dart';

void main() {
  group('narration output budget', () {
    test('leaves reasoning room in the analysis token budget', () async {
      final bodies = <Map<String, dynamic>>[];
      final adapter = OpenAICompatibleAdapter(
        name: 'DeepSeek',
        baseUrl: 'http://ai.test',
        apiKey: 'test-key',
        model: 'deepseek-flash',
        dio: _scriptedDio((options) {
          bodies.add(Map<String, dynamic>.from(options.data as Map));
          return _completion(_validAnalysisJson());
        }),
      );

      await adapter.analyseNarration(
        rawTranscript: 'I go to shop yesterday.',
        cleanedTranscript: 'I go to shop yesterday.',
        chineseTranslation: '我昨天去商店了。',
        targetEnglish: 'I went to the shop yesterday.',
        accent: 'british',
        register: 'spoken',
        existingLearningItems: const [],
      );

      expect(bodies.single['max_tokens'], greaterThanOrEqualTo(16384));
    });

    test(
      'retries with a larger budget when reasoning eats max_tokens',
      () async {
        final budgets = <int>[];
        final adapter = OpenAICompatibleAdapter(
          name: 'DeepSeek',
          baseUrl: 'http://ai.test',
          apiKey: 'test-key',
          model: 'deepseek-flash',
          dio: _scriptedDio((options) {
            final budget = (options.data as Map)['max_tokens'] as int;
            budgets.add(budget);
            if (budgets.length == 1) {
              // Reasoning consumed the whole budget: no visible content at all.
              return _completion('', finishReason: 'length');
            }
            return _completion(_validAnalysisJson());
          }),
        );

        final analysis = await adapter.analyseNarration(
          rawTranscript: 'I go to shop yesterday.',
          cleanedTranscript: 'I go to shop yesterday.',
          chineseTranslation: '我昨天去商店了。',
          targetEnglish: 'I went to the shop yesterday.',
          accent: 'british',
          register: 'spoken',
          existingLearningItems: const [],
        );

        expect(budgets, hasLength(2));
        expect(budgets[1], budgets[0] * 2);
        expect(analysis.correctedExpression, 'I went to the shop yesterday.');
      },
    );

    test('raises a truncation error instead of a JSON format error', () async {
      final adapter = OpenAICompatibleAdapter(
        name: 'DeepSeek',
        baseUrl: 'http://ai.test',
        apiKey: 'test-key',
        model: 'deepseek-flash',
        dio: _scriptedDio((options) => _completion('', finishReason: 'length')),
      );

      await expectLater(
        adapter.analyseNarration(
          rawTranscript: 'I go to shop yesterday.',
          cleanedTranscript: 'I go to shop yesterday.',
          chineseTranslation: '我昨天去商店了。',
          targetEnglish: 'I went to the shop yesterday.',
          accent: 'british',
          register: 'spoken',
          existingLearningItems: const [],
        ),
        throwsA(isA<AiOutputTruncatedException>()),
      );
    });

    test('gives target generation enough room for reasoning tokens', () async {
      late Map<String, dynamic> body;
      final adapter = OpenAICompatibleAdapter(
        name: 'DeepSeek',
        baseUrl: 'http://ai.test',
        apiKey: 'test-key',
        model: 'deepseek-flash',
        dio: _scriptedDio((options) {
          body = Map<String, dynamic>.from(options.data as Map);
          return _completion(
            jsonEncode({
              'recommended': 'I went to the shop yesterday.',
              'alternatives': [
                {
                  'text': 'I popped to the shop yesterday.',
                  'difference': '更口语。',
                },
              ],
              'conflict_detected': false,
              'conflict_message': '',
              'needs_user_confirmation': false,
            }),
          );
        }),
      );

      await adapter.generateNarrationTarget(
        transcript: 'I go to shop yesterday.',
        chineseTranslation: '我昨天去商店了。',
        accent: 'british',
        register: 'spoken',
      );

      expect(body['max_tokens'], greaterThanOrEqualTo(4096));
    });

    test('claude adapter detects stop_reason max_tokens', () async {
      final adapter = ClaudeAdapter(
        apiKey: 'test-key',
        baseUrl: 'http://ai.test',
        dio: _scriptedDio(
          (options) => {
            'stop_reason': 'max_tokens',
            'content': const <Map<String, dynamic>>[],
            'usage': {'input_tokens': 10, 'output_tokens': 16384},
          },
        ),
      );

      await expectLater(
        adapter.analyseNarration(
          rawTranscript: 'I go to shop yesterday.',
          cleanedTranscript: 'I go to shop yesterday.',
          chineseTranslation: '我昨天去商店了。',
          targetEnglish: 'I went to the shop yesterday.',
          accent: 'british',
          register: 'spoken',
          existingLearningItems: const [],
        ),
        throwsA(isA<AiOutputTruncatedException>()),
      );
    });
  });
}

Dio _scriptedDio(Map<String, dynamic> Function(RequestOptions) handler) {
  return Dio(BaseOptions(baseUrl: 'http://ai.test'))
    ..httpClientAdapter = _JsonAdapter(handler);
}

Map<String, dynamic> _completion(
  String content, {
  String finishReason = 'stop',
}) {
  return {
    'choices': [
      {
        'finish_reason': finishReason,
        'message': {'content': content},
      },
    ],
    'usage': {'prompt_tokens': 100, 'completion_tokens': 200},
  };
}

String _validAnalysisJson() {
  return jsonEncode({
    'normalized_transcript': 'I went to the shop yesterday.',
    'sentence_pairs': [
      {
        'original': 'I go to shop yesterday.',
        'corrected': 'I went to the shop yesterday.',
        'differences': [
          {
            'original': 'go',
            'corrected': 'went',
            'type': 'grammar',
            'reason': '过去时间需要一般过去时。',
          },
        ],
      },
    ],
    'errors': [
      {
        'grade': 'B',
        'original': 'go',
        'issue': '一般现在时误用于过去时间。',
        'correction': 'went',
        'reason': 'yesterday 表明动作已发生。',
        'sentence_index': 0,
      },
    ],
    'collected_words': [
      {
        'stable_key': 'shop',
        'chinese': '商店',
        'english': 'shop',
        'part_of_speech': '名词',
        'category': 'word',
        'note': '常见的英式说法。',
      },
    ],
    'knowledge_points': [
      {
        'stable_key': 'past_simple',
        'title': '一般过去时',
        'explanation': '描述已完成的过去动作。',
        'level': 'core',
        'source': 'error',
        'review_required': true,
        'error_grade': 'B',
      },
    ],
    'speech_features': const <Map<String, dynamic>>[],
    'corrected_expression': 'I went to the shop yesterday.',
    'acceptable_variants': const <Map<String, dynamic>>[],
    'self_check': {
      'iterations': 1,
      'needs_user_confirmation': false,
      'checks': [
        {'key': 'semantics', 'passed': true, 'detail': '语义一致。'},
        {'key': 'form', 'passed': true, 'detail': '形式正确。'},
        {'key': 'naturalness', 'passed': true, 'detail': '表达自然。'},
        {'key': 'consistency', 'passed': true, 'detail': '与目标一致。'},
        {'key': 'style', 'passed': true, 'detail': '口语风格保留。'},
      ],
      'modifications': const <String>[],
      'uncertainties': const <String>[],
      'target_difference': '',
      'naturalness_basis': '符合英式口语习惯。',
    },
    'metrics': {
      'english_word_count': 6,
      'sentence_count': 1,
      'chinese_substitute_count': 0,
      'error_a_count': 0,
      'error_b_count': 1,
      'error_c_count': 0,
      'complexity': 10,
    },
    'real_usage_events': const <Map<String, dynamic>>[],
  });
}

class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this.handler);

  final Map<String, dynamic> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(handler(options)),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
