/// Sealed class hierarchy representing the state of the TTS model download.
sealed class TtsModelState {}

class TtsModelNotDownloaded extends TtsModelState {}

class TtsModelDownloading extends TtsModelState {
  final double progress; // 0.0 to 1.0
  TtsModelDownloading(this.progress);
}

class TtsModelReady extends TtsModelState {
  final String modelDir;
  TtsModelReady(this.modelDir);
}

class TtsModelError extends TtsModelState {
  final String message;
  TtsModelError(this.message);
}
