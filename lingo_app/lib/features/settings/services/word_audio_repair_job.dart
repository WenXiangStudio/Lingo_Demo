import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/word_audio_repair_service.dart';
import '../../../data/providers.dart';

final wordAudioRepairJobProvider =
    StateNotifierProvider<
      WordAudioRepairJobController,
      WordAudioRepairJobState
    >((ref) => WordAudioRepairJobController(ref));

enum WordAudioRepairJobStage {
  idle,
  planning,
  ready,
  generating,
  staged,
  applying,
  applied,
  restoring,
  restored,
  failed,
}

class WordAudioRepairJobState {
  final WordAudioRepairJobStage stage;
  final WordAudioRepairPlan? plan;
  final WordAudioRepairProgress? progress;
  final WordAudioRepairStagedAudio? staged;
  final WordAudioRepairApplyResult? applied;
  final WordAudioRepairRestoreResult? restored;
  final WordAudioRepairFailure? failure;
  final bool cancelRequested;

  const WordAudioRepairJobState({
    this.stage = WordAudioRepairJobStage.idle,
    this.plan,
    this.progress,
    this.staged,
    this.applied,
    this.restored,
    this.failure,
    this.cancelRequested = false,
  });

  bool get isBusy =>
      stage == WordAudioRepairJobStage.planning ||
      stage == WordAudioRepairJobStage.generating ||
      stage == WordAudioRepairJobStage.applying ||
      stage == WordAudioRepairJobStage.restoring;

  bool get canCancel => stage == WordAudioRepairJobStage.generating;

  WordAudioRepairJobState copyWith({
    WordAudioRepairJobStage? stage,
    WordAudioRepairPlan? plan,
    bool clearPlan = false,
    WordAudioRepairProgress? progress,
    bool clearProgress = false,
    WordAudioRepairStagedAudio? staged,
    bool clearStaged = false,
    WordAudioRepairApplyResult? applied,
    bool clearApplied = false,
    WordAudioRepairRestoreResult? restored,
    bool clearRestored = false,
    WordAudioRepairFailure? failure,
    bool clearFailure = false,
    bool? cancelRequested,
  }) {
    return WordAudioRepairJobState(
      stage: stage ?? this.stage,
      plan: clearPlan ? null : plan ?? this.plan,
      progress: clearProgress ? null : progress ?? this.progress,
      staged: clearStaged ? null : staged ?? this.staged,
      applied: clearApplied ? null : applied ?? this.applied,
      restored: clearRestored ? null : restored ?? this.restored,
      failure: clearFailure ? null : failure ?? this.failure,
      cancelRequested: cancelRequested ?? this.cancelRequested,
    );
  }
}

