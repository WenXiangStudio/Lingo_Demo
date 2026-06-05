import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../../data_dir.dart';

/// Windows SAPI TTS engine via VBScript.
///
/// Speaks directly through the system audio output — no audio file needed.
/// Only available on Windows.
class SapiTtsEngine {
  double speed = 0.5;
  Process? _process;

  bool get isAvailable => Platform.isWindows;

  int _rateFromSpeed(double speed) {
    return ((speed - 0.25) / 0.75 * 20 - 10).round().clamp(-10, 10);
  }

  /// Speak [text] via Windows SAPI and wait until SAPI finishes the utterance.
  Future<void> speak(String text) async {
    if (!isAvailable) return;

    final rate = _rateFromSpeed(speed);
    final dir = Directory('${(await getLingoDataDir()).path}\\lingo_tts_tmp');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final textPath = '${dir.path}\\lingo_tts_text_$stamp.txt';
    final vbsPath = '${dir.path}\\lingo_tts_$stamp.vbs';

    await _writeUnicodeFile(File(textPath), text);

    final vbsTextPath = textPath.replaceAll('\\', '\\\\');
    await File(vbsPath).writeAsString('''
Set fso = CreateObject("Scripting.FileSystemObject")
Set f = fso.OpenTextFile("$vbsTextPath", 1, False, -1)
tt = f.ReadAll
f.Close
Set voice = CreateObject("SAPI.SpVoice")
voice.Rate = $rate
voice.Speak tt
''');

    try {
      final process = await Process.start('wscript', [vbsPath]);
      _process = process;
      unawaited(process.stdout.drain<void>());
      unawaited(process.stderr.drain<void>());
      await process.exitCode;
    } finally {
      _process = null;
      final textFile = File(textPath);
      if (await textFile.exists()) await textFile.delete();
      final vbsFile = File(vbsPath);
      if (await vbsFile.exists()) await vbsFile.delete();
    }
  }

  Future<void> stop() async {
    final process = _process;
    if (process == null) return;
    process.kill();
    try {
      await process.exitCode.timeout(const Duration(seconds: 1));
    } catch (_) {}
    if (identical(_process, process)) {
      _process = null;
    }
  }

  /// Write text as UTF-16 LE with BOM (VBS OpenTextFile Unicode format).
  Future<void> _writeUnicodeFile(File file, String text) async {
    final bytes = Uint8List(text.length * 2 + 2);
    bytes[0] = 0xFF;
    bytes[1] = 0xFE;
    for (int i = 0; i < text.length; i++) {
      final code = text.codeUnitAt(i);
      bytes[i * 2 + 2] = code & 0xFF;
      bytes[i * 2 + 3] = (code >> 8) & 0xFF;
    }
    await file.writeAsBytes(bytes);
  }
}
