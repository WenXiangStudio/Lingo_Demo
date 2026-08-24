import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../data/database/app_database.dart';
import '../../../data/providers.dart';
import '../../lists/providers/list_provider.dart';
import '../providers/practice_provider.dart';

class PracticeResultScreen extends ConsumerStatefulWidget {
  final int listId;
  final String returnPath;

  const PracticeResultScreen({
    super.key,
    required this.listId,
    required this.returnPath,
  });

  @override
  ConsumerState<PracticeResultScreen> createState() =>
      _PracticeResultScreenState();
}

class _PracticeResultScreenState extends ConsumerState<PracticeResultScreen> {
  bool _saved = false;
  Future<void>? _saveFuture;

  @override
  void initState() {
    super.initState();
    _saveFuture = _saveIfNeeded();
  }

  Future<void> _saveIfNeeded() async {
    if (_saved) return;
    final state = ref.read(practiceProvider);
    if (state.phase == PracticePhase.finished && state.sessionId == null) {
      final notifier = ref.read(practiceProvider.notifier);
      try {
        await notifier.markListPassedIfEligible();
        await notifier.saveSession().timeout(
          const Duration(seconds: 8),
          onTimeout: () {
            notifier.markSaveFailed('timeout');
          },
        );
      } catch (e) {
        notifier.markSaveFailed(e.toString());
      }
    }
    if (mounted) setState(() => _saved = true);
  }

  Future<void> _ensureSaved() async {
    _saveFuture ??= _saveIfNeeded();
    await _saveFuture;
  }

