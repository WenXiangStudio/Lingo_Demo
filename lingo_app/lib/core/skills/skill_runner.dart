import 'skill_definition.dart';
import 'skill_handler.dart';
import 'skill_registry.dart';

class SkillRunner {
  final SkillRegistry _registry;
  bool _cancelRequested = false;

  SkillRunner(this._registry);

  Future<SkillRunResult> run(
    String skillId,
    Map<String, Object?> inputs, {
    SkillProgressCallback? onProgress,
  }) async {
    _cancelRequested = false;
    final skill = _registry.getSkill(skillId);
    if (skill == null) {
      throw const SkillException('skill_error_unknown_skill');
    }
    _validateInputs(skill, inputs);

    final handler = _registry.getHandler(skill.handlerKey);
    if (handler == null) {
      throw const SkillException('skill_error_missing_handler');
    }

    return handler.run(
      inputs,
      SkillRunContext(
        onProgress: onProgress ?? (_) {},
        isCancelled: () => _cancelRequested,
      ),
    );
  }

  void cancel() {
    _cancelRequested = true;
  }

  static void _validateInputs(LingoSkill skill, Map<String, Object?> inputs) {
    for (final spec in skill.inputs) {
      final value = inputs[spec.id];
      if (spec.required && value == null) {
        throw const SkillException('skill_error_required_input');
      }
      if (value == null) continue;
      switch (spec.type) {
        case SkillInputType.wordList:
          if (value is! int) {
            throw const SkillException('skill_error_invalid_input');
          }
          break;
        case SkillInputType.integer:
          if (value is! int) {
            throw const SkillException('skill_error_invalid_input');
          }
          if (spec.min != null && value < spec.min!) {
            throw const SkillException('skill_error_invalid_input');
          }
          if (spec.max != null && value > spec.max!) {
            throw const SkillException('skill_error_invalid_input');
          }
          break;
      }
    }
  }
}
