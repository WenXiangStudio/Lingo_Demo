import 'dart:io';

import 'package:record/record.dart';

import '../../../core/data_dir.dart';

class SpeakingRecordingService {
  SpeakingRecordingService({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<String> start() async {
    if (!await hasPermission()) {
      throw const SpeakingRecordingException('speaking_mic_permission_denied');
    }

    final appDir = await getLingoDataDir();
    final tmpDir = Directory('${appDir.path}/lingo_speaking_tmp');
    if (!await tmpDir.exists()) {
      await tmpDir.create(recursive: true);
    }

    final stamp = DateTime.now().microsecondsSinceEpoch;
    final path = '${tmpDir.path}/speaking_$stamp.wav';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
        echoCancel: true,
        noiseSuppress: true,
      ),
      path: path,
    );
    return path;
  }

  Future<String?> stop() => _recorder.stop();

  Future<void> cancel() => _recorder.cancel();

  Future<bool> isRecording() => _recorder.isRecording();

  void dispose() {
    _recorder.dispose();
  }
}

class SpeakingRecordingException implements Exception {
  const SpeakingRecordingException(this.code);

  final String code;

  @override
  String toString() => code;
}
