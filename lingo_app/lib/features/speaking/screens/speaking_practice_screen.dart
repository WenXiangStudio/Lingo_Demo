import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/services/tts_providers.dart';
import '../../../data/providers.dart';
import '../models/speaking_models.dart';
import '../providers/speaking_provider.dart';
import '../services/speaking_asr_model_manager.dart';

class SpeakingPracticeScreen extends ConsumerStatefulWidget {
  const SpeakingPracticeScreen({
    super.key,
    required this.listId,
    required this.returnPath,
  });

  final int listId;
  final String returnPath;

  @override
  ConsumerState<SpeakingPracticeScreen> createState() =>
      _SpeakingPracticeScreenState();
}

class _SpeakingPracticeScreenState
    extends ConsumerState<SpeakingPracticeScreen> {
  final _transcriptController = TextEditingController();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(speakingProvider.notifier).init(widget.listId);
      ref.read(speakingAsrModelManagerProvider).checkStatus();
    });
  }

  @override
  void dispose() {
    unawaited(ref.read(ttsServiceProvider).stop());
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) return;
    setState(() => _isSpeaking = true);
    try {
      final result = await ref.read(ttsServiceProvider).speakCustomText(text);
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
    } finally {
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
    }
  }

  void _syncTranscriptField(SpeakingState state) {
    if (_transcriptController.text == state.currentTranscript) return;
    _transcriptController.value = TextEditingValue(
      text: state.currentTranscript,
      selection: TextSelection.collapsed(
        offset: state.currentTranscript.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(speakingProvider);
    final asrModelState = ref.watch(speakingAsrModelStateProvider);
    final lang = ref.watch(languageProvider);
    final theme = Theme.of(context);
    _syncTranscriptField(state);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('speaking_practice', lang)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(speakingProvider.notifier).reset();
            context.go(widget.returnPath);
          },
        ),
      ),
      body: switch (state.phase) {
        SpeakingPhase.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        SpeakingPhase.error => _ErrorState(
          message: state.error == 'no_speaking_prompts'
              ? AppStrings.get('no_speaking_prompts', lang)
              : state.error ?? AppStrings.get('error', lang),
          lang: lang,
          onRetry: () =>
              ref.read(speakingProvider.notifier).init(widget.listId),
        ),
        SpeakingPhase.finished => _FinishedState(
          score: state.averageScore,
          lang: lang,
          onDone: () {
            ref.read(speakingProvider.notifier).reset();
            context.go(widget.returnPath);
          },
        ),
        _ => _PracticeBody(
          state: state,
          asrModelState: asrModelState,
          lang: lang,
          theme: theme,
          controller: _transcriptController,
          isSpeaking: _isSpeaking,
          onSpeak: _speak,
          onTranscriptChanged: (value) =>
              ref.read(speakingProvider.notifier).updateTranscript(value),
          onAssess: () =>
              ref.read(speakingProvider.notifier).assessCurrentTranscript(),
          onStartRecording: () =>
              ref.read(speakingProvider.notifier).startRecording(),
          onStopRecording: () => ref
              .read(speakingProvider.notifier)
              .stopRecordingAndAssess(language: 'en'),
          onDownloadModel: () =>
              ref.read(speakingAsrModelManagerProvider).downloadModel(),
          onNext: () => ref.read(speakingProvider.notifier).nextPrompt(),
        ),
      },
    );
  }
}

class _PracticeBody extends StatelessWidget {
  const _PracticeBody({
    required this.state,
    required this.asrModelState,
    required this.lang,
    required this.theme,
    required this.controller,
    required this.isSpeaking,
    required this.onSpeak,
    required this.onTranscriptChanged,
    required this.onAssess,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onDownloadModel,
    required this.onNext,
  });

