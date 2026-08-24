import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

import '../data_dir.dart';
import 'remote_example_audio_client.dart';
import 'remote_word_audio_client.dart';
import 'tts_adapters/qwen3_tts_adapter.dart';
import 'tts_adapters/qwen_tts_adapter.dart';
import 'tts_adapters/tencent_tts_adapter.dart';
import 'tts_service.dart';

/// The approved batch policy is one normal request plus at most two retries
/// for each word that has no valid staged WAV yet.
const int wordAudioReleaseMaxRetries = 2;

/// Immutable details that keep independently reviewed static-audio profiles
/// from sharing cache files, package reports, or server directories.
///
/// The historical Qwen word release remains this service's default profile.
/// Qwen3 example sentences use the second profile through the named
/// [WordAudioReleaseService.qwen3Examples] constructor.
class WordAudioReleaseProfile {
  final String ttsProvider;
  final String cacheProfileVersion;
  final String dataStem;
  final String publisherReleaseKind;
  final RegExp fileNamePattern;
  final String Function(String text, String language) fileNameFor;
  final List<String> Function(String text, String language) fileNamesFor;
  final List<String> compatibleProfileVersions;
  final bool Function(Uint8List bytes) isValidAudio;

  WordAudioReleaseProfile({
    required this.ttsProvider,
    required this.cacheProfileVersion,
    required this.dataStem,
    required this.publisherReleaseKind,
    required this.fileNamePattern,
    required this.fileNameFor,
    List<String> Function(String text, String language)? fileNamesFor,
    List<String>? compatibleProfileVersions,
    required this.isValidAudio,
  }) : fileNamesFor =
           fileNamesFor ?? ((text, language) => [fileNameFor(text, language)]),
       compatibleProfileVersions = List.unmodifiable(
         compatibleProfileVersions ?? [cacheProfileVersion],
       );

  static final words = WordAudioReleaseProfile(
    ttsProvider: 'qwen',
    cacheProfileVersion: RemoteWordAudioClient.audioKeyProfileVersion,
    dataStem: 'lingo_word_audio',
    publisherReleaseKind: 'word',
    fileNamePattern: RegExp(r'^[a-f0-9]{64}\.wav$'),
    fileNameFor: (text, language) =>
        RemoteWordAudioClient.audioFileNameFor(text, language: language),
    isValidAudio: (bytes) =>
        QwenTtsAdapter.wordAudioValidationFailure(bytes) == null,
  );

  static final qwen3Examples = WordAudioReleaseProfile(
    ttsProvider: TtsService.qwen3FlashKaterinaProvider,
    cacheProfileVersion: RemoteExampleAudioClient.audioKeyProfileVersion,
    dataStem: 'lingo_example_audio',
    publisherReleaseKind: 'example',
    fileNamePattern: RegExp(r'^qwen3-example-[a-f0-9]{64}\.wav$'),
    fileNameFor: (text, language) =>
        RemoteExampleAudioClient.audioFileNameFor(text, language: language),
    fileNamesFor: (text, language) =>
        RemoteExampleAudioClient.audioFileNamesFor(text, language: language),
    compatibleProfileVersions:
        RemoteExampleAudioClient.compatibleAudioKeyProfileVersions,
    isValidAudio: (bytes) =>
        Qwen3TtsAdapter.exampleAudioValidationFailure(bytes) == null,
  );

  /// Tencent WeWinny uses the same static `/examples/` server directory as
  /// Qwen3, but an entirely separate key profile, filename prefix, cache
  /// validation policy, local report stem, and cloud-provider identity.
  static final tencentWeWinnyExamples = WordAudioReleaseProfile(
    ttsProvider: TtsService.tencentWeWinnyProvider,
    cacheProfileVersion:
        RemoteExampleAudioProfile.tencentWeWinny.audioKeyProfileVersion,
    dataStem: 'lingo_tencent_wewinny_example_audio',
    publisherReleaseKind: 'tencent_example',
    fileNamePattern: RegExp(r'^tencent-wewinny-example-[a-f0-9]{64}\.wav$'),
    fileNameFor: (text, language) => RemoteExampleAudioProfile.tencentWeWinny
        .audioFileNameFor(text, language: language),
    fileNamesFor: (text, language) => RemoteExampleAudioProfile.tencentWeWinny
        .audioFileNamesFor(text, language: language),
    compatibleProfileVersions: RemoteExampleAudioProfile
        .tencentWeWinny
        .compatibleAudioKeyProfileVersions,
    isValidAudio: (bytes) =>
        TencentTtsAdapter.weWinnyAudioValidationFailure(bytes) == null,
  );

  /// Mixed Tencent example release: existing WeWinny files remain reusable,
  /// while all newly synthesized files use WeJack's independent 16 kHz key.
  /// The filename and validator accept both immutable profiles so a package
  /// can contain the original recordings plus the 25 repaired items.
  static final tencentWeJackExamples = WordAudioReleaseProfile(
    ttsProvider: TencentTtsAdapter.weJackProviderId,
    cacheProfileVersion:
        RemoteExampleAudioProfile.tencentWeJack.audioKeyProfileVersion,
    dataStem: 'lingo_tencent_wewinny_example_audio',
    publisherReleaseKind: 'tencent_example',
    fileNamePattern: RegExp(
      r'^tencent-(?:wewinny|wejack)-example-[a-f0-9]{64}\.wav$',
    ),
    fileNameFor: (text, language) => RemoteExampleAudioProfile.tencentWeJack
        .audioFileNameFor(text, language: language),
    fileNamesFor: (text, language) => RemoteExampleAudioProfile.tencentWeJack
        .audioFileNamesFor(text, language: language),
    compatibleProfileVersions: [
      RemoteExampleAudioProfile.tencentWeJack.audioKeyProfileVersion,
      RemoteExampleAudioProfile.tencentWeWinny.audioKeyProfileVersion,
    ],
    isValidAudio: (bytes) =>
        TencentTtsAdapter.audioValidationFailure(
              bytes,
              expectedSampleRate: TencentTtsAdapter.weWinnySampleRate,
            ) ==
            null ||
        TencentTtsAdapter.audioValidationFailure(
              bytes,
              expectedSampleRate: TencentTtsAdapter.weJackSampleRate,
            ) ==
            null,
  );
}

