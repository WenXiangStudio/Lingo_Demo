import '../../../../data/diagnosis/present_tense_diagnosis_client.dart';

class DiagnosisLabRecord {
  final String id;
  final String question;
  final String answer;
  final Map<String, dynamic> diagnosisJson;
  final List<String> centralCards;
  final List<String> supportingCards;
  final bool fallback;
  final DateTime createdAt;
  final DiagnosisLabRating? manualRating;

  const DiagnosisLabRecord({
    required this.id,
    required this.question,
    required this.answer,
    required this.diagnosisJson,
    required this.centralCards,
    required this.supportingCards,
    required this.fallback,
    required this.createdAt,
    required this.manualRating,
  });

  factory DiagnosisLabRecord.fromResult({
    required String id,
    required PresentTenseDiagnosisResult result,
    required DateTime createdAt,
  }) {
    return DiagnosisLabRecord(
      id: id,
      question: result.question,
      answer: result.answer,
      diagnosisJson: result.raw,
      centralCards: result.retrieval.centralCards,
      supportingCards: result.retrieval.supportingCards,
      fallback: result.retrieval.fallback,
      createdAt: createdAt,
      manualRating: null,
    );
  }

  factory DiagnosisLabRecord.fromJson(Map<String, dynamic> json) {
    return DiagnosisLabRecord(
      id: _string(json['id']),
      question: _string(json['question']),
      answer: _string(json['answer']),
      diagnosisJson: _map(json['diagnosisJson']),
      centralCards: _stringList(json['centralCards']),
      supportingCards: _stringList(json['supportingCards']),
      fallback: _bool(json['fallback']) ?? false,
      createdAt:
          DateTime.tryParse(_string(json['createdAt'])) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      manualRating: DiagnosisLabRatingX.tryParse(_string(json['manualRating'])),
    );
  }

  DiagnosisLabRecord copyWith({DiagnosisLabRating? manualRating}) {
    return DiagnosisLabRecord(
      id: id,
      question: question,
      answer: answer,
      diagnosisJson: diagnosisJson,
      centralCards: centralCards,
      supportingCards: supportingCards,
      fallback: fallback,
      createdAt: createdAt,
      manualRating: manualRating ?? this.manualRating,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'diagnosisJson': diagnosisJson,
      'centralCards': centralCards,
      'supportingCards': supportingCards,
      'fallback': fallback,
      'createdAt': createdAt.toIso8601String(),
      'manualRating': manualRating?.name,
    };
  }
}

enum DiagnosisLabRating { good, acceptable, failed }

extension DiagnosisLabRatingX on DiagnosisLabRating {
  static DiagnosisLabRating? tryParse(String value) {
    for (final rating in DiagnosisLabRating.values) {
      if (rating.name == value) return rating;
    }
    return null;
  }
}

Map<String, dynamic> _map(Object? raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return raw.cast<String, dynamic>();
  return const <String, dynamic>{};
}

List<String> _stringList(Object? raw) {
  if (raw is! List) return const [];
  return [
    for (final item in raw)
      if (item is String && item.trim().isNotEmpty) item.trim(),
  ];
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
