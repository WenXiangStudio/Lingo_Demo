import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingo_app/features/speaking/services/speaking_asr_model_manager.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('lingo_asr_model_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('SpeakingAsrModelManager', () {
    test('reports not downloaded for an empty directory', () async {
      final manager = SpeakingAsrModelManager(
        model: _testModel(),
        baseDir: tempDir,
      );

      expect(await manager.isModelReady(), isFalse);
      await manager.checkStatus();
      expect(manager.currentState, isA<SpeakingAsrModelNotDownloaded>());

      manager.dispose();
    });

    test('rejects marker-only or corrupted model files', () async {
      final manager = SpeakingAsrModelManager(
        model: _testModel(),
        baseDir: tempDir,
      );
      final dir = Directory(await manager.modelDir);
      await dir.create(recursive: true);
      await File('${dir.path}/.lingo_asr_model_version').writeAsString('v1');

      expect(await manager.isModelReady(), isFalse);
      expect(
        await File('${dir.path}/.lingo_asr_model_version').exists(),
        isFalse,
      );

      await File('${dir.path}/one.bin').writeAsBytes([9, 9, 9]);
      await File('${dir.path}/two.txt').writeAsBytes([4, 5]);
      await File('${dir.path}/.lingo_asr_model_version').writeAsString('v1');

      expect(await manager.isModelReady(), isFalse);

      manager.dispose();
    });

    test('reports ready only when version, size, and hash match', () async {
      final one = Uint8List.fromList([1, 2, 3]);
      final two = Uint8List.fromList([4, 5]);
      final manager = SpeakingAsrModelManager(
        model: _testModel(one: one, two: two),
        baseDir: tempDir,
      );
      final dir = Directory(await manager.modelDir);
      await dir.create(recursive: true);
      await File('${dir.path}/one.bin').writeAsBytes(one);
      await File('${dir.path}/two.txt').writeAsBytes(two);
      await File('${dir.path}/.lingo_asr_model_version').writeAsString('v1');

      expect(await manager.isModelReady(), isTrue);
      await manager.checkStatus();
      expect(manager.currentState, isA<SpeakingAsrModelReady>());

      manager.dispose();
    });

    test('downloads to final files and writes marker after verification', () async {
      final one = Uint8List.fromList([1, 2, 3]);
      final two = Uint8List.fromList([4, 5]);
      final adapter = _FakeAdapter({
        '/one.bin': one,
        '/two.txt': two,
      });
      final dio = Dio()..httpClientAdapter = adapter;
      final manager = SpeakingAsrModelManager(
        dio: dio,
        model: _testModel(one: one, two: two),
        baseDir: tempDir,
      );

      await manager.downloadModel();

      final dir = await manager.modelDir;
      expect(await File('$dir/one.bin').readAsBytes(), one);
      expect(await File('$dir/two.txt').readAsBytes(), two);
      expect(await File('$dir/one.bin.part').exists(), isFalse);
      expect(
        await File('$dir/.lingo_asr_model_version').readAsString(),
        'v1',
      );
      expect(manager.currentState, isA<SpeakingAsrModelReady>());
      expect(adapter.fetchCount, 2);

      manager.dispose();
    });

    test('does not write marker when verification fails', () async {
      final one = Uint8List.fromList([1, 2, 3]);
      final badOne = Uint8List.fromList([1, 2, 4]);
      final two = Uint8List.fromList([4, 5]);
      final dio = Dio()
        ..httpClientAdapter = _FakeAdapter({
          '/one.bin': badOne,
          '/two.txt': two,
        });
      final manager = SpeakingAsrModelManager(
        dio: dio,
        model: _testModel(one: one, two: two),
        baseDir: tempDir,
      );

      await manager.downloadModel();

      final dir = await manager.modelDir;
      expect(await File('$dir/.lingo_asr_model_version').exists(), isFalse);
      expect(await File('$dir/one.bin.part').exists(), isFalse);
      final error = manager.currentState;
      expect(error, isA<SpeakingAsrModelError>());
      expect(
        (error as SpeakingAsrModelError).code,
        'asr_download_verification_failed',
      );

      manager.dispose();
    });

    test('coalesces concurrent downloads', () async {
      final one = Uint8List.fromList([1, 2, 3]);
      final two = Uint8List.fromList([4, 5]);
      final adapter = _FakeAdapter({
        '/one.bin': one,
        '/two.txt': two,
      }, delay: const Duration(milliseconds: 10));
      final dio = Dio()..httpClientAdapter = adapter;
      final manager = SpeakingAsrModelManager(
        dio: dio,
        model: _testModel(one: one, two: two),
        baseDir: tempDir,
      );

      await Future.wait([manager.downloadModel(), manager.downloadModel()]);

      expect(adapter.fetchCount, 2);
      expect(manager.currentState, isA<SpeakingAsrModelReady>());

      manager.dispose();
    });
  });
}

SpeakingAsrModelInfo _testModel({
  Uint8List? one,
  Uint8List? two,
}) {
  final oneBytes = one ?? Uint8List.fromList([1, 2, 3]);
  final twoBytes = two ?? Uint8List.fromList([4, 5]);
  return SpeakingAsrModelInfo(
    id: 'test',
    name: 'Test',
    dirName: 'test-model',
    version: 'v1',
    approxSizeMb: 1,
    baseUrl: 'https://example.test',
    files: [
      SpeakingAsrModelFile(
        path: 'one.bin',
        sizeBytes: oneBytes.length,
        sha256: sha256.convert(oneBytes).toString(),
      ),
      SpeakingAsrModelFile(
        path: 'two.txt',
        sizeBytes: twoBytes.length,
        sha256: sha256.convert(twoBytes).toString(),
      ),
    ],
    supportedLanguages: ['en'],
  );
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.responses, {this.delay = Duration.zero});

  final Map<String, Uint8List> responses;
  final Duration delay;
  int fetchCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    fetchCount++;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    final data = responses[options.uri.path];
    if (data == null) {
      return ResponseBody.fromString('Not Found', 404);
    }
    return ResponseBody.fromBytes(
      data,
      200,
      headers: {
        Headers.contentLengthHeader: [data.length.toString()],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
