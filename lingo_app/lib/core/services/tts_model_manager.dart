import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../../data/repositories/repositories.dart';
import '../data_dir.dart';
import 'tts_model_state.dart';

/// Manages installing and verifying Supertonic 3 model files.
///
/// The offline Android test build bundles the known-good ONNX files, so model
/// installation works without a network connection. Lightweight builds can
/// still fall back to the model mirrors when the full assets are not present.
class TtsModelManager {
  final SettingsRepository _settingsRepo;
  final Dio _dio = Dio();
  final StreamController<TtsModelState> _stateController =
      StreamController<TtsModelState>.broadcast();

  static const String _modelVersion = 'supertonic-3-fp32-v3-offline';
  static const String _assetRoot = 'assets/tts_model';
  static const MethodChannel _assetInstaller = MethodChannel(
    'lingo/tts_model_assets',
  );

  static const _modelMirrors = <String>[
    'https://hf-mirror.com/Supertone/supertonic-3/resolve/main',
    'https://huggingface.co/Supertone/supertonic-3/resolve/main',
  ];

  /// Large ONNX / JSON files. The offline build keeps these below
  /// [assets/tts_model/onnx/].
  static const _modelFiles = <String>[
    'onnx/duration_predictor.onnx',
    'onnx/text_encoder.onnx',
    'onnx/vector_estimator.onnx',
    'onnx/vocoder.onnx',
    'onnx/tts.json',
  ];

  /// BIN files bundled as Flutter assets (assets/tts_model/).
  static const _assetFiles = <String>['unicode_indexer.bin'];

  /// Voice style BIN files bundled as assets.
  static const _voiceStyles = <String>[
    'M1',
    'M2',
    'M3',
    'M4',
    'M5',
    'F1',
    'F2',
    'F3',
    'F4',
    'F5',
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

  /// Expected sizes prevent a partial or proxy-generated response from being
  /// treated as a usable model. APK assets themselves are signature-checked by
  /// Android; these sizes additionally protect the network fallback.
  static const _requiredFileSizes = <String, int>{
    'onnx/duration_predictor.onnx': 3700147,
    'onnx/text_encoder.onnx': 36416150,
    'onnx/vector_estimator.onnx': 256534781,
    'onnx/vocoder.onnx': 101424195,
    'onnx/tts.json': 8253,
    'onnx/unicode_indexer.bin': 262144,
  };

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
    if (!await _hasRequiredModelFiles()) return false;
    final saved = await _settingsRepo.getTtsModelVersion();
    return saved == _modelVersion;
  }

  Future<bool> _hasRequiredModelFiles() async {
    final dir = await modelDir;
    for (final rel in _requiredFiles) {
      final file = File('$dir/$rel');
      if (!await file.exists()) return false;
      final expectedSize = _requiredFileSizes[rel];
      if (expectedSize != null && await file.length() != expectedSize) {
        return false;
      }
    }
    // At least one voice style must exist
    final voiceDir = Directory('$dir/voice_styles');
    if (!await voiceDir.exists()) return false;
    final voices = await voiceDir.list().toList();
    if (voices.isEmpty) return false;
    return true;
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

  /// Install a bundled model when available, otherwise download it from a
  /// mirror. The public method name remains for compatibility with callers.
  Future<void> downloadModel() async {
    final dir = await modelDir;
    try {
      _stateController.add(TtsModelDownloading(0));

      final totalFiles =
          _modelFiles.length + _assetFiles.length + _voiceStyles.length;
      int completed = 0;
      final hasBundledModel = await _hasBundledModelAssets();

      // Create directories
      await Directory('$dir/onnx').create(recursive: true);
      await Directory('$dir/voice_styles').create(recursive: true);

      // The offline build copies the exact model that was validated locally.
      // Lightweight builds retain the download path as a fallback.
      for (final relativePath in _modelFiles) {
        final savePath = '$dir/$relativePath';
        if (hasBundledModel) {
          await _copyAssetToFile('$_assetRoot/$relativePath', savePath);
        } else {
          await _downloadFile(relativePath, savePath);
        }
        completed++;
        _stateController.add(TtsModelDownloading(completed / totalFiles));
      }

      // Copy small BIN files from bundled assets
      for (final assetName in _assetFiles) {
        await _copyAssetToFile(
          '$_assetRoot/$assetName',
          '$dir/onnx/$assetName',
        );
        completed++;
        _stateController.add(TtsModelDownloading(completed / totalFiles));
      }

      // Copy voice style BIN files from bundled assets
      for (final voice in _voiceStyles) {
        await _copyAssetToFile(
          '$_assetRoot/$voice.bin',
          '$dir/voice_styles/$voice.bin',
        );
        completed++;
        _stateController.add(TtsModelDownloading(completed / totalFiles));
      }

      // Verify
      if (await _hasRequiredModelFiles()) {
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

  Future<bool> _hasBundledModelAssets() async {
    try {
      await rootBundle.load('$_assetRoot/onnx/tts.json');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _copyAssetToFile(String assetPath, String savePath) async {
    final target = File(savePath);
    await target.parent.create(recursive: true);

    if (Platform.isAndroid) {
      try {
        await _assetInstaller.invokeMethod<void>('copyAssetToFile', {
          'assetPath': assetPath,
          'destinationPath': savePath,
        });
        return;
      } on MissingPluginException {
        // Fall through for unit tests and non-Android Flutter embedders.
      }
    }

    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final temporary = File('$savePath.part');
    if (await temporary.exists()) await temporary.delete();
    await temporary.writeAsBytes(bytes, flush: true);
    if (await target.exists()) await target.delete();
    await temporary.rename(savePath);
  }

  Future<void> _downloadFile(String relativePath, String savePath) async {
    Object? lastError;
    for (final baseUrl in _modelMirrors) {
      final temporary = File('$savePath.part');
      try {
        if (await temporary.exists()) await temporary.delete();
        await _dio.download(
          '$baseUrl/$relativePath',
          temporary.path,
          options: Options(
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(minutes: 5),
            validateStatus: (status) =>
                status != null && status >= 200 && status < 300,
          ),
          deleteOnError: false,
        );
        final target = File(savePath);
        if (await target.exists()) await target.delete();
        await temporary.rename(savePath);
        return;
      } catch (error) {
        lastError = error;
      }
    }
    throw lastError ?? StateError('No model mirror is available.');
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
