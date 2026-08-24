import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../../data/repositories/repositories.dart';
import '../data_dir.dart';
import '../utils/text_normalizer.dart';
import 'remote_word_audio_client.dart';
import 'tts_adapters/qwen_tts_adapter.dart';
import 'tts_provider.dart';

/// A single repair makes one normal request and can retry twice only when the
/// service receives a retryable transport/server failure or an invalid WAV.
const int wordAudioRepairMaxRetries = 2;

const _wordAudioRepairProvider = 'qwen';
const _wordAudioRepairLanguage = 'en';

final _repairableEnglishWord = RegExp(r"^[A-Za-z]+(?:[ '\-][A-Za-z]+)*$");

enum WordAudioRepairFailure {
  invalidWord,
  missingApiKey,
  missingWorkspaceId,
  synthesisFailed,
  invalidStagedAudio,
  stagedAudioMissing,
  applyFailed,
  restoreUnavailable,
  restoreFailed,
  cancelled,
  unknown,
}

/// A typed, non-sensitive failure intended for the UI to map to AppStrings.
class WordAudioRepairException implements Exception {
  final WordAudioRepairFailure failure;

  const WordAudioRepairException(this.failure);

  @override
  String toString() => 'word_audio_repair_${failure.name}';
}

class _InvalidRepairWavException implements Exception {
  final QwenWordAudioValidationFailure failure;

  const _InvalidRepairWavException(this.failure);
}

/// The currently approved Qwen word-audio configuration. The model, voice,
/// WAV format, and profile remain fixed in [QwenTtsAdapter].
class WordAudioRepairTtsConfig {
  final String apiKey;
  final String baseUrl;
  final String workspaceId;

  const WordAudioRepairTtsConfig({
    required this.apiKey,
    required this.baseUrl,
    required this.workspaceId,
  });
}

/// User-entered pronunciation context. IPA here is semantic guidance for the
/// model instruction, not a Qwen phoneme/SSML control field.
class WordAudioRepairRequest {
  final String word;
  final String partOfSpeech;
  final String ipa;
  final String note;

  const WordAudioRepairRequest({
    required this.word,
    this.partOfSpeech = '',
    this.ipa = '',
    this.note = '',
  });
}

/// The immutable scope that the maintainer reviews before a paid call.
class WordAudioRepairPlan {
  final WordAudioRepairRequest request;
  final String word;
  final String language;
  final String instruction;
  final File targetFile;
  final bool hasExistingFile;
  final bool existingFileIsValid;

  const WordAudioRepairPlan({
    required this.request,
    required this.word,
    required this.language,
    required this.instruction,
    required this.targetFile,
    required this.hasExistingFile,
    required this.existingFileIsValid,
  });

  int get normalCalls => 1;
  int get maxAttempts => wordAudioRepairMaxRetries + 1;
  String get audioFileName => p.basename(targetFile.path);
}

class WordAudioRepairProgress {
  final int attempt;
  final int maxAttempts;

  const WordAudioRepairProgress({
    required this.attempt,
    required this.maxAttempts,
  });
}

/// A validated WAV that has not changed the formal cache yet.
class WordAudioRepairStagedAudio {
  final String operationId;
  final WordAudioRepairPlan plan;
  final File stagedFile;
  final File auditFile;
  final Uint8List audioBytes;
  final TtsSynthesisResult synthesis;
  final int apiCalls;

  const WordAudioRepairStagedAudio({
    required this.operationId,
    required this.plan,
    required this.stagedFile,
    required this.auditFile,
    required this.audioBytes,
    required this.synthesis,
    required this.apiCalls,
  });
}

/// The result of accepting a staged WAV into the formal local v2 cache.
class WordAudioRepairApplyResult {
  final WordAudioRepairStagedAudio staged;
  final File targetFile;
  final File? backupFile;
  final File auditFile;

  const WordAudioRepairApplyResult({
    required this.staged,
    required this.targetFile,
    required this.backupFile,
    required this.auditFile,
  });

