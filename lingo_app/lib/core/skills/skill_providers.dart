import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import 'handlers/review_plan_skill_handler.dart';
import 'handlers/word_story_skill_handler.dart';
import 'skill_definition.dart';
import 'skill_handler.dart';
import 'skill_registry.dart';
import 'skill_runner.dart';

final skillRegistryProvider = Provider<SkillRegistry>((ref) {
  return SkillRegistry(
    skills: builtInSkills,
    handlers: {
      'word_story': WordStorySkillHandler(
        wordListRepository: ref.watch(wordListRepositoryProvider),
        settingsRepository: ref.watch(settingsRepositoryProvider),
      ),
      'review_plan': ReviewPlanSkillHandler(
        wordListRepository: ref.watch(wordListRepositoryProvider),
        practiceRepository: ref.watch(practiceRepositoryProvider),
      ),
    },
  );
});

final skillRunnerProvider = Provider<SkillRunner>((ref) {
  return SkillRunner(ref.watch(skillRegistryProvider));
});

enum SkillRunPhase { idle, running, complete, error, cancelled }

class SkillRunState {
  final SkillRunPhase phase;
  final String? runningSkillId;
  final SkillRunProgress? progress;
  final SkillRunResult? result;
  final String? errorKey;
  final Map<String, String> errorParams;
  final String? rawError;

  const SkillRunState({
    this.phase = SkillRunPhase.idle,
    this.runningSkillId,
    this.progress,
    this.result,
    this.errorKey,
    this.errorParams = const {},
    this.rawError,
  });

  SkillRunState copyWith({
    SkillRunPhase? phase,
    String? runningSkillId,
    SkillRunProgress? progress,
    SkillRunResult? result,
    String? errorKey,
    Map<String, String>? errorParams,
    String? rawError,
    bool clearError = false,
  }) {
    return SkillRunState(
      phase: phase ?? this.phase,
      runningSkillId: runningSkillId ?? this.runningSkillId,
      progress: progress ?? this.progress,
      result: result ?? this.result,
      errorKey: clearError ? null : (errorKey ?? this.errorKey),
      errorParams: clearError ? const {} : (errorParams ?? this.errorParams),
      rawError: clearError ? null : (rawError ?? this.rawError),
    );
  }
}

final skillRunControllerProvider =
    StateNotifierProvider<SkillRunController, SkillRunState>((ref) {
      return SkillRunController(ref);
    });

class SkillRunController extends StateNotifier<SkillRunState> {
  final Ref _ref;

  SkillRunController(this._ref) : super(const SkillRunState());

  Future<void> runSkill(String skillId, Map<String, Object?> inputs) async {
    if (state.phase == SkillRunPhase.running) return;

    state = SkillRunState(
      phase: SkillRunPhase.running,
      runningSkillId: skillId,
      progress: const SkillRunProgress(messageKey: 'skill_progress_starting'),
    );

    try {
      final runner = _ref.read(skillRunnerProvider);
      final result = await runner.run(
        skillId,
        inputs,
        onProgress: (progress) {
          if (!mounted) return;
          state = state.copyWith(progress: progress);
        },
      );
      if (!mounted) return;
      state = SkillRunState(
        phase: SkillRunPhase.complete,
        runningSkillId: skillId,
        result: result,
      );
    } on SkillCancelledException {
      if (!mounted) return;
      state = const SkillRunState(
        phase: SkillRunPhase.cancelled,
        runningSkillId: null,
        errorKey: 'skill_run_cancelled',
      );
    } on SkillException catch (e) {
      if (!mounted) return;
      state = SkillRunState(
        phase: SkillRunPhase.error,
        runningSkillId: skillId,
        errorKey: e.messageKey,
        errorParams: e.params,
      );
    } catch (e) {
      if (!mounted) return;
      state = SkillRunState(
        phase: SkillRunPhase.error,
        runningSkillId: skillId,
        errorKey: 'skill_run_failed',
        rawError: e.toString(),
      );
    }
  }

  void cancel() {
    _ref.read(skillRunnerProvider).cancel();
  }

  void reset() {
    if (state.phase == SkillRunPhase.running) {
      cancel();
    }
    state = const SkillRunState();
  }
}
