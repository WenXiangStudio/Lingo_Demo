import 'package:dio/dio.dart';

class RetrievalV2Client {
  static const defaultBaseUrl = 'http://127.0.0.1:8765';

  final Dio _dio;

  RetrievalV2Client({String baseUrl = defaultBaseUrl, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              headers: {'Content-Type': 'application/json'},
              connectTimeout: const Duration(seconds: 2),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  Future<RetrievalV2Health> health() async {
    final response = await _dio.get('/health');
    return RetrievalV2Health.fromJson(_asMap(response.data));
  }

  Future<RetrievalV2Bundle> buildBundle({
    required String query,
    int topK = 5,
    int candidateK = 20,
    int maxEvidenceExamples = 3,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(query, 'query', 'must not be empty');
    }

    final response = await _dio.post(
      '/retrieval/v2/bundle',
      data: {
        'query': trimmed,
        'topK': topK,
        'candidateK': candidateK,
        'maxEvidenceExamples': maxEvidenceExamples,
      },
    );
    return RetrievalV2Bundle.fromJson(_asMap(response.data));
  }
}

class RetrievalV2Health {
  final String status;
  final String route;
  final String retrievalVersion;
  final String embeddingProvider;
  final String routerProvider;
  final int? cardCount;
  final int? vectorCount;

  const RetrievalV2Health({
    required this.status,
    required this.route,
    required this.retrievalVersion,
    required this.embeddingProvider,
    required this.routerProvider,
    required this.cardCount,
    required this.vectorCount,
  });

  factory RetrievalV2Health.fromJson(Map<String, dynamic> json) {
    return RetrievalV2Health(
      status: _string(json['status']),
      route: _string(json['route']),
      retrievalVersion: _string(json['retrievalVersion']),
      embeddingProvider: _string(json['embeddingProvider']),
      routerProvider: _string(json['routerProvider']),
      cardCount: _int(json['cardCount']),
      vectorCount: _int(json['vectorCount']),
    );
  }
}

class RetrievalV2Bundle {
  final String query;
  final String retrievalVersion;
  final List<RetrievalV2SelectedCard> selected;
  final Map<String, dynamic> raw;

  const RetrievalV2Bundle({
    required this.query,
    required this.retrievalVersion,
    required this.selected,
    required this.raw,
  });

  factory RetrievalV2Bundle.fromJson(Map<String, dynamic> json) {
    return RetrievalV2Bundle(
      query: _string(json['query']),
      retrievalVersion: _string(json['retrievalVersion']),
      selected: _list(json['selected'])
          .map((item) => RetrievalV2SelectedCard.fromJson(_asMap(item)))
          .toList(growable: false),
      raw: json,
    );
  }

  String toPromptContext({int maxCards = 3, int maxExamplesPerCard = 2}) {
    if (selected.isEmpty) return '';
    final lines = <String>[
      'Relevant English grammar references for the learner reply:',
      for (final card in selected.take(maxCards))
        card.toPromptLine(maxExamples: maxExamplesPerCard),
    ];
    return lines.join('\n');
  }
}

class RetrievalV2SelectedCard {
  final String cardId;
  final String role;
  final String ruleName;
  final String generationInstruction;
  final String evidenceStatus;
  final List<String> evidenceExamples;

  const RetrievalV2SelectedCard({
    required this.cardId,
    required this.role,
    required this.ruleName,
    required this.generationInstruction,
    required this.evidenceStatus,
    required this.evidenceExamples,
  });

  factory RetrievalV2SelectedCard.fromJson(Map<String, dynamic> json) {
    final card = _map(json['card']);
    final examples = <String>[];
    for (final evidence in _list(json['evidence'])) {
      final evidenceMap = _map(evidence);
      for (final example in _list(evidenceMap['examples'])) {
        final text = _string(example).trim();
        if (text.isNotEmpty) examples.add(text);
      }
    }
    return RetrievalV2SelectedCard(
      cardId: _string(json['cardId']),
      role: _string(json['role']),
      ruleName: _string(card['ruleName']),
      generationInstruction: _string(json['generationInstruction']),
      evidenceStatus: _string(json['evidenceStatus']),
      evidenceExamples: examples,
    );
  }

  String toPromptLine({int maxExamples = 2}) {
    final buffer = StringBuffer('- ');
    if (role.isNotEmpty) buffer.write('$role: ');
    buffer.write(ruleName.isNotEmpty ? ruleName : cardId);
    if (generationInstruction.isNotEmpty) {
      buffer.write('. $generationInstruction');
    }
    final examples = evidenceExamples
        .where((example) => example.trim().isNotEmpty)
        .take(maxExamples)
        .toList(growable: false);
    if (examples.isNotEmpty) {
      buffer.write(' Examples: ${examples.join(' | ')}');
    }
    return buffer.toString();
  }
}

class RetrievalV2Exception implements Exception {
  final String message;

  const RetrievalV2Exception(this.message);

  @override
  String toString() => 'RetrievalV2Exception: $message';
}

Map<String, dynamic> _asMap(Object? raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return raw.cast<String, dynamic>();
  throw const RetrievalV2Exception('Unexpected Retrieval v2 response shape');
}

Map<String, dynamic> _map(Object? raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return raw.cast<String, dynamic>();
  return const <String, dynamic>{};
}

List<Object?> _list(Object? raw) {
  if (raw is List) return raw;
  return const <Object?>[];
}

String _string(Object? raw) => raw is String ? raw : '';

int? _int(Object? raw) => raw is num ? raw.toInt() : null;