class WordAudioReleaseException implements Exception {
  final String message;

  const WordAudioReleaseException(this.message);

  @override
  String toString() => message;
}

class WordAudioReleaseUnsupportedPlatformException
    extends WordAudioReleaseException {
  const WordAudioReleaseUnsupportedPlatformException()
    : super('Word-audio publishing is supported on Windows only.');
}

/// One word belonging to the exact CET-4 List being released.
class WordAudioReleaseItem {
  final String text;
  final String listName;
  final int listId;
  final String language;

  const WordAudioReleaseItem({
    required this.text,
    required this.listName,
    required this.listId,
    this.language = 'en',
  });

  String get audioFileName =>
      RemoteWordAudioClient.audioFileNameFor(text, language: language);

  TtsPreCacheItem toPreCacheItem() =>
      TtsPreCacheItem(text: text, listName: listName, listId: listId);
}

/// One selected CET-4 List in a release batch.
class WordAudioReleaseListTarget {
  final int listNumber;
  final int listId;
  final String listName;

  const WordAudioReleaseListTarget({
    required this.listNumber,
    required this.listId,
    required this.listName,
  });
}

/// A read-only estimate shown before the user authorizes a cloud batch.
///
/// [items] contains one item per server-audio key. If a word appears in more
/// than one selected List, it needs only one canonical WAV, one cloud request
/// at most, and one uploaded file.
class WordAudioReleasePlan {
  final List<WordAudioReleaseListTarget> lists;
  final List<WordAudioReleaseItem> items;
  final List<WordAudioReleaseItem> reusableItems;
  final List<WordAudioReleaseItem> pendingItems;

  const WordAudioReleasePlan({
    required this.lists,
    required this.items,
    required this.reusableItems,
    required this.pendingItems,
  });

  int get listCount => lists.length;
  List<int> get listIds => lists.map((list) => list.listId).toList();
  List<int> get listNumbers => lists.map((list) => list.listNumber).toList();

  /// Kept for the existing PowerShell publisher, whose mandatory ListNumber
  /// is only an identifier once SourceDirectory is explicitly supplied.
  int get listNumber => lists.first.listNumber;
  int get listId => lists.first.listId;
  String get listName => lists.first.listName;
  int get totalWords => items.length;
  int get reusableWords => reusableItems.length;
  int get normalCalls => pendingItems.length;
  int get maxAttempts => normalCalls * (wordAudioReleaseMaxRetries + 1);
  bool get isReadyForPackaging => pendingItems.isEmpty;
}

class WordAudioReleaseTtsConfig {
  final String apiKey;
  final String baseUrl;
  final String model;
  final String voice;
  final String resourceId;

  const WordAudioReleaseTtsConfig({
    required this.apiKey,
    required this.baseUrl,
    required this.model,
    required this.voice,
    required this.resourceId,
  });

  /// Safe fixed configuration for Tencent's production path. Credentials are
  /// intentionally absent: [TtsService] reads them only from the persistent
  /// Windows environment variables when synthesis is actually authorized.
  const WordAudioReleaseTtsConfig.tencentWeWinny()
    : apiKey = '',
      baseUrl = TencentTtsAdapter.defaultEndpoint,
      model = TencentTtsAdapter.action,
      voice = '501009',
      resourceId = TencentTtsAdapter.defaultRegion;

  const WordAudioReleaseTtsConfig.tencentWeJack()
    : apiKey = '',
      baseUrl = TencentTtsAdapter.defaultEndpoint,
      model = TencentTtsAdapter.action,
      voice = '101050',
      resourceId = TencentTtsAdapter.defaultRegion;
}

enum WordAudioReleaseOperationStage {
  synthesizing,
  validating,
  packaging,
  publishing,
  verifying,
}

enum WordAudioReleaseRunStatus {
  generated,
  published,
  interactiveSudoRequired,
  synthesisFailed,
  validationFailed,
  cancelled,
  publishFailed,
}

class WordAudioReleasePackage {
  final List<WordAudioReleaseListTarget> lists;
  final int expectedCount;
  final Directory sourceDirectory;
  final File archiveFile;
  final File reportFile;
  final List<String> fileNames;
  final int totalBytes;

  const WordAudioReleasePackage({
    required this.lists,
    required this.expectedCount,
    required this.sourceDirectory,
    required this.archiveFile,
    required this.reportFile,
    required this.fileNames,
    required this.totalBytes,
  });

  int get listCount => lists.length;
  List<int> get listIds => lists.map((list) => list.listId).toList();
  List<int> get listNumbers => lists.map((list) => list.listNumber).toList();
  int get listNumber => lists.first.listNumber;
  int get listId => lists.first.listId;
  String get listName => lists.first.listName;
}

class WordAudioPublisherInvocation {
  final File script;
  final int listNumber;
  final Directory sourceDirectory;
  final int expectedCount;
  final bool verifyOnly;
  final String releaseKind;
  final void Function(String line)? onLog;

  const WordAudioPublisherInvocation({
    required this.script,
    required this.listNumber,
    required this.sourceDirectory,
    required this.expectedCount,
    required this.verifyOnly,
    this.releaseKind = 'word',
    this.onLog,
  });
}

class WordAudioPublisherResult {
  final int exitCode;
  final String output;

  const WordAudioPublisherResult({
    required this.exitCode,
    required this.output,
  });

  bool get succeeded => exitCode == 0;
}

