import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingo_app/data/retrieval/retrieval_v2_client.dart';

void main() {
  group('RetrievalV2Client', () {
    test('posts bundle requests and parses selected cards', () async {
      late Map<String, dynamic> requestBody;
      final dio = Dio(BaseOptions(baseUrl: 'http://retrieval.test'))
        ..httpClientAdapter = _JsonAdapter((options) {
          expect(options.uri.path, '/retrieval/v2/bundle');
          requestBody = (options.data as Map).cast<String, dynamic>();
          return {
            'query': requestBody['query'],
            'retrievalVersion': '2.0',
            'selected': [
              {
                'cardId': 'spelling-006',
                'role': 'central',
                'card': {
                  'ruleName': 'third-person singular present simple spelling',
                },
                'generationInstruction':
                    'Use the correct -s/-es form with he, she, or it.',
                'evidenceStatus': 'render-verified',
                'evidence': [
                  {
                    'examples': [
                      'I work in a shop. My brother works in a bank.',
                    ],
                  },
                ],
              },
            ],
          };
        });
      final client = RetrievalV2Client(dio: dio);

      final bundle = await client.buildBundle(
        query: 'How do I correct My brother work?',
        topK: 5,
        candidateK: 20,
        maxEvidenceExamples: 2,
      );

      expect(requestBody['query'], 'How do I correct My brother work?');
      expect(requestBody['topK'], 5);
      expect(requestBody['candidateK'], 20);
      expect(requestBody['maxEvidenceExamples'], 2);
      expect(bundle.selected.single.cardId, 'spelling-006');
      expect(bundle.selected.single.role, 'central');
      expect(
        bundle.toPromptContext(),
        contains('third-person singular present simple spelling'),
      );
    });

    test('rejects empty queries before calling the route', () async {
      final client = RetrievalV2Client(dio: Dio());

      expect(
        () => client.buildBundle(query: '   '),
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
