import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/ai/ai_provider.dart';
import '../../../data/ai/ai_service.dart';
import '../../../data/models/narration_ai_models.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/narration_repository.dart';
import '../../speaking/providers/speaking_provider.dart';
import '../models/narration_models.dart';
import '../services/narration_audio_vault.dart';
import '../services/narration_audio_playback_service.dart';

final narrationRepositoryProvider = Provider<NarrationRepository>((ref) {
  return NarrationRepository(ref.watch(appDatabaseProvider));
});

final narrationAudioVaultProvider = Provider<NarrationAudioVault>((ref) {
  final vault = NarrationAudioVault();
  Future.microtask(vault.purgeTemporaryCopies);
  return vault;
});

final narrationAudioPlaybackProvider = Provider<NarrationAudioPlaybackService>((
  ref,
) {
  final service = NarrationAudioPlaybackService(
    ref.watch(narrationAudioVaultProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final narrationDashboardProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(narrationRepositoryProvider).getDashboardSummary();
});

final narrationRecentSessionsProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(narrationRepositoryProvider).getRecentSessions();
});

final narrationDueItemsProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(narrationRepositoryProvider).getDueItems();
});

final narrationLearningItemsProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(narrationRepositoryProvider).getLearningItems();
});

final narrationProgressProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(narrationRepositoryProvider).getProgress();
});

enum NarrationFlowPhase {
  idle,
  recording,
  recognizing,
  transcriptReview,
  generatingTarget,
  targetReview,
  analysing,
  results,
}

class NarrationFlowState {
  const NarrationFlowState({
    this.phase = NarrationFlowPhase.idle,
    this.session,
    this.retainAudio = false,
    this.actionError,
    this.targetDraft,
    this.recordingPath,
    this.accent = 'british',
    this.speechRegister = 'spoken',
    this.thinkingEnabled = true,
  });

  final NarrationFlowPhase phase;
  final NarrationSession? session;
  final bool retainAudio;
  final String? actionError;
  final NarrationTargetDraft? targetDraft;
  final String? recordingPath;
  final String accent;
  final String speechRegister;
  final bool thinkingEnabled;

  NarrationFlowState copyWith({
    NarrationFlowPhase? phase,
    NarrationSession? session,
    bool? retainAudio,
    String? actionError,
    NarrationTargetDraft? targetDraft,
    String? recordingPath,
    String? accent,
    String? speechRegister,
    bool? thinkingEnabled,
    bool clearSession = false,
    bool clearError = false,
    bool clearTargetDraft = false,
    bool clearRecordingPath = false,
  }) {
    return NarrationFlowState(
      phase: phase ?? this.phase,
      session: clearSession ? null : session ?? this.session,
      retainAudio: retainAudio ?? this.retainAudio,
      actionError: clearError ? null : actionError ?? this.actionError,
      targetDraft: clearTargetDraft ? null : targetDraft ?? this.targetDraft,
      recordingPath: clearRecordingPath
          ? null
          : recordingPath ?? this.recordingPath,
      accent: accent ?? this.accent,
      speechRegister: speechRegister ?? this.speechRegister,
      thinkingEnabled: thinkingEnabled ?? this.thinkingEnabled,
    );
  }
}

final narrationFlowProvider =
    StateNotifierProvider<NarrationFlowNotifier, NarrationFlowState>((ref) {
      return NarrationFlowNotifier(ref);
    });

class NarrationFlowNotifier extends StateNotifier<NarrationFlowState> {
  NarrationFlowNotifier(this._ref) : super(const NarrationFlowState());

  final Ref _ref;

  void setRetainAudio(bool value) {
    state = state.copyWith(retainAudio: value, clearError: true);
  }

  void clearActionError() {
    state = state.copyWith(clearError: true);
  }

  void setAccent(String value) {
    state = state.copyWith(accent: value, clearError: true);
  }

  void setSpeechRegister(String value) {
    state = state.copyWith(speechRegister: value, clearError: true);
  }

  void setThinkingEnabled(bool value) {
    state = state.copyWith(thinkingEnabled: value, clearError: true);
  }

  /// Seeds the per-narration toggle from the global AI setting. Ignored once a
  /// session is loaded, because that session records the value it was run with.
  Future<void> loadThinkingDefault() async {
    if (state.session != null) return;
    final enabled = await _ref
        .read(settingsRepositoryProvider)
        .getAiThinkingEnabled();
    if (!mounted || state.session != null) return;
    state = state.copyWith(thinkingEnabled: enabled);
  }

  Future<void> startRecording() async {
    if (state.phase == NarrationFlowPhase.recording ||
        state.phase == NarrationFlowPhase.recognizing) {
      return;
    }
    try {
      final path = await _ref.read(speakingRecordingServiceProvider).start();
      state = state.copyWith(
        phase: NarrationFlowPhase.recording,
        recordingPath: path,
        clearError: true,
        clearSession: true,
        clearTargetDraft: true,
      );
    } catch (error) {
      state = state.copyWith(actionError: _errorCode(error));
    }
  }