class WordAudioReleaseRunResult {
  final WordAudioReleaseRunStatus status;
  final WordAudioReleasePlan plan;
  final TtsPreCacheResult? synthesis;
  final WordAudioReleasePackage? package;
  final WordAudioPublisherResult? publisher;
  final String? message;

  const WordAudioReleaseRunResult({
    required this.status,
    required this.plan,
    this.synthesis,
    this.package,
    this.publisher,
    this.message,
  });
}

typedef WordAudioReleaseSynthesis =
    Future<TtsPreCacheResult> Function({
      required WordAudioReleaseTtsConfig config,
      required List<TtsPreCacheItem> items,
      required int maxRetries,
      bool Function()? shouldCancel,
      void Function(TtsPreCacheProgress progress)? onProgress,
    });

typedef WordAudioReleasePublisher =
    Future<WordAudioPublisherResult> Function(
      WordAudioPublisherInvocation invocation,
    );

typedef WordAudioPublisherScriptLocator = Future<File> Function();

/// Coordinates the already-approved local Qwen cache format with the existing
/// PowerShell publisher. It deliberately never reads API keys or SSH details
/// from disk: the caller supplies the former and the publisher keeps owning
/// the latter through its existing D-drive JSON configuration.
class WordAudioReleaseService {
  WordAudioReleaseService({
    TtsService? ttsService,
    WordAudioReleaseSynthesis? synthesis,
    Future<Directory> Function()? dataDirProvider,
    bool Function()? isWindows,
    WordAudioReleasePublisher? publisher,
    WordAudioPublisherScriptLocator? publisherScriptLocator,
    WordAudioReleaseProfile? profile,
  }) : assert(ttsService != null || synthesis != null),
       _profile = profile ?? WordAudioReleaseProfile.words,
       _dataDirProvider = dataDirProvider ?? getLingoDataDir,
       _isWindows = isWindows ?? (() => Platform.isWindows),
       _synthesis =
           synthesis ??
           _synthesisFor(ttsService!, profile ?? WordAudioReleaseProfile.words),
       _publisher = publisher ?? _runPowerShellPublisher,
       _publisherScriptLocator =
           publisherScriptLocator ?? _defaultPublisherScriptLocator;

  WordAudioReleaseService.qwen3Examples({
    TtsService? ttsService,
    WordAudioReleaseSynthesis? synthesis,
    Future<Directory> Function()? dataDirProvider,
    bool Function()? isWindows,
    WordAudioReleasePublisher? publisher,
    WordAudioPublisherScriptLocator? publisherScriptLocator,
  }) : this(
         ttsService: ttsService,
         synthesis: synthesis,
         dataDirProvider: dataDirProvider,
         isWindows: isWindows,
         publisher: publisher,
         publisherScriptLocator: publisherScriptLocator,
         profile: WordAudioReleaseProfile.qwen3Examples,
       );

  WordAudioReleaseService.tencentWeWinnyExamples({
    TtsService? ttsService,
    WordAudioReleaseSynthesis? synthesis,
    Future<Directory> Function()? dataDirProvider,
    bool Function()? isWindows,
    WordAudioReleasePublisher? publisher,
    WordAudioPublisherScriptLocator? publisherScriptLocator,
  }) : this(
         ttsService: ttsService,
         synthesis: synthesis,
         dataDirProvider: dataDirProvider,
         isWindows: isWindows,
         publisher: publisher,
         publisherScriptLocator: publisherScriptLocator,
         profile: WordAudioReleaseProfile.tencentWeWinnyExamples,
       );

  WordAudioReleaseService.tencentWeJackExamples({
    TtsService? ttsService,
    WordAudioReleaseSynthesis? synthesis,
    Future<Directory> Function()? dataDirProvider,
    bool Function()? isWindows,
    WordAudioReleasePublisher? publisher,
    WordAudioPublisherScriptLocator? publisherScriptLocator,
  }) : this(
         ttsService: ttsService,
         synthesis: synthesis,
         dataDirProvider: dataDirProvider,
         isWindows: isWindows,
         publisher: publisher,
         publisherScriptLocator: publisherScriptLocator,
         profile: WordAudioReleaseProfile.tencentWeJackExamples,
       );

  final WordAudioReleaseProfile _profile;
  final Future<Directory> Function() _dataDirProvider;
  final bool Function() _isWindows;
  final WordAudioReleaseSynthesis _synthesis;
  final WordAudioReleasePublisher _publisher;
  final WordAudioPublisherScriptLocator _publisherScriptLocator;

  static WordAudioReleaseSynthesis _synthesisFor(
    TtsService service,
    WordAudioReleaseProfile profile,
  ) {
    return ({
      required WordAudioReleaseTtsConfig config,
      required List<TtsPreCacheItem> items,
      required int maxRetries,
      bool Function()? shouldCancel,
      void Function(TtsPreCacheProgress progress)? onProgress,
    }) {
      return service.preCacheCloudConfig(
        provider: profile.ttsProvider,
        apiKey: config.apiKey,
        baseUrl: config.baseUrl,
        model: config.model,
        voice: config.voice,
        resourceId: config.resourceId,
        items: items,
        lang: 'en',
        maxRetries: maxRetries,
        shouldCancel: shouldCancel,
        onProgress: onProgress,
      );
    };
  }

