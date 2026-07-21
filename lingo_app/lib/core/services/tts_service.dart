import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart' as p;

import '../../data/database/app_database.dart';
import '../../data/repositories/repositories.dart';
import '../data_dir.dart';
import '../utils/text_normalizer.dart';
import 'tts_adapters/doubao_tts_adapter.dart';
import 'tts_adapters/openai_tts_adapter.dart';
import 'tts_adapters/qwen_tts_adapter.dart';
import 'tts_engines/sapi_tts_engine.dart';
import 'tts_engines/supertonic_tts_engine.dart';
import 'tts_model_manager.dart';
import 'tts_provider.dart';

class TtsPreCacheItem {
  final String text;
  final String listName;
  final int? listId;

  const TtsPreCacheItem({
    required this.text,
    required this.listName,
    this.listId,
  });
}

class TtsPreCacheProgress {
  final int done;
  final int total;
  final int success;
  final int skipped;
  final int failed;
  final int apiCalls;
  final int chargedCharacters;
  final int audioBytes;
  final String currentText;
  final String currentListName;

  const TtsPreCacheProgress({
    required this.done,
    required this.total,
    required this.success,
    required this.skipped,
    required this.failed,
    required this.apiCalls,
    required this.chargedCharacters,
    required this.audioBytes,
    required this.currentText,
    required this.currentListName,
  });
}

class TtsPreCacheResult {
  final int total;
  final int success;
  final int skipped;
  final int failed;
  final int apiCalls;
  final int chargedCharacters;
  final int audioBytes;
  final bool cancelled;
  final List<String> failedItems;

  const TtsPreCacheResult({
    required this.total,
    required this.success,
    required this.skipped,
    required this.failed,
    required this.apiCalls,
    required this.chargedCharacters,
    required this.audioBytes,
    required this.cancelled,
    required this.failedItems,
  });
}

class TtsCacheHealthReport {
  final String provider;
  final String language;
  final int recordCount;
  final int fileCount;
  final int healthyRecords;
  final int missingFiles;
  final int emptyFiles;
  final int orphanFiles;
  final int expiredRecords;
  final int expiredFiles;
  final int totalBytes;
  final Duration maxAge;

  const TtsCacheHealthReport({
    required this.provider,
    required this.language,
    required this.recordCount,
    required this.fileCount,
    required this.healthyRecords,
    required this.missingFiles,
    required this.emptyFiles,
    required this.orphanFiles,
    required this.expiredRecords,
    required this.expiredFiles,
    required this.totalBytes,
    required this.maxAge,
  });

  bool get hasIssues =>
      missingFiles > 0 ||
      emptyFiles > 0 ||
      orphanFiles > 0 ||
      expiredRecords > 0 ||
      expiredFiles > 0;

  bool get isHealthy => !hasIssues;
}

class TtsCacheCleanupResult {
  final int removedFiles;
  final int removedRecords;
  final int expiredRecords;
  final int orphanFiles;
  final int emptyFiles;

  const TtsCacheCleanupResult({
    required this.removedFiles,
    required this.removedRecords,
    required this.expiredRecords,
    required this.orphanFiles,
    required this.emptyFiles,
  });
}

/// Orchestrates TTS across multiple engines: Supertonic (on-device),
/// SAPI (Windows system), and cloud TtsProvider adapters.
///
/// Usage:
/// ```dart
/// final tts = TtsService(settingsRepo: repo, modelManager: manager);
/// await tts.init();
/// await tts.speak('Hello');
/// ```
class TtsService {
  final SettingsRepository _settingsRepo;
  final TtsModelManager _modelManager;
  final TtsRepository? _ttsRepo;

  SupertonicTtsEngine? _supertonic;
  SapiTtsEngine? _sapi;
  TtsProvider? _cloudProvider;
  Directory? _cacheDir;
  AudioPlayer? _player;
  Completer<void>? _playbackCompleter;
  void Function()? _completePlayback;

  bool _initialized = false;
  Future<void>? _initFuture;
  bool _speaking = false;
  bool _preCaching = false;

  TtsService({
    required SettingsRepository settingsRepo,
    required TtsModelManager modelManager,
    TtsRepository? ttsRepo,
  }) : _settingsRepo = settingsRepo,
       _modelManager = modelManager,
       _ttsRepo = ttsRepo;

  bool get isReady => _initialized;

  /// Initialise the service: read preferences, create engines, set up cache.
  ///
  /// Call once after construction. Safe to call again after [dispose].
  Future<void> init() {
    if (_initialized) return Future.value();
    return _initFuture ??= _initInternal();
  }

  Future<bool> _ensureInitialized() async {
    try {
      await init();
    } catch (_) {
      return false;
    }
    return _initialized;
  }

