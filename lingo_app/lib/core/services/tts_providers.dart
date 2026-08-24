import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import 'tts_service.dart';

/// Singleton TTS orchestrator used everywhere in the app.
final ttsServiceProvider = Provider<TtsService>((ref) {
  final svc = TtsService(
    settingsRepo: ref.watch(settingsRepositoryProvider),
    ttsRepo: ref.watch(ttsRepositoryProvider),
  );
  ref.onDispose(() => svc.dispose());
  return svc;
});
