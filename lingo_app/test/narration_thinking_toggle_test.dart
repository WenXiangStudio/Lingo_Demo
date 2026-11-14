import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lingo_app/data/ai/adapters/openai_compatible.dart';
import 'package:lingo_app/data/database/app_database.dart';
import 'package:lingo_app/data/repositories/repositories.dart';

void main() {
  group('thinking toggle', () {
    test('sends thinking disabled when reasoning is turned off', () async {
      late Map<String, dynamic> body;
      final adapter = OpenAICompatibleAdapter(
        name: 'DeepSeek',
        baseUrl: 'http://ai.test',
        apiKey: 'test-key',
        model: 'deepseek-flash',
        supportsThinkingToggle: true,
        thinkingEnabled: false,
        dio: _scriptedDio((options) {
          body = Map<String, dynamic>.from(options.data as Map);
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

      expect(body['thinking'], {'type': 'disabled'});
    });

    test('omits the thinking field when reasoning stays on', () async {
      late Map<String, dynamic> body;
      final adapter = OpenAICompatibleAdapter(
        name: 'DeepSeek',
        baseUrl: 'http://ai.test',
        apiKey: 'test-key',
        model: 'deepseek-flash',
        supportsThinkingToggle: true,
        thinkingEnabled: true,
        dio: _scriptedDio((options) {
          body = Map<String, dynamic>.from(options.data as Map);
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

      expect(body.containsKey('thinking'), isFalse);
    });

    test(
      'never sends the thinking field to providers without support',
      () async {
        late Map<String, dynamic> body;
        final adapter = OpenAICompatibleAdapter(
          name: 'Kimi',
          baseUrl: 'http://ai.test',
          apiKey: 'test-key',
          model: 'moonshot-v1-8k',
          thinkingEnabled: false,
          dio: _scriptedDio((options) {
            body = Map<String, dynamic>.from(options.data as Map);
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

        expect(body.containsKey('thinking'), isFalse);
      },
    );

    test('per-call override wins over the adapter default', () async {
      late Map<String, dynamic> body;
      final adapter = OpenAICompatibleAdapter(
        name: 'DeepSeek',
        baseUrl: 'http://ai.test',
        apiKey: 'test-key',
        model: 'deepseek-flash',
        supportsThinkingToggle: true,
        thinkingEnabled: false,
        dio: _scriptedDio((options) {
          body = Map<String, dynamic>.from(options.data as Map);
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
        thinkingEnabled: true,
      );

      expect(body.containsKey('thinking'), isFalse);
    });
  });

  group('thinking setting persistence', () {
    late AppDatabase database;
    late SettingsRepository settings;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      settings = SettingsRepository(database);
    });

    tearDown(() => database.close());

    test('defaults to reasoning on', () async {
      expect(await settings.getAiThinkingEnabled(), isTrue);
    });

    test('round-trips a disabled value', () async {
      await settings.setAiThinkingEnabled(false);
      expect(await settings.getAiThinkingEnabled(), isFalse);

      await settings.setAiThinkingEnabled(true);
      expect(await settings.getAiThinkingEnabled(), isTrue);
    });
  });
}

Dio _scriptedDio(Map<String, dynamic> Function(RequestOptions) handler) {
  return Dio(BaseOptions(baseUrl: 'http://ai.test'))
    ..httpClientAdapter = _JsonAdapter(handler);
}

Map<String, dynamic> _completion(String content) {
  return {
    'choices': [
      {
        'finish_reason': 'stop',
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