  /// Inspects only canonical v2 cache files. A non-empty but invalid WAV is
  /// intentionally planned as pending so the existing TTS service retries it.
  Future<WordAudioReleasePlan> createPlan({
    required List<WordAudioReleaseListTarget> lists,
    required List<WordAudioReleaseItem> items,
  }) async {
    if (lists.isEmpty) {
      throw const WordAudioReleaseException(
        'Select at least one CET-4 List before creating a release plan.',
      );
    }
    if (items.isEmpty) {
      throw const WordAudioReleaseException(
        'The selected CET-4 Lists have no words.',
      );
    }

    final selectedLists = [...lists]
      ..sort((a, b) => a.listNumber.compareTo(b.listNumber));
    final selectedListIds = <int>{};
    final selectedListNumbers = <int>{};
    for (final list in selectedLists) {
      if (list.listNumber < 1) {
        throw const WordAudioReleaseException('List number must be 1 or more.');
      }
      if (!selectedListIds.add(list.listId) ||
          !selectedListNumbers.add(list.listNumber)) {
        throw const WordAudioReleaseException(
          'The release selection contains the same CET-4 List more than once.',
        );
      }
      if (list.listName.trim().isEmpty) {
        throw const WordAudioReleaseException(
          'The release selection contains an unnamed CET-4 List.',
        );
      }
    }

    final uniqueItems = <WordAudioReleaseItem>[];
    final fileNames = <String>{};
    for (final item in items) {
      if (item.text.trim().isEmpty) {
        throw const WordAudioReleaseException(
          'The selected CET-4 Lists contain an empty word.',
        );
      }
      if (!selectedListIds.contains(item.listId)) {
        throw const WordAudioReleaseException(
          'A release word does not belong to the selected CET-4 Lists.',
        );
      }
      if (fileNames.add(_audioFileNameFor(item))) uniqueItems.add(item);
    }

    final root = await _dataDirProvider();
    final cacheDir = Directory(p.join(root.path, 'lingo_tts_cache'));
    final reusable = <WordAudioReleaseItem>[];
    final pending = <WordAudioReleaseItem>[];

    for (final item in uniqueItems) {
      final cached = await _validatedCacheFileFor(item, cacheDir);
      if (cached != null) {
        reusable.add(item);
      } else {
        pending.add(item);
      }
    }

    return WordAudioReleasePlan(
      lists: List.unmodifiable(selectedLists),
      items: List.unmodifiable(uniqueItems),
      reusableItems: List.unmodifiable(reusable),
      pendingItems: List.unmodifiable(pending),
    );
  }

  /// Runs synthesis only for items that were pending at confirmation time.
  /// If a formerly reusable file disappears meanwhile, validation fails rather
  /// than making an unconfirmed additional API request.
  Future<WordAudioReleaseRunResult> run({
    required WordAudioReleasePlan confirmedPlan,
    required WordAudioReleaseTtsConfig config,
    required bool publish,
    bool Function()? shouldCancel,
    void Function(TtsPreCacheProgress progress)? onProgress,
    void Function(WordAudioReleaseOperationStage stage)? onStage,
    void Function(String line)? onLog,
  }) async {
    _ensureWindows();
    await _persistStatus(
      stage: WordAudioReleaseOperationStage.synthesizing.name,
      plan: confirmedPlan,
    );

    if (shouldCancel?.call() == true) {
      return _cancelledResult(confirmedPlan);
    }

    final synthesis = confirmedPlan.pendingItems.isEmpty
        ? _emptySynthesisResult()
        : await _synthesis(
            config: config,
            items: confirmedPlan.pendingItems
                .map((item) => item.toPreCacheItem())
                .toList(growable: false),
            maxRetries: wordAudioReleaseMaxRetries,
            shouldCancel: shouldCancel,
            onProgress: onProgress,
          );

    if (synthesis.cancelled || shouldCancel?.call() == true) {
      final result = _cancelledResult(confirmedPlan, synthesis: synthesis);
      await _persistStatus(
        stage: WordAudioReleaseRunStatus.cancelled.name,
        plan: confirmedPlan,
        synthesis: synthesis,
      );
      return result;
    }
    if (synthesis.failed > 0) {
      final result = WordAudioReleaseRunResult(
        status: WordAudioReleaseRunStatus.synthesisFailed,
        plan: confirmedPlan,
        synthesis: synthesis,
      );
      await _persistStatus(
        stage: WordAudioReleaseRunStatus.synthesisFailed.name,
        plan: confirmedPlan,
        synthesis: synthesis,
      );
      return result;
    }

    onStage?.call(WordAudioReleaseOperationStage.validating);
    await _persistStatus(
      stage: WordAudioReleaseOperationStage.validating.name,
      plan: confirmedPlan,
      synthesis: synthesis,
    );
    final validatedPlan = await createPlan(
      lists: confirmedPlan.lists,
      items: confirmedPlan.items,
    );
    if (!validatedPlan.isReadyForPackaging) {
      final result = WordAudioReleaseRunResult(
        status: WordAudioReleaseRunStatus.validationFailed,
        plan: validatedPlan,
        synthesis: synthesis,
        message: 'Not every word has a valid staged WAV after synthesis.',
      );
      await _persistStatus(
        stage: WordAudioReleaseRunStatus.validationFailed.name,
        plan: validatedPlan,
        authorizationPlan: confirmedPlan,
        synthesis: synthesis,
        message: result.message,
      );
      return result;
    }
    if (shouldCancel?.call() == true) {
      final result = _cancelledResult(validatedPlan, synthesis: synthesis);
      await _persistStatus(
        stage: WordAudioReleaseRunStatus.cancelled.name,
        plan: validatedPlan,
        authorizationPlan: confirmedPlan,
        synthesis: synthesis,
      );
      return result;
    }

    onStage?.call(WordAudioReleaseOperationStage.packaging);
    final package = await createPackage(validatedPlan);
    if (!publish) {
      await _persistStatus(
        stage: WordAudioReleaseRunStatus.generated.name,
        plan: validatedPlan,
        authorizationPlan: confirmedPlan,
        synthesis: synthesis,
        package: package,
      );
      return WordAudioReleaseRunResult(
        status: WordAudioReleaseRunStatus.generated,
        plan: validatedPlan,
        synthesis: synthesis,
        package: package,
      );
    }
    if (shouldCancel?.call() == true) {
      final result = _cancelledResult(
        validatedPlan,
        synthesis: synthesis,
        package: package,
      );
      await _persistStatus(
        stage: WordAudioReleaseRunStatus.cancelled.name,
        plan: validatedPlan,
        authorizationPlan: confirmedPlan,
        synthesis: synthesis,
        package: package,
      );
      return result;
    }

    onStage?.call(WordAudioReleaseOperationStage.publishing);
    final publisher = await _invokePublisher(
      package,
      verifyOnly: false,
      onStage: onStage,
      onLog: onLog,
    );
    if (isInteractiveSudoRequired(publisher)) {
      final result = WordAudioReleaseRunResult(
        status: WordAudioReleaseRunStatus.interactiveSudoRequired,
        plan: validatedPlan,
        synthesis: synthesis,
        package: package,
        publisher: publisher,
      );
      await _persistStatus(
        stage: WordAudioReleaseRunStatus.interactiveSudoRequired.name,
        plan: validatedPlan,
        authorizationPlan: confirmedPlan,
        synthesis: synthesis,
        package: package,
        publisher: publisher,
      );
      return result;
    }
    if (!publisher.succeeded) {
      final result = WordAudioReleaseRunResult(
        status: WordAudioReleaseRunStatus.publishFailed,
        plan: validatedPlan,
        synthesis: synthesis,
        package: package,
        publisher: publisher,
        message: 'The publisher exited with code ${publisher.exitCode}.',
      );
      await _persistStatus(
        stage: WordAudioReleaseRunStatus.publishFailed.name,
        plan: validatedPlan,
        authorizationPlan: confirmedPlan,
        synthesis: synthesis,
        package: package,
        publisher: publisher,
        message: result.message,
      );
      return result;
    }

    await _persistStatus(
      stage: WordAudioReleaseRunStatus.published.name,
      plan: validatedPlan,
      authorizationPlan: confirmedPlan,
      synthesis: synthesis,
      package: package,
      publisher: publisher,
    );
    return WordAudioReleaseRunResult(
      status: WordAudioReleaseRunStatus.published,
      plan: validatedPlan,
      synthesis: synthesis,
      package: package,
      publisher: publisher,
    );
  }

