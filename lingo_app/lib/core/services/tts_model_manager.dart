import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../data/repositories/repositories.dart';
import '../data_dir.dart';
import 'tts_model_state.dart';

/// Manages downloading and verifying Supertonic 3 model files.
///
/// Large ONNX files (~380 MB) are downloaded from HuggingFace.
/// Small binary files (unicode_indexer.bin, voice_styles/*.bin, ~780 KB) are
/// bundled as Flutter assets and copied to the model directory on first launch.
class TtsModelManager {
  final SettingsRepository _settingsRepo;
  final Dio _dio = Dio();
  final StreamController<TtsModelState> _stateController =
      StreamController<TtsModelState>.broadcast();

  static const String _modelVersion = 'supertonic-3-fp32-v2';
  static const String _hfBase =
      'https://hf-mirror.com/Supertone/supertonic-3/resolve/main';

  /// ONNX / JSON files downloaded from HuggingFace.
  static const _hfFiles = <(String, String)>[
    ('onnx/duration_predictor.onnx', 'onnx/duration_predictor.onnx'),
    ('onnx/text_encoder.onnx', 'onnx/text_encoder.onnx'),
    ('onnx/vector_estimator.onnx', 'onnx/vector_estimator.onnx'),
    ('onnx/vocoder.onnx', 'onnx/vocoder.onnx'),
    ('onnx/tts.json', 'onnx/tts.json'),
  ];

  /// BIN files bundled as Flutter assets (assets/tts_model/).
  static const _assetFiles = <String>[
    'unicode_indexer.bin',
  ];

  /// Voice style BIN files bundled as assets.
  static const _voiceStyles = <String>[
    'M1', 'M2', 'M3', 'M4', 'M5',
    'F1', 'F2', 'F3', 'F4', 'F5',
  ];

  /// All files that must exist for the model to be considered ready.
  static const _requiredFiles = <String>[
    'onnx/duration_predictor.onnx',
    'onnx/text_encoder.onnx',
    'onnx/vector_estimator.onnx',
    'onnx/vocoder.onnx',
    'onnx/tts.json',
    'onnx/unicode_indexer.bin',
  ];

  TtsModelManager({required SettingsRepository settingsRepo})
      : _settingsRepo = settingsRepo;

  Stream<TtsModelState> get stateStream => _stateController.stream;

  TtsModelState get currentState {
    if (_stateController.isClosed) return TtsModelNotDownloaded();
    return TtsModelNotDownloaded();
  }

  String _modelDir = '';

  Future<String> get modelDir async {
    if (_modelDir.isNotEmpty) return _modelDir;
    final appDir = await getLingoDataDir();
    _modelDir = '${appDir.path}/lingo_tts_models/supertonic-3-fp32';
    return _modelDir;
  }

  /// Check whether all required model files exist on disk.
  Future<bool> isModelReady() async {
    final dir = await modelDir;
    for (final rel in _requiredFiles) {
      final file = File('$dir/$rel');
      if (!await file.exists() || await file.length() == 0) return false;
    }
    // At least one voice style must exist
    final voiceDir = Directory('$dir/voice_styles');
    if (!await voiceDir.exists()) return false;
    final voices = await voiceDir.list().toList();
    if (voices.isEmpty) return false;

    final saved = await _settingsRepo.getTtsModelVersion();
    return saved == _modelVersion;
  }

  /// Check model status and emit the appropriate state.
  Future<void> checkStatus() async {
    if (await isModelReady()) {
      final dir = await modelDir;
      _stateController.add(TtsModelReady(dir));
    } else {
      _stateController.add(TtsModelNotDownloaded());
    }
  }

  /// Download ONNX files from HuggingFace and copy BIN files from assets.
  Future<void> downloadModel() async {
    final dir = await modelDir;
    try {
      _stateController.add(TtsModelDownloading(0));

      final totalFiles = _hfFiles.length + _assetFiles.length + _voiceStyles.length;
      int completed = 0;

      // Create directories
      await Directory('$dir/onnx').create(recursive: true);
      await Directory('$dir/voice_styles').create(recursive: true);

      // Download large ONNX files from HuggingFace
      for (final (remote, local) in _hfFiles) {
        final url = '$_hfBase/$remote';
        final savePath = '$dir/$local';
        await _downloadFile(url, savePath);
        completed++;
        _stateController.add(TtsModelDownloading(completed / totalFiles));
      }

      // Copy small BIN files from bundled assets
      for (final assetName in _assetFiles) {
        final data = await rootBundle.load('assets/tts_model/$assetName');
        await File('$dir/onnx/$assetName').writeAsBytes(
          data.buffer.asUint8List(),
        );
        completed++;
        _stateController.add(TtsModelDownloading(completed / totalFiles));
      }

      // Copy voice style BIN files from bundled assets
      for (final voice in _voiceStyles) {
        final data = await rootBundle.load('assets/tts_model/$voice.bin');
        await File('$dir/voice_styles/$voice.bin').writeAsBytes(
          data.buffer.asUint8List(),
        );
        completed++;
        _stateController.add(TtsModelDownloading(completed / totalFiles));
      }

      // Verify
      if (await isModelReady()) {
        await _settingsRepo.setTtsModelVersion(_modelVersion);
        _stateController.add(TtsModelReady(dir));
      } else {
        _stateController.add(
          TtsModelError('Download completed but model verification failed.'),
        );
      }
    } on DioException catch (e) {
      _stateController.add(
        TtsModelError('Network error: ${e.message ?? e.type}'),
      );
    } catch (e) {
      _stateController.add(TtsModelError(e.toString()));
    }
  }

  Future<void> _downloadFile(String url, String savePath) async {
    await _dio.download(url, savePath);
  }

  /// Delete all model files.
  Future<void> deleteModel() async {
    final dir = await modelDir;
    final md = Directory(dir);
    if (await md.exists()) {
      await md.delete(recursive: true);
    }
    await _settingsRepo.setTtsModelVersion('');
    _stateController.add(TtsModelNotDownloaded());
  }

  void dispose() {
    _stateController.close();
    _dio.close();
  }
}
