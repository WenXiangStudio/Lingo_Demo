import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/services/tts_model_state.dart';
import '../../../core/services/tts_providers.dart';
import '../../../core/services/tts_service.dart';
import '../../../data/ai/ai_provider.dart';
import '../../../data/ai/ai_service.dart';
import '../../../data/database/app_database.dart';
import '../../../data/language_tool/language_tool_client.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/repositories.dart';

final _aiServiceProvider = Provider<AiService>((ref) {
  return AiService(ref.watch(settingsRepositoryProvider));
});

final _aiUsageSummaryProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(settingsRepositoryProvider).getAiUsageSummary();
});

final _ttsUsageSummaryProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(ttsRepositoryProvider).getUsageSummary(provider: 'doubao');
});

final _ttsRecentUsageRecordsProvider = FutureProvider.autoDispose((ref) {
  return ref
      .watch(ttsRepositoryProvider)
      .getRecentUsageRecords(provider: 'doubao', limit: 20);
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
  final TtsCacheHealthReport? report;
  final TtsCacheCleanupResult? cleanupResult;
  final String? error;

  const _TtsCacheMaintenanceState({
    this.isChecking = false,
    this.isCleaning = false,
    this.report,
    this.cleanupResult,
    this.error,
  });

  _TtsCacheMaintenanceState copyWith({
    bool? isChecking,
    bool? isCleaning,
    TtsCacheHealthReport? report,
    bool clearReport = false,
    TtsCacheCleanupResult? cleanupResult,
    bool clearCleanupResult = false,
    String? error,
    bool clearError = false,
  }) {
    return _TtsCacheMaintenanceState(
      isChecking: isChecking ?? this.isChecking,
      isCleaning: isCleaning ?? this.isCleaning,
      report: clearReport ? null : report ?? this.report,
      cleanupResult: clearCleanupResult
          ? null
          : cleanupResult ?? this.cleanupResult,
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
    if (state.isChecking || state.isCleaning) return;
    state = state.copyWith(isChecking: true, clearError: true);
    try {
      final report = await _ref
          .read(ttsServiceProvider)
          .inspectCacheHealth(provider: 'doubao', language: 'en');
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
    if (state.isCleaning || state.isChecking) return;
    state = state.copyWith(isCleaning: true, clearError: true);
    try {
      final result = await _ref
          .read(ttsServiceProvider)
          .cleanExpiredCache(provider: 'doubao', language: 'en');
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

  Future<void> startCet4Doubao({
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
            provider: 'doubao',
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
        .getCachedAudioPresence(allTexts, provider: 'doubao', lang: 'en');
    final cacheRecords = await _ref
        .read(ttsRepositoryProvider)
        .getCacheRecords(provider: 'doubao', language: 'en');
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
  double _ttsSpeed = 0.5;
  String _language = 'en';
  String _ttsProvider = 'sapi';
  bool _ttsDoubaoLiveApiEnabled = true;
  bool _aiCollocationOptionValidationEnabled = true;
  bool _languageToolEnabled = true;
  bool _isLanguageToolTesting = false;
  String? _languageToolTestResult;
  bool _loaded = false;

  static const _ttsPreCacheListCountKey = 'tts_doubao_precache_list_count';
  static const _ttsDoubaoLiveApiEnabledKey = 'tts_doubao_live_api_enabled';
  static const _defaultTtsPreCacheListCount = 30;

  static const _ttsProviderValues = {
    'supertonic',
    'qwen',
    'doubao',
    'sapi',
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
    final ttsSpeed = await settingsRepo.getDouble('tts_speed');
    final lang = await settingsRepo.getAppLanguage();
    final ttsProvider = await settingsRepo.getTtsProvider();
    final ttsNs =
        (ttsProvider != null &&
            ttsProvider != 'none' &&
            ttsProvider != 'sapi' &&
            ttsProvider != 'supertonic')
        ? ttsProvider
        : null;
    final ttsApiKey = ttsNs != null
        ? await settingsRepo.getString('tts_${ttsNs}_api_key')
        : null;
    final ttsBaseUrl = ttsNs != null
        ? await settingsRepo.getString('tts_${ttsNs}_base_url')
        : null;
    final ttsModel = ttsNs != null
        ? await settingsRepo.getString('tts_${ttsNs}_model')
        : null;
    final ttsVoice = ttsNs != null
        ? await settingsRepo.getString('tts_${ttsNs}_voice')
        : null;
    final ttsAppId = ttsNs != null
        ? await settingsRepo.getString('tts_${ttsNs}_app_id')
        : null;
    final ttsPreCacheListCount = await settingsRepo.getInt(
      _ttsPreCacheListCountKey,
    );
    final ttsDoubaoLiveApiEnabled = await settingsRepo.getString(
      _ttsDoubaoLiveApiEnabledKey,
    );
    final aiBaseUrl = await settingsRepo.getAiBaseUrl();
    final aiModel = await settingsRepo.getAiModel();
    final aiCollocationOptionValidationEnabled = await settingsRepo
        .getAiCollocationOptionValidationEnabled();
    final languageToolEnabled = await settingsRepo.getLanguageToolEnabled();
    final languageToolBaseUrl = await settingsRepo.getLanguageToolBaseUrl();

    if (mounted) {
      setState(() {
        _selectedProvider = provider ?? 'claude';
        _apiKeyController.text = apiKey ?? '';
        _passThreshold = threshold;
        _themeMode = themeMode ?? 'system';
        _ttsSpeed = ttsSpeed ?? 0.6;
        _language = lang ?? 'en';
        _ttsProvider = _normalizeTtsProvider(ttsProvider);
        _ttsApiKeyController.text = ttsApiKey ?? '';
        _ttsBaseUrlController.text = ttsBaseUrl ?? '';
        _ttsModelController.text = ttsModel ?? '';
        _ttsVoiceController.text = ttsVoice ?? '';
        _ttsAppIdController.text = ttsAppId ?? '';
        _ttsPreCacheListCountController.text =
            (ttsPreCacheListCount ?? _defaultTtsPreCacheListCount).toString();
        _ttsDoubaoLiveApiEnabled = ttsDoubaoLiveApiEnabled != 'false';
        _aiBaseUrlController.text = aiBaseUrl ?? '';
        _aiModelController.text = aiModel ?? '';
        _aiCollocationOptionValidationEnabled =
            aiCollocationOptionValidationEnabled;
        _languageToolEnabled = languageToolEnabled;
        _languageToolBaseUrlController.text =
            languageToolBaseUrl ?? LanguageToolClient.defaultBaseUrl;
        _loaded = true;
      });
      if (_normalizeTtsProvider(ttsProvider) == 'doubao') {
        await ref
            .read(_ttsPreCacheJobProvider.notifier)
            .refreshCacheStatus(lang ?? 'en');
        await ref
            .read(_ttsCacheMaintenanceProvider.notifier)
            .refreshCacheHealth();
      }
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

  Future<void> _saveTtsSpeed(double value) async {
    setState(() => _ttsSpeed = value);
    await ref.read(settingsRepositoryProvider).setTtsSpeed(value);
    await ref.read(ttsServiceProvider).reloadSettings();
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
    if (normalized == 'doubao') {
      await ref
          .read(_ttsPreCacheJobProvider.notifier)
          .refreshCacheStatus(_language);
      await ref
          .read(_ttsCacheMaintenanceProvider.notifier)
          .refreshCacheHealth();
    }
  }

  String _normalizeTtsProvider(String? provider) {
    if (provider == null || provider == 'none') {
      return 'sapi';
    }
    return _ttsProviderValues.contains(provider) ? provider : 'sapi';
  }

  Widget _ttsProviderChip({required String value, required String label}) {
    return ChoiceChip(
      label: Text(label),
      selected: _ttsProvider == value,
      onSelected: (_) => _saveTtsProvider(value),
    );
  }

  /// Persist current UI fields under the active provider's namespace.
  Future<void> _flushCurrentTtsConfig() async {
    if (_ttsProvider == 'sapi' || _ttsProvider == 'supertonic') return;
    final repo = ref.read(settingsRepositoryProvider);
    final ns = _ttsProvider;
    await repo.setString('tts_${ns}_api_key', _ttsApiKeyController.text.trim());
    await repo.setString(
      'tts_${ns}_base_url',
      _ttsBaseUrlController.text.trim(),
    );
    await repo.setString('tts_${ns}_model', _ttsModelController.text.trim());
    await repo.setString('tts_${ns}_voice', _ttsVoiceController.text.trim());
    await repo.setString('tts_${ns}_app_id', _ttsAppIdController.text.trim());
  }

  /// Load saved config for [provider] into the UI fields.
  Future<void> _loadTtsConfigFor(String provider) async {
    final repo = ref.read(settingsRepositoryProvider);
    final ns = provider;
    final apiKey = (await repo.getString('tts_${ns}_api_key')) ?? '';
    final baseUrl = (await repo.getString('tts_${ns}_base_url')) ?? '';
    final model = (await repo.getString('tts_${ns}_model')) ?? '';
    final voice = (await repo.getString('tts_${ns}_voice')) ?? '';
    final appId = (await repo.getString('tts_${ns}_app_id')) ?? '';
    setState(() {
      _ttsApiKeyController.text = apiKey;
      _ttsBaseUrlController.text = baseUrl;
      _ttsModelController.text = model;
      _ttsVoiceController.text = voice;
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
            lang: lang,
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

  Future<void> _preCacheCet4Doubao(
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
        .startCet4Doubao(
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

  Future<void> _saveTtsCloudConfig(BuildContext context, String lang) async {
    final repo = ref.read(settingsRepositoryProvider);
    final ns = _ttsProvider;
    await repo.setString('tts_${ns}_api_key', _ttsApiKeyController.text.trim());
    await repo.setString(
      'tts_${ns}_base_url',
      _ttsBaseUrlController.text.trim(),
    );
    await repo.setString('tts_${ns}_model', _ttsModelController.text.trim());
    await repo.setString('tts_${ns}_voice', _ttsVoiceController.text.trim());
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
                params: {'error': result.failedItems.first},
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

  Widget _ttsCacheStatusCard(
    ThemeData theme,
    String lang,
    _TtsPreCacheJobState job,
  ) {
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
                onPressed: job.isRunning
                    ? null
                    : () => _preCacheCet4Doubao(lang, onlyIncomplete: true),
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
                          onPressed: job.isRunning
                              ? null
                              : () => _preCacheCet4Doubao(
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
    _TtsCacheMaintenanceState state,
  ) {
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
                  onPressed: state.isCleaning
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

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = ref.watch(languageProvider);
    final preCacheJob = ref.watch(_ttsPreCacheJobProvider);
    final cacheMaintenance = ref.watch(_ttsCacheMaintenanceProvider);
    final usageSummary = ref.watch(_ttsUsageSummaryProvider);
    final aiUsageSummary = ref.watch(_aiUsageSummaryProvider);
    final recentUsageRecords = ref.watch(_ttsRecentUsageRecordsProvider);
    final preCacheListCount = _ttsPreCacheListCount();

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
          // ─── TTS Speed ─────────────────────────────────────────────
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
                          AppStrings.get('tts_speed_label', lang),
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        '${_ttsSpeed.toStringAsFixed(2)}x',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _ttsSpeed,
                    min: 0.25,
                    max: 1.0,
                    divisions: 15,
                    onChanged: _saveTtsSpeed,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0.25x',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      Text(
                        '1.0x',
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
          // ─── TTS Provider ───────────────────────────────────────────
          _sectionHeader(
            AppStrings.get('tts_section', lang),
            Icons.record_voice_over_outlined,
          ),
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
                        value: 'supertonic',
                        label: AppStrings.get('tts_supertonic', lang),
                      ),
                      _ttsProviderChip(
                        value: 'qwen',
                        label: AppStrings.get('tts_qwen', lang),
                      ),
                      _ttsProviderChip(
                        value: 'doubao',
                        label: AppStrings.get('tts_doubao', lang),
                      ),
                      _ttsProviderChip(
                        value: 'sapi',
                        label: AppStrings.get('tts_sapi', lang),
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
                        Text(switch (_ttsProvider) {
                          'qwen' => AppStrings.get('tts_qwen_title', lang),
                          'openai' => AppStrings.get('tts_openai_title', lang),
                          _ => AppStrings.get('tts_doubao_title', lang),
                        }, style: theme.textTheme.titleSmall),
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
                        hintText: switch (_ttsProvider) {
                          'qwen' => 'https://dashscope.aliyuncs.com',
                          'openai' => 'https://api.openai.com',
                          _ => 'https://openspeech.bytedance.com',
                        },
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
                      decoration: InputDecoration(
                        labelText: AppStrings.get('tts_model_label', lang),
                        hintText: switch (_ttsProvider) {
                          'qwen' => 'qwen3-tts-flash',
                          'doubao' => 'seed-tts-2.0-standard',
                          _ => 'tts-1',
                        },
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
                      decoration: InputDecoration(
                        labelText: AppStrings.get('tts_voice_label', lang),
                        hintText: switch (_ttsProvider) {
                          'qwen' => 'Jennifer',
                          'doubao' => 'zh_female_tiexinnvsheng_mars_bigtts',
                          _ => 'alloy',
                        },
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    if (_ttsProvider == 'doubao') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _ttsAppIdController,
                        onChanged: _saveTtsAppId,
                        decoration: InputDecoration(
                          labelText: AppStrings.get(
                            'tts_resource_id_label',
                            lang,
                          ),
                          hintText: 'seed-tts-2.0',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
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
                      const SizedBox(height: 8),
                      _ttsUsageStatsCard(
                        theme,
                        lang,
                        usageSummary,
                        recentUsageRecords,
                      ),
                      const SizedBox(height: 8),
                      _ttsCacheStatusCard(theme, lang, preCacheJob),
                      const SizedBox(height: 8),
                      _ttsCacheHealthCard(theme, lang, cacheMaintenance),
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
                        enabled: !preCacheJob.isRunning,
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
                              onPressed: preCacheJob.isRunning
                                  ? null
                                  : () => _preCacheCet4Doubao(lang),
                              icon: preCacheJob.isRunning
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
                  ],
                ),
              ),
            ),
          ],
          // ─── Model download status (Supertonic only) ──────────────
          if (_ttsProvider == 'supertonic') ...[
            const SizedBox(height: 8),
            _ModelDownloadCard(lang: lang),
          ],
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
      'deepseek' => 'deepseek-chat',
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

class _ModelDownloadCard extends ConsumerWidget {
  const _ModelDownloadCard({required this.lang});

  final String lang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(ttsModelStateProvider);

    return state.when(
      data: (modelState) {
        return switch (modelState) {
          TtsModelReady(modelDir: final _) => Card(
            color: Colors.green.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.get('tts_model_ready', lang),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          TtsModelNotDownloaded() => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.install_mobile_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppStrings.get('tts_model_not_downloaded', lang),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.get('tts_download_warning', lang),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      ref.read(ttsModelManagerProvider).downloadModel();
                    },
                    icon: const Icon(Icons.install_mobile, size: 18),
                    label: Text(AppStrings.get('tts_download_model', lang)),
                  ),
                ],
              ),
            ),
          ),
          TtsModelDownloading(progress: final p) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppStrings.get(
                          'tts_model_downloading',
                          lang,
                          params: {'progress': (p * 100).toStringAsFixed(0)},
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: p),
                ],
              ),
            ),
          ),
          TtsModelError(message: final msg) => Card(
            color: Colors.red.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppStrings.get(
                            'tts_model_error',
                            lang,
                            params: {'error': msg},
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(ttsModelManagerProvider).downloadModel();
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(AppStrings.get('tts_retry_download', lang)),
                  ),
                ],
              ),
            ),
          ),
        };
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}
