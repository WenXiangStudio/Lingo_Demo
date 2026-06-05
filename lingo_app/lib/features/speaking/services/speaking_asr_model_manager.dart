import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../../core/data_dir.dart';

class SpeakingAsrModelFile {
  const SpeakingAsrModelFile({
    required this.path,
    required this.sizeBytes,
    required this.sha256,
  });

  final String path;
  final int sizeBytes;
  final String sha256;
}

class SpeakingAsrModelInfo {
  const SpeakingAsrModelInfo({
    required this.id,
    required this.name,
    required this.dirName,
    required this.version,
    required this.approxSizeMb,
    required this.baseUrl,
    required this.files,
    required this.supportedLanguages,
  });

  final String id;
  final String name;
  final String dirName;
  final String version;
  final int approxSizeMb;
  final String baseUrl;
  final List<SpeakingAsrModelFile> files;
  final List<String> supportedLanguages;

  int get totalSizeBytes =>
      files.fold<int>(0, (total, file) => total + file.sizeBytes);
}

abstract class SpeakingAsrModelState {
  const SpeakingAsrModelState();
}

class SpeakingAsrModelNotDownloaded extends SpeakingAsrModelState {
  const SpeakingAsrModelNotDownloaded();
}

class SpeakingAsrModelDownloading extends SpeakingAsrModelState {
  const SpeakingAsrModelDownloading(this.progress);

  final double progress;
}

class SpeakingAsrModelReady extends SpeakingAsrModelState {
  const SpeakingAsrModelReady(this.modelDir);

  final String modelDir;
}

class SpeakingAsrModelError extends SpeakingAsrModelState {
  const SpeakingAsrModelError(this.code, {this.detail});

  final String code;
  final String? detail;
}

class SpeakingAsrModelManager {
  SpeakingAsrModelManager({
    Dio? dio,
    SpeakingAsrModelInfo model = defaultModel,
    Directory? baseDir,
  }) : _dio = dio ?? Dio(),
       _model = model,
       _baseDir = baseDir;

  static const defaultModel = SpeakingAsrModelInfo(
    id: 'sense_voice_int8',
    name: 'SenseVoice Small INT8',
    dirName: 'sense-voice-zh-en-ja-ko-yue-int8',
    version: 'sense-voice-2024-07-17-int8-v1',
    approxSizeMb: 240,
    baseUrl:
        'https://hf-mirror.com/csukuangfj/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17/resolve/main',
    files: [
      SpeakingAsrModelFile(
        path: 'model.int8.onnx',
        sizeBytes: 239233841,
        sha256:
            'C71F0CE00BEC95B07744E116345E33D8CBBE08CEF896382CF907BF4B51A2CD51',
      ),
      SpeakingAsrModelFile(
        path: 'tokens.txt',
        sizeBytes: 315894,
        sha256:
            'F449EB28DC567533D7FA59BE34E2ABCA8784F771850C78A47FB731A31429A1DC',
      ),
    ],
    supportedLanguages: ['zh', 'en', 'ja', 'ko', 'yue'],
  );

  final Dio _dio;
  final SpeakingAsrModelInfo _model;
  final Directory? _baseDir;
  final _stateController = StreamController<SpeakingAsrModelState>.broadcast();
  SpeakingAsrModelState _currentState = const SpeakingAsrModelNotDownloaded();
  Future<void>? _downloadInFlight;
  String _modelDir = '';

  Stream<SpeakingAsrModelState> get stateStream => _stateController.stream;
  SpeakingAsrModelState get currentState => _currentState;
  SpeakingAsrModelInfo get model => _model;

  Future<String> get modelDir async {
    if (_modelDir.isNotEmpty) return _modelDir;
    final appDir = _baseDir ?? await getLingoDataDir();
    _modelDir = '${appDir.path}/lingo_asr_models/${_model.dirName}';
    return _modelDir;
  }

  Future<bool> isModelReady() async {
    final dir = await modelDir;
    final marker = File('$dir/.lingo_asr_model_version');
    if (!await marker.exists()) return false;
    if ((await marker.readAsString()).trim() != _model.version) return false;

    for (final modelFile in _model.files) {
      if (!await _verifyFile(modelFile)) {
        await _deleteIfExists(marker);
        return false;
      }
    }
    return true;
  }

  Future<void> checkStatus() async {
    if (await isModelReady()) {
      await _emit(SpeakingAsrModelReady(await modelDir));
    } else {
      await _emit(const SpeakingAsrModelNotDownloaded());
    }
  }

