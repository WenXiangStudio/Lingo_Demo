import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingo_app/data/diagnosis/present_tense_diagnosis_client.dart';

void main() {
  group('PresentTenseDiagnosisClient', () {
    test(
      'posts question and answer and parses diagnosis debug fields',
      () async {
        late Map<String, dynamic> requestBody;
        final dio = Dio(BaseOptions(baseUrl: 'http://diagnosis.test'))
          ..httpClientAdapter = _JsonAdapter((options) {
            expect(options.uri.path, '/diagnosis/present-tense');
            requestBody = (options.data as Map).cast<String, dynamic>();
            return {
              'question': requestBody['question'],
              'answer': requestBody['answer'],
              'hasError': true,
              'correctedAnswer':
                  'My brother likes coffee, but he is drinking tea now.',
              'errors': [
                {
                  'span': 'My brother like',
                  'errorType': '一般现在时第三人称单数形式错误',
                  'grammarRule': '主语是第三人称单数时，动词需要使用第三人称单数形式。',
                  'reasoning': 'My brother 相当于 he，所以 like 应改为 likes。',
                  'correction': 'My brother likes',
                },
              ],
              'retrieval': {
                'centralCards': ['tense-005', 'tense-003'],
                'supportingCards': ['tense-006'],
                'fallback': false,
              },
            };
          });
        final client = PresentTenseDiagnosisClient(dio: dio);

        final result = await client.diagnose(
          question: 'What does your brother drink?',
          answer: 'My brother like coffee, but he drinking tea now.',
        );

        expect(requestBody['question'], 'What does your brother drink?');
        expect(
          requestBody['answer'],
          'My brother like coffee, but he drinking tea now.',
        );
        expect(result.hasError, isTrue);
        expect(result.errors.single.errorType, '一般现在时第三人称单数形式错误');
        expect(result.retrieval.centralCards, ['tense-005', 'tense-003']);
        expect(result.retrieval.supportingCards, ['tense-006']);
        expect(result.retrieval.fallback, isFalse);
      },
    );

    test('rejects empty answers before calling the route', () async {
      final client = PresentTenseDiagnosisClient(dio: Dio());

      expect(
        () => client.diagnose(question: 'What are you doing?', answer: '   '),
        throwsA(isA<ArgumentError>()),
      );
    });
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
    final response = handler(options);
    return ResponseBody.fromString(
      jsonEncode(response),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
