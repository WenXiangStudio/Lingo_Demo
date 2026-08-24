import 'dart:typed_data';

/// Builds a playback-only PCM WAV with real silent frames before its audio.
///
/// Unsupported or malformed inputs are returned unchanged so callers can
/// safely use this immediately before playback without changing MP3 or other
/// audio paths. The source bytes themselves are never modified.
class WavPlaybackPreRoll {
  const WavPlaybackPreRoll._();

  static Uint8List prependPcm16Silence(
    Uint8List source, {
    required Duration duration,
  }) {
    if (duration <= Duration.zero ||
        source.length < 12 ||
        !_hasAsciiId(source, 0, 'RIFF') ||
        !_hasAsciiId(source, 8, 'WAVE')) {
      return source;
    }

    final sourceData = ByteData.sublistView(source);
    var chunkOffset = 12;
    int? audioFormat;
    int? channels;
    int? sampleRate;
    int? byteRate;
    int? blockAlign;
    int? bitsPerSample;
    int? dataChunkOffset;
    int? audioDataOffset;
    int? audioDataLength;

    while (chunkOffset + 8 <= source.length) {
      final chunkSize = sourceData.getUint32(chunkOffset + 4, Endian.little);
      final chunkDataOffset = chunkOffset + 8;
      final availableChunkBytes = source.length - chunkDataOffset;

      if (_hasAsciiId(source, chunkOffset, 'fmt ')) {
        if (chunkSize < 16 || chunkSize > availableChunkBytes) return source;
        audioFormat = sourceData.getUint16(chunkDataOffset, Endian.little);
        channels = sourceData.getUint16(chunkDataOffset + 2, Endian.little);
        sampleRate = sourceData.getUint32(chunkDataOffset + 4, Endian.little);
        byteRate = sourceData.getUint32(chunkDataOffset + 8, Endian.little);
        blockAlign = sourceData.getUint16(chunkDataOffset + 12, Endian.little);
        bitsPerSample = sourceData.getUint16(
          chunkDataOffset + 14,
          Endian.little,
        );
      } else if (_hasAsciiId(source, chunkOffset, 'data')) {
        // Downloaded streaming WAVs can retain a sentinel/very large chunk
        // length. Once all bytes are in memory, the remaining bytes are the
        // authoritative PCM payload.
        dataChunkOffset = chunkOffset;
        audioDataOffset = chunkDataOffset;
        audioDataLength = chunkSize > availableChunkBytes
            ? availableChunkBytes
            : chunkSize;
        break;
      } else if (chunkSize > availableChunkBytes) {
        return source;
      }

      chunkOffset = chunkDataOffset + chunkSize + (chunkSize.isOdd ? 1 : 0);
    }

    if (audioFormat != 1 ||
        channels == null ||
        channels <= 0 ||
        sampleRate == null ||
        sampleRate <= 0 ||
        byteRate == null ||
        blockAlign == null ||
        bitsPerSample != 16 ||
        dataChunkOffset == null ||
        audioDataOffset == null ||
        audioDataLength == null) {
      return source;
    }

    final expectedBlockAlign = channels * 2;
    if (blockAlign != expectedBlockAlign ||
        byteRate != sampleRate * blockAlign ||
        audioDataLength % blockAlign != 0) {
      return source;
    }

    final silentFrameCount =
        (sampleRate * duration.inMicroseconds + 500000) ~/ 1000000;
    final silenceLength = silentFrameCount * blockAlign;
    if (silenceLength <= 0) return source;

    final rebuiltDataLength = audioDataLength + silenceLength;
    final rebuiltFileLength = source.length + silenceLength;
    if (rebuiltDataLength > 0xffffffff || rebuiltFileLength - 8 > 0xffffffff) {
      return source;
    }

    final rebuilt = Uint8List(rebuiltFileLength);
    rebuilt.setRange(0, audioDataOffset, source);
    // Uint8List is zero-initialized, so the inserted frames are PCM silence.
    rebuilt.setRange(
      audioDataOffset + silenceLength,
      rebuilt.length,
      source,
      audioDataOffset,
    );

    final rebuiltData = ByteData.sublistView(rebuilt);
    rebuiltData.setUint32(4, rebuilt.length - 8, Endian.little);
    rebuiltData.setUint32(
      dataChunkOffset + 4,
      rebuiltDataLength,
      Endian.little,
    );
    return rebuilt;
  }

  static bool _hasAsciiId(Uint8List bytes, int offset, String id) {
    if (id.length != 4 || offset < 0 || offset + 4 > bytes.length) {
      return false;
    }
    return bytes[offset] == id.codeUnitAt(0) &&
        bytes[offset + 1] == id.codeUnitAt(1) &&
        bytes[offset + 2] == id.codeUnitAt(2) &&
        bytes[offset + 3] == id.codeUnitAt(3);
  }
}
