import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/skills/skill_definition.dart';
import '../../../core/skills/skill_providers.dart';
import '../../../data/database/app_database.dart';
import '../../../data/providers.dart';
import '../../lists/providers/list_provider.dart';

class SkillsScreen extends ConsumerStatefulWidget {
  const SkillsScreen({super.key});

  @override
  ConsumerState<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends ConsumerState<SkillsScreen> {
  final Map<String, Map<String, Object?>> _inputsBySkill = {};

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final registry = ref.watch(skillRegistryProvider);
    final listsAsync = ref.watch(listOverviewProvider);
    final runState = ref.watch(skillRunControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: AppStrings.get('back_home', lang),
          onPressed: () => context.go('/'),
        ),
        title: Text(AppStrings.get('skills_title', lang)),
      ),
      body: listsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          title: AppStrings.get('failed_lists', lang),
          detail: error.toString(),
          onRetry: () => ref.invalidate(listOverviewProvider),
          lang: lang,
        ),
        data: (lists) {
          if (lists.isEmpty) {
            return _EmptySkillsState(lang: lang);
          }
          _seedInputs(registry.skills, lists);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Text(
                AppStrings.get('skills_intro', lang),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                ),
              ),
              const SizedBox(height: 12),
              for (final skill in registry.skills) ...[
                _SkillCard(
                  skill: skill,
                  lists: lists,
                  inputs: _inputsBySkill[skill.id]!,
                  runState: runState,
                  lang: lang,
                  onInputChanged: (inputId, value) {
                    setState(() {
                      _inputsBySkill[skill.id]![inputId] = value;
                    });
                  },
                  onRun: () => _runSkill(skill, lang),
                  onCancel: () =>
                      ref.read(skillRunControllerProvider.notifier).cancel(),
                ),
                const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }

  void _seedInputs(List<LingoSkill> skills, List<WordList> lists) {
    for (final skill in skills) {
      final inputs = _inputsBySkill.putIfAbsent(skill.id, () => {});
      for (final spec in skill.inputs) {
        if (inputs.containsKey(spec.id)) continue;
        switch (spec.type) {
          case SkillInputType.wordList:
            inputs[spec.id] = lists.first.id;
            break;
          case SkillInputType.integer:
            inputs[spec.id] = spec.defaultValue ?? spec.min ?? 1;
            break;
        }
      }
    }
  }

  Future<void> _runSkill(LingoSkill skill, String lang) async {
    if (skill.usesAi || skill.usesCloud) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppStrings.get('skill_ai_confirm_title', lang)),
          content: Text(AppStrings.get('skill_ai_confirm_body', lang)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(AppStrings.get('cancel', lang)),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(AppStrings.get('start', lang)),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    await ref
        .read(skillRunControllerProvider.notifier)
        .runSkill(
          skill.id,
          Map<String, Object?>.from(_inputsBySkill[skill.id]!),
        );
  }
}

class _SkillCard extends StatelessWidget {
  final LingoSkill skill;
  final List<WordList> lists;
  final Map<String, Object?> inputs;
  final SkillRunState runState;
  final String lang;
  final void Function(String inputId, Object? value) onInputChanged;
  final VoidCallback onRun;
  final VoidCallback onCancel;

