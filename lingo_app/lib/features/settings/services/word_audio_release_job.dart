import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/remote_example_audio_client.dart';
import '../../../core/services/remote_word_audio_client.dart';
import '../../../core/services/tts_providers.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/services/word_audio_release_service.dart';
import '../../../data/database/app_database.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/repositories.dart';

final wordAudioReleaseJobProvider =
    StateNotifierProvider<
      WordAudioReleaseJobController,
      WordAudioReleaseJobState
    >((ref) {
      return WordAudioReleaseJobController(ref);
    });

/// Uses the same durable planner, package and publisher as word audio, but
/// keeps Qwen3 Katerina example sentences in their own cache/profile.
final qwen3ExampleAudioReleaseJobProvider =
    StateNotifierProvider<
      WordAudioReleaseJobController,
      WordAudioReleaseJobState
    >((ref) {
      return WordAudioReleaseJobController.qwen3Examples(ref);
    });

/// A separate controller/state instance for Tencent example audio. Existing
/// WeWinny files are reused, while missing examples are synthesized as
/// independently keyed WeJack files.
final tencentWeWinnyExampleAudioReleaseJobProvider =
    StateNotifierProvider<
      WordAudioReleaseJobController,
      WordAudioReleaseJobState
    >((ref) {
      return WordAudioReleaseJobController.tencentWeWinnyExamples(ref);
    });

enum WordAudioReleaseContent { words, qwen3Examples, tencentWeWinnyExamples }

enum WordAudioReleaseJobStage {
  idle,
  planning,
  ready,
  synthesizing,
  validating,
  packaging,
  publishing,
  verifying,
  generated,
  published,
  verified,
  interactiveSudoRequired,
  interactivePublisherOpened,
  synthesisFailed,
  validationFailed,
  cancelled,
  failed,
  unsupported,
}

class WordAudioReleaseListOption {
  final int id;
  final int listNumber;
  final String name;
  final int wordCount;

  const WordAudioReleaseListOption({
    required this.id,
    required this.listNumber,
    required this.name,
    required this.wordCount,
  });
}

/// Read-only local-cache summary for one CET-4 List.
///
/// The release controller uses the same shape for the historical word profile
/// and the Qwen3 Katerina example profile.  Keeping this separate from the
/// server summary makes it impossible for a stale server result to masquerade
/// as a local cache hit.
class WordAudioReleaseListCacheStatus {
  final int listId;
  final int listNumber;
  final String listName;
  final int totalItems;
  final int cachedItems;

  const WordAudioReleaseListCacheStatus({
    required this.listId,
    required this.listNumber,
    required this.listName,
    required this.totalItems,
    required this.cachedItems,
  });

  bool get isComplete => totalItems > 0 && cachedItems == totalItems;
  int get missingItems =>
      (totalItems - cachedItems).clamp(0, totalItems).toInt();

  // Backwards-friendly vocabulary for callers that display word-oriented
  // status rows.  Qwen3 uses the item aliases below without changing the
  // durable release state shape.
  int get totalWords => totalItems;
  int get cachedWords => cachedItems;
  int get missingWords => missingItems;
}

enum WordAudioServerListUploadState {
  checking,
  uploaded,
  notUploaded,
  partiallyUploaded,
  unavailable,
}

/// A read-only server-presence summary for one fully cached CET-4 List.
///
/// A list is considered uploaded only after every expected static WAV responds
/// with a valid WAV header. A network, HTTP, or malformed-audio response is
/// deliberately kept separate from a 404 so the UI never claims a List is
/// missing when its server state could not be determined.
class WordAudioServerListStatus {
  final int listId;
  final int totalWords;
  final int checkedWords;
  final int uploadedWords;
  final int missingWords;
  final int unavailableWords;

  const WordAudioServerListStatus({
    required this.listId,
    required this.totalWords,
    required this.checkedWords,
    required this.uploadedWords,
    required this.missingWords,
    required this.unavailableWords,
  });

