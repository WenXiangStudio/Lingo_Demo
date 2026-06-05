import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../data/providers.dart';
import '../providers/deep_practice_provider.dart';

class DeepPracticeQuizScreen extends ConsumerStatefulWidget {
  final int listId;
  final String returnPath;

  const DeepPracticeQuizScreen({
    super.key,
    required this.listId,
    required this.returnPath,
  });

  @override
  ConsumerState<DeepPracticeQuizScreen> createState() =>
      _DeepPracticeQuizScreenState();
}

class _DeepPracticeQuizScreenState
    extends ConsumerState<DeepPracticeQuizScreen> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitText() {
    final state = ref.read(deepPracticeProvider);
    if (state.phase != DeepPracticePhase.quiz) return;
    ref
        .read(deepPracticeProvider.notifier)
        .submitTextAnswer(_textController.text);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deepPracticeProvider);
    final lang = ref.watch(languageProvider);
    final theme = Theme.of(context);

    if (state.phase == DeepPracticePhase.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          GoRouter.of(context).replace(
            '/deep-practice/${widget.listId}/result?returnPath=${Uri.encodeComponent(widget.returnPath)}',
          );
        }
      });
      return const SizedBox.shrink();
    }

    if (state.phase != DeepPracticePhase.quiz &&
        state.phase != DeepPracticePhase.feedback) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          GoRouter.of(context).replace(
            '/deep-practice/${widget.listId}/setup?returnPath=${Uri.encodeComponent(widget.returnPath)}',
          );
        }
      });
      return const SizedBox.shrink();
    }

    final question = state.currentQuestion;
    if (question == null) {
      return Scaffold(
        body: Center(child: Text(AppStrings.get('no_questions', lang))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${state.currentIndex + 1} / ${state.totalQuestions}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showQuitDialog(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value:
                    (state.currentIndex +
                        (state.phase == DeepPracticePhase.feedback ? 1 : 0)) /
                    state.totalQuestions,
                minHeight: 4,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: state.mode == 'deep_choice'
                  ? _buildChoiceQuestion(context, question, state, theme, lang)
                  : _buildFillQuestion(context, question, state, theme, lang),
            ),
          ),
          if (state.phase == DeepPracticePhase.feedback)
            _buildFeedback(context, state, theme, lang),
        ],
      ),
    );
  }

  Widget _buildChoiceQuestion(
    BuildContext context,
    DeepQuestion question,
    DeepPracticeState state,
    ThemeData theme,
    String lang,
  ) {
    final options = state.currentOptions ?? [];
    final showFeedback = state.phase == DeepPracticePhase.feedback;

    return Column(
      children: [
        const SizedBox(height: 20),
        // Description
        Text(
          AppStrings.get('collocation_question', lang),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 16),
        // Collocation with blank
        Card(
          elevation: 0,
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
            child: Text(
              question.displayText,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (question.chineseHint.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            AppStrings.get(
              'hint_prefix',
              lang,
              params: {'hint': question.chineseHint},
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
        const SizedBox(height: 24),
        ...options.map((option) {
          final isCorrectAnswer =
              option.toLowerCase() == question.correctAnswer.toLowerCase();
          Color? bgColor;
          Color? borderColor;

          if (showFeedback && isCorrectAnswer) {
            bgColor = Colors.green.withValues(alpha: 0.1);
            borderColor = Colors.green;
          } else if (showFeedback &&
              !isCorrectAnswer &&
              state.lastAnswerCorrect == false &&
              option == state.answers.last.userAnswer) {
            bgColor = Colors.red.withValues(alpha: 0.1);
            borderColor = Colors.red;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: showFeedback
                    ? null
                    : () => ref
                          .read(deepPracticeProvider.notifier)
                          .submitChoiceAnswer(option),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: bgColor,
                  side: BorderSide(
                    color: borderColor ?? theme.colorScheme.outline,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    if (showFeedback && isCorrectAnswer)
                      const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                      )
                    else if (showFeedback &&
                        !isCorrectAnswer &&
                        option == state.answers.last.userAnswer)
                      const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(Icons.cancel, color: Colors.red, size: 20),
                      ),
                    Expanded(
                      child: Text(option, style: theme.textTheme.bodyLarge),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFillQuestion(
    BuildContext context,
    DeepQuestion question,
    DeepPracticeState state,
    ThemeData theme,
    String lang,
  ) {
    final showFeedback = state.phase == DeepPracticePhase.feedback;
    final lastAnswer = state.answers.isNotEmpty ? state.answers.last : null;

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          AppStrings.get('complete_sentence', lang),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              question.displayText,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
        ),
        if (question.chineseHint.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            AppStrings.get(
              'hint_prefix',
              lang,
              params: {'hint': question.chineseHint},
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
        const SizedBox(height: 24),
        TextField(
          controller: _textController,
          focusNode: _focusNode,
          enabled: !showFeedback,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitText(),
          decoration: InputDecoration(
            hintText: AppStrings.get('type_missing_word', lang),
            prefixIcon: const Icon(Icons.edit_outlined),
            suffixIcon: showFeedback
                ? lastAnswer?.isCorrect == true
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.cancel, color: Colors.red)
                : IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _submitText,
                  ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        if (!showFeedback) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submitText,
              child: Text(AppStrings.get('submit', lang)),
            ),
          ),
        ],
        if (showFeedback && lastAnswer != null && !lastAnswer.isCorrect) ...[
          const SizedBox(height: 20),
          Card(
            color: Colors.green.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.green),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get('correct_answer_label', lang),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      Text(
                        lastAnswer.correctAnswer,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFeedback(
    BuildContext context,
    DeepPracticeState state,
    ThemeData theme,
    String lang,
  ) {
    final isCorrect = state.lastAnswerCorrect ?? false;
    final isLast = state.currentIndex + 1 >= state.totalQuestions;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withValues(alpha: 0.08)
            : Colors.red.withValues(alpha: 0.08),
        border: Border(
          top: BorderSide(
            color: isCorrect
                ? Colors.green.withValues(alpha: 0.3)
                : Colors.red.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? Colors.green : Colors.red,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            isCorrect
                ? AppStrings.get('correct', lang)
                : AppStrings.get('incorrect', lang),
            style: theme.textTheme.titleSmall?.copyWith(
              color: isCorrect ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                _textController.clear();
                if (isLast) {
                  context.go('/deep-practice/${widget.listId}/result');
                } else {
                  ref.read(deepPracticeProvider.notifier).nextQuestion();
                  if (state.mode == 'deep_fill') {
                    _focusNode.requestFocus();
                  }
                }
              },
              icon: Icon(isLast ? Icons.emoji_events : Icons.arrow_forward),
              label: Text(
                isLast
                    ? AppStrings.get('see_results', lang)
                    : AppStrings.get('next', lang),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuitDialog(BuildContext context) {
    final state = ref.read(deepPracticeProvider);
    final lang = ref.read(languageProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.get('quit_practice_title', lang)),
        content: Text(
          '${AppStrings.get('answer_progress', lang, params: {'answered': state.answers.length.toString(), 'total': state.totalQuestions.toString()})} ${AppStrings.get('progress_lost', lang)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppStrings.get('continue_label', lang)),
          ),
          FilledButton(
            onPressed: () {
              ref.read(deepPracticeProvider.notifier).reset();
              Navigator.of(ctx).pop();
              context.go(widget.returnPath);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(AppStrings.get('quit', lang)),
          ),
        ],
      ),
    );
  }
}
