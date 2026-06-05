import 'package:sherpa_onnx/sherpa_onnx.dart';

import 'speaking_asr_model_manager.dart';

class SpeakingAsrService {
  const SpeakingAsrService(this._modelManager);

  final SpeakingAsrModelManager _modelManager;

  Future<String> transcribe({
    required String wavPath,
    String language = 'en',
  }) async {
    if (!await _modelManager.isModelReady()) {
      throw const SpeakingAsrException('asr_model_not_downloaded');
    }

    final dir = await _modelManager.modelDir;
    final wave = readWave(wavPath);
    if (wave.samples.isEmpty || wave.sampleRate <= 0) {
      throw const SpeakingAsrException('asr_empty_audio');
    }

    final recognizer = OfflineRecognizer(
      OfflineRecognizerConfig(
        model: OfflineModelConfig(
          senseVoice: OfflineSenseVoiceModelConfig(
            model: '$dir/model.int8.onnx',
            language: _senseVoiceLanguage(language),
            useInverseTextNormalization: true,
          ),
          tokens: '$dir/tokens.txt',
          numThreads: 2,
          provider: 'cpu',
          modelingUnit: 'cjkchar',
        ),
      ),
    );

    OfflineStream? stream;
    try {
      stream = recognizer.createStream();
      stream.acceptWaveform(samples: wave.samples, sampleRate: wave.sampleRate);
      recognizer.decode(stream);
      final result = recognizer.getResult(stream);
      return _cleanTranscript(result.text);
    } finally {
      stream?.free();
      recognizer.free();
    }
  }

  static String _senseVoiceLanguage(String language) {
    final normalized = language.trim().toLowerCase();
    if (normalized.isEmpty) return 'en';
    final primary = normalized.split(RegExp(r'[-_]')).first;
    return switch (primary) {
      'zh' || 'cmn' => 'zh',
      'ja' => 'ja',
      'ko' => 'ko',
      'yue' => 'yue',
      _ => 'en',
    };
  }

  static String _cleanTranscript(String text) {
    return text
        .replaceAll(RegExp(r'<\|[^>]+?\|>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class SpeakingAsrException implements Exception {
  const SpeakingAsrException(this.code);

  final String code;

  @override
  String toString() => code;
}