  const _SkillCard({
    required this.skill,
    required this.lists,
    required this.inputs,
    required this.runState,
    required this.lang,
    required this.onInputChanged,
    required this.onRun,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRunning =
        runState.phase == SkillRunPhase.running &&
        runState.runningSkillId == skill.id;
    final result = runState.runningSkillId == skill.id ? runState.result : null;
    final showError =
        runState.runningSkillId == skill.id && runState.errorKey != null;
    final anyRunning = runState.phase == SkillRunPhase.running;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _skillIcon(skill),
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get(skill.titleKey, lang),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        AppStrings.get(skill.descriptionKey, lang),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.62,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skill.capabilities
                  .map(
                    (capability) => _CapabilityChip(
                      label: AppStrings.get(
                        _capabilityLabelKey(capability),
                        lang,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            for (final spec in skill.inputs) ...[
              _SkillInputControl(
                spec: spec,
                lists: lists,
                value: inputs[spec.id],
                lang: lang,
                onChanged: (value) => onInputChanged(spec.id, value),
              ),
              const SizedBox(height: 10),
            ],
            if (isRunning && runState.progress != null) ...[
              _ProgressLine(progress: runState.progress!, lang: lang),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: anyRunning ? null : onRun,
                    icon: isRunning
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(
                      isRunning
                          ? AppStrings.get('skill_running', lang)
                          : AppStrings.get('skill_run', lang),
                    ),
                  ),
                ),
                if (isRunning) ...[
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.stop_outlined),
                    label: Text(AppStrings.get('cancel', lang)),
                  ),
                ],
              ],
            ),
            if (result != null) ...[
              const SizedBox(height: 12),
              _SkillResultPanel(result: result, lang: lang),
            ],
            if (showError) ...[
              const SizedBox(height: 12),
              _RunErrorPanel(runState: runState, lang: lang),
            ],
          ],
        ),
      ),
    );
  }

  static IconData _skillIcon(LingoSkill skill) {
    return switch (skill.category) {
      SkillCategory.ai => Icons.auto_awesome,
      SkillCategory.review => Icons.fact_check_outlined,
      SkillCategory.speaking => Icons.record_voice_over_outlined,
      SkillCategory.tts => Icons.volume_up_outlined,
      SkillCategory.maintenance => Icons.build_outlined,
    };
  }

  static String _capabilityLabelKey(SkillCapability capability) {
    return switch (capability) {
      SkillCapability.ai => 'skill_capability_ai',
      SkillCapability.database => 'skill_capability_database',
      SkillCapability.tts => 'skill_capability_tts',
      SkillCapability.asr => 'skill_capability_asr',
      SkillCapability.local => 'skill_capability_local',
      SkillCapability.cloud => 'skill_capability_cloud',
    };
  }
}

class _SkillInputControl extends StatelessWidget {
  final SkillInputSpec spec;
  final List<WordList> lists;
  final Object? value;
  final String lang;
  final ValueChanged<Object?> onChanged;

