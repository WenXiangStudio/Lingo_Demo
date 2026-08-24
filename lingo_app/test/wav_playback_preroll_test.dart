import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingo_app/core/utils/wav_playback_preroll.dart';

Uint8List _pcm16Wav({
  int sampleRate = 48000,
  int channels = 1,
  int durationMilliseconds = 250,
  int? riffLengthHeader,
  int? dataLengthHeader,
}) {
  const bitsPerSample = 16;
  final blockAlign = channels * bitsPerSample ~/ 8;
  final sampleFrameCount = sampleRate * durationMilliseconds ~/ 1000;
  final audioDataLength = sampleFrameCount * blockAlign;
  final bytes = Uint8List(44 + audioDataLength);
  final data = ByteData.sublistView(bytes);

  bytes.setRange(0, 4, 'RIFF'.codeUnits);
  data.setUint32(4, riffLengthHeader ?? bytes.length - 8, Endian.little);
  bytes.setRange(8, 12, 'WAVE'.codeUnits);
  bytes.setRange(12, 16, 'fmt '.codeUnits);
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, channels, Endian.little);
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, sampleRate * blockAlign, Endian.little);
  data.setUint16(32, blockAlign, Endian.little);
  data.setUint16(34, bitsPerSample, Endian.little);
  bytes.setRange(36, 40, 'data'.codeUnits);
  data.setUint32(40, dataLengthHeader ?? audioDataLength, Endian.little);

  for (var offset = 44; offset < bytes.length; offset += 2) {
    final sampleIndex = (offset - 44) ~/ 2;
    data.setInt16(offset, 1000 + sampleIndex % 20000, Endian.little);
  }
  return bytes;
}

void main() {
  group('WavPlaybackPreRoll', () {
    const preRoll = Duration(milliseconds: 210);
    const sampleRate = 48000;
    const blockAlign = 2;
    const silenceLength = sampleRate * 210 ~/ 1000 * blockAlign;

    test('prepends zero PCM frames and preserves every original PCM byte', () {
      final source = _pcm16Wav();
      final originalPcm = Uint8List.fromList(source.sublist(44));

      final rebuilt = WavPlaybackPreRoll.prependPcm16Silence(
        source,
        duration: preRoll,
      );
      final rebuiltData = ByteData.sublistView(rebuilt);

      expect(rebuilt.length, source.length + silenceLength);
      expect(rebuiltData.getUint32(4, Endian.little), rebuilt.length - 8);
      expect(
        rebuiltData.getUint32(40, Endian.little),
        originalPcm.length + silenceLength,
      );
      expect(rebuilt.sublist(44, 44 + silenceLength), everyElement(0));
      expect(rebuilt.sublist(44 + silenceLength), orderedEquals(originalPcm));
      expect(source.sublist(44), orderedEquals(originalPcm));
    });

    test('normalizes Qwen streaming length headers in the memory copy', () {
      final source = _pcm16Wav(
        riffLengthHeader: 0x7fffffbf,
        dataLengthHeader: 0x7fffff9b,
      );
      final sourceHeader = Uint8List.fromList(source.sublist(0, 44));

      final rebuilt = WavPlaybackPreRoll.prependPcm16Silence(
        source,
        duration: preRoll,
      );
      final rebuiltData = ByteData.sublistView(rebuilt);

      expect(rebuiltData.getUint32(4, Endian.little), rebuilt.length - 8);
      expect(
        rebuiltData.getUint32(40, Endian.little),
        source.length - 44 + silenceLength,
      );
      expect(
        rebuilt.sublist(44 + silenceLength),
        orderedEquals(source.sublist(44)),
      );
      expect(source.sublist(0, 44), orderedEquals(sourceHeader));
    });

    test('supports PCM16 frame sizes other than the Qwen mono profile', () {
      final source = _pcm16Wav(sampleRate: 44100, channels: 2);
      const stereoSilenceLength = 44100 * 210 ~/ 1000 * 4;

      final rebuilt = WavPlaybackPreRoll.prependPcm16Silence(
        source,
        duration: preRoll,
      );

      expect(rebuilt.length, source.length + stereoSilenceLength);
      expect(rebuilt.sublist(44, 44 + stereoSilenceLength), everyElement(0));
      expect(
        rebuilt.sublist(44 + stereoSilenceLength),
        orderedEquals(source.sublist(44)),
      );
    });

    test('returns malformed and unsupported audio unchanged', () {
      final malformed = Uint8List.fromList([1, 2, 3]);
      expect(
        identical(
          WavPlaybackPreRoll.prependPcm16Silence(malformed, duration: preRoll),
          malformed,
        ),
        isTrue,
      );

      final unsupported = _pcm16Wav();
      ByteData.sublistView(unsupported).setUint16(20, 3, Endian.little);
      expect(
        identical(
          WavPlaybackPreRoll.prependPcm16Silence(
            unsupported,
            duration: preRoll,
          ),
          unsupported,
        ),
        isTrue,
      );
    });

    test('returns the source unchanged when pre-roll is disabled', () {
      final source = _pcm16Wav();
      expect(
        identical(
          WavPlaybackPreRoll.prependPcm16Silence(
            source,
            duration: Duration.zero,
          ),
          source,
        ),
        isTrue,
      );
    });
  });
}
