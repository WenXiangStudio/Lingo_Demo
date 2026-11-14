import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/services/remote_example_audio_client.dart';
import '../../../core/services/remote_word_audio_client.dart';
import '../../../core/services/tts_adapters/qwen3_tts_adapter.dart';
import '../../../core/services/tts_adapters/qwen_tts_adapter.dart';
import '../../../core/services/tts_adapters/tencent_tts_adapter.dart';
import '../../../core/services/tts_providers.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/services/word_audio_release_service.dart';
import '../../../data/ai/ai_provider.dart';
import '../../../data/ai/ai_service.dart';
import '../../../data/database/app_database.dart';
import '../../../data/language_tool/language_tool_client.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/repositories.dart';
import '../services/word_audio_release_job.dart';
import 'word_audio_repair_screen.dart';

final _aiServiceProvider = Provider<AiService>((ref) {
  return AiService(ref.watch(settingsRepositoryProvider));
});

final _aiUsageSummaryProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(settingsRepositoryProvider).getAiUsageSummary();
});

final _ttsUsageSummaryProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(ttsRepositoryProvider).getUsageSummary(provider: 'qwen');
});

final _ttsRecentUsageRecordsProvider = FutureProvider.autoDispose((ref) {
  return ref
      .watch(ttsRepositoryProvider)
      .getRecentUsageRecords(provider: 'qwen', limit: 20);
});

class _TtsWordCacheFailure {
  final String text;
  final String message;

  const _TtsWordCacheFailure({required this.text, required this.message});
}

class _TtsListCacheStatus {
  final int listId;
  final String listName;
  final int listIndex;
  final int totalWords;
  final int cachedWords;
  final List<TtsPreCacheItem> pendingItems;
  final List<_TtsWordCacheFailure> failures;

  const _TtsListCacheStatus({
    required this.listId,
    required this.listName,
    required this.listIndex,
    required this.totalWords,
    required this.cachedWords,
    required this.pendingItems,
    required this.failures,
  });

  bool get isComplete => totalWords > 0 && cachedWords == totalWords;
  int get missingWords => totalWords - cachedWords;
}

final _ttsPreCacheJobProvider =
    StateNotifierProvider<_TtsPreCacheJobController, _TtsPreCacheJobState>((
      ref,
    ) {
      return _TtsPreCacheJobController(ref);
    });

final _ttsCacheMaintenanceProvider =
    StateNotifierProvider<
      _TtsCacheMaintenanceController,
      _TtsCacheMaintenanceState
    >((ref) {
      return _TtsCacheMaintenanceController(ref);
    });

class _TtsCacheMaintenanceState {
  final bool isChecking;
  final bool isCleaning;
  final bool isApplyingLimit;
  final TtsCacheHealthReport? report;
  final TtsCacheCleanupResult? cleanupResult;
  final TtsCacheLimitResult? limitResult;
  final String? error;

  const _TtsCacheMaintenanceState({
    this.isChecking = false,
    this.isCleaning = false,
    this.isApplyingLimit = false,
    this.report,
    this.cleanupResult,
    this.limitResult,
    this.error,
  });

  _TtsCacheMaintenanceState copyWith({
    bool? isChecking,
    bool? isCleaning,
    bool? isApplyingLimit,
    TtsCacheHealthReport? report,
    bool clearReport = false,
    TtsCacheCleanupResult? cleanupResult,
    bool clearCleanupResult = false,
    TtsCacheLimitResult? limitResult,
    bool clearLimitResult = false,
    String? error,
    bool clearError = false,
  }) {
    return _TtsCacheMaintenanceState(
      isChecking: isChecking ?? this.isChecking,
      isCleaning: isCleaning ?? this.isCleaning,
      isApplyingLimit: isApplyingLimit ?? this.isApplyingLimit,
      report: clearReport ? null : report ?? this.report,
      cleanupResult: clearCleanupResult
          ? null
          : cleanupResult ?? this.cleanupResult,
      limitResult: clearLimitResult ? null : limitResult ?? this.limitResult,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class _TtsCacheMaintenanceController
    extends StateNotifier<_TtsCacheMaintenanceState> {
  _TtsCacheMaintenanceController(this._ref)
    : super(const _TtsCacheMaintenanceState());

  final Ref _ref;

  Future<void> refreshCacheHealth() async {
    if (state.isChecking || state.isCleaning || state.isApplyingLimit) return;
    state = state.copyWith(isChecking: true, clearError: true);
    try {
      final report = await _ref
          .read(ttsServiceProvider)
          .inspectCacheHealth(provider: 'qwen', language: 'en');
      if (mounted) {
        state = state.copyWith(
          isChecking: false,
          report: report,
          clearError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isChecking: false, error: _formatTtsError(e));
      }
    }
  }

  Future<void> cleanExpiredCache(String lang) async {
    if (state.isCleaning || state.isChecking || state.isApplyingLimit) return;
    state = state.copyWith(isCleaning: true, clearError: true);
    try {
      final result = await _ref
          .read(ttsServiceProvider)
          .cleanExpiredCache(provider: 'qwen', language: 'en');
      if (mounted) {
        state = state.copyWith(
          isCleaning: false,
          cleanupResult: result,
          clearError: true,
        );
      }
      await refreshCacheHealth();
      await _ref
          .read(_ttsPreCacheJobProvider.notifier)
          .refreshCacheStatus(lang);
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isCleaning: false, error: _formatTtsError(e));
      }
    }
  }

  Future<void> applyCacheLimit(String lang) async {
    if (state.isCleaning || state.isChecking || state.isApplyingLimit) return;
    state = state.copyWith(
      isApplyingLimit: true,
      clearError: true,
      clearLimitResult: true,
    );
    try {
      final result = await _ref
          .read(ttsServiceProvider)
          .enforceCacheLimit(provider: 'qwen', language: 'en');
      if (mounted) {
        state = state.copyWith(
          isApplyingLimit: false,
          limitResult: result,
          clearError: true,
        );
      }
      await refreshCacheHealth();
      await _ref
          .read(_ttsPreCacheJobProvider.notifier)
          .refreshCacheStatus(lang);
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isApplyingLimit: false,
          error: _formatTtsError(e),
        );
      }
    }
  }

  String _formatTtsError(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }
}

class _TtsPreCacheJobState {
  final bool isRunning;
  final bool cancelRequested;
  final TtsPreCacheProgress? progress;
  final TtsPreCacheResult? result;
  final String? error;
  final bool isLoadingStatus;
  final List<_TtsListCacheStatus> cacheStatuses;
  final String? statusError;

  const _TtsPreCacheJobState({
    this.isRunning = false,
    this.cancelRequested = false,
    this.progress,
    this.result,
    this.error,
    this.isLoadingStatus = false,
    this.cacheStatuses = const [],
    this.statusError,
  });

  _TtsPreCacheJobState copyWith({
    bool? isRunning,
    bool? cancelRequested,
    TtsPreCacheProgress? progress,
    bool clearProgress = false,
    TtsPreCacheResult? result,
    bool clearResult = false,
    String? error,
    bool clearError = false,
    bool? isLoadingStatus,
    List<_TtsListCacheStatus>? cacheStatuses,
    String? statusError,
    bool clearStatusError = false,
  }) {
    return _TtsPreCacheJobState(
      isRunning: isRunning ?? this.isRunning,
      cancelRequested: cancelRequested ?? this.cancelRequested,
      progress: clearProgress ? null : progress ?? this.progress,
      result: clearResult ? null : result ?? this.result,
      error: clearError ? null : error ?? this.error,
      isLoadingStatus: isLoadingStatus ?? this.isLoadingStatus,
      cacheStatuses: cacheStatuses ?? this.cacheStatuses,
      statusError: clearStatusError ? null : statusError ?? this.statusError,
    );
  }
}

class _TtsPreCacheJobController extends StateNotifier<_TtsPreCacheJobState> {
  _TtsPreCacheJobController(this._ref) : super(const _TtsPreCacheJobState());

  final Ref _ref;
  bool _cancelRequested = false;

  Future<void> startCet4Qwen({
    required String apiKey,
    required String baseUrl,
    required String model,
    required String voice,
    required String resourceId,
    required int listCount,
    required String lang,
    bool onlyIncomplete = false,
    int? targetListId,
  }) async {
    if (state.isRunning) return;
    if (apiKey.trim().isEmpty) {
      state = state.copyWith(
        error: AppStrings.get('tts_precache_need_api_key', lang),
        clearResult: true,
      );
      return;
    }
    if (resourceId.trim().isEmpty) {
      state = state.copyWith(
        error: AppStrings.get('tts_precache_need_workspace_id', lang),
        clearResult: true,
      );
      return;
    }
    if (!onlyIncomplete && targetListId == null && listCount < 1) {
      state = state.copyWith(
        error: AppStrings.get('tts_precache_invalid_list_count', lang),
        clearResult: true,
      );
      return;
    }

    _cancelRequested = false;
    state = state.copyWith(
      isRunning: true,
      cancelRequested: false,
      clearProgress: true,
      clearResult: true,
      clearError: true,
    );

    try {
      final statuses = await _loadCet4CacheStatuses(lang);
      final targetStatuses = _targetStatuses(
        statuses,
        listCount: listCount,
        onlyIncomplete: onlyIncomplete,
        targetListId: targetListId,
      );
      final items = [
        for (final status in targetStatuses) ...status.pendingItems,
      ];
      state = state.copyWith(cacheStatuses: statuses);
      if (items.isEmpty) {
        final result = const TtsPreCacheResult(
          total: 0,
          success: 0,
          skipped: 0,
          failed: 0,
          apiCalls: 0,
          chargedCharacters: 0,
          audioBytes: 0,
          cancelled: false,
          failedItems: [],
        );
        state = state.copyWith(
          isRunning: false,
          cancelRequested: false,
          result: result,
          clearError: true,
        );
        return;
      }

      final result = await _ref
          .read(ttsServiceProvider)
          .preCacheCloudConfig(
            provider: 'qwen',
            apiKey: apiKey.trim(),
            baseUrl: baseUrl.trim(),
            model: model.trim(),
            voice: voice.trim(),
            resourceId: resourceId.trim(),
            items: items,
            lang: 'en',
            shouldCancel: () => _cancelRequested,
            onProgress: (progress) {
              if (mounted) {
                state = state.copyWith(
                  progress: progress,
                  clearResult: true,
                  clearError: true,
                );
              }
            },
          );
      final refreshed = await _loadCet4CacheStatuses(lang);
      _ref.invalidate(_ttsUsageSummaryProvider);
      _ref.invalidate(_ttsRecentUsageRecordsProvider);
      if (mounted) {
        state = state.copyWith(
          isRunning: false,
          cancelRequested: false,
          result: result,
          cacheStatuses: refreshed,
          clearError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isRunning: false,
          cancelRequested: false,
          error: AppStrings.get(
            'tts_precache_failed',
            lang,
            params: {'msg': _formatTtsError(e)},
          ),
          clearResult: true,
        );
      }
    } finally {
      _cancelRequested = false;
      if (mounted && state.isRunning) {
        state = state.copyWith(isRunning: false, cancelRequested: false);
      }
    }
  }

  Future<void> refreshCacheStatus(String lang) async {
    if (state.isLoadingStatus) return;
    state = state.copyWith(isLoadingStatus: true, clearStatusError: true);
    try {
      final statuses = await _loadCet4CacheStatuses(lang);
      if (mounted) {
        state = state.copyWith(
          isLoadingStatus: false,
          cacheStatuses: statuses,
          clearStatusError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isLoadingStatus: false,
          statusError: _formatTtsError(e),
        );
      }
    }
  }

  void cancel() {
    if (!state.isRunning) return;
    _cancelRequested = true;
    state = state.copyWith(cancelRequested: true);
  }

  List<_TtsListCacheStatus> _targetStatuses(
    List<_TtsListCacheStatus> statuses, {
    required int listCount,
    required bool onlyIncomplete,
    required int? targetListId,
  }) {
    if (targetListId != null) {
      return statuses
          .where(
            (status) => status.listId == targetListId && !status.isComplete,
          )
          .toList();
    }
    if (onlyIncomplete) {
      return statuses.where((status) => !status.isComplete).toList();
    }
    return statuses
        .take(listCount)
        .where((status) => !status.isComplete)
        .toList();
  }

  Future<List<_TtsListCacheStatus>> _loadCet4CacheStatuses(String lang) async {
    final listRepo = _ref.read(wordListRepositoryProvider);
    final books = await listRepo.getAllBooks();
    int? cet4BookId;
    for (final book in books) {
      final name = book.name.trim().toLowerCase();
      if (name == 'cet-4' || name == 'cet4' || name == '四级') {
        cet4BookId = book.id;
        break;
      }
    }
    if (cet4BookId == null) {
      throw Exception(AppStrings.get('tts_precache_no_cet4', lang));
    }

    final lists = await listRepo.getListsForBook(cet4BookId);
    lists.sort((a, b) => a.id.compareTo(b.id));
    if (lists.isEmpty) {
      throw Exception(AppStrings.get('tts_precache_no_cet4', lang));
    }

    final wordsByList = <int, List<Word>>{};
    final allTexts = <String>[];
    for (final list in lists) {
      final words = await listRepo.getWordsForList(list.id);
      wordsByList[list.id] = words;
      allTexts.addAll(words.map((word) => word.english));
    }
    final presence = await _ref
        .read(ttsServiceProvider)
        .getCachedAudioPresence(allTexts, provider: 'qwen', lang: 'en');
    final cacheRecords = await _ref
        .read(ttsRepositoryProvider)
        .getCacheRecords(provider: 'qwen', language: 'en');
    final failuresByText = {
      for (final record in cacheRecords)
        if (record.status == 'failed')
          record.textValue: record.errorMessage ?? '',
    };

    final statuses = <_TtsListCacheStatus>[];
    for (var i = 0; i < lists.length; i++) {
      final list = lists[i];
      final words = wordsByList[list.id] ?? const [];
      var cachedWords = 0;
      final pendingItems = <TtsPreCacheItem>[];
      final failures = <_TtsWordCacheFailure>[];
      for (final word in words) {
        final text = word.english.toString();
        final hasCache = presence[text] == true;
        if (hasCache) {
          cachedWords++;
          continue;
        }
        pendingItems.add(
          TtsPreCacheItem(text: text, listName: list.name, listId: list.id),
        );
        final failure = failuresByText[text];
        if (failure != null) {
          failures.add(_TtsWordCacheFailure(text: text, message: failure));
        }
      }
      statuses.add(
        _TtsListCacheStatus(
          listId: list.id,
          listName: list.name,
          listIndex: i + 1,
          totalWords: words.length,
          cachedWords: cachedWords,
          pendingItems: pendingItems,
          failures: failures,
        ),
      );
    }
    return statuses;
  }