  Future<void> _initInternal() async {
    if (_initialized) return;
    try {
      _player = AudioPlayer();

      try {
        await _ensureCacheDir();
      } catch (_) {}

      // Initialise Windows SAPI engine (zero-cost, always available on Windows)
      if (Platform.isWindows) {
        _sapi = SapiTtsEngine();
      }

      // If Supertonic model is already downloaded, pre-load the engine
      final provider = await _settingsRepo.getTtsProvider() ?? 'sapi';
      if (provider == 'supertonic' && await _modelManager.isModelReady()) {
        try {
          await _initSupertonic();
        } catch (_) {}
      }

      // Wire up cloud TTS adapter
      if (provider == 'qwen' || provider == 'openai' || provider == 'doubao') {
        await _initCloudProvider();
      }
      if (_sapi != null) {
        _sapi!.speed = await _settingsRepo.getTtsSpeed();
      }

      _initialized = true;
      _initFuture = null;
    } finally {
      if (!_initialized) {
        _initFuture = null;
      }
    }
  }

  /// Speak [text] using the configured TTS engine.
  ///
  /// Routes to Supertonic, cloud, or SAPI based on the user's setting.
  /// Falls back to SAPI on Windows if the selected engine fails.
  ///
  /// Guards against concurrent calls — taps during playback are ignored.
  Future<TtsSpeakResult> speak(String text, {String lang = 'en'}) async {
    if (!await _ensureInitialized()) {
      return const TtsSpeakResult(
        provider: 'none',
        source: 'not_ready',
        played: false,
      );
    }
    if (_speaking) {
      return const TtsSpeakResult(
        provider: 'none',
        source: 'blocked',
        played: false,
      );
    }
    _speaking = true;

    try {
      final normalizedText = _normalizeCacheText(text);
      final provider = await _settingsRepo.getTtsProvider() ?? 'sapi';

      if (provider != 'sapi') {
        final cached = await _getCachedAudio(normalizedText, lang, provider);
        if (cached != null) {
          if (provider == 'supertonic') {
            await _playWav(cached);
          } else {
            await _playAudio(
              cached,
              mimeType: _audioMimeTypeForProvider(provider),
            );
          }
          return TtsSpeakResult(
            provider: provider,
            source: 'cache',
            played: true,
          );
        }
      }

      if (provider == 'doubao' && !await _isDoubaoLiveApiEnabled()) {
        return const TtsSpeakResult(
          provider: 'doubao',
          source: 'api_disabled_missing_cache',
          played: false,
        );
      }

      switch (provider) {
        case 'supertonic':
          return await _speakViaSupertonic(normalizedText, lang);
        case 'qwen':
        case 'openai':
        case 'doubao':
          return await _speakViaCloud(normalizedText, lang);
        case 'sapi':
        default:
          await _speakViaSapi(normalizedText);
          return TtsSpeakResult(
            provider: provider,
            source: 'sapi',
            played: true,
          );
      }
    } finally {
      _speaking = false;
    }
  }