  final SpeakingState state;
  final AsyncValue<SpeakingAsrModelState> asrModelState;
  final String lang;
  final ThemeData theme;
  final TextEditingController controller;
  final bool isSpeaking;
  final Future<void> Function(String text) onSpeak;
  final ValueChanged<String> onTranscriptChanged;
  final VoidCallback onAssess;
  final Future<void> Function() onStartRecording;
  final Future<void> Function() onStopRecording;
  final Future<void> Function() onDownloadModel;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final prompt = state.currentPrompt!;
    final result =
        state.phase == SpeakingPhase.feedback && state.results.isNotEmpty
        ? state.results.last
        : null;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: state.totalQuestions == 0
                  ? 0
                  : (state.currentIndex +
                            (state.phase == SpeakingPhase.feedback ? 1 : 0)) /
                        state.totalQuestions,
              minHeight: 4,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text(
                '${state.currentIndex + 1} / ${state.totalQuestions}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.25,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton.filledTonal(
                        onPressed:
                            state.phase == SpeakingPhase.recording ||
                                state.phase == SpeakingPhase.recognizing ||
                                isSpeaking
                            ? null
                            : () => onSpeak(prompt.referenceText),
                        icon: const Icon(Icons.volume_up),
                        tooltip: AppStrings.get('pronounce_example', lang),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          prompt.referenceText,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (result == null)
                _RecordingInput(
                  state: state,
                  asrModelState: asrModelState,
                  controller: controller,
                  lang: lang,
                  onChanged: onTranscriptChanged,
                  onAssess: onAssess,
                  onStartRecording: onStartRecording,
                  onStopRecording: onStopRecording,
                  onDownloadModel: onDownloadModel,
                  isSpeaking: isSpeaking,
                )
              else
                _ResultPanel(result: result, lang: lang, theme: theme),
            ],
          ),
        ),
        if (result != null)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onNext,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(AppStrings.get('continue_label', lang)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RecordingInput extends StatelessWidget {
  const _RecordingInput({
    required this.state,
    required this.asrModelState,
    required this.controller,
    required this.lang,
    required this.onChanged,
    required this.onAssess,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onDownloadModel,
    required this.isSpeaking,
  });

  final SpeakingState state;
  final AsyncValue<SpeakingAsrModelState> asrModelState;
  final TextEditingController controller;
  final String lang;
  final ValueChanged<String> onChanged;
  final VoidCallback onAssess;
  final Future<void> Function() onStartRecording;
  final Future<void> Function() onStopRecording;
  final Future<void> Function() onDownloadModel;
  final bool isSpeaking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modelState = asrModelState.valueOrNull;
    final modelReady = modelState is SpeakingAsrModelReady;
    final isRecording = state.phase == SpeakingPhase.recording;
    final isRecognizing = state.phase == SpeakingPhase.recognizing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AsrModelPanel(
          state: modelState,
          isLoading: asrModelState.isLoading,
          lang: lang,
          onDownloadModel: onDownloadModel,
        ),
        const SizedBox(height: 18),
        Center(
          child: SizedBox(
            width: 112,
            height: 112,
            child: FilledButton(
              onPressed: !modelReady || isRecognizing || isSpeaking
                  ? null
                  : () {
                      if (isRecording) {
                        onStopRecording();
                      } else {
                        onStartRecording();
                      }
                    },
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Icon(isRecording ? Icons.stop : Icons.mic, size: 44),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: Text(
            _recordingStatusText(
              lang: lang,
              modelReady: modelReady,
              isRecording: isRecording,
              isRecognizing: isRecognizing,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (isRecognizing) ...[
          const SizedBox(height: 12),
          const Center(child: CircularProgressIndicator()),
        ],
        if (state.actionError != null) ...[
          const SizedBox(height: 12),
          Text(
            _actionErrorText(state.actionError!, lang),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 18),
        TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: AppStrings.get('speaking_transcript_label', lang),
            hintText: AppStrings.get('speaking_transcript_hint', lang),
            border: const OutlineInputBorder(),
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.get('speaking_asr_ready_hint', lang),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: controller.text.trim().isEmpty ? null : onAssess,
          icon: const Icon(Icons.fact_check_outlined),
          label: Text(AppStrings.get('check_answer', lang)),
        ),
      ],
    );
  }

  static String _recordingStatusText({
    required String lang,
    required bool modelReady,
    required bool isRecording,
    required bool isRecognizing,
  }) {
    if (!modelReady) return AppStrings.get('speaking_asr_model_needed', lang);
    if (isRecognizing) return AppStrings.get('speaking_recognizing', lang);
    if (isRecording) return AppStrings.get('speaking_recording', lang);
    return AppStrings.get('speaking_tap_record', lang);
  }

  static String _actionErrorText(String code, String lang) {
    final key = switch (code) {
      'speaking_mic_permission_denied' => 'speaking_mic_permission_denied',
      'speaking_recording_failed' => 'speaking_recording_failed',
      'asr_model_not_downloaded' => 'speaking_asr_model_not_downloaded',
      'asr_empty_audio' => 'speaking_asr_empty_audio',
      'asr_empty_transcript' => 'speaking_asr_empty_transcript',
      _ => null,
    };
    if (key == null) {
      return AppStrings.get(
        'speaking_action_failed',
        lang,
        params: {'msg': code},
      );
    }
    return AppStrings.get(key, lang);
  }
}

class _AsrModelPanel extends StatelessWidget {
  const _AsrModelPanel({
    required this.state,
    required this.isLoading,
    required this.lang,
    required this.onDownloadModel,
  });

  final SpeakingAsrModelState? state;
  final bool isLoading;
  final String lang;
  final Future<void> Function() onDownloadModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = state;

    if (isLoading && current == null) {
      return const Center(child: LinearProgressIndicator());
    }

    if (current is SpeakingAsrModelReady) {
      return _AsrStatusCard(
        icon: Icons.check_circle_outline,
        title: AppStrings.get('speaking_asr_model_ready', lang),
        body: AppStrings.get('speaking_asr_model_ready_desc', lang),
        color: theme.colorScheme.primary,
      );
    }

    if (current is SpeakingAsrModelDownloading) {
      final percent = (current.progress * 100).clamp(0, 100).round();
      return Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.55,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.get(
                  'speaking_asr_model_downloading',
                  lang,
                  params: {'progress': percent.toString()},
                ),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(value: current.progress.clamp(0, 1)),
            ],
          ),
        ),
      );
    }

    if (current is SpeakingAsrModelError) {
      return _AsrStatusCard(
        icon: Icons.error_outline,
        title: AppStrings.get('speaking_asr_model_error', lang),
        body: _downloadErrorText(current.code, lang),
        color: theme.colorScheme.error,
        buttonLabel: AppStrings.get('speaking_asr_retry_download', lang),
        onPressed: onDownloadModel,
      );
    }

    return _AsrStatusCard(
      icon: Icons.download_outlined,
      title: AppStrings.get('speaking_asr_model_not_downloaded', lang),
      body: AppStrings.get('speaking_asr_model_desc', lang),
      color: theme.colorScheme.tertiary,
      buttonLabel: AppStrings.get('speaking_asr_download_model', lang),
      onPressed: onDownloadModel,
    );
  }

  static String _downloadErrorText(String code, String lang) {
    final key = switch (code) {
      'asr_download_network_error' => 'speaking_asr_download_network_error',
      'asr_download_verification_failed' =>
        'speaking_asr_download_verification_failed',
      'asr_model_verification_failed' =>
        'speaking_asr_download_verification_failed',
      'asr_download_disk_error' => 'speaking_asr_download_disk_error',
      'asr_download_unknown_error' => 'speaking_asr_download_unknown_error',
      _ => 'speaking_asr_download_unknown_error',
    };
    return AppStrings.get(key, lang);
  }
}

