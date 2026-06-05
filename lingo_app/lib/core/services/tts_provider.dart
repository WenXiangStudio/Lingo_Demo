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
  /// Returns raw audio bytes (MP3 format).
  Future<Uint8List> synthesize(String text, {String language = 'en'});
}

abstract class MeteredTtsProvider implements TtsProvider {
  Future<TtsSynthesisResult> synthesizeWithMetadata(
    String text, {
    String language = 'en',
  });
}

enum TtsProviderType {
  supertonic,
  openai,
  azure,
  qwen,
  doubao,
  sapi;

  String get displayName {
    switch (this) {
      case TtsProviderType.supertonic:
        return 'Supertonic 3 (on-device)';
      case TtsProviderType.openai:
        return 'OpenAI TTS';
      case TtsProviderType.azure:
        return 'Azure TTS';
      case TtsProviderType.qwen:
        return 'Qwen3 TTS (cloud)';
      case TtsProviderType.doubao:
        return 'Doubao TTS (cloud)';
      case TtsProviderType.sapi:
        return 'Windows SAPI';
    }
  }

  static TtsProviderType fromString(String s) {
    return TtsProviderType.values.firstWhere(
      (t) => t.name == s,
      orElse: () => TtsProviderType.sapi,
    );
  }
}
