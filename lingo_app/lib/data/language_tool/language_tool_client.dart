import 'package:dio/dio.dart';

class LanguageToolClient {
  static const defaultBaseUrl = 'https://api.languagetool.org';

  final Dio _dio;

  LanguageToolClient({String baseUrl = defaultBaseUrl, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: normalizeBaseUrl(baseUrl),
              connectTimeout: const Duration(seconds: 4),
              receiveTimeout: const Duration(seconds: 8),
            ),
          );

  static String normalizeBaseUrl(String value) {
    var normalized = value.trim();
    if (normalized.isEmpty) return defaultBaseUrl;
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    if (normalized.endsWith('/v2/check')) {
      normalized = normalized.substring(0, normalized.length - 9);
    }
    if (normalized.endsWith('/v2')) {
      normalized = normalized.substring(0, normalized.length - 3);
    }
    return normalized.isEmpty ? defaultBaseUrl : normalized;
  }

  Future<LanguageToolResult> check(
    String text, {
    String language = 'en-US',
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return const LanguageToolResult(matches: []);
    }

    final response = await _dio.post(
      '/v2/check',
      data: {'text': trimmed, 'language': language, 'enabledOnly': 'false'},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    return LanguageToolResult.fromJson(_asMap(response.data));
  }
}

class LanguageToolResult {
  final List<LanguageToolMatch> matches;
  final String? errorMessage;

  const LanguageToolResult({required this.matches, this.errorMessage});

  const LanguageToolResult.failed(String message)
    : matches = const [],
      errorMessage = message;

  bool get checked => errorMessage == null;

  bool get hasMatches => matches.isNotEmpty;

  factory LanguageToolResult.fromJson(Map<String, dynamic> json) {
    return LanguageToolResult(
      matches: _list(json['matches'])
          .map((item) => LanguageToolMatch.fromJson(_asMap(item)))
          .where((match) => match.message.isNotEmpty)
          .toList(growable: false),
    );
  }

  String toPromptContext(String sourceText, {int maxMatches = 5}) {
    if (!checked || matches.isEmpty) return '';
    final lines = <String>[
      'LanguageTool check for the user reply:',
      'Original reply: "$sourceText"',
      for (final match in matches.take(maxMatches)) match.toPromptLine(),
    ];
    return lines.join('\n');
  }
}

class LanguageToolMatch {
  final String message;
  final String shortMessage;
  final int offset;
  final int length;
  final String sentence;
  final String contextText;
  final int contextOffset;
  final int contextLength;
  final String ruleId;
  final String ruleDescription;
  final String issueType;
  final String categoryName;
  final List<String> replacements;

  const LanguageToolMatch({
    required this.message,
    required this.shortMessage,
    required this.offset,
    required this.length,
    required this.sentence,
    required this.contextText,
    required this.contextOffset,
    required this.contextLength,
    required this.ruleId,
    required this.ruleDescription,
    required this.issueType,
    required this.categoryName,
    required this.replacements,
  });

  factory LanguageToolMatch.fromJson(Map<String, dynamic> json) {
    final context = _map(json['context']);
    final rule = _map(json['rule']);
    final category = _map(rule['category']);
    return LanguageToolMatch(
      message: _string(json['message']),
      shortMessage: _string(json['shortMessage']),
      offset: _int(json['offset']),
      length: _int(json['length']),
      sentence: _string(json['sentence']),
      contextText: _string(context['text']),
      contextOffset: _int(context['offset']),
      contextLength: _int(context['length']),
      ruleId: _string(rule['id']),
      ruleDescription: _string(rule['description']),
      issueType: _string(rule['issueType']),
      categoryName: _string(category['name']),
      replacements: _list(json['replacements'])
          .map((item) => _string(_map(item)['value']).trim())
          .where((value) => value.isNotEmpty)
          .take(5)
          .toList(growable: false),
    );
  }

  String get issueText {
    if (contextText.isEmpty || contextLength <= 0) return '';
    final start = contextOffset.clamp(0, contextText.length);
    final end = (start + contextLength).clamp(start, contextText.length);
    return contextText.substring(start, end);
  }

  String get displayMessage => shortMessage.isNotEmpty ? shortMessage : message;

  String toPromptLine() {
    final buffer = StringBuffer('- ');
    final issue = issueText;
    if (issue.isNotEmpty) {
      buffer.write('"$issue": ');
    }
    buffer.write(message);
    if (replacements.isNotEmpty) {
      buffer.write(' Suggested replacement(s): ${replacements.join(', ')}.');
    }
    if (categoryName.isNotEmpty) {
      buffer.write(' Category: $categoryName.');
    }
    return buffer.toString();
  }
}

Map<String, dynamic> _asMap(Object? raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return raw.cast<String, dynamic>();
  return const <String, dynamic>{};
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

int _int(Object? raw) => raw is num ? raw.toInt() : 0;
