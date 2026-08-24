import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lingo_app/core/i18n/app_strings.dart';
import 'package:lingo_app/data/ai/adapters/openai_compatible.dart';
import 'package:lingo_app/data/ai/prompts.dart';
import 'package:lingo_app/data/models/ai_models.dart';
import 'package:lingo_app/features/practice/providers/deep_practice_provider.dart';

void main() {
  group('Deep practice AI models', () {
    test('keeps the source word when parsing generated collocations', () {
      final collocation = Collocation.fromJson({
        'word': 'tiny',
        'english': 'a tiny detail',
        'chinese_translation': '一个微小的细节',
        'collocation_type': 'adjective + noun',
      });

      expect(collocation.sourceWord, 'tiny');
      expect(collocation.toJson()['word'], 'tiny');
    });

    test('parses only the approved collocation distractor payload', () {
      final validation = CollocationOptionValidation.fromJson({
        'word_id': 42,
        'distractors': ['large', 'formal', 'basic'],
      });

      expect(validation.wordId, 42);
      expect(validation.distractors, ['large', 'formal', 'basic']);
    });

    test(
      'distinguishes an acceptable alternative from an incorrect answer',
      () {
        expect(
          FillAnswerEvaluation.fromJson({
            'classification': 'acceptable_alternative',
            'feedback': '表达自然，但不是目标词。',
          }).isAcceptableAlternative,
          isTrue,
        );
        expect(
          FillAnswerEvaluation.fromJson({
            'classification': 'incorrect',
            'is_acceptable_alternative': false,
          }).isAcceptableAlternative,
          isFalse,
        );
      },
    );

    test('option validation prompt is constrained to local candidates', () {
      final prompt = AiPrompts.collocationOptionValidationPrompt([
        const CollocationOptionRequest(
          wordId: 42,
          targetWord: 'tiny',
          collocation: 'a tiny detail',
          displayText: 'a _____ detail',
          candidateWords: ['major', 'formal', 'basic'],
        ),
      ]);

      expect(prompt, contains('word_id'));
      expect(prompt, contains('candidate_words'));
      expect(prompt, contains('Never invent a word'));
      expect(prompt, contains('tiny'));
    });

    test('collocation prompt anchors translations to the studied sense', () {
      final prompt = AiPrompts.collocationsPrompt(
        ['duck'],
        targetMeanings: {'duck': '鸭；鸭子；鸭肉'},
      );

      expect(prompt, contains('dictionary_chinese_meanings'));
      expect(prompt, contains('鸭；鸭子；鸭肉'));
      expect(prompt, contains('duck out of'));
      expect(prompt, contains('Never use an idiom'));
    });

    test('uses DeepSeek JSON object output for option validation', () async {
      late Map<String, dynamic> requestBody;
      final dio = Dio(BaseOptions(baseUrl: 'http://ai.test'))
        ..httpClientAdapter = _JsonAdapter((options) {
          requestBody = Map<String, dynamic>.from(options.data as Map);
          return {
            'choices': [
              {
                'finish_reason': 'stop',
                'message': {
                  'content':
                      '{"items":[{"word_id":42,"distractors":["major","formal","basic"]}]}',
                },
              },
            ],
            'usage': {'prompt_tokens': 10, 'completion_tokens': 8},
          };
        });
      final adapter = OpenAICompatibleAdapter(
        name: 'DeepSeek',
        baseUrl: 'http://ai.test',
        apiKey: 'test-key',
        model: 'deepseek-v4-flash',
        useJsonObjectForCollocationValidation: true,
        dio: dio,
      );

      final result = await adapter.validateCollocationOptions([
        const CollocationOptionRequest(
          wordId: 42,
          targetWord: 'tiny',
          collocation: 'a tiny detail',
          displayText: 'a _____ detail',
          candidateWords: ['major', 'formal', 'basic'],
        ),
      ]);

      expect(requestBody['response_format'], {'type': 'json_object'});
      expect(requestBody['temperature'], 0.1);
      expect(requestBody['max_tokens'], 1024);
      final message = (requestBody['messages'] as List).single as Map;
      expect(message['content'], contains('"items"'));
      expect(result.single.wordId, 42);
      expect(result.single.distractors, ['major', 'formal', 'basic']);
    });
  });

  test('new deep-practice UI strings are translated', () {
    expect(AppStrings.get('deep_scope_title', 'en'), 'Choose practice range');
    expect(AppStrings.get('deep_scope_title', 'zh'), '选择练习范围');
    expect(AppStrings.get('previous_question', 'zh'), '上一题');
    expect(
      AppStrings.get('ai_collocation_option_validation', 'zh'),
      'AI 校验搭配干扰项',
    );
  });

  test('disabled AI option validation uses the collocation fill-in flow', () {
    const state = DeepPracticeState(
      mode: 'deep_choice',
      collocationOptionValidationEnabled: false,
    );

    expect(state.collocationOptionsDisabledBySetting, isTrue);
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
