import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/word_audio_repair_service.dart';
import '../../../core/services/word_audio_server_replace_service.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/repositories.dart';

final wordAudioServerReplaceJobProvider =
    StateNotifierProvider<
      WordAudioServerReplaceJobController,
      WordAudioServerReplaceJobState
    >((ref) => WordAudioServerReplaceJobController(ref));

enum WordAudioServerReplaceJobStage {
  idle,
  preparingReplacement,
  replacementReady,
  alreadyPublished,
  replacing,
  replacementSucceeded,
  preparingRollback,
  rollbackReady,
  rollingBack,
  rollbackSucceeded,
  interactiveSudoRequired,
  interactivePublisherOpened,
  checkingInteractiveResult,
  failed,
  unsupported,
}

enum WordAudioServerReplaceNotice { interactiveNotCompleted }

class WordAudioServerReplaceJobState {
  final WordAudioServerReplaceJobStage stage;
  final WordAudioServerReplacementPlan? replacementPlan;
  final WordAudioServerRollbackPlan? rollbackPlan;
  final WordAudioServerOperationResult? result;
  final WordAudioServerOperationAction? interactiveAction;
  final WordAudioServerReplaceFailure? failure;
  final WordAudioServerReplaceNotice? notice;
  final String? diagnosticOutput;

  const WordAudioServerReplaceJobState({
    this.stage = WordAudioServerReplaceJobStage.idle,
    this.replacementPlan,
    this.rollbackPlan,
    this.result,
    this.interactiveAction,
    this.failure,
    this.notice,
    this.diagnosticOutput,
  });

  bool get isBusy =>
      stage == WordAudioServerReplaceJobStage.preparingReplacement ||
      stage == WordAudioServerReplaceJobStage.replacing ||
      stage == WordAudioServerReplaceJobStage.preparingRollback ||
      stage == WordAudioServerReplaceJobStage.rollingBack ||
      stage == WordAudioServerReplaceJobStage.checkingInteractiveResult;

  WordAudioServerReplaceJobState copyWith({
    WordAudioServerReplaceJobStage? stage,
    WordAudioServerReplacementPlan? replacementPlan,
    bool clearReplacementPlan = false,
    WordAudioServerRollbackPlan? rollbackPlan,
    bool clearRollbackPlan = false,
    WordAudioServerOperationResult? result,
    bool clearResult = false,
    WordAudioServerOperationAction? interactiveAction,
    bool clearInteractiveAction = false,
    WordAudioServerReplaceFailure? failure,
    bool clearFailure = false,
    WordAudioServerReplaceNotice? notice,
    bool clearNotice = false,
    String? diagnosticOutput,
    bool clearDiagnosticOutput = false,
  }) {
    return WordAudioServerReplaceJobState(
      stage: stage ?? this.stage,
      replacementPlan: clearReplacementPlan
          ? null
          : replacementPlan ?? this.replacementPlan,
      rollbackPlan: clearRollbackPlan
          ? null
          : rollbackPlan ?? this.rollbackPlan,
      result: clearResult ? null : result ?? this.result,
      interactiveAction: clearInteractiveAction
          ? null
          : interactiveAction ?? this.interactiveAction,
      failure: clearFailure ? null : failure ?? this.failure,
      notice: clearNotice ? null : notice ?? this.notice,
      diagnosticOutput: clearDiagnosticOutput
          ? null
          : diagnosticOutput ?? this.diagnosticOutput,
    );
  }
}