  bool get replacedExistingAudio => backupFile != null;
}

class WordAudioRepairRestoreResult {
  final WordAudioRepairApplyResult applied;
  final File targetFile;
  final File? displacedRepairFile;

  const WordAudioRepairRestoreResult({
    required this.applied,
    required this.targetFile,
    required this.displacedRepairFile,
  });
}

typedef WordAudioRepairSynthesis =
    Future<TtsSynthesisResult> Function({
      required WordAudioRepairTtsConfig config,
      required String text,
      required String instruction,
      required String language,
    });

/// Local-only single-word repair workflow.
///
/// Cloud output always lands in a dedicated staging directory first. A user
/// must separately accept the staged file before the canonical v2 cache is
/// changed. This service intentionally contains no upload or server-publish
/// capability.
class WordAudioRepairService {
  WordAudioRepairService({
    TtsRepository? ttsRepository,
    Future<Directory> Function()? dataDirProvider,
    WordAudioRepairSynthesis? synthesis,
    DateTime Function()? now,
  }) : _ttsRepository = ttsRepository,
       _dataDirProvider = dataDirProvider ?? getLingoDataDir,
       _synthesis = synthesis ?? _synthesizeWithQwen,
       _now = now ?? DateTime.now;

  final TtsRepository? _ttsRepository;
  final Future<Directory> Function() _dataDirProvider;
  final WordAudioRepairSynthesis _synthesis;
  final DateTime Function() _now;
  int _operationCounter = 0;

  Future<WordAudioRepairPlan> createPlan(WordAudioRepairRequest request) async {
    final word = _normalize(request.word);
    if (!_repairableEnglishWord.hasMatch(word)) {
      throw const WordAudioRepairException(WordAudioRepairFailure.invalidWord);
    }

    final root = await _ensureRoot();
    final cacheDirectory = await _ensureDirectory(
      p.join(root.path, 'lingo_tts_cache'),
    );
    final targetFile = File(
      p.join(
        cacheDirectory.path,
        RemoteWordAudioClient.audioFileNameFor(
          word,
          language: _wordAudioRepairLanguage,
        ),
      ),
    );
    final hasExistingFile = await targetFile.exists();
    final existingBytes = hasExistingFile
        ? await _readValidatedWav(targetFile)
        : null;

    final normalizedRequest = WordAudioRepairRequest(
      word: word,
      partOfSpeech: _normalize(request.partOfSpeech),
      ipa: _normalize(request.ipa),
      note: _normalize(request.note),
    );

    return WordAudioRepairPlan(
      request: normalizedRequest,
      word: word,
      language: _wordAudioRepairLanguage,
      instruction: _instructionFor(normalizedRequest, word),
      targetFile: targetFile,
      hasExistingFile: hasExistingFile,
      existingFileIsValid: existingBytes != null,
    );
  }

  /// Returns an existing canonical WAV only when it still passes the approved
  /// production-format validation.
  Future<Uint8List?> readCurrentAudio(WordAudioRepairPlan plan) {
    return _readValidatedWav(plan.targetFile);
  }

