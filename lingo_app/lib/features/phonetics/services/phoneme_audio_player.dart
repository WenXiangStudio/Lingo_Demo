import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/wav_playback_preroll.dart';

abstract interface class PhonemeAudioPlayer {
  Future<void> playAsset(String assetPath);

  Future<void> stop();

  Future<void> dispose();
}

class AssetPhonemeAudioPlayer implements PhonemeAudioPlayer {
  static const _windowsPreRoll = Duration(milliseconds: 210);

  AssetPhonemeAudioPlayer({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;
  final AudioPlayer _player = AudioPlayer();
  final Map<String, Uint8List> _assetCache = {};

  Future<void>? _initialization;
  Completer<void>? _playbackCompletion;
  StreamSubscription<void>? _completionSubscription;
  int _requestId = 0;
  bool _disposed = false;

  Future<void> _ensureInitialized() =>
      _initialization ??= _player.setReleaseMode(ReleaseMode.stop);

  @override
  Future<void> playAsset(String assetPath) async {
    if (_disposed) return;
    final requestId = ++_requestId;
    await _ensureInitialized();
    if (_disposed || requestId != _requestId) return;

    _completePlayback();
    await _player.stop();

    final sourceBytes = await _loadAsset(assetPath);
    if (_disposed || requestId != _requestId) return;
    final playbackBytes = Platform.isWindows
        ? WavPlaybackPreRoll.prependPcm16Silence(
            sourceBytes,
            duration: _windowsPreRoll,
          )
        : sourceBytes;

    await _player.setSource(BytesSource(playbackBytes, mimeType: 'audio/wav'));
    await _player.seek(Duration.zero);
    if (_disposed || requestId != _requestId) return;

    final completion = Completer<void>();
    _playbackCompletion = completion;
    _completionSubscription = _player.onPlayerComplete.listen((_) {
      _completePlayback();
    });

    try {
      await _player.resume();
      await completion.future;
    } catch (_) {
      _completePlayback();
      rethrow;
    }
  }

  Future<Uint8List> _loadAsset(String assetPath) async {
    final cached = _assetCache[assetPath];
    if (cached != null) return cached;
    final data = await _assetBundle.load(assetPath);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    _assetCache[assetPath] = bytes;
    return bytes;
  }

  @override
  Future<void> stop() async {
    if (_disposed) return;
    _requestId++;
    _completePlayback();
    await _player.stop();
  }

  void _completePlayback() {
    final subscription = _completionSubscription;
    _completionSubscription = null;
    if (subscription != null) unawaited(subscription.cancel());

    final completion = _playbackCompletion;
    _playbackCompletion = null;
    if (completion != null && !completion.isCompleted) completion.complete();
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _requestId++;
    _completePlayback();
    _assetCache.clear();
    await _player.dispose();
  }
}
