enum SkillCategory { ai, review, speaking, tts, maintenance }

enum SkillCapability { ai, database, tts, asr, local, cloud }

enum SkillInputType { wordList, integer }

class SkillInputSpec {
  final String id;
  final String labelKey;
  final SkillInputType type;
  final bool required;
  final int? min;
  final int? max;
  final Object? defaultValue;

  const SkillInputSpec({
    required this.id,
    required this.labelKey,
    required this.type,
    this.required = true,
    this.min,
    this.max,
    this.defaultValue,
  });
}

class LingoSkill {
  final String id;
  final String titleKey;
  final String descriptionKey;
  final SkillCategory category;
  final Set<SkillCapability> capabilities;
  final List<SkillInputSpec> inputs;
  final String handlerKey;
  final bool usesAi;
  final bool usesCloud;

  const LingoSkill({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.category,
    required this.capabilities,
    required this.inputs,
    required this.handlerKey,
    this.usesAi = false,
    this.usesCloud = false,
  });
}

class SkillResultLine {
  final String? textKey;
  final Map<String, String> params;
  final Map<String, String> paramKeys;
  final String? rawText;

  const SkillResultLine.key(
    this.textKey, {
    this.params = const {},
    this.paramKeys = const {},
  }) : rawText = null;

  const SkillResultLine.raw(this.rawText)
    : textKey = null,
      params = const {},
      paramKeys = const {};
}

class SkillResultSection {
  final String titleKey;
  final Map<String, String> titleParams;
  final String? bodyKey;
  final Map<String, String> bodyParams;
  final String? bodyText;
  final List<SkillResultLine> lines;
  final List<String> highlightTerms;

  const SkillResultSection({
    required this.titleKey,
    this.titleParams = const {},
    this.bodyKey,
    this.bodyParams = const {},
    this.bodyText,
    this.lines = const [],
    this.highlightTerms = const [],
  });
}

class SkillRunResult {
  final String skillId;
  final String summaryKey;
  final Map<String, String> summaryParams;
  final List<SkillResultSection> sections;
  final DateTime completedAt;

  SkillRunResult({
    required this.skillId,
    required this.summaryKey,
    this.summaryParams = const {},
    this.sections = const [],
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now();
}

class SkillRunProgress {
  final String messageKey;
  final Map<String, String> messageParams;
  final int? completed;
  final int? total;

  const SkillRunProgress({
    required this.messageKey,
    this.messageParams = const {},
    this.completed,
    this.total,
  });
}
