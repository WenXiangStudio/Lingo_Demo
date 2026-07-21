import 'package:dio/dio.dart';

class PresentTenseDiagnosisClient {
  static const defaultBaseUrl = 'http://127.0.0.1:8765';
  static const endpointPath = '/diagnosis/present-tense';

  final Dio _dio;

  PresentTenseDiagnosisClient({String baseUrl = defaultBaseUrl, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              headers: {'Content-Type': 'application/json'},
              connectTimeout: const Duration(seconds: 3),
              receiveTimeout: const Duration(seconds: 90),
            ),
          );

  Future<PresentTenseDiagnosisResult> diagnose({
    required String question,
    required String answer,
  }) async {
    final trimmedQuestion = question.trim();
    final trimmedAnswer = answer.trim();
    if (trimmedQuestion.isEmpty) {
      throw ArgumentError.value(question, 'question', 'must not be empty');
    }
    if (trimmedAnswer.isEmpty) {
      throw ArgumentError.value(answer, 'answer', 'must not be empty');
    }

    final response = await _dio.post(
      endpointPath,
      data: {'question': trimmedQuestion, 'answer': trimmedAnswer},
    );
    return PresentTenseDiagnosisResult.fromJson(_asMap(response.data));
  }
}

class PresentTenseDiagnosisResult {
  final String question;
  final String answer;
  final bool hasError;
  final String correctedAnswer;
  final List<PresentTenseDiagnosisError> errors;
  final PresentTenseRetrievalDebug retrieval;
  final Map<String, dynamic> raw;

  const PresentTenseDiagnosisResult({
    required this.question,
    required this.answer,
    required this.hasError,
    required this.correctedAnswer,
    required this.errors,
    required this.retrieval,
    required this.raw,
  });

  factory PresentTenseDiagnosisResult.fromJson(Map<String, dynamic> json) {
    final errors = _list(json['errors'])
        .map((item) => PresentTenseDiagnosisError.fromJson(_map(item)))
        .where((error) => error.hasContent)
        .toList(growable: false);
    return PresentTenseDiagnosisResult(
      question: _string(json['question']),
      answer: _string(json['answer']),
      hasError:
          _bool(json['hasError'] ?? json['has_error']) ?? errors.isNotEmpty,
      correctedAnswer: _string(
        json['correctedAnswer'] ?? json['corrected_answer'],
      ),
      errors: errors,
      retrieval: PresentTenseRetrievalDebug.fromJson(
        _map(json['retrieval']),
        rawRoot: json,
      ),
      raw: json,
    );
  }
}

class PresentTenseDiagnosisError {
  final String span;
  final String errorType;
  final String grammarRule;
  final String reasoning;
  final String correction;

  const PresentTenseDiagnosisError({
    required this.span,
    required this.errorType,
    required this.grammarRule,
    required this.reasoning,
    required this.correction,
  });

  factory PresentTenseDiagnosisError.fromJson(Map<String, dynamic> json) {
    return PresentTenseDiagnosisError(
      span: _string(json['span']),
      errorType: _string(json['errorType'] ?? json['error_type']),
      grammarRule: _string(json['grammarRule'] ?? json['grammar_rule']),
      reasoning: _string(json['reasoning'] ?? json['reason']),
      correction: _string(json['correction']),
    );
  }

  bool get hasContent =>
      span.isNotEmpty ||
      errorType.isNotEmpty ||
      grammarRule.isNotEmpty ||
      reasoning.isNotEmpty ||
      correction.isNotEmpty;
}

class PresentTenseRetrievalDebug {
  final List<String> centralCards;
  final List<String> supportingCards;
  final bool fallback;

  const PresentTenseRetrievalDebug({
    required this.centralCards,
    required this.supportingCards,
    required this.fallback,
  });

  factory PresentTenseRetrievalDebug.fromJson(
    Map<String, dynamic> json, {
    required Map<String, dynamic> rawRoot,
  }) {
    final bundle = _map(rawRoot['bundle']);
    final routerDecision = _map(bundle['routerDecision']);
    final decisionSource = json.isNotEmpty ? json : routerDecision;
    return PresentTenseRetrievalDebug(
      centralCards: _cardIds(
        decisionSource['centralCards'] ?? routerDecision['centralCards'],
      ),
      supportingCards: _cardIds(
        decisionSource['supportingCards'] ?? routerDecision['supportingCards'],
      ),
      fallback:
          _bool(decisionSource['fallback']) ??
          _routerFallback(routerDecision) ??
          false,
    );
  }
}

class PresentTenseDiagnosisException implements Exception {
  final String message;

  const PresentTenseDiagnosisException(this.message);

  @override
  String toString() => 'PresentTenseDiagnosisException: $message';
}

Map<String, dynamic> _asMap(Object? raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return raw.cast<String, dynamic>();
  throw const PresentTenseDiagnosisException(
    'Unexpected diagnosis response shape',
  );
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

List<String> _cardIds(Object? raw) {
  final ids = <String>[];
  for (final item in _list(raw)) {
    if (item is String && item.trim().isNotEmpty) {
      ids.add(item.trim());
      continue;
    }
    final map = _map(item);
    final id = _string(map['cardId'] ?? map['card_id'] ?? map['id']).trim();
    if (id.isNotEmpty) ids.add(id);
  }
  return ids;
}

String _string(Object? raw) => raw is String ? raw : '';

bool? _bool(Object? raw) {
  if (raw is bool) return raw;
  if (raw is String) {
    final value = raw.trim().toLowerCase();
    if (value == 'true') return true;
    if (value == 'false') return false;
  }
  return null;
}

bool? _routerFallback(Map<String, dynamic> routerDecision) {
  final gateDecision = _string(routerDecision['gateDecision']);
  final routeMode = _string(routerDecision['routeMode']);
  if (gateDecision == 'fallback' || routeMode == 'needs_llm_router') {
    return true;
  }
  if (gateDecision.isNotEmpty || routeMode.isNotEmpty) {
    return false;
  }
  return null;
}