  Future<void> downloadModel() async {
    final existing = _downloadInFlight;
    if (existing != null) return existing;
    final download = _downloadModelInternal();
    _downloadInFlight = download;
    try {
      await download;
    } finally {
      _downloadInFlight = null;
    }
  }

  Future<void> _downloadModelInternal() async {
    final dir = await modelDir;
    try {
      await Directory(dir).create(recursive: true);
      await _emit(const SpeakingAsrModelDownloading(0));

      var completedBytes = 0;
      final totalBytes = _model.totalSizeBytes;
      for (final modelFile in _model.files) {
        if (await _verifyFile(modelFile)) {
          completedBytes += modelFile.sizeBytes;
          _emitProgress(completedBytes, 0, totalBytes);
          continue;
        }

        await _deleteVersionMarker();
        await _downloadAndVerifyFile(
          modelFile,
          completedBytes: completedBytes,
          totalBytes: totalBytes,
        );
        completedBytes += modelFile.sizeBytes;
        _emitProgress(completedBytes, 0, totalBytes);
      }

      if (!await _hasRequiredFiles()) {
        throw const SpeakingAsrModelException('asr_model_verification_failed');
      }

      await File(
        '$dir/.lingo_asr_model_version',
      ).writeAsString(_model.version);
      await _emit(SpeakingAsrModelReady(dir));
    } on DioException catch (e) {
      await _emit(
        SpeakingAsrModelError(
          'asr_download_network_error',
          detail: e.message ?? e.type.name,
        ),
      );
    } on FileSystemException catch (e) {
      await _emit(
        SpeakingAsrModelError('asr_download_disk_error', detail: e.message),
      );
    } on SpeakingAsrModelException catch (e) {
      await _emit(SpeakingAsrModelError(e.code));
    } catch (e) {
      await _emit(SpeakingAsrModelError('asr_download_unknown_error'));
    }
  }

  Future<bool> _hasRequiredFiles() async {
    for (final modelFile in _model.files) {
      if (!await _verifyFile(modelFile)) {
        return false;
      }
    }
    return true;
  }

  Future<void> _downloadAndVerifyFile(
    SpeakingAsrModelFile modelFile, {
    required int completedBytes,
    required int totalBytes,
  }) async {
    final dir = await modelDir;
    final savePath = '$dir/${modelFile.path}';
    final partPath = '$savePath.part';
    final partFile = File(partPath);
    if (await partFile.exists()) {
      await partFile.delete();
    }

    await _dio.download(
      '${_model.baseUrl}/${modelFile.path}',
      partPath,
      onReceiveProgress: (received, _) {
        _emitProgress(completedBytes, received, totalBytes);
      },
    );

    if (!await _verifyFile(modelFile, pathOverride: partPath)) {
      await _deleteIfExists(partFile);
      throw const SpeakingAsrModelException(
        'asr_download_verification_failed',
      );
    }

    final target = File(savePath);
    if (await target.exists()) {
      await target.delete();
    }
    await partFile.rename(savePath);
  }

  void _emitProgress(int completedBytes, int currentBytes, int totalBytes) {
    final progress = totalBytes <= 0
        ? 0.0
        : (completedBytes + currentBytes) / totalBytes;
    _setState(SpeakingAsrModelDownloading(progress.clamp(0, 1)));
  }

  Future<bool> _verifyFile(
    SpeakingAsrModelFile modelFile, {
    String? pathOverride,
  }) async {
    final dir = await modelDir;
    final file = File(pathOverride ?? '$dir/${modelFile.path}');
    if (!await file.exists()) return false;
    if (await file.length() != modelFile.sizeBytes) return false;
    final actual = await _sha256(file);
    return actual.toUpperCase() == modelFile.sha256.toUpperCase();
  }

  Future<String> _sha256(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  Future<void> _deleteVersionMarker() async {
    final dir = await modelDir;
    final marker = File('$dir/.lingo_asr_model_version');
    if (await marker.exists()) {
      await marker.delete();
    }
  }

  Future<void> _deleteIfExists(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> _emit(SpeakingAsrModelState state) async {
    _setState(state);
  }

  void _setState(SpeakingAsrModelState state) {
    _currentState = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  void dispose() {
    _stateController.close();
    _dio.close();
  }
}

class SpeakingAsrModelException implements Exception {
  const SpeakingAsrModelException(this.code);

  final String code;

  @override
  String toString() => code;
}
