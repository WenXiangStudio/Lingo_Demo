import 'dart:io';
import 'dart:typed_data';

import 'package:sherpa_onnx/sherpa_onnx.dart';

import '../../data_dir.dart';
import '../../utils/text_normalizer.dart';

/// Wraps the sherpa_onnx [OfflineTts] with Supertonic 3 model configuration.
///
/// Must call [initialize] before [synthesize].
class SupertonicTtsEngine {
  static const int longFormMaxChars = 150;
  static const int longFormMinChars = 100;
  static const int longFormSilenceMs = 80;
  static const int longFormNumSteps = 8;
  static const double longFormSpeed = 1.05;

  OfflineTts? _tts;
  bool _initialized = false;
  int _sampleRate = 0;

  bool get isInitialized => _initialized;
  int get sampleRate => _sampleRate;

  /// Load all ONNX model files from [modelDir] and create the TTS engine.
  ///
  /// [modelDir] should contain the HuggingFace directory structure:
  ///   onnx/duration_predictor.onnx, onnx/text_encoder.onnx, etc.
  ///   onnx/unicode_indexer.bin (binary format, converted from HF JSON)
  ///   voice_styles/M1.bin (binary format, converted from HF JSON)
  Future<void> initialize(String modelDir, {int numThreads = 2}) async {
    final config = OfflineTtsModelConfig(
      supertonic: OfflineTtsSupertonicModelConfig(
        durationPredictor: '$modelDir/onnx/duration_predictor.onnx',
        textEncoder: '$modelDir/onnx/text_encoder.onnx',
        vectorEstimator: '$modelDir/onnx/vector_estimator.onnx',
        vocoder: '$modelDir/onnx/vocoder.onnx',
        ttsJson: '$modelDir/onnx/tts.json',
        unicodeIndexer: '$modelDir/onnx/unicode_indexer.bin',
        voiceStyle: '$modelDir/voice_styles/M1.bin',
      ),
      numThreads: numThreads,
      provider: 'cpu',
    );

    _tts = OfflineTts(OfflineTtsConfig(model: config));
    _sampleRate = _tts!.sampleRate;
    _initialized = true;
  }

  /// Synthesize [text] and return raw PCM audio samples.
  ///
  /// [speed] range: 0.25 to 2.0 (1.0 = normal).
  /// [sid] speaker ID (0 = default voice from voiceStyle).
  /// [numSteps] diffusion denoising steps (5=fast, 10=clean, 15=best). Higher
  /// values reduce breath/sigh artifacts at word endings.
  GeneratedAudio synthesize(
    String text, {
    double speed = 1.0,
    int sid = 0,
    int numSteps = 10,
    String lang = 'en',
  }) {
    if (!_initialized || _tts == null) {
      throw StateError(
        'SupertonicTtsEngine not initialized. Call initialize() first.',
      );
    }
    return _tts!.generateWithConfig(
      text: text,
      config: OfflineTtsGenerationConfig(
        sid: sid,
        speed: speed,
        numSteps: numSteps,
        extra: {'lang': _generationLang(lang)},
      ),
    );
  }

  static String _generationLang(String lang) {
    final normalized = lang.trim().toLowerCase();
    if (normalized.isEmpty) return 'en';
    return normalized.split(RegExp(r'[-_]')).first;
  }

  /// Preprocess text for cleaner TTS output.
  ///
  /// Normalize text before synthesis. Repeated dots / ellipsis often get
  /// verbalized as noise by the model, so treat them as a pause instead.
  /// Semicolons create an overly strong pause in Supertonic, so degrade them
  /// to commas before generation.
  static String preprocessText(String text, {bool preserveParagraphs = false}) {
    final normalized = TextNormalizer.normalizeQuotes(text)
        .replaceAll(RegExp(r'\.{2,}'), ',')
        .replaceAll(RegExp(r'…+'), ',')
        .replaceAll(RegExp(r'[;；]'), ',');
    if (!preserveParagraphs) {
      return normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    }
    return normalized
        .replaceAll(RegExp(r'[ \t\r\f\v]+'), ' ')
        .replaceAll(RegExp(r' *\n *'), '\n')
        .trim();
  }

