import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../data/models/narration_ai_models.dart';
import '../../../data/providers.dart';
import '../../speaking/providers/speaking_provider.dart';
import '../../speaking/services/speaking_asr_model_manager.dart';
import '../models/narration_models.dart';
import '../providers/narration_provider.dart';

class NarrationFlowScreen extends ConsumerStatefulWidget {
  const NarrationFlowScreen({super.key, this.sessionId});

  final int? sessionId;

  @override
  ConsumerState<NarrationFlowScreen> createState() =>
      _NarrationFlowScreenState();
}

class _NarrationFlowScreenState extends ConsumerState<NarrationFlowScreen> {
  final _manualInputController = TextEditingController();
  final _transcriptController = TextEditingController();
  final _translationController = TextEditingController();
  final _targetController = TextEditingController();
  final _finalController = TextEditingController();
  NarrationTranscriptConfidence _confidence =
      NarrationTranscriptConfidence.medium;
  bool _privacyAccepted = false;
  int? _syncedSessionId;
  int? _syncedSessionUpdatedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(speakingAsrModelManagerProvider).checkStatus();
      if (widget.sessionId != null) {
        await ref
            .read(narrationFlowProvider.notifier)
            .loadSession(widget.sessionId!);
      } else {
        await ref.read(narrationFlowProvider.notifier).loadThinkingDefault();
      }
    });
  }

  @override
  void dispose() {
    _manualInputController.dispose();
    _transcriptController.dispose();
    _translationController.dispose();
    _targetController.dispose();
    _finalController.dispose();
    super.dispose();
  }

  void _syncControllers(NarrationFlowState state) {
    final session = state.session;
    if (session == null) return;
    final updatedAt = session.updatedAt.millisecondsSinceEpoch;
    if (_syncedSessionId == session.id &&
        _syncedSessionUpdatedAt == updatedAt) {
      return;
    }
    _setText(
      _transcriptController,
      session.cleanedTranscript ?? session.rawTranscript,
    );
    _setText(_translationController, session.chineseTranslation ?? '');
    _setText(_targetController, session.targetEnglish ?? '');
    _setText(
      _finalController,
      session.finalExpression ?? session.correctedExpression ?? '',
    );
    _confidence = session.transcriptConfidence;
    _syncedSessionId = session.id;
    _syncedSessionUpdatedAt = updatedAt;
  }

  void _setText(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final state = ref.watch(narrationFlowProvider);
    final asrState = ref.watch(speakingAsrModelStateProvider);
    _syncControllers(state);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('narration_new', lang)),
        actions: [
          if (state.session != null)
            if (state.session!.audioRetained &&
                state.session!.audioPath != null)
              IconButton(
                tooltip: AppStrings.get('narration_play_audio', lang),
                onPressed: () => _playRetainedAudio(state.session!, lang),
                icon: const Icon(Icons.play_circle_outline),
              ),
          if (state.session != null)
            IconButton(
              tooltip: AppStrings.get('delete', lang),
              onPressed: () => _deleteSession(lang),
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: Column(
        children: [
          _FlowHeader(phase: state.phase, lang: lang),
          if (state.actionError != null)
            MaterialBanner(
              content: Text(_errorMessage(state.actionError!, lang)),
              actions: [
                TextButton(
                  onPressed: () => ref
                      .read(narrationFlowProvider.notifier)
                      .clearActionError(),
                  child: Text(AppStrings.get('dismiss', lang)),
                ),
              ],
            ),
          Expanded(
            child: switch (state.phase) {
              NarrationFlowPhase.idle ||
              NarrationFlowPhase.recording ||
              NarrationFlowPhase.recognizing => _InputStep(
                lang: lang,
                state: state,
                asrState: asrState,
                manualController: _manualInputController,
                privacyAccepted: _privacyAccepted,
                onPrivacyChanged: (value) =>
                    setState(() => _privacyAccepted = value ?? false),
                onRecord: _handleRecording,
                onCancelRecording: () =>
                    ref.read(narrationFlowProvider.notifier).cancelRecording(),
                onStartFromText: () {
                  if (!_privacyAccepted) return;
                  _recordConsent();
                  ref
                      .read(narrationFlowProvider.notifier)
                      .startFromText(_manualInputController.text);
                },
                onTextChanged: (_) => setState(() {}),
                onRetainAudio: (value) => ref
                    .read(narrationFlowProvider.notifier)
                    .setRetainAudio(value ?? false),
                onAccentChanged: (value) {
                  if (value != null) {
                    ref.read(narrationFlowProvider.notifier).setAccent(value);
                  }
                },
                onRegisterChanged: (value) {
                  if (value != null) {
                    ref
                        .read(narrationFlowProvider.notifier)
                        .setSpeechRegister(value);
                  }
                },
                onThinkingChanged: (value) => ref
                    .read(narrationFlowProvider.notifier)
                    .setThinkingEnabled(value ?? true),
                onDownloadModel: () =>
                    ref.read(speakingAsrModelManagerProvider).downloadModel(),
              ),
              NarrationFlowPhase.transcriptReview => _TranscriptStep(
                lang: lang,
                session: state.session!,
                transcriptController: _transcriptController,
                translationController: _translationController,
                confidence: _confidence,
                onConfidenceChanged: (value) {
                  if (value != null) setState(() => _confidence = value);
                },
                onConfirmTranscript: () => ref
                    .read(narrationFlowProvider.notifier)
                    .confirmTranscript(
                      cleanedTranscript: _transcriptController.text,
                      confidence: _confidence,
                    ),
                onTranscriptChanged: (_) => setState(() {}),
                onSubmitTranslation: () => ref
                    .read(narrationFlowProvider.notifier)
                    .submitTranslation(_translationController.text),
                onTranslationChanged: (_) => setState(() {}),
              ),
              NarrationFlowPhase.generatingTarget ||
              NarrationFlowPhase.analysing => _BusyStep(
                lang: lang,
                analysing: state.phase == NarrationFlowPhase.analysing,
              ),
              NarrationFlowPhase.targetReview => _TargetStep(
                lang: lang,
                session: state.session!,
                targetDraft: state.targetDraft,
                controller: _targetController,
                onTargetChanged: (_) => setState(() {}),
                onAnalyse: () => ref
                    .read(narrationFlowProvider.notifier)
                    .confirmTargetAndAnalyse(_targetController.text),
                onFeedback: () => _recordFeedback(
                  stage: 'target_expression',
                  judgement: state.session!.targetEnglish ?? '',
                  explanationKey: 'narration_feedback_target_explanation',
                  lang: lang,
                ),
              ),
              NarrationFlowPhase.results => _ResultStep(
                lang: lang,
                session: state.session!,
                finalController: _finalController,
                onConfirmFinal: () => ref
                    .read(narrationFlowProvider.notifier)
                    .confirmFinal(_finalController.text),
                onFeedback: (stage, judgement, explanationKey) =>
                    _recordFeedback(
                      stage: stage,
                      judgement: judgement,
                      explanationKey: explanationKey,
                      lang: lang,
                    ),
              ),
            },
          ),
        ],
      ),
    );
  }

  Future<void> _recordConsent() async {
    await ref
        .read(narrationRepositoryProvider)
        .recordConsent(consentType: 'narration_processing', granted: true);
  }

  Future<void> _handleRecording() async {
    if (!_privacyAccepted) return;
    await _recordConsent();
    final phase = ref.read(narrationFlowProvider).phase;
    if (phase == NarrationFlowPhase.recording) {
      await ref
          .read(narrationFlowProvider.notifier)
          .stopRecordingAndTranscribe();
    } else {
      await ref.read(narrationFlowProvider.notifier).startRecording();
    }
  }

  Future<void> _deleteSession(String lang) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.get('narration_delete_title', lang)),
        content: Text(AppStrings.get('narration_delete_body', lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppStrings.get('cancel', lang)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppStrings.get('delete', lang)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(narrationFlowProvider.notifier).deleteSession();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _playRetainedAudio(NarrationSession session, String lang) async {
    try {
      await ref.read(narrationAudioPlaybackProvider).play(session.audioPath!);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.get(
              'narration_audio_play_failed',
              lang,
              params: {'error': error.toString()},
            ),
          ),
        ),
      );
    }
  }

  Future<void> _recordFeedback({
    required String stage,
    required String judgement,
    required String explanationKey,
    required String lang,
  }) async {
    final session = ref.read(narrationFlowProvider).session;
    if (session == null) return;
    final controller = TextEditingController();
    final explanation = AppStrings.get(explanationKey, lang);
    final resolution = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.get('narration_feedback_title', lang)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(explanation),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: AppStrings.get('narration_feedback_reason', lang),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppStrings.get('cancel', lang)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('accepted'),
            child: Text(
              AppStrings.get('narration_feedback_accept_explanation', lang),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop('user_override'),
            child: Text(
              AppStrings.get('narration_feedback_submit_objection', lang),
            ),
          ),
        ],
      ),
    );
    final reason = controller.text.trim();
    controller.dispose();
    if (resolution == null) return;
    await ref
        .read(narrationRepositoryProvider)
        .recordFeedback(
          sessionId: session.id,
          stage: stage,
          originalJudgement: judgement,
          systemExplanation: explanation,
          userReason: reason.isEmpty ? null : reason,
          resolution: resolution,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.get('narration_feedback_saved', lang))),
    );
  }

  String _errorMessage(String error, String lang) {
    const known = {
      'speaking_mic_permission_denied',
      'speaking_recording_failed',
      'asr_model_not_downloaded',
      'asr_empty_audio',
      'asr_empty_transcript',
      'narration_target_empty',
      'narration_analysis_empty',
      'narration_analysis_missing',
      'narration_session_missing',
      'narration_audio_key_missing',
      'narration_ai_auth_failed',
      'narration_ai_balance_insufficient',
      'narration_ai_rate_limited',
      'narration_ai_model_unavailable',
      'narration_ai_timeout',
      'narration_ai_connection_failed',
      'narration_ai_request_failed',
      'narration_ai_response_invalid',
      'narration_ai_output_truncated',
    };
    if (known.contains(error)) return AppStrings.get(error, lang);
    if (error.contains('API key')) {
      return AppStrings.get('narration_ai_not_configured', lang);
    }
    return AppStrings.get(
      'narration_unknown_error',
      lang,
      params: {'error': error},
    );
  }
}