  /// Copies only validated canonical WAVs into a publisher-compatible folder,
  /// then writes a ZIP and JSON audit report next to that folder on D drive.
  Future<WordAudioReleasePackage> createPackage(
    WordAudioReleasePlan plan,
  ) async {
    _ensureWindows();
    final revalidated = await createPlan(lists: plan.lists, items: plan.items);
    if (!revalidated.isReadyForPackaging) {
      throw const WordAudioReleaseException(
        'Cannot package until every word has a valid staged WAV.',
      );
    }

    final root = await _dataDirProvider();
    final sourceDirectory = await _createUniqueSourceDirectory(
      root,
      _releaseSlugForLists(revalidated.lists),
    );
    final fileNames = <String>[];
    var totalBytes = 0;

    try {
      final cacheDirectory = Directory(p.join(root.path, 'lingo_tts_cache'));
      for (final item in revalidated.items) {
        final source = await _validatedCacheFileFor(item, cacheDirectory);
        if (source == null) {
          throw WordAudioReleaseException(
            'A staged WAV became invalid while packaging: '
            '${_audioFileNameFor(item)}',
          );
        }
        // Preserve the immutable filename/profile of a legacy cache entry.
        // New synthesis still writes the current profile key; this branch
        // simply lets yesterday's validated v1 file remain publishable.
        final fileName = p.basename(source.path);
        final bytes = await source.readAsBytes();
        final destination = File(p.join(sourceDirectory.path, fileName));
        await destination.writeAsBytes(bytes, flush: true);
        fileNames.add(fileName);
        totalBytes += bytes.length;
      }

      final sourceFiles = await _validatedSourceFiles(
        sourceDirectory,
        expectedCount: revalidated.totalWords,
      );
      final sourcePrefix =
          '${_profile.dataStem}_upload_v2_${_releaseSlugForLists(revalidated.lists)}_';
      final stamp = p
          .basename(sourceDirectory.path)
          .replaceFirst(sourcePrefix, '');
      final archiveFile = File('${sourceDirectory.path}.zip');
      final encoder = ZipFileEncoder();
      await encoder.zipDirectoryAsync(
        sourceDirectory,
        filename: archiveFile.path,
      );
      if (!await archiveFile.exists() || await archiveFile.length() <= 0) {
        throw const WordAudioReleaseException(
          'Could not create the ZIP package.',
        );
      }

      final reportFile = File(
        p.join(
          root.path,
          '${_profile.dataStem}_release_v2_${_releaseSlugForLists(revalidated.lists)}_$stamp.json',
        ),
      );
      final package = WordAudioReleasePackage(
        lists: revalidated.lists,
        expectedCount: revalidated.totalWords,
        sourceDirectory: sourceDirectory,
        archiveFile: archiveFile,
        reportFile: reportFile,
        fileNames: List.unmodifiable(
          sourceFiles.map((file) => p.basename(file.path)).toList(),
        ),
        totalBytes: totalBytes,
      );
      await _persistStatus(
        stage: 'packaged',
        plan: revalidated,
        package: package,
      );
      return package;
    } catch (_) {
      // Keep a partial folder for diagnosis, but it is never passed to the
      // publisher because this method did not return a package.
      rethrow;
    }
  }

  Future<WordAudioPublisherResult> verifyPackage(
    WordAudioReleasePackage package, {
    void Function(String line)? onLog,
  }) async {
    _ensureWindows();
    await validatePackage(package);
    return _invokePublisher(package, verifyOnly: true, onLog: onLog);
  }

  Future<WordAudioPublisherResult> republishPackage(
    WordAudioReleasePackage package, {
    void Function(WordAudioReleaseOperationStage stage)? onStage,
    void Function(String line)? onLog,
  }) async {
    _ensureWindows();
    await validatePackage(package);
    return _invokePublisher(
      package,
      verifyOnly: false,
      onStage: onStage,
      onLog: onLog,
    );
  }