  /// Split paragraph-like input into bounded chunks for Supertonic generation.
  ///
  /// The model is reliable on short utterances but can repeat earlier phrases
  /// when one long paragraph is generated in a single pass. This mirrors
  /// Supertonic's official Python chunk_text approach: split paragraphs into
  /// sentences, then accumulate whole sentences up to a bounded chunk length.
  /// Playback still happens after all chunks are stitched into one WAV.
  static List<String> splitLongFormText(
    String text, {
    int maxChars = longFormMaxChars,
    int minChars = longFormMinChars,
  }) {
    if (maxChars < 10) {
      throw ArgumentError.value(maxChars, 'maxChars', 'must be at least 10');
    }

    final normalized = preprocessText(text, preserveParagraphs: true);
    if (normalized.isEmpty) return const [];

    final chunks = <String>[];
    final paragraphs = normalized
        .split(RegExp(r'\n\s*\n+'))
        .map((p) => p.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((p) => p.isNotEmpty);

    for (final paragraph in paragraphs) {
      var currentChunk = '';
      for (final sentence in _splitSentences(paragraph)) {
        if (sentence.length > maxChars) {
          if (currentChunk.isNotEmpty) {
            chunks.add(currentChunk);
            currentChunk = '';
          }
          chunks.addAll(
            _splitOverlongSentence(
              sentence,
              maxChars: maxChars,
              minChars: minChars,
            ),
          );
          continue;
        }

        final candidate = currentChunk.isEmpty
            ? sentence
            : '$currentChunk $sentence';
        if (candidate.length <= maxChars) {
          currentChunk = candidate;
        } else {
          if (currentChunk.isNotEmpty) chunks.add(currentChunk);
          currentChunk = sentence;
        }
      }
      if (currentChunk.isNotEmpty) chunks.add(currentChunk);
    }
    return chunks;
  }

  static List<String> _splitSentences(String paragraph) {
    final sentences = <String>[];
    var start = 0;
    var i = 0;
    while (i < paragraph.length) {
      final char = paragraph[i];
      final isBoundary = '.!?。！？'.contains(char);
      if (!isBoundary || _isProtectedSentenceDot(paragraph, i)) {
        i++;
        continue;
      }

      final next = i + 1;
      final canSplit =
          next >= paragraph.length || RegExp(r'\s').hasMatch(paragraph[next]);
      if (!canSplit) {
        i++;
        continue;
      }

      final sentence = paragraph.substring(start, next).trim();
      if (sentence.isNotEmpty) sentences.add(sentence);
      start = next;
      while (start < paragraph.length &&
          RegExp(r'\s').hasMatch(paragraph[start])) {
        start++;
      }
      i = start;
    }

    final tail = paragraph.substring(start).trim();
    if (tail.isNotEmpty) sentences.add(tail);
    return sentences;
  }

  static bool _isProtectedSentenceDot(String text, int index) {
    if (text[index] != '.') return false;
    var start = index - 1;
    while (start >= 0 && !RegExp(r'\s').hasMatch(text[start])) {
      start--;
    }
    final token = text.substring(start + 1, index);
    final lower = token.toLowerCase();
    const abbreviations = {
      'mr',
      'mrs',
      'ms',
      'dr',
      'prof',
      'sr',
      'jr',
      'st',
      'vs',
      'etc',
      'e.g',
      'i.e',
      'ph.d',
    };
    return abbreviations.contains(lower) || RegExp(r'^[A-Z]$').hasMatch(token);
  }

  static List<String> _splitOverlongSentence(
    String sentence, {
    required int maxChars,
    required int minChars,
  }) {
    final chunks = <String>[];
    var start = 0;
    while (start < sentence.length) {
      while (start < sentence.length && sentence[start] == ' ') {
        start++;
      }
      if (start >= sentence.length) break;

      var end = (start + maxChars).clamp(0, sentence.length);
      if (end < sentence.length) {
        final phraseBoundary = _lastBoundary(sentence, start, end, ',，:：');
        final wordBoundary = sentence.lastIndexOf(' ', end);

        if (phraseBoundary >= start + minChars) {
          end = phraseBoundary;
        } else if (wordBoundary >= start + minChars) {
          end = wordBoundary;
        }
      }

      final chunk = sentence.substring(start, end).trim();
      if (chunk.isNotEmpty) chunks.add(chunk);
      start = end;
    }
    return chunks;
  }

  static int _lastBoundary(
    String text,
    int start,
    int end,
    String boundaryChars,
  ) {
    for (var i = end - 1; i > start; i--) {
      if (boundaryChars.contains(text[i])) return i + 1;
    }
    return -1;
  }

  /// Join synthesized chunks with a small silence gap, producing one playback
  /// buffer instead of repeatedly starting and stopping the audio player.
  static Float32List concatenateWithSilence(
    List<Float32List> chunks,
    int sampleRate, {
    int silenceMs = longFormSilenceMs,
  }) {
    if (chunks.isEmpty) return Float32List(0);
    if (chunks.length == 1) return chunks.first;

    final silenceSamples = (sampleRate * silenceMs / 1000).round();
    final totalSamples =
        chunks.fold<int>(0, (sum, chunk) => sum + chunk.length) +
        silenceSamples * (chunks.length - 1);
    final result = Float32List(totalSamples);
    var offset = 0;
    for (var i = 0; i < chunks.length; i++) {
      result.setRange(offset, offset + chunks[i].length, chunks[i]);
      offset += chunks[i].length;
      if (i != chunks.length - 1) offset += silenceSamples;
    }
    return result;
  }

  /// Apply a short fade-out to the tail of the audio to suppress breath/sigh
  /// artifacts that TTS models sometimes produce at utterance boundaries.
  static Float32List applyTailFadeOut(
    Float32List samples,
    int sampleRate, {
    int fadeDurationMs = 80,
  }) {
    final fadeSamples = (sampleRate * fadeDurationMs / 1000).round();
    if (fadeSamples >= samples.length || samples.length < fadeSamples * 2) {
      return samples;
    }
    final result = Float32List.fromList(samples);
    for (int i = 0; i < fadeSamples; i++) {
      final idx = result.length - fadeSamples + i;
      final gain = 1.0 - (i / fadeSamples);
      result[idx] *= gain;
    }
    return result;
  }

  /// Silence-gate: remove only trailing silence after the final audible sample.
  ///
  /// This removes breath/sigh/grunt artifacts that TTS models produce after
  /// the actual word ends without cutting valid audio after internal pauses.
  ///
  /// A short fade-out (10 ms) is applied at the new tail to avoid clicks.
  static Float32List trimTailSilence(
    Float32List samples,
    int sampleRate, {
    double threshold = 0.03,
    int holdMs = 80,
  }) {
    if (samples.isEmpty) return samples;
    final holdSamples = (sampleRate * holdMs / 1000).round();
    final fadeSamples = (sampleRate * 10 / 1000).round(); // 10ms fade
    final keepAfterLastAudibleSamples = (sampleRate * 15 / 1000).round();
    final minKeepSamples = sampleRate ~/ 20; // keep at least 50ms

    var lastAudible = samples.length - 1;
    while (lastAudible >= minKeepSamples &&
        samples[lastAudible].abs() < threshold) {
      lastAudible--;
    }
    if (lastAudible < minKeepSamples) return samples;

    final trailingSilenceSamples = samples.length - lastAudible - 1;
    if (trailingSilenceSamples < holdSamples) return samples;

    final cutLength = (lastAudible + 1 + keepAfterLastAudibleSamples)
        .clamp(minKeepSamples, samples.length)
        .toInt();
    if (cutLength >= samples.length - fadeSamples) return samples;

    final result = Float32List(cutLength);
    result.setRange(0, cutLength, samples);

    final fadeStart = (result.length - fadeSamples)
        .clamp(0, result.length)
        .toInt();
    final fadeLength = result.length - fadeStart;
    for (int i = 0; i < fadeLength; i++) {
      final idx = fadeStart + i;
      final gain = 1.0 - (i / fadeLength);
      result[idx] *= gain;
    }
    return result;
  }

  /// Convert raw PCM [samples] to a WAV byte buffer (in memory).
  ///
  /// Writes to a temp file using sherpa_onnx's writeWave(), then reads it back.
  /// This is a workaround until we implement an in-memory WAV encoder.
  Future<Uint8List> samplesToWav(Float32List samples) async {
    final appDir = await getLingoDataDir();
    final tmpDir = Directory('${appDir.path}/lingo_tts_tmp');
    if (!await tmpDir.exists()) {
      await tmpDir.create(recursive: true);
    }
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final tmpPath = '${tmpDir.path}/supertonic_$stamp.wav';
    writeWave(filename: tmpPath, samples: samples, sampleRate: sampleRate);
    final file = File(tmpPath);
    final bytes = await file.readAsBytes();
    if (await file.exists()) await file.delete();
    return bytes;
  }

  void dispose() {
    _tts?.free();
    _tts = null;
    _initialized = false;
  }
}