  /// Makes at most [WordAudioRepairPlan.maxAttempts] cloud requests and keeps
  /// the successful, validated output in staging until [applyStagedAudio].
  Future<WordAudioRepairStagedAudio> generateStagedAudio(
    WordAudioRepairPlan plan,
    WordAudioRepairTtsConfig config, {
    bool Function()? shouldCancel,
    void Function(WordAudioRepairProgress progress)? onProgress,
  }) async {
    _validateConfig(config);
    final operationId = _newOperationId();
    final maxAttempts = plan.maxAttempts;
    TtsSynthesisResult? successfulSynthesis;
    Uint8List? successfulBytes;
    Object? terminalError;
    var apiCalls = 0;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      if (shouldCancel?.call() == true) {
        await _writeFailureAudit(
          operationId: operationId,
          plan: plan,
          apiCalls: apiCalls,
          failure: WordAudioRepairFailure.cancelled,
        );
        throw const WordAudioRepairException(WordAudioRepairFailure.cancelled);
      }
      onProgress?.call(
        WordAudioRepairProgress(attempt: attempt, maxAttempts: maxAttempts),
      );

      try {
        apiCalls++;
        final synthesis = await _synthesis(
          config: config,
          text: plan.word,
          instruction: plan.instruction,
          language: plan.language,
        );
        final validation = QwenTtsAdapter.wordAudioValidationFailure(
          synthesis.audioBytes,
        );
        if (validation != null) {
          throw _InvalidRepairWavException(validation);
        }
        successfulSynthesis = synthesis;
        successfulBytes = synthesis.audioBytes;
        break;
      } catch (error) {
        terminalError = error;
        if (attempt < maxAttempts && _isRetryable(error)) {
          await Future<void>.delayed(_retryDelay(attempt));
          continue;
        }
        break;
      }
    }

    if (successfulSynthesis == null || successfulBytes == null) {
      final failure =
          terminalError is _InvalidRepairWavException ||
              terminalError is QwenWordAudioValidationException
          ? WordAudioRepairFailure.invalidStagedAudio
          : WordAudioRepairFailure.synthesisFailed;
      await _recordUsageFailure(plan, config);
      await _writeFailureAudit(
        operationId: operationId,
        plan: plan,
        apiCalls: apiCalls,
        failure: failure,
      );
      throw WordAudioRepairException(failure);
    }

