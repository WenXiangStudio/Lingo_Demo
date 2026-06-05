import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../data/providers.dart';
import '../../lists/providers/list_provider.dart';
import '../providers/practice_provider.dart';

class PracticeSetupScreen extends ConsumerWidget {
  final int listId;
  final bool onlyForgotten;
  final bool onlyErrors;
  final String returnPath;

  const PracticeSetupScreen({
    super.key,
    required this.listId,
    this.onlyForgotten = false,
    this.onlyErrors = false,
    required this.returnPath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(practiceProvider);
    final lang = ref.watch(languageProvider);
    final listAsync = ref.watch(listDetailProvider(listId));
    final theme = Theme.of(context);

    final isPassed = listAsync.valueOrNull?.isPassed ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('start_practice_title', lang)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(returnPath),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (onlyForgotten || onlyErrors)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.flag,
                      size: 18,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.get(
                          onlyErrors
                              ? 'error_practice_intro'
                              : 'forgotten_practice_intro',
                          lang,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              AppStrings.get('choose_mode', lang),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _ModeCard(
              icon: Icons.touch_app_outlined,
              title: AppStrings.get('multiple_choice', lang),
              description: AppStrings.get('multiple_choice_desc', lang),
              selected: state.mode == PracticeMode.choice,
              locked: false,
              onTap: () => _selectMode(ref, PracticeMode.choice),
            ),
            const SizedBox(height: 10),
            _ModeCard(
              icon: Icons.edit_outlined,
              title: AppStrings.get('fill_blank', lang),
              description: AppStrings.get('fill_blank_desc', lang),
              selected: state.mode == PracticeMode.fill,
              locked: false,
              onTap: () => _selectMode(ref, PracticeMode.fill),
            ),
            const SizedBox(height: 10),
            _ModeCard(
              icon: Icons.hearing_outlined,
              title: AppStrings.get('dictation', lang),
              description: AppStrings.get('dictation_desc', lang),
              selected: state.mode == PracticeMode.dictation,
              locked: !isPassed && !onlyForgotten && !onlyErrors,
              lockedHint: AppStrings.get('locked_until_passed', lang),
              onTap: () => _selectMode(ref, PracticeMode.dictation),
            ),
            const SizedBox(height: 10),
            _ModeCard(
              icon: Icons.headphones_outlined,
              title: AppStrings.get('audio_choice', lang),
              description: AppStrings.get('audio_choice_desc', lang),
              selected: state.mode == PracticeMode.audioChoice,
              locked: !isPassed && !onlyForgotten && !onlyErrors,
              lockedHint: AppStrings.get('locked_until_passed', lang),
              onTap: () => _selectMode(ref, PracticeMode.audioChoice),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: state.mode != null
                  ? () async {
                      final notifier = ref.read(practiceProvider.notifier);
                      await notifier.initSession(
                        listId: listId,
                        mode: state.mode!,
                        onlyForgotten: onlyForgotten,
                        onlyErrors: onlyErrors,
                      );
                      if (context.mounted) {
                        context.push(
                          '/practice/$listId/quiz?returnPath=${Uri.encodeComponent(returnPath)}',
                        );
                      }
                    }
                  : null,
              icon: const Icon(Icons.play_arrow),
              label: Text(AppStrings.get('start', lang)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _selectMode(WidgetRef ref, PracticeMode mode) {
    ref.read(practiceProvider.notifier).selectMode(mode);
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final bool locked;
  final String? lockedHint;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.locked,
    this.lockedHint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Opacity(
      opacity: locked ? 0.55 : 1,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: locked ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: selected
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                            ),
                          ),
                          if (locked) const Icon(Icons.lock_outline, size: 16),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        locked && lockedHint != null
                            ? lockedHint!
                            : description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle, color: theme.colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
