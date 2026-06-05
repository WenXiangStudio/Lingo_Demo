import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../data/providers.dart';
import '../../lists/providers/list_provider.dart';
import '../providers/deep_practice_provider.dart';

class DeepPracticeResultScreen extends ConsumerStatefulWidget {
  final int listId;
  final String returnPath;

  const DeepPracticeResultScreen({
    super.key,
    required this.listId,
    required this.returnPath,
  });

  @override
  ConsumerState<DeepPracticeResultScreen> createState() =>
      _DeepPracticeResultScreenState();
}

class _DeepPracticeResultScreenState
    extends ConsumerState<DeepPracticeResultScreen> {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _saveIfNeeded();
  }

  Future<void> _saveIfNeeded() async {
    if (_saved) return;
    final state = ref.read(deepPracticeProvider);
    if (state.phase == DeepPracticePhase.finished && state.sessionId == null) {
      await ref.read(deepPracticeProvider.notifier).saveSession();
      if (mounted) setState(() => _saved = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deepPracticeProvider);
    final lang = ref.watch(languageProvider);
    final theme = Theme.of(context);

    if (state.phase != DeepPracticePhase.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(widget.returnPath);
      });
      return const SizedBox.shrink();
    }

    final accuracy = state.accuracy;
    final percentage = (accuracy * 100).round();
    final correctCount = state.correctCount;
    final totalCount = state.totalQuestions;
    final threshold =
        ref
            .watch(listDetailProvider(widget.listId))
            .valueOrNull
            ?.passThreshold ??
        AppConstants.defaultPassThreshold;
    final isPassed = accuracy >= threshold;

    final errorWords = <String>[];
    for (var i = 0; i < state.answers.length; i++) {
      final a = state.answers[i];
      if (!a.isCorrect) {
        errorWords.add(a.correctAnswer);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('deep_results', lang)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(deepPracticeProvider.notifier).reset();
            context.go(widget.returnPath);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
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
          const SizedBox(height: 24),
          Row(
            children: [
              _statCard(
                theme,
                Icons.check_circle_outline,
                AppStrings.get('correct_stat', lang),
                '$correctCount',
                Colors.green,
              ),
              const SizedBox(width: 12),
              _statCard(
                theme,
                Icons.cancel_outlined,
                AppStrings.get('incorrect_stat', lang),
                '${totalCount - correctCount}',
                Colors.red,
              ),
              const SizedBox(width: 12),
              _statCard(
                theme,
                Icons.quiz_outlined,
                AppStrings.get('total_stat', lang),
                '$totalCount',
                theme.colorScheme.primary,
              ),
            ],
          ),
          if (errorWords.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              AppStrings.get('words_to_review', lang),
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: errorWords
                      .map(
                        (w) => Chip(
                          label: Text(w),
                          backgroundColor: Colors.red.withValues(alpha: 0.08),
                          side: BorderSide.none,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              ref.read(deepPracticeProvider.notifier).reset();
              context.go(
                '/deep-practice/${widget.listId}/setup?returnPath=${Uri.encodeComponent(widget.returnPath)}',
              );
            },
            icon: const Icon(Icons.replay),
            label: Text(AppStrings.get('practice_again', lang)),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              ref.read(deepPracticeProvider.notifier).reset();
              context.go(widget.returnPath);
            },
            icon: const Icon(Icons.list_alt),
            label: Text(AppStrings.get('back_to_list', lang)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _statCard(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
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