  WordAudioServerListUploadState get uploadState {
    if (totalWords <= 0) {
      return WordAudioServerListUploadState.unavailable;
    }
    if (checkedWords < totalWords) {
      return WordAudioServerListUploadState.checking;
    }
    if (unavailableWords > 0) {
      return WordAudioServerListUploadState.unavailable;
    }
    if (uploadedWords == totalWords) {
      return WordAudioServerListUploadState.uploaded;
    }
    if (missingWords == totalWords) {
      return WordAudioServerListUploadState.notUploaded;
    }
    return WordAudioServerListUploadState.partiallyUploaded;
  }

  int get totalItems => totalWords;
  int get checkedItems => checkedWords;
  int get uploadedItems => uploadedWords;
  int get missingItems => missingWords;
  int get unavailableItems => unavailableWords;
}

class _WordAudioServerListCounter {
  final int totalWords;
  int checkedWords = 0;
  int uploadedWords = 0;
  int missingWords = 0;
  int unavailableWords = 0;

  _WordAudioServerListCounter({required this.totalWords});

  void record({required bool found, required bool notFound}) {
    checkedWords++;
    if (found) {
      uploadedWords++;
    } else if (notFound) {
      missingWords++;
    } else {
      unavailableWords++;
    }
  }

  WordAudioServerListStatus toStatus(int listId) {
    return WordAudioServerListStatus(
      listId: listId,
      totalWords: totalWords,
      checkedWords: checkedWords,
      uploadedWords: uploadedWords,
      missingWords: missingWords,
      unavailableWords: unavailableWords,
    );
  }
}

class _WordAudioServerProbeTarget {
  final int listId;
  final String? text;

  const _WordAudioServerProbeTarget({required this.listId, required this.text});
}

class WordAudioReleaseJobState {
  final bool isRunning;
  final bool cancelRequested;
  final bool isLoadingLists;
  final List<WordAudioReleaseListOption> lists;
  final WordAudioReleaseJobStage stage;
  final WordAudioReleasePlan? plan;
  final TtsPreCacheProgress? progress;
  final TtsPreCacheResult? synthesis;
  final WordAudioReleasePackage? package;
  final WordAudioPublisherResult? publisher;
  final bool isLoadingCacheStatus;
  final Map<int, WordAudioReleaseListCacheStatus> localListStatuses;
  final String? cacheStatusError;
  final bool isCheckingServerStatus;
  final int serverStatusCheckedWords;
  final int serverStatusTotalWords;
  final Map<int, WordAudioServerListStatus> serverListStatuses;
  final RemoteWordAudioFailure? serverStatusFailure;
  final RemoteExampleAudioFailure? exampleServerStatusFailure;
  final List<String> logs;
  final String? error;

  const WordAudioReleaseJobState({
    this.isRunning = false,
    this.cancelRequested = false,
    this.isLoadingLists = false,
    this.lists = const [],
    this.stage = WordAudioReleaseJobStage.idle,
    this.plan,
    this.progress,
    this.synthesis,
    this.package,
    this.publisher,
    this.isLoadingCacheStatus = false,
    this.localListStatuses = const {},
    this.cacheStatusError,
    this.isCheckingServerStatus = false,
    this.serverStatusCheckedWords = 0,
    this.serverStatusTotalWords = 0,
    this.serverListStatuses = const {},
    this.serverStatusFailure,
    this.exampleServerStatusFailure,
    this.logs = const [],
    this.error,
  });

  Map<int, WordAudioReleaseListCacheStatus> get listCacheStatuses =>
      localListStatuses;

  bool get isCheckingCacheStatus => isLoadingCacheStatus;

  Object? get effectiveServerStatusFailure =>
      exampleServerStatusFailure ?? serverStatusFailure;

  bool get canCancel =>
      isRunning &&
      (stage == WordAudioReleaseJobStage.synthesizing ||
          stage == WordAudioReleaseJobStage.validating ||
          stage == WordAudioReleaseJobStage.packaging);

