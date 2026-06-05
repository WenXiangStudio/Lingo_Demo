import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../data/providers.dart';
import '../providers/deep_practice_provider.dart';

class DeepPracticeSetupScreen extends ConsumerStatefulWidget {
  final int listId;
  final String returnPath;

  const DeepPracticeSetupScreen({
    super.key,
    required this.listId,
    required this.returnPath,
  });

  @override
  ConsumerState<DeepPracticeSetupScreen> createState() =>
      _DeepPracticeSetupScreenState();
}

class _DeepPracticeSetupScreenState
    extends ConsumerState<DeepPracticeSetupScreen> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deepPracticeProvider);
    final lang = ref.watch(languageProvider);
    final theme = Theme.of(context);

    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(deepPracticeProvider.notifier)
            .initSession(listId: widget.listId, mode: 'deep_choice');
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('ai_deep_learning', lang)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(widget.returnPath),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mode selection
            Text(
              AppStrings.get('choose_mode', lang),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _ModeCard(
              icon: Icons.link,
              title: AppStrings.get('collocations_title', lang),
              description: AppStrings.get('collocations_desc', lang),
              selected: state.mode == 'deep_choice',
              onTap: () => ref
                  .read(deepPracticeProvider.notifier)
                  .initSession(listId: widget.listId, mode: 'deep_choice'),
            ),
            const SizedBox(height: 8),
            _ModeCard(
              icon: Icons.text_fields,
              title: AppStrings.get('contextual_sentences', lang),
              description: AppStrings.get('contextual_sentences_desc', lang),
              selected: state.mode == 'deep_fill',
              onTap: () => ref
                  .read(deepPracticeProvider.notifier)
                  .initSession(listId: widget.listId, mode: 'deep_fill'),
            ),
            const SizedBox(height: 8),
            _ModeCard(
              icon: Icons.format_quote,
              title: AppStrings.get('idioms_mode', lang),
              description: AppStrings.get('idioms_mode_desc', lang),
              selected: state.mode == 'deep_idioms',
              onTap: () => ref
                  .read(deepPracticeProvider.notifier)
                  .initSession(listId: widget.listId, mode: 'deep_idioms'),
            ),
            const SizedBox(height: 24),

            // Generation progress
            if (state.phase == DeepPracticePhase.generating) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppStrings.get('generating_ai', lang),
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: state.totalToGenerate > 0
                            ? state.generatedCount / state.totalToGenerate
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.get(
                          'n_of_m_words',
                          lang,
                          params: {
                            'generated': state.generatedCount.toString(),
                            'total': state.totalToGenerate.toString(),
                          },
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Ready state
            if (state.phase == DeepPracticePhase.ready) ...[
              Card(
                color: Colors.green.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.get('content_ready', lang),
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              AppStrings.get(
                                'n_questions_prepared',
                                lang,
                                params: {
                                  'count': state.questions.length.toString(),
                                },
                              ),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Error
            if (state.generationError != null) ...[
              const SizedBox(height: 12),
              Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.generationError!,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const Spacer(),

            // Action buttons
            if (state.phase == DeepPracticePhase.setup)
              FilledButton.icon(
                onPressed: () =>
                    ref.read(deepPracticeProvider.notifier).generateContent(),
                icon: const Icon(Icons.auto_awesome),
                label: Text(AppStrings.get('generate_ai_content', lang)),
              ),

            if (state.phase == DeepPracticePhase.generating)
              FilledButton.icon(
                onPressed: null,
                icon: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                label: Text(AppStrings.get('generating_btn', lang)),
              ),

            if (state.phase == DeepPracticePhase.ready)
              FilledButton.icon(
                onPressed: () {
                  ref.read(deepPracticeProvider.notifier).startQuiz();
                  context.push(
                    '/deep-practice/${widget.listId}/quiz?returnPath=${Uri.encodeComponent(widget.returnPath)}',
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  AppStrings.get(
                    'start_practice_n',
                    lang,
                    params: {'count': state.questions.length.toString()},
                  ),
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: selected ? theme.colorScheme.primary : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
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
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
