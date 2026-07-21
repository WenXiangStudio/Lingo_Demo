import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../data/providers.dart';
import '../providers/deep_practice_provider.dart';

class DeepPracticeQuizScreen extends ConsumerStatefulWidget {
  final int listId;
  final List<int> listIds;
  final String returnPath;

  const DeepPracticeQuizScreen({
    super.key,
    required this.listId,
    required this.listIds,
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
  int? _controllerQuestionIndex;
  bool? _controllerWasFeedback;

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitText() {
    final state = ref.read(deepPracticeProvider);
    if (state.phase != DeepPracticePhase.quiz || state.isEvaluatingAnswer) {
      return;
    }
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
        if (!mounted) return;
        GoRouter.of(context).replace(
          '/deep-practice/${widget.listId}/result?listIds=${widget.listIds.join(',')}&returnPath=${Uri.encodeComponent(widget.returnPath)}',
        );
      });
      return const SizedBox.shrink();
    }

    if (state.phase != DeepPracticePhase.quiz &&
        state.phase != DeepPracticePhase.feedback) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        GoRouter.of(context).replace(
          '/deep-practice/${widget.listId}/setup?listIds=${widget.listIds.join(',')}&returnPath=${Uri.encodeComponent(widget.returnPath)}',
        );
      });
      return const SizedBox.shrink();
    }

    final question = state.currentQuestion;
    if (question == null) {
      return Scaffold(
        body: Center(child: Text(AppStrings.get('no_questions', lang))),
      );
    }
    _syncTextController(state);
    final isCollocationFillFallback =
        state.mode == 'deep_choice' && question.answerOptions.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('${state.currentIndex + 1} / ${state.totalQuestions}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showQuitDialog(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: AppStrings.get('previous_question', lang),
            onPressed: state.currentIndex > 0
                ? () =>
                      ref.read(deepPracticeProvider.notifier).previousQuestion()
                : null,
          ),
        ],
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
              child: state.mode == 'deep_choice' && !isCollocationFillFallback
                  ? _buildChoiceQuestion(context, question, state, theme, lang)
                  : _buildFillQuestion(
                      context,
                      question,
                      state,
                      theme,
                      lang,
                      isCollocationFallback: isCollocationFillFallback,
                    ),
            ),
          ),
          if (state.phase == DeepPracticePhase.feedback)
            _buildFeedback(context, state, theme, lang),
        ],
      ),
    );
  }

  void _syncTextController(DeepPracticeState state) {
    final isFeedback = state.phase == DeepPracticePhase.feedback;
    if (_controllerQuestionIndex == state.currentIndex &&
        _controllerWasFeedback == isFeedback) {
      return;
    }
    _controllerQuestionIndex = state.currentIndex;
    _controllerWasFeedback = isFeedback;
    _textController.text = state.currentAnswer?.userAnswer ?? '';
    _textController.selection = TextSelection.collapsed(
      offset: _textController.text.length,
    );
  }

  Widget _buildChoiceQuestion(
    BuildContext context,
    DeepQuestion question,
    DeepPracticeState state,
    ThemeData theme,
    String lang,
  ) {
    final options = question.answerOptions;
    final showFeedback = state.phase == DeepPracticePhase.feedback;
    final answer = state.currentAnswer;

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          AppStrings.get('collocation_question', lang),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 16),
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
          final isSelected =
              answer?.userAnswer?.toLowerCase() == option.toLowerCase();
          Color? background;
          Color? border;
          if (showFeedback && isCorrectAnswer) {
            background = Colors.green.withValues(alpha: 0.1);
            border = Colors.green;
          } else if (showFeedback && isSelected) {
            background = Colors.red.withValues(alpha: 0.1);
            border = Colors.red;
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
                  backgroundColor: background,
                  side: BorderSide(
                    color:
                        border ??
                        theme.colorScheme.outline.withValues(alpha: 0.4),
                    width: border == null ? 1 : 2,
                  ),
                ),
                child: Text(option, style: theme.textTheme.titleMedium),
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
    String lang, {
    required bool isCollocationFallback,
  }) {
    final showFeedback = state.phase == DeepPracticePhase.feedback;
    final answer = state.currentAnswer;
    final verdict = answer?.verdict;

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          AppStrings.get(
            isCollocationFallback
                ? 'collocation_fill_question'
                : 'complete_sentence',
            lang,
          ),
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
        if (isCollocationFallback) ...[
          const SizedBox(height: 12),
          _InlineNotice(
            icon: Icons.info_outline,
            color: theme.colorScheme.primary,
            text: AppStrings.get(
              state.collocationOptionsDisabledBySetting
                  ? 'deep_collocation_fill_disabled_notice'
                  : 'deep_collocation_fill_notice',
              lang,
            ),
          ),
        ],
        const SizedBox(height: 24),
        TextField(
          controller: _textController,
          focusNode: _focusNode,
          enabled: !showFeedback && !state.isEvaluatingAnswer,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitText(),
          decoration: InputDecoration(
            hintText: AppStrings.get('type_missing_word', lang),
            prefixIcon: const Icon(Icons.edit_outlined),
            suffixIcon: _fillSuffixIcon(state, verdict),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        if (state.answerEvaluationErrorKey != null) ...[
          const SizedBox(height: 12),
          _InlineNotice(
            icon: Icons.error_outline,
            color: theme.colorScheme.error,
            text: AppStrings.get(
              state.answerEvaluationErrorKey!,
              lang,
              params: {'error': state.answerEvaluationErrorDetail ?? ''},
            ),
          ),
        ],
        if (!showFeedback) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.isEvaluatingAnswer ? null : _submitText,
              child: state.isEvaluatingAnswer
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(AppStrings.get('submit', lang)),
            ),
          ),
        ],
        if (showFeedback && answer != null) ...[
          const SizedBox(height: 20),
          _buildFillVerdictCard(question, answer, theme, lang),
        ],
      ],
    );
  }

  Widget? _fillSuffixIcon(DeepPracticeState state, DeepAnswerVerdict? verdict) {
    if (state.isEvaluatingAnswer) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (state.phase != DeepPracticePhase.feedback) {
      return IconButton(icon: const Icon(Icons.send), onPressed: _submitText);
    }
    switch (verdict) {
      case DeepAnswerVerdict.targetCorrect:
        return const Icon(Icons.check_circle, color: Colors.green);
      case DeepAnswerVerdict.acceptableAlternative:
        return const Icon(Icons.info, color: Colors.orange);
      case DeepAnswerVerdict.incorrect:
        return const Icon(Icons.cancel, color: Colors.red);
      case null:
        return null;
    }
  }

  Widget _buildFillVerdictCard(
    DeepQuestion question,
    DeepAnswerRecord answer,
    ThemeData theme,
    String lang,
  ) {
    final acceptable = answer.isAcceptableAlternative;
    final incorrect = answer.shouldRecordError;
    if (!acceptable && !incorrect && answer.feedback.isEmpty) {
      return const SizedBox.shrink();
    }
    final color = acceptable ? Colors.orange : Colors.green;
    final title = acceptable
        ? AppStrings.get(
            'deep_acceptable_alternative_message',
            lang,
            params: {'word': question.correctAnswer},
          )
        : AppStrings.get('correct_answer_label', lang);
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              acceptable ? Icons.info_outline : Icons.lightbulb_outline,
              color: color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.labelLarge),
                  if (acceptable || incorrect) ...[
                    const SizedBox(height: 4),
                    Text(
                      question.correctAnswer,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  if (answer.feedback.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(answer.feedback, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedback(
    BuildContext context,
    DeepPracticeState state,
    ThemeData theme,
    String lang,
  ) {
    final answer = state.currentAnswer!;
    final isLast = state.currentIndex + 1 >= state.totalQuestions;
    final (color, icon, label) = switch (answer.verdict) {
      DeepAnswerVerdict.targetCorrect => (
        Colors.green,
        Icons.check_circle,
        AppStrings.get('correct', lang),
      ),
      DeepAnswerVerdict.acceptableAlternative => (
        Colors.orange,
        Icons.info,
        AppStrings.get('deep_acceptable_alternative', lang),
      ),
      DeepAnswerVerdict.incorrect => (
        Colors.red,
        Icons.cancel,
        AppStrings.get('incorrect', lang),
      ),
    };
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border(top: BorderSide(color: color.withValues(alpha: 0.3))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (state.currentIndex > 0)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    ref.read(deepPracticeProvider.notifier).previousQuestion(),
                icon: const Icon(Icons.arrow_back),
                label: Text(AppStrings.get('previous_question', lang)),
              ),
            ),
          if (state.currentIndex > 0) const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                ref.read(deepPracticeProvider.notifier).editCurrentAnswer();
                _textController.text = answer.userAnswer ?? '';
                _textController.selection = TextSelection.collapsed(
                  offset: _textController.text.length,
                );
                if (_usesTextInput(state)) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _focusNode.requestFocus(),
                  );
                }
              },
              icon: const Icon(Icons.edit_outlined),
              label: Text(AppStrings.get('edit_answer', lang)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                ref.read(deepPracticeProvider.notifier).nextQuestion();
                if (!isLast && _usesTextInput(state)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final next = ref.read(deepPracticeProvider);
                    if (mounted && next.phase == DeepPracticePhase.quiz) {
                      _focusNode.requestFocus();
                    }
                  });
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

  bool _usesTextInput(DeepPracticeState state) {
    return state.mode != 'deep_choice' ||
        state.currentQuestion?.answerOptions.isEmpty == true;
  }

  void _showQuitDialog(BuildContext context) {
    final state = ref.read(deepPracticeProvider);
    final lang = ref.read(languageProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.get('quit_practice_title', lang)),
        content: Text(
          '${AppStrings.get('answer_progress', lang, params: {'answered': state.answeredCount.toString(), 'total': state.totalQuestions.toString()})} ${AppStrings.get('progress_lost', lang)}',
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

class _InlineNotice extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InlineNotice({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