  /// Speak free-form user text.
  ///
  /// Supertonic is less stable when one long paragraph is synthesized in a
  /// single pass. For that engine, synthesize bounded chunks, stitch the PCM
  /// samples in memory, and play one WAV. Other providers keep their ordinary
  /// whole-text path.
  Future<TtsSpeakResult> speakCustomText(
    String text, {
    String lang = 'en',
  }) async {
    if (!await _ensureInitialized()) {
      return const TtsSpeakResult(
        provider: 'none',
        source: 'not_ready',
        played: false,
      );
    }

    final provider = await _settingsRepo.getTtsProvider() ?? 'sapi';
    if (provider != 'supertonic') {
      return speak(text, lang: lang);
    }

    if (_speaking) {
      return const TtsSpeakResult(
        provider: 'none',
        source: 'blocked',
        played: false,
      );
    }
    _speaking = true;

    try {
      final normalizedText = _normalizeCacheText(text);
      final cached = await _getCachedAudio(normalizedText, lang, provider);
      if (cached != null) {
        await _playWav(cached);
        return const TtsSpeakResult(
          provider: 'supertonic',
          source: 'cache',
          played: true,
        );
      }
      return await _speakViaSupertonicLongForm(normalizedText, lang);
    } finally {
      _speaking = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Supertonic
  // ---------------------------------------------------------------------------

  Future<void> _initSupertonic() async {
    if (_supertonic?.isInitialized == true) return;
    final modelDir = await _modelManager.modelDir;
    _supertonic = SupertonicTtsEngine();
    await _supertonic!.initialize(modelDir);
  }

  Future<TtsSpeakResult> _speakViaSupertonic(String text, String lang) async {
    try {
      if (_supertonic?.isInitialized != true) {
        await _initSupertonic();
      }
      final speed = await _settingsRepo.getTtsSpeed();
      // Bare words need an explicit boundary to avoid Supertonic tail noise.
      final processed = SupertonicTtsEngine.preprocessSingleWord(text);
      final audio = _supertonic!.synthesize(
        processed,
        speed: speed,
        numSteps: 15,
        lang: lang,
      );
      final cleaned = SupertonicTtsEngine.applyTailFadeOut(
        audio.samples,
        audio.sampleRate,
        fadeDurationMs: 80,
      );
      final wavBytes = await _supertonic!.samplesToWav(cleaned);
      // Cache with original text as key (not processed) for correct lookup
      await _cacheAudio(text, lang, 'supertonic', wavBytes);
      await _playWav(wavBytes);
      return const TtsSpeakResult(
        provider: 'supertonic',
        source: 'api',
        played: true,
      );
    } catch (e) {
      if (_sapi?.isAvailable == true) {
        await _speakViaSapi(text);
        return TtsSpeakResult(
          provider: 'sapi',
          source: 'fallback_sapi',
          played: true,
          message: _shortError(e),
        );
      }
      return TtsSpeakResult(
        provider: 'supertonic',
        source: 'failed',
        played: false,
        message: _shortError(e),
      );
    }
  }

  Future<TtsSpeakResult> _speakViaSupertonicLongForm(
    String text,
    String lang,
  ) async {
    try {
      if (_supertonic?.isInitialized != true) {
        await _initSupertonic();
      }
      final chunks = SupertonicTtsEngine.splitLongFormText(text);
      if (chunks.isEmpty) {
        return const TtsSpeakResult(
          provider: 'supertonic',
          source: 'empty',
          played: false,
        );
      }

      final sampleChunks = <Float32List>[];
      for (final chunk in chunks) {
        final audio = _supertonic!.synthesize(
          chunk,
          speed: SupertonicTtsEngine.longFormSpeed,
          numSteps: SupertonicTtsEngine.longFormNumSteps,
          lang: lang,
        );
        // Keep the synthesized tail intact here. The earlier silence trim and
        // fade-out were shaving off the final consonant on sentence playback.
        sampleChunks.add(audio.samples);
      }

      final samples = SupertonicTtsEngine.concatenateWithSilence(
        sampleChunks,
        _supertonic!.sampleRate,
      );
      final wavBytes = await _supertonic!.samplesToWav(samples);
      await _cacheAudio(text, lang, 'supertonic', wavBytes);
      await _playWav(wavBytes);
      return TtsSpeakResult(
        provider: 'supertonic',
        source: chunks.length == 1 ? 'api' : 'api_long_form',
        played: true,
      );
    } catch (e) {
      if (_sapi?.isAvailable == true) {
        await _speakViaSapi(text);
        return TtsSpeakResult(
          provider: 'sapi',
          source: 'fallback_sapi',
          played: true,
          message: _shortError(e),
        );
      }
      return TtsSpeakResult(
        provider: 'supertonic',
        source: 'failed',
        played: false,
        message: _shortError(e),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Cloud TTS (OpenAI, etc.)
  // ---------------------------------------------------------------------------

  Future<TtsSpeakResult> _speakViaCloud(String text, String lang) async {
    final provider = await _settingsRepo.getTtsProvider() ?? 'qwen';
    if (_cloudProvider == null) {
      if (provider == 'doubao') {
        return const TtsSpeakResult(
          provider: 'doubao',
          source: 'not_configured',
          played: false,
        );
      }
      if (_sapi?.isAvailable == true) {
        await _speakViaSapi(text);
        return const TtsSpeakResult(
          provider: 'sapi',
          source: 'fallback_sapi',
          played: true,
        );
      }
      return TtsSpeakResult(
        provider: provider,
        source: 'failed',
        played: false,
      );
    }
    try {
      final result = await _synthesizeCloudWithMetadata(
        _cloudProvider!,
        text,
        lang,
      );
      await _cacheAudio(text, lang, provider, result.audioBytes);
      await _recordUsage(
        provider: provider,
        action: 'speak',
        text: text,
        language: lang,
        result: result,
        status: 'success',
      );
      await _recordCache(
        provider: provider,
        language: lang,
        text: text,
        status: 'cached',
        audioBytes: result.audioBytes.length,
        chargedCharacters: result.chargedCharacters,
      );
      await _playAudio(
        result.audioBytes,
        mimeType: _audioMimeTypeForProvider(provider),
      );
      return TtsSpeakResult(provider: provider, source: 'api', played: true);
    } catch (e) {
      await _recordUsage(
        provider: provider,
        action: 'speak',
        text: text,
        language: lang,
        status: 'failed',
        errorMessage: _shortError(e),
      );
      await _recordCache(
        provider: provider,
        language: lang,
        text: text,
        status: 'failed',
        errorMessage: _shortError(e),
      );
      if (provider == 'doubao') {
        return const TtsSpeakResult(
          provider: 'doubao',
          source: 'api_failed',
          played: false,
        );
      }
      if (_sapi?.isAvailable == true) {
        await _speakViaSapi(text);
        return const TtsSpeakResult(
          provider: 'sapi',
          source: 'fallback_sapi',
          played: true,
        );
      }
      return TtsSpeakResult(
        provider: provider,
        source: 'failed',
        played: false,
      );
    }
  }

  /// Test a cloud TTS provider directly without fallback or cache.
  ///
  /// This is used by the settings UI to verify the exact values currently
  /// entered in the form, not whatever was previously saved.
  Future<void> testCloudConfig({
    required String provider,
    required String apiKey,
    required String baseUrl,
    required String model,
    required String voice,
    required String resourceId,
    String text = 'test',
    String lang = 'en',
  }) async {
    if (_speaking) {
      throw Exception('Another TTS request is already running');
    }
    _speaking = true;
    _player ??= AudioPlayer();

    try {
      if (provider != 'qwen' && provider != 'openai' && provider != 'doubao') {
        throw Exception(
          'Selected TTS provider is not a cloud provider: $provider',
        );
      }

      final cloudProvider = _createCloudProvider(
        provider: provider,
        apiKey: apiKey,
        baseUrl: baseUrl,
        model: model,
        voice: voice,
        resourceId: resourceId,
      );
      if (cloudProvider == null) {
        throw Exception('Cloud TTS is not configured: $provider');
      }

      final result = await _synthesizeCloudWithMetadata(
        cloudProvider,
        text,
        lang,
      );
      await _recordUsage(
        provider: provider,
        action: 'test',
        text: text,
        language: lang,
        result: result,
        status: 'success',
      );
      await _playAudio(
        result.audioBytes,
        mimeType: _audioMimeTypeForProvider(provider),
      );
    } catch (e) {
      await _recordUsage(
        provider: provider,
        action: 'test',
        text: text,
        language: lang,
        status: 'failed',
        errorMessage: _shortError(e),
      );
      rethrow;
    } finally {
      _speaking = false;
    }
  }

  Future<TtsPreCacheResult> preCacheCloudConfig({
    required String provider,
    required String apiKey,
    required String baseUrl,
    required String model,
    required String voice,
    required String resourceId,
    required List<TtsPreCacheItem> items,
    String lang = 'en',
    int maxRetries = 2,
    Duration delay = const Duration(milliseconds: 300),
    bool Function()? shouldCancel,
    void Function(TtsPreCacheProgress progress)? onProgress,
  }) async {
    if (_preCaching) {
      throw Exception('A TTS pre-cache job is already running');
    }
    _preCaching = true;

    var done = 0;
    var success = 0;
    var skipped = 0;
    var failed = 0;
    var apiCalls = 0;
    var chargedCharacters = 0;
    var audioBytes = 0;
    var cancelled = false;
    final failedItems = <String>[];

    try {
      await _ensureCacheDir();
      if (provider != 'qwen' && provider != 'openai' && provider != 'doubao') {
        throw Exception(
          'Selected TTS provider is not a cloud provider: $provider',
        );
      }

      final cloudProvider = _createCloudProvider(
        provider: provider,
        apiKey: apiKey,
        baseUrl: baseUrl,
        model: model,
        voice: voice,
        resourceId: resourceId,
      );
      if (cloudProvider == null) {
        throw Exception('Cloud TTS is not configured: $provider');
      }

      for (final item in items) {
        if (shouldCancel?.call() == true) {
          cancelled = true;
          break;
        }

        final text = _normalizeCacheText(item.text.trim());
        onProgress?.call(
          TtsPreCacheProgress(
            done: done,
            total: items.length,
            success: success,
            skipped: skipped,
            failed: failed,
            apiCalls: apiCalls,
            chargedCharacters: chargedCharacters,
            audioBytes: audioBytes,
            currentText: text,
            currentListName: item.listName,
          ),
        );

        if (text.isEmpty) {
          skipped++;
        } else if (await _getCachedAudio(text, lang, provider) != null) {
          skipped++;
        } else {
          Object? lastError;
          for (var attempt = 0; attempt <= maxRetries; attempt++) {
            try {
              final result = await _synthesizeCloudWithMetadata(
                cloudProvider,
                text,
                lang,
              );
              await _cacheAudio(text, lang, provider, result.audioBytes);
              await _recordUsage(
                provider: provider,
                action: 'precache',
                text: text,
                language: lang,
                result: result,
                status: 'success',
              );
              await _recordCache(
                provider: provider,
                language: lang,
                text: text,
                status: 'cached',
                audioBytes: result.audioBytes.length,
                chargedCharacters: result.chargedCharacters,
              );
              apiCalls++;
              chargedCharacters += result.chargedCharacters ?? 0;
              audioBytes += result.audioBytes.length;
              lastError = null;
              success++;
              break;
            } catch (e) {
              lastError = e;
              if (attempt < maxRetries) {
                await Future.delayed(
                  Duration(milliseconds: 500 * (attempt + 1)),
                );
              }
            }
          }
          if (lastError != null) {
            failed++;
            final errorMessage = _shortError(lastError);
            failedItems.add('$text: $errorMessage');
            await _recordUsage(
              provider: provider,
              action: 'precache',
              text: text,
              language: lang,
              status: 'failed',
              errorMessage: errorMessage,
            );
            await _recordCache(
              provider: provider,
              language: lang,
              text: text,
              status: 'failed',
              errorMessage: errorMessage,
            );
          }
        }

        done++;
        onProgress?.call(
          TtsPreCacheProgress(
            done: done,
            total: items.length,
            success: success,
            skipped: skipped,
            failed: failed,
            apiCalls: apiCalls,
            chargedCharacters: chargedCharacters,
            audioBytes: audioBytes,
            currentText: text,
            currentListName: item.listName,
          ),
        );

        if (done < items.length && shouldCancel?.call() != true) {
          await Future.delayed(delay);
        }
      }

      return TtsPreCacheResult(
        total: items.length,
        success: success,
        skipped: skipped,
        failed: failed,
        apiCalls: apiCalls,
        chargedCharacters: chargedCharacters,
        audioBytes: audioBytes,
        cancelled: cancelled,
        failedItems: failedItems,
      );
    } finally {
      _preCaching = false;
    }
  }

  Future<void> _initCloudProvider() async {
    final provider = await _settingsRepo.getTtsProvider() ?? '';
    final ns = provider;
    final apiKey = await _settingsRepo.getString('tts_${ns}_api_key');
    final baseUrl =
        (await _settingsRepo.getString('tts_${ns}_base_url'))?.trim() ?? '';
    final voice =
        (await _settingsRepo.getString('tts_${ns}_voice'))?.trim() ?? '';
    final model =
        (await _settingsRepo.getString('tts_${ns}_model'))?.trim() ?? '';
    final resourceId =
        (await _settingsRepo.getString('tts_${ns}_app_id'))?.trim() ?? '';

    _cloudProvider = _createCloudProvider(
      provider: provider,
      apiKey: apiKey ?? '',
      baseUrl: baseUrl,
      model: model,
      voice: voice,
      resourceId: resourceId,
    );
  }

  TtsProvider? _createCloudProvider({
    required String provider,
    required String apiKey,
    required String baseUrl,
    required String model,
    required String voice,
    required String resourceId,
  }) {
    if (apiKey.trim().isEmpty) {
      return null;
    }

    switch (provider) {
      case 'qwen':
        return QwenTtsAdapter(
          apiKey: apiKey,
          baseUrl: baseUrl.isNotEmpty
              ? baseUrl
              : 'https://dashscope.aliyuncs.com',
          model: model.isNotEmpty ? model : 'qwen3-tts-flash',
          voice: voice.isNotEmpty ? voice : 'Jennifer',
        );
      case 'openai':
        return OpenAiTtsAdapter(
          apiKey: apiKey,
          model: model.isNotEmpty ? model : 'tts-1',
          voice: voice.isNotEmpty ? voice : 'alloy',
        );
      case 'doubao':
        return DoubaoTtsAdapter(
          apiKey: apiKey,
          baseUrl: baseUrl.isNotEmpty
              ? baseUrl
              : 'https://openspeech.bytedance.com',
          model: model.isNotEmpty ? model : 'seed-tts-2.0-standard',
          voice: voice.isNotEmpty
              ? voice
              : 'zh_female_tiexinnvsheng_mars_bigtts',
          resourceId: resourceId.isNotEmpty ? resourceId : 'seed-tts-2.0',
        );
      default:
        return null;
    }
  }

  Future<TtsSynthesisResult> _synthesizeCloudWithMetadata(
    TtsProvider provider,
    String text,
    String lang,
  ) async {
    if (provider is MeteredTtsProvider) {
      return provider.synthesizeWithMetadata(text, language: lang);
    }
    final stopwatch = Stopwatch()..start();
    final bytes = await provider.synthesize(text, language: lang);
    stopwatch.stop();
    return TtsSynthesisResult(
      audioBytes: bytes,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  }

  Future<void> _recordUsage({
    required String provider,
    required String action,
    required String text,
    required String language,
    required String status,
    TtsSynthesisResult? result,
    String? errorMessage,
  }) async {
    if (provider != 'doubao') return;
    final normalizedText = _normalizeCacheText(text);
    final repo = _ttsRepo;
    if (repo != null) {
      await repo.insertUsageRecord(
        provider: provider,
        action: action,
        text: normalizedText,
        language: language,
        model: await _settingsRepo.getString('tts_${provider}_model'),
        voice: await _settingsRepo.getString('tts_${provider}_voice'),
        resourceId: await _settingsRepo.getString('tts_${provider}_app_id'),
        chargedCharacters: result?.chargedCharacters,
        audioBytes: result?.audioBytes.length,
        durationMs: result?.durationMs,
        requestId: result?.requestId,
        logId: result?.logId,
        status: status,
        errorMessage: errorMessage,
      );
    }
  }

  Future<void> _recordCache({
    required String provider,
    required String language,
    required String text,
    required String status,
    String? errorMessage,
    int? audioBytes,
    int? chargedCharacters,
  }) async {
    if (provider != 'doubao') return;
    await _ensureCacheDir();
    final normalizedText = _normalizeCacheText(text);
    final repo = _ttsRepo;
    if (repo != null) {
      await repo.upsertCacheRecord(
        provider: provider,
        language: language,
        text: normalizedText,
        cacheKey: _stableCacheKey(normalizedText, language, provider),
        status: status,
        cachePath: status == 'cached'
            ? _cacheFilePath(normalizedText, language, provider)
            : null,
        errorMessage: errorMessage,
        audioBytes: audioBytes,
        chargedCharacters: chargedCharacters,
      );
    }
  }

  Future<TtsCacheHealthReport> inspectCacheHealth({
    String provider = 'doubao',
    String language = 'en',
    Duration maxAge = const Duration(days: 30),
  }) async {
    await _ensureCacheDir();
    final records = await _loadCacheRecords(provider, language);
    final fileNames = await _cacheFileNames(
      provider: provider,
      language: language,
    );
    final now = DateTime.now();

    var healthyRecords = 0;
    var missingFiles = 0;
    var emptyFiles = 0;
    var orphanFiles = 0;
    var expiredRecords = 0;
    var totalBytes = 0;

    final expectedFileNames = <String>{};
    final fileAgeByName = <String, DateTime>{};
    final expiredFileNames = <String>{};
    for (final file in await _cacheFiles(
      provider: provider,
      language: language,
    )) {
      final length = await file.length();
      totalBytes += length;
      final fileName = p.basename(file.path);
      if (length == 0) {
        emptyFiles++;
        expiredFileNames.add(fileName);
      }
      fileAgeByName[fileName] = await file.lastModified();
    }

    for (final record in records) {
      final recordAge = now.difference(
        DateTime.fromMillisecondsSinceEpoch(record.updatedAt),
      );
      final normalizedText = _normalizeCacheText(record.textValue);
      final currentFileName = _cacheFileName(
        normalizedText,
        language,
        provider,
      );
      final legacyFileName = _legacyCacheFileName(
        record.textValue,
        language,
        provider,
      );
      expectedFileNames.add(currentFileName);
      if (provider != 'supertonic') {
        expectedFileNames.add(legacyFileName);
      }

      if (record.status == 'cached') {
        if (_hasCachedFile(
          fileNames,
          normalizedText,
          record.textValue,
          language,
          provider,
        )) {
          healthyRecords++;
        } else {
          missingFiles++;
          if (recordAge >= maxAge) {
            expiredRecords++;
          }
        }
      } else if (recordAge >= maxAge) {
        expiredRecords++;
      }
    }

    for (final entry in fileAgeByName.entries) {
      if (!expectedFileNames.contains(entry.key)) {
        orphanFiles++;
        expiredFileNames.add(entry.key);
      }
    }

    return TtsCacheHealthReport(
      provider: provider,
      language: language,
      recordCount: records.length,
      fileCount: fileAgeByName.length,
      healthyRecords: healthyRecords,
      missingFiles: missingFiles,
      emptyFiles: emptyFiles,
      orphanFiles: orphanFiles,
      expiredRecords: expiredRecords,
      expiredFiles: expiredFileNames.length,
      totalBytes: totalBytes,
      maxAge: maxAge,
    );
  }

  Future<TtsCacheCleanupResult> cleanExpiredCache({
    String provider = 'doubao',
    String language = 'en',
    Duration maxAge = const Duration(days: 30),
  }) async {
    await _ensureCacheDir();
    final records = await _loadCacheRecords(provider, language);
    final fileNames = await _cacheFileNames(
      provider: provider,
      language: language,
    );
    final now = DateTime.now();

    var removedFiles = 0;
    var removedRecords = 0;
    var expiredRecords = 0;
    var orphanFiles = 0;
    var emptyFiles = 0;

    final expectedFileNames = <String>{};
    for (final record in records) {
      final recordAge = now.difference(
        DateTime.fromMillisecondsSinceEpoch(record.updatedAt),
      );
      final normalizedText = _normalizeCacheText(record.textValue);
      expectedFileNames.add(_cacheFileName(normalizedText, language, provider));
      if (provider != 'supertonic') {
        expectedFileNames.add(
          _legacyCacheFileName(record.textValue, language, provider),
        );
      }

      final hasFile = _hasCachedFile(
        fileNames,
        normalizedText,
        record.textValue,
        language,
        provider,
      );
      if (record.status != 'cached' && recordAge >= maxAge) {
        final repo = _ttsRepo;
        if (repo != null) {
          await repo.deleteCacheRecord(record.id);
        }
        removedRecords++;
        expiredRecords++;
      } else if (record.status == 'cached' && !hasFile && recordAge >= maxAge) {
        final repo = _ttsRepo;
        if (repo != null) {
          await repo.deleteCacheRecord(record.id);
        }
        removedRecords++;
        expiredRecords++;
      }
    }

    for (final file in await _cacheFiles(
      provider: provider,
      language: language,
    )) {
      final fileName = p.basename(file.path);
      final length = await file.length();
      final isOrphan = !expectedFileNames.contains(fileName);
      final isEmpty = length == 0;
      if (isEmpty) {
        emptyFiles++;
      }
      if (isOrphan) {
        orphanFiles++;
      }
      if (isEmpty || isOrphan) {
        try {
          await file.delete();
          removedFiles++;
        } catch (_) {}
      }
    }

    return TtsCacheCleanupResult(
      removedFiles: removedFiles,
      removedRecords: removedRecords,
      expiredRecords: expiredRecords,
      orphanFiles: orphanFiles,
      emptyFiles: emptyFiles,
    );
  }

  Future<bool> _isDoubaoLiveApiEnabled() async {
    final saved = await _settingsRepo.getString('tts_doubao_live_api_enabled');
    return saved != 'false';
  }

  /// Set a cloud TTS provider for premium-quality speech.
  void setCloudProvider(TtsProvider provider) {
    _cloudProvider = provider;
  }

  // ---------------------------------------------------------------------------
  // SAPI (Windows system speech)
  // ---------------------------------------------------------------------------

  Future<void> _speakViaSapi(String text) async {
    if (_sapi == null) return;
    final speed = await _settingsRepo.getTtsSpeed();
    _sapi!.speed = speed;
    await _sapi!.speak(text);
  }

  // ---------------------------------------------------------------------------
  // Audio cache
  // ---------------------------------------------------------------------------

  Future<void> _ensureCacheDir() async {
    if (_cacheDir != null) return;
    final appDir = await getLingoDataDir();
    _cacheDir = Directory('${appDir.path}/lingo_tts_cache');
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }
  }

  String _cacheFilePath(String text, String lang, String provider) {
    return '${_cacheDir!.path}/${_cacheFileName(text, lang, provider)}';
  }

  String _legacyCacheFilePath(String text, String lang, String provider) {
    return '${_cacheDir!.path}/${_legacyCacheFileName(text, lang, provider)}';
  }

  String _cacheFileName(String text, String lang, String provider) {
    final hash = _stableCacheKey(text, lang, provider);
    final ext = _cacheExtensionForProvider(provider);
    return '$hash-$provider-$lang.$ext';
  }

  String _legacyCacheFileName(String text, String lang, String provider) {
    final hash = text.hashCode.toRadixString(36);
    final ext = _cacheExtensionForProvider(provider);
    return '$hash-$provider-$lang.$ext';
  }

  Future<Uint8List?> _getCachedAudio(
    String text,
    String lang,
    String provider,
  ) async {
    if (_cacheDir == null) return null;
    final paths = _cachePathsForText(text, lang, provider);
    for (final path in paths) {
      final file = File(path);
      if (await file.exists() && await file.length() > 0) {
        return await file.readAsBytes();
      }
    }
    return null;
  }

  Future<Map<String, bool>> getCachedAudioPresence(
    List<String> texts, {
    String provider = 'doubao',
    String lang = 'en',
  }) async {
    await _ensureCacheDir();
    final fileNames = await _cacheFileNames(provider: provider, language: lang);
    final records = await _loadCacheRecords(provider, lang);
    final cachedTexts = <String>{};
    for (final record in records) {
      if (record.status != 'cached') continue;
      if (_hasCachedFile(
        fileNames,
        _normalizeCacheText(record.textValue),
        record.textValue,
        lang,
        provider,
      )) {
        cachedTexts.add(_normalizeCacheText(record.textValue));
      }
    }

    final result = <String, bool>{};
    for (final text in texts) {
      final normalizedText = _normalizeCacheText(text);
      result[text] =
          cachedTexts.contains(normalizedText) ||
          _hasCachedFile(fileNames, normalizedText, text, lang, provider);
    }
    return result;
  }

  String cacheKeyFor(
    String text, {
    String provider = 'doubao',
    String lang = 'en',
  }) {
    return _stableCacheKey(_normalizeCacheText(text), lang, provider);
  }

  Future<void> _cacheAudio(
    String text,
    String lang,
    String provider,
    Uint8List bytes,
  ) async {
    if (_cacheDir == null) return;
    try {
      final file = File(
        _cacheFilePath(_normalizeCacheText(text), lang, provider),
      );
      await file.writeAsBytes(bytes);
    } catch (_) {}
  }

  String _cacheExtensionForProvider(String provider) {
    return provider == 'supertonic' ? 'wav' : 'mp3';
  }

  String _stableCacheKey(String text, String lang, String provider) {
    final normalizedText = _normalizeCacheText(text);
    final cacheText = provider == 'supertonic'
        ? 'v9\n$normalizedText'
        : normalizedText;
    var hash = 0xcbf29ce484222325;
    for (final byte in utf8.encode('$provider\n$lang\n$cacheText')) {
      hash ^= byte;
      hash = (hash * 0x100000001b3) & 0xffffffffffffffff;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }

  String _normalizeCacheText(String text) {
    return TextNormalizer.normalizeQuotes(text);
  }

  List<String> _cachePathsForText(String text, String lang, String provider) {
    final normalizedText = _normalizeCacheText(text);
    final paths = <String>[_cacheFilePath(normalizedText, lang, provider)];
    if (provider != 'supertonic') {
      paths.add(_legacyCacheFilePath(text, lang, provider));
      if (normalizedText != text) {
        paths.add(_legacyCacheFilePath(normalizedText, lang, provider));
      }
    }
    return paths;
  }

  Future<List<String>> _cacheFileNames({
    String? provider,
    String? language,
  }) async {
    final fileNames = <String>{};
    await for (final entity in _cacheDir!.list()) {
      if (entity is File && await entity.length() > 0) {
        final fileName = p.basename(entity.path);
        if (_isCacheFileFor(fileName, provider: provider, language: language)) {
          fileNames.add(fileName);
        }
      }
    }
    return fileNames.toList();
  }

  Future<List<File>> _cacheFiles({String? provider, String? language}) async {
    final files = <File>[];
    await for (final entity in _cacheDir!.list()) {
      if (entity is File &&
          _isCacheFileFor(
            p.basename(entity.path),
            provider: provider,
            language: language,
          )) {
        files.add(entity);
      }
    }
    return files;
  }

  Future<List<TtsCacheRecord>> _loadCacheRecords(
    String provider,
    String language,
  ) async {
    final repo = _ttsRepo;
    if (repo == null) return const [];
    return repo.getCacheRecords(provider: provider, language: language);
  }

  bool _hasCachedFile(
    List<String> fileNames,
    String normalizedText,
    String rawText,
    String lang,
    String provider,
  ) {
    if (fileNames.contains(_cacheFileName(normalizedText, lang, provider))) {
      return true;
    }
    if (provider == 'supertonic') return false;
    return fileNames.contains(_legacyCacheFileName(rawText, lang, provider)) ||
        fileNames.contains(
          _legacyCacheFileName(normalizedText, lang, provider),
        );
  }

  bool _isCacheFileFor(String fileName, {String? provider, String? language}) {
    if (provider == null && language == null) return true;
    if (provider == null || language == null) return true;
    return fileName.contains('-$provider-$language.');
  }

  String _shortError(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }

  // ---------------------------------------------------------------------------
  // Audio playback
  // ---------------------------------------------------------------------------

  Future<void> _playWav(Uint8List wavBytes) async {
    if (_player == null) return;
    await _player!.stop();
    final completed = _waitForPlaybackComplete();
    await _player!.play(BytesSource(wavBytes, mimeType: 'audio/wav'));
    await completed;
  }

  Future<void> _playAudio(Uint8List bytes, {String? mimeType}) async {
    if (_player == null) {
      throw Exception('Audio player is not initialized');
    }
    await _player!.stop();
    final completed = _waitForPlaybackComplete();
    await _player!.play(BytesSource(bytes, mimeType: mimeType));
    await completed;
  }

  Future<void> _waitForPlaybackComplete() async {
    if (_player == null) return;
    final completer = Completer<void>();
    _playbackCompleter = completer;
    late final StreamSubscription<dynamic> sub;
    Timer? timer;

    void complete() {
      if (completer.isCompleted) return;
      timer?.cancel();
      sub.cancel();
      if (identical(_playbackCompleter, completer)) {
        _playbackCompleter = null;
        _completePlayback = null;
      }
      completer.complete();
    }

    _completePlayback = complete;

    sub = _player!.onPlayerComplete.listen((_) => complete());
    timer = Timer(const Duration(minutes: 5), complete);
    await completer.future;
  }

  String? _audioMimeTypeForProvider(String provider) {
    switch (provider) {
      case 'qwen':
      case 'openai':
      case 'doubao':
        return 'audio/mpeg';
      default:
        return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Batch pre-generation (for use after word import)
  // ---------------------------------------------------------------------------

  /// Pre-generate and cache audio for a list of words.
  ///
  /// Returns the number of successfully cached items.
  Future<int> preGenerate(
    List<String> texts, {
    String lang = 'en',
    void Function(int done, int total)? onProgress,
  }) async {
    int success = 0;
    final provider = await _settingsRepo.getTtsProvider() ?? 'sapi';

    for (int i = 0; i < texts.length; i++) {
      final text = texts[i];

      // Skip if already cached
      final normalizedText = _normalizeCacheText(text);
      final existing = await _getCachedAudio(normalizedText, lang, provider);
      if (existing != null) {
        success++;
        onProgress?.call(i + 1, texts.length);
        continue;
      }

      try {
        switch (provider) {
          case 'supertonic':
            if (_supertonic?.isInitialized != true) await _initSupertonic();
            final speed = await _settingsRepo.getTtsSpeed();
            final processed = SupertonicTtsEngine.preprocessSingleWord(
              normalizedText,
            );
            final audio = _supertonic!.synthesize(
              processed,
              speed: speed,
              numSteps: 15,
              lang: lang,
            );
            final cleaned = SupertonicTtsEngine.applyTailFadeOut(
              audio.samples,
              audio.sampleRate,
              fadeDurationMs: 80,
            );
            final wavBytes = await _supertonic!.samplesToWav(cleaned);
            await _cacheAudio(normalizedText, lang, 'supertonic', wavBytes);
            success++;
            break;
          case 'qwen':
          case 'openai':
          case 'doubao':
            if (_cloudProvider != null) {
              final bytes = await _cloudProvider!.synthesize(
                normalizedText,
                language: lang,
              );
              await _cacheAudio(normalizedText, lang, provider, bytes);
              success++;
            }
            break;
          default:
            break; // SAPI doesn't support pre-generation
        }
      } catch (_) {}

      onProgress?.call(i + 1, texts.length);
    }

    return success;
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  Future<void> stop() async {
    await _player?.stop();
    _completePlayback?.call();
    _playbackCompleter = null;
    _completePlayback = null;
    await _sapi?.stop();
    _speaking = false;
  }

  Future<void> reloadSettings() async {
    final speed = await _settingsRepo.getTtsSpeed();
    if (_sapi != null) _sapi!.speed = speed;

    final provider = await _settingsRepo.getTtsProvider() ?? 'sapi';

    // Re-initialise Supertonic if provider changed to it
    if (provider == 'supertonic' && _supertonic?.isInitialized != true) {
      if (await _modelManager.isModelReady()) {
        try {
          await _initSupertonic();
        } catch (_) {}
      }
    }

    // Wire up cloud TTS adapter
    if (provider == 'qwen' || provider == 'openai' || provider == 'doubao') {
      await _initCloudProvider();
    } else {
      _cloudProvider = null;
    }
  }

  void dispose() {
    _player?.dispose();
    _player = null;
    _supertonic?.dispose();
    _supertonic = null;
    _sapi = null;
    _cloudProvider = null;
    _initialized = false;
    _initFuture = null;
  }
}