class _FlowHeader extends StatelessWidget {
  const _FlowHeader({required this.phase, required this.lang});

  final NarrationFlowPhase phase;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final step = switch (phase) {
      NarrationFlowPhase.idle ||
      NarrationFlowPhase.recording ||
      NarrationFlowPhase.recognizing => 0,
      NarrationFlowPhase.transcriptReview => 1,
      NarrationFlowPhase.generatingTarget ||
      NarrationFlowPhase.targetReview => 2,
      NarrationFlowPhase.analysing || NarrationFlowPhase.results => 3,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          for (var index = 0; index < 4; index++) ...[
            Expanded(
              child: LinearProgressIndicator(
                value: index <= step ? 1 : 0,
                minHeight: 5,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            if (index < 3) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _InputStep extends StatelessWidget {
  const _InputStep({
    required this.lang,
    required this.state,
    required this.asrState,
    required this.manualController,
    required this.privacyAccepted,
    required this.onPrivacyChanged,
    required this.onRecord,
    required this.onCancelRecording,
    required this.onStartFromText,
    required this.onTextChanged,
    required this.onRetainAudio,
    required this.onAccentChanged,
    required this.onRegisterChanged,
    required this.onThinkingChanged,
    required this.onDownloadModel,
  });

  final String lang;
  final NarrationFlowState state;
  final AsyncValue<SpeakingAsrModelState> asrState;
  final TextEditingController manualController;
  final bool privacyAccepted;
  final ValueChanged<bool?> onPrivacyChanged;
  final Future<void> Function() onRecord;
  final Future<void> Function() onCancelRecording;
  final VoidCallback onStartFromText;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<bool?> onRetainAudio;
  final ValueChanged<String?> onAccentChanged;
  final ValueChanged<String?> onRegisterChanged;
  final ValueChanged<bool?> onThinkingChanged;
  final Future<void> Function() onDownloadModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = asrState.valueOrNull;
    final ready = model is SpeakingAsrModelReady;
    final recording = state.phase == NarrationFlowPhase.recording;
    final recognizing = state.phase == NarrationFlowPhase.recognizing;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        Text(
          AppStrings.get('narration_input_heading', lang),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(AppStrings.get('narration_input_intro', lang)),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(ready ? Icons.offline_bolt : Icons.download_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ready
                            ? AppStrings.get(
                                'speaking_asr_model_ready_desc',
                                lang,
                              )
                            : AppStrings.get('speaking_asr_model_needed', lang),
                      ),
                    ),
                    if (!ready)
                      TextButton(
                        onPressed: model is SpeakingAsrModelDownloading
                            ? null
                            : onDownloadModel,
                        child: Text(
                          AppStrings.get('speaking_asr_download_model', lang),
                        ),
                      ),
                  ],
                ),
                if (model is SpeakingAsrModelDownloading) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: model.progress),
                ],
                const SizedBox(height: 18),
                Center(
                  child: SizedBox(
                    width: 112,
                    height: 112,
                    child: FilledButton(
                      onPressed: !ready || recognizing || !privacyAccepted
                          ? null
                          : onRecord,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Icon(recording ? Icons.stop : Icons.mic, size: 44),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  recognizing
                      ? AppStrings.get('speaking_recognizing', lang)
                      : recording
                      ? AppStrings.get('narration_recording', lang)
                      : AppStrings.get('narration_tap_record', lang),
                  textAlign: TextAlign.center,
                ),
                if (recording) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onCancelRecording,
                    child: Text(AppStrings.get('cancel', lang)),
                  ),
                ],
                if (recognizing) ...[
                  const SizedBox(height: 12),
                  const Center(child: CircularProgressIndicator()),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: state.retainAudio,
                  onChanged: recording || recognizing ? null : onRetainAudio,
                  title: Text(AppStrings.get('narration_retain_audio', lang)),
                  subtitle: Text(
                    AppStrings.get('narration_retain_audio_desc', lang),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: state.accent,
                        decoration: InputDecoration(
                          labelText: AppStrings.get('narration_accent', lang),
                          border: const OutlineInputBorder(),
                        ),
                        items: const ['british', 'american']
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(
                                  AppStrings.get(
                                    'narration_accent_$value',
                                    lang,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: recording || recognizing
                            ? null
                            : onAccentChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: state.speechRegister,
                        decoration: InputDecoration(
                          labelText: AppStrings.get('narration_register', lang),
                          border: const OutlineInputBorder(),
                        ),
                        items: const ['spoken', 'formal', 'academic']
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(
                                  AppStrings.get(
                                    'narration_register_$value',
                                    lang,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: recording || recognizing
                            ? null
                            : onRegisterChanged,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: state.thinkingEnabled,
                  onChanged: recording || recognizing
                      ? null
                      : onThinkingChanged,
                  secondary: const Icon(Icons.psychology_outlined),
                  title: Text(
                    AppStrings.get('narration_thinking_toggle', lang),
                  ),
                  subtitle: Text(
                    AppStrings.get('narration_thinking_toggle_desc', lang),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: manualController,
          minLines: 4,
          maxLines: 8,
          decoration: InputDecoration(
            labelText: AppStrings.get('narration_manual_label', lang),
            hintText: AppStrings.get('narration_manual_hint', lang),
            border: const OutlineInputBorder(),
          ),
          onChanged: onTextChanged,
        ),
        const SizedBox(height: 10),
        FilledButton.tonalIcon(
          onPressed: !privacyAccepted || manualController.text.trim().isEmpty
              ? null
              : onStartFromText,
          icon: const Icon(Icons.arrow_forward),
          label: Text(AppStrings.get('narration_use_text', lang)),
        ),
        const SizedBox(height: 18),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: privacyAccepted,
          onChanged: recording || recognizing ? null : onPrivacyChanged,
          title: Text(AppStrings.get('narration_consent_title', lang)),
          subtitle: Text(AppStrings.get('narration_consent_desc', lang)),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }
}

class _TranscriptStep extends StatelessWidget {
  const _TranscriptStep({
    required this.lang,
    required this.session,
    required this.transcriptController,
    required this.translationController,
    required this.confidence,
    required this.onConfidenceChanged,
    required this.onConfirmTranscript,
    required this.onTranscriptChanged,
    required this.onSubmitTranslation,
    required this.onTranslationChanged,
  });

  final String lang;
  final NarrationSession session;
  final TextEditingController transcriptController;
  final TextEditingController translationController;
  final NarrationTranscriptConfidence confidence;
  final ValueChanged<NarrationTranscriptConfidence?> onConfidenceChanged;
  final Future<void> Function() onConfirmTranscript;
  final ValueChanged<String> onTranscriptChanged;
  final Future<void> Function() onSubmitTranslation;
  final ValueChanged<String> onTranslationChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transcriptConfirmed =
        session.status != NarrationSessionStatus.transcriptReview;
    final canContinue =
        transcriptConfirmed && translationController.text.trim().isNotEmpty;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        Text(
          AppStrings.get('narration_transcript_heading', lang),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(AppStrings.get('narration_transcript_intro', lang)),
        const SizedBox(height: 16),
        _Label(AppStrings.get('narration_raw_transcript', lang)),
        SelectableText(session.rawTranscript),
        const SizedBox(height: 16),
        TextField(
          controller: transcriptController,
          minLines: 4,
          maxLines: 9,
          decoration: InputDecoration(
            labelText: AppStrings.get('narration_cleaned_transcript', lang),
            helperText: AppStrings.get('narration_cleanup_help', lang),
            border: const OutlineInputBorder(),
          ),
          onChanged: onTranscriptChanged,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<NarrationTranscriptConfidence>(
          initialValue: confidence,
          decoration: InputDecoration(
            labelText: AppStrings.get('narration_confidence', lang),
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final item in NarrationTranscriptConfidence.values)
              DropdownMenuItem(
                value: item,
                child: Text(
                  AppStrings.get('narration_confidence_${item.name}', lang),
                ),
              ),
          ],
          onChanged: transcriptConfirmed ? null : onConfidenceChanged,
        ),
        if (confidence != NarrationTranscriptConfidence.high) ...[
          const SizedBox(height: 10),
          Text(
            AppStrings.get(
              confidence == NarrationTranscriptConfidence.low
                  ? 'narration_low_confidence_warning'
                  : 'narration_medium_confidence_warning',
              lang,
            ),
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ],
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed:
              transcriptConfirmed || transcriptController.text.trim().isEmpty
              ? null
              : onConfirmTranscript,
          icon: const Icon(Icons.check),
          label: Text(
            transcriptConfirmed
                ? AppStrings.get('narration_transcript_confirmed', lang)
                : AppStrings.get('narration_confirm_transcript', lang),
          ),
        ),
        const Divider(height: 36),
        Text(
          AppStrings.get('narration_translation_heading', lang),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(AppStrings.get('narration_translation_intro', lang)),
        const SizedBox(height: 12),
        TextField(
          controller: translationController,
          minLines: 4,
          maxLines: 9,
          enabled: transcriptConfirmed,
          decoration: InputDecoration(
            labelText: AppStrings.get('narration_translation_label', lang),
            hintText: AppStrings.get('narration_translation_hint', lang),
            border: const OutlineInputBorder(),
          ),
          onChanged: onTranslationChanged,
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: canContinue ? onSubmitTranslation : null,
          icon: const Icon(Icons.auto_awesome),
          label: Text(AppStrings.get('narration_generate_target', lang)),
        ),
      ],
    );
  }
}

class _BusyStep extends StatelessWidget {
  const _BusyStep({required this.lang, required this.analysing});

  final String lang;
  final bool analysing;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              AppStrings.get(
                analysing
                    ? 'narration_analysing'
                    : 'narration_generating_target',
                lang,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetStep extends StatelessWidget {
  const _TargetStep({
    required this.lang,
    required this.session,
    required this.targetDraft,
    required this.controller,
    required this.onTargetChanged,
    required this.onAnalyse,
    required this.onFeedback,
  });

  final String lang;
  final NarrationSession session;
  final NarrationTargetDraft? targetDraft;
  final TextEditingController controller;
  final ValueChanged<String> onTargetChanged;
  final Future<void> Function() onAnalyse;
  final VoidCallback onFeedback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        Text(
          AppStrings.get('narration_target_heading', lang),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(AppStrings.get('narration_target_intro', lang)),
        if (targetDraft?.conflictDetected == true) ...[
          const SizedBox(height: 14),
          Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber),
                  const SizedBox(width: 10),
                  Expanded(child: Text(targetDraft!.conflictMessage)),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          minLines: 4,
          maxLines: 10,
          decoration: InputDecoration(
            labelText: AppStrings.get('narration_target_label', lang),
            border: const OutlineInputBorder(),
          ),
          onChanged: onTargetChanged,
        ),
        if (session.targetAlternatives.isNotEmpty) ...[
          const SizedBox(height: 16),
          _Label(AppStrings.get('narration_variants', lang)),
          for (final item in session.targetAlternatives)
            Card(
              child: ListTile(
                title: Text(item.text),
                subtitle: Text(item.difference),
                trailing: const Icon(Icons.swap_horiz),
                onTap: () => controller.text = item.text,
              ),
            ),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: controller.text.trim().isEmpty ? null : onAnalyse,
          icon: const Icon(Icons.analytics_outlined),
          label: Text(AppStrings.get('narration_confirm_and_analyse', lang)),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onFeedback,
          icon: const Icon(Icons.feedback_outlined),
          label: Text(AppStrings.get('narration_raise_objection', lang)),
        ),
      ],
    );
  }
}

class _ResultStep extends StatelessWidget {
  const _ResultStep({
    required this.lang,
    required this.session,
    required this.finalController,
    required this.onConfirmFinal,
    required this.onFeedback,
  });

  final String lang;
  final NarrationSession session;
  final TextEditingController finalController;
  final Future<void> Function() onConfirmFinal;
  final void Function(String stage, String judgement, String explanationKey)
  onFeedback;

  @override
  Widget build(BuildContext context) {
    final analysis = session.analysis!;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
      children: [
        Text(
          AppStrings.get('narration_result_heading', lang),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        _ThinkingSummary(session: session, lang: lang),
        const SizedBox(height: 14),
        _SectionCard(
          title: AppStrings.get('narration_comparison', lang),
          child: Column(
            children: [
              for (
                var index = 0;
                index < analysis.sentencePairs.length;
                index++
              ) ...[
                _SentenceComparison(
                  pair: analysis.sentencePairs[index],
                  lang: lang,
                ),
                if (index < analysis.sentencePairs.length - 1)
                  const Divider(height: 24),
              ],
              if (analysis.sentencePairs.isEmpty) ...[
                _Label(AppStrings.get('narration_raw_transcript', lang)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(session.rawTranscript),
                ),
                const SizedBox(height: 12),
                _Label(AppStrings.get('narration_corrected', lang)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(analysis.correctedExpression),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ErrorSections(
          errors: analysis.errors,
          lang: lang,
          onFeedback: () => onFeedback(
            'error_analysis',
            analysis.errors.map((item) => item.toJson()).toString(),
            'narration_feedback_error_explanation',
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: AppStrings.get('narration_collected_words', lang),
          footer: TextButton.icon(
            onPressed: () => onFeedback(
              'word_collection',
              analysis.collectedWords.map((item) => item.toJson()).toString(),
              'narration_feedback_word_explanation',
            ),
            icon: const Icon(Icons.feedback_outlined),
            label: Text(AppStrings.get('narration_raise_objection', lang)),
          ),
          child: analysis.collectedWords.isEmpty
              ? Text(AppStrings.get('narration_none', lang))
              : Column(
                  children: [
                    for (final word in analysis.collectedWords)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.translate),
                        title: Text('${word.chinese} → ${word.english}'),
                        subtitle: Text(
                          [
                            word.partOfSpeech,
                            word.note,
                          ].where((part) => part.isNotEmpty).join(' · '),
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: AppStrings.get('narration_knowledge_summary', lang),
          footer: TextButton.icon(
            onPressed: () => onFeedback(
              'knowledge_summary',
              analysis.knowledgePoints.map((item) => item.toJson()).toString(),
              'narration_feedback_knowledge_explanation',
            ),
            icon: const Icon(Icons.feedback_outlined),
            label: Text(AppStrings.get('narration_raise_objection', lang)),
          ),
          child: analysis.knowledgePoints.isEmpty
              ? Text(AppStrings.get('narration_none', lang))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final level in const ['core', 'related', 'extended'])
                      if (analysis.knowledgePoints.any(
                        (item) => item.level == level,
                      )) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 4),
                          child: Text(
                            AppStrings.get('narration_knowledge_$level', lang),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        for (final point in analysis.knowledgePoints.where(
                          (item) => item.level == level,
                        ))
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(point.title),
                            subtitle: Text(point.explanation),
                            trailing: point.reviewRequired
                                ? const Icon(Icons.replay)
                                : null,
                          ),
                      ],
                  ],
                ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: AppStrings.get('narration_self_check', lang),
          child: Column(
            children: [
              for (final check in analysis.selfCheck.checks)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    check.passed ? Icons.check_circle : Icons.help_outline,
                    color: check.passed
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                  title: Text(
                    AppStrings.get('narration_check_${check.key}', lang),
                  ),
                  subtitle: Text(check.detail),
                ),
              Text(
                AppStrings.get(
                  'narration_self_check_iterations',
                  lang,
                  params: {'count': analysis.selfCheck.iterations.toString()},
                ),
              ),
              if (analysis.selfCheck.modifications.isNotEmpty) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    analysis.selfCheck.modifications
                        .map((item) => '• $item')
                        .join('\n'),
                  ),
                ),
              ],
              if (analysis.selfCheck.targetDifference.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(analysis.selfCheck.targetDifference),
              ],
              if (analysis.selfCheck.naturalnessBasis.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(analysis.selfCheck.naturalnessBasis),
              ],
              if (analysis.selfCheck.uncertainties.isNotEmpty)
                Text(
                  analysis.selfCheck.uncertainties.join('\n'),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ExpansionTile(
          title: Text(AppStrings.get('narration_target_details', lang)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SelectableText(session.targetEnglish ?? ''),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: finalController,
          minLines: 4,
          maxLines: 10,
          readOnly: session.finalConfirmed,
          decoration: InputDecoration(
            labelText: AppStrings.get('narration_final_expression', lang),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: session.finalConfirmed ? null : onConfirmFinal,
          icon: const Icon(Icons.library_add_check_outlined),
          label: Text(
            session.finalConfirmed
                ? AppStrings.get('narration_saved_to_library', lang)
                : AppStrings.get('narration_confirm_final', lang),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => onFeedback(
            'corrected_expression',
            analysis.correctedExpression,
            'narration_feedback_correction_explanation',
          ),
          icon: const Icon(Icons.feedback_outlined),
          label: Text(AppStrings.get('narration_raise_objection', lang)),
        ),
        if (session.finalConfirmed) ...[
          const SizedBox(height: 10),
          Text(
            AppStrings.get('narration_learning_saved_desc', lang),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _ThinkingSummary extends StatelessWidget {
  const _ThinkingSummary({required this.session, required this.lang});

  final NarrationSession session;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = session.analysisDurationMs;
    final parts = <String>[
      AppStrings.get(
        session.thinkingEnabled
            ? 'narration_thinking_on'
            : 'narration_thinking_off',
        lang,
      ),
      if (duration != null)
        AppStrings.get(
          'narration_analysis_elapsed',
          lang,
          params: {'seconds': (duration / 1000).toStringAsFixed(1)},
        ),
    ];
    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        avatar: Icon(
          session.thinkingEnabled ? Icons.psychology : Icons.bolt,
          size: 18,
        ),
        label: Text(parts.join(' · ')),
        labelStyle: theme.textTheme.bodySmall,
      ),
    );
  }
}

class _ErrorSections extends StatelessWidget {
  const _ErrorSections({
    required this.errors,
    required this.lang,
    required this.onFeedback,
  });

  final List<NarrationErrorItem> errors;
  final String lang;
  final VoidCallback onFeedback;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: AppStrings.get('narration_error_analysis', lang),
      child: errors.isEmpty
          ? Text(AppStrings.get('narration_no_errors', lang))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final grade in const ['A', 'B', 'C'])
                  if (errors.any((item) => item.grade == grade)) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Text(
                        AppStrings.get(
                          'narration_grade_${grade.toLowerCase()}',
                          lang,
                        ),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    for (final error in errors.where(
                      (item) => item.grade == grade,
                    ))
                      Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                error.original,
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                error.correction,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text('${error.issue}\n${error.reason}'),
                            ],
                          ),
                        ),
                      ),
                  ],
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onFeedback,
                    icon: const Icon(Icons.feedback_outlined),
                    label: Text(
                      AppStrings.get('narration_raise_objection', lang),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SentenceComparison extends StatelessWidget {
  const _SentenceComparison({required this.pair, required this.lang});

  final NarrationSentencePair pair;
  final String lang;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(pair.original),
        const SizedBox(height: 6),
        Text(
          pair.corrected,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        if (pair.differences.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final difference in pair.differences)
                Tooltip(
                  message: difference.reason,
                  child: Chip(
                    avatar: Icon(_differenceIcon(difference.type), size: 16),
                    label: Text(
                      '${difference.original.isEmpty ? '＋' : difference.original} → ${difference.corrected.isEmpty ? '−' : difference.corrected}',
                    ),
                    backgroundColor: _differenceColour(
                      context,
                      difference.type,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  IconData _differenceIcon(String type) => switch (type) {
    'chinese_substitute' => Icons.translate,
    'addition' => Icons.add,
    'deletion' => Icons.remove,
    'naturalness' => Icons.auto_awesome,
    _ => Icons.rule,
  };

  Color _differenceColour(BuildContext context, String type) {
    final colors = Theme.of(context).colorScheme;
    return switch (type) {
      'chinese_substitute' => colors.tertiaryContainer,
      'addition' || 'deletion' => colors.secondaryContainer,
      'naturalness' => colors.surfaceContainerHighest,
      _ => colors.primaryContainer,
    };
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.footer});

  final String title;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            child,
            if (footer != null) ...[
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: footer!),
            ],
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
