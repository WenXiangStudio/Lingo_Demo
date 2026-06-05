import 'skill_definition.dart';
import 'skill_handler.dart';

class SkillRegistry {
  final Map<String, LingoSkill> _skills;
  final Map<String, SkillHandler> _handlers;

  SkillRegistry({
    required Iterable<LingoSkill> skills,
    required Map<String, SkillHandler> handlers,
  }) : _skills = {for (final skill in skills) skill.id: skill},
       _handlers = handlers;

  List<LingoSkill> get skills => _skills.values.toList(growable: false);

  LingoSkill? getSkill(String id) => _skills[id];

  SkillHandler? getHandler(String handlerKey) => _handlers[handlerKey];
}

final builtInSkills = [
  const LingoSkill(
    id: 'word_story',
    titleKey: 'skill_word_story',
    descriptionKey: 'skill_word_story_desc',
    category: SkillCategory.ai,
    capabilities: {
      SkillCapability.ai,
      SkillCapability.cloud,
      SkillCapability.database,
    },
    inputs: [
      SkillInputSpec(
        id: 'list_id',
        labelKey: 'skill_input_word_list',
        type: SkillInputType.wordList,
      ),
      SkillInputSpec(
        id: 'word_count',
        labelKey: 'skill_input_word_count',
        type: SkillInputType.integer,
        min: 3,
        max: 12,
        defaultValue: 8,
      ),
    ],
    handlerKey: 'word_story',
    usesAi: true,
    usesCloud: true,
  ),
  const LingoSkill(
    id: 'review_plan',
    titleKey: 'skill_review_plan',
    descriptionKey: 'skill_review_plan_desc',
    category: SkillCategory.review,
    capabilities: {SkillCapability.local, SkillCapability.database},
    inputs: [
      SkillInputSpec(
        id: 'list_id',
        labelKey: 'skill_input_word_list',
        type: SkillInputType.wordList,
      ),
    ],
    handlerKey: 'review_plan',
  ),
];