  String _formatTtsError(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  final _ttsApiKeyController = TextEditingController();
  final _ttsBaseUrlController = TextEditingController();
  final _ttsModelController = TextEditingController();
  final _ttsVoiceController = TextEditingController();
  final _ttsAppIdController = TextEditingController();
  final _ttsPreCacheListCountController = TextEditingController();
  final _ttsCacheLimitMbController = TextEditingController();
  final _wordAudioServerBaseUrlController = TextEditingController();
  final _aiBaseUrlController = TextEditingController();
  final _aiModelController = TextEditingController();
  final _languageToolBaseUrlController = TextEditingController();
  bool _apiKeyVisible = false;
  bool _ttsApiKeyVisible = false;
  bool _isTesting = false;
  String? _testResult;
  bool _isTtsTesting = false;
  String? _ttsTestResult;
  String? _selectedProvider;
  double _passThreshold = AppConstants.defaultPassThreshold;
  String _themeMode = 'system';
  String _language = 'en';
  String _ttsProvider = 'qwen';
  String _wordAudioPlaybackSource = TtsService.remoteWordPlaybackSource;
  String _exampleAudioPlaybackSource =
      TtsService.configuredTtsExamplePlaybackSource;
  Set<int>? _wordAudioReleaseListIds;
  Set<int>? _qwen3ExampleAudioReleaseListIds;
  Set<int>? _tencentWeWinnyExampleAudioReleaseListIds;
  bool _ttsDoubaoLiveApiEnabled = true;
  bool _aiCollocationOptionValidationEnabled = true;
  bool _aiThinkingEnabled = true;
  bool _languageToolEnabled = true;
  bool _isLanguageToolTesting = false;
  String? _languageToolTestResult;
  bool _loaded = false;

  static const _ttsPreCacheListCountKey = 'tts_qwen_precache_list_count';
  static const _ttsDoubaoLiveApiEnabledKey = 'tts_doubao_live_api_enabled';
  static const _defaultTtsPreCacheListCount = 1;

  static const _ttsProviderValues = {
    'qwen',
    TtsService.qwen3FlashKaterinaProvider,
    'doubao',
    'openai',
  };

  @override
  void dispose() {
    _apiKeyController.dispose();
    _ttsApiKeyController.dispose();
    _ttsBaseUrlController.dispose();
    _ttsModelController.dispose();
    _ttsVoiceController.dispose();
    _ttsAppIdController.dispose();
    _ttsPreCacheListCountController.dispose();
    _ttsCacheLimitMbController.dispose();
    _wordAudioServerBaseUrlController.dispose();
    _aiBaseUrlController.dispose();
    _aiModelController.dispose();
    _languageToolBaseUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final provider = await settingsRepo.getAiProvider();
    final apiKey = await settingsRepo.getAiApiKey();
    final threshold = await settingsRepo.getPassThreshold();
    final themeMode = await settingsRepo.getString('theme_mode');
    final lang = await settingsRepo.getAppLanguage();
    final ttsProvider = await settingsRepo.getTtsProvider();
    final normalizedTtsProvider = _normalizeTtsProvider(ttsProvider);
    final ttsSettingsNamespace = _ttsSettingsNamespace(normalizedTtsProvider);
    final ttsApiKey = await settingsRepo.getString(
      'tts_${ttsSettingsNamespace}_api_key',
    );
    final ttsBaseUrl = await settingsRepo.getString(
      'tts_${ttsSettingsNamespace}_base_url',
    );
    final ttsModel = await settingsRepo.getString(
      'tts_${ttsSettingsNamespace}_model',
    );
    final ttsVoice = await settingsRepo.getString(
      'tts_${ttsSettingsNamespace}_voice',
    );
    final ttsAppId = await settingsRepo.getString(
      'tts_${ttsSettingsNamespace}_app_id',
    );
    final ttsPreCacheListCount = await settingsRepo.getInt(
      _ttsPreCacheListCountKey,
    );
    final ttsCacheLimitMb = await settingsRepo.getInt(
      TtsService.qwenCacheLimitSettingKey,
    );
    final ttsDoubaoLiveApiEnabled = await settingsRepo.getString(
      _ttsDoubaoLiveApiEnabledKey,
    );
    final wordAudioServerBaseUrl = await settingsRepo.getString(
      SettingsRepository.keyRemoteWordAudioBaseUrl,
    );
    final wordAudioPlaybackSource = await settingsRepo.getString(
      SettingsRepository.keyWordAudioPlaybackSource,
    );
    final exampleAudioPlaybackSource = await settingsRepo.getString(
      SettingsRepository.keyExampleAudioPlaybackSource,
    );
    final aiBaseUrl = await settingsRepo.getAiBaseUrl();
    final aiModel = await settingsRepo.getAiModel();
    final aiCollocationOptionValidationEnabled = await settingsRepo
        .getAiCollocationOptionValidationEnabled();
    final aiThinkingEnabled = await settingsRepo.getAiThinkingEnabled();
    final languageToolEnabled = await settingsRepo.getLanguageToolEnabled();
    final languageToolBaseUrl = await settingsRepo.getLanguageToolBaseUrl();

    if (mounted) {
      setState(() {
        _selectedProvider = provider ?? 'claude';
        _apiKeyController.text = apiKey ?? '';
        _passThreshold = threshold;
        _themeMode = themeMode ?? 'system';
        _language = lang ?? 'en';
        _ttsProvider = normalizedTtsProvider;
        _ttsApiKeyController.text = ttsApiKey ?? '';
        _ttsBaseUrlController.text = ttsBaseUrl ?? '';
        _ttsModelController.text = _modelForTtsProvider(
          normalizedTtsProvider,
          ttsModel,
        );
        _ttsVoiceController.text = _voiceForTtsProvider(
          normalizedTtsProvider,
          ttsVoice,
        );
        _ttsAppIdController.text = ttsAppId ?? '';
        _ttsPreCacheListCountController.text =
            (ttsPreCacheListCount ?? _defaultTtsPreCacheListCount).toString();
        _ttsCacheLimitMbController.text =
            (ttsCacheLimitMb ?? TtsService.defaultQwenCacheLimitMb).toString();
        _wordAudioServerBaseUrlController.text = wordAudioServerBaseUrl ?? '';
        _wordAudioPlaybackSource = TtsService.normalizeWordPlaybackSource(
          wordAudioPlaybackSource,
        );
        _exampleAudioPlaybackSource = TtsService.normalizeExamplePlaybackSource(
          exampleAudioPlaybackSource,
        );
        _ttsDoubaoLiveApiEnabled = ttsDoubaoLiveApiEnabled != 'false';
        _aiBaseUrlController.text = aiBaseUrl ?? '';
        _aiModelController.text = aiModel ?? '';
        _aiCollocationOptionValidationEnabled =
            aiCollocationOptionValidationEnabled;
        _aiThinkingEnabled = aiThinkingEnabled;
        _languageToolEnabled = languageToolEnabled;
        _languageToolBaseUrlController.text =
            languageToolBaseUrl ?? LanguageToolClient.defaultBaseUrl;
        _loaded = true;
      });
      if (normalizedTtsProvider == 'qwen') {
        await ref
            .read(_ttsPreCacheJobProvider.notifier)
            .refreshCacheStatus(lang ?? 'en');
        await ref
            .read(_ttsCacheMaintenanceProvider.notifier)
            .refreshCacheHealth();
        await ref.read(wordAudioReleaseJobProvider.notifier).refreshLists();
        await ref
            .read(wordAudioReleaseJobProvider.notifier)
            .loadLatestPackage();
      } else if (normalizedTtsProvider ==
          TtsService.qwen3FlashKaterinaProvider) {
        await ref
            .read(qwen3ExampleAudioReleaseJobProvider.notifier)
            .refreshLists();
        await ref
            .read(qwen3ExampleAudioReleaseJobProvider.notifier)
            .refreshCacheStatuses();
        await ref
            .read(qwen3ExampleAudioReleaseJobProvider.notifier)
            .loadLatestPackage();
      }
      await ref
          .read(tencentWeWinnyExampleAudioReleaseJobProvider.notifier)
          .refreshLists();
      await ref
          .read(tencentWeWinnyExampleAudioReleaseJobProvider.notifier)
          .refreshCacheStatuses();
      await ref
          .read(tencentWeWinnyExampleAudioReleaseJobProvider.notifier)
          .loadLatestPackage();
    }
  }

  Future<void> _saveProvider(String value) async {
    setState(() => _selectedProvider = value);
    await ref.read(settingsRepositoryProvider).setAiProvider(value);
    ref.read(_aiServiceProvider).clearCache();
  }

  Future<void> _saveApiKey(String value) async {
    await ref.read(settingsRepositoryProvider).setAiApiKey(value.trim());
    ref.read(_aiServiceProvider).clearCache();
  }

  Future<void> _saveAiBaseUrl(String value) async {
    await ref.read(settingsRepositoryProvider).setAiBaseUrl(value.trim());
    ref.read(_aiServiceProvider).clearCache();
  }

  Future<void> _saveAiModel(String value) async {
    await ref.read(settingsRepositoryProvider).setAiModel(value.trim());
    ref.read(_aiServiceProvider).clearCache();
  }

  Future<void> _saveAiCollocationOptionValidationEnabled(bool value) async {
    setState(() => _aiCollocationOptionValidationEnabled = value);
    await ref
        .read(settingsRepositoryProvider)
        .setAiCollocationOptionValidationEnabled(value);
  }

  Future<void> _saveAiThinkingEnabled(bool value) async {
    setState(() => _aiThinkingEnabled = value);
    await ref.read(settingsRepositoryProvider).setAiThinkingEnabled(value);
    // The adapter caches the provider, so the new value only takes effect
    // after the cache is dropped.
    ref.read(_aiServiceProvider).clearCache();
  }

  Future<void> _saveAiConfig(BuildContext context, String lang) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setAiApiKey(_apiKeyController.text.trim());
    await repo.setAiBaseUrl(_aiBaseUrlController.text.trim());
    await repo.setAiModel(_aiModelController.text.trim());
    ref.read(_aiServiceProvider).clearCache();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('ai_settings_saved', lang)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _savePassThreshold(double value) async {
    setState(() => _passThreshold = value);
    await ref.read(settingsRepositoryProvider).setPassThreshold(value);
  }

  Future<void> _saveLanguageToolEnabled(bool value) async {
    setState(() => _languageToolEnabled = value);
    await ref.read(settingsRepositoryProvider).setLanguageToolEnabled(value);
  }

  Future<void> _saveLanguageToolBaseUrl(String value) async {
    final baseUrl = LanguageToolClient.normalizeBaseUrl(value);
    await ref.read(settingsRepositoryProvider).setLanguageToolBaseUrl(baseUrl);
    ref.invalidate(languageToolClientProvider);
    if (mounted && _languageToolBaseUrlController.text != baseUrl) {
      _languageToolBaseUrlController.text = baseUrl;
    }
  }

  Future<void> _saveThemeMode(String value) async {
    setState(() => _themeMode = value);
    await ref.read(settingsRepositoryProvider).setString('theme_mode', value);
    final newMode = switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    ref.read(themeModeProvider.notifier).state = newMode;
  }

  Future<void> _saveWordAudioServerBaseUrl(
    BuildContext context,
    String lang,
  ) async {
    final rawBaseUrl = _wordAudioServerBaseUrlController.text.trim();
    try {
      final baseUrl = rawBaseUrl.isEmpty
          ? ''
          : RemoteWordAudioClient.normalizeBaseUrl(rawBaseUrl);
      await ref
          .read(settingsRepositoryProvider)
          .setString(SettingsRepository.keyRemoteWordAudioBaseUrl, baseUrl);
      if (mounted) {
        _wordAudioServerBaseUrlController.text = baseUrl;
      }
      await ref.read(ttsServiceProvider).reloadSettings();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.get('settings_saved', lang)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on RemoteWordAudioException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppStrings.get('word_audio_server_invalid_address', lang),
            ),
          ),
        );
      }
    }
  }

  Future<void> _saveWordAudioPlaybackSource(String value) async {
    final normalized = TtsService.normalizeWordPlaybackSource(value);
    setState(() => _wordAudioPlaybackSource = normalized);
    await ref
        .read(settingsRepositoryProvider)
        .setString(SettingsRepository.keyWordAudioPlaybackSource, normalized);
  }

  Future<void> _saveExampleAudioPlaybackSource(String value) async {
    final normalized = TtsService.normalizeExamplePlaybackSource(value);
    setState(() => _exampleAudioPlaybackSource = normalized);
    await ref
        .read(settingsRepositoryProvider)
        .setString(
          SettingsRepository.keyExampleAudioPlaybackSource,
          normalized,
        );
  }

  Future<void> _saveTtsProvider(String value) async {
    // Save current engine's config before switching
    await _flushCurrentTtsConfig();
    final normalized = _normalizeTtsProvider(value);
    setState(() => _ttsProvider = normalized);
    await ref.read(settingsRepositoryProvider).setTtsProvider(normalized);
    // Load the new engine's saved config (or blank)
    await _loadTtsConfigFor(normalized);
    await ref.read(ttsServiceProvider).reloadSettings();
    if (normalized == 'qwen') {
      await ref
          .read(_ttsPreCacheJobProvider.notifier)
          .refreshCacheStatus(_language);
      await ref
          .read(_ttsCacheMaintenanceProvider.notifier)
          .refreshCacheHealth();
      await ref.read(wordAudioReleaseJobProvider.notifier).refreshLists();
      await ref.read(wordAudioReleaseJobProvider.notifier).loadLatestPackage();
    } else if (normalized == TtsService.qwen3FlashKaterinaProvider) {
      await ref
          .read(qwen3ExampleAudioReleaseJobProvider.notifier)
          .refreshLists();
      await ref
          .read(qwen3ExampleAudioReleaseJobProvider.notifier)
          .refreshCacheStatuses();
      await ref
          .read(qwen3ExampleAudioReleaseJobProvider.notifier)
          .loadLatestPackage();
    }
  }

  String _normalizeTtsProvider(String? provider) {
    return _ttsProviderValues.contains(provider) ? provider! : 'qwen';
  }

  bool _isQwenTtsProfile(String provider) {
    return provider == 'qwen' ||
        provider == TtsService.qwen3FlashKaterinaProvider;
  }

  String _ttsSettingsNamespace(String provider) {
    return provider == TtsService.qwen3FlashKaterinaProvider
        ? 'qwen'
        : provider;
  }

  String _modelForTtsProvider(String provider, String? savedModel) {
    return switch (provider) {
      'qwen' => QwenTtsAdapter.wordModel,
      TtsService.qwen3FlashKaterinaProvider => Qwen3TtsAdapter.flashModel,
      _ => savedModel ?? '',
    };
  }

  String _voiceForTtsProvider(String provider, String? savedVoice) {
    return switch (provider) {
      'qwen' => QwenTtsAdapter.wordVoice,
      TtsService.qwen3FlashKaterinaProvider => Qwen3TtsAdapter.flashVoice,
      _ => savedVoice ?? '',
    };
  }

  Widget _ttsProviderChip({required String value, required String label}) {
    return ChoiceChip(
      label: Text(label),
      selected: _ttsProvider == value,
      onSelected: (_) => _saveTtsProvider(value),
    );
  }

  String _ttsProfileTitle(String lang) {
    return switch (_ttsProvider) {
      'qwen' => AppStrings.get('tts_qwen_title', lang),
      TtsService.qwen3FlashKaterinaProvider => AppStrings.get(
        'tts_qwen3_flash_katerina_title',
        lang,
      ),
      'openai' => AppStrings.get('tts_openai_title', lang),
      _ => AppStrings.get('tts_doubao_title', lang),
    };
  }

  String _ttsBaseUrlHint() {
    return switch (_ttsProvider) {
      'qwen' || TtsService.qwen3FlashKaterinaProvider =>
        'https://{WorkspaceId}.cn-beijing.maas.aliyuncs.com',
      'openai' => 'https://api.openai.com',
      _ => 'https://openspeech.bytedance.com',
    };
  }

  String _ttsModelHint() {
    return switch (_ttsProvider) {
      'qwen' => QwenTtsAdapter.wordModel,
      TtsService.qwen3FlashKaterinaProvider => Qwen3TtsAdapter.flashModel,
      'doubao' => 'seed-tts-2.0-standard',
      _ => 'tts-1',
    };
  }

  String _ttsVoiceHint() {
    return switch (_ttsProvider) {
      'qwen' => QwenTtsAdapter.wordVoice,
      TtsService.qwen3FlashKaterinaProvider => Qwen3TtsAdapter.flashVoice,
      'doubao' => 'zh_female_tiexinnvsheng_mars_bigtts',
      _ => 'alloy',
    };
  }

  Widget _qwenTtsProfileSummary(ThemeData theme, String lang) {
    final isFlashKaterina =
        _ttsProvider == TtsService.qwen3FlashKaterinaProvider;
    final titleKey = isFlashKaterina
        ? 'tts_qwen3_flash_katerina_title'
        : 'tts_qwen_word_preset_title';
    final descriptionKey = isFlashKaterina
        ? 'tts_qwen3_flash_katerina_desc'
        : 'tts_qwen_word_preset_desc';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isFlashKaterina
                ? Icons.auto_awesome_outlined
                : Icons.record_voice_over_outlined,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get(titleKey, lang),
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 3),
                Text(
                  AppStrings.get(descriptionKey, lang),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppStrings.get('tts_model_label', lang)}: '
                  '${_ttsModelController.text}',
                  style: theme.textTheme.labelMedium,
                ),
                Text(
                  '${AppStrings.get('tts_voice_label', lang)}: '
                  '${_ttsVoiceController.text}',
                  style: theme.textTheme.labelMedium,
                ),
                if (isFlashKaterina)
                  Text(
                    '${AppStrings.get('tts_instruction_label', lang)}: '
                    '${AppStrings.get('tts_qwen3_flash_katerina_instruction', lang)}',
                    style: theme.textTheme.labelMedium,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Persist current UI fields under the active provider's namespace.
  Future<void> _flushCurrentTtsConfig() async {
    final repo = ref.read(settingsRepositoryProvider);
    final ns = _ttsSettingsNamespace(_ttsProvider);
    await repo.setString('tts_${ns}_api_key', _ttsApiKeyController.text.trim());
    await repo.setString(
      'tts_${ns}_base_url',
      _ttsBaseUrlController.text.trim(),
    );
    if (!_isQwenTtsProfile(_ttsProvider)) {
      await repo.setString('tts_${ns}_model', _ttsModelController.text.trim());
      await repo.setString('tts_${ns}_voice', _ttsVoiceController.text.trim());
    }
    await repo.setString('tts_${ns}_app_id', _ttsAppIdController.text.trim());
  }

  /// Load saved config for [provider] into the UI fields.
  Future<void> _loadTtsConfigFor(String provider) async {
    final repo = ref.read(settingsRepositoryProvider);
    final ns = _ttsSettingsNamespace(provider);
    final apiKey = (await repo.getString('tts_${ns}_api_key')) ?? '';
    final baseUrl = (await repo.getString('tts_${ns}_base_url')) ?? '';
    final model = (await repo.getString('tts_${ns}_model')) ?? '';
    final voice = (await repo.getString('tts_${ns}_voice')) ?? '';
    final appId = (await repo.getString('tts_${ns}_app_id')) ?? '';
    setState(() {
      _ttsApiKeyController.text = apiKey;
      _ttsBaseUrlController.text = baseUrl;
      _ttsModelController.text = _modelForTtsProvider(provider, model);
      _ttsVoiceController.text = _voiceForTtsProvider(provider, voice);
      _ttsAppIdController.text = appId;
    });
  }

  void _saveTtsApiKey(String value) {}

  void _saveTtsBaseUrl(String value) {}

  void _saveTtsModel(String value) {}

  void _saveTtsVoice(String value) {}

  void _saveTtsAppId(String value) {}

  Future<void> _saveDoubaoLiveApiEnabled(bool value) async {
    setState(() => _ttsDoubaoLiveApiEnabled = value);
    await ref
        .read(settingsRepositoryProvider)
        .setString(_ttsDoubaoLiveApiEnabledKey, value ? 'true' : 'false');
    await ref.read(ttsServiceProvider).reloadSettings();
  }

  Future<void> _saveTtsPreCacheListCount(String value) async {
    setState(() {});
    final count = int.tryParse(value.trim());
    if (count != null && count > 0) {
      await ref
          .read(settingsRepositoryProvider)
          .setInt(_ttsPreCacheListCountKey, count);
    }
  }

  int _ttsPreCacheListCount() {
    final count = int.tryParse(_ttsPreCacheListCountController.text.trim());
    if (count == null || count < 1) return _defaultTtsPreCacheListCount;
    return count;
  }

  Future<void> _saveTtsCacheLimitMb(String value) async {
    setState(() {});
    final megabytes = int.tryParse(value.trim());
    if (megabytes != null && megabytes >= 0) {
      await ref
          .read(settingsRepositoryProvider)
          .setInt(TtsService.qwenCacheLimitSettingKey, megabytes);
    }
  }

  int? _ttsCacheLimitMb() {
    final megabytes = int.tryParse(_ttsCacheLimitMbController.text.trim());
    return megabytes != null && megabytes >= 0 ? megabytes : null;
  }

  Future<void> _applyTtsCacheLimit(String lang) async {
    final megabytes = _ttsCacheLimitMb();
    if (megabytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.get('tts_cache_limit_invalid', lang)),
          ),
        );
      }
      return;
    }
    await _saveTtsCacheLimitMb(megabytes.toString());
    await ref.read(_ttsCacheMaintenanceProvider.notifier).applyCacheLimit(lang);
  }

  Future<void> _testTts(BuildContext context, String lang) async {
    setState(() {
      _isTtsTesting = true;
      _ttsTestResult = null;
    });
    try {
      // Test the current form values directly without relying on saved state.
      await ref
          .read(ttsServiceProvider)
          .testCloudConfig(
            provider: _ttsProvider,
            apiKey: _ttsApiKeyController.text.trim(),
            baseUrl: _ttsBaseUrlController.text.trim(),
            model: _ttsModelController.text.trim(),
            voice: _ttsVoiceController.text.trim(),
            resourceId: _ttsAppIdController.text.trim(),
            text: 'test',
            lang: _isQwenTtsProfile(_ttsProvider) ? 'en' : lang,
          );
      if (mounted) setState(() => _ttsTestResult = 'success');
    } catch (e) {
      if (mounted) {
        setState(
          () => _ttsTestResult = AppStrings.get(
            'tts_test_failed_detail',
            lang,
            params: {'msg': _formatTtsError(e)},
          ),
        );
      }
    } finally {
      ref.invalidate(_ttsUsageSummaryProvider);
      ref.invalidate(_ttsRecentUsageRecordsProvider);
      if (mounted) setState(() => _isTtsTesting = false);
    }
  }

  String _formatTtsError(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }

  Future<void> _preCacheCet4Qwen(
    String lang, {
    bool onlyIncomplete = false,
    int? targetListId,
  }) async {
    final listCount = int.tryParse(_ttsPreCacheListCountController.text.trim());
    if (listCount != null && listCount > 0) {
      await ref
          .read(settingsRepositoryProvider)
          .setInt(_ttsPreCacheListCountKey, listCount);
    }
    await ref
        .read(_ttsPreCacheJobProvider.notifier)
        .startCet4Qwen(
          apiKey: _ttsApiKeyController.text,
          baseUrl: _ttsBaseUrlController.text,
          model: _ttsModelController.text,
          voice: _ttsVoiceController.text,
          resourceId: _ttsAppIdController.text,
          listCount: listCount ?? 0,
          lang: lang,
          onlyIncomplete: onlyIncomplete,
          targetListId: targetListId,
        );
  }

  List<WordAudioReleaseListOption> _selectedWordAudioReleaseLists(
    WordAudioReleaseJobState job,
  ) {
    final selectedIds = _wordAudioReleaseListIds;
    if (selectedIds == null) {
      return job.lists.isEmpty ? const [] : [job.lists.first];
    }
    return job.lists
        .where((item) => selectedIds.contains(item.id))
        .toList(growable: false);
  }

  Set<int> _fullyCachedListIds(_TtsPreCacheJobState job) {
    return {
      for (final status in job.cacheStatuses)
        if (status.isComplete) status.listId,
    };
  }

  bool _wordAudioReleasePlanMatchesSelection(
    WordAudioReleasePlan? plan,
    List<WordAudioReleaseListOption> selected,
  ) {
    if (plan == null || plan.listIds.length != selected.length) return false;
    final selectedIds = selected.map((item) => item.id).toSet();
    return plan.listIds.every(selectedIds.contains);
  }

  String _wordAudioReleaseSelectedListsText(
    String lang,
    Iterable<int> listNumbers,
  ) {
    final numbers = listNumbers.toList(growable: false);
    return AppStrings.get(
      'word_audio_release_selected_lists',
      lang,
      params: {'count': numbers.length.toString(), 'lists': numbers.join(', ')},
    );
  }

  String _wordAudioReleaseSelectionLabel(
    String lang,
    List<WordAudioReleaseListOption> selected,
  ) {
    if (selected.isEmpty) {
      return AppStrings.get('word_audio_release_no_selection', lang);
    }
    if (selected.length == 1) {
      final item = selected.single;
      return AppStrings.get(
        'word_audio_release_list_option',
        lang,
        params: {
          'index': item.listNumber.toString(),
          'name': item.name,
          'count': item.wordCount.toString(),
        },
      );
    }
    return _wordAudioReleaseSelectedListsText(
      lang,
      selected.map((item) => item.listNumber),
    );
  }

  String _wordAudioReleaseListStatusText(
    String lang,
    _TtsListCacheStatus? cacheStatus, {
    required WordAudioServerListStatus? serverStatus,
  }) {
    final localStatus = cacheStatus == null
        ? AppStrings.get('word_audio_release_list_cache_unknown', lang)
        : cacheStatus.isComplete
        ? AppStrings.get('word_audio_release_list_cached', lang)
        : AppStrings.get(
            'word_audio_release_list_cache_progress',
            lang,
            params: {
              'cached': cacheStatus.cachedWords.toString(),
              'total': cacheStatus.totalWords.toString(),
            },
          );
    if (cacheStatus?.isComplete != true) return localStatus;

    final remoteStatus = switch (serverStatus?.uploadState) {
      WordAudioServerListUploadState.checking => AppStrings.get(
        'word_audio_release_list_server_checking',
        lang,
        params: {
          'checked': serverStatus!.checkedWords.toString(),
          'total': serverStatus.totalWords.toString(),
        },
      ),
      WordAudioServerListUploadState.uploaded => AppStrings.get(
        'word_audio_release_list_server_uploaded',
        lang,
        params: {
          'uploaded': serverStatus!.uploadedWords.toString(),
          'total': serverStatus.totalWords.toString(),
        },
      ),
      WordAudioServerListUploadState.notUploaded => AppStrings.get(
        'word_audio_release_list_server_not_uploaded',
        lang,
        params: {'total': serverStatus!.totalWords.toString()},
      ),
      WordAudioServerListUploadState.partiallyUploaded => AppStrings.get(
        'word_audio_release_list_server_partial',
        lang,
        params: {
          'uploaded': serverStatus!.uploadedWords.toString(),
          'total': serverStatus.totalWords.toString(),
        },
      ),
      WordAudioServerListUploadState.unavailable => AppStrings.get(
        'word_audio_release_list_server_unavailable',
        lang,
      ),
      null => AppStrings.get(
        'word_audio_release_list_server_not_checked',
        lang,
      ),
    };
    return '$localStatus · $remoteStatus';
  }

  String _wordAudioReleaseServerFailureText(
    String lang,
    RemoteWordAudioFailure failure,
  ) {
    return AppStrings.get(switch (failure) {
      RemoteWordAudioFailure.notConfigured =>
        'word_audio_release_server_status_not_configured',
      RemoteWordAudioFailure.invalidUrl =>
        'word_audio_release_server_status_invalid_url',
      _ => 'word_audio_release_server_status_failed',
    }, lang);
  }

  String _qwen3ExampleReleaseListStatusText(
    String lang,
    WordAudioReleaseListCacheStatus? cacheStatus, {
    required WordAudioServerListStatus? serverStatus,
  }) {
    final localStatus = cacheStatus == null
        ? AppStrings.get('qwen3_example_audio_release_list_cache_unknown', lang)
        : cacheStatus.isComplete
        ? AppStrings.get('qwen3_example_audio_release_list_cached', lang)
        : AppStrings.get(
            'qwen3_example_audio_release_list_cache_progress',
            lang,
            params: {
              'cached': cacheStatus.cachedItems.toString(),
              'total': cacheStatus.totalItems.toString(),
            },
          );
    if (cacheStatus?.isComplete != true) return localStatus;

    final remoteStatus = switch (serverStatus?.uploadState) {
      WordAudioServerListUploadState.checking => AppStrings.get(
        'qwen3_example_audio_release_list_server_checking',
        lang,
        params: {
          'checked': serverStatus!.checkedItems.toString(),
          'total': serverStatus.totalItems.toString(),
        },
      ),
      WordAudioServerListUploadState.uploaded => AppStrings.get(
        'qwen3_example_audio_release_list_server_uploaded',
        lang,
        params: {
          'uploaded': serverStatus!.uploadedItems.toString(),
          'total': serverStatus.totalItems.toString(),
        },
      ),
      WordAudioServerListUploadState.notUploaded => AppStrings.get(
        'qwen3_example_audio_release_list_server_not_uploaded',
        lang,
        params: {'total': serverStatus!.totalItems.toString()},
      ),
      WordAudioServerListUploadState.partiallyUploaded => AppStrings.get(
        'qwen3_example_audio_release_list_server_partial',
        lang,
        params: {
          'uploaded': serverStatus!.uploadedItems.toString(),
          'total': serverStatus.totalItems.toString(),
        },
      ),
      WordAudioServerListUploadState.unavailable => AppStrings.get(
        'qwen3_example_audio_release_list_server_unavailable',
        lang,
      ),
      null => AppStrings.get(
        'qwen3_example_audio_release_list_server_not_checked',
        lang,
      ),
    };
    return '$localStatus · $remoteStatus';
  }

  String _qwen3ExampleReleaseServerFailureText(
    String lang,
    RemoteExampleAudioFailure failure,
  ) {
    return AppStrings.get(switch (failure) {
      RemoteExampleAudioFailure.notConfigured =>
        'qwen3_example_audio_release_server_status_not_configured',
      RemoteExampleAudioFailure.invalidUrl =>
        'qwen3_example_audio_release_server_status_invalid_url',
      _ => 'qwen3_example_audio_release_server_status_failed',
    }, lang);
  }

  String _compactWordAudioReleaseListNumbers(Iterable<int> values) {
    final numbers = values.toSet().toList()..sort();
    if (numbers.isEmpty) return '';

    final groups = <String>[];
    var start = numbers.first;
    var end = start;
    for (final number in numbers.skip(1)) {
      if (number == end + 1) {
        end = number;
        continue;
      }
      groups.add(start == end ? '$start' : '$start–$end');
      start = number;
      end = number;
    }
    groups.add(start == end ? '$start' : '$start–$end');
    return groups.join(', ');
  }

  List<int> _serverStatusListNumbers(
    WordAudioReleaseJobState job,
    WordAudioServerListUploadState status,
  ) {
    return [
      for (final item in job.lists)
        if (job.serverListStatuses[item.id]?.uploadState == status)
          item.listNumber,
    ];
  }

  Future<void> _chooseWordAudioReleaseLists(
    String lang,
    List<WordAudioReleaseListOption> options,
    Map<int, _TtsListCacheStatus> cacheStatuses,
    Map<int, WordAudioServerListStatus> serverListStatuses,
  ) async {
    if (options.isEmpty) return;
    final initialIds = _wordAudioReleaseListIds == null
        ? {options.first.id}
        : {..._wordAudioReleaseListIds!};
    final selected = await showDialog<Set<int>>(
      context: context,
      builder: (dialogContext) {
        final draftIds = Set<int>.from(initialIds);
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: Text(
              AppStrings.get('word_audio_release_select_lists', lang),
            ),
            content: SizedBox(
              width: 420,
              height: 360,
              child: ListView(
                children: [
                  for (final item in options)
                    CheckboxListTile(
                      value: draftIds.contains(item.id),
                      onChanged: (checked) => setDialogState(() {
                        if (checked ?? false) {
                          draftIds.add(item.id);
                        } else {
                          draftIds.remove(item.id);
                        }
                      }),
                      title: Text(
                        AppStrings.get(
                          'word_audio_release_list_option',
                          lang,
                          params: {
                            'index': item.listNumber.toString(),
                            'name': item.name,
                            'count': item.wordCount.toString(),
                          },
                        ),
                      ),
                      subtitle: Text(
                        _wordAudioReleaseListStatusText(
                          lang,
                          cacheStatuses[item.id],
                          serverStatus: serverListStatuses[item.id],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: options.isEmpty
                    ? null
                    : () => setDialogState(() {
                        draftIds
                          ..clear()
                          ..addAll(options.map((item) => item.id));
                      }),
                child: Text(AppStrings.get('select_all', lang)),
              ),
              TextButton(
                onPressed: () => setDialogState(draftIds.clear),
                child: Text(AppStrings.get('deselect_all', lang)),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(AppStrings.get('cancel', lang)),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(Set<int>.from(draftIds)),
                child: Text(AppStrings.get('done', lang)),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted || selected == null) return;
    setState(() => _wordAudioReleaseListIds = selected);
  }

  Future<void> _confirmWordAudioRelease(
    String lang, {
    required bool publish,
  }) async {
    final job = ref.read(wordAudioReleaseJobProvider);
    final selected = _selectedWordAudioReleaseLists(job);
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.get('word_audio_release_no_selection', lang),
          ),
        ),
      );
      return;
    }
    final plan = await ref
        .read(wordAudioReleaseJobProvider.notifier)
        .preparePlan(selected.map((item) => item.id).toList());
    if (!mounted || plan == null) return;
    if (plan.normalCalls > 0 && _ttsApiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('tts_precache_need_api_key', lang)),
        ),
      );
      return;
    }
    if (plan.normalCalls > 0 && _ttsAppIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('tts_precache_need_workspace_id', lang)),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.get('word_audio_release_confirm_title', lang)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get(
                publish
                    ? 'word_audio_release_confirm_publish_desc'
                    : 'word_audio_release_confirm_generate_desc',
                lang,
                params: {
                  'lists': _wordAudioReleaseSelectedListsText(
                    lang,
                    plan.listNumbers,
                  ),
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.get(
                'word_audio_release_confirm_calls',
                lang,
                params: {
                  'calls': plan.normalCalls.toString(),
                  'attempts': plan.maxAttempts.toString(),
                },
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.get(
                'word_audio_release_confirm_cache',
                lang,
                params: {
                  'reusable': plan.reusableWords.toString(),
                  'total': plan.totalWords.toString(),
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.get('cancel', lang)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              AppStrings.get(
                publish
                    ? 'word_audio_release_confirm_publish'
                    : 'word_audio_release_confirm_generate',
                lang,
              ),
            ),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    await ref
        .read(wordAudioReleaseJobProvider.notifier)
        .run(
          plan: plan,
          config: WordAudioReleaseTtsConfig(
            apiKey: _ttsApiKeyController.text.trim(),
            baseUrl: _ttsBaseUrlController.text.trim(),
            model: _ttsModelController.text.trim(),
            voice: _ttsVoiceController.text.trim(),
            resourceId: _ttsAppIdController.text.trim(),
          ),
          publish: publish,
        );
    await _refreshWordAudioReleaseViews(lang);
  }

  Future<void> _refreshWordAudioReleaseViews(String lang) async {
    ref.invalidate(_ttsUsageSummaryProvider);
    ref.invalidate(_ttsRecentUsageRecordsProvider);
    await ref.read(_ttsPreCacheJobProvider.notifier).refreshCacheStatus(lang);
    await ref.read(_ttsCacheMaintenanceProvider.notifier).refreshCacheHealth();
  }

  Future<void> _verifyWordAudioRelease() async {
    await ref.read(wordAudioReleaseJobProvider.notifier).verifyLatestPackage();
  }

  Future<void> _republishWordAudioRelease() async {
    await ref
        .read(wordAudioReleaseJobProvider.notifier)
        .republishLatestPackage();
  }

  Future<void> _openInteractiveWordAudioPublisher() async {
    await ref
        .read(wordAudioReleaseJobProvider.notifier)
        .openInteractivePublisher();
  }

  List<WordAudioReleaseListOption> _selectedQwen3ExampleReleaseLists(
    WordAudioReleaseJobState job,
  ) {
    final selectedIds = _qwen3ExampleAudioReleaseListIds;
    if (selectedIds == null) {
      return job.lists.isEmpty ? const [] : [job.lists.first];
    }
    return job.lists
        .where((item) => selectedIds.contains(item.id))
        .toList(growable: false);
  }

  String _qwen3ExampleReleaseSelectedListsText(
    String lang,
    Iterable<int> listNumbers,
  ) {
    final numbers = listNumbers.toList(growable: false);
    return AppStrings.get(
      'qwen3_example_audio_release_selected_lists',
      lang,
      params: {'count': numbers.length.toString(), 'lists': numbers.join(', ')},
    );
  }

  String _qwen3ExampleReleaseSelectionLabel(
    String lang,
    List<WordAudioReleaseListOption> selected,
  ) {
    if (selected.isEmpty) {
      return AppStrings.get('qwen3_example_audio_release_no_selection', lang);
    }
    if (selected.length == 1) {
      final item = selected.single;
      return AppStrings.get(
        'qwen3_example_audio_release_list_option',
        lang,
        params: {
          'index': item.listNumber.toString(),
          'name': item.name,
          'count': item.wordCount.toString(),
        },
      );
    }
    return _qwen3ExampleReleaseSelectedListsText(
      lang,
      selected.map((item) => item.listNumber),
    );
  }

  Future<void> _chooseQwen3ExampleReleaseLists(
    String lang,
    List<WordAudioReleaseListOption> options,
    Map<int, WordAudioReleaseListCacheStatus> cacheStatuses,
    Map<int, WordAudioServerListStatus> serverListStatuses,
  ) async {
    if (options.isEmpty) return;
    final initialIds = _qwen3ExampleAudioReleaseListIds == null
        ? {options.first.id}
        : {..._qwen3ExampleAudioReleaseListIds!};
    final selected = await showDialog<Set<int>>(
      context: context,
      builder: (dialogContext) {
        final draftIds = Set<int>.from(initialIds);
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: Text(
              AppStrings.get('qwen3_example_audio_release_select_lists', lang),
            ),
            content: SizedBox(
              width: 420,
              height: 360,
              child: ListView(
                children: [
                  for (final item in options)
                    CheckboxListTile(
                      value: draftIds.contains(item.id),
                      onChanged: (checked) => setDialogState(() {
                        if (checked ?? false) {
                          draftIds.add(item.id);
                        } else {
                          draftIds.remove(item.id);
                        }
                      }),
                      title: Text(
                        AppStrings.get(
                          'qwen3_example_audio_release_list_option',
                          lang,
                          params: {
                            'index': item.listNumber.toString(),
                            'name': item.name,
                            'count': item.wordCount.toString(),
                          },
                        ),
                      ),
                      subtitle: Text(
                        _qwen3ExampleReleaseListStatusText(
                          lang,
                          cacheStatuses[item.id],
                          serverStatus: serverListStatuses[item.id],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => setDialogState(() {
                  draftIds
                    ..clear()
                    ..addAll(options.map((item) => item.id));
                }),
                child: Text(AppStrings.get('select_all', lang)),
              ),
              TextButton(
                onPressed: () => setDialogState(draftIds.clear),
                child: Text(AppStrings.get('deselect_all', lang)),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(AppStrings.get('cancel', lang)),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(Set<int>.from(draftIds)),
                child: Text(AppStrings.get('done', lang)),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted || selected == null) return;
    setState(() => _qwen3ExampleAudioReleaseListIds = selected);
  }

  Future<void> _confirmQwen3ExampleRelease(
    String lang, {
    required bool publish,
  }) async {
    final job = ref.read(qwen3ExampleAudioReleaseJobProvider);
    final selected = _selectedQwen3ExampleReleaseLists(job);
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.get('qwen3_example_audio_release_no_selection', lang),
          ),
        ),
      );
      return;
    }

    final plan = await ref
        .read(qwen3ExampleAudioReleaseJobProvider.notifier)
        .preparePlan(selected.map((item) => item.id).toList());
    if (!mounted || plan == null) return;
    if (plan.normalCalls > 0 && _ttsApiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('tts_precache_need_api_key', lang)),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          AppStrings.get('qwen3_example_audio_release_confirm_title', lang),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get(
                publish
                    ? 'qwen3_example_audio_release_confirm_publish_desc'
                    : 'qwen3_example_audio_release_confirm_generate_desc',
                lang,
                params: {
                  'lists': _qwen3ExampleReleaseSelectedListsText(
                    lang,
                    plan.listNumbers,
                  ),
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.get(
                'qwen3_example_audio_release_confirm_calls',
                lang,
                params: {
                  'calls': plan.normalCalls.toString(),
                  'attempts': plan.maxAttempts.toString(),
                },
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.get(
                'qwen3_example_audio_release_confirm_cache',
                lang,
                params: {
                  'reusable': plan.reusableWords.toString(),
                  'total': plan.totalWords.toString(),
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.get('cancel', lang)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              AppStrings.get(
                publish
                    ? 'word_audio_release_confirm_publish'
                    : 'word_audio_release_confirm_generate',
                lang,
              ),
            ),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    await ref
        .read(qwen3ExampleAudioReleaseJobProvider.notifier)
        .run(
          plan: plan,
          config: WordAudioReleaseTtsConfig(
            apiKey: _ttsApiKeyController.text.trim(),
            baseUrl: _ttsBaseUrlController.text.trim(),
            model: Qwen3TtsAdapter.flashModel,
            voice: Qwen3TtsAdapter.flashVoice,
            resourceId: _ttsAppIdController.text.trim(),
          ),
          publish: publish,
        );
  }

  Future<void> _verifyQwen3ExampleRelease() async {
    await ref
        .read(qwen3ExampleAudioReleaseJobProvider.notifier)
        .verifyLatestPackage();
  }

  Future<void> _republishQwen3ExampleRelease() async {
    await ref
        .read(qwen3ExampleAudioReleaseJobProvider.notifier)
        .republishLatestPackage();
  }

  Future<void> _openInteractiveQwen3ExamplePublisher() async {
    await ref
        .read(qwen3ExampleAudioReleaseJobProvider.notifier)
        .openInteractivePublisher();
  }

  List<WordAudioReleaseListOption> _selectedTencentWeWinnyExampleReleaseLists(
    WordAudioReleaseJobState job,
  ) {
    final selectedIds = _tencentWeWinnyExampleAudioReleaseListIds;
    if (selectedIds == null) {
      return job.lists.isEmpty ? const [] : [job.lists.first];
    }
    return job.lists
        .where((item) => selectedIds.contains(item.id))
        .toList(growable: false);
  }

  String _tencentWeWinnyExampleReleaseSelectedListsText(
    String lang,
    Iterable<int> listNumbers,
  ) {
    final numbers = listNumbers.toList(growable: false);
    return AppStrings.get(
      'tencent_wewinny_example_audio_release_selected_lists',
      lang,
      params: {'count': numbers.length.toString(), 'lists': numbers.join(', ')},
    );
  }

  String _tencentWeWinnyExampleReleaseSelectionLabel(
    String lang,
    List<WordAudioReleaseListOption> selected,
  ) {
    if (selected.isEmpty) {
      return AppStrings.get(
        'tencent_wewinny_example_audio_release_no_selection',
        lang,
      );
    }
    if (selected.length == 1) {
      final item = selected.single;
      return AppStrings.get(
        'tencent_wewinny_example_audio_release_list_option',
        lang,
        params: {
          'index': item.listNumber.toString(),
          'name': item.name,
          'count': item.wordCount.toString(),
        },
      );
    }
    return _tencentWeWinnyExampleReleaseSelectedListsText(
      lang,
      selected.map((item) => item.listNumber),
    );
  }

  String _tencentWeWinnyExampleReleaseListStatusText(
    String lang,
    WordAudioReleaseListCacheStatus? cacheStatus, {
    required WordAudioServerListStatus? serverStatus,
  }) {
    final localStatus = cacheStatus == null
        ? AppStrings.get(
            'tencent_wewinny_example_audio_release_list_cache_unknown',
            lang,
          )
        : cacheStatus.isComplete
        ? AppStrings.get(
            'tencent_wewinny_example_audio_release_list_cached',
            lang,
          )
        : AppStrings.get(
            'tencent_wewinny_example_audio_release_list_cache_progress',
            lang,
            params: {
              'cached': cacheStatus.cachedItems.toString(),
              'total': cacheStatus.totalItems.toString(),
            },
          );
    final remoteStatus = switch (serverStatus?.uploadState) {
      WordAudioServerListUploadState.checking => AppStrings.get(
        'word_audio_release_list_server_checking',
        lang,
        params: {
          'checked': serverStatus!.checkedItems.toString(),
          'total': serverStatus.totalItems.toString(),
        },
      ),
      WordAudioServerListUploadState.uploaded => AppStrings.get(
        'word_audio_release_list_server_uploaded',
        lang,
        params: {
          'uploaded': serverStatus!.uploadedItems.toString(),
          'total': serverStatus.totalItems.toString(),
        },
      ),
      WordAudioServerListUploadState.notUploaded => AppStrings.get(
        'word_audio_release_list_server_not_uploaded',
        lang,
        params: {'total': serverStatus!.totalItems.toString()},
      ),
      WordAudioServerListUploadState.partiallyUploaded => AppStrings.get(
        'word_audio_release_list_server_partial',
        lang,
        params: {
          'uploaded': serverStatus!.uploadedItems.toString(),
          'total': serverStatus.totalItems.toString(),
        },
      ),
      WordAudioServerListUploadState.unavailable => AppStrings.get(
        'word_audio_release_list_server_unavailable',
        lang,
      ),
      null => AppStrings.get(
        'word_audio_release_list_server_not_checked',
        lang,
      ),
    };
    return '$localStatus · $remoteStatus';
  }

  String _tencentWeWinnyExampleReleaseServerFailureText(
    String lang,
    RemoteExampleAudioFailure failure,
  ) {
    return AppStrings.get(switch (failure) {
      RemoteExampleAudioFailure.notConfigured =>
        'tencent_wewinny_example_audio_release_server_status_not_configured',
      RemoteExampleAudioFailure.invalidUrl =>
        'tencent_wewinny_example_audio_release_server_status_invalid_url',
      _ => 'tencent_wewinny_example_audio_release_server_status_failed',
    }, lang);
  }

  Future<void> _chooseTencentWeWinnyExampleReleaseLists(
    String lang,
    List<WordAudioReleaseListOption> options,
    Map<int, WordAudioReleaseListCacheStatus> cacheStatuses,
    Map<int, WordAudioServerListStatus> serverListStatuses,
  ) async {
    if (options.isEmpty) return;
    final initialIds = _tencentWeWinnyExampleAudioReleaseListIds == null
        ? {options.first.id}
        : {..._tencentWeWinnyExampleAudioReleaseListIds!};
    final selected = await showDialog<Set<int>>(
      context: context,
      builder: (dialogContext) {
        final draftIds = Set<int>.from(initialIds);
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: Text(
              AppStrings.get(
                'tencent_wewinny_example_audio_release_select_lists',
                lang,
              ),
            ),
            content: SizedBox(
              width: 420,
              height: 360,
              child: ListView(
                children: [
                  for (final item in options)
                    CheckboxListTile(
                      value: draftIds.contains(item.id),
                      onChanged: (checked) => setDialogState(() {
                        if (checked ?? false) {
                          draftIds.add(item.id);
                        } else {
                          draftIds.remove(item.id);
                        }
                      }),
                      title: Text(
                        AppStrings.get(
                          'tencent_wewinny_example_audio_release_list_option',
                          lang,
                          params: {
                            'index': item.listNumber.toString(),
                            'name': item.name,
                            'count': item.wordCount.toString(),
                          },
                        ),
                      ),
                      subtitle: Text(
                        _tencentWeWinnyExampleReleaseListStatusText(
                          lang,
                          cacheStatuses[item.id],
                          serverStatus: serverListStatuses[item.id],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => setDialogState(() {
                  draftIds
                    ..clear()
                    ..addAll(options.map((item) => item.id));
                }),
                child: Text(AppStrings.get('select_all', lang)),
              ),
              TextButton(
                onPressed: () => setDialogState(draftIds.clear),
                child: Text(AppStrings.get('deselect_all', lang)),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(AppStrings.get('cancel', lang)),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(Set<int>.from(draftIds)),
                child: Text(AppStrings.get('done', lang)),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted || selected == null) return;
    setState(() => _tencentWeWinnyExampleAudioReleaseListIds = selected);
  }

  Future<void> _confirmTencentWeWinnyExampleRelease(
    String lang, {
    required bool publish,
  }) async {
    final job = ref.read(tencentWeWinnyExampleAudioReleaseJobProvider);
    final selected = _selectedTencentWeWinnyExampleReleaseLists(job);
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.get(
              'tencent_wewinny_example_audio_release_no_selection',
              lang,
            ),
          ),
        ),
      );
      return;
    }

    final plan = await ref
        .read(tencentWeWinnyExampleAudioReleaseJobProvider.notifier)
        .preparePlan(selected.map((item) => item.id).toList());
    if (!mounted || plan == null) return;
    if (plan.normalCalls > 0 &&
        !TencentTtsAdapter.hasEnvironmentCredentials()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.get(
              'tencent_wewinny_example_audio_release_credentials_required',
              lang,
            ),
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          AppStrings.get(
            'tencent_wewinny_example_audio_release_confirm_title',
            lang,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get(
                publish
                    ? 'tencent_wewinny_example_audio_release_confirm_publish_desc'
                    : 'tencent_wewinny_example_audio_release_confirm_generate_desc',
                lang,
                params: {
                  'lists': _tencentWeWinnyExampleReleaseSelectedListsText(
                    lang,
                    plan.listNumbers,
                  ),
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.get(
                'tencent_wewinny_example_audio_release_confirm_calls',
                lang,
                params: {
                  'calls': plan.normalCalls.toString(),
                  'attempts': plan.maxAttempts.toString(),
                },
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.get(
                'tencent_wewinny_example_audio_release_confirm_cache',
                lang,
                params: {
                  'reusable': plan.reusableWords.toString(),
                  'total': plan.totalWords.toString(),
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.get('cancel', lang)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              AppStrings.get(
                publish
                    ? 'word_audio_release_confirm_publish'
                    : 'word_audio_release_confirm_generate',
                lang,
              ),
            ),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    await ref
        .read(tencentWeWinnyExampleAudioReleaseJobProvider.notifier)
        .run(
          plan: plan,
          config: const WordAudioReleaseTtsConfig.tencentWeJack(),
          publish: publish,
        );
  }

  Future<void> _verifyTencentWeWinnyExampleRelease() async {
    await ref
        .read(tencentWeWinnyExampleAudioReleaseJobProvider.notifier)
        .verifyLatestPackage();
  }

  Future<void> _republishTencentWeWinnyExampleRelease() async {
    await ref
        .read(tencentWeWinnyExampleAudioReleaseJobProvider.notifier)
        .republishLatestPackage();
  }

  Future<void> _openInteractiveTencentWeWinnyExamplePublisher() async {
    await ref
        .read(tencentWeWinnyExampleAudioReleaseJobProvider.notifier)
        .openInteractivePublisher();
  }

  Future<void> _saveTtsCloudConfig(BuildContext context, String lang) async {
    final repo = ref.read(settingsRepositoryProvider);
    final ns = _ttsSettingsNamespace(_ttsProvider);
    await repo.setString('tts_${ns}_api_key', _ttsApiKeyController.text.trim());
    await repo.setString(
      'tts_${ns}_base_url',
      _ttsBaseUrlController.text.trim(),
    );
    if (!_isQwenTtsProfile(_ttsProvider)) {
      await repo.setString('tts_${ns}_model', _ttsModelController.text.trim());
      await repo.setString('tts_${ns}_voice', _ttsVoiceController.text.trim());
    }
    await repo.setString('tts_${ns}_app_id', _ttsAppIdController.text.trim());
    await ref.read(ttsServiceProvider).reloadSettings();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('settings_saved', lang)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveLanguage(String value) async {
    setState(() => _language = value);
    await ref.read(settingsRepositoryProvider).setAppLanguage(value);
    ref.read(languageProvider.notifier).setLanguage(value);
  }

  Future<void> _testConnection() async {
    final lang = ref.read(languageProvider);
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final provider = await ref.read(_aiServiceProvider).getProvider();
      await provider.generateSentences(['test']);
      ref.invalidate(_aiUsageSummaryProvider);
      if (mounted) setState(() => _testResult = 'success');
    } on AiException catch (e) {
      if (mounted) setState(() => _testResult = e.message);
    } catch (e) {
      if (mounted) {
        final message = e.toString();
        final shortMessage = message.length > 100
            ? message.substring(0, 100)
            : message;
        setState(
          () => _testResult =
              '${AppStrings.get('connection_failed', lang)}$shortMessage',
        );
      }
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  Future<void> _testLanguageToolConnection() async {
    final lang = ref.read(languageProvider);
    setState(() {
      _isLanguageToolTesting = true;
      _languageToolTestResult = null;
    });

    try {
      final baseUrl = LanguageToolClient.normalizeBaseUrl(
        _languageToolBaseUrlController.text,
      );
      await ref
          .read(settingsRepositoryProvider)
          .setLanguageToolBaseUrl(baseUrl);
      ref.invalidate(languageToolClientProvider);
      _languageToolBaseUrlController.text = baseUrl;

      final client = LanguageToolClient(baseUrl: baseUrl);
      await client.check('She go to school every day.');
      if (mounted) setState(() => _languageToolTestResult = 'success');
    } catch (e) {
      if (mounted) {
        setState(
          () => _languageToolTestResult = AppStrings.get(
            'language_tool_test_failed',
            lang,
            params: {'error': _formatTtsError(e)},
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLanguageToolTesting = false);
    }
  }

  Widget _wordAudioPlaybackCard(ThemeData theme, String lang) {
    final usesRemoteServer =
        _wordAudioPlaybackSource == TtsService.remoteWordPlaybackSource;
    final usesRemoteQwen3ExampleServer =
        _exampleAudioPlaybackSource == TtsService.remoteExamplePlaybackSource;
    final usesRemoteTencentExampleServer =
        _exampleAudioPlaybackSource ==
        TtsService.remoteTencentWeWinnyExamplePlaybackSource;
    final usesRemoteExampleServer =
        usesRemoteQwen3ExampleServer || usesRemoteTencentExampleServer;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.volume_up_outlined, size: 18),
                const SizedBox(width: 8),
                Text(
                  AppStrings.get('word_audio_playback_title', lang),
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.get('word_audio_playback_source_label', lang),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(
                    AppStrings.get('word_audio_playback_remote', lang),
                  ),
                  selected: usesRemoteServer,
                  onSelected: (_) => _saveWordAudioPlaybackSource(
                    TtsService.remoteWordPlaybackSource,
                  ),
                ),
                ChoiceChip(
                  label: Text(
                    AppStrings.get('word_audio_playback_current_tts', lang),
                  ),
                  selected: !usesRemoteServer,
                  onSelected: (_) => _saveWordAudioPlaybackSource(
                    TtsService.configuredTtsWordPlaybackSource,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.get(
                usesRemoteServer
                    ? 'word_audio_playback_remote_desc'
                    : 'word_audio_playback_current_tts_desc',
                lang,
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 4),
            Text(
              AppStrings.get('example_audio_playback_title', lang),
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.get('example_audio_playback_source_label', lang),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(
                    AppStrings.get('example_audio_playback_remote', lang),
                  ),
                  selected: usesRemoteQwen3ExampleServer,
                  onSelected: (_) => _saveExampleAudioPlaybackSource(
                    TtsService.remoteExamplePlaybackSource,
                  ),
                ),
                ChoiceChip(
                  label: Text(
                    AppStrings.get(
                      'example_audio_playback_remote_tencent_wewinny',
                      lang,
                    ),
                  ),
                  selected: usesRemoteTencentExampleServer,
                  onSelected: (_) => _saveExampleAudioPlaybackSource(
                    TtsService.remoteTencentWeWinnyExamplePlaybackSource,
                  ),
                ),
                ChoiceChip(
                  label: Text(
                    AppStrings.get('example_audio_playback_current_tts', lang),
                  ),
                  selected: !usesRemoteExampleServer,
                  onSelected: (_) => _saveExampleAudioPlaybackSource(
                    TtsService.configuredTtsExamplePlaybackSource,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.get(
                usesRemoteQwen3ExampleServer
                    ? 'example_audio_playback_remote_desc'
                    : usesRemoteTencentExampleServer
                    ? 'example_audio_playback_remote_tencent_wewinny_desc'
                    : 'example_audio_playback_current_tts_desc',
                lang,
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            if (usesRemoteServer || usesRemoteExampleServer) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _wordAudioServerBaseUrlController,
                keyboardType: TextInputType.url,
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                enableSuggestions: false,
                onSubmitted: (_) => _saveWordAudioServerBaseUrl(context, lang),
                decoration: InputDecoration(
                  labelText: AppStrings.get('word_audio_server_address', lang),
                  hintText: AppStrings.get(
                    'word_audio_server_address_hint',
                    lang,
                  ),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _saveWordAudioServerBaseUrl(context, lang),
                  icon: const Icon(Icons.save, size: 18),
                  label: Text(AppStrings.get('word_audio_server_save', lang)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _ttsPreCacheStatusCard(
    ThemeData theme,
    String lang,
    _TtsPreCacheJobState job,
  ) {
    final result = job.result;
    final progress = job.progress;
    final statusColor = job.error != null
        ? Colors.red
        : result == null
        ? theme.colorScheme.primary
        : result.cancelled || result.failed > 0
        ? Colors.orange
        : Colors.green;
    final icon = job.error != null
        ? Icons.error_outline
        : result == null
        ? Icons.downloading
        : result.cancelled || result.failed > 0
        ? Icons.warning_amber_outlined
        : Icons.check_circle;

    final message =
        job.error ??
        (result != null
            ? AppStrings.get(
                result.cancelled
                    ? 'tts_precache_cancelled'
                    : 'tts_precache_done',
                lang,
                params: {
                  'success': result.success.toString(),
                  'skipped': result.skipped.toString(),
                  'failed': result.failed.toString(),
                },
              )
            : AppStrings.get(
                'tts_precache_running',
                lang,
                params: {
                  'done': (progress?.done ?? 0).toString(),
                  'total': (progress?.total ?? 0).toString(),
                },
              ));
    final success = result?.success ?? progress?.success ?? 0;
    final skipped = result?.skipped ?? progress?.skipped ?? 0;
    final failed = result?.failed ?? progress?.failed ?? 0;
    final apiCalls = result?.apiCalls ?? progress?.apiCalls ?? 0;
    final chargedCharacters =
        result?.chargedCharacters ?? progress?.chargedCharacters ?? 0;
    final audioBytes = result?.audioBytes ?? progress?.audioBytes ?? 0;
    final total = result?.total ?? progress?.total ?? 0;
    final done = result?.total ?? progress?.done ?? 0;
    final currentText = progress?.currentText ?? '';
    final currentListName = progress?.currentListName ?? '';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: statusColor, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(message, style: theme.textTheme.bodySmall)),
            ],
          ),
          if (progress != null && result == null && total > 0) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(value: done / total),
            const SizedBox(height: 8),
            Text(
              AppStrings.get(
                'tts_precache_current',
                lang,
                params: {'list': currentListName, 'word': currentText},
              ),
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 4),
          Text(
            AppStrings.get(
              'tts_precache_counts',
              lang,
              params: {
                'success': success.toString(),
                'skipped': skipped.toString(),
                'failed': failed.toString(),
              },
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.get(
              'tts_precache_usage',
              lang,
              params: {
                'calls': apiCalls.toString(),
                'chars': chargedCharacters.toString(),
                'bytes': _formatBytes(audioBytes),
              },
            ),
            style: theme.textTheme.bodySmall,
          ),
          if (result != null && result.failedItems.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              AppStrings.get(
                'tts_precache_first_failure',
                lang,
                params: {
                  'error': _formatPreCacheFailure(
                    result.failedItems.first,
                    lang,
                  ),
                },
              ),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _ttsUsageStatsCard(
    ThemeData theme,
    String lang,
    AsyncValue<TtsUsageSummary> summary,
    AsyncValue<List<TtsUsageRecord>> recent,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_outlined, size: 18),
                const SizedBox(width: 8),
                Text(
                  AppStrings.get('tts_usage_title', lang),
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            summary.when(
              data: (value) => Text(
                AppStrings.get(
                  'tts_usage_summary',
                  lang,
                  params: {
                    'calls': value.apiCalls.toString(),
                    'chars': value.chargedCharacters.toString(),
                    'bytes': _formatBytes(value.audioBytes),
                    'failed': value.failedCalls.toString(),
                  },
                ),
                style: theme.textTheme.bodySmall,
              ),
              loading: () => Text(
                AppStrings.get('loading', lang),
                style: theme.textTheme.bodySmall,
              ),
              error: (e, _) => Text(
                AppStrings.get(
                  'tts_usage_load_failed',
                  lang,
                  params: {'msg': _formatTtsError(e)},
                ),
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 8),
            recent.when(
              data: (records) {
                if (records.isEmpty) {
                  return Text(
                    AppStrings.get('tts_usage_no_records', lang),
                    style: theme.textTheme.bodySmall,
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: records.take(5).map((record) {
                    final time = DateTime.fromMillisecondsSinceEpoch(
                      record.createdAt,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        AppStrings.get(
                          'tts_usage_record',
                          lang,
                          params: {
                            'time':
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                            'action': record.action,
                            'word': record.textValue,
                            'chars': (record.chargedCharacters ?? 0).toString(),
                            'status': record.status,
                          },
                        ),
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wordAudioRepairCard(
    ThemeData theme,
    String lang, {
    required bool enabled,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.build_circle_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.get('word_audio_repair_settings_title', lang),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.get('word_audio_repair_settings_desc', lang),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: !enabled
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const WordAudioRepairScreen(),
                        ),
                      ),
                icon: const Icon(Icons.tune_outlined, size: 18),
                label: Text(AppStrings.get('word_audio_repair_open', lang)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wordAudioReleaseCard(
    ThemeData theme,
    String lang,
    WordAudioReleaseJobState job, {
    required bool ttsPreCacheRunning,
    required _TtsPreCacheJobState cacheJob,
  }) {
    final fullyCachedListIds = _fullyCachedListIds(cacheJob);
    final cacheStatusesByListId = {
      for (final status in cacheJob.cacheStatuses) status.listId: status,
    };
    final selected = _selectedWordAudioReleaseLists(job);
    final allListsCached =
        job.lists.isNotEmpty &&
        job.lists.every((item) => fullyCachedListIds.contains(item.id));
    final plan = _wordAudioReleasePlanMatchesSelection(job.plan, selected)
        ? job.plan
        : null;
    final successStages = {
      WordAudioReleaseJobStage.generated,
      WordAudioReleaseJobStage.published,
      WordAudioReleaseJobStage.verified,
    };
    final warningStages = {
      WordAudioReleaseJobStage.interactiveSudoRequired,
      WordAudioReleaseJobStage.cancelled,
      WordAudioReleaseJobStage.synthesisFailed,
      WordAudioReleaseJobStage.validationFailed,
    };
    final errorStages = {
      WordAudioReleaseJobStage.failed,
      WordAudioReleaseJobStage.unsupported,
    };
    final color = successStages.contains(job.stage)
        ? Colors.green
        : errorStages.contains(job.stage)
        ? Colors.red
        : warningStages.contains(job.stage)
        ? Colors.orange
        : theme.colorScheme.primary;
    final busy =
        job.isRunning || ttsPreCacheRunning || job.isCheckingServerStatus;
    final selectionLoading = job.isLoadingLists || cacheJob.isLoadingStatus;
    final serverStatusRows = [
      (
        state: WordAudioServerListUploadState.uploaded,
        key: 'word_audio_release_server_status_uploaded',
      ),
      (
        state: WordAudioServerListUploadState.notUploaded,
        key: 'word_audio_release_server_status_not_uploaded',
      ),
      (
        state: WordAudioServerListUploadState.partiallyUploaded,
        key: 'word_audio_release_server_status_partial',
      ),
      (
        state: WordAudioServerListUploadState.unavailable,
        key: 'word_audio_release_server_status_unavailable',
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.rocket_launch_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.get('word_audio_release_title', lang),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: selectionLoading || busy
                      ? null
                      : () async {
                          ref
                              .read(wordAudioReleaseJobProvider.notifier)
                              .clearServerStatuses();
                          await Future.wait([
                            ref
                                .read(wordAudioReleaseJobProvider.notifier)
                                .refreshLists(),
                            ref
                                .read(_ttsPreCacheJobProvider.notifier)
                                .refreshCacheStatus(lang),
                          ]);
                        },
                  icon: selectionLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 16),
                  label: Text(AppStrings.get('refresh', lang)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.get('word_audio_release_desc', lang),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.get('word_audio_release_list_label', lang),
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: busy || selectionLoading || job.lists.isEmpty
                    ? null
                    : () => _chooseWordAudioReleaseLists(
                        lang,
                        job.lists,
                        cacheStatusesByListId,
                        job.serverListStatuses,
                      ),
                icon: const Icon(Icons.playlist_add_check, size: 18),
                label: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _wordAudioReleaseSelectionLabel(lang, selected),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            if (job.lists.isEmpty && !job.isLoadingLists) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.get('word_audio_release_no_lists', lang),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                ),
              ),
            ],
            if (allListsCached && !selectionLoading) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.get('word_audio_release_all_lists_cached', lang),
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.green),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud_outlined, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppStrings.get(
                            'word_audio_release_server_status_title',
                            lang,
                          ),
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: busy || selectionLoading
                            ? null
                            : () => ref
                                  .read(wordAudioReleaseJobProvider.notifier)
                                  .refreshServerStatuses(
                                    fullyCachedListIds: fullyCachedListIds,
                                  ),
                        icon: job.isCheckingServerStatus
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh, size: 16),
                        label: Text(
                          AppStrings.get(
                            job.serverListStatuses.isEmpty
                                ? 'word_audio_release_check_server_status'
                                : 'word_audio_release_refresh_server_status',
                            lang,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (job.isCheckingServerStatus) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: job.serverStatusTotalWords == 0
                          ? null
                          : job.serverStatusCheckedWords /
                                job.serverStatusTotalWords,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.get(
                        'word_audio_release_server_status_progress',
                        lang,
                        params: {
                          'done': job.serverStatusCheckedWords.toString(),
                          'total': job.serverStatusTotalWords.toString(),
                        },
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ] else if (job.serverStatusFailure != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _wordAudioReleaseServerFailureText(
                        lang,
                        job.serverStatusFailure!,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                      ),
                    ),
                  ] else if (fullyCachedListIds.isEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.get(
                        'word_audio_release_server_status_no_cached',
                        lang,
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ] else if (job.serverListStatuses.isEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.get(
                        'word_audio_release_server_status_not_checked',
                        lang,
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ] else ...[
                    const SizedBox(height: 6),
                    for (final row in serverStatusRows)
                      if (_serverStatusListNumbers(job, row.state).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            AppStrings.get(
                              row.key,
                              lang,
                              params: {
                                'lists': _compactWordAudioReleaseListNumbers(
                                  _serverStatusListNumbers(job, row.state),
                                ),
                              },
                            ),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                  ],
                ],
              ),
            ),
            if (plan != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get(
                        'word_audio_release_plan_summary',
                        lang,
                        params: {
                          'lists': _wordAudioReleaseSelectedListsText(
                            lang,
                            plan.listNumbers,
                          ),
                          'total': plan.totalWords.toString(),
                          'reusable': plan.reusableWords.toString(),
                          'pending': plan.normalCalls.toString(),
                        },
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.get(
                        'word_audio_release_call_summary',
                        lang,
                        params: {
                          'calls': plan.normalCalls.toString(),
                          'attempts': plan.maxAttempts.toString(),
                        },
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: busy || selectionLoading || selected.isEmpty
                      ? null
                      : () => _confirmWordAudioRelease(lang, publish: true),
                  icon: const Icon(Icons.rocket_launch, size: 18),
                  label: Text(
                    AppStrings.get('word_audio_release_generate_publish', lang),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: busy || selectionLoading || selected.isEmpty
                      ? null
                      : () => _confirmWordAudioRelease(lang, publish: false),
                  icon: const Icon(Icons.inventory_2_outlined, size: 18),
                  label: Text(
                    AppStrings.get('word_audio_release_generate_only', lang),
                  ),
                ),
                if (job.canCancel)
                  OutlinedButton.icon(
                    onPressed: job.cancelRequested
                        ? null
                        : () => ref
                              .read(wordAudioReleaseJobProvider.notifier)
                              .cancel(),
                    icon: const Icon(Icons.stop_circle_outlined, size: 18),
                    label: Text(AppStrings.get('cancel', lang)),
                  ),
              ],
            ),
            if (job.package != null) ...[
              const SizedBox(height: 12),
              Text(
                AppStrings.get(
                  'word_audio_release_package_ready',
                  lang,
                  params: {'count': job.package!.expectedCount.toString()},
                ),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: busy ? null : _verifyWordAudioRelease,
                    icon: const Icon(Icons.verified_outlined, size: 18),
                    label: Text(
                      AppStrings.get('word_audio_release_verify_server', lang),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: busy ? null : _republishWordAudioRelease,
                    icon: const Icon(Icons.publish_outlined, size: 18),
                    label: Text(
                      AppStrings.get('word_audio_release_republish', lang),
                    ),
                  ),
                ],
              ),
            ],
            if (job.stage ==
                WordAudioReleaseJobStage.interactiveSudoRequired) ...[
              const SizedBox(height: 12),
              Text(
                AppStrings.get('word_audio_release_sudo_required', lang),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: busy ? null : _openInteractiveWordAudioPublisher,
                icon: const Icon(Icons.terminal_outlined, size: 18),
                label: Text(
                  AppStrings.get('word_audio_release_open_interactive', lang),
                ),
              ),
            ],
            if (job.stage ==
                WordAudioReleaseJobStage.interactivePublisherOpened) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.get('word_audio_release_interactive_opened', lang),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                ),
              ),
            ],
            if (job.stage != WordAudioReleaseJobStage.idle) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          busy
                              ? Icons.hourglass_top_outlined
                              : Icons.info_outline,
                          color: color,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _wordAudioReleaseStatusText(job, lang),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    if (job.progress != null && busy) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: job.progress!.total == 0
                            ? null
                            : job.progress!.done / job.progress!.total,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.get(
                          'tts_precache_current',
                          lang,
                          params: {
                            'list': job.progress!.currentListName,
                            'word': job.progress!.currentText,
                          },
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    if (job.synthesis != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.get(
                          'tts_precache_counts',
                          lang,
                          params: {
                            'success': job.synthesis!.success.toString(),
                            'skipped': job.synthesis!.skipped.toString(),
                            'failed': job.synthesis!.failed.toString(),
                          },
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.get(
                          'tts_precache_usage',
                          lang,
                          params: {
                            'calls': job.synthesis!.apiCalls.toString(),
                            'chars': job.synthesis!.chargedCharacters
                                .toString(),
                            'bytes': _formatBytes(job.synthesis!.audioBytes),
                          },
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (job.logs.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.get('word_audio_release_log_title', lang),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              ...job.logs.reversed
                  .take(4)
                  .map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(line, style: theme.textTheme.bodySmall),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _qwen3ExampleAudioReleaseCard(
    ThemeData theme,
    String lang,
    WordAudioReleaseJobState job,
  ) {
    final cacheStatuses = job.localListStatuses;
    final fullyCachedListIds = {
      for (final status in cacheStatuses.values)
        if (status.isComplete) status.listId,
    };
    final selected = _selectedQwen3ExampleReleaseLists(job);
    final plan = _wordAudioReleasePlanMatchesSelection(job.plan, selected)
        ? job.plan
        : null;
    final successStages = {
      WordAudioReleaseJobStage.generated,
      WordAudioReleaseJobStage.published,
      WordAudioReleaseJobStage.verified,
    };
    final warningStages = {
      WordAudioReleaseJobStage.interactiveSudoRequired,
      WordAudioReleaseJobStage.cancelled,
      WordAudioReleaseJobStage.synthesisFailed,
      WordAudioReleaseJobStage.validationFailed,
    };
    final errorStages = {
      WordAudioReleaseJobStage.failed,
      WordAudioReleaseJobStage.unsupported,
    };
    final color = successStages.contains(job.stage)
        ? Colors.green
        : errorStages.contains(job.stage)
        ? Colors.red
        : warningStages.contains(job.stage)
        ? Colors.orange
        : theme.colorScheme.primary;
    final busy =
        job.isRunning || job.isLoadingCacheStatus || job.isCheckingServerStatus;
    final serverStatusRows = [
      (
        state: WordAudioServerListUploadState.uploaded,
        key: 'qwen3_example_audio_release_server_status_uploaded',
      ),
      (
        state: WordAudioServerListUploadState.notUploaded,
        key: 'qwen3_example_audio_release_server_status_not_uploaded',
      ),
      (
        state: WordAudioServerListUploadState.partiallyUploaded,
        key: 'qwen3_example_audio_release_server_status_partial',
      ),
      (
        state: WordAudioServerListUploadState.unavailable,
        key: 'qwen3_example_audio_release_server_status_unavailable',
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.get('qwen3_example_audio_release_title', lang),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: busy || job.isLoadingLists
                      ? null
                      : () async {
                          final controller = ref.read(
                            qwen3ExampleAudioReleaseJobProvider.notifier,
                          );
                          await controller.refreshLists();
                          await controller.refreshCacheStatuses();
                          await controller.loadLatestPackage();
                        },
                  icon: job.isLoadingLists || job.isLoadingCacheStatus
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 16),
                  label: Text(AppStrings.get('refresh', lang)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.get('qwen3_example_audio_release_desc', lang),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.get('qwen3_example_audio_release_list_label', lang),
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: busy || job.isLoadingLists || job.lists.isEmpty
                    ? null
                    : () => _chooseQwen3ExampleReleaseLists(
                        lang,
                        job.lists,
                        cacheStatuses,
                        job.serverListStatuses,
                      ),
                icon: const Icon(Icons.playlist_add_check, size: 18),
                label: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _qwen3ExampleReleaseSelectionLabel(lang, selected),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            if (job.lists.isEmpty && !job.isLoadingLists) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.get('qwen3_example_audio_release_no_lists', lang),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                ),
              ),
            ],
            if (job.cacheStatusError != null) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.get(
                  'qwen3_example_audio_release_cache_status_failed',
                  lang,
                  params: {'msg': job.cacheStatusError!},
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                ),
              ),
            ] else if (cacheStatuses.isNotEmpty &&
                fullyCachedListIds.length == job.lists.length &&
                !job.isLoadingCacheStatus) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.get(
                  'qwen3_example_audio_release_all_lists_cached',
                  lang,
                ),
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.green),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud_outlined, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppStrings.get(
                            'qwen3_example_audio_release_server_status_title',
                            lang,
                          ),
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: busy || job.isLoadingLists
                            ? null
                            : () => ref
                                  .read(
                                    qwen3ExampleAudioReleaseJobProvider
                                        .notifier,
                                  )
                                  .refreshServerStatuses(
                                    fullyCachedListIds: fullyCachedListIds,
                                  ),
                        icon: job.isCheckingServerStatus
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh, size: 16),
                        label: Text(
                          AppStrings.get(
                            job.serverListStatuses.isEmpty
                                ? 'qwen3_example_audio_release_check_server_status'
                                : 'qwen3_example_audio_release_refresh_server_status',
                            lang,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (job.isCheckingServerStatus) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: job.serverStatusTotalWords == 0
                          ? null
                          : job.serverStatusCheckedWords /
                                job.serverStatusTotalWords,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.get(
                        'qwen3_example_audio_release_server_status_progress',
                        lang,
                        params: {
                          'done': job.serverStatusCheckedWords.toString(),
                          'total': job.serverStatusTotalWords.toString(),
                        },
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ] else if (job.exampleServerStatusFailure != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _qwen3ExampleReleaseServerFailureText(
                        lang,
                        job.exampleServerStatusFailure!,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                      ),
                    ),
                  ] else if (fullyCachedListIds.isEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.get(
                        'qwen3_example_audio_release_server_status_no_cached',
                        lang,
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ] else if (job.serverListStatuses.isEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.get(
                        'qwen3_example_audio_release_server_status_not_checked',
                        lang,
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ] else ...[
                    const SizedBox(height: 6),
                    for (final row in serverStatusRows)
                      if (_serverStatusListNumbers(job, row.state).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            AppStrings.get(
                              row.key,
                              lang,
                              params: {
                                'lists': _compactWordAudioReleaseListNumbers(
                                  _serverStatusListNumbers(job, row.state),
                                ),
                              },
                            ),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                  ],
                ],
              ),
            ),
            if (plan != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get(
                        'qwen3_example_audio_release_plan_summary',
                        lang,
                        params: {
                          'lists': _qwen3ExampleReleaseSelectedListsText(
                            lang,
                            plan.listNumbers,
                          ),
                          'total': plan.totalWords.toString(),
                          'reusable': plan.reusableWords.toString(),
                          'pending': plan.normalCalls.toString(),
                        },
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.get(
                        'word_audio_release_call_summary',
                        lang,
                        params: {
                          'calls': plan.normalCalls.toString(),
                          'attempts': plan.maxAttempts.toString(),
                        },
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: busy || job.isLoadingLists || selected.isEmpty
                      ? null
                      : () => _confirmQwen3ExampleRelease(lang, publish: true),
                  icon: const Icon(Icons.rocket_launch, size: 18),
                  label: Text(
                    AppStrings.get('word_audio_release_generate_publish', lang),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: busy || job.isLoadingLists || selected.isEmpty
                      ? null
                      : () => _confirmQwen3ExampleRelease(lang, publish: false),
                  icon: const Icon(Icons.inventory_2_outlined, size: 18),
                  label: Text(
                    AppStrings.get('word_audio_release_generate_only', lang),
                  ),
                ),
                if (job.canCancel)
                  OutlinedButton.icon(
                    onPressed: job.cancelRequested
                        ? null
                        : () => ref
                              .read(
                                qwen3ExampleAudioReleaseJobProvider.notifier,
                              )
                              .cancel(),
                    icon: const Icon(Icons.stop_circle_outlined, size: 18),
                    label: Text(AppStrings.get('cancel', lang)),
                  ),
              ],
            ),
            if (job.package != null) ...[
              const SizedBox(height: 12),
              Text(
                AppStrings.get(
                  'qwen3_example_audio_release_package_ready',
                  lang,
                  params: {'count': job.package!.expectedCount.toString()},
                ),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: busy ? null : _verifyQwen3ExampleRelease,
                    icon: const Icon(Icons.verified_outlined, size: 18),
                    label: Text(
                      AppStrings.get('word_audio_release_verify_server', lang),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: busy ? null : _republishQwen3ExampleRelease,
                    icon: const Icon(Icons.publish_outlined, size: 18),
                    label: Text(
                      AppStrings.get('word_audio_release_republish', lang),
                    ),
                  ),
                ],
              ),
            ],
            if (job.stage ==
                WordAudioReleaseJobStage.interactiveSudoRequired) ...[
              const SizedBox(height: 12),
              Text(
                AppStrings.get('word_audio_release_sudo_required', lang),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: busy ? null : _openInteractiveQwen3ExamplePublisher,
                icon: const Icon(Icons.terminal_outlined, size: 18),
                label: Text(
                  AppStrings.get('word_audio_release_open_interactive', lang),
                ),
              ),
            ],
            if (job.stage ==
                WordAudioReleaseJobStage.interactivePublisherOpened) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.get('word_audio_release_interactive_opened', lang),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                ),
              ),
            ],
            if (job.stage != WordAudioReleaseJobStage.idle) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          busy
                              ? Icons.hourglass_top_outlined
                              : Icons.info_outline,
                          color: color,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _qwen3ExampleReleaseStatusText(job, lang),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    if (job.progress != null && busy) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: job.progress!.total == 0
                            ? null
                            : job.progress!.done / job.progress!.total,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.get(
                          'tts_precache_current',
                          lang,
                          params: {
                            'list': job.progress!.currentListName,
                            'word': job.progress!.currentText,
                          },
                        ),
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (job.synthesis != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.get(
                          'tts_precache_counts',
                          lang,
                          params: {
                            'success': job.synthesis!.success.toString(),
                            'skipped': job.synthesis!.skipped.toString(),
                            'failed': job.synthesis!.failed.toString(),
                          },
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.get(
                          'tts_precache_usage',
                          lang,
                          params: {
                            'calls': job.synthesis!.apiCalls.toString(),
                            'chars': job.synthesis!.chargedCharacters
                                .toString(),
                            'bytes': _formatBytes(job.synthesis!.audioBytes),
                          },
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (job.logs.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.get('word_audio_release_log_title', lang),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              ...job.logs.reversed
                  .take(4)
                  .map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(line, style: theme.textTheme.bodySmall),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tencentWeWinnyExampleAudioReleaseCard(
    ThemeData theme,
    String lang,
    WordAudioReleaseJobState job,
  ) {
    final credentialPresence =
        TencentTtsAdapter.environmentCredentialPresence();
    final credentialsReady =
        credentialPresence[TencentTtsAdapter.secretIdEnvironmentKey] == true &&
        credentialPresence[TencentTtsAdapter.secretKeyEnvironmentKey] == true;
    final cacheStatuses = job.localListStatuses;
    final fullyCachedListIds = {
      for (final status in cacheStatuses.values)
        if (status.isComplete) status.listId,
    };
    final selected = _selectedTencentWeWinnyExampleReleaseLists(job);
    final plan = _wordAudioReleasePlanMatchesSelection(job.plan, selected)
        ? job.plan
        : null;
    final successStages = {
      WordAudioReleaseJobStage.generated,
      WordAudioReleaseJobStage.published,
      WordAudioReleaseJobStage.verified,
    };
    final warningStages = {
      WordAudioReleaseJobStage.interactiveSudoRequired,
      WordAudioReleaseJobStage.cancelled,
      WordAudioReleaseJobStage.synthesisFailed,
      WordAudioReleaseJobStage.validationFailed,
    };
    final errorStages = {
      WordAudioReleaseJobStage.failed,
      WordAudioReleaseJobStage.unsupported,
    };
    final color = successStages.contains(job.stage)
        ? Colors.green
        : errorStages.contains(job.stage)
        ? Colors.red
        : warningStages.contains(job.stage)
        ? Colors.orange
        : theme.colorScheme.primary;
    final busy =
        job.isRunning || job.isLoadingCacheStatus || job.isCheckingServerStatus;
    final serverStatusRows = [
      (
        state: WordAudioServerListUploadState.uploaded,
        key: 'tencent_wewinny_example_audio_release_server_status_uploaded',
      ),
      (
        state: WordAudioServerListUploadState.notUploaded,
        key: 'tencent_wewinny_example_audio_release_server_status_not_uploaded',
      ),
      (
        state: WordAudioServerListUploadState.partiallyUploaded,
        key: 'tencent_wewinny_example_audio_release_server_status_partial',
      ),
      (
        state: WordAudioServerListUploadState.unavailable,
        key: 'tencent_wewinny_example_audio_release_server_status_unavailable',
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.get(
                      'tencent_wewinny_example_audio_release_title',
                      lang,
                    ),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: busy || job.isLoadingLists
                      ? null
                      : () async {
                          final controller = ref.read(
                            tencentWeWinnyExampleAudioReleaseJobProvider
                                .notifier,
                          );
                          await controller.refreshLists();
                          await controller.refreshCacheStatuses();
                          await controller.loadLatestPackage();
                        },
                  icon: job.isLoadingLists || job.isLoadingCacheStatus
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 16),
                  label: Text(AppStrings.get('refresh', lang)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.get(
                'tencent_wewinny_example_audio_release_desc',
                lang,
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (credentialsReady ? Colors.green : Colors.orange)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    credentialsReady
                        ? Icons.verified_user_outlined
                        : Icons.warning_amber_outlined,
                    size: 18,
                    color: credentialsReady ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.get(
                        credentialsReady
                            ? 'tencent_wewinny_example_audio_release_credentials_ready'
                            : 'tencent_wewinny_example_audio_release_credentials_missing',
                        lang,
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.get(
                'tencent_wewinny_example_audio_release_list_label',
                lang,
              ),
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: busy || job.isLoadingLists || job.lists.isEmpty
                    ? null
                    : () => _chooseTencentWeWinnyExampleReleaseLists(
                        lang,
                        job.lists,
                        cacheStatuses,
                        job.serverListStatuses,
                      ),
                icon: const Icon(Icons.playlist_add_check, size: 18),
                label: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _tencentWeWinnyExampleReleaseSelectionLabel(lang, selected),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            if (job.lists.isEmpty && !job.isLoadingLists) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.get(
                  'tencent_wewinny_example_audio_release_no_lists',
                  lang,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                ),
              ),
            ],
            if (job.cacheStatusError != null) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.get(
                  'tencent_wewinny_example_audio_release_cache_status_failed',
                  lang,
                  params: {'msg': job.cacheStatusError!},
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                ),
              ),
            ] else if (cacheStatuses.isNotEmpty &&
                fullyCachedListIds.length == job.lists.length &&
                !job.isLoadingCacheStatus) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.get(
                  'tencent_wewinny_example_audio_release_all_lists_cached',
                  lang,
                ),
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.green),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud_outlined, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppStrings.get(
                            'tencent_wewinny_example_audio_release_server_status_title',
                            lang,
                          ),
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: busy || job.isLoadingLists
                            ? null
                            : () => ref
                                  .read(
                                    tencentWeWinnyExampleAudioReleaseJobProvider
                                        .notifier,
                                  )
                                  .refreshServerStatuses(
                                    fullyCachedListIds: fullyCachedListIds,
                                  ),
                        icon: job.isCheckingServerStatus
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh, size: 16),
                        label: Text(
                          AppStrings.get(
                            job.serverListStatuses.isEmpty
                                ? 'tencent_wewinny_example_audio_release_check_server_status'
                                : 'tencent_wewinny_example_audio_release_refresh_server_status',
                            lang,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (job.isCheckingServerStatus) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: job.serverStatusTotalWords == 0
                          ? null
                          : job.serverStatusCheckedWords /
                                job.serverStatusTotalWords,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.get(
                        'tencent_wewinny_example_audio_release_server_status_progress',
                        lang,
                        params: {
                          'done': job.serverStatusCheckedWords.toString(),
                          'total': job.serverStatusTotalWords.toString(),
                        },
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ] else if (job.exampleServerStatusFailure != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _tencentWeWinnyExampleReleaseServerFailureText(
                        lang,
                        job.exampleServerStatusFailure!,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                      ),
                    ),
                  ] else if (fullyCachedListIds.isEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.get(
                        'tencent_wewinny_example_audio_release_server_status_no_cached',
                        lang,
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ] else if (job.serverListStatuses.isEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.get(
                        'tencent_wewinny_example_audio_release_server_status_not_checked',
                        lang,
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ] else ...[
                    const SizedBox(height: 6),
                    for (final row in serverStatusRows)
                      if (_serverStatusListNumbers(job, row.state).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            AppStrings.get(
                              row.key,
                              lang,
                              params: {
                                'lists': _compactWordAudioReleaseListNumbers(
                                  _serverStatusListNumbers(job, row.state),
                                ),
                              },
                            ),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                  ],
                ],
              ),
            ),
            if (plan != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get(
                        'tencent_wewinny_example_audio_release_plan_summary',
                        lang,
                        params: {
                          'lists':
                              _tencentWeWinnyExampleReleaseSelectedListsText(
                                lang,
                                plan.listNumbers,
                              ),
                          'total': plan.totalWords.toString(),
                          'reusable': plan.reusableWords.toString(),
                          'pending': plan.normalCalls.toString(),
                        },
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.get(
                        'word_audio_release_call_summary',
                        lang,
                        params: {
                          'calls': plan.normalCalls.toString(),
                          'attempts': plan.maxAttempts.toString(),
                        },
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: busy || job.isLoadingLists || selected.isEmpty
                      ? null
                      : () => _confirmTencentWeWinnyExampleRelease(
                          lang,
                          publish: true,
                        ),
                  icon: const Icon(Icons.rocket_launch, size: 18),
                  label: Text(
                    AppStrings.get('word_audio_release_generate_publish', lang),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: busy || job.isLoadingLists || selected.isEmpty
                      ? null
                      : () => _confirmTencentWeWinnyExampleRelease(
                          lang,
                          publish: false,
                        ),
                  icon: const Icon(Icons.inventory_2_outlined, size: 18),
                  label: Text(
                    AppStrings.get('word_audio_release_generate_only', lang),
                  ),
                ),
                if (job.canCancel)
                  OutlinedButton.icon(
                    onPressed: job.cancelRequested
                        ? null
                        : () => ref
                              .read(
                                tencentWeWinnyExampleAudioReleaseJobProvider
                                    .notifier,
                              )
                              .cancel(),
                    icon: const Icon(Icons.stop_circle_outlined, size: 18),
                    label: Text(AppStrings.get('cancel', lang)),
                  ),
              ],
            ),
            if (job.package != null) ...[
              const SizedBox(height: 12),
              Text(
                AppStrings.get(
                  'tencent_wewinny_example_audio_release_package_ready',
                  lang,
                  params: {'count': job.package!.expectedCount.toString()},
                ),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: busy
                        ? null
                        : _verifyTencentWeWinnyExampleRelease,
                    icon: const Icon(Icons.verified_outlined, size: 18),
                    label: Text(
                      AppStrings.get('word_audio_release_verify_server', lang),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: busy
                        ? null
                        : _republishTencentWeWinnyExampleRelease,
                    icon: const Icon(Icons.publish_outlined, size: 18),
                    label: Text(
                      AppStrings.get('word_audio_release_republish', lang),
                    ),
                  ),
                ],
              ),
            ],
            if (job.stage ==
                WordAudioReleaseJobStage.interactiveSudoRequired) ...[
              const SizedBox(height: 12),
              Text(
                AppStrings.get('word_audio_release_sudo_required', lang),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: busy
                    ? null
                    : _openInteractiveTencentWeWinnyExamplePublisher,
                icon: const Icon(Icons.terminal_outlined, size: 18),
                label: Text(
                  AppStrings.get('word_audio_release_open_interactive', lang),
                ),
              ),
            ],
            if (job.stage ==
                WordAudioReleaseJobStage.interactivePublisherOpened) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.get('word_audio_release_interactive_opened', lang),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                ),
              ),
            ],
            if (job.stage != WordAudioReleaseJobStage.idle) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          busy
                              ? Icons.hourglass_top_outlined
                              : Icons.info_outline,
                          color: color,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _tencentWeWinnyExampleReleaseStatusText(job, lang),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    if (job.progress != null && busy) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: job.progress!.total == 0
                            ? null
                            : job.progress!.done / job.progress!.total,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.get(
                          'tts_precache_current',
                          lang,
                          params: {
                            'list': job.progress!.currentListName,
                            'word': job.progress!.currentText,
                          },
                        ),
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (job.synthesis != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.get(
                          'tts_precache_counts',
                          lang,
                          params: {
                            'success': job.synthesis!.success.toString(),
                            'skipped': job.synthesis!.skipped.toString(),
                            'failed': job.synthesis!.failed.toString(),
                          },
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.get(
                          'tts_precache_usage',
                          lang,
                          params: {
                            'calls': job.synthesis!.apiCalls.toString(),
                            'chars': job.synthesis!.chargedCharacters
                                .toString(),
                            'bytes': _formatBytes(job.synthesis!.audioBytes),
                          },
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (job.logs.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.get('word_audio_release_log_title', lang),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              ...job.logs.reversed
                  .take(4)
                  .map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(line, style: theme.textTheme.bodySmall),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  String _tencentWeWinnyExampleReleaseStatusText(
    WordAudioReleaseJobState job,
    String lang,
  ) {
    return switch (job.stage) {
      WordAudioReleaseJobStage.synthesisFailed => AppStrings.get(
        'tencent_wewinny_example_audio_release_synthesis_failed',
        lang,
      ),
      WordAudioReleaseJobStage.validationFailed => AppStrings.get(
        'tencent_wewinny_example_audio_release_validation_failed',
        lang,
      ),
      _ =>
        job.error != null
            ? AppStrings.get(
                'tencent_wewinny_example_audio_release_error_detail',
                lang,
                params: {'msg': job.error!},
              )
            : _wordAudioReleaseStatusText(job, lang),
    };
  }

  String _qwen3ExampleReleaseStatusText(
    WordAudioReleaseJobState job,
    String lang,
  ) {
    return switch (job.stage) {
      WordAudioReleaseJobStage.synthesisFailed => AppStrings.get(
        'qwen3_example_audio_release_synthesis_failed',
        lang,
      ),
      WordAudioReleaseJobStage.validationFailed => AppStrings.get(
        'qwen3_example_audio_release_validation_failed',
        lang,
      ),
      _ =>
        job.error != null
            ? AppStrings.get(
                'qwen3_example_audio_release_error_detail',
                lang,
                params: {'msg': job.error!},
              )
            : _wordAudioReleaseStatusText(job, lang),
    };
  }

  String _wordAudioReleaseStatusText(
    WordAudioReleaseJobState job,
    String lang,
  ) {
    if (job.error != null) {
      return AppStrings.get(
        'word_audio_release_error_detail',
        lang,
        params: {'msg': job.error!},
      );
    }
    return switch (job.stage) {
      WordAudioReleaseJobStage.planning => AppStrings.get(
        'word_audio_release_stage_planning',
        lang,
      ),
      WordAudioReleaseJobStage.ready => AppStrings.get(
        'word_audio_release_stage_ready',
        lang,
      ),
      WordAudioReleaseJobStage.synthesizing => AppStrings.get(
        'word_audio_release_stage_synthesizing',
        lang,
      ),
      WordAudioReleaseJobStage.validating => AppStrings.get(
        'word_audio_release_stage_validating',
        lang,
      ),
      WordAudioReleaseJobStage.packaging => AppStrings.get(
        'word_audio_release_stage_packaging',
        lang,
      ),
      WordAudioReleaseJobStage.publishing => AppStrings.get(
        'word_audio_release_stage_publishing',
        lang,
      ),
      WordAudioReleaseJobStage.verifying => AppStrings.get(
        'word_audio_release_stage_verifying',
        lang,
      ),
      WordAudioReleaseJobStage.generated => AppStrings.get(
        'word_audio_release_generated',
        lang,
      ),
      WordAudioReleaseJobStage.published => AppStrings.get(
        'word_audio_release_published',
        lang,
      ),
      WordAudioReleaseJobStage.verified => AppStrings.get(
        'word_audio_release_verified',
        lang,
      ),
      WordAudioReleaseJobStage.interactiveSudoRequired => AppStrings.get(
        'word_audio_release_sudo_required',
        lang,
      ),
      WordAudioReleaseJobStage.interactivePublisherOpened => AppStrings.get(
        'word_audio_release_interactive_opened',
        lang,
      ),
      WordAudioReleaseJobStage.synthesisFailed => AppStrings.get(
        'word_audio_release_synthesis_failed',
        lang,
      ),
      WordAudioReleaseJobStage.validationFailed => AppStrings.get(
        'word_audio_release_validation_failed',
        lang,
      ),
      WordAudioReleaseJobStage.cancelled => AppStrings.get(
        'word_audio_release_cancelled',
        lang,
      ),
      WordAudioReleaseJobStage.unsupported => AppStrings.get(
        'word_audio_release_unsupported',
        lang,
      ),
      WordAudioReleaseJobStage.failed => AppStrings.get(
        'word_audio_release_failed',
        lang,
      ),
      WordAudioReleaseJobStage.idle => '',
    };
  }

  Widget _ttsCacheStatusCard(
    ThemeData theme,
    String lang,
    _TtsPreCacheJobState job, {
    required bool wordAudioReleaseRunning,
  }) {
    final ttsWorkRunning = job.isRunning || wordAudioReleaseRunning;
    final statuses = job.cacheStatuses;
    final completed = statuses.where((status) => status.isComplete).length;
    final failed = statuses.fold<int>(
      0,
      (sum, status) => sum + status.failures.length,
    );
    final totalWords = statuses.fold<int>(
      0,
      (sum, status) => sum + status.totalWords,
    );
    final cachedWords = statuses.fold<int>(
      0,
      (sum, status) => sum + status.cachedWords,
    );
    final visibleStatuses = statuses
        .where((status) => !status.isComplete)
        .take(30)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.get('tts_cache_status_title', lang),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: job.isLoadingStatus
                      ? null
                      : () => ref
                            .read(_ttsPreCacheJobProvider.notifier)
                            .refreshCacheStatus(lang),
                  icon: job.isLoadingStatus
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 16),
                  label: Text(AppStrings.get('refresh', lang)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (job.statusError != null)
              Text(
                job.statusError!,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
              )
            else if (statuses.isEmpty)
              Text(
                AppStrings.get('tts_cache_status_empty', lang),
                style: theme.textTheme.bodySmall,
              )
            else ...[
              Text(
                AppStrings.get(
                  'tts_cache_status_summary',
                  lang,
                  params: {
                    'doneLists': completed.toString(),
                    'totalLists': statuses.length.toString(),
                    'cachedWords': cachedWords.toString(),
                    'totalWords': totalWords.toString(),
                    'failed': failed.toString(),
                  },
                ),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: ttsWorkRunning
                    ? null
                    : () => _preCacheCet4Qwen(lang, onlyIncomplete: true),
                icon: const Icon(Icons.playlist_add_check, size: 18),
                label: Text(AppStrings.get('tts_cache_incomplete', lang)),
              ),
              const SizedBox(height: 8),
              if (visibleStatuses.isEmpty)
                Text(
                  AppStrings.get('tts_cache_all_done', lang),
                  style: theme.textTheme.bodySmall,
                )
              else
                ...visibleStatuses.map((status) {
                  final color = status.failures.isNotEmpty
                      ? Colors.orange
                      : theme.colorScheme.primary;
                  final icon = status.failures.isNotEmpty
                      ? Icons.warning_amber_outlined
                      : Icons.schedule;
                  final failedWords = status.failures
                      .take(3)
                      .map((failure) => failure.text)
                      .join(', ');
                  return Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, size: 18, color: color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.get(
                                  'tts_cache_list_status',
                                  lang,
                                  params: {
                                    'index': status.listIndex.toString(),
                                    'name': status.listName,
                                    'cached': status.cachedWords.toString(),
                                    'total': status.totalWords.toString(),
                                  },
                                ),
                                style: theme.textTheme.bodySmall,
                              ),
                              if (status.failures.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  AppStrings.get(
                                    'tts_cache_failed_words',
                                    lang,
                                    params: {'words': failedWords},
                                  ),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: ttsWorkRunning
                              ? null
                              : () => _preCacheCet4Qwen(
                                  lang,
                                  targetListId: status.listId,
                                ),
                          child: Text(
                            AppStrings.get('tts_cache_this_list', lang),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _ttsCacheHealthCard(
    ThemeData theme,
    String lang,
    _TtsCacheMaintenanceState state, {
    required bool wordAudioReleaseRunning,
  }) {
    final report = state.report;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.health_and_safety_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.get('tts_cache_health_title', lang),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: state.isChecking
                      ? null
                      : () => ref
                            .read(_ttsCacheMaintenanceProvider.notifier)
                            .refreshCacheHealth(),
                  icon: state.isChecking
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search, size: 16),
                  label: Text(AppStrings.get('tts_cache_health_check', lang)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (state.error != null)
              Text(
                state.error!,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
              )
            else if (report == null)
              Text(
                AppStrings.get('tts_cache_health_empty', lang),
                style: theme.textTheme.bodySmall,
              )
            else ...[
              Text(
                AppStrings.get(
                  'tts_cache_health_summary',
                  lang,
                  params: {
                    'records': report.recordCount.toString(),
                    'healthy': report.healthyRecords.toString(),
                    'missing': report.missingFiles.toString(),
                    'empty': report.emptyFiles.toString(),
                    'orphan': report.orphanFiles.toString(),
                    'expiredRecords': report.expiredRecords.toString(),
                  },
                ),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Text(
                report.isHealthy
                    ? AppStrings.get('tts_cache_health_ok', lang)
                    : AppStrings.get('tts_cache_health_issue', lang),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: report.isHealthy ? Colors.green : Colors.orange,
                ),
              ),
              if (report.hasIssues) ...[
                const SizedBox(height: 6),
                Text(
                  AppStrings.get(
                    'tts_cache_cleanup_desc',
                    lang,
                    params: {'days': report.maxAge.inDays.toString()},
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: state.isCleaning || wordAudioReleaseRunning
                      ? null
                      : () => ref
                            .read(_ttsCacheMaintenanceProvider.notifier)
                            .cleanExpiredCache(lang),
                  icon: state.isCleaning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_sweep_outlined, size: 18),
                  label: Text(AppStrings.get('tts_cache_cleanup', lang)),
                ),
              ),
              if (state.cleanupResult != null) ...[
                const SizedBox(height: 8),
                Text(
                  AppStrings.get(
                    'tts_cache_cleanup_done',
                    lang,
                    params: {
                      'files': state.cleanupResult!.removedFiles.toString(),
                      'records': state.cleanupResult!.removedRecords.toString(),
                    },
                  ),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _ttsCacheLimitCard(
    ThemeData theme,
    String lang,
    _TtsCacheMaintenanceState state,
    _TtsPreCacheJobState job, {
    required bool wordAudioReleaseRunning,
  }) {
    final configuredLimitMb = _ttsCacheLimitMb();
    final limitLabel = configuredLimitMb == 0
        ? AppStrings.get('tts_cache_limit_unlimited', lang)
        : '${configuredLimitMb ?? TtsService.defaultQwenCacheLimitMb} MB';
    final report = state.report;
    final result = state.limitResult;
    final isBusy =
        state.isApplyingLimit || job.isRunning || wordAudioReleaseRunning;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storage_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.get('tts_cache_limit_title', lang),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.get('tts_cache_limit_desc', lang),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ttsCacheLimitMbController,
              enabled: !isBusy,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: _saveTtsCacheLimitMb,
              decoration: InputDecoration(
                labelText: AppStrings.get('tts_cache_limit_label', lang),
                hintText: AppStrings.get('tts_cache_limit_hint', lang),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (report != null)
              Text(
                AppStrings.get(
                  'tts_cache_limit_summary',
                  lang,
                  params: {
                    'used': _formatBytes(report.totalBytes),
                    'limit': limitLabel,
                  },
                ),
                style: theme.textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isBusy ? null : () => _applyTtsCacheLimit(lang),
                icon: state.isApplyingLimit
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cleaning_services_outlined, size: 18),
                label: Text(AppStrings.get('tts_cache_limit_apply', lang)),
              ),
            ),
            if (result != null) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.get(
                  'tts_cache_limit_done',
                  lang,
                  params: {
                    'files': result.removedFiles.toString(),
                    'bytes': _formatBytes(result.removedBytes),
                    'used': _formatBytes(result.afterBytes),
                  },
                ),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  String _formatPreCacheFailure(TtsPreCacheFailure failure, String lang) {
    final message = switch (failure.audioValidationFailure) {
      QwenWordAudioValidationFailure.invalidWav => AppStrings.get(
        'tts_precache_audio_invalid_wav',
        lang,
      ),
      QwenWordAudioValidationFailure.unexpectedFormat => AppStrings.get(
        'tts_precache_audio_unexpected_format',
        lang,
      ),
      QwenWordAudioValidationFailure.tooShort => AppStrings.get(
        'tts_precache_audio_too_short',
        lang,
      ),
      QwenWordAudioValidationFailure.silent => AppStrings.get(
        'tts_precache_audio_silent',
        lang,
      ),
      null => failure.message,
    };
    return '${failure.text}: $message';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = ref.watch(languageProvider);
    final preCacheJob = ref.watch(_ttsPreCacheJobProvider);
    final wordAudioReleaseJob = ref.watch(wordAudioReleaseJobProvider);
    final qwen3ExampleAudioReleaseJob = ref.watch(
      qwen3ExampleAudioReleaseJobProvider,
    );
    final tencentWeWinnyExampleAudioReleaseJob = ref.watch(
      tencentWeWinnyExampleAudioReleaseJobProvider,
    );
    final cacheMaintenance = ref.watch(_ttsCacheMaintenanceProvider);
    final usageSummary = ref.watch(_ttsUsageSummaryProvider);
    final aiUsageSummary = ref.watch(_aiUsageSummaryProvider);
    final recentUsageRecords = ref.watch(_ttsRecentUsageRecordsProvider);
    final preCacheListCount = _ttsPreCacheListCount();
    final anyWordAudioGenerationRunning =
        preCacheJob.isRunning ||
        wordAudioReleaseJob.isRunning ||
        qwen3ExampleAudioReleaseJob.isRunning ||
        tencentWeWinnyExampleAudioReleaseJob.isRunning;

    if (!_loaded) {
      _loadSettings();
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('settings', lang))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader(
            AppStrings.get('ai_provider_section', lang),
            Icons.psychology_outlined,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedProvider,
                decoration: InputDecoration(
                  labelText: AppStrings.get('provider_label', lang),
                  border: InputBorder.none,
                ),
                items: AiProviderType.values.map((t) {
                  return DropdownMenuItem(
                    value: t.name,
                    child: Text(t.displayName),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) _saveProvider(v);
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        AiProviderType.fromString(
                          _selectedProvider ?? 'claude',
                        ).displayName,
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const Divider(),
                  TextField(
                    controller: _apiKeyController,
                    onChanged: _saveApiKey,
                    obscureText: !_apiKeyVisible,
                    decoration: InputDecoration(
                      labelText: AppStrings.get('api_key_label', lang),
                      hintText: 'sk-xxxxxxxxxxxxxxxxxxxxxxxx',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _apiKeyVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _apiKeyVisible = !_apiKeyVisible),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _aiBaseUrlController,
                    onChanged: _saveAiBaseUrl,
                    decoration: InputDecoration(
                      labelText: AppStrings.get('tts_base_url_label', lang),
                      hintText: _aiDefaultBaseUrl(),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _aiModelController,
                    onChanged: _saveAiModel,
                    decoration: InputDecoration(
                      labelText: AppStrings.get('tts_model_label', lang),
                      hintText: _aiDefaultModel(),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _saveAiConfig(context, lang),
                          icon: const Icon(Icons.save, size: 18),
                          label: Text(AppStrings.get('save', lang)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isTesting ? null : _testConnection,
                          icon: _isTesting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.play_arrow, size: 18),
                          label: Text(
                            _isTesting
                                ? AppStrings.get('testing', lang)
                                : AppStrings.get('test_btn', lang),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_testResult != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _testResult == 'success'
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _testResult == 'success'
                                ? Icons.check_circle
                                : Icons.error_outline,
                            color: _testResult == 'success'
                                ? Colors.green
                                : Colors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _testResult == 'success'
                                  ? AppStrings.get('connection_success', lang)
                                  : _testResult!,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _aiUsageStatsCard(theme, lang, aiUsageSummary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.quiz_outlined),
              title: Text(
                AppStrings.get('ai_collocation_option_validation', lang),
              ),
              subtitle: Text(
                AppStrings.get('ai_collocation_option_validation_desc', lang),
              ),
              value: _aiCollocationOptionValidationEnabled,
              onChanged: _saveAiCollocationOptionValidationEnabled,
            ),
          ),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.psychology_outlined),
              title: Text(AppStrings.get('ai_thinking_enabled', lang)),
              subtitle: Text(AppStrings.get('ai_thinking_enabled_desc', lang)),
              value: _aiThinkingEnabled,
              onChanged: _saveAiThinkingEnabled,
            ),
          ),
          const SizedBox(height: 16),
          _languageToolSettingsCard(theme, lang),
          const SizedBox(height: 16),
          _sectionHeader(AppStrings.get('practice_section', lang), Icons.tune),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.speed),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppStrings.get('default_pass_threshold', lang),
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        '${(_passThreshold * 100).round()}%',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _passThreshold,
                    min: AppConstants.minPassThreshold,
                    max: AppConstants.maxPassThreshold,
                    divisions: 10,
                    onChanged: _savePassThreshold,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '50%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      Text(
                        '100%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // ─── Theme Mode ────────────────────────────────────────────
          _sectionHeader(
            AppStrings.get('appearance_section', lang),
            Icons.palette_outlined,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: DropdownButtonFormField<String>(
                initialValue: _themeMode,
                decoration: InputDecoration(
                  labelText: AppStrings.get('theme_label', lang),
                  border: InputBorder.none,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'system',
                    child: Text(AppStrings.get('system_default', lang)),
                  ),
                  DropdownMenuItem(
                    value: 'light',
                    child: Text(AppStrings.get('light', lang)),
                  ),
                  DropdownMenuItem(
                    value: 'dark',
                    child: Text(AppStrings.get('dark', lang)),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) _saveThemeMode(v);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // ─── Language ──────────────────────────────────────────────
          _sectionHeader(
            AppStrings.get('language_section', lang),
            Icons.language,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: DropdownButtonFormField<String>(
                initialValue: _language,
                decoration: InputDecoration(
                  labelText: AppStrings.get('language_label', lang),
                  border: InputBorder.none,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'en',
                    child: Text(AppStrings.get('english_lang', lang)),
                  ),
                  DropdownMenuItem(
                    value: 'zh',
                    child: Text(AppStrings.get('chinese_lang', lang)),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) _saveLanguage(v);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // ─── TTS Provider ───────────────────────────────────────────
          _sectionHeader(
            AppStrings.get('tts_section', lang),
            Icons.record_voice_over_outlined,
          ),
          const SizedBox(height: 8),
          _wordAudioPlaybackCard(theme, lang),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 8, bottom: 8),
                    child: Text(
                      AppStrings.get('tts_engine_label', lang),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ttsProviderChip(
                        value: 'qwen',
                        label: AppStrings.get('tts_qwen', lang),
                      ),
                      _ttsProviderChip(
                        value: TtsService.qwen3FlashKaterinaProvider,
                        label: AppStrings.get('tts_qwen3_flash_katerina', lang),
                      ),
                      _ttsProviderChip(
                        value: 'doubao',
                        label: AppStrings.get('tts_doubao', lang),
                      ),
                      _ttsProviderChip(
                        value: 'openai',
                        label: AppStrings.get('tts_openai', lang),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ─── Cloud TTS configuration (Qwen / OpenAI / Doubao) ────────────
          if (_ttsProvider == 'qwen' ||
              _ttsProvider == TtsService.qwen3FlashKaterinaProvider ||
              _ttsProvider == 'openai' ||
              _ttsProvider == 'doubao') ...[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cloud_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _ttsProfileTitle(lang),
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const Divider(),
                    TextField(
                      controller: _ttsApiKeyController,
                      onChanged: _saveTtsApiKey,
                      obscureText: !_ttsApiKeyVisible,
                      decoration: InputDecoration(
                        labelText: AppStrings.get('tts_api_key_label', lang),
                        hintText: 'sk-xxxxxxxxxxxxxxxxxxxxxxxx',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _ttsApiKeyVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _ttsApiKeyVisible = !_ttsApiKeyVisible,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ttsBaseUrlController,
                      onChanged: _saveTtsBaseUrl,
                      decoration: InputDecoration(
                        labelText: AppStrings.get('tts_base_url_label', lang),
                        hintText: _ttsBaseUrlHint(),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ttsModelController,
                      onChanged: _saveTtsModel,
                      readOnly: _isQwenTtsProfile(_ttsProvider),
                      decoration: InputDecoration(
                        labelText: AppStrings.get('tts_model_label', lang),
                        hintText: _ttsModelHint(),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ttsVoiceController,
                      onChanged: _saveTtsVoice,
                      readOnly: _isQwenTtsProfile(_ttsProvider),
                      decoration: InputDecoration(
                        labelText: AppStrings.get('tts_voice_label', lang),
                        hintText: _ttsVoiceHint(),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    if (_isQwenTtsProfile(_ttsProvider) ||
                        _ttsProvider == 'doubao') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _ttsAppIdController,
                        onChanged: _saveTtsAppId,
                        decoration: InputDecoration(
                          labelText: AppStrings.get(
                            _isQwenTtsProfile(_ttsProvider)
                                ? 'tts_workspace_id_label'
                                : 'tts_resource_id_label',
                            lang,
                          ),
                          hintText: _isQwenTtsProfile(_ttsProvider)
                              ? 'ws-xxxxxxxxxxxxxxxx'
                              : 'seed-tts-2.0',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                    if (_ttsProvider == 'qwen') ...[
                      const SizedBox(height: 10),
                      Text(
                        AppStrings.get('tts_qwen_word_audio_profile', lang),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.get(
                          'tts_qwen_word_audio_profile_desc',
                          lang,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                    if (_isQwenTtsProfile(_ttsProvider)) ...[
                      const SizedBox(height: 12),
                      _qwenTtsProfileSummary(theme, lang),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _saveTtsCloudConfig(context, lang),
                            icon: const Icon(Icons.save, size: 18),
                            label: Text(AppStrings.get('save', lang)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isTtsTesting
                                ? null
                                : () => _testTts(context, lang),
                            icon: _isTtsTesting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.play_arrow, size: 18),
                            label: Text(
                              _isTtsTesting
                                  ? AppStrings.get('testing', lang)
                                  : AppStrings.get('test_btn', lang),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_ttsTestResult != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _ttsTestResult == 'success'
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _ttsTestResult == 'success'
                                  ? Icons.check_circle
                                  : Icons.error_outline,
                              color: _ttsTestResult == 'success'
                                  ? Colors.green
                                  : Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _ttsTestResult == 'success'
                                    ? AppStrings.get('tts_test_success', lang)
                                    : _ttsTestResult!,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_ttsProvider == 'doubao') ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _ttsDoubaoLiveApiEnabled,
                        onChanged: _saveDoubaoLiveApiEnabled,
                        title: Text(
                          AppStrings.get('tts_doubao_live_api_enabled', lang),
                          style: theme.textTheme.bodyMedium,
                        ),
                        subtitle: Text(
                          AppStrings.get(
                            'tts_doubao_live_api_enabled_desc',
                            lang,
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                    if (_ttsProvider == 'qwen') ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      _ttsUsageStatsCard(
                        theme,
                        lang,
                        usageSummary,
                        recentUsageRecords,
                      ),
                      const SizedBox(height: 8),
                      _wordAudioRepairCard(
                        theme,
                        lang,
                        enabled: !anyWordAudioGenerationRunning,
                      ),
                      const SizedBox(height: 8),
                      _wordAudioReleaseCard(
                        theme,
                        lang,
                        wordAudioReleaseJob,
                        ttsPreCacheRunning: preCacheJob.isRunning,
                        cacheJob: preCacheJob,
                      ),
                      const SizedBox(height: 8),
                      _ttsCacheStatusCard(
                        theme,
                        lang,
                        preCacheJob,
                        wordAudioReleaseRunning: wordAudioReleaseJob.isRunning,
                      ),
                      const SizedBox(height: 8),
                      _ttsCacheLimitCard(
                        theme,
                        lang,
                        cacheMaintenance,
                        preCacheJob,
                        wordAudioReleaseRunning: wordAudioReleaseJob.isRunning,
                      ),
                      const SizedBox(height: 8),
                      _ttsCacheHealthCard(
                        theme,
                        lang,
                        cacheMaintenance,
                        wordAudioReleaseRunning: wordAudioReleaseJob.isRunning,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.get(
                          'tts_precache_hint',
                          lang,
                          params: {'count': preCacheListCount.toString()},
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _ttsPreCacheListCountController,
                        enabled: !anyWordAudioGenerationRunning,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: _saveTtsPreCacheListCount,
                        decoration: InputDecoration(
                          labelText: AppStrings.get(
                            'tts_precache_list_count_label',
                            lang,
                          ),
                          hintText: AppStrings.get(
                            'tts_precache_list_count_hint',
                            lang,
                          ),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: anyWordAudioGenerationRunning
                                  ? null
                                  : () => _preCacheCet4Qwen(lang),
                              icon: anyWordAudioGenerationRunning
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.download_for_offline,
                                      size: 18,
                                    ),
                              label: Text(
                                AppStrings.get(
                                  'tts_precache_cet4_n',
                                  lang,
                                  params: {
                                    'count': preCacheListCount.toString(),
                                  },
                                ),
                              ),
                            ),
                          ),
                          if (preCacheJob.isRunning) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: preCacheJob.cancelRequested
                                    ? null
                                    : () => ref
                                          .read(
                                            _ttsPreCacheJobProvider.notifier,
                                          )
                                          .cancel(),
                                icon: const Icon(
                                  Icons.stop_circle_outlined,
                                  size: 18,
                                ),
                                label: Text(
                                  AppStrings.get('tts_precache_cancel', lang),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (preCacheJob.error != null ||
                          preCacheJob.result != null ||
                          preCacheJob.progress != null) ...[
                        const SizedBox(height: 8),
                        _ttsPreCacheStatusCard(theme, lang, preCacheJob),
                      ],
                    ],
                    if (_ttsProvider ==
                        TtsService.qwen3FlashKaterinaProvider) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      _qwen3ExampleAudioReleaseCard(
                        theme,
                        lang,
                        qwen3ExampleAudioReleaseJob,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          _tencentWeWinnyExampleAudioReleaseCard(
            theme,
            lang,
            tencentWeWinnyExampleAudioReleaseJob,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _aiDefaultBaseUrl() {
    return switch (_selectedProvider) {
      'claude' => 'https://api.anthropic.com',
      'openai' => 'https://api.openai.com',
      'deepseek' => 'https://api.deepseek.com',
      'kimi' => 'https://api.moonshot.cn',
      'glm' => 'https://open.bigmodel.cn/api/paas/v4',
      _ => 'https://api.openai.com',
    };
  }

  String _aiDefaultModel() {
    return switch (_selectedProvider) {
      'claude' => 'claude-sonnet-4-6',
      'openai' => 'gpt-4o',
      'deepseek' => 'deepseek-flash',
      'kimi' => 'moonshot-v1-8k',
      'glm' => 'glm-4-flash',
      _ => 'gpt-4o',
    };
  }

  Widget _aiUsageStatsCard(
    ThemeData theme,
    String lang,
    AsyncValue<AiUsageSummary> usageSummary,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: usageSummary.when(
        data: (summary) {
          if (!summary.hasUsage) {
            return Text(
              AppStrings.get('ai_usage_no_records', lang),
              style: theme.textTheme.bodySmall,
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.get('ai_usage_title', lang),
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.get(
                  'ai_usage_last',
                  lang,
                  params: {
                    'provider': summary.lastProvider ?? '-',
                    'model': summary.lastModel ?? '-',
                    'input': summary.lastInputTokens.toString(),
                    'output': summary.lastOutputTokens.toString(),
                  },
                ),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.get(
                  'ai_usage_total',
                  lang,
                  params: {
                    'input': summary.totalInputTokens.toString(),
                    'output': summary.totalOutputTokens.toString(),
                  },
                ),
                style: theme.textTheme.bodySmall,
              ),
            ],
          );
        },
        loading: () => const SizedBox(
          height: 24,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (e, _) => Text(
          AppStrings.get(
            'ai_usage_load_failed',
            lang,
            params: {'msg': e.toString()},
          ),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ),
    );
  }

  Widget _languageToolSettingsCard(ThemeData theme, String lang) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.rule, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.get('language_tool_section', lang),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Switch(
                  value: _languageToolEnabled,
                  onChanged: _saveLanguageToolEnabled,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.get('language_tool_desc', lang),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _languageToolBaseUrlController,
              enabled: _languageToolEnabled,
              onSubmitted: _saveLanguageToolBaseUrl,
              onEditingComplete: () =>
                  _saveLanguageToolBaseUrl(_languageToolBaseUrlController.text),
              decoration: InputDecoration(
                labelText: AppStrings.get('language_tool_base_url', lang),
                hintText: LanguageToolClient.defaultBaseUrl,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: !_languageToolEnabled || _isLanguageToolTesting
                        ? null
                        : _testLanguageToolConnection,
                    icon: _isLanguageToolTesting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow, size: 18),
                    label: Text(
                      _isLanguageToolTesting
                          ? AppStrings.get('testing', lang)
                          : AppStrings.get('test_btn', lang),
                    ),
                  ),
                ),
              ],
            ),
            if (_languageToolTestResult != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _languageToolTestResult == 'success'
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _languageToolTestResult == 'success'
                          ? Icons.check_circle
                          : Icons.error_outline,
                      color: _languageToolTestResult == 'success'
                          ? Colors.green
                          : Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _languageToolTestResult == 'success'
                            ? AppStrings.get('language_tool_test_success', lang)
                            : _languageToolTestResult!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}