  /// Starts the existing publisher in a visible PowerShell session for the
  /// one remaining server-side sudo password prompt. The app does not collect,
  /// persist, or transmit that password itself.
  Future<void> openInteractivePublisher(WordAudioReleasePackage package) async {
    _ensureWindows();
    await validatePackage(package);
    final script = await _publisherScriptLocator();
    final publisherArguments = <String>[
      '-NoLogo',
      '-NoProfile',
      '-NoExit',
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      script.path,
      '-ListNumber',
      package.listNumber.toString(),
      '-SourceDirectory',
      package.sourceDirectory.path,
      '-ExpectedCount',
      package.expectedCount.toString(),
      if (_profile.publisherReleaseKind != 'word') ...[
        '-ReleaseKind',
        _profile.publisherReleaseKind,
      ],
    ];
    final quotedArguments = publisherArguments
        .map(_powerShellSingleQuoted)
        .join(', ');
    final command =
        "${r'$ErrorActionPreference'} = 'Stop'; "
        "${r'$publisherArguments'} = @($quotedArguments); "
        "Start-Process -FilePath powershell.exe "
        "-ArgumentList ${r'$publisherArguments'} -WindowStyle Normal "
        '-ErrorAction Stop';
    final launcher = await Process.run('powershell.exe', [
      '-NoLogo',
      '-NoProfile',
      '-NonInteractive',
      '-ExecutionPolicy',
      'Bypass',
      '-Command',
      command,
    ]);
    if (launcher.exitCode != 0) {
      throw const WordAudioReleaseException(
        'Could not open the interactive server password window.',
      );
    }
  }

