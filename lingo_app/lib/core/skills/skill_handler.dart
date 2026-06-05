import 'skill_definition.dart';

typedef SkillProgressCallback = void Function(SkillRunProgress progress);

class SkillRunContext {
  final SkillProgressCallback onProgress;
  final bool Function() isCancelled;

  const SkillRunContext({required this.onProgress, required this.isCancelled});

  void throwIfCancelled() {
    if (isCancelled()) {
      throw const SkillCancelledException();
    }
  }
}

abstract class SkillHandler {
  Future<SkillRunResult> run(
    Map<String, Object?> inputs,
    SkillRunContext context,
  );
}

class SkillException implements Exception {
  final String messageKey;
  final Map<String, String> params;

  const SkillException(this.messageKey, {this.params = const {}});

  @override
  String toString() => messageKey;
}

class SkillCancelledException implements Exception {
  const SkillCancelledException();
}