  WordAudioReleaseJobState copyWith({
    bool? isRunning,
    bool? cancelRequested,
    bool? isLoadingLists,
    List<WordAudioReleaseListOption>? lists,
    WordAudioReleaseJobStage? stage,
    WordAudioReleasePlan? plan,
    bool clearPlan = false,
    TtsPreCacheProgress? progress,
    bool clearProgress = false,
    TtsPreCacheResult? synthesis,
    bool clearSynthesis = false,
    WordAudioReleasePackage? package,
    bool clearPackage = false,
    WordAudioPublisherResult? publisher,
    bool clearPublisher = false,
    bool? isLoadingCacheStatus,
    Map<int, WordAudioReleaseListCacheStatus>? localListStatuses,
    String? cacheStatusError,
    bool clearCacheStatusError = false,
    bool? isCheckingServerStatus,
    int? serverStatusCheckedWords,
    int? serverStatusTotalWords,
    Map<int, WordAudioServerListStatus>? serverListStatuses,
    RemoteWordAudioFailure? serverStatusFailure,
    RemoteExampleAudioFailure? exampleServerStatusFailure,
    bool clearServerStatusFailure = false,
    List<String>? logs,
    String? error,
    bool clearError = false,
  }) {
    return WordAudioReleaseJobState(
      isRunning: isRunning ?? this.isRunning,
      cancelRequested: cancelRequested ?? this.cancelRequested,
      isLoadingLists: isLoadingLists ?? this.isLoadingLists,
      lists: lists ?? this.lists,
      stage: stage ?? this.stage,
      plan: clearPlan ? null : plan ?? this.plan,
      progress: clearProgress ? null : progress ?? this.progress,
      synthesis: clearSynthesis ? null : synthesis ?? this.synthesis,
      package: clearPackage ? null : package ?? this.package,
      publisher: clearPublisher ? null : publisher ?? this.publisher,
      isLoadingCacheStatus: isLoadingCacheStatus ?? this.isLoadingCacheStatus,
      localListStatuses: localListStatuses ?? this.localListStatuses,
      cacheStatusError: clearCacheStatusError
          ? null
          : cacheStatusError ?? this.cacheStatusError,
      isCheckingServerStatus:
          isCheckingServerStatus ?? this.isCheckingServerStatus,
      serverStatusCheckedWords:
          serverStatusCheckedWords ?? this.serverStatusCheckedWords,
      serverStatusTotalWords:
          serverStatusTotalWords ?? this.serverStatusTotalWords,
      serverListStatuses: serverListStatuses ?? this.serverListStatuses,
      serverStatusFailure: clearServerStatusFailure
          ? null
          : serverStatusFailure ?? this.serverStatusFailure,
      exampleServerStatusFailure: clearServerStatusFailure
          ? null
          : exampleServerStatusFailure ?? this.exampleServerStatusFailure,
      logs: logs ?? this.logs,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class WordAudioReleaseJobController
    extends StateNotifier<WordAudioReleaseJobState> {
  WordAudioReleaseJobController(
    this._ref, {
    this.content = WordAudioReleaseContent.words,
  }) : super(const WordAudioReleaseJobState());

  WordAudioReleaseJobController.qwen3Examples(Ref ref)
    : this(ref, content: WordAudioReleaseContent.qwen3Examples);

  WordAudioReleaseJobController.tencentWeWinnyExamples(Ref ref)
    : this(ref, content: WordAudioReleaseContent.tencentWeWinnyExamples);

  final Ref _ref;
  final WordAudioReleaseContent content;
  bool _cancelRequested = false;
  static const int _serverStatusConcurrency = 6;

  Future<void> refreshLists() async {
    if (state.isLoadingLists) return;
    state = state.copyWith(
      isLoadingLists: true,
      clearError: true,
      localListStatuses: const {},
      clearCacheStatusError: true,
      serverStatusCheckedWords: 0,
      serverStatusTotalWords: 0,
      serverListStatuses: const {},
      clearServerStatusFailure: true,
    );
    try {
      final lists = await _loadCet4Lists();
      if (mounted) {
        state = state.copyWith(
          isLoadingLists: false,
          lists: lists,
          clearError: true,
        );
      }
    } catch (error) {
      if (mounted) {
        state = state.copyWith(
          isLoadingLists: false,
          error: _shortError(error),
        );
      }
    }
  }

  Future<void> loadLatestPackage() async {
    try {
      final package = await _service().loadLatestPackage();
      if (mounted && package != null) {
        state = state.copyWith(package: package);
      }
    } catch (_) {
      // Recovery data is optional. A corrupt/stale report must not prevent
      // normal List planning or generation.
    }
  }

  /// Refreshes the local staging status used by an example release card. A
  /// valid cached example is required before its List can join the read-only
  /// server preflight below.
  ///
  /// Word WAV status remains owned by the established Qwen pre-cache job; the
  /// example profiles intentionally do not share cache keys or validation
  /// rules.
  Future<void> refreshCacheStatuses() async {
    if (!_isExampleContent || state.isRunning || state.isLoadingCacheStatus) {
      return;
    }

    state = state.copyWith(
      isLoadingCacheStatus: true,
      localListStatuses: const {},
      serverStatusCheckedWords: 0,
      serverStatusTotalWords: 0,
      serverListStatuses: const {},
      clearCacheStatusError: true,
      clearServerStatusFailure: true,
    );
    try {
      final availableLists = state.lists.isEmpty
          ? await _loadCet4Lists()
          : state.lists;
      final repository = _ref.read(wordListRepositoryProvider);
      final textsByList = <int, List<String>>{};
      final itemCountsByList = <int, int>{};
      final allTexts = <String>[];

      for (final list in availableLists) {
        final words = await repository.getWordsForList(list.id);
        itemCountsByList[list.id] = words.length;
        final texts = <String>[];
        for (final word in words) {
          final text = _releaseTextOrNull(word);
          if (text == null) continue;
          texts.add(text);
          allTexts.add(text);
        }
        textsByList[list.id] = texts;
      }

      final presence = await _ref
          .read(ttsServiceProvider)
          .getCachedAudioPresence(
            allTexts,
            provider: _exampleTtsProvider,
            lang: 'en',
          );
      final statuses = <int, WordAudioReleaseListCacheStatus>{
        for (final list in availableLists)
          list.id: WordAudioReleaseListCacheStatus(
            listId: list.id,
            listNumber: list.listNumber,
            listName: list.name,
            // A missing scenario example must leave the List incomplete. The
            // release planner will later name that exact data problem instead
            // of claiming the server has a complete publishable set.
            totalItems: itemCountsByList[list.id] ?? 0,
            cachedItems: (textsByList[list.id] ?? const <String>[])
                .where((text) => presence[text] == true)
                .length,
          ),
      };

      if (mounted) {
        state = state.copyWith(
          isLoadingCacheStatus: false,
          lists: availableLists,
          localListStatuses: Map.unmodifiable(statuses),
          serverStatusCheckedWords: 0,
          serverStatusTotalWords: 0,
          serverListStatuses: const {},
          clearCacheStatusError: true,
          clearServerStatusFailure: true,
        );
      }
    } catch (error) {
      if (mounted) {
        state = state.copyWith(
          isLoadingCacheStatus: false,
          cacheStatusError: _shortError(error),
        );
      }
    }
  }

  /// Inspects the static server only for Lists whose local WAV cache is
  /// already complete. This is intentionally explicit and read-only: opening
  /// Settings must not trigger hundreds of HTTP requests by itself.  The
  /// selected profile determines whether it probes word keys in `/v1/en/` or
  /// independently keyed example files in `/v1/en/examples/`.
  Future<void> refreshServerStatuses({
    required Iterable<int> fullyCachedListIds,
  }) async {
    if (state.isRunning || state.isCheckingServerStatus) return;

    final cachedIds = fullyCachedListIds.toSet();
    if (cachedIds.isEmpty) {
      if (mounted) {
        state = state.copyWith(
          isCheckingServerStatus: false,
          serverStatusCheckedWords: 0,
          serverStatusTotalWords: 0,
          serverListStatuses: const {},
          clearServerStatusFailure: true,
        );
      }
      return;
    }

    if (mounted) {
      state = state.copyWith(
        isCheckingServerStatus: true,
        serverStatusCheckedWords: 0,
        serverStatusTotalWords: 0,
        serverListStatuses: const {},
        clearServerStatusFailure: true,
      );
    }

    try {
      final baseUrl =
          (await _ref
                  .read(settingsRepositoryProvider)
                  .getString(SettingsRepository.keyRemoteWordAudioBaseUrl))
              ?.trim() ??
          '';
      final wordClient = content == WordAudioReleaseContent.words
          ? RemoteWordAudioClient(baseUrl: baseUrl)
          : null;
      final exampleClient = _isExampleContent
          ? RemoteExampleAudioClient(
              baseUrl: baseUrl,
              profile: _exampleRemoteProfile,
            )
          : null;
      final availableLists = state.lists.isEmpty
          ? await _loadCet4Lists()
          : state.lists;
      final selectedLists = availableLists
          .where((item) => cachedIds.contains(item.id))
          .toList(growable: false);
      final repository = _ref.read(wordListRepositoryProvider);
      final counters = <int, _WordAudioServerListCounter>{};
      final targets = <_WordAudioServerProbeTarget>[];

      for (final list in selectedLists) {
        final words = await repository.getWordsForList(list.id);
        counters[list.id] = _WordAudioServerListCounter(
          totalWords: words.length,
        );
        targets.addAll([
          for (final word in words)
            _WordAudioServerProbeTarget(
              listId: list.id,
              text: _releaseTextOrNull(word),
            ),
        ]);
      }

      if (mounted) {
        state = state.copyWith(
          serverStatusCheckedWords: 0,
          serverStatusTotalWords: targets.length,
          serverListStatuses: _serverStatusSnapshot(counters),
          clearServerStatusFailure: true,
        );
      }

      var checkedWords = 0;
      for (
        var start = 0;
        start < targets.length;
        start += _serverStatusConcurrency
      ) {
        final end = (start + _serverStatusConcurrency)
            .clamp(0, targets.length)
            .toInt();
        final batch = targets.sublist(start, end);
        final outcomes = await Future.wait(
          batch.map((target) async {
            final text = target.text;
            if (text == null) {
              return (target: target, found: false, notFound: false);
            }
            if (content == WordAudioReleaseContent.words) {
              final failure = await wordClient!.probe(text);
              return (
                target: target,
                found: failure == null,
                notFound: failure == RemoteWordAudioFailure.notFound,
              );
            }
            final failure = await exampleClient!.probe(text);
            return (
              target: target,
              found: failure == null,
              notFound: failure == RemoteExampleAudioFailure.notFound,
            );
          }),
        );
        for (final outcome in outcomes) {
          counters[outcome.target.listId]!.record(
            found: outcome.found,
            notFound: outcome.notFound,
          );
          checkedWords++;
        }
        if (mounted) {
          state = state.copyWith(
            serverStatusCheckedWords: checkedWords,
            serverListStatuses: _serverStatusSnapshot(counters),
            clearServerStatusFailure: true,
          );
        }
      }

      if (mounted) {
        state = state.copyWith(
          isCheckingServerStatus: false,
          serverStatusCheckedWords: checkedWords,
          serverListStatuses: _serverStatusSnapshot(counters),
          clearServerStatusFailure: true,
        );
      }
    } on RemoteWordAudioException catch (error) {
      if (mounted) {
        state = state.copyWith(
          isCheckingServerStatus: false,
          serverStatusFailure: error.failure,
        );
      }
    } on RemoteExampleAudioException catch (error) {
      if (mounted) {
        state = state.copyWith(
          isCheckingServerStatus: false,
          exampleServerStatusFailure: error.failure,
        );
      }
    } catch (_) {
      if (mounted) {
        state = content == WordAudioReleaseContent.words
            ? state.copyWith(
                isCheckingServerStatus: false,
                serverStatusFailure: RemoteWordAudioFailure.unavailable,
              )
            : state.copyWith(
                isCheckingServerStatus: false,
                exampleServerStatusFailure:
                    RemoteExampleAudioFailure.unavailable,
              );
      }
    }
  }

  void clearServerStatuses() {
    if (state.isCheckingServerStatus) return;
    state = state.copyWith(
      serverStatusCheckedWords: 0,
      serverStatusTotalWords: 0,
      serverListStatuses: const {},
      clearServerStatusFailure: true,
    );
  }

  Future<WordAudioReleasePlan?> preparePlan(List<int> listIds) async {
    if (state.isRunning) return null;
    state = state.copyWith(
      stage: WordAudioReleaseJobStage.planning,
      clearPlan: true,
      clearProgress: true,
      clearSynthesis: true,
      clearPublisher: true,
      logs: const [],
      clearError: true,
    );
    try {
      final options = state.lists.isEmpty
          ? await _loadCet4Lists()
          : state.lists;
      final selectedIds = listIds.toSet();
      final selected = options
          .where((item) => selectedIds.contains(item.id))
          .toList(growable: false);
      if (selected.isEmpty || selected.length != selectedIds.length) {
        throw const WordAudioReleaseException(
          'One or more selected CET-4 Lists were not found.',
        );
      }
      final items = <WordAudioReleaseItem>[];
      for (final option in selected) {
        final words = await _ref
            .read(wordListRepositoryProvider)
            .getWordsForList(option.id);
        items.addAll([
          for (final word in words)
            WordAudioReleaseItem(
              text: _textForRelease(word, option),
              listName: option.name,
              listId: option.id,
            ),
        ]);
      }
      final plan = await _service().createPlan(
        lists: [
          for (final option in selected)
            WordAudioReleaseListTarget(
              listNumber: option.listNumber,
              listId: option.id,
              listName: option.name,
            ),
        ],
        items: items,
      );
      if (mounted) {
        state = state.copyWith(
          lists: options,
          stage: WordAudioReleaseJobStage.ready,
          plan: plan,
          clearError: true,
        );
      }
      return plan;
    } catch (error) {
      if (mounted) {
        state = state.copyWith(
          stage: error is WordAudioReleaseUnsupportedPlatformException
              ? WordAudioReleaseJobStage.unsupported
              : WordAudioReleaseJobStage.failed,
          error: _shortError(error),
        );
      }
      return null;
    }
  }

  Future<void> run({
    required WordAudioReleasePlan plan,
    required WordAudioReleaseTtsConfig config,
    required bool publish,
  }) async {
    if (state.isRunning) return;
    clearServerStatuses();
    _cancelRequested = false;
    state = state.copyWith(
      isRunning: true,
      cancelRequested: false,
      stage: WordAudioReleaseJobStage.synthesizing,
      plan: plan,
      clearProgress: true,
      clearSynthesis: true,
      clearPublisher: true,
      logs: const [],
      clearError: true,
    );

    try {
      final result = await _service().run(
        confirmedPlan: plan,
        config: config,
        publish: publish,
        shouldCancel: () => _cancelRequested,
        onProgress: (progress) {
          if (mounted) {
            state = state.copyWith(progress: progress, clearError: true);
          }
        },
        onStage: (stage) {
          if (mounted) {
            state = state.copyWith(stage: _stageForOperation(stage));
          }
        },
        onLog: _appendLog,
      );
      if (mounted) {
        state = state.copyWith(
          isRunning: false,
          cancelRequested: false,
          stage: _stageForResult(result.status),
          plan: result.plan,
          synthesis: result.synthesis,
          package: result.package,
          publisher: result.publisher,
          error: result.message,
          clearError: result.message == null,
        );
      }
      await _refreshListsAfterJob();
    } catch (error) {
      if (mounted) {
        state = state.copyWith(
          isRunning: false,
          cancelRequested: false,
          stage: error is WordAudioReleaseUnsupportedPlatformException
              ? WordAudioReleaseJobStage.unsupported
              : WordAudioReleaseJobStage.failed,
          error: _shortError(error),
        );
      }
    } finally {
      _cancelRequested = false;
      if (mounted && state.isRunning) {
        state = state.copyWith(isRunning: false, cancelRequested: false);
      }
    }
  }

  Future<void> verifyLatestPackage() async {
    if (state.isRunning) return;
    final package = state.package ?? await _service().loadLatestPackage();
    if (package == null) {
      state = state.copyWith(
        stage: WordAudioReleaseJobStage.failed,
        error: 'No validated local release package is available.',
      );
      return;
    }
    state = state.copyWith(
      isRunning: true,
      stage: WordAudioReleaseJobStage.verifying,
      package: package,
      clearPublisher: true,
      logs: const [],
      clearError: true,
    );
    try {
      final result = await _service().verifyPackage(package, onLog: _appendLog);
      if (mounted) {
        state = state.copyWith(
          isRunning: false,
          stage: result.succeeded
              ? WordAudioReleaseJobStage.verified
              : WordAudioReleaseJobStage.failed,
          publisher: result,
          error: result.succeeded
              ? null
              : 'Server verification exited with code ${result.exitCode}.',
          clearError: result.succeeded,
        );
      }
    } catch (error) {
      if (mounted) {
        state = state.copyWith(
          isRunning: false,
          stage: error is WordAudioReleaseUnsupportedPlatformException
              ? WordAudioReleaseJobStage.unsupported
              : WordAudioReleaseJobStage.failed,
          error: _shortError(error),
        );
      }
    }
  }

  Future<void> republishLatestPackage() async {
    if (state.isRunning) return;
    clearServerStatuses();
    final package = state.package ?? await _service().loadLatestPackage();
    if (package == null) {
      state = state.copyWith(
        stage: WordAudioReleaseJobStage.failed,
        error: 'No validated local release package is available.',
      );
      return;
    }
    state = state.copyWith(
      isRunning: true,
      stage: WordAudioReleaseJobStage.publishing,
      package: package,
      clearPublisher: true,
      logs: const [],
      clearError: true,
    );
    try {
      final result = await _service().republishPackage(
        package,
        onStage: (stage) {
          if (mounted) state = state.copyWith(stage: _stageForOperation(stage));
        },
        onLog: _appendLog,
      );
      final interactive = _service().isInteractiveSudoRequired(result);
      if (mounted) {
        state = state.copyWith(
          isRunning: false,
          stage: result.succeeded
              ? WordAudioReleaseJobStage.published
              : interactive
              ? WordAudioReleaseJobStage.interactiveSudoRequired
              : WordAudioReleaseJobStage.failed,
          publisher: result,
          error: result.succeeded || interactive
              ? null
              : 'Publisher exited with code ${result.exitCode}.',
          clearError: result.succeeded || interactive,
        );
      }
    } catch (error) {
      if (mounted) {
        state = state.copyWith(
          isRunning: false,
          stage: error is WordAudioReleaseUnsupportedPlatformException
              ? WordAudioReleaseJobStage.unsupported
              : WordAudioReleaseJobStage.failed,
          error: _shortError(error),
        );
      }
    }
  }

  Future<void> openInteractivePublisher() async {
    final package = state.package ?? await _service().loadLatestPackage();
    if (package == null) {
      state = state.copyWith(
        stage: WordAudioReleaseJobStage.failed,
        error: 'No validated local release package is available.',
      );
      return;
    }
    try {
      await _service().openInteractivePublisher(package);
      if (mounted) {
        state = state.copyWith(
          package: package,
          stage: WordAudioReleaseJobStage.interactivePublisherOpened,
          clearError: true,
        );
      }
    } catch (error) {
      if (mounted) {
        state = state.copyWith(
          stage: error is WordAudioReleaseUnsupportedPlatformException
              ? WordAudioReleaseJobStage.unsupported
              : WordAudioReleaseJobStage.failed,
          error: _shortError(error),
        );
      }
    }
  }

  void cancel() {
    if (!state.canCancel) return;
    _cancelRequested = true;
    state = state.copyWith(cancelRequested: true);
  }

  Future<List<WordAudioReleaseListOption>> _loadCet4Lists() async {
    final repository = _ref.read(wordListRepositoryProvider);
    final books = await repository.getAllBooks();
    final book = books.where((candidate) {
      final name = candidate.name.trim().toLowerCase();
      return name == 'cet-4' || name == 'cet4' || name == '四级';
    }).firstOrNull;
    if (book == null) {
      throw const WordAudioReleaseException('CET-4 word book not found.');
    }
    final lists = await repository.getListsForBook(book.id);
    lists.sort((a, b) => a.id.compareTo(b.id));
    if (lists.isEmpty) {
      throw const WordAudioReleaseException('CET-4 word book has no Lists.');
    }
    return [
      for (var index = 0; index < lists.length; index++)
        WordAudioReleaseListOption(
          id: lists[index].id,
          listNumber: index + 1,
          name: lists[index].name,
          wordCount: lists[index].wordCount,
        ),
    ];
  }

  Future<void> _refreshListsAfterJob() async {
    try {
      final lists = await _loadCet4Lists();
      if (mounted) state = state.copyWith(lists: lists);
      if (_isExampleContent) {
        await refreshCacheStatuses();
      }
    } catch (_) {
      // The completed job result remains more useful than a secondary refresh
      // failure, so retain the list snapshot that was already displayed.
    }
  }

  Map<int, WordAudioServerListStatus> _serverStatusSnapshot(
    Map<int, _WordAudioServerListCounter> counters,
  ) {
    return Map.unmodifiable({
      for (final entry in counters.entries)
        entry.key: entry.value.toStatus(entry.key),
    });
  }

  bool get _isExampleContent => content != WordAudioReleaseContent.words;

  String get _exampleTtsProvider => switch (content) {
    WordAudioReleaseContent.qwen3Examples =>
      TtsService.qwen3FlashKaterinaProvider,
    WordAudioReleaseContent.tencentWeWinnyExamples =>
      TtsService.tencentWeJackProvider,
    WordAudioReleaseContent.words => throw StateError(
      'Words do not have an example-audio provider.',
    ),
  };

  RemoteExampleAudioProfile get _exampleRemoteProfile => switch (content) {
    WordAudioReleaseContent.qwen3Examples => RemoteExampleAudioProfile.qwen3,
    WordAudioReleaseContent.tencentWeWinnyExamples =>
      RemoteExampleAudioProfile.tencentWeJack,
    WordAudioReleaseContent.words => throw StateError(
      'Words do not have an example-audio profile.',
    ),
  };

  WordAudioReleaseService _service() => switch (content) {
    WordAudioReleaseContent.words => WordAudioReleaseService(
      ttsService: _ref.read(ttsServiceProvider),
    ),
    WordAudioReleaseContent.qwen3Examples =>
      WordAudioReleaseService.qwen3Examples(
        ttsService: _ref.read(ttsServiceProvider),
      ),
    WordAudioReleaseContent.tencentWeWinnyExamples =>
      WordAudioReleaseService.tencentWeJackExamples(
        ttsService: _ref.read(ttsServiceProvider),
      ),
  };

  String _textForRelease(Word word, WordAudioReleaseListOption list) {
    if (content == WordAudioReleaseContent.words) return word.english;
    final example = word.scenarioExample?.trim() ?? '';
    if (example.isEmpty) {
      throw WordAudioReleaseException(
        'List ${list.listNumber} (${list.name}) has no example sentence for '
        '${word.english}.',
      );
    }
    return example;
  }

  String? _releaseTextOrNull(Word word) {
    if (content == WordAudioReleaseContent.words) {
      return word.english.trim().isEmpty ? null : word.english;
    }
    final example = word.scenarioExample?.trim() ?? '';
    return example.isEmpty ? null : example;
  }

  WordAudioReleaseJobStage _stageForOperation(
    WordAudioReleaseOperationStage stage,
  ) {
    return switch (stage) {
      WordAudioReleaseOperationStage.synthesizing =>
        WordAudioReleaseJobStage.synthesizing,
      WordAudioReleaseOperationStage.validating =>
        WordAudioReleaseJobStage.validating,
      WordAudioReleaseOperationStage.packaging =>
        WordAudioReleaseJobStage.packaging,
      WordAudioReleaseOperationStage.publishing =>
        WordAudioReleaseJobStage.publishing,
      WordAudioReleaseOperationStage.verifying =>
        WordAudioReleaseJobStage.verifying,
    };
  }

  WordAudioReleaseJobStage _stageForResult(WordAudioReleaseRunStatus status) {
    return switch (status) {
      WordAudioReleaseRunStatus.generated => WordAudioReleaseJobStage.generated,
      WordAudioReleaseRunStatus.published => WordAudioReleaseJobStage.published,
      WordAudioReleaseRunStatus.interactiveSudoRequired =>
        WordAudioReleaseJobStage.interactiveSudoRequired,
      WordAudioReleaseRunStatus.synthesisFailed =>
        WordAudioReleaseJobStage.synthesisFailed,
      WordAudioReleaseRunStatus.validationFailed =>
        WordAudioReleaseJobStage.validationFailed,
      WordAudioReleaseRunStatus.cancelled => WordAudioReleaseJobStage.cancelled,
      WordAudioReleaseRunStatus.publishFailed =>
        WordAudioReleaseJobStage.failed,
    };
  }

  void _appendLog(String line) {
    if (!mounted || line.trim().isEmpty) return;
    final logs = [...state.logs, line.trim()];
    if (logs.length > 80) logs.removeRange(0, logs.length - 80);
    state = state.copyWith(logs: logs);
  }

  String _shortError(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }
}