  Future<void> _leaveResult(String target) async {
    await _ensureSaved();
    if (!mounted) return;
    ref.invalidate(listDetailProvider(widget.listId));
    ref.invalidate(listOverviewProvider);
    ref.read(practiceProvider.notifier).reset();
    context.go(target);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(practiceProvider);
    final theme = Theme.of(context);

    if (state.phase != PracticePhase.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(widget.returnPath);
      });
      return const SizedBox.shrink();
    }

    final lang = ref.watch(languageProvider);
    final accuracy = state.accuracy;
    final correctCount = state.correctCount;
    final totalCount = state.totalQuestions;
    final isPassed =
        accuracy >=
        (state.words.isNotEmpty
            ? ref
                      .watch(listDetailProvider(widget.listId))
                      .valueOrNull
                      ?.passThreshold ??
                  AppConstants.defaultPassThreshold
            : AppConstants.defaultPassThreshold);
    final percentage = (accuracy * 100).round();
    final isPersisting = !_saved && (state.isSaving || state.sessionId == null);
    final saveError = state.saveError;

    final errorWords = <Word>[];
    final correctWords = <Word>[];
    for (var i = 0; i < state.answers.length; i++) {
      final answer = state.answers[i];
      final word = state.words[i];
      if (answer.isCorrect) {
        correctWords.add(word);
      } else {
        errorWords.add(word);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('practice_results', lang)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: isPersisting
              ? null
              : () => _leaveResult(widget.returnPath),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Score circle
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: accuracy,
                      strokeWidth: 12,
                      strokeCap: StrokeCap.round,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      color: isPassed ? Colors.green : Colors.orange,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$percentage%',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isPassed ? Colors.green : Colors.orange,
                        ),
                      ),
                      Text(
                        '$correctCount / $totalCount',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Verdict
          Center(
            child: Chip(
              avatar: Icon(
                isPassed ? Icons.emoji_events : Icons.fitness_center,
                size: 18,
                color: isPassed ? Colors.green : Colors.orange,
              ),
              label: Text(
                isPassed
                    ? AppStrings.get('passed', lang)
                    : AppStrings.get('keep_practice', lang),
                style: TextStyle(
                  color: isPassed ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: isPassed
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              side: BorderSide.none,
            ),
          ),

          if (isPassed && !state.onlyForgotten && !state.onlyErrors) ...[
            const SizedBox(height: 12),
            Card(
              color: Colors.green.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.lock_open, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppStrings.get('list_passed_unlocked', lang),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (isPersisting) ...[
            const SizedBox(height: 12),
            const Center(child: CircularProgressIndicator()),
          ],

          if (saveError != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Colors.orange.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppStrings.get(
                          'practice_save_warning',
                          lang,
                          params: {
                            'msg': saveError == 'timeout'
                                ? AppStrings.get('practice_save_timeout', lang)
                                : saveError,
                          },
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Forgotten-words session result message
          if (state.onlyForgotten) ...[
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: state.clearedForgottenCount > 0
                      ? Colors.green.withValues(alpha: 0.08)
                      : Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      state.clearedForgottenCount > 0
                          ? Icons.flag_outlined
                          : Icons.flag,
                      size: 18,
                      color: state.clearedForgottenCount > 0
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        state.clearedForgottenCount > 0
                            ? AppStrings.get(
                                'forgotten_cleared_n',
                                lang,
                                params: {
                                  'count': state.clearedForgottenCount
                                      .toString(),
                                },
                              )
                            : AppStrings.get('forgotten_not_cleared', lang),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: state.clearedForgottenCount > 0
                              ? Colors.green.shade800
                              : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (state.onlyErrors) ...[
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: state.clearedForgottenCount > 0
                      ? Colors.green.withValues(alpha: 0.08)
                      : Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      state.clearedForgottenCount > 0
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      size: 18,
                      color: state.clearedForgottenCount > 0
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        state.clearedForgottenCount > 0
                            ? AppStrings.get(
                                'error_cleared_n',
                                lang,
                                params: {
                                  'count': state.clearedForgottenCount
                                      .toString(),
                                },
                              )
                            : AppStrings.get('error_not_cleared', lang),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: state.clearedForgottenCount > 0
                              ? Colors.green.shade800
                              : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Elapsed time
          Center(
            child: Text(
              _formatTime(state.elapsedSeconds),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Stats row
          Row(
            children: [
              _StatCard(
                icon: Icons.check_circle_outline,
                label: AppStrings.get('correct_stat', lang),
                value: '$correctCount',
                color: Colors.green,
                theme: theme,
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.cancel_outlined,
                label: AppStrings.get('incorrect_stat', lang),
                value: '${state.incorrectCount}',
                color: Colors.red,
                theme: theme,
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.quiz_outlined,
                label: AppStrings.get('total_stat', lang),
                value: '$totalCount',
                color: theme.colorScheme.primary,
                theme: theme,
              ),
            ],
          ),

          // Error words
          if (errorWords.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              AppStrings.get('words_to_review', lang),
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...errorWords.map(
              (w) => Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              w.english,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              w.chineseMeanings,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Actions
          OutlinedButton.icon(
            onPressed: isPersisting
                ? null
                : () => _leaveResult(_practiceAgainPath(state)),
            icon: const Icon(Icons.replay),
            label: Text(AppStrings.get('practice_again', lang)),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: isPersisting
                ? null
                : () => _leaveResult(widget.returnPath),
            icon: const Icon(Icons.list_alt),
            label: Text(AppStrings.get('back_to_list', lang)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: isPersisting ? null : () => _leaveResult('/'),
            icon: const Icon(Icons.home_outlined),
            label: Text(AppStrings.get('workflow_return', lang)),
          ),
          if (isPassed && !state.onlyForgotten && !state.onlyErrors) ...[
            const SizedBox(height: 18),
            Text(
              AppStrings.get('workflow_ai_learning', lang),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: isPersisting
                      ? null
                      : () => _leaveResult(
                          '/deep-practice/${widget.listId}/setup?listIds=${widget.listId}&returnPath=${Uri.encodeComponent('/')}',
                        ),
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(AppStrings.get('workflow_ai_learning', lang)),
                ),
                OutlinedButton.icon(
                  onPressed: isPersisting
                      ? null
                      : () => _leaveResult(
                          '/dialogue/${widget.listId}?listId=${widget.listId}',
                        ),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text(AppStrings.get('workflow_ai_dialogue', lang)),
                ),
                OutlinedButton.icon(
                  onPressed: isPersisting
                      ? null
                      : () => _leaveResult('/skills?listId=${widget.listId}'),
                  icon: const Icon(Icons.auto_fix_high),
                  label: Text(AppStrings.get('workflow_skills', lang)),
                ),
              ],
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _practiceAgainPath(PracticeState state) {
    if (state.onlyErrors && state.clearedForgottenCount >= state.words.length) {
      return widget.returnPath;
    }
    final params = <String, String>{'returnPath': widget.returnPath};
    if (state.onlyForgotten) params['forgotten'] = 'true';
    if (state.onlyErrors) params['errors'] = 'true';
    if (state.trackExampleReveals) params['exampleCueTracking'] = 'true';
    return Uri(
      path: '/practice/${widget.listId}/setup',
      queryParameters: params,
    ).toString();
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
