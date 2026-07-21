import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/services/tts_providers.dart';
import '../../../data/language_tool/language_tool_client.dart';
import '../../../data/models/ai_models.dart';
import '../../../data/providers.dart';
import '../providers/dialogue_provider.dart';

class DialogueScreen extends ConsumerStatefulWidget {
  final int listId;

  const DialogueScreen({super.key, required this.listId});

  @override
  ConsumerState<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends ConsumerState<DialogueScreen> {
  final _replyController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dialogueProvider.notifier).init(widget.listId);
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    final result = await ref.read(ttsServiceProvider).speak(text);
    if (!mounted || result.provider != 'doubao') return;
    final lang = ref.read(languageProvider);
    final key = switch (result.source) {
      'cache' => 'tts_played_doubao_cache',
      'api' => 'tts_played_doubao_api',
      'api_disabled_missing_cache' => 'tts_doubao_cache_missing_api_disabled',
      'api_failed' => 'tts_doubao_api_failed',
      _ => null,
    };
    if (key == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.get(key, lang)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _submitReply() async {
    final text = _replyController.text;
    _replyController.clear();
    await ref.read(dialogueProvider.notifier).sendReply(text);
    if (!mounted || !_scrollController.hasClients) return;
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted || !_scrollController.hasClients) return;
    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dialogueProvider);
    final lang = ref.watch(languageProvider);
    final theme = Theme.of(context);
    final canToggleTranslation = switch (state.phase) {
      DialoguePhase.active ||
      DialoguePhase.sending ||
      DialoguePhase.complete => true,
      _ => false,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('ai_dialogue_title', lang)),
        actions: [
          if (canToggleTranslation)
            IconButton(
              icon: Icon(
                state.showTranslation
                    ? Icons.translate
                    : Icons.translate_outlined,
              ),
              tooltip: AppStrings.get('toggle_translation', lang),
              onPressed: () =>
                  ref.read(dialogueProvider.notifier).toggleTranslation(),
            ),
        ],
      ),
      body: switch (state.phase) {
        DialoguePhase.setup => _buildSetup(context, state, lang, theme),
        DialoguePhase.starting => _buildBusy(
          context,
          AppStrings.get('dialogue_starting_practice', lang),
          theme,
        ),
        DialoguePhase.active ||
        DialoguePhase.sending ||
        DialoguePhase.complete => _buildPractice(context, state, lang, theme),
        DialoguePhase.error => _buildError(context, state, lang, theme),
      },
    );
  }

  Widget _buildSetup(
    BuildContext context,
    DialogueState state,
    String lang,
    ThemeData theme,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          AppStrings.get('dialogue_scenario', lang),
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<DialogueScenario>(
          initialValue: state.scenario,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: dialogueScenarios.map((scenario) {
            return DropdownMenuItem(
              value: scenario,
              child: Text(AppStrings.get(scenario.labelKey, lang)),
            );
          }).toList(),
          onChanged: (scenario) {
            if (scenario != null) {
              ref.read(dialogueProvider.notifier).setScenario(scenario);
            }
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.get(
                  'select_words_for_dialogue',
                  lang,
                  params: {'count': state.selectedWords.length.toString()},
                ),
                style: theme.textTheme.titleSmall,
              ),
            ),
            TextButton(
              onPressed: () =>
                  ref.read(dialogueProvider.notifier).selectRecommended(),
              child: Text(AppStrings.get('dialogue_select_recommended', lang)),
            ),
            TextButton(
              onPressed: () =>
                  ref.read(dialogueProvider.notifier).deselectAll(),
              child: Text(AppStrings.get('deselect_all', lang)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: state.words.map((word) {
            final isSelected = state.selectedWords.contains(word.english);
            return FilterChip(
              label: Text(word.english),
              selected: isSelected,
              onSelected: (_) =>
                  ref.read(dialogueProvider.notifier).toggleWord(word.english),
            );
          }).toList(),
        ),
        if (state.errorKey != null) ...[
          const SizedBox(height: 16),
          _InlineError(text: _errorText(state, lang), theme: theme),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: state.selectedWords.length < 3
                ? null
                : () => ref.read(dialogueProvider.notifier).startPractice(),
            icon: const Icon(Icons.forum),
            label: Text(AppStrings.get('dialogue_start_practice', lang)),
          ),
        ),
      ],
    );
  }

  Widget _buildBusy(BuildContext context, String label, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(label, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildPractice(
    BuildContext context,
    DialogueState state,
    String lang,
    ThemeData theme,
  ) {
    final isSending = state.phase == DialoguePhase.sending;
    final isComplete = state.phase == DialoguePhase.complete;
    return Column(
      children: [
        _PracticeHeader(state: state, lang: lang, theme: theme),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final message = state.messages[index];
              return _DialogueBubble(
                message: message,
                showTranslation: state.showTranslation,
                onSpeak: () => _speak(message.english),
                theme: theme,
              );
            },
          ),
        ),
        if (isSending)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        if (state.latestFeedback != null && !isSending)
          _FeedbackPanel(
            feedback: state.latestFeedback!,
            languageToolResult: state.latestLanguageToolResult,
            lang: lang,
            theme: theme,
          ),
        if (state.errorKey != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _InlineError(text: _errorText(state, lang), theme: theme),
          ),
        if (isComplete)
          _SummaryPanel(
            state: state,
            lang: lang,
            theme: theme,
            onPracticeAgain: () =>
                ref.read(dialogueProvider.notifier).startPractice(),
            onChangeSetup: () =>
                ref.read(dialogueProvider.notifier).backToSetup(),
          )
        else
          _ReplyComposer(
            controller: _replyController,
            enabled: state.canSend && !isSending,
            lang: lang,
            onSubmit: _submitReply,
          ),
      ],
    );
  }

  Widget _buildError(
    BuildContext context,
    DialogueState state,
    String lang,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorText(state, lang), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilledButton(
                  onPressed: () =>
                      ref.read(dialogueProvider.notifier).startPractice(),
                  child: Text(AppStrings.get('retry', lang)),
                ),
                OutlinedButton(
                  onPressed: () =>
                      ref.read(dialogueProvider.notifier).backToSetup(),
                  child: Text(AppStrings.get('dialogue_change_setup', lang)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _errorText(DialogueState state, String lang) {
    final key = state.errorKey ?? 'error';
    return AppStrings.get(key, lang, params: state.errorParams);
  }
}

class _PracticeHeader extends StatelessWidget {
  final DialogueState state;
  final String lang;
  final ThemeData theme;

  const _PracticeHeader({
    required this.state,
    required this.lang,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.35)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.title.isEmpty
                ? AppStrings.get('ai_dialogue_title', lang)
                : state.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _InfoChip(
                icon: Icons.loop,
                label: AppStrings.get(
                  'dialogue_turn_count',
                  lang,
                  params: {
                    'current': state.turnCount.toString(),
                    'total': state.maxTurns.toString(),
                  },
                ),
                theme: theme,
              ),
              _InfoChip(
                icon: Icons.check_circle_outline,
                label: AppStrings.get(
                  'dialogue_words_used_count',
                  lang,
                  params: {
                    'used': state.usedWords.length.toString(),
                    'total': state.selectedWords.length.toString(),
                  },
                ),
                theme: theme,
              ),
            ],
          ),
          if (state.nextTargetWords.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              AppStrings.get(
                'dialogue_try_words',
                lang,
                params: {'words': state.nextTargetWords.join(', ')},
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.primary),
          const SizedBox(width: 5),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _DialogueBubble extends StatelessWidget {
  final InteractiveDialogueMessage message;
  final bool showTranslation;
  final VoidCallback onSpeak;
  final ThemeData theme;

  const _DialogueBubble({
    required this.message,
    required this.showTranslation,
    required this.onSpeak,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = message.isUser
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final bubbleColor = message.isUser
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.55)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Text(
            message.speaker,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            message.english,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: onSpeak,
                          borderRadius: BorderRadius.circular(14),
                          child: Icon(
                            Icons.volume_up,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    if (showTranslation &&
                        message.chineseTranslation.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        message.chineseTranslation,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.62,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  final InteractiveDialogueFeedback feedback;
  final LanguageToolResult? languageToolResult;
  final String lang;
  final ThemeData theme;

  const _FeedbackPanel({
    required this.feedback,
    required this.languageToolResult,
    required this.lang,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('dialogue_feedback', lang),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _ScorePill(
                label: AppStrings.get('dialogue_naturalness', lang),
                score: feedback.naturalnessScore,
                theme: theme,
              ),
              _ScorePill(
                label: AppStrings.get('dialogue_context_fit', lang),
                score: feedback.contextFitScore,
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            feedback.usedWords.isEmpty
                ? AppStrings.get('dialogue_no_words_used', lang)
                : AppStrings.get(
                    'dialogue_used_words',
                    lang,
                    params: {'words': feedback.usedWords.join(', ')},
                  ),
            style: theme.textTheme.bodySmall,
          ),
          if (languageToolResult != null) ...[
            const SizedBox(height: 8),
            _LanguageToolPanel(
              result: languageToolResult!,
              lang: lang,
              theme: theme,
            ),
          ],
          if (feedback.chineseExplanation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(feedback.chineseExplanation, style: theme.textTheme.bodySmall),
          ],
          if (feedback.correction.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              AppStrings.get(
                'dialogue_correction',
                lang,
                params: {'text': feedback.correction},
              ),
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (feedback.betterVersion.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              AppStrings.get(
                'dialogue_better_version',
                lang,
                params: {'text': feedback.betterVersion},
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LanguageToolPanel extends StatelessWidget {
  final LanguageToolResult result;
  final String lang;
  final ThemeData theme;

  const _LanguageToolPanel({
    required this.result,
    required this.lang,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final matches = result.matches.take(3).toList(growable: false);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.rule,
                size: 16,
                color: result.checked
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
              ),
              const SizedBox(width: 6),
              Text(
                AppStrings.get('language_tool_title', lang),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (!result.checked)
            Text(
              AppStrings.get(
                'language_tool_unavailable',
                lang,
                params: {'error': result.errorMessage ?? ''},
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            )
          else if (matches.isEmpty)
            Text(
              AppStrings.get('language_tool_no_issues', lang),
              style: theme.textTheme.bodySmall,
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: matches.map((match) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _LanguageToolMatchLine(
                    match: match,
                    lang: lang,
                    theme: theme,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _LanguageToolMatchLine extends StatelessWidget {
  final LanguageToolMatch match;
  final String lang;
  final ThemeData theme;

  const _LanguageToolMatchLine({
    required this.match,
    required this.lang,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final issueText = match.issueText;
    final message = issueText.isEmpty
        ? match.displayMessage
        : AppStrings.get(
            'language_tool_issue',
            lang,
            params: {'issue': issueText, 'message': match.displayMessage},
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message, style: theme.textTheme.bodySmall),
        if (match.replacements.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            AppStrings.get(
              'language_tool_suggestions',
              lang,
              params: {'suggestions': match.replacements.take(3).join(', ')},
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String label;
  final int score;
  final ThemeData theme;

  const _ScorePill({
    required this.label,
    required this.score,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$label $score/5', style: theme.textTheme.labelSmall),
    );
  }
}

class _ReplyComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final String lang;
  final VoidCallback onSubmit;

  const _ReplyComposer({
    required this.controller,
    required this.enabled,
    required this.lang,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: AppStrings.get('dialogue_reply_hint', lang),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: enabled ? (_) => onSubmit() : null,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: enabled ? onSubmit : null,
              icon: const Icon(Icons.send),
              tooltip: AppStrings.get('dialogue_send', lang),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  final DialogueState state;
  final String lang;
  final ThemeData theme;
  final VoidCallback onPracticeAgain;
  final VoidCallback onChangeSetup;

  const _SummaryPanel({
    required this.state,
    required this.lang,
    required this.theme,
    required this.onPracticeAgain,
    required this.onChangeSetup,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.35)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.get('dialogue_complete_title', lang),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.get(
                'dialogue_summary',
                lang,
                params: {
                  'turns': state.turnCount.toString(),
                  'used': state.usedWords.length.toString(),
                  'total': state.selectedWords.length.toString(),
                },
              ),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onPracticeAgain,
                  icon: const Icon(Icons.replay),
                  label: Text(AppStrings.get('dialogue_practice_again', lang)),
                ),
                OutlinedButton.icon(
                  onPressed: onChangeSetup,
                  icon: const Icon(Icons.tune),
                  label: Text(AppStrings.get('dialogue_change_setup', lang)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String text;
  final ThemeData theme;

  const _InlineError({required this.text, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
    );
  }
}