  const _SkillInputControl({
    required this.spec,
    required this.lists,
    required this.value,
    required this.lang,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (spec.type) {
      case SkillInputType.wordList:
        return DropdownButtonFormField<int>(
          initialValue: value as int?,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: AppStrings.get(spec.labelKey, lang),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          items: lists
              .map(
                (list) => DropdownMenuItem<int>(
                  value: list.id,
                  child: Text(
                    list.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        );
      case SkillInputType.integer:
        final current =
            value as int? ?? spec.defaultValue as int? ?? spec.min ?? 1;
        return Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.get(spec.labelKey, lang),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            IconButton(
              tooltip: AppStrings.get('previous_page', lang),
              onPressed: current <= (spec.min ?? current)
                  ? null
                  : () => onChanged(current - 1),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            SizedBox(
              width: 42,
              child: Text(
                current.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            IconButton(
              tooltip: AppStrings.get('next_page', lang),
              onPressed: current >= (spec.max ?? current)
                  ? null
                  : () => onChanged(current + 1),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        );
    }
  }
}

class _CapabilityChip extends StatelessWidget {
  final String label;

  const _CapabilityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: theme.textTheme.labelSmall),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final SkillRunProgress progress;
  final String lang;

  const _ProgressLine({required this.progress, required this.lang});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = AppStrings.get(
      progress.messageKey,
      lang,
      params: progress.messageParams,
    );
    return Row(
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ),
      ],
    );
  }
}

class _SkillResultPanel extends StatelessWidget {
  final SkillRunResult result;
  final String lang;

  const _SkillResultPanel({required this.result, required this.lang});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get(
              result.summaryKey,
              lang,
              params: result.summaryParams,
            ),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (final section in result.sections) ...[
            Text(
              AppStrings.get(
                section.titleKey,
                lang,
                params: section.titleParams,
              ),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (section.bodyText != null) ...[
              const SizedBox(height: 4),
              Text(section.bodyText!, style: theme.textTheme.bodyMedium),
            ],
            if (section.bodyKey != null) ...[
              const SizedBox(height: 4),
              Text(
                AppStrings.get(
                  section.bodyKey!,
                  lang,
                  params: section.bodyParams,
                ),
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (section.lines.isNotEmpty) ...[
              const SizedBox(height: 6),
              ...section.lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: _HighlightableText(
                    text: _formatResultLine(line, lang),
                    highlightTerms: section.highlightTerms,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  static String _formatResultLine(SkillResultLine line, String lang) {
    if (line.rawText != null) return line.rawText!;
    final key = line.textKey;
    if (key == null) return '';
    final params = Map<String, String>.from(line.params);
    for (final entry in line.paramKeys.entries) {
      params[entry.key] = AppStrings.get(entry.value, lang);
    }
    return AppStrings.get(key, lang, params: params);
  }
}

class _HighlightableText extends StatelessWidget {
  final String text;
  final List<String> highlightTerms;
  final TextStyle? style;

  const _HighlightableText({
    required this.text,
    required this.highlightTerms,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final terms =
        highlightTerms
            .map((term) => term.trim())
            .where((term) => term.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => b.length.compareTo(a.length));
    if (terms.isEmpty || text.isEmpty) {
      return Text(text, style: style);
    }

    final spans = <TextSpan>[];
    var index = 0;
    while (index < text.length) {
      _Match? best;
      for (final term in terms) {
        final match = _findTerm(text, term, index);
        if (match == null) continue;
        if (best == null ||
            match.start < best.start ||
            (match.start == best.start && match.end > best.end)) {
          best = match;
        }
      }
      if (best == null) {
        spans.add(TextSpan(text: text.substring(index)));
        break;
      }
      if (best.start > index) {
        spans.add(TextSpan(text: text.substring(index, best.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(best.start, best.end),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w800,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.7),
          ),
        ),
      );
      index = best.end;
    }

    return RichText(
      text: TextSpan(style: style, children: spans),
    );
  }

  static _Match? _findTerm(String text, String term, int start) {
    final isAsciiWord = RegExp(r'^[A-Za-z]+$').hasMatch(term);
    if (!isAsciiWord) {
      final index = text.indexOf(term, start);
      return index < 0 ? null : _Match(index, index + term.length);
    }
    final lowerText = text.toLowerCase();
    final lowerTerm = term.toLowerCase();
    var index = lowerText.indexOf(lowerTerm, start);
    while (index >= 0) {
      final end = index + term.length;
      final beforeOk =
          index == 0 || !RegExp(r'[A-Za-z]').hasMatch(text[index - 1]);
      final afterOk =
          end >= text.length || !RegExp(r'[A-Za-z]').hasMatch(text[end]);
      if (beforeOk && afterOk) return _Match(index, end);
      index = lowerText.indexOf(lowerTerm, index + 1);
    }
    return null;
  }
}

class _Match {
  final int start;
  final int end;

  const _Match(this.start, this.end);
}

class _RunErrorPanel extends StatelessWidget {
  final SkillRunState runState;
  final String lang;

  const _RunErrorPanel({required this.runState, required this.lang});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorText = AppStrings.get(
      runState.errorKey!,
      lang,
      params: runState.errorParams,
    );
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              runState.rawError == null
                  ? errorText
                  : '$errorText\n${runState.rawError}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String title;
  final String detail;
  final VoidCallback onRetry;
  final String lang;

  const _ErrorState({
    required this.title,
    required this.detail,
    required this.onRetry,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(detail, style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: Text(AppStrings.get('retry', lang)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySkillsState extends StatelessWidget {
  final String lang;

  const _EmptySkillsState({required this.lang});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 56,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.get('skills_no_lists', lang),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
