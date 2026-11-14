import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';

import 'narration_audio_vault.dart';

class NarrationAudioPlaybackService {
  NarrationAudioPlaybackService(this._vault) {
    _completeSubscription = _player.onPlayerComplete.listen((_) {
      unawaited(_deleteTemporaryCopy());
    });
  }

  final NarrationAudioVault _vault;
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<void>? _completeSubscription;
  String? _temporaryPath;

  Future<void> play(String encryptedPath) async {
    await stop();
    final temporaryPath = await _vault.openTemporaryCopy(encryptedPath);
    _temporaryPath = temporaryPath;
    try {
      await _player.play(DeviceFileSource(temporaryPath));
    } catch (_) {
      await _deleteTemporaryCopy();
      rethrow;
    }
  }

  Future<void> stop() async {
    await _player.stop();
    await _deleteTemporaryCopy();
  }

  Future<void> _deleteTemporaryCopy() async {
    final path = _temporaryPath;
    _temporaryPath = null;
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  Future<void> dispose() async {
    await stop();
    await _completeSubscription?.cancel();
    _completeSubscription = null;
    await _player.dispose();
  }
}