  /// Reads the durable latest package report, if its exact WAV source folder
  /// still passes all local validation checks.
  Future<WordAudioReleasePackage?> loadLatestPackage() async {
    final root = await _dataDirProvider();
    final latest = File(
      p.join(root.path, '${_profile.dataStem}_release_v2_latest.json'),
    );
    if (!await latest.exists()) return null;

    try {
      final raw = jsonDecode(await latest.readAsString());
      if (raw is! Map<String, dynamic>) return null;
      if (!_profile.compatibleProfileVersions.contains(
        raw['profileVersion']?.toString(),
      )) {
        return null;
      }
      final packageData = raw['package'];
      if (packageData is! Map<String, dynamic>) return null;
      final sourcePath = packageData['sourceDirectory'];
      final archivePath = packageData['archiveFile'];
      final reportPath = packageData['reportFile'];
      final expectedCount = _asInt(packageData['expectedCount']);
      final lists =
          _listTargetsFromJson(packageData['lists']) ??
          _legacyListTargetFromPackageJson(packageData);
      if (sourcePath is! String ||
          archivePath is! String ||
          reportPath is! String ||
          expectedCount == null ||
          lists == null) {
        return null;
      }
      final sourceDirectory = Directory(sourcePath);
      if (!_isWithinRoot(root, sourceDirectory)) return null;
      final fileNames = (packageData['fileNames'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(growable: false);
      final package = WordAudioReleasePackage(
        lists: lists,
        expectedCount: expectedCount,
        sourceDirectory: sourceDirectory,
        archiveFile: File(archivePath),
        reportFile: File(reportPath),
        fileNames: fileNames,
        totalBytes: _asInt(packageData['totalBytes']) ?? 0,
      );
      await validatePackage(package);
      return package;
    } catch (_) {
      return null;
    }
  }

  Future<void> validatePackage(WordAudioReleasePackage package) async {
    if (!await package.sourceDirectory.exists()) {
      throw WordAudioReleaseException(
        'The local upload package no longer exists: ${package.sourceDirectory.path}',
      );
    }
    await _validatedSourceFiles(
      package.sourceDirectory,
      expectedCount: package.expectedCount,
      expectedFileNames: package.fileNames,
    );
  }

  bool isInteractiveSudoRequired(WordAudioPublisherResult result) {
    if (result.succeeded) return false;
    final output = result.output.toLowerCase();
    final hasSudo = output.contains('sudo');
    return hasSudo &&
        (output.contains('password') ||
            output.contains('terminal') ||
            output.contains('tty') ||
            output.contains('askpass'));
  }

  WordAudioReleaseRunResult _cancelledResult(
    WordAudioReleasePlan plan, {
    TtsPreCacheResult? synthesis,
    WordAudioReleasePackage? package,
  }) {
    return WordAudioReleaseRunResult(
      status: WordAudioReleaseRunStatus.cancelled,
      plan: plan,
      synthesis: synthesis,
      package: package,
    );
  }

  TtsPreCacheResult _emptySynthesisResult() {
    return const TtsPreCacheResult(
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
  }

  Future<WordAudioPublisherResult> _invokePublisher(
    WordAudioReleasePackage package, {
    required bool verifyOnly,
    void Function(WordAudioReleaseOperationStage stage)? onStage,
    void Function(String line)? onLog,
  }) async {
    final script = await _publisherScriptLocator();
    var verificationStarted = false;
    return _publisher(
      WordAudioPublisherInvocation(
        script: script,
        listNumber: package.listNumber,
        sourceDirectory: package.sourceDirectory,
        expectedCount: package.expectedCount,
        verifyOnly: verifyOnly,
        releaseKind: _profile.publisherReleaseKind,
        onLog: (line) {
          if (!verificationStarted && line.contains('HTTP checked:')) {
            verificationStarted = true;
            onStage?.call(WordAudioReleaseOperationStage.verifying);
          }
          onLog?.call(line);
        },
      ),
    );
  }

  String _audioFileNameFor(WordAudioReleaseItem item) =>
      _profile.fileNameFor(item.text, item.language);

  List<String> _audioFileNamesFor(WordAudioReleaseItem item) =>
      _profile.fileNamesFor(item.text, item.language);

  Future<File?> _validatedCacheFileFor(
    WordAudioReleaseItem item,
    Directory cacheDirectory,
  ) async {
    for (final fileName in _audioFileNamesFor(item)) {
      final candidate = File(p.join(cacheDirectory.path, fileName));
      if (await _isValidatedAudioWav(candidate)) return candidate;
    }
    return null;
  }

  Future<bool> _isValidatedAudioWav(File file) async {
    try {
      if (!await file.exists() || await file.length() <= 0) return false;
      return _profile.isValidAudio(await file.readAsBytes());
    } catch (_) {
      return false;
    }
  }

  Future<Directory> _createUniqueSourceDirectory(
    Directory root,
    String releaseSlug,
  ) {
    final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final prefix =
        '${_profile.dataStem}_upload_v2_${releaseSlug}_${timestamp}_';

    // Directory.create treats an existing directory as success. createTemp
    // creates a genuinely unique child directory, while allowing all real
    // file-system failures (including access and path-length errors) to reach
    // the caller unchanged.
    return root.createTemp(prefix);
  }

  Future<List<File>> _validatedSourceFiles(
    Directory sourceDirectory, {
    required int expectedCount,
    List<String>? expectedFileNames,
  }) async {
    final files = <File>[];
    final unexpected = <String>[];
    await for (final entity in sourceDirectory.list()) {
      if (entity is! File) {
        unexpected.add(p.basename(entity.path));
        continue;
      }
      if (p.extension(entity.path).toLowerCase() != '.wav') {
        unexpected.add(p.basename(entity.path));
        continue;
      }
      files.add(entity);
    }
    files.sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));
    if (unexpected.isNotEmpty) {
      throw WordAudioReleaseException(
        'The upload package contains non-WAV files: ${unexpected.join(', ')}',
      );
    }
    if (files.length != expectedCount) {
      throw WordAudioReleaseException(
        'Expected $expectedCount WAV files but found ${files.length}.',
      );
    }
    final actualNames = files.map((file) => p.basename(file.path)).toSet();
    if (actualNames.length != files.length ||
        actualNames.any((name) => !_profile.fileNamePattern.hasMatch(name))) {
      throw const WordAudioReleaseException(
        'The upload package contains an invalid server-audio file name.',
      );
    }
    if (expectedFileNames != null && expectedFileNames.isNotEmpty) {
      final expectedNames = expectedFileNames.toSet();
      if (expectedNames.length != files.length ||
          !actualNames.containsAll(expectedNames)) {
        throw const WordAudioReleaseException(
          'The upload package no longer matches its release report.',
        );
      }
    }
    for (final file in files) {
      if (!await _isValidatedAudioWav(file)) {
        throw WordAudioReleaseException(
          'Invalid WAV in upload package: ${p.basename(file.path)}',
        );
      }
    }
    return files;
  }

  Future<void> _persistStatus({
    required String stage,
    required WordAudioReleasePlan plan,
    WordAudioReleasePlan? authorizationPlan,
    TtsPreCacheResult? synthesis,
    WordAudioReleasePackage? package,
    WordAudioPublisherResult? publisher,
    String? message,
  }) async {
    final root = await _dataDirProvider();
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
    final latest = File(
      p.join(root.path, '${_profile.dataStem}_release_v2_latest.json'),
    );
    Map<String, dynamic>? retainedPackage;
    if (package == null && await latest.exists()) {
      try {
        final previous = jsonDecode(await latest.readAsString());
        if (previous is Map<String, dynamic> &&
            previous['package'] is Map<String, dynamic>) {
          retainedPackage = previous['package'] as Map<String, dynamic>;
        }
      } catch (_) {
        // A broken status file must not block a new local release attempt.
      }
    }
    final packageJson = package == null
        ? retainedPackage
        : _packageJson(package);
    final authorization = authorizationPlan ?? plan;
    final payload = <String, dynamic>{
      'schemaVersion': 2,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
      'profileVersion': _profile.cacheProfileVersion,
      'stage': stage,
      'lists': _listTargetsJson(plan.lists),
      'batch': {
        'listCount': plan.listCount,
        'listNumbers': plan.listNumbers,
        'totalWords': plan.totalWords,
        'reusableWords': plan.reusableWords,
        'normalCalls': plan.normalCalls,
        'maxAttempts': plan.maxAttempts,
      },
      // Retained for v1 report readers. Batch-aware readers should use
      // `lists` and `batch` above.
      'list': {
        'listNumber': plan.listNumber,
        'listId': plan.listId,
        'listName': plan.listName,
        'totalWords': plan.totalWords,
        'reusableWords': plan.reusableWords,
        'normalCalls': plan.normalCalls,
        'maxAttempts': plan.maxAttempts,
      },
      'authorization': {
        'lists': _listTargetsJson(authorization.lists),
        'listCount': authorization.listCount,
        'normalCalls': authorization.normalCalls,
        'maxAttempts': authorization.maxAttempts,
        'reusableWordsAtConfirmation': authorization.reusableWords,
      },
      if (synthesis != null)
        'synthesis': {
          'success': synthesis.success,
          'skipped': synthesis.skipped,
          'failed': synthesis.failed,
          'apiCalls': synthesis.apiCalls,
          'chargedCharacters': synthesis.chargedCharacters,
          'audioBytes': synthesis.audioBytes,
          'cancelled': synthesis.cancelled,
        },
      'package': ?packageJson,
      if (publisher != null)
        'publisher': {
          'exitCode': publisher.exitCode,
          'output': _trimLog(publisher.output),
        },
      'message': ?message,
    };
    final encoded = const JsonEncoder.withIndent('  ').convert(payload);
    await latest.writeAsString(encoded, flush: true);
    if (package != null) {
      await package.reportFile.writeAsString(encoded, flush: true);
    }
  }

  Map<String, dynamic> _packageJson(WordAudioReleasePackage package) {
    return {
      'lists': _listTargetsJson(package.lists),
      // Retained so a v1 local package report remains recoverable.
      'listNumber': package.listNumber,
      'listId': package.listId,
      'listName': package.listName,
      'expectedCount': package.expectedCount,
      'sourceDirectory': package.sourceDirectory.path,
      'archiveFile': package.archiveFile.path,
      'reportFile': package.reportFile.path,
      'fileNames': package.fileNames,
      'totalBytes': package.totalBytes,
    };
  }

  List<Map<String, dynamic>> _listTargetsJson(
    Iterable<WordAudioReleaseListTarget> lists,
  ) => [
    for (final list in lists)
      {
        'listNumber': list.listNumber,
        'listId': list.listId,
        'listName': list.listName,
      },
  ];

  List<WordAudioReleaseListTarget>? _listTargetsFromJson(Object? value) {
    if (value is! List || value.isEmpty) return null;
    final lists = <WordAudioReleaseListTarget>[];
    final ids = <int>{};
    final numbers = <int>{};
    for (final entry in value) {
      final list = _listTargetFromJson(entry);
      if (list == null ||
          !ids.add(list.listId) ||
          !numbers.add(list.listNumber)) {
        return null;
      }
      lists.add(list);
    }
    lists.sort((a, b) => a.listNumber.compareTo(b.listNumber));
    return List.unmodifiable(lists);
  }

  List<WordAudioReleaseListTarget>? _legacyListTargetFromPackageJson(
    Map<String, dynamic> packageData,
  ) {
    final list = _listTargetFromJson(packageData);
    return list == null ? null : List.unmodifiable([list]);
  }

  WordAudioReleaseListTarget? _listTargetFromJson(Object? value) {
    if (value is! Map) return null;
    final listNumber = _asInt(value['listNumber']);
    final listId = _asInt(value['listId']);
    final listName = value['listName']?.toString().trim();
    if (listNumber == null ||
        listNumber < 1 ||
        listId == null ||
        listName == null ||
        listName.isEmpty) {
      return null;
    }
    return WordAudioReleaseListTarget(
      listNumber: listNumber,
      listId: listId,
      listName: listName,
    );
  }

  String _releaseSlugForLists(Iterable<WordAudioReleaseListTarget> lists) {
    final numbers = lists.map((list) => list.listNumber).toList()..sort();
    if (numbers.length == 1) return 'list${numbers.single}';

    // The full, exact List selection is persisted in the release report.
    // Keeping every number in a folder name made large batches exceed the
    // Windows/NTFS single-name limit before ZIP packaging could begin.
    return 'batch${numbers.first}-${numbers.last}-n${numbers.length}';
  }

  bool _isWithinRoot(Directory root, Directory child) {
    final rootPath = p.normalize(root.absolute.path);
    final childPath = p.normalize(child.absolute.path);
    return p.equals(rootPath, childPath) || p.isWithin(rootPath, childPath);
  }

  int? _asInt(Object? value) => value is num ? value.toInt() : null;

  String _powerShellSingleQuoted(String value) =>
      "'${value.replaceAll("'", "''")}'";

  String _trimLog(String value) {
    const limit = 12000;
    return value.length <= limit
        ? value
        : value.substring(value.length - limit);
  }

  void _ensureWindows() {
    if (!_isWindows()) {
      throw const WordAudioReleaseUnsupportedPlatformException();
    }
  }

  static Future<File> _defaultPublisherScriptLocator() async {
    final roots = <Directory>[Directory.current, Directory(r'D:\LingoDemo')];
    for (final root in roots) {
      var directory = root;
      for (var depth = 0; depth < 8; depth++) {
        final candidate = File(
          p.join(
            directory.path,
            'deploy',
            'lighthouse',
            'publish-word-audio.ps1',
          ),
        );
        if (await candidate.exists()) return candidate;
        final parent = directory.parent;
        if (p.equals(parent.path, directory.path)) break;
        directory = parent;
      }
    }
    throw const WordAudioReleaseException(
      'Could not find deploy/lighthouse/publish-word-audio.ps1.',
    );
  }

  static Future<WordAudioPublisherResult> _runPowerShellPublisher(
    WordAudioPublisherInvocation invocation,
  ) async {
    final arguments = <String>[
      '-NoLogo',
      '-NoProfile',
      '-NonInteractive',
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      invocation.script.path,
      '-ListNumber',
      invocation.listNumber.toString(),
      '-SourceDirectory',
      invocation.sourceDirectory.path,
      '-ExpectedCount',
      invocation.expectedCount.toString(),
      if (invocation.releaseKind != 'word') ...[
        '-ReleaseKind',
        invocation.releaseKind,
      ],
      if (invocation.verifyOnly) '-VerifyOnly',
    ];
    try {
      final process = await Process.start(
        'powershell.exe',
        arguments,
        mode: ProcessStartMode.normal,
      );
      await process.stdin.close();
      final output = StringBuffer();

      Future<void> collect(Stream<List<int>> stream) async {
        // Windows PowerShell can append a localized non-UTF-8 error after
        // otherwise ASCII publisher output (for example, an SSH sudo prompt).
        // Keep the useful ASCII lines instead of allowing one malformed byte
        // to hide the publisher result and its interactive-sudo signal.
        await for (final chunk in stream.transform(
          const Utf8Decoder(allowMalformed: true),
        )) {
          output.write(chunk);
          for (final line in const LineSplitter().convert(chunk)) {
            final trimmed = line.trimRight();
            if (trimmed.isNotEmpty) invocation.onLog?.call(trimmed);
          }
        }
      }

      await Future.wait([collect(process.stdout), collect(process.stderr)]);
      final exitCode = await process.exitCode;
      return WordAudioPublisherResult(
        exitCode: exitCode,
        output: output.toString(),
      );
    } on ProcessException catch (error) {
      return WordAudioPublisherResult(exitCode: -1, output: error.message);
    }
  }
}
