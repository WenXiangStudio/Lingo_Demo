import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/tts_providers.dart';
import '../../../data/providers.dart';
import '../models/speaking_models.dart';
import '../services/speaking_alignment.dart';
import '../services/speaking_asr_model_manager.dart';
import '../services/speaking_asr_service.dart';
import '../services/speaking_recording_service.dart';

final speakingAsrModelManagerProvider = Provider<SpeakingAsrModelManager>((
  ref,
) {
  final manager = SpeakingAsrModelManager();
  ref.onDispose(manager.dispose);
  return manager;
});

final speakingAsrModelStateProvider = StreamProvider<SpeakingAsrModelState>((
  ref,
) {
  final manager = ref.watch(speakingAsrModelManagerProvider);
  Future.microtask(manager.checkStatus);
  return manager.stateStream;
});

final speakingRecordingServiceProvider = Provider<SpeakingRecordingService>((
  ref,
) {
  final service = SpeakingRecordingService();
  ref.onDispose(service.dispose);
  return service;
});

final speakingAsrServiceProvider = Provider<SpeakingAsrService>((ref) {
  return SpeakingAsrService(ref.watch(speakingAsrModelManagerProvider));
});

final speakingProvider = StateNotifierProvider<SpeakingNotifier, SpeakingState>(
  (ref) {
    return SpeakingNotifier(ref);
  },
);

class SpeakingNotifier extends StateNotifier<SpeakingState> {
  SpeakingNotifier(this._ref) : super(const SpeakingState());

  final Ref _ref;

  Future<void> init(int listId) async {
    state = SpeakingState(phase: SpeakingPhase.loading, listId: listId);
    try {
      final repo = _ref.read(wordListRepositoryProvider);
      final words = await repo.getWordsForList(listId);
      final prompts = [
        for (final word in words)
          if (word.scenarioExample != null &&
              word.scenarioExample!.trim().isNotEmpty)
            SpeakingPrompt(
              word: word,
              referenceText: word.scenarioExample!.trim(),
            ),
      ];

      state = state.copyWith(
        phase: prompts.isEmpty ? SpeakingPhase.error : SpeakingPhase.ready,
        prompts: prompts,
        currentIndex: 0,
        currentTranscript: '',
        error: prompts.isEmpty ? 'no_speaking_prompts' : null,
        clearError: prompts.isNotEmpty,
        clearActionError: true,
        clearCurrentAudioPath: true,
      );
    } catch (e) {
      state = state.copyWith(phase: SpeakingPhase.error, error: e.toString());
    }
  }

  void updateTranscript(String value) {
    state = state.copyWith(currentTranscript: value, clearActionError: true);
  }

  void assessCurrentTranscript() {
    final prompt = state.currentPrompt;
    if (prompt == null || state.currentTranscript.trim().isEmpty) return;

    final result = SpeakingAlignment.assess(
      referenceText: prompt.referenceText,
      transcript: state.currentTranscript,
    );

    state = state.copyWith(
      phase: SpeakingPhase.feedback,
      results: [...state.results, result],
      clearActionError: true,
    );
  }

  Future<void> startRecording() async {
    final prompt = state.currentPrompt;
    if (prompt == null ||
        state.phase == SpeakingPhase.recording ||
        state.phase == SpeakingPhase.recognizing) {
      return;
    }

    try {
      await _ref.read(ttsServiceProvider).stop();
      final recorder = _ref.read(speakingRecordingServiceProvider);
      final path = await recorder.start();
      state = state.copyWith(
        phase: SpeakingPhase.recording,
        currentTranscript: '',
        currentAudioPath: path,
        clearActionError: true,
      );
    } catch (e) {
      state = state.copyWith(
        phase: SpeakingPhase.ready,
        actionError: _errorCode(e),
      );
    }
  }

  Future<void> stopRecordingAndAssess({String language = 'en'}) async {
    if (state.phase != SpeakingPhase.recording) return;

    final recorder = _ref.read(speakingRecordingServiceProvider);
    state = state.copyWith(
      phase: SpeakingPhase.recognizing,
      clearActionError: true,
    );

    try {
      final recordedPath = await recorder.stop();
      final wavPath = recordedPath ?? state.currentAudioPath;
      if (wavPath == null || wavPath.trim().isEmpty) {
        throw const SpeakingRecordingException('speaking_recording_failed');
      }

      final transcript = await _ref
          .read(speakingAsrServiceProvider)
          .transcribe(wavPath: wavPath, language: language);

      if (transcript.trim().isEmpty) {
        throw const SpeakingAsrException('asr_empty_transcript');
      }

      state = state.copyWith(
        phase: SpeakingPhase.ready,
        currentTranscript: transcript,
        currentAudioPath: wavPath,
        clearActionError: true,
      );
      assessCurrentTranscript();
    } catch (e) {
      state = state.copyWith(
        phase: SpeakingPhase.ready,
        actionError: _errorCode(e),
      );
    }
  }

  Future<void> cancelRecording() async {
    if (state.phase != SpeakingPhase.recording) return;
    await _ref.read(speakingRecordingServiceProvider).cancel();
    state = state.copyWith(
      phase: SpeakingPhase.ready,
      clearCurrentAudioPath: true,
    );
  }

  void nextPrompt() {
    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.prompts.length) {
      state = state.copyWith(
        phase: SpeakingPhase.finished,
        currentTranscript: '',
      );
      return;
    }
    state = state.copyWith(
      phase: SpeakingPhase.ready,
      currentIndex: nextIndex,
      currentTranscript: '',
      clearActionError: true,
      clearCurrentAudioPath: true,
    );
  }

  void reset() {
    state = const SpeakingState();
  }

  String _errorCode(Object error) {
    if (error is SpeakingRecordingException) return error.code;
    if (error is SpeakingAsrException) return error.code;
    if (error is SpeakingAsrModelException) return error.code;
    return error.toString();
  }
}
