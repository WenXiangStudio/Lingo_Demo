import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/data_dir.dart';

class NarrationAudioVault {
  NarrationAudioVault({FlutterSecureStorage? secureStorage, AesGcm? cipher})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
      _cipher = cipher ?? AesGcm.with256bits();

  static const _keyName = 'lingo_narration_audio_key_v1';
  static const _formatMarker = 'LINGO-AUDIO-ENC-V1';

  final FlutterSecureStorage _secureStorage;
  final AesGcm _cipher;

  Future<String?> finishTranscription({
    required String? plaintextPath,
    required bool retain,
  }) async {
    if (plaintextPath == null || plaintextPath.trim().isEmpty) return null;
    final source = File(plaintextPath);
    if (!await source.exists()) return null;
    if (!retain) {
      await source.delete();
      return null;
    }

    try {
      final appDir = await getLingoDataDir();
      final targetDir = Directory('${appDir.path}/lingo_narration_audio');
      await targetDir.create(recursive: true);
      final target = File(
        '${targetDir.path}/narration_${DateTime.now().microsecondsSinceEpoch}.lingoenc',
      );
      final secretKey = await _loadOrCreateKey();
      final nonce = _cipher.newNonce();
      final clearBytes = await source.readAsBytes();
      final secretBox = await _cipher.encrypt(
        clearBytes,
        secretKey: secretKey,
        nonce: nonce,
      );
      final envelope = jsonEncode({
        'format': _formatMarker,
        'nonce': base64Encode(secretBox.nonce),
        'mac': base64Encode(secretBox.mac.bytes),
        'ciphertext': base64Encode(secretBox.cipherText),
      });
      await target.writeAsString(envelope, flush: true);
      if (!await target.exists() || await target.length() == 0) {
        throw const FileSystemException('Encrypted audio was not saved.');
      }
      await source.delete();
      return target.path;
    } catch (_) {
      if (await source.exists()) {
        await source.delete();
      }
      rethrow;
    }
  }

  Future<String> openTemporaryCopy(String encryptedPath) async {
    await purgeTemporaryCopies();
    final source = File(encryptedPath);
    final envelope = jsonDecode(await source.readAsString());
    if (envelope is! Map || envelope['format'] != _formatMarker) {
      throw const FormatException('Unsupported encrypted audio format.');
    }
    final secretKey = await _loadOrCreateKey(createIfMissing: false);
    final box = SecretBox(
      base64Decode(envelope['ciphertext'] as String),
      nonce: base64Decode(envelope['nonce'] as String),
      mac: Mac(base64Decode(envelope['mac'] as String)),
    );
    final clearBytes = await _cipher.decrypt(box, secretKey: secretKey);
    final appDir = await getLingoDataDir();
    final tempDir = Directory('${appDir.path}/lingo_narration_audio_tmp');
    await tempDir.create(recursive: true);
    final target = File(
      '${tempDir.path}/playback_${DateTime.now().microsecondsSinceEpoch}.wav',
    );
    await target.writeAsBytes(clearBytes, flush: true);
    return target.path;
  }

  Future<void> deleteEncrypted(String? encryptedPath) async {
    if (encryptedPath == null || encryptedPath.trim().isEmpty) return;
    final file = File(encryptedPath);
    if (await file.exists()) await file.delete();
  }

  Future<void> purgeTemporaryCopies() async {
    final appDir = await getLingoDataDir();
    final tempDir = Directory('${appDir.path}/lingo_narration_audio_tmp');
    if (!await tempDir.exists()) return;
    await for (final entity in tempDir.list(followLinks: false)) {
      if (entity is File && entity.path.toLowerCase().endsWith('.wav')) {
        await entity.delete();
      }
    }
  }

  Future<SecretKey> _loadOrCreateKey({bool createIfMissing = true}) async {
    final encoded = await _secureStorage.read(key: _keyName);
    if (encoded != null && encoded.isNotEmpty) {
      return SecretKey(base64Decode(encoded));
    }
    if (!createIfMissing) {
      throw StateError('narration_audio_key_missing');
    }
    final key = await _cipher.newSecretKey();
    final bytes = Uint8List.fromList(await key.extractBytes());
    await _secureStorage.write(key: _keyName, value: base64Encode(bytes));
    return SecretKey(bytes);
  }
}