class WordAudioRepairJobController
    extends StateNotifier<WordAudioRepairJobState> {
  WordAudioRepairJobController(this._ref)
    : super(const WordAudioRepairJobState());

  final Ref _ref;
  bool _cancelRequested = false;

  Future<WordAudioRepairPlan?> preparePlan(
    WordAudioRepairRequest request,
  ) async {
    if (state.isBusy || state.staged != null) return null;
    state = state.copyWith(
      stage: WordAudioRepairJobStage.planning,
      clearPlan: true,
      clearProgress: true,
      clearApplied: true,
      clearRestored: true,
      clearFailure: true,
      cancelRequested: false,
    );
    try {
      final plan = await _service().createPlan(request);
      if (mounted) {
        state = state.copyWith(
          stage: WordAudioRepairJobStage.ready,
          plan: plan,
          clearFailure: true,
        );
      }
      return plan;
    } catch (error) {
      _setFailure(error, clearPlan: true);
      return null;
    }
  }

  Future<void> generateStagedAudio() async {
    final plan = state.plan;
    if (plan == null || state.isBusy || state.staged != null) return;
    _cancelRequested = false;
    state = state.copyWith(
      stage: WordAudioRepairJobStage.generating,
      clearProgress: true,
      clearFailure: true,
      cancelRequested: false,
    );
    try {
      final staged = await _service().generateStagedAudio(
        plan,
        await _loadQwenConfig(),
        shouldCancel: () => _cancelRequested,
        onProgress: (progress) {
          if (mounted) {
            state = state.copyWith(progress: progress, clearFailure: true);
          }
        },
      );
      if (mounted) {
        state = state.copyWith(
          stage: WordAudioRepairJobStage.staged,
          staged: staged,
          clearProgress: true,
          clearFailure: true,
          cancelRequested: false,
        );
      }
    } catch (error) {
      _setFailure(error);
    } finally {
      _cancelRequested = false;
    }
  }

  Future<void> applyStagedAudio() async {
    final staged = state.staged;
    if (staged == null || state.isBusy) return;
    state = state.copyWith(
      stage: WordAudioRepairJobStage.applying,
      clearFailure: true,
    );
    try {
      final applied = await _service().applyStagedAudio(staged);
      if (mounted) {
        state = state.copyWith(
          stage: WordAudioRepairJobStage.applied,
          applied: applied,
          clearFailure: true,
        );
      }
    } catch (error) {
      _setFailure(error);
    }
  }

  Future<void> restorePreviousAudio() async {
    final applied = state.applied;
    if (applied == null || state.isBusy) return;
    state = state.copyWith(
      stage: WordAudioRepairJobStage.restoring,
      clearFailure: true,
    );
    try {
      final restored = await _service().restorePreviousAudio(applied);
      if (mounted) {
        state = state.copyWith(
          stage: WordAudioRepairJobStage.restored,
          restored: restored,
          clearFailure: true,
        );
      }
    } catch (error) {
      _setFailure(error);
    }
  }

  Future<void> discardStagedAudio() async {
    final staged = state.staged;
    if (staged == null || state.isBusy) return;
    state = state.copyWith(
      stage: WordAudioRepairJobStage.applying,
      clearFailure: true,
    );
    try {
      await _service().discardStagedAudio(staged);
      if (mounted) {
        state = state.copyWith(
          stage: WordAudioRepairJobStage.ready,
          clearStaged: true,
          clearApplied: true,
          clearRestored: true,
          clearFailure: true,
        );
      }
    } catch (error) {
      _setFailure(error);
    }
  }

  Future<Uint8List?> readCurrentAudio() {
    final plan = state.plan;
    if (plan == null) return Future.value(null);
    return _service().readCurrentAudio(plan);
  }

  void cancel() {
    if (!state.canCancel) return;
    _cancelRequested = true;
    state = state.copyWith(cancelRequested: true);
  }

  void reset() {
    if (state.isBusy) return;
    state = const WordAudioRepairJobState();
  }

  WordAudioRepairService _service() =>
      WordAudioRepairService(ttsRepository: _ref.read(ttsRepositoryProvider));

  Future<WordAudioRepairTtsConfig> _loadQwenConfig() async {
    final repository = _ref.read(settingsRepositoryProvider);
    final values = await Future.wait([
      repository.getString('tts_qwen_api_key'),
      repository.getString('tts_qwen_base_url'),
      repository.getString('tts_qwen_app_id'),
    ]);
    return WordAudioRepairTtsConfig(
      apiKey: values[0]?.trim() ?? '',
      baseUrl: values[1]?.trim() ?? '',
      workspaceId: values[2]?.trim() ?? '',
    );
  }

  void _setFailure(Object error, {bool clearPlan = false}) {
    final failure = error is WordAudioRepairException
        ? error.failure
        : WordAudioRepairFailure.unknown;
    if (mounted) {
      state = state.copyWith(
        stage: WordAudioRepairJobStage.failed,
        clearPlan: clearPlan,
        clearProgress: true,
        failure: failure,
        cancelRequested: false,
      );
    }
  }
}
