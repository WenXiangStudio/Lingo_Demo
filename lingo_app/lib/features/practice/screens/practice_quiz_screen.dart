import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/services/tts_providers.dart';
import '../../../core/utils/answer_checker.dart';
import '../../../data/database/app_database.dart';
import '../../../data/providers.dart';
import '../../lists/providers/list_provider.dart';
import '../../review_center/providers/review_center_provider.dart';
import '../providers/practice_provider.dart';

class PracticeQuizScreen extends ConsumerStatefulWidget {
  final int listId;
  final String returnPath;

  const PracticeQuizScreen({
    super.key,
    required this.listId,
    required this.returnPath,
  });

  @override
  ConsumerState<PracticeQuizScreen> createState() => _PracticeQuizScreenState();
}

class _PracticeQuizScreenState extends ConsumerState<PracticeQuizScreen> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final Set<int> _cueMemoryWordIds = <int>{};
  final Set<int> _forgottenWordIds = <int>{};

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    final result = await ref.read(ttsServiceProvider).speakWord(text);
    if (!mounted || result.played) return;
    final lang = ref.read(languageProvider);
    final key = _wordAudioErrorKey(result.provider, result.source);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.get(key, lang, params: {'msg': result.message ?? ''}),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _wordAudioErrorKey(String provider, String source) {
    if (provider == 'remote_word_audio') {
      return switch (source) {
        'remote_not_configured' => 'word_audio_server_not_configured',
        'remote_invalid_url' => 'word_audio_server_invalid_url',
        'remote_not_found' => 'word_audio_file_not_found',
        'remote_timeout' => 'word_audio_timeout',
        'remote_invalid_audio' => 'word_audio_invalid_file',
        'blocked' => 'word_audio_busy',
        'not_ready' => 'word_audio_not_ready',
        _ => 'word_audio_unavailable',
      };
    }

    if (provider == 'qwen') {
      return switch (source) {
        'not_configured' => 'tts_qwen_not_configured',
        'api_failed' => 'tts_qwen_api_failed_detail',
        'blocked' => 'word_audio_busy',
        'not_ready' => 'word_audio_not_ready',
        _ => 'word_audio_direct_failed',
      };
    }

    if (provider == 'doubao') {
      return switch (source) {
        'not_configured' => 'word_audio_direct_not_configured',
        'api_disabled_missing_cache' => 'tts_doubao_cache_missing_api_disabled',
        'api_failed' => 'tts_doubao_api_failed',
        'blocked' => 'word_audio_busy',
        'not_ready' => 'word_audio_not_ready',
        _ => 'word_audio_direct_failed',
      };
    }

    return switch (source) {
      'not_configured' => 'word_audio_direct_not_configured',
      'blocked' => 'word_audio_busy',
      'not_ready' => 'word_audio_not_ready',
      _ => 'word_audio_direct_failed',
    };
  }

  void _submitText() {
    final state = ref.read(practiceProvider);
    if (state.phase != PracticePhase.quiz) return;
    ref.read(practiceProvider.notifier).submitTextAnswer(_textController.text);
    _focusNode.unfocus();
  }

  void _revealPracticeExample() {
    ref.read(practiceProvider.notifier).revealCurrentExample();
  }

  Future<void> _markCueMemory(Word word, int listId) async {
    final recordedIds =
        ref.read(cueMemoryWordIdsProvider(listId)).valueOrNull ?? const <int>{};
    final needsPersist = !recordedIds.contains(word.id);
    if (!_cueMemoryWordIds.contains(word.id)) {
      setState(() => _cueMemoryWordIds.add(word.id));
    }
    if (!needsPersist) return;
    try {
      await ref
          .read(practiceRepositoryProvider)
          .markWordCueMemory(word.id, listId);
    } catch (_) {
      if (mounted) {
        setState(() => _cueMemoryWordIds.remove(word.id));
      }
      return;
    }
    ref.invalidate(cueMemoryWordIdsProvider(listId));
    ref.invalidate(reviewCenterDataProvider);
  }

  Future<void> _markCompletelyForgotten(Word word, int listId) async {
    final recordedIds =
        ref.read(forgottenWordIdsProvider(listId)).valueOrNull ?? const <int>{};
    if (_forgottenWordIds.contains(word.id) || recordedIds.contains(word.id)) {
      return;
    }
    await ref
        .read(practiceRepositoryProvider)
        .markWordForgotten(word.id, listId);
    if (!mounted) return;
    setState(() => _forgottenWordIds.add(word.id));
    ref.invalidate(forgottenWordIdsProvider(listId));
    ref.invalidate(forgottenWordsProvider(listId));
    ref.invalidate(reviewCenterDataProvider);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(practiceProvider);
    final lang = ref.watch(languageProvider);
    final theme = Theme.of(context);

    // Guard: redirect to setup if no session
    if (state.phase == PracticePhase.setup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          GoRouter.of(context).replace(
            '/practice/${widget.listId}/setup?returnPath=${Uri.encodeComponent(widget.returnPath)}',
          );
        }
      });
      return const SizedBox.shrink();
    }

    // Guard: redirect to result if finished
    if (state.phase == PracticePhase.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          GoRouter.of(context).replace(
            '/practice/${widget.listId}/result?returnPath=${Uri.encodeComponent(widget.returnPath)}',
          );
        }
      });
      return const SizedBox.shrink();
    }

    final word = state.currentWord;
    if (word == null) {
      return Scaffold(
        body: Center(child: Text(AppStrings.get('no_words_practice', lang))),
      );
    }

    final isChoiceLike =
        state.mode == PracticeMode.choice ||
        state.mode == PracticeMode.audioChoice;

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
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value:
                    (state.currentIndex +
                        (state.phase == PracticePhase.feedback ? 1 : 0)) /
                    state.totalQuestions,
                minHeight: 4,
              ),
            ),
          ),

          // Question area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: isChoiceLike
                  ? _buildChoiceQuestion(context, word, state, theme, lang)
                  : _buildTextQuestion(context, word, state, theme, lang),
            ),
          ),

          // Feedback area
          if (state.phase == PracticePhase.feedback)
            _buildFeedback(context, state, theme, lang),
        ],
      ),
    );
  }

  /// English-word header card. When [obscured] is true, hides the word as
  /// "•••" placeholder per design ("选择/输入过程中不显示单词").
  Widget _buildWordCard(
    BuildContext context,
    Word word,
    ThemeData theme, {
    required bool obscured,
    bool showPronunciation = true,
    bool showAudioButton = false,
    String? audioTooltip,
  }) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          children: [
            Text(
              obscured ? '• • •' : word.english,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: obscured ? 6 : null,
                color: obscured
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.35)
                    : null,
              ),
              textAlign: TextAlign.center,
            ),
            if (!obscured &&
                showPronunciation &&
                word.pronunciation != null &&
                word.pronunciation!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '/${word.pronunciation}/',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            if (!obscured && showAudioButton)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: IconButton.filledTonal(
                  onPressed: () => _speak(word.english),
                  icon: const Icon(Icons.volume_up),
                  tooltip: audioTooltip,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _audioButton(BuildContext context, Word word, ThemeData theme) {
    return Center(
      child: IconButton.filled(
        onPressed: () => _speak(word.english),
        iconSize: 48,
        icon: const Icon(Icons.volume_up),
        style: IconButton.styleFrom(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.primary,
          minimumSize: const Size(80, 80),
        ),
      ),
    );
  }

  // ─── Choice / Audio-choice question ─────────────────────────────────────────

  Widget _buildChoiceQuestion(
    BuildContext context,
    Word word,
    PracticeState state,
    ThemeData theme,
    String lang,
  ) {
    final options = state.currentOptions ?? [];
    final showFeedback = state.phase == PracticePhase.feedback;
    final correctAnswer = word.chineseMeanings;
    final isAudio = state.mode == PracticeMode.audioChoice;
    final shouldObscure = isAudio && !showFeedback;
    final cueMemoryWordIds =
        ref.watch(cueMemoryWordIdsProvider(widget.listId)).valueOrNull ??
        const <int>{};
    final forgottenWordIds =
        ref.watch(forgottenWordIdsProvider(widget.listId)).valueOrNull ??
        const <int>{};
    final isCueMemoryRevealed = _cueMemoryWordIds.contains(word.id);
    final isCueMemoryRecorded = cueMemoryWordIds.contains(word.id);
    final isCompletelyForgotten =
        _forgottenWordIds.contains(word.id) ||
        forgottenWordIds.contains(word.id);
    final selectedAnswer = state.answers.isEmpty
        ? null
        : state.answers.last.userAnswer;

    return Column(
      children: [
        const SizedBox(height: 16),
        if (isAudio) ...[
          _audioButton(context, word, theme),
          const SizedBox(height: 12),
          Text(
            AppStrings.get(
              shouldObscure ? 'word_obscured_hint' : 'listen_then_choose',
              lang,
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
        _buildWordCard(
          context,
          word,
          theme,
          obscured: shouldObscure,
          showAudioButton: !isAudio,
          audioTooltip: AppStrings.get('pronounce', lang),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.get(
            isAudio ? 'listen_then_choose' : 'choose_meaning',
            lang,
          ),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () =>
                  _markCueMemory(word, state.listId ?? widget.listId),
              icon: Icon(
                isCueMemoryRecorded
                    ? Icons.bookmark
                    : Icons.bookmark_add_outlined,
              ),
              label: Text(
                AppStrings.get(
                  isCueMemoryRecorded
                      ? 'cue_memory_marked'
                      : 'cue_memory_button',
                  lang,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: isCompletelyForgotten
                  ? null
                  : () => _markCompletelyForgotten(
                      word,
                      state.listId ?? widget.listId,
                    ),
              icon: Icon(
                isCompletelyForgotten ? Icons.flag : Icons.flag_outlined,
              ),
              label: Text(AppStrings.get('completely_forgotten', lang)),
            ),
          ],
        ),
        _buildPracticeExample(
          word,
          theme,
          obscured: !showFeedback && !isCueMemoryRevealed,
        ),
        const SizedBox(height: 24),
        ...options.map((option) {
          final isCorrectAnswer = AnswerChecker.isChoiceAnswerCorrect(
            option,
            correctAnswer,
          );
          return _BlurredChoiceOption(
            key: ValueKey('${state.currentIndex}:$option'),
            option: option,
            showFeedback: showFeedback,
            isCorrectAnswer: isCorrectAnswer,
            isIncorrectSelected:
                showFeedback && !isCorrectAnswer && option == selectedAnswer,
            forceRevealed: isCueMemoryRevealed,
            theme: theme,
            onSubmit: () =>
                ref.read(practiceProvider.notifier).submitChoiceAnswer(option),
          );
        }),
      ],
    );
  }

  // ─── Text question (fill / dictation) ───────────────────────────────────────

  Widget _buildTextQuestion(
    BuildContext context,
    Word word,
    PracticeState state,
    ThemeData theme,
    String lang,
  ) {
    final showFeedback = state.phase == PracticePhase.feedback;
    final lastAnswer = state.answers.isNotEmpty ? state.answers.last : null;
    final isDictation = state.mode == PracticeMode.dictation;
    final isFill = state.mode == PracticeMode.fill;
    final isExampleCueTracking = isFill && state.trackExampleReveals;
    final isExampleRevealed =
        state.revealedExampleWordIds.contains(word.id) || showFeedback;
    final forgottenWordIds =
        ref.watch(forgottenWordIdsProvider(widget.listId)).valueOrNull ??
        const <int>{};
    final isCompletelyForgotten =
        _forgottenWordIds.contains(word.id) ||
        forgottenWordIds.contains(word.id);

    return Column(
      children: [
        const SizedBox(height: 16),

        // Dictation: TTS play button + obscured word card; show word once in
        // feedback phase per design ("选择完成后才显示完整单词").
        if (isDictation) ...[
          _audioButton(context, word, theme),
          const SizedBox(height: 8),
          Text(
            AppStrings.get(
              showFeedback ? 'listen_then_choose' : 'tap_listen',
              lang,
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildWordCard(context, word, theme, obscured: !showFeedback),
          const SizedBox(height: 16),
        ],

        // Fill mode: show English word
        if (isFill) ...[
          Card(
            elevation: 0,
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: Column(
                children: [
                  Text(
                    word.english,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  IconButton.filledTonal(
                    onPressed: () => _speak(word.english),
                    icon: const Icon(Icons.volume_up),
                    tooltip: AppStrings.get('pronounce', lang),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildPracticeExample(
            word,
            theme,
            obscured: isExampleCueTracking && !isExampleRevealed,
            canReveal: isExampleCueTracking && !showFeedback,
            onReveal: _revealPracticeExample,
            revealLabel: AppStrings.get('reveal_example', lang),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.get('type_chinese', lang),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
        ],

        if (isFill && !showFeedback)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: OutlinedButton.icon(
              onPressed: isCompletelyForgotten
                  ? null
                  : () => _markCompletelyForgotten(
                      word,
                      state.listId ?? widget.listId,
                    ),
              icon: Icon(
                isCompletelyForgotten ? Icons.flag : Icons.flag_outlined,
              ),
              label: Text(AppStrings.get('completely_forgotten', lang)),
            ),
          ),

        // Text input
        TextField(
          controller: _textController,
          focusNode: _focusNode,
          enabled: !showFeedback,
          autofocus: !isDictation,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitText(),
          decoration: InputDecoration(
            hintText: AppStrings.get('enter_chinese_hint', lang),
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

        // Show correct answer in feedback
        if (showFeedback && lastAnswer != null && !lastAnswer.isCorrect) ...[
          const SizedBox(height: 24),
          Card(
            color: Colors.green.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
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
                  ),
                ],
              ),
            ),
          ),
        ],

        if (showFeedback &&
            lastAnswer != null &&
            isFill &&
            !lastAnswer.isCorrect)
          _buildInvalidFillParts(lastAnswer, theme, lang),

        // Show missing meanings for fill / dictation mode (multi-meaning feedback)
        if (showFeedback &&
            lastAnswer != null &&
            (state.mode == PracticeMode.fill ||
                state.mode == PracticeMode.dictation))
          _buildMissingMeanings(context, word, lastAnswer, theme, lang),
      ],
    );
  }

  Widget _buildPracticeExample(
    Word word,
    ThemeData theme, {
    required bool obscured,
    bool canReveal = false,
    VoidCallback? onReveal,
    String? revealLabel,
  }) {
    final example = word.scenarioExample?.trim().isNotEmpty == true
        ? word.scenarioExample!.trim()
        : word.exampleSentence?.trim();
    if (example == null || example.isEmpty) return const SizedBox.shrink();
    final text = Text(
      example,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
      ),
      textAlign: TextAlign.left,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(8),
        ),
        child: obscured
            ? Stack(
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: text,
                  ),
                  Positioned.fill(
                    child: canReveal
                        ? Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onReveal,
                              borderRadius: BorderRadius.circular(8),
                              child: Center(
                                child: IconButton.filledTonal(
                                  onPressed: onReveal,
                                  icon: const Icon(Icons.visibility_outlined),
                                  tooltip: revealLabel,
                                ),
                              ),
                            ),
                          )
                        : DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withValues(
                                alpha: 0.55,
                              ),
                            ),
                          ),
                  ),
                ],
              )
            : text,
      ),
    );
  }

  Widget _buildMissingMeanings(
    BuildContext context,
    Word word,
    AnswerRecord lastAnswer,
    ThemeData theme,
    String lang,
  ) {
    final missing = AnswerChecker.missingMeanings(
      lastAnswer.userAnswer ?? '',
      word.chineseMeanings,
    );
    if (missing.isEmpty) return const SizedBox.shrink();

    final label = lastAnswer.isCorrect
        ? AppStrings.get('also_means', lang)
        : AppStrings.get('missing_meanings', lang);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        color: Colors.orange.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      missing.join(' ； '),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvalidFillParts(
    AnswerRecord lastAnswer,
    ThemeData theme,
    String lang,
  ) {
    final invalidParts = AnswerChecker.invalidFillAnswerParts(
      lastAnswer.userAnswer ?? '',
      lastAnswer.correctAnswer,
    );
    if (invalidParts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Text(
              AppStrings.get('invalid_meanings', lang),
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.red.shade700,
              ),
            ),
            ...invalidParts.map(
              (part) => Text(
                part,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Feedback panel ─────────────────────────────────────────────────────────

  Widget _buildFeedback(
    BuildContext context,
    PracticeState state,
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
                  ref.read(practiceProvider.notifier).nextQuestion();
                } else {
                  ref.read(practiceProvider.notifier).nextQuestion();
                  if (state.mode == PracticeMode.dictation ||
                      state.mode == PracticeMode.audioChoice) {
                    _focusNode.unfocus();
                  } else if (state.mode == PracticeMode.fill) {
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
    final lang = ref.read(languageProvider);
    final state = ref.read(practiceProvider);
    if (state.phase == PracticePhase.feedback ||
        state.phase == PracticePhase.quiz) {
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
                ref.read(practiceProvider.notifier).reset();
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  context.go(widget.returnPath);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(AppStrings.get('quit', lang)),
            ),
          ],
        ),
      );
    } else {
      ref.read(practiceProvider.notifier).reset();
      context.go(widget.returnPath);
    }
  }
}

class _BlurredChoiceOption extends StatefulWidget {
  final String option;
  final bool showFeedback;
  final bool isCorrectAnswer;
  final bool isIncorrectSelected;
  final bool forceRevealed;
  final ThemeData theme;
  final VoidCallback onSubmit;

  const _BlurredChoiceOption({
    super.key,
    required this.option,
    required this.showFeedback,
    required this.isCorrectAnswer,
    required this.isIncorrectSelected,
    required this.forceRevealed,
    required this.theme,
    required this.onSubmit,
  });

  @override
  State<_BlurredChoiceOption> createState() => _BlurredChoiceOptionState();
}

class _BlurredChoiceOptionState extends State<_BlurredChoiceOption> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final isObscured =
        !widget.showFeedback && !widget.forceRevealed && !_revealed;
    Color? backgroundColor;
    Color? borderColor;
    if (widget.showFeedback && widget.isCorrectAnswer) {
      backgroundColor = Colors.green.withValues(alpha: 0.1);
      borderColor = Colors.green;
    } else if (widget.showFeedback && widget.isIncorrectSelected) {
      backgroundColor = Colors.red.withValues(alpha: 0.1);
      borderColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: widget.showFeedback
              ? null
              : () {
                  if (!widget.forceRevealed && !_revealed) {
                    setState(() => _revealed = true);
                    return;
                  }
                  widget.onSubmit();
                },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: backgroundColor,
            side: BorderSide(
              color: borderColor ?? widget.theme.colorScheme.outline,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            children: [
              if (widget.showFeedback && widget.isCorrectAnswer)
                const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                )
              else if (widget.showFeedback && widget.isIncorrectSelected)
                const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(Icons.cancel, color: Colors.red, size: 20),
                ),
              Expanded(
                child: isObscured
                    ? Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                            child: Text(
                              widget.option,
                              style: widget.theme.textTheme.bodyLarge,
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: widget.theme.colorScheme.surface
                                    .withValues(alpha: 0.55),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        widget.option,
                        style: widget.theme.textTheme.bodyLarge,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