    try {
      final stageDirectory = await _ensureDirectoryFor(
        'lingo_tts_repair_staging',
      );
      final stagedFile = File(
        p.join(stageDirectory.path, '${_safeSlug(plan.word)}_$operationId.wav'),
      );
      await _writeNewFileAtomically(stagedFile, successfulBytes, operationId);
      final stagedBytes = await _readValidatedWav(stagedFile);
      if (stagedBytes == null) {
        throw const WordAudioRepairException(
          WordAudioRepairFailure.invalidStagedAudio,
        );
      }
      final auditFile = await _writeAudit(
        operationId: operationId,
        plan: plan,
        status: 'staged',
        apiCalls: apiCalls,
        synthesis: successfulSynthesis,
        stagedFile: stagedFile,
      );
      await _recordUsageSuccess(plan, config, successfulSynthesis);
      return WordAudioRepairStagedAudio(
        operationId: operationId,
        plan: plan,
        stagedFile: stagedFile,
        auditFile: auditFile,
        audioBytes: stagedBytes,
        synthesis: successfulSynthesis,
        apiCalls: apiCalls,
      );
    } on WordAudioRepairException {
      rethrow;
    } catch (_) {
      await _writeFailureAudit(
        operationId: operationId,
        plan: plan,
        apiCalls: apiCalls,
        failure: WordAudioRepairFailure.unknown,
      );
      throw const WordAudioRepairException(WordAudioRepairFailure.unknown);
    }
  }

  /// Backs up the old cache file, then replaces it with a staged WAV. The old
  /// file is moved rather than deleted so a failed replacement can be rolled
  /// back without regenerating anything.
  Future<WordAudioRepairApplyResult> applyStagedAudio(
    WordAudioRepairStagedAudio staged,
  ) async {
    final stagedBytes = await _readValidatedWav(staged.stagedFile);
    if (stagedBytes == null) {
      throw const WordAudioRepairException(
        WordAudioRepairFailure.stagedAudioMissing,
      );
    }

    final plan = staged.plan;
    final operationId = _newOperationId();
    final target = plan.targetFile;
    await _ensureDirectory(p.dirname(target.path));
    final incoming = File('${target.path}.$operationId.repair');
    File? backupFile;
    var oldAudioMoved = false;

    try {
      await _writeNewFileAtomically(incoming, stagedBytes, operationId);
      if (await target.exists()) {
        final backupDirectory = await _ensureDirectoryFor(
          'lingo_tts_repair_backups',
        );
        backupFile = File(
          p.join(
            backupDirectory.path,
            '${_safeSlug(plan.word)}_before_${_now().millisecondsSinceEpoch}-${plan.audioFileName}',
          ),
        );
        await target.rename(backupFile.path);
        oldAudioMoved = true;
      }
      await incoming.rename(target.path);
    } catch (_) {
      await _deleteIfExists(incoming);
      if (oldAudioMoved &&
          backupFile != null &&
          await backupFile.exists() &&
          !await target.exists()) {
        try {
          await backupFile.rename(target.path);
        } catch (_) {
          // The backup stays on disk even if an OS-level rollback fails.
        }
      }
      await _writeAudit(
        operationId: staged.operationId,
        plan: plan,
        status: 'apply_failed',
        apiCalls: staged.apiCalls,
        synthesis: staged.synthesis,
        stagedFile: staged.stagedFile,
        backupFile: backupFile,
        failure: WordAudioRepairFailure.applyFailed,
      );
      throw const WordAudioRepairException(WordAudioRepairFailure.applyFailed);
    }

    try {
      await _recordCachedAudio(plan, staged.synthesis, stagedBytes.length);
    } catch (_) {
      await _rollbackCacheAfterRecordFailure(
        target: target,
        backupFile: backupFile,
        operationId: operationId,
      );
      await _writeAudit(
        operationId: staged.operationId,
        plan: plan,
        status: 'apply_failed',
        apiCalls: staged.apiCalls,
        synthesis: staged.synthesis,
        stagedFile: staged.stagedFile,
        backupFile: backupFile,
        failure: WordAudioRepairFailure.applyFailed,
      );
      throw const WordAudioRepairException(WordAudioRepairFailure.applyFailed);
    }

    final auditFile = await _writeAudit(
      operationId: staged.operationId,
      plan: plan,
      status: 'applied_local',
      apiCalls: staged.apiCalls,
      synthesis: staged.synthesis,
      stagedFile: staged.stagedFile,
      backupFile: backupFile,
    );
    return WordAudioRepairApplyResult(
      staged: staged,
      targetFile: target,
      backupFile: backupFile,
      auditFile: auditFile,
    );
  }

  /// Restores the pre-repair WAV from the backup retained by
  /// [applyStagedAudio]. The replacement is preserved in the backup directory
  /// rather than silently deleted.
  Future<WordAudioRepairRestoreResult> restorePreviousAudio(
    WordAudioRepairApplyResult applied,
  ) async {
    final backupFile = applied.backupFile;
    if (backupFile == null || !await backupFile.exists()) {
      throw const WordAudioRepairException(
        WordAudioRepairFailure.restoreUnavailable,
      );
    }
    final backupBytes = await _readValidatedWav(backupFile);
    if (backupBytes == null) {
      throw const WordAudioRepairException(
        WordAudioRepairFailure.restoreUnavailable,
      );
    }

    final operationId = _newOperationId();
    final target = applied.targetFile;
    final restoreIncoming = File('${target.path}.$operationId.restore');
    File? displacedRepairFile;
    var replacementMoved = false;

    try {
      await _writeNewFileAtomically(restoreIncoming, backupBytes, operationId);
      if (await target.exists()) {
        final backupDirectory = await _ensureDirectoryFor(
          'lingo_tts_repair_backups',
        );
        displacedRepairFile = File(
          p.join(
            backupDirectory.path,
            '${_safeSlug(applied.staged.plan.word)}_replaced_${_now().millisecondsSinceEpoch}-${applied.staged.plan.audioFileName}',
          ),
        );
        await target.rename(displacedRepairFile.path);
        replacementMoved = true;
      }
      await restoreIncoming.rename(target.path);
      await _recordCachedAudio(applied.staged.plan, null, backupBytes.length);
    } catch (_) {
      await _deleteIfExists(restoreIncoming);
      if (replacementMoved &&
          displacedRepairFile != null &&
          await displacedRepairFile.exists() &&
          !await target.exists()) {
        try {
          await displacedRepairFile.rename(target.path);
        } catch (_) {
          // Preserve the displaced file for manual recovery if rollback fails.
        }
      }
      await _writeAudit(
        operationId: applied.staged.operationId,
        plan: applied.staged.plan,
        status: 'restore_failed',
        apiCalls: applied.staged.apiCalls,
        synthesis: applied.staged.synthesis,
        stagedFile: applied.staged.stagedFile,
        backupFile: backupFile,
        failure: WordAudioRepairFailure.restoreFailed,
      );
      throw const WordAudioRepairException(
        WordAudioRepairFailure.restoreFailed,
      );
    }

    await _writeAudit(
      operationId: applied.staged.operationId,
      plan: applied.staged.plan,
      status: 'restored_local',
      apiCalls: applied.staged.apiCalls,
      synthesis: applied.staged.synthesis,
      stagedFile: applied.staged.stagedFile,
      backupFile: backupFile,
      displacedRepairFile: displacedRepairFile,
    );
    return WordAudioRepairRestoreResult(
      applied: applied,
      targetFile: target,
      displacedRepairFile: displacedRepairFile,
    );
  }

  /// Discarding a staged candidate never changes the formal cache or server.
  Future<void> discardStagedAudio(WordAudioRepairStagedAudio staged) async {
    await _writeAudit(
      operationId: staged.operationId,
      plan: staged.plan,
      status: 'discarded',
      apiCalls: staged.apiCalls,
      synthesis: staged.synthesis,
      stagedFile: staged.stagedFile,
    );
    await _deleteIfExists(staged.stagedFile);
  }

  static Future<TtsSynthesisResult> _synthesizeWithQwen({
    required WordAudioRepairTtsConfig config,
    required String text,
    required String instruction,
    required String language,
  }) {
    final adapter = QwenTtsAdapter(
      apiKey: config.apiKey,
      workspaceId: config.workspaceId,
      baseUrl: config.baseUrl,
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
    return adapter.synthesizeWithMetadata(text, language: language);
  }

  void _validateConfig(WordAudioRepairTtsConfig config) {
    if (config.apiKey.trim().isEmpty) {
      throw const WordAudioRepairException(
        WordAudioRepairFailure.missingApiKey,
      );
    }
    if (config.workspaceId.trim().isEmpty) {
      throw const WordAudioRepairException(
        WordAudioRepairFailure.missingWorkspaceId,
      );
    }
  }

  String _instructionFor(WordAudioRepairRequest request, String word) {
    final partOfSpeech = _normalize(request.partOfSpeech);
    final ipa = _normalize(request.ipa);
    final note = _normalize(request.note);
    final clauses = <String>[
      QwenTtsAdapter.wordInstruction,
      '仅朗读英语单词“$word”一次',
      if (partOfSpeech.isNotEmpty) '目标词性为$partOfSpeech',
      if (ipa.isNotEmpty) '目标英式读音为$ipa',
      if (note.isNotEmpty) note,
    ];
    return clauses.join('。');
  }

  bool _isRetryable(Object error) {
    if (error is _InvalidRepairWavException ||
        error is QwenWordAudioValidationException ||
        error is TimeoutException ||
        error is SocketException) {
      return true;
    }
    return RegExp(r'Qwen TTS HTTP (?:429|5\d\d):').hasMatch(error.toString());
  }

  Duration _retryDelay(int completedAttempt) {
    const seconds = [1, 3];
    final index = (completedAttempt - 1).clamp(0, seconds.length - 1);
    return Duration(seconds: seconds[index]);
  }

  Future<Directory> _ensureRoot() async {
    final root = await _dataDirProvider();
    if (!await root.exists()) await root.create(recursive: true);
    return root;
  }

  Future<Directory> _ensureDirectoryFor(String name) async {
    final root = await _ensureRoot();
    return _ensureDirectory(p.join(root.path, name));
  }

  Future<Directory> _ensureDirectory(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) await directory.create(recursive: true);
    return directory;
  }

  Future<Uint8List?> _readValidatedWav(File file) async {
    try {
      if (!await file.exists() || await file.length() <= 0) return null;
      final bytes = await file.readAsBytes();
      return QwenTtsAdapter.wordAudioValidationFailure(bytes) == null
          ? bytes
          : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeNewFileAtomically(
    File target,
    Uint8List bytes,
    String operationId,
  ) async {
    await _ensureDirectory(p.dirname(target.path));
    final temporary = File('${target.path}.$operationId.part');
    await _deleteIfExists(temporary);
    try {
      await temporary.writeAsBytes(bytes, flush: true);
      final validated = await _readValidatedWav(temporary);
      if (validated == null) {
        throw const WordAudioRepairException(
          WordAudioRepairFailure.invalidStagedAudio,
        );
      }
      if (await target.exists()) {
        throw const WordAudioRepairException(
          WordAudioRepairFailure.applyFailed,
        );
      }
      await temporary.rename(target.path);
    } finally {
      await _deleteIfExists(temporary);
    }
  }

  Future<void> _rollbackCacheAfterRecordFailure({
    required File target,
    required File? backupFile,
    required String operationId,
  }) async {
    if (await target.exists()) {
      final backupDirectory = await _ensureDirectoryFor(
        'lingo_tts_repair_backups',
      );
      final uncommitted = File(
        p.join(
          backupDirectory.path,
          'uncommitted_$operationId-${p.basename(target.path)}',
        ),
      );
      try {
        await target.rename(uncommitted.path);
      } catch (_) {
        // Retain the file in place if Windows has temporarily locked it.
      }
    }
    if (backupFile != null &&
        await backupFile.exists() &&
        !await target.exists()) {
      try {
        await backupFile.rename(target.path);
      } catch (_) {
        // Both files remain available for manual recovery.
      }
    }
  }

  Future<void> _recordUsageSuccess(
    WordAudioRepairPlan plan,
    WordAudioRepairTtsConfig config,
    TtsSynthesisResult synthesis,
  ) {
    final repository = _ttsRepository;
    if (repository == null) return Future.value();
    return repository.insertUsageRecord(
      provider: _wordAudioRepairProvider,
      action: 'repair',
      text: plan.word,
      language: plan.language,
      model: QwenTtsAdapter.wordModel,
      voice: QwenTtsAdapter.wordVoice,
      resourceId: config.workspaceId,
      chargedCharacters: synthesis.chargedCharacters,
      audioBytes: synthesis.audioBytes.length,
      durationMs: synthesis.durationMs,
      requestId: synthesis.requestId,
      logId: synthesis.logId,
      status: 'success',
    );
  }

  Future<void> _recordUsageFailure(
    WordAudioRepairPlan plan,
    WordAudioRepairTtsConfig config,
  ) async {
    final repository = _ttsRepository;
    if (repository == null) return;
    try {
      await repository.insertUsageRecord(
        provider: _wordAudioRepairProvider,
        action: 'repair',
        text: plan.word,
        language: plan.language,
        model: QwenTtsAdapter.wordModel,
        voice: QwenTtsAdapter.wordVoice,
        resourceId: config.workspaceId,
        status: 'failed',
      );
    } catch (_) {
      // The primary repair error is more actionable than a secondary audit-row
      // failure. The on-disk audit still records the terminal state.
    }
  }

  Future<void> _recordCachedAudio(
    WordAudioRepairPlan plan,
    TtsSynthesisResult? synthesis,
    int audioBytes,
  ) {
    final repository = _ttsRepository;
    if (repository == null) return Future.value();
    return repository.upsertCacheRecord(
      provider: _wordAudioRepairProvider,
      language: plan.language,
      text: plan.word,
      cacheKey: RemoteWordAudioClient.audioKeyFor(
        plan.word,
        language: plan.language,
      ),
      status: 'cached',
      cachePath: plan.targetFile.path,
      audioBytes: audioBytes,
      chargedCharacters: synthesis?.chargedCharacters,
    );
  }

  Future<File> _writeFailureAudit({
    required String operationId,
    required WordAudioRepairPlan plan,
    required int apiCalls,
    required WordAudioRepairFailure failure,
  }) {
    return _writeAudit(
      operationId: operationId,
      plan: plan,
      status: 'failed',
      apiCalls: apiCalls,
      failure: failure,
    );
  }

  Future<File> _writeAudit({
    required String operationId,
    required WordAudioRepairPlan plan,
    required String status,
    required int apiCalls,
    TtsSynthesisResult? synthesis,
    File? stagedFile,
    File? backupFile,
    File? displacedRepairFile,
    WordAudioRepairFailure? failure,
  }) async {
    final directory = await _ensureDirectoryFor('lingo_tts_repair_audits');
    final file = File(
      p.join(directory.path, '${_safeSlug(plan.word)}_$operationId.json'),
    );
    final payload = <String, dynamic>{
      'schemaVersion': 1,
      'updatedAt': _now().toUtc().toIso8601String(),
      'operationId': operationId,
      'status': status,
      'scope': 'local_cache_only',
      'serverPublished': false,
      'profileVersion': QwenTtsAdapter.wordCacheProfileVersion,
      'word': plan.word,
      'language': plan.language,
      'target': {
        'partOfSpeech': plan.request.partOfSpeech,
        'ipa': plan.request.ipa,
        'note': plan.request.note,
        'instruction': plan.instruction,
      },
      'cache': {
        'fileName': plan.audioFileName,
        'path': plan.targetFile.path,
        'hadExistingFile': plan.hasExistingFile,
        'existingFileWasValid': plan.existingFileIsValid,
      },
      'authorization': {
        'normalCalls': plan.normalCalls,
        'maxAttempts': plan.maxAttempts,
      },
      'result': {
        'apiCalls': apiCalls,
        'chargedCharacters': synthesis?.chargedCharacters,
        'audioBytes': synthesis?.audioBytes.length,
        'durationMs': synthesis?.durationMs,
        'requestId': synthesis?.requestId,
        'stagedFile': stagedFile?.path,
        'backupFile': backupFile?.path,
        'displacedRepairFile': displacedRepairFile?.path,
      },
      if (failure != null) 'failure': failure.name,
    };
    await _writeJsonAtomically(file, payload, operationId);
    return file;
  }

  Future<void> _writeJsonAtomically(
    File target,
    Map<String, dynamic> payload,
    String operationId,
  ) async {
    await _ensureDirectory(p.dirname(target.path));
    final temporary = File('${target.path}.$operationId.part');
    await _deleteIfExists(temporary);
    try {
      await temporary.writeAsString(
        const JsonEncoder.withIndent('  ').convert(payload),
        flush: true,
      );
      if (await target.exists()) await target.delete();
      await temporary.rename(target.path);
    } finally {
      await _deleteIfExists(temporary);
    }
  }

  Future<void> _deleteIfExists(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {
      // A leftover temporary artifact is safer than deleting an unrelated file.
    }
  }

  String _newOperationId() {
    _operationCounter++;
    return '${_now().toUtc().microsecondsSinceEpoch}_$_operationCounter';
  }

  String _normalize(String value) =>
      TextNormalizer.normalizeQuotes(value).trim();

  String _safeSlug(String value) {
    final normalized = value.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '_',
    );
    final trimmed = normalized.replaceAll(RegExp(r'^_+|_+$'), '');
    if (trimmed.isEmpty) return 'word';
    final end = trimmed.length > 48 ? 48 : trimmed.length;
    return trimmed.substring(0, end);
  }
}
