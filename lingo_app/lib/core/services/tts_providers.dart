import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import 'tts_model_manager.dart';
import 'tts_model_state.dart';
import 'tts_service.dart';

/// Manages model file download and verification.
final ttsModelManagerProvider = Provider<TtsModelManager>((ref) {
  final mgr = TtsModelManager(
    settingsRepo: ref.watch(settingsRepositoryProvider),
  );
  ref.onDispose(() => mgr.dispose());
  return mgr;
});

/// Streams the current model download state.
final ttsModelStateProvider = StreamProvider<TtsModelState>((ref) {
  final mgr = ref.watch(ttsModelManagerProvider);
  // Trigger status check when first subscribed
  mgr.checkStatus();
  return mgr.stateStream;
});

/// Singleton TTS orchestrator used everywhere in the app.
final ttsServiceProvider = Provider<TtsService>((ref) {
  final svc = TtsService(
    settingsRepo: ref.watch(settingsRepositoryProvider),
    modelManager: ref.watch(ttsModelManagerProvider),
    ttsRepo: ref.watch(ttsRepositoryProvider),
  );
  ref.onDispose(() => svc.dispose());
  return svc;
});
