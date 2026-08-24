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
import '../utils/wav_playback_preroll.dart';
import 'remote_example_audio_client.dart';
import 'remote_word_audio_client.dart';
import 'tts_adapters/doubao_tts_adapter.dart';
import 'tts_adapters/openai_tts_adapter.dart';
import 'tts_adapters/qwen3_tts_adapter.dart';
import 'tts_adapters/qwen_tts_adapter.dart';
import 'tts_adapters/tencent_tts_adapter.dart';
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

class TtsPreCacheFailure {
  final String text;
  final String message;
  final QwenWordAudioValidationFailure? audioValidationFailure;

  const TtsPreCacheFailure({
    required this.text,
    required this.message,
    this.audioValidationFailure,
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
  final List<TtsPreCacheFailure> failedItems;

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

class TtsCacheLimitResult {
  final int limitBytes;
  final int beforeBytes;
  final int afterBytes;
  final int removedFiles;
  final int removedRecords;

  const TtsCacheLimitResult({
    required this.limitBytes,
    required this.beforeBytes,
    required this.afterBytes,
    required this.removedFiles,
    required this.removedRecords,
  });

  int get removedBytes => beforeBytes - afterBytes;
  bool get isUnlimited => limitBytes <= 0;
}

class _TtsCacheFileCandidate {
  final File file;
  final int length;
  final DateTime lastModified;

  const _TtsCacheFileCandidate({
    required this.file,
    required this.length,
    required this.lastModified,
  });
}

/// Orchestrates cloud TTS generation, persistent audio caching, and playback.
/// Dictionary words default to pre-generated static WAV playback; direct cloud
/// playback is an explicit development-only choice.
///
/// Usage:
/// ```dart
/// final tts = TtsService(settingsRepo: repo);
/// await tts.init();
/// await tts.speak('Hello');
/// ```
class TtsService {
  static const Duration _windowsWavPlaybackPreRoll = Duration(
    milliseconds: 210,
  );
  static const String qwenCacheLimitSettingKey = 'tts_qwen_cache_limit_mb';
  static const int defaultQwenCacheLimitMb = 0;
  static const String remoteWordPlaybackSource = 'remote';
  static const String configuredTtsWordPlaybackSource = 'configured_tts';
  static const String remoteExamplePlaybackSource = 'remote';
  static const String configuredTtsExamplePlaybackSource = 'configured_tts';
  static const String qwen3FlashKaterinaProvider =
      Qwen3TtsAdapter.flashKaterinaProviderId;
  static const String tencentWeWinnyProvider =
      TencentTtsAdapter.weWinnyProviderId;
  static const String tencentWeJackProvider =
      TencentTtsAdapter.weJackProviderId;
  static const String remoteTencentWeWinnyExamplePlaybackSource =
      'remote_tencent_wewinny';

  final SettingsRepository _settingsRepo;
  final TtsRepository? _ttsRepo;
  final Future<Directory> Function() _dataDirProvider;

  TtsProvider? _cloudProvider;
  TtsProvider? _wordProvider;
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
    TtsRepository? ttsRepo,
    Future<Directory> Function()? dataDirProvider,
  }) : _settingsRepo = settingsRepo,
       _ttsRepo = ttsRepo,
       _dataDirProvider = dataDirProvider ?? getLingoDataDir;

  bool get isReady => _initialized;

  /// Initialise cloud adapters and the persistent audio cache.
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
      await _ensurePlaybackPlayer();

      try {
        await _ensureCacheDir();
      } catch (_) {}

      await _initCloudProvider();

      _initialized = true;
      _initFuture = null;
    } finally {
      if (!_initialized) {
        _initFuture = null;
      }
    }
  }

  /// Speak [text] using the configured cloud provider.
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
      final provider = await _configuredCloudProvider();

      final cached = await _getCachedAudio(normalizedText, lang, provider);
      if (cached != null) {
        await _playAudio(cached, mimeType: _audioMimeTypeForProvider(provider));
        return TtsSpeakResult(
          provider: provider,
          source: 'cache',
          played: true,
        );
      }

      if (provider == 'doubao' && !await _isDoubaoLiveApiEnabled()) {
        return const TtsSpeakResult(
          provider: 'doubao',
          source: 'api_disabled_missing_cache',
          played: false,
        );
      }

      switch (provider) {
        case 'qwen':
        case qwen3FlashKaterinaProvider:
        case 'openai':
        case 'doubao':
          return await _speakViaCloud(normalizedText, lang);
        default:
          return TtsSpeakResult(
            provider: provider,
            source: 'unsupported_provider',
            played: false,
          );
      }
    } finally {
      _speaking = false;
    }
  }

  /// Uses the configured word playback source.
  ///
  /// The default is the pre-generated static WAV server. The user can
  /// explicitly switch to the currently selected cloud TTS engine for
  /// development testing; this is never an automatic fallback.
  Future<TtsSpeakResult> speakWord(String text, {String lang = 'en'}) async {
    final playbackSource = normalizeWordPlaybackSource(
      await _settingsRepo.getString(
        SettingsRepository.keyWordAudioPlaybackSource,
      ),
    );
    if (playbackSource == configuredTtsWordPlaybackSource) {
      return speak(text, lang: lang);
    }

    return _speakWordFromRemoteServer(text, lang: lang);
  }

  /// Plays a word's stored example sentence from its selected static release
  /// profile. The fallback to the active TTS engine is a user choice, never
  /// an automatic API call after a server miss.
  Future<TtsSpeakResult> speakExampleSentence(
    String text, {
    String lang = 'en',
  }) async {
    final playbackSource = normalizeExamplePlaybackSource(
      await _settingsRepo.getString(
        SettingsRepository.keyExampleAudioPlaybackSource,
      ),
    );
    if (playbackSource == configuredTtsExamplePlaybackSource) {
      return speak(text, lang: lang);
    }
    return _speakExampleFromRemoteServer(text, lang: lang);
  }

  static String normalizeWordPlaybackSource(String? value) {
    return value == configuredTtsWordPlaybackSource
        ? configuredTtsWordPlaybackSource
        : remoteWordPlaybackSource;
  }

  static String normalizeExamplePlaybackSource(String? value) {
    // Existing installations used the active cloud engine for examples before
    // a static example-audio server existed. Preserve that behaviour until a
    // user explicitly switches this new setting to the server.
    return switch (value) {
      remoteExamplePlaybackSource => remoteExamplePlaybackSource,
      remoteTencentWeWinnyExamplePlaybackSource =>
        remoteTencentWeWinnyExamplePlaybackSource,
      _ => configuredTtsExamplePlaybackSource,
    };
  }

  /// Plays a locally validated Qwen word WAV without reading or changing the
  /// persistent cache. This is used by the repair UI to audition a staged
  /// candidate before the user accepts it.
  Future<bool> previewWordAudioBytes(Uint8List bytes) async {
    if (QwenTtsAdapter.wordAudioValidationFailure(bytes) != null) {
      return false;
    }
    if (!await _ensureInitialized()) return false;
    if (_speaking) await stop();
    _speaking = true;
    try {
      await _playAudio(bytes, mimeType: QwenTtsAdapter.wordAudioMimeType);
      return true;
    } catch (_) {
      return false;
    } finally {
      _speaking = false;
    }
  }

  /// Fetches and memory-plays a dictionary word from the static WAV server.
  /// This path intentionally never invokes Qwen and never reads or writes a
  /// persistent audio file on the device.
  Future<TtsSpeakResult> _speakWordFromRemoteServer(
    String text, {
    required String lang,
  }) async {
    if (!await _ensureInitialized()) {
      return const TtsSpeakResult(
        provider: 'remote_word_audio',
        source: 'not_ready',
        played: false,
      );
    }
    if (_speaking) await stop();
    _speaking = true;

    try {
      final normalizedText = _normalizeCacheText(text).trim();
      if (normalizedText.isEmpty) {
        return const TtsSpeakResult(
          provider: 'remote_word_audio',
          source: 'empty',
          played: false,
        );
      }

      final baseUrl =
          await _settingsRepo.getString(
            SettingsRepository.keyRemoteWordAudioBaseUrl,
          ) ??
          '';
      try {
        final audioBytes = await RemoteWordAudioClient(
          baseUrl: baseUrl,
        ).fetch(normalizedText, language: lang);
        await _playAudio(
          audioBytes,
          mimeType: RemoteWordAudioClient.wavMimeType,
        );
        return const TtsSpeakResult(
          provider: 'remote_word_audio',
          source: 'remote',
          played: true,
        );
      } on RemoteWordAudioException catch (error) {
        return TtsSpeakResult(
          provider: 'remote_word_audio',
          source: error.source,
          played: false,
        );
      } catch (_) {
        return const TtsSpeakResult(
          provider: 'remote_word_audio',
          source: 'remote_unavailable',
          played: false,
        );
      }
    } finally {
      _speaking = false;
    }
  }

  /// Fetches and memory-plays an immutable example sentence from the selected
  /// static server profile. It intentionally never reads/writes the local
  /// cache and does not fall back to a cloud API if a release is incomplete.
  Future<TtsSpeakResult> _speakExampleFromRemoteServer(
    String text, {
    required String lang,
  }) async {
    if (!await _ensureInitialized()) {
      return const TtsSpeakResult(
        provider: 'remote_example_audio',
        source: 'not_ready',
        played: false,
      );
    }
    if (_speaking) await stop();
    _speaking = true;

    try {
      final playbackSource = normalizeExamplePlaybackSource(
        await _settingsRepo.getString(
          SettingsRepository.keyExampleAudioPlaybackSource,
        ),
      );
      final isTencentExample =
          playbackSource == remoteTencentWeWinnyExamplePlaybackSource;
      final profile = isTencentExample
          ? RemoteExampleAudioProfile.tencentWeJack
          : RemoteExampleAudioProfile.qwen3;
      final remoteProvider = isTencentExample
          ? 'remote_tencent_wewinny_example_audio'
          : 'remote_example_audio';
      final normalizedText = RemoteExampleAudioClient.normalizeText(text);
      if (normalizedText.isEmpty) {
        return TtsSpeakResult(
          provider: remoteProvider,
          source: 'empty',
          played: false,
        );
      }
      final baseUrl =
          await _settingsRepo.getString(
            SettingsRepository.keyRemoteWordAudioBaseUrl,
          ) ??
          '';
      try {
        final audioBytes = await RemoteExampleAudioClient(
          baseUrl: baseUrl,
          profile: profile,
        ).fetch(normalizedText, language: lang);
        await _playAudio(
          audioBytes,
          mimeType: RemoteExampleAudioClient.wavMimeType,
        );
        return TtsSpeakResult(
          provider: remoteProvider,
          source: 'remote',
          played: true,
        );
      } on RemoteExampleAudioException catch (error) {
        return TtsSpeakResult(
          provider: remoteProvider,
          source: error.source,
          played: false,
        );
      } catch (_) {
        return TtsSpeakResult(
          provider: remoteProvider,
          source: 'remote_example_unavailable',
          played: false,
        );
      }
    } finally {
      _speaking = false;
    }
  }

  /// Free-form text remains cloud-only. Long-form streaming is a later phase.
  Future<TtsSpeakResult> speakCustomText(String text, {String lang = 'en'}) =>
      speak(text, lang: lang);

  // ---------------------------------------------------------------------------
  // Cloud TTS (OpenAI, etc.)
  // ---------------------------------------------------------------------------

  Future<TtsSpeakResult> _speakViaCloud(
    String text,
    String lang, {
    String? providerOverride,
    TtsProvider? cloudProviderOverride,
  }) async {
    final provider = providerOverride ?? await _configuredCloudProvider();
    final cloudProvider = cloudProviderOverride ?? _cloudProvider;
    if (cloudProvider == null) {
      return TtsSpeakResult(
        provider: provider,
        source: 'not_configured',
        played: false,
      );
    }
    try {
      final result = await _synthesizeWithQwenWordFallback(
        cloudProvider,
        text,
        lang,
        providerType: provider,
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
      return TtsSpeakResult(
        provider: provider,
        source: 'api_failed',
        played: false,
        message: _shortError(e),
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
    await _ensurePlaybackPlayer();

    try {
      if (provider != 'qwen' &&
          provider != qwen3FlashKaterinaProvider &&
          provider != tencentWeWinnyProvider &&
          provider != tencentWeJackProvider &&
          provider != 'openai' &&
          provider != 'doubao') {
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
    final failedItems = <TtsPreCacheFailure>[];

    try {
      await _ensureCacheDir();
      if (provider != 'qwen' &&
          provider != qwen3FlashKaterinaProvider &&
          provider != tencentWeWinnyProvider &&
          provider != tencentWeJackProvider &&
          provider != 'openai' &&
          provider != 'doubao') {
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
        instruction: provider == 'qwen' && lang.trim().toLowerCase() == 'en'
            ? QwenTtsAdapter.wordInstruction
            : null,
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
              final synthesisText = _preCacheSynthesisText(
                provider,
                text,
                lang,
                attempt,
              );
              apiCalls++;
              final result = await _synthesizeCloudWithMetadata(
                cloudProvider,
                synthesisText,
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
              chargedCharacters += result.chargedCharacters ?? 0;
              audioBytes += result.audioBytes.length;
              lastError = null;
              success++;
              break;
            } catch (e) {
              lastError = e;
              if (attempt < maxRetries && _isPreCacheRetryable(provider, e)) {
                await Future.delayed(_preCacheRetryDelay(provider, attempt));
              } else {
                break;
              }
            }
          }
          if (lastError != null) {
            failed++;
            final errorMessage = _shortError(lastError);
            failedItems.add(
              TtsPreCacheFailure(
                text: text,
                message: errorMessage,
                audioValidationFailure:
                    lastError is QwenWordAudioValidationException
                    ? lastError.failure
                    : null,
              ),
            );
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
    final provider = await _configuredCloudProvider();
    final ns = _settingsNamespaceForProvider(provider);
    final apiKey = await _settingsRepo.getString('tts_${ns}_api_key');
    final baseUrl =
        (await _settingsRepo.getString('tts_${ns}_base_url'))?.trim() ?? '';
    final voice = provider == qwen3FlashKaterinaProvider
        ? Qwen3TtsAdapter.flashVoice
        : (await _settingsRepo.getString('tts_${ns}_voice'))?.trim() ?? '';
    final model = provider == qwen3FlashKaterinaProvider
        ? Qwen3TtsAdapter.flashModel
        : (await _settingsRepo.getString('tts_${ns}_model'))?.trim() ?? '';
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

  Future<String> _configuredCloudProvider() async {
    final provider = await _settingsRepo.getTtsProvider();
    return provider == 'qwen' ||
            provider == qwen3FlashKaterinaProvider ||
            provider == 'openai' ||
            provider == 'doubao'
        ? provider!
        : 'qwen';
  }

  static String _settingsNamespaceForProvider(String provider) {
    // The legacy word profile and the new Qwen3 Flash profile use the same
    // DashScope API credentials, while model/voice/cache identities stay
    // separate. This avoids copying or overwriting the approved word preset.
    return provider == qwen3FlashKaterinaProvider ? 'qwen' : provider;
  }

  Future<void> _initWordProvider({required String language}) async {
    final apiKey =
        (await _settingsRepo.getString('tts_qwen_api_key'))?.trim() ?? '';
    final baseUrl =
        (await _settingsRepo.getString('tts_qwen_base_url'))?.trim() ?? '';
    final workspaceId =
        (await _settingsRepo.getString('tts_qwen_app_id'))?.trim() ?? '';
    _wordProvider = _createCloudProvider(
      provider: 'qwen',
      apiKey: apiKey,
      baseUrl: baseUrl,
      model: QwenTtsAdapter.wordModel,
      voice: QwenTtsAdapter.wordVoice,
      resourceId: workspaceId,
      instruction: language.trim().toLowerCase() == 'en'
          ? QwenTtsAdapter.wordInstruction
          : null,
    );
  }

  TtsProvider? _createCloudProvider({
    required String provider,
    required String apiKey,
    required String baseUrl,
    required String model,
    required String voice,
    required String resourceId,
    String? instruction,
  }) {
    if (provider == tencentWeWinnyProvider ||
        provider == tencentWeJackProvider) {
      final useWeJack = provider == tencentWeJackProvider;
      return TencentTtsAdapter.fromEnvironment(
        endpoint: baseUrl.trim().isEmpty
            ? TencentTtsAdapter.defaultEndpoint
            : baseUrl.trim(),
        region: resourceId.trim().isEmpty
            ? TencentTtsAdapter.defaultRegion
            : resourceId.trim(),
        voiceType: useWeJack
            ? TencentTtsAdapter.weJackVoiceType
            : TencentTtsAdapter.weWinnyVoiceType,
        sampleRate: useWeJack
            ? TencentTtsAdapter.weJackSampleRate
            : TencentTtsAdapter.weWinnySampleRate,
      );
    }
    if (apiKey.trim().isEmpty) {
      return null;
    }

    switch (provider) {
      case 'qwen':
        if (resourceId.trim().isEmpty) return null;
        return QwenTtsAdapter(
          apiKey: apiKey,
          workspaceId: resourceId,
          baseUrl: baseUrl,
          model: QwenTtsAdapter.wordModel,
          voice: QwenTtsAdapter.wordVoice,
          audioFormat: QwenTtsAdapter.wordAudioFormat,
          sampleRate: QwenTtsAdapter.wordSampleRate,
          volume: QwenTtsAdapter.wordVolume,
          rate: QwenTtsAdapter.wordRate,
          pitch: QwenTtsAdapter.wordPitch,
          seed: QwenTtsAdapter.wordSeed,
          instruction: instruction,
        );
      case qwen3FlashKaterinaProvider:
        return Qwen3TtsAdapter(
          apiKey: apiKey,
          workspaceId: resourceId,
          baseUrl: baseUrl,
          model: Qwen3TtsAdapter.flashModel,
          voice: Qwen3TtsAdapter.flashVoice,
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

  /// Retries a Qwen bare word once with a terminal boundary when Qwen returns
  /// either a retryable server error or an unusable WAV. Cached audio still
  /// uses the original dictionary word as its key and metadata text.
  Future<TtsSynthesisResult> _synthesizeWithQwenWordFallback(
    TtsProvider provider,
    String text,
    String lang, {
    required String providerType,
  }) async {
    try {
      return await _synthesizeCloudWithMetadata(provider, text, lang);
    } catch (error) {
      final shouldRetryWithBoundary =
          providerType == 'qwen' &&
          (_isQwenRetryableServerError(error) ||
              error is QwenWordAudioValidationException);
      final fallbackText = shouldRetryWithBoundary
          ? QwenTtsAdapter.bareEnglishWordFallbackText(text, language: lang)
          : null;
      if (fallbackText == null) rethrow;
      return _synthesizeCloudWithMetadata(provider, fallbackText, lang);
    }
  }

  String _preCacheSynthesisText(
    String provider,
    String text,
    String lang,
    int attempt,
  ) {
    if (provider != 'qwen' || attempt == 0) return text;
    return QwenTtsAdapter.bareEnglishWordFallbackText(text, language: lang) ??
        text;
  }

  Duration _preCacheRetryDelay(String provider, int attempt) {
    if (provider != 'qwen') {
      return Duration(milliseconds: 500 * (attempt + 1));
    }
    const delaysInSeconds = [1, 3, 6, 12];
    final index = attempt.clamp(0, delaysInSeconds.length - 1);
    return Duration(seconds: delaysInSeconds[index]);
  }

  bool _isQwenRetryableServerError(Object error) {
    return RegExp(r'Qwen TTS HTTP (?:429|5\d\d):').hasMatch(error.toString());
  }

  bool _isPreCacheRetryable(String provider, Object error) {
    if (provider != tencentWeWinnyProvider &&
        provider != tencentWeJackProvider) {
      return true;
    }
    return error is TencentTtsException && error.isRetryable;
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
    if (provider != 'doubao' &&
        provider != 'qwen' &&
        provider != qwen3FlashKaterinaProvider &&
        provider != tencentWeWinnyProvider &&
        provider != tencentWeJackProvider) {
      return;
    }
    final normalizedText = _normalizeCacheText(text);
    final repo = _ttsRepo;
    if (repo != null) {
      final settingsNamespace = _settingsNamespaceForProvider(provider);
      await repo.insertUsageRecord(
        provider: provider,
        action: action,
        text: normalizedText,
        language: language,
        model: provider == 'qwen'
            ? QwenTtsAdapter.wordModel
            : provider == qwen3FlashKaterinaProvider
            ? Qwen3TtsAdapter.flashModel
            : provider == tencentWeWinnyProvider ||
                  provider == tencentWeJackProvider
            ? TencentTtsAdapter.action
            : await _settingsRepo.getString('tts_${settingsNamespace}_model'),
        voice: provider == 'qwen'
            ? QwenTtsAdapter.wordVoice
            : provider == qwen3FlashKaterinaProvider
            ? Qwen3TtsAdapter.flashVoice
            : provider == tencentWeWinnyProvider
            ? TencentTtsAdapter.weWinnyVoiceType.toString()
            : provider == tencentWeJackProvider
            ? TencentTtsAdapter.weJackVoiceType.toString()
            : await _settingsRepo.getString('tts_${settingsNamespace}_voice'),
        resourceId:
            provider == tencentWeWinnyProvider ||
                provider == tencentWeJackProvider
            ? TencentTtsAdapter.defaultRegion
            : await _settingsRepo.getString('tts_${settingsNamespace}_app_id'),
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
    if (provider != 'doubao' &&
        provider != 'qwen' &&
        provider != qwen3FlashKaterinaProvider &&
        provider != tencentWeWinnyProvider &&
        provider != tencentWeJackProvider) {
      return;
    }
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
    if (status == 'cached' && provider == 'qwen') {
      await enforceCacheLimit(provider: provider, language: language);
    }
  }

  Future<TtsCacheHealthReport> inspectCacheHealth({
    String provider = 'qwen',
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
      expectedFileNames.addAll(
        _compatibleCacheFileNames(
          normalizedText,
          record.textValue,
          language,
          provider,
        ),
      );

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
    String provider = 'qwen',
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
      expectedFileNames.addAll(
        _compatibleCacheFileNames(
          normalizedText,
          record.textValue,
          language,
          provider,
        ),
      );

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

  /// Returns the Qwen cache limit in bytes. A saved value of zero means no
  /// automatic pruning; the default is intentionally bounded for mobile use.
  Future<int> getCacheLimitBytes({String provider = 'qwen'}) async {
    if (provider != 'qwen') return 0;
    final configured = await _settingsRepo.getInt(qwenCacheLimitSettingKey);
    final megabytes = configured ?? defaultQwenCacheLimitMb;
    if (megabytes <= 0) return 0;
    return megabytes * 1024 * 1024;
  }

  /// Keeps a provider/language cache within its configured byte budget.
  ///
  /// Cache hits touch the file's modified time, so the least recently used
  /// audio is pruned first. Files are only ever deleted from LingoDemo's own
  /// cache directory, and their matching database record is removed too.
  Future<TtsCacheLimitResult> enforceCacheLimit({
    String provider = 'qwen',
    String language = 'en',
    int? limitBytes,
  }) async {
    await _ensureCacheDir();
    final effectiveLimit =
        limitBytes ?? await getCacheLimitBytes(provider: provider);
    final candidates = <_TtsCacheFileCandidate>[];
    for (final file in await _cacheFiles(
      provider: provider,
      language: language,
    )) {
      try {
        candidates.add(
          _TtsCacheFileCandidate(
            file: file,
            length: await file.length(),
            lastModified: await file.lastModified(),
          ),
        );
      } catch (_) {
        // A concurrent cleanup can make an entry disappear between listing
        // and inspection. It is safe to skip it here.
      }
    }

    final beforeBytes = candidates.fold<int>(
      0,
      (sum, candidate) => sum + candidate.length,
    );
    if (effectiveLimit <= 0 || beforeBytes <= effectiveLimit) {
      return TtsCacheLimitResult(
        limitBytes: effectiveLimit,
        beforeBytes: beforeBytes,
        afterBytes: beforeBytes,
        removedFiles: 0,
        removedRecords: 0,
      );
    }

    final records = await _loadCacheRecords(provider, language);
    final recordsByFileName = <String, TtsCacheRecord>{};
    for (final record in records) {
      final cachePath = record.cachePath;
      if (cachePath != null && cachePath.trim().isNotEmpty) {
        recordsByFileName[_fileNameFromPath(cachePath)] = record;
      }
    }

    candidates.sort(
      (left, right) => left.lastModified.compareTo(right.lastModified),
    );
    var remainingBytes = beforeBytes;
    var removedFiles = 0;
    var removedRecords = 0;
    final removedRecordIds = <int>{};
    for (final candidate in candidates) {
      if (remainingBytes <= effectiveLimit) break;
      try {
        await candidate.file.delete();
      } catch (_) {
        continue;
      }
      remainingBytes -= candidate.length;
      removedFiles++;

      final record = recordsByFileName[p.basename(candidate.file.path)];
      if (record != null && removedRecordIds.add(record.id)) {
        final repo = _ttsRepo;
        if (repo != null) {
          await repo.deleteCacheRecord(record.id);
        }
        removedRecords++;
      }
    }

    return TtsCacheLimitResult(
      limitBytes: effectiveLimit,
      beforeBytes: beforeBytes,
      afterBytes: remainingBytes,
      removedFiles: removedFiles,
      removedRecords: removedRecords,
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
  // Audio cache
  // ---------------------------------------------------------------------------

  Future<void> _ensureCacheDir() async {
    if (_cacheDir != null) return;
    final appDir = await _dataDirProvider();
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
    if (provider == 'qwen') {
      return RemoteWordAudioClient.audioFileNameFor(text, language: lang);
    }
    if (provider == qwen3FlashKaterinaProvider) {
      return RemoteExampleAudioClient.audioFileNameFor(text, language: lang);
    }
    if (provider == tencentWeWinnyProvider) {
      return RemoteExampleAudioProfile.tencentWeWinny.audioFileNameFor(
        text,
        language: lang,
      );
    }
    if (provider == tencentWeJackProvider) {
      return RemoteExampleAudioProfile.tencentWeJack.audioFileNameFor(
        text,
        language: lang,
      );
    }
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
      final bytes = await _readCachedAudioFile(
        file,
        provider: provider,
        touchLastModified: true,
      );
      if (bytes != null) return bytes;
    }
    return null;
  }

  Future<Uint8List?> _readCachedAudioFile(
    File file, {
    required String provider,
    required bool touchLastModified,
  }) async {
    if (!await file.exists() || await file.length() <= 0) return null;
    final bytes = await file.readAsBytes();
    if (provider == 'qwen' &&
        QwenTtsAdapter.wordAudioValidationFailure(bytes) != null) {
      // Treat an unusable staging file as a miss, but keep it until a
      // successful regeneration overwrites it. Status checks are read-only.
      return null;
    }
    if (provider == qwen3FlashKaterinaProvider &&
        Qwen3TtsAdapter.exampleAudioValidationFailure(bytes) != null) {
      // The sentence profile has a separate validation policy because Qwen3
      // owns its output sample rate. Treat a broken staged file as a cache
      // miss so the explicit batch/release workflow can regenerate it.
      return null;
    }
    if ((provider == tencentWeWinnyProvider ||
            provider == tencentWeJackProvider) &&
        !_isValidTencentExampleAudio(bytes)) {
      // Tencent WeWinny has a fixed 24 kHz PCM WAV profile. A broken staged
      // file remains visible for diagnosis but cannot be reused or packaged.
      return null;
    }
    if (touchLastModified) {
      try {
        await file.setLastModified(DateTime.now());
      } catch (_) {
        // Last-access metadata is an optimisation for LRU pruning only.
      }
    }
    return bytes;
  }

  bool _isValidTencentExampleAudio(Uint8List bytes) {
    return TencentTtsAdapter.audioValidationFailure(
              bytes,
              expectedSampleRate: TencentTtsAdapter.weWinnySampleRate,
            ) ==
            null ||
        TencentTtsAdapter.audioValidationFailure(
              bytes,
              expectedSampleRate: TencentTtsAdapter.weJackSampleRate,
            ) ==
            null;
  }

  Future<Map<String, bool>> getCachedAudioPresence(
    List<String> texts, {
    String provider = 'qwen',
    String lang = 'en',
  }) async {
    await _ensureCacheDir();
    final result = <String, bool>{};
    final resolved = <String, bool>{};
    for (final text in texts) {
      final normalizedText = _normalizeCacheText(text);
      final cached = resolved[normalizedText];
      if (cached != null) {
        result[text] = cached;
        continue;
      }
      var found = false;
      for (final path in _cachePathsForText(normalizedText, lang, provider)) {
        final bytes = await _readCachedAudioFile(
          File(path),
          provider: provider,
          touchLastModified: false,
        );
        if (bytes != null) {
          found = true;
          break;
        }
      }
      resolved[normalizedText] = found;
      result[text] = found;
    }
    return result;
  }

  String cacheKeyFor(
    String text, {
    String provider = 'qwen',
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
    return switch (provider) {
      'qwen' => QwenTtsAdapter.wordCacheFileExtension,
      qwen3FlashKaterinaProvider => Qwen3TtsAdapter.cacheFileExtension,
      tencentWeWinnyProvider => TencentTtsAdapter.cacheFileExtension,
      tencentWeJackProvider => TencentTtsAdapter.cacheFileExtension,
      _ => 'mp3',
    };
  }

  String _stableCacheKey(String text, String lang, String provider) {
    final normalizedText = _normalizeCacheText(text);
    if (provider == 'qwen') {
      return RemoteWordAudioClient.audioKeyFor(normalizedText, language: lang);
    }
    if (provider == qwen3FlashKaterinaProvider) {
      return RemoteExampleAudioClient.audioKeyFor(
        normalizedText,
        language: lang,
      );
    }
    if (provider == tencentWeWinnyProvider) {
      return RemoteExampleAudioProfile.tencentWeWinny.audioKeyFor(
        normalizedText,
        language: lang,
      );
    }
    if (provider == tencentWeJackProvider) {
      return RemoteExampleAudioProfile.tencentWeJack.audioKeyFor(
        normalizedText,
        language: lang,
      );
    }
    var hash = 0xcbf29ce484222325;
    for (final byte in utf8.encode('$provider\n$lang\n$normalizedText')) {
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
    if (provider == qwen3FlashKaterinaProvider) {
      // Qwen3's profile version is part of the immutable filename.  Keep the
      // current key first, then accept the v1 key used by the first release so
      // an app update cannot make an already-paid local cache look missing.
      return [
        for (final fileName in RemoteExampleAudioClient.audioFileNamesFor(
          normalizedText,
          language: lang,
        ))
          '${_cacheDir!.path}/$fileName',
      ];
    }
    if (provider == tencentWeWinnyProvider) {
      return [
        '${_cacheDir!.path}/${RemoteExampleAudioProfile.tencentWeWinny.audioFileNameFor(normalizedText, language: lang)}',
      ];
    }
    if (provider == tencentWeJackProvider) {
      return [
        for (final fileName
            in RemoteExampleAudioProfile.tencentWeJack.audioFileNamesFor(
              normalizedText,
              language: lang,
            ))
          '${_cacheDir!.path}/$fileName',
      ];
    }
    final paths = <String>[_cacheFilePath(normalizedText, lang, provider)];
    if (_supportsLegacyCache(provider)) {
      paths.add(_legacyCacheFilePath(text, lang, provider));
      if (normalizedText != text) {
        paths.add(_legacyCacheFilePath(normalizedText, lang, provider));
      }
    }
    return paths;
  }

  List<String> _compatibleCacheFileNames(
    String normalizedText,
    String rawText,
    String lang,
    String provider,
  ) {
    if (provider == qwen3FlashKaterinaProvider) {
      return RemoteExampleAudioClient.audioFileNamesFor(
        normalizedText,
        language: lang,
      );
    }
    if (provider == tencentWeWinnyProvider) {
      return RemoteExampleAudioProfile.tencentWeWinny.audioFileNamesFor(
        normalizedText,
        language: lang,
      );
    }
    if (provider == tencentWeJackProvider) {
      return RemoteExampleAudioProfile.tencentWeJack.audioFileNamesFor(
        normalizedText,
        language: lang,
      );
    }
    final names = <String>{_cacheFileName(normalizedText, lang, provider)};
    if (_supportsLegacyCache(provider)) {
      names.add(_legacyCacheFileName(rawText, lang, provider));
      names.add(_legacyCacheFileName(normalizedText, lang, provider));
    }
    return names.toList(growable: false);
  }

  bool _supportsLegacyCache(String provider) => provider != 'qwen';

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
    if (provider == qwen3FlashKaterinaProvider) {
      return RemoteExampleAudioClient.audioFileNamesFor(
        normalizedText,
        language: lang,
      ).any(fileNames.contains);
    }
    if (provider == tencentWeWinnyProvider) {
      return RemoteExampleAudioProfile.tencentWeWinny
          .audioFileNamesFor(normalizedText, language: lang)
          .any(fileNames.contains);
    }
    if (provider == tencentWeJackProvider) {
      return RemoteExampleAudioProfile.tencentWeJack
          .audioFileNamesFor(normalizedText, language: lang)
          .any(fileNames.contains);
    }
    if (fileNames.contains(_cacheFileName(normalizedText, lang, provider))) {
      return true;
    }
    if (!_supportsLegacyCache(provider)) return false;
    return fileNames.contains(_legacyCacheFileName(rawText, lang, provider)) ||
        fileNames.contains(
          _legacyCacheFileName(normalizedText, lang, provider),
        );
  }

  bool _isCacheFileFor(String fileName, {String? provider, String? language}) {
    if (provider == null && language == null) return true;
    if (provider == 'qwen') {
      // Current Qwen staging files have the exact same name expected by the
      // static server. Keep recognising prior qwen files so maintenance can
      // clean them deliberately, but they are never used for word playback.
      if (RegExp(r'^[a-f0-9]{64}\\.wav$').hasMatch(fileName)) return true;
      if (language == null) return fileName.contains('-qwen-');
      return fileName.contains('-qwen-$language.');
    }
    if (provider == qwen3FlashKaterinaProvider) {
      return RegExp(r'^qwen3-example-[a-f0-9]{64}\.wav$').hasMatch(fileName) ||
          fileName.contains('-$provider-');
    }
    if (provider == tencentWeWinnyProvider) {
      return RegExp(
            r'^tencent-wewinny-example-[a-f0-9]{64}\.wav$',
          ).hasMatch(fileName) ||
          fileName.contains('-$provider-');
    }
    if (provider == tencentWeJackProvider) {
      return RegExp(
            r'^tencent-(?:wewinny|wejack)-example-[a-f0-9]{64}\.wav$',
          ).hasMatch(fileName) ||
          fileName.contains('-$provider-');
    }
    if (provider == null || language == null) return true;
    return fileName.contains('-$provider-$language.');
  }

  String _fileNameFromPath(String path) {
    final normalized = path.replaceAll('\\', '/');
    final slash = normalized.lastIndexOf('/');
    return slash < 0 ? normalized : normalized.substring(slash + 1);
  }

  String _shortError(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }

  // ---------------------------------------------------------------------------
  // Audio playback
  // ---------------------------------------------------------------------------

  /// Word buttons often play short WAV files back-to-back. On Windows the
  /// default release mode tears down the native media source after each word;
  /// the completion event can reach Dart before that release fully settles.
  /// Keeping the player in stop mode and explicitly seeking a newly prepared
  /// source to zero prevents a previous source position/release from affecting
  /// the first phoneme of the next word.
  Future<void> _ensurePlaybackPlayer() async {
    if (_player != null) return;
    final player = AudioPlayer();
    try {
      await player.setReleaseMode(ReleaseMode.stop);
      _player = player;
    } catch (_) {
      player.dispose();
      rethrow;
    }
  }

  Future<void> _playAudio(Uint8List bytes, {String? mimeType}) async {
    final player = _player;
    if (player == null) {
      throw Exception('Audio player is not initialized');
    }
    // A delay before resume() leaves the Windows audio endpoint asleep. Real
    // silent PCM frames warm it while preserving every sample of the source
    // word. This copy exists only for playback; cached/server WAVs are intact.
    final playbackBytes = Platform.isWindows
        ? WavPlaybackPreRoll.prependPcm16Silence(
            bytes,
            duration: _windowsWavPlaybackPreRoll,
          )
        : bytes;
    await player.stop();
    await player.setSource(BytesSource(playbackBytes, mimeType: mimeType));
    await player.seek(Duration.zero);
    final completed = _waitForPlaybackComplete(player);
    try {
      await player.resume();
      await completed;
    } catch (_) {
      _completePlayback?.call();
      rethrow;
    }
  }

  Future<void> _waitForPlaybackComplete(AudioPlayer player) async {
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

    sub = player.onPlayerComplete.listen((_) => complete());
    timer = Timer(const Duration(minutes: 5), complete);
    await completer.future;
  }

  String? _audioMimeTypeForProvider(String provider) {
    switch (provider) {
      case 'qwen':
        return QwenTtsAdapter.wordAudioMimeType;
      case qwen3FlashKaterinaProvider:
        return Qwen3TtsAdapter.audioMimeType;
      case tencentWeWinnyProvider:
      case tencentWeJackProvider:
        return TencentTtsAdapter.audioMimeType;
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
    if (!await _ensureInitialized()) return 0;
    await _initWordProvider(language: lang);
    final wordProvider = _wordProvider;
    if (wordProvider == null) return 0;

    int success = 0;
    const provider = 'qwen';

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
        final result = await _synthesizeWithQwenWordFallback(
          wordProvider,
          normalizedText,
          lang,
          providerType: provider,
        );
        await _cacheAudio(normalizedText, lang, provider, result.audioBytes);
        await _recordUsage(
          provider: provider,
          action: 'precache',
          text: normalizedText,
          language: lang,
          result: result,
          status: 'success',
        );
        await _recordCache(
          provider: provider,
          language: lang,
          text: normalizedText,
          status: 'cached',
          audioBytes: result.audioBytes.length,
          chargedCharacters: result.chargedCharacters,
        );
        success++;
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
    _speaking = false;
  }

  Future<void> reloadSettings() async {
    await _initCloudProvider();
    _wordProvider = null;
  }

  void dispose() {
    _player?.dispose();
    _player = null;
    _cloudProvider = null;
    _wordProvider = null;
    _initialized = false;
    _initFuture = null;
  }
}
