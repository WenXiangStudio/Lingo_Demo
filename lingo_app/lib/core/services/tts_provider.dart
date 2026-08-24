import 'dart:typed_data';

class TtsSynthesisResult {
  final Uint8List audioBytes;
  final int? chargedCharacters;
  final String? requestId;
  final String? logId;
  final int durationMs;

  const TtsSynthesisResult({
    required this.audioBytes,
    this.chargedCharacters,
    this.requestId,
    this.logId,
    required this.durationMs,
  });
}

class TtsSpeakResult {
  final String provider;
  final String source;
  final bool played;
  final String? message;

  const TtsSpeakResult({
    required this.provider,
    required this.source,
    required this.played,
    this.message,
  });
}

abstract class TtsProvider {
  String get providerName;

  /// Generate speech audio for [text] in the given [language].
  /// Returns encoded audio bytes in the provider's configured format.
  Future<Uint8List> synthesize(String text, {String language = 'en'});
}

abstract class MeteredTtsProvider implements TtsProvider {
  Future<TtsSynthesisResult> synthesizeWithMetadata(
    String text, {
    String language = 'en',
  });
}