  Future<void> cancelRecording() async {
    if (state.phase != NarrationFlowPhase.recording) return;
    await _ref.read(speakingRecordingServiceProvider).cancel();
    final path = state.recordingPath;
    await _ref
        .read(narrationAudioVaultProvider)
        .finishTranscription(plaintextPath: path, retain: false);
    state = state.copyWith(
      phase: NarrationFlowPhase.idle,
      clearRecordingPath: true,
      clearError: true,
    );
  }

  Future<void> stopRecordingAndTranscribe() async {
    if (state.phase != NarrationFlowPhase.recording) return;
    state = state.copyWith(
      phase: NarrationFlowPhase.recognizing,
      clearError: true,
    );
    final recorder = _ref.read(speakingRecordingServiceProvider);
    String? recordedPath;
    try {
      recordedPath = await recorder.stop() ?? state.recordingPath;
      if (recordedPath == null || recordedPath.trim().isEmpty) {
        throw StateError('speaking_recording_failed');
      }
      final transcript = await _ref
          .read(speakingAsrServiceProvider)
          .transcribe(wavPath: recordedPath, language: 'auto');
      if (transcript.trim().isEmpty) {
        throw StateError('asr_empty_transcript');
      }
      final encryptedPath = await _ref
          .read(narrationAudioVaultProvider)
          .finishTranscription(
            plaintextPath: recordedPath,
            retain: state.retainAudio,
          );
      final id = await _ref
          .read(narrationRepositoryProvider)
          .createSession(
            rawTranscript: transcript.trim(),
            cleanedTranscript: transcript.trim(),
            confidence: NarrationTranscriptConfidence.medium,
            audioPath: encryptedPath,
            audioRetained: encryptedPath != null,
            accent: state.accent,
            register: state.speechRegister,
            thinkingEnabled: state.thinkingEnabled,
          );
      await loadSession(id);
      _invalidateCollections();
    } catch (error) {
      if (recordedPath != null) {
        await _ref
            .read(narrationAudioVaultProvider)
            .finishTranscription(plaintextPath: recordedPath, retain: false);
      }
      state = state.copyWith(
        phase: NarrationFlowPhase.idle,
        actionError: _errorCode(error),
        clearRecordingPath: true,
      );
    }
  }

  Future<void> startFromText(String transcript) async {
    final text = transcript.trim();
    if (text.isEmpty) return;
    try {
      final id = await _ref
          .read(narrationRepositoryProvider)
          .createSession(
            rawTranscript: text,
            cleanedTranscript: text,
            confidence: NarrationTranscriptConfidence.high,
            accent: state.accent,
            register: state.speechRegister,
            thinkingEnabled: state.thinkingEnabled,
          );
      await loadSession(id);
      _invalidateCollections();
    } catch (error) {
      state = state.copyWith(actionError: _errorCode(error));
    }
  }

  Future<void> loadSession(int id) async {
    final session = await _ref.read(narrationRepositoryProvider).getSession(id);
    if (session == null) {
      state = state.copyWith(actionError: 'narration_session_missing');
      return;
    }
    state = state.copyWith(
      session: session,
      phase: _phaseForSession(session),
      targetDraft: session.targetEnglish == null
          ? null
          : NarrationTargetDraft(
              recommended: session.targetEnglish!,
              alternatives: session.targetAlternatives,
            ),
      accent: session.accent,
      speechRegister: session.register,
      thinkingEnabled: session.thinkingEnabled,
      clearError: true,
      clearRecordingPath: true,
    );
  }

  Future<void> confirmTranscript({
    required String cleanedTranscript,
    required NarrationTranscriptConfidence confidence,
    List<NarrationUncertainSegment> uncertainSegments = const [],
  }) async {
    final session = state.session;
    if (session == null || cleanedTranscript.trim().isEmpty) return;
    try {
      await _ref
          .read(narrationRepositoryProvider)
          .confirmTranscript(
            sessionId: session.id,
            cleanedTranscript: cleanedTranscript.trim(),
            confidence: confidence,
            uncertainSegments: uncertainSegments,
          );
      await loadSession(session.id);
    } catch (error) {
      state = state.copyWith(actionError: _errorCode(error));
    }
  }

  Future<void> submitTranslation(String chineseTranslation) async {
    final session = state.session;
    final translation = chineseTranslation.trim();
    if (session == null || translation.isEmpty) return;
    state = state.copyWith(
      phase: NarrationFlowPhase.generatingTarget,
      clearError: true,
    );
    try {
      final repository = _ref.read(narrationRepositoryProvider);
      await repository.saveConfirmedTranslation(
        sessionId: session.id,
        chineseTranslation: translation,
      );
      final provider = await AiService(
        _ref.read(settingsRepositoryProvider),
      ).getProvider();
      final target = await provider.generateNarrationTarget(
        transcript: session.cleanedTranscript ?? session.rawTranscript,
        chineseTranslation: translation,
        accent: session.accent,
        register: session.register,
        thinkingEnabled: session.thinkingEnabled,
      );
      if (target.recommended.trim().isEmpty) {
        throw StateError('narration_target_empty');
      }
      await repository.saveTargetDraft(sessionId: session.id, target: target);
      await loadSession(session.id);
      state = state.copyWith(
        phase: NarrationFlowPhase.targetReview,
        targetDraft: target,
      );
    } catch (error) {
      state = state.copyWith(
        phase: NarrationFlowPhase.transcriptReview,
        actionError: _errorCode(error),
      );
      final refreshed = await _ref
          .read(narrationRepositoryProvider)
          .getSession(session.id);
      if (refreshed != null) {
        state = state.copyWith(
          session: refreshed,
          phase: NarrationFlowPhase.transcriptReview,
        );
      }
    }
  }