class WordAudioServerReplaceJobController
    extends StateNotifier<WordAudioServerReplaceJobState> {
  WordAudioServerReplaceJobController(this._ref)
    : super(const WordAudioServerReplaceJobState());

  final Ref _ref;

  Future<void> prepareReplacement(WordAudioRepairPlan repairPlan) async {
    if (state.isBusy) return;
    state = state.copyWith(
      stage: WordAudioServerReplaceJobStage.preparingReplacement,
      clearReplacementPlan: true,
      clearRollbackPlan: true,
      clearResult: true,
      clearInteractiveAction: true,
      clearFailure: true,
      clearNotice: true,
      clearDiagnosticOutput: true,
    );
    try {
      final plan = await _service().createReplacementPlan(
        repairPlan: repairPlan,
        remoteBaseUrl: await _loadRemoteBaseUrl(),
      );
      if (mounted) {
        state = state.copyWith(
          stage: plan.isAlreadyPublished
              ? WordAudioServerReplaceJobStage.alreadyPublished
              : WordAudioServerReplaceJobStage.replacementReady,
          replacementPlan: plan,
          clearFailure: true,
        );
      }
    } catch (error) {
      _setFailure(error);
    }
  }

  Future<void> replace() async {
    final plan = state.replacementPlan;
    if (plan == null || state.isBusy || plan.isAlreadyPublished) return;
    state = state.copyWith(
      stage: WordAudioServerReplaceJobStage.replacing,
      clearResult: true,
      clearInteractiveAction: true,
      clearFailure: true,
      clearNotice: true,
      clearDiagnosticOutput: true,
    );
    try {
      final result = await _service().replace(plan);
      if (!mounted) return;
      if (result.outcome ==
          WordAudioServerOperationOutcome.interactiveSudoRequired) {
        state = state.copyWith(
          stage: WordAudioServerReplaceJobStage.interactiveSudoRequired,
          result: result,
          interactiveAction: WordAudioServerOperationAction.replace,
          diagnosticOutput: _diagnosticForResult(result),
          clearFailure: true,
        );
      } else {
        state = state.copyWith(
          stage: WordAudioServerReplaceJobStage.replacementSucceeded,
          result: result,
          diagnosticOutput: _diagnosticForResult(result),
          clearInteractiveAction: true,
          clearFailure: true,
        );
      }
    } catch (error) {
      _setFailure(error);
    }
  }

  Future<void> prepareRollback({
    required String word,
    required String language,
  }) async {
    if (state.isBusy) return;
    state = state.copyWith(
      stage: WordAudioServerReplaceJobStage.preparingRollback,
      clearRollbackPlan: true,
      clearResult: true,
      clearInteractiveAction: true,
      clearFailure: true,
      clearNotice: true,
      clearDiagnosticOutput: true,
    );
    try {
      final plan = await _service().createRollbackPlan(
        word: word,
        language: language,
        remoteBaseUrl: await _loadRemoteBaseUrl(),
      );
      if (mounted) {
        state = state.copyWith(
          stage: WordAudioServerReplaceJobStage.rollbackReady,
          rollbackPlan: plan,
          clearFailure: true,
        );
      }
    } catch (error) {
      _setFailure(error);
    }
  }

  Future<void> rollback() async {
    final plan = state.rollbackPlan;
    if (plan == null || state.isBusy) return;
    state = state.copyWith(
      stage: WordAudioServerReplaceJobStage.rollingBack,
      clearResult: true,
      clearInteractiveAction: true,
      clearFailure: true,
      clearNotice: true,
      clearDiagnosticOutput: true,
    );
    try {
      final result = await _service().rollback(plan);
      if (!mounted) return;
      if (result.outcome ==
          WordAudioServerOperationOutcome.interactiveSudoRequired) {
        state = state.copyWith(
          stage: WordAudioServerReplaceJobStage.interactiveSudoRequired,
          result: result,
          interactiveAction: WordAudioServerOperationAction.rollback,
          diagnosticOutput: _diagnosticForResult(result),
          clearFailure: true,
        );
      } else {
        state = state.copyWith(
          stage: WordAudioServerReplaceJobStage.rollbackSucceeded,
          result: result,
          diagnosticOutput: _diagnosticForResult(result),
          clearInteractiveAction: true,
          clearFailure: true,
        );
      }
    } catch (error) {
      _setFailure(error);
    }
  }

  Future<void> openInteractivePublisher() async {
    if (state.stage != WordAudioServerReplaceJobStage.interactiveSudoRequired ||
        state.isBusy) {
      return;
    }
    final action = state.interactiveAction;
    if (action == null) return;
    try {
      if (action == WordAudioServerOperationAction.replace) {
        final plan = state.replacementPlan;
        if (plan == null) return;
        await _service().openInteractiveReplacement(plan);
      } else {
        final plan = state.rollbackPlan;
        if (plan == null) return;
        await _service().openInteractiveRollback(plan);
      }
      if (mounted) {
        state = state.copyWith(
          stage: WordAudioServerReplaceJobStage.interactivePublisherOpened,
          clearFailure: true,
          clearNotice: true,
        );
      }
    } catch (error) {
      _setFailure(error);
    }
  }

  Future<void> confirmInteractiveResult() async {
    if (state.stage !=
            WordAudioServerReplaceJobStage.interactivePublisherOpened ||
        state.isBusy) {
      return;
    }
    final action = state.interactiveAction;
    if (action == null) return;
    state = state.copyWith(
      stage: WordAudioServerReplaceJobStage.checkingInteractiveResult,
      clearFailure: true,
      clearNotice: true,
      clearDiagnosticOutput: true,
    );
    try {
      final result = action == WordAudioServerOperationAction.replace
          ? await _confirmInteractiveReplacement()
          : await _confirmInteractiveRollback();
      if (!mounted) return;
      if (result == null) {
        state = state.copyWith(
          stage: action == WordAudioServerOperationAction.replace
              ? WordAudioServerReplaceJobStage.replacementReady
              : WordAudioServerReplaceJobStage.rollbackReady,
          clearInteractiveAction: true,
          notice: WordAudioServerReplaceNotice.interactiveNotCompleted,
          clearFailure: true,
        );
        return;
      }
      state = state.copyWith(
        stage: action == WordAudioServerOperationAction.replace
            ? WordAudioServerReplaceJobStage.replacementSucceeded
            : WordAudioServerReplaceJobStage.rollbackSucceeded,
        result: result,
        clearInteractiveAction: true,
        clearFailure: true,
      );
    } catch (error) {
      _setFailure(error);
    }
  }

  Future<WordAudioServerOperationResult?> _confirmInteractiveReplacement() {
    final plan = state.replacementPlan;
    if (plan == null) return Future.value(null);
    return _service().confirmReplacementAfterInteractive(plan);
  }

  Future<WordAudioServerOperationResult?> _confirmInteractiveRollback() {
    final plan = state.rollbackPlan;
    if (plan == null) return Future.value(null);
    return _service().confirmRollbackAfterInteractive(plan);
  }

  void reset() {
    if (state.isBusy) return;
    state = const WordAudioServerReplaceJobState();
  }

  WordAudioServerReplaceService _service() => WordAudioServerReplaceService();

  Future<String> _loadRemoteBaseUrl() async {
    return (await _ref
                .read(settingsRepositoryProvider)
                .getString(SettingsRepository.keyRemoteWordAudioBaseUrl))
            ?.trim() ??
        '';
  }

  String? _diagnosticForResult(WordAudioServerOperationResult result) {
    final diagnostic = result.publisher?.diagnosticOutput;
    return diagnostic == null || diagnostic.isEmpty ? null : diagnostic;
  }

  void _setFailure(Object error) {
    final failure = error is WordAudioServerReplaceException
        ? error.failure
        : WordAudioServerReplaceFailure.unknown;
    final diagnostic = error is WordAudioServerReplaceException
        ? error.safeDiagnosticOutput
        : null;
    if (mounted) {
      state = state.copyWith(
        stage: failure == WordAudioServerReplaceFailure.unsupportedPlatform
            ? WordAudioServerReplaceJobStage.unsupported
            : WordAudioServerReplaceJobStage.failed,
        clearInteractiveAction: true,
        failure: failure,
        clearNotice: true,
        diagnosticOutput: diagnostic,
      );
    }
  }
}