class _AsrStatusCard extends StatelessWidget {
  const _AsrStatusCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
    this.buttonLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;
  final String? buttonLabel;
  final Future<void> Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.68,
                      ),
                    ),
                  ),
                  if (buttonLabel != null && onPressed != null) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: onPressed,
                      icon: const Icon(Icons.download),
                      label: Text(buttonLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.result,
    required this.lang,
    required this.theme,
  });

  final SpeakingAssessmentResult result;
  final String lang;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final score = result.score.round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              result.isPassed ? Icons.check_circle : Icons.info_outline,
              color: result.isPassed
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
            const SizedBox(width: 8),
            Text(
              AppStrings.get(
                'speaking_score',
                lang,
                params: {'score': score.toString()},
              ),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final token in result.tokens)
              _TokenChip(token: token, theme: theme),
          ],
        ),
        if (result.extraWords.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            AppStrings.get(
              'speaking_extra_words',
              lang,
              params: {'words': result.extraWords.join(', ')},
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          result.transcript,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _TokenChip extends StatelessWidget {
  const _TokenChip({required this.token, required this.theme});

  final SpeakingTokenResult token;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, icon) = switch (token.status) {
      SpeakingTokenStatus.correct => (
        theme.colorScheme.primaryContainer,
        theme.colorScheme.onPrimaryContainer,
        Icons.check,
      ),
      SpeakingTokenStatus.missing => (
        theme.colorScheme.errorContainer,
        theme.colorScheme.onErrorContainer,
        Icons.close,
      ),
      SpeakingTokenStatus.maybeWrong => (
        theme.colorScheme.tertiaryContainer,
        theme.colorScheme.onTertiaryContainer,
        Icons.help_outline,
      ),
      SpeakingTokenStatus.extra => (
        theme.colorScheme.surfaceContainerHighest,
        theme.colorScheme.onSurface,
        Icons.add,
      ),
    };

    return Chip(
      avatar: Icon(icon, size: 16, color: foreground),
      label: Text(token.reference),
      backgroundColor: background,
      labelStyle: TextStyle(color: foreground, fontWeight: FontWeight.w600),
      side: BorderSide.none,
    );
  }
}

class _FinishedState extends StatelessWidget {
  const _FinishedState({
    required this.score,
    required this.lang,
    required this.onDone,
  });

  final double score;
  final String lang;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.record_voice_over,
              size: 52,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.get(
                'speaking_finished',
                lang,
                params: {'score': score.round().toString()},
              ),
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onDone,
              child: Text(AppStrings.get('done', lang)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.lang,
    required this.onRetry,
  });

  final String message;
  final String lang;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
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