  Future<void> confirmTargetAndAnalyse(String targetEnglish) async {
    final session = state.session;
    final target = targetEnglish.trim();
    if (session == null || target.isEmpty) return;
    state = state.copyWith(
      phase: NarrationFlowPhase.analysing,
      clearError: true,
    );
    try {
      final repository = _ref.read(narrationRepositoryProvider);
      await repository.confirmTarget(
        sessionId: session.id,
        targetEnglish: target,
      );
      final existing = await repository.getExistingItemsForAnalysis();
      final provider = await AiService(
        _ref.read(settingsRepositoryProvider),
      ).getProvider();
      final stopwatch = Stopwatch()..start();
      final analysis = await provider.analyseNarration(
        rawTranscript: session.rawTranscript,
        cleanedTranscript: session.cleanedTranscript ?? session.rawTranscript,
        chineseTranslation: session.chineseTranslation ?? '',
        targetEnglish: target,
        accent: session.accent,
        register: session.register,
        existingLearningItems: existing
            .map((item) => item.toAiSummary())
            .toList(growable: false),
        thinkingEnabled: session.thinkingEnabled,
      );
      stopwatch.stop();
      if (analysis.correctedExpression.trim().isEmpty) {
        throw StateError('narration_analysis_empty');
      }
      await repository.saveAnalysis(
        sessionId: session.id,
        analysis: analysis,
        durationMs: stopwatch.elapsedMilliseconds,
      );
      await loadSession(session.id);
      _invalidateCollections();
    } catch (error) {
      state = state.copyWith(
        phase: NarrationFlowPhase.targetReview,
        actionError: _errorCode(error),
      );
    }
  }

  Future<void> confirmFinal(String expression) async {
    final session = state.session;
    final value = expression.trim();
    if (session == null || value.isEmpty) return;
    try {
      await _ref
          .read(narrationRepositoryProvider)
          .confirmFinalExpression(
            sessionId: session.id,
            finalExpression: value,
          );
      await loadSession(session.id);
      _invalidateCollections();
    } catch (error) {
      state = state.copyWith(actionError: _errorCode(error));
    }
  }

  Future<void> deleteSession() async {
    final session = state.session;
    if (session == null) return;
    await _ref
        .read(narrationAudioVaultProvider)
        .deleteEncrypted(session.audioPath);
    await _ref.read(narrationRepositoryProvider).deleteSession(session.id);
    reset();
    _invalidateCollections();
  }

  void reset() {
    state = const NarrationFlowState();
  }

  NarrationFlowPhase _phaseForSession(NarrationSession session) {
    return switch (session.status) {
      NarrationSessionStatus.transcriptReview ||
      NarrationSessionStatus.translation => NarrationFlowPhase.transcriptReview,
      NarrationSessionStatus.targetReview =>
        session.targetEnglish?.trim().isNotEmpty == true
            ? NarrationFlowPhase.targetReview
            : NarrationFlowPhase.transcriptReview,
      NarrationSessionStatus.analysed ||
      NarrationSessionStatus.confirmed => NarrationFlowPhase.results,
    };
  }

  void _invalidateCollections() {
    _ref.invalidate(narrationDashboardProvider);
    _ref.invalidate(narrationRecentSessionsProvider);
    _ref.invalidate(narrationDueItemsProvider);
    _ref.invalidate(narrationLearningItemsProvider);
    _ref.invalidate(narrationProgressProvider);
  }

  String _errorCode(Object error) {
    if (error is AiOutputTruncatedException) {
      return 'narration_ai_output_truncated';
    }
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final responseText = error.response?.data?.toString().toLowerCase() ?? '';
      if (statusCode == 401 || statusCode == 403) {
        return 'narration_ai_auth_failed';
      }
      if (statusCode == 402 || responseText.contains('balance')) {
        return 'narration_ai_balance_insufficient';
      }
      if (statusCode == 429) return 'narration_ai_rate_limited';
      if (responseText.contains('model') &&
          (responseText.contains('not exist') ||
              responseText.contains('not found') ||
              responseText.contains('invalid'))) {
        return 'narration_ai_model_unavailable';
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'narration_ai_timeout';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'narration_ai_connection_failed';
      }
      if (statusCode != null) return 'narration_ai_request_failed';
    }
    if (error is FormatException || error is TypeError) {
      return 'narration_ai_response_invalid';
    }
    final text = error.toString();
    return text
        .replaceFirst('Bad state: ', '')
        .replaceFirst('SpeakingRecordingException: ', '')
        .replaceFirst('SpeakingAsrException: ', '')
        .replaceFirst('SpeakingAsrModelException: ', '');
  }
}
