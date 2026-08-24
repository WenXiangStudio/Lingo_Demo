import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../data_dir.dart';
import 'remote_word_audio_client.dart';
import 'tts_adapters/qwen_tts_adapter.dart';
import 'word_audio_repair_service.dart';

/// A server-side action is deliberately separate from local repair.  Both
/// actions preserve the fixed v2 audio key; the server changes only after the
/// maintainer has reviewed a plan and explicitly confirms it in the UI.
enum WordAudioServerOperationAction { replace, rollback }

enum WordAudioServerReplaceFailure {
  unsupportedPlatform,
  localCandidateMissing,
  localCandidateInvalid,
  serverNotConfigured,
  serverAddressInvalid,
  remoteAudioMissing,
  remoteAudioInvalid,
  remoteUnavailable,
  remoteChanged,
  serverAddressChanged,
  rollbackUnavailable,
  publishFailed,
  publishMayHaveChanged,
  unknown,
}

/// A typed, non-sensitive outcome for the maintenance UI. Raw server command
/// output is never exposed; an optional diagnostic is redacted and bounded.
class WordAudioServerReplaceException implements Exception {
  final WordAudioServerReplaceFailure failure;
  final WordAudioServerPublisherResult? publisher;
  final String? diagnosticOutput;

  const WordAudioServerReplaceException(
    this.failure, {
    this.publisher,
    this.diagnosticOutput,
  });

  /// A bounded, redacted diagnostic suitable for the maintenance UI and the
  /// local audit. Publisher output itself stays private to this service.
  String? get safeDiagnosticOutput {
    final supplied = diagnosticOutput;
    if (supplied != null && supplied.trim().isNotEmpty) {
      return _sanitizePublisherDiagnostic(supplied);
    }
    final fromPublisher = publisher?.diagnosticOutput;
    return fromPublisher == null || fromPublisher.isEmpty
        ? null
        : fromPublisher;
  }

  @override
  String toString() => 'word_audio_server_replace_${failure.name}';
}

class WordAudioServerReplacementPlan {
  final String operationId;
  final WordAudioRepairPlan repairPlan;
  final String baseUrl;
  final Uri remoteUri;
  final File localCandidateFile;
  final Uint8List localCandidateBytes;
  final String localCandidateSha256;
  final Uint8List remoteCurrentBytes;
  final String remoteCurrentSha256;
  final DateTime createdAt;

  const WordAudioServerReplacementPlan({
    required this.operationId,
    required this.repairPlan,
    required this.baseUrl,
    required this.remoteUri,
    required this.localCandidateFile,
    required this.localCandidateBytes,
    required this.localCandidateSha256,
    required this.remoteCurrentBytes,
    required this.remoteCurrentSha256,
    required this.createdAt,
  });

  String get word => repairPlan.word;
  String get language => repairPlan.language;
  String get audioFileName => repairPlan.audioFileName;
  int get localCandidateBytesLength => localCandidateBytes.length;
  int get remoteCurrentBytesLength => remoteCurrentBytes.length;

  /// No server command is needed when the active fixed-key resource already
  /// contains the exact reviewed local bytes.
  bool get isAlreadyPublished => localCandidateSha256 == remoteCurrentSha256;
}

/// A durable local reference to one successful (or possibly successful) fixed
/// key replacement.  The original server file itself remains in the protected
/// server backup directory; this record contains only its identifier and hash.
class WordAudioServerReplacementRecord {
  final File auditFile;
  final String operationId;
  final String word;
  final String language;
  final String baseUrl;
  final String audioFileName;
  final String previousSha256;
  final int previousBytesLength;
  final String activeSha256;
  final int activeBytesLength;
  final String serverBackupId;
  final String? serverBackupPath;
  final DateTime updatedAt;
  final bool rolledBack;
  final bool needsVerification;

  const WordAudioServerReplacementRecord({
    required this.auditFile,
    required this.operationId,
    required this.word,
    required this.language,
    required this.baseUrl,
    required this.audioFileName,
    required this.previousSha256,
    required this.previousBytesLength,
    required this.activeSha256,
    required this.activeBytesLength,
    required this.serverBackupId,
    required this.serverBackupPath,
    required this.updatedAt,
    required this.rolledBack,
    required this.needsVerification,
  });
}

class WordAudioServerRollbackPlan {
  final String operationId;
  final WordAudioServerReplacementRecord replacement;
  final Uri remoteUri;
  final Uint8List currentRemoteBytes;
  final String currentRemoteSha256;
  final DateTime createdAt;

  const WordAudioServerRollbackPlan({
    required this.operationId,
    required this.replacement,
    required this.remoteUri,
    required this.currentRemoteBytes,
    required this.currentRemoteSha256,
    required this.createdAt,
  });

  String get word => replacement.word;
  String get language => replacement.language;
  String get audioFileName => replacement.audioFileName;
  String get baseUrl => replacement.baseUrl;
  String get restoreSha256 => replacement.previousSha256;
  int get restoreBytesLength => replacement.previousBytesLength;
  String get serverBackupId => replacement.serverBackupId;
  String get rollbackBackupId => 'rollback_$operationId';
}

class WordAudioServerPublisherInvocation {
  final File script;
  final WordAudioServerOperationAction action;
  final String baseUrl;
  final String audioFileName;
  final File? localCandidateFile;
  final String expectedCurrentSha256;
  final String expectedResultSha256;
  final int expectedResultBytesLength;
  final String operationId;
  final String? serverBackupId;
  final void Function(String line)? onLog;

  const WordAudioServerPublisherInvocation({
    required this.script,
    required this.action,
    required this.baseUrl,
    required this.audioFileName,
    required this.localCandidateFile,
    required this.expectedCurrentSha256,
    required this.expectedResultSha256,
    required this.expectedResultBytesLength,
    required this.operationId,
    required this.serverBackupId,
    this.onLog,
  });
}

class WordAudioServerPublisherResult {
  final int exitCode;
  final String output;

  const WordAudioServerPublisherResult({
    required this.exitCode,
    required this.output,
  });

  bool get succeeded => exitCode == 0;

  /// Never expose the raw PowerShell/SSH output to widgets or audit files.
  String get diagnosticOutput => _sanitizePublisherDiagnostic(output);
}

const _publisherDiagnosticLimit = 8000;
const _publisherDiagnosticLineLimit = 1200;

/// Publisher output can contain environment-specific SSH errors. Keep enough
/// recent context to diagnose an operation, while explicitly avoiding storage
/// or display of credentials, private-key paths, and overlong output.
String _sanitizePublisherDiagnostic(String output) {
  var value = output.replaceAll('\u0000', '');
  value = value.replaceAllMapped(
    RegExp(
      r'''\bidentityfile\b\s*(?:[:=]\s*|\s+)(?:"[^"]*"|'[^']*'|\S+)''',
      caseSensitive: false,
      multiLine: true,
    ),
    (_) => 'IdentityFile <redacted-identity-file>',
  );
  value = value.replaceAllMapped(
    RegExp(r'''(^|\s)-i\s+(?:"[^"]*"|'[^']*'|\S+)''', multiLine: true),
    (match) => '${match.group(1) ?? ''}-i <redacted-identity-file>',
  );
  value = value.replaceAllMapped(
    RegExp(
      r'''-----BEGIN [^-]*PRIVATE KEY-----.*?-----END [^-]*PRIVATE KEY-----''',
      caseSensitive: false,
      dotAll: true,
    ),
    (_) => '<redacted-private-key>',
  );
  value = value.replaceAllMapped(
    RegExp(
      r'''(?:[a-z]:\\|/)(?:[^\r\n\\/:"']+[\\/])*(?:id_(?:rsa|dsa|ecdsa|ed25519)|[^\\/\r\n\s:"']*?(?:ed25519|rsa|ecdsa|dsa)(?:\.pub)?|[^\\/\r\n\s:"']+\.(?:pem|ppk|key))(?:\.pub)?''',
      caseSensitive: false,
    ),
    (_) => '<redacted-identity-file>',
  );
  value = value.replaceAllMapped(
    RegExp(r'(https?://)[^/\s:@]+:[^@\s/]+@', caseSensitive: false),
    (match) => '${match.group(1)}<redacted>@',
  );
  value = value.replaceAllMapped(
    RegExp(
      r'''^\s*(?:authorization|proxy-authorization)\s*:\s*[^\r\n]+''',
      caseSensitive: false,
      multiLine: true,
    ),
    (_) => '<redacted-authorization>',
  );
  value = value.replaceAllMapped(
    RegExp(
      r'''\b(?:password|passphrase|token|secret|api[-_ ]?key)\b(?:\s+for\s+[^:=\r\n]+)?\s*[:=]\s*[^\r\n]+''',
      caseSensitive: false,
      multiLine: true,
    ),
    (_) => '<redacted-credential>',
  );

  final lines = <String>[];
  for (final rawLine in const LineSplitter().convert(value)) {
    final line = rawLine.trimRight();
    if (line.isEmpty) continue;
    lines.add(
      line.length <= _publisherDiagnosticLineLimit
          ? line
          : '${line.substring(0, _publisherDiagnosticLineLimit)}…',
    );
  }
  var result = lines.join('\n');
  if (result.length > _publisherDiagnosticLimit) {
    result =
        '[Earlier publisher output omitted]\n'
        '${result.substring(result.length - _publisherDiagnosticLimit)}';
  }
  return result;
}

enum WordAudioServerOperationOutcome { completed, interactiveSudoRequired }

class WordAudioServerOperationResult {
  final WordAudioServerOperationAction action;
  final WordAudioServerOperationOutcome outcome;
  final WordAudioServerPublisherResult? publisher;
  final File? auditFile;
  final String? serverBackupId;
  final String? serverBackupPath;

  const WordAudioServerOperationResult({
    required this.action,
    required this.outcome,
    this.publisher,
    this.auditFile,
    this.serverBackupId,
    this.serverBackupPath,
  });
}

typedef WordAudioServerPublisher =
    Future<WordAudioServerPublisherResult> Function(
      WordAudioServerPublisherInvocation invocation,
    );

typedef WordAudioServerPublisherScriptLocator = Future<File> Function();
typedef WordAudioServerRemoteClientFactory =
    RemoteWordAudioClient Function(String baseUrl);

/// Executes one guarded server replacement at the existing fixed word-audio
/// URL.  It does not synthesize audio and never changes the generic batch
/// publisher's conflict-protection policy.
class WordAudioServerReplaceService {
  WordAudioServerReplaceService({
    Future<Directory> Function()? dataDirProvider,
    bool Function()? isWindows,
    WordAudioServerPublisher? publisher,
    WordAudioServerPublisherScriptLocator? publisherScriptLocator,
    WordAudioServerRemoteClientFactory? remoteClientFactory,
    DateTime Function()? now,
  }) : _dataDirProvider = dataDirProvider ?? getLingoDataDir,
       _isWindows = isWindows ?? (() => Platform.isWindows),
       _publisher = publisher ?? _runPowerShellPublisher,
       _publisherScriptLocator =
           publisherScriptLocator ?? _defaultPublisherScriptLocator,
       _remoteClientFactory = remoteClientFactory ?? _defaultRemoteClient,
       _now = now ?? DateTime.now;

  final Future<Directory> Function() _dataDirProvider;
  final bool Function() _isWindows;
  final WordAudioServerPublisher _publisher;
  final WordAudioServerPublisherScriptLocator _publisherScriptLocator;
  final WordAudioServerRemoteClientFactory _remoteClientFactory;
  final DateTime Function() _now;
  int _operationCounter = 0;

  /// Reads the current fixed-key resource and the approved local v2 cache
  /// candidate.  This is a read-only step; the returned hashes are supplied to
  /// the server as a compare-and-swap precondition during [replace].
  Future<WordAudioServerReplacementPlan> createReplacementPlan({
    required WordAudioRepairPlan repairPlan,
    required String remoteBaseUrl,
  }) async {
    _ensureWindows();
    final localBytes = await _readValidatedLocalCandidate(
      repairPlan.targetFile,
    );
    if (localBytes == null) {
      final exists = await repairPlan.targetFile.exists();
      throw WordAudioServerReplaceException(
        exists
            ? WordAudioServerReplaceFailure.localCandidateInvalid
            : WordAudioServerReplaceFailure.localCandidateMissing,
      );
    }

    final remote = await _readRemoteSnapshot(
      baseUrl: remoteBaseUrl,
      word: repairPlan.word,
      language: repairPlan.language,
    );
    return WordAudioServerReplacementPlan(
      operationId: _newOperationId(),
      repairPlan: repairPlan,
      baseUrl: remote.client.baseUrl,
      remoteUri: remote.uri,
      localCandidateFile: repairPlan.targetFile,
      localCandidateBytes: localBytes,
      localCandidateSha256: _sha256(localBytes),
      remoteCurrentBytes: remote.bytes,
      remoteCurrentSha256: _sha256(remote.bytes),
      createdAt: _now().toUtc(),
    );
  }

  /// Uses the server backup identified by a prior local audit.  The current
  /// remote hash must still equal the replacement's published hash, preventing
  /// an old rollback plan from overwriting a later manual change.
  Future<WordAudioServerRollbackPlan> createRollbackPlan({
    required String word,
    required String language,
    required String remoteBaseUrl,
  }) async {
    _ensureWindows();
    final record = await loadLatestRollbackCandidate(
      word: word,
      language: language,
    );
    final normalizedBaseUrl = _normalizeBaseUrl(remoteBaseUrl);
    if (normalizedBaseUrl != record.baseUrl) {
      throw const WordAudioServerReplaceException(
        WordAudioServerReplaceFailure.serverAddressChanged,
      );
    }

    final remote = await _readRemoteSnapshot(
      baseUrl: normalizedBaseUrl,
      word: record.word,
      language: record.language,
    );
    final currentSha256 = _sha256(remote.bytes);
    if (currentSha256 != record.activeSha256) {
      throw const WordAudioServerReplaceException(
        WordAudioServerReplaceFailure.remoteChanged,
      );
    }
    return WordAudioServerRollbackPlan(
      operationId: _newOperationId(),
      replacement: record,
      remoteUri: remote.uri,
      currentRemoteBytes: remote.bytes,
      currentRemoteSha256: currentSha256,
      createdAt: _now().toUtc(),
    );
  }

  /// Finds the newest local replacement audit whose server backup has not
  /// already been restored.  The later [createRollbackPlan] still verifies the
  /// live server bytes before any UI can offer a rollback confirmation.
  Future<WordAudioServerReplacementRecord> loadLatestRollbackCandidate({
    required String word,
    required String language,
  }) async {
    final normalizedWord = RemoteWordAudioClient.normalizeWord(word);
    final normalizedLanguage = RemoteWordAudioClient.normalizeLanguage(
      language,
    );
    final directory = await _auditDirectory();
    final records = <WordAudioServerReplacementRecord>[];
    await for (final entity in directory.list()) {
      if (entity is! File ||
          p.extension(entity.path).toLowerCase() != '.json') {
        continue;
      }
      final record = await _readReplacementRecord(entity);
      if (record != null &&
          record.word == normalizedWord &&
          record.language == normalizedLanguage &&
          !record.rolledBack) {
        records.add(record);
      }
    }
    if (records.isEmpty) {
      throw const WordAudioServerReplaceException(
        WordAudioServerReplaceFailure.rollbackUnavailable,
      );
    }
    records.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return records.first;
  }

  /// Invokes the guarded replacement script.  Its server-side compare checks
  /// the hash observed in [createReplacementPlan] again while holding a per
  /// file lock, backs up the old WAV, atomically moves the new file into the
  /// fixed URL, then validates the public GET body by SHA-256.
  Future<WordAudioServerOperationResult> replace(
    WordAudioServerReplacementPlan plan, {
    void Function(String line)? onLog,
  }) async {
    _ensureWindows();
    final currentLocalBytes = await _readValidatedLocalCandidate(
      plan.localCandidateFile,
    );
    if (currentLocalBytes == null ||
        _sha256(currentLocalBytes) != plan.localCandidateSha256) {
      throw const WordAudioServerReplaceException(
        WordAudioServerReplaceFailure.localCandidateInvalid,
      );
    }
    if (plan.isAlreadyPublished) {
      final audit = await _writeReplacementAudit(
        plan,
        status: 'already_published',
        verificationMethod: 'plan_hash_comparison',
      );
      return WordAudioServerOperationResult(
        action: WordAudioServerOperationAction.replace,
        outcome: WordAudioServerOperationOutcome.completed,
        auditFile: audit,
      );
    }

    final invocation = await _replacementInvocation(plan, onLog: onLog);
    return _runReplacementInvocation(plan, invocation);
  }

  /// Invokes the matching server-side restoration.  The active replacement is
  /// backed up once more before the retained previous WAV is atomically put
  /// back at the same fixed URL.
  Future<WordAudioServerOperationResult> rollback(
    WordAudioServerRollbackPlan plan, {
    void Function(String line)? onLog,
  }) async {
    _ensureWindows();
    final invocation = await _rollbackInvocation(plan, onLog: onLog);
    return _runRollbackInvocation(plan, invocation);
  }

  /// Opens an explicit visible PowerShell window only after a prior confirmed
  /// action reached a sudo password prompt.  The app never collects that
  /// password.  Call [confirmReplacementAfterInteractive] afterwards.
  Future<void> openInteractiveReplacement(
    WordAudioServerReplacementPlan plan,
  ) async {
    _ensureWindows();
    await _openInteractive(await _replacementInvocation(plan));
  }

  Future<void> openInteractiveRollback(WordAudioServerRollbackPlan plan) async {
    _ensureWindows();
    await _openInteractive(await _rollbackInvocation(plan));
  }

  /// Read-only recovery check for an action completed in the visible sudo
  /// terminal.  A matching body hash is sufficient to record the operation as
  /// complete; the server script itself requires the named backup to exist
  /// before it can have made that change.
  Future<WordAudioServerOperationResult?> confirmReplacementAfterInteractive(
    WordAudioServerReplacementPlan plan,
  ) async {
    final remote = await _readRemoteSnapshot(
      baseUrl: plan.baseUrl,
      word: plan.word,
      language: plan.language,
    );
    final sha256 = _sha256(remote.bytes);
    if (sha256 == plan.localCandidateSha256) {
      final audit = await _writeReplacementAudit(
        plan,
        status: 'replaced',
        serverBackupId: plan.operationId,
        verificationMethod: 'app_get_after_interactive_sudo',
      );
      return WordAudioServerOperationResult(
        action: WordAudioServerOperationAction.replace,
        outcome: WordAudioServerOperationOutcome.completed,
        auditFile: audit,
        serverBackupId: plan.operationId,
      );
    }
    if (sha256 == plan.remoteCurrentSha256) return null;
    throw const WordAudioServerReplaceException(
      WordAudioServerReplaceFailure.remoteChanged,
    );
  }

  Future<WordAudioServerOperationResult?> confirmRollbackAfterInteractive(
    WordAudioServerRollbackPlan plan,
  ) async {
    final remote = await _readRemoteSnapshot(
      baseUrl: plan.baseUrl,
      word: plan.word,
      language: plan.language,
    );
    final sha256 = _sha256(remote.bytes);
    if (sha256 == plan.restoreSha256) {
      final audit = await _completeRollback(
        plan,
        verificationMethod: 'app_get_after_interactive_sudo',
        serverBackupId: plan.rollbackBackupId,
      );
      return WordAudioServerOperationResult(
        action: WordAudioServerOperationAction.rollback,
        outcome: WordAudioServerOperationOutcome.completed,
        auditFile: audit,
        serverBackupId: plan.rollbackBackupId,
      );
    }
    if (sha256 == plan.currentRemoteSha256) return null;
    throw const WordAudioServerReplaceException(
      WordAudioServerReplaceFailure.remoteChanged,
    );
  }

  bool isInteractiveSudoRequired(WordAudioServerPublisherResult result) {
    if (result.succeeded) return false;
    final markers = _publisherMarkers(result.output);
    if (markers['INTERACTIVE_SUDO_REQUIRED'] == '1') return true;
    final output = result.output.toLowerCase();
    return output.contains('sudo') &&
        (output.contains('password') ||
            output.contains('terminal') ||
            output.contains('tty') ||
            output.contains('askpass'));
  }

  Future<WordAudioServerOperationResult> _runReplacementInvocation(
    WordAudioServerReplacementPlan plan,
    WordAudioServerPublisherInvocation invocation,
  ) async {
    final publisher = await _publisher(invocation);
    if (isInteractiveSudoRequired(publisher)) {
      final audit = await _writeReplacementAudit(
        plan,
        status: 'interactive_sudo_required',
        publisher: publisher,
        remoteMutationReported: false,
      );
      return WordAudioServerOperationResult(
        action: WordAudioServerOperationAction.replace,
        outcome: WordAudioServerOperationOutcome.interactiveSudoRequired,
        publisher: publisher,
        auditFile: audit,
      );
    }
    final markers = _publisherMarkers(publisher.output);
    final mutationReported = markers['REMOTE_REPLACED'] == '1';
    if (!publisher.succeeded) {
      if (mutationReported) {
        final recovered = await _verifyReplacementAfterUncertainResult(
          plan,
          publisher,
          markers,
        );
        if (recovered != null) return recovered;
      }
      await _writeReplacementAudit(
        plan,
        status: mutationReported
            ? 'remote_mutation_unverified'
            : 'replace_failed_before_remote_mutation',
        publisher: publisher,
        serverBackupId: markers['REMOTE_BACKUP_ID'] ?? plan.operationId,
        serverBackupPath: markers['REMOTE_BACKUP_PATH'],
        remoteMutationReported: mutationReported,
      );
      throw WordAudioServerReplaceException(
        mutationReported
            ? WordAudioServerReplaceFailure.publishMayHaveChanged
            : WordAudioServerReplaceFailure.publishFailed,
        publisher: publisher,
      );
    }
    if (!mutationReported ||
        markers['REMOTE_BEFORE_SHA256'] != plan.remoteCurrentSha256 ||
        markers['REMOTE_AFTER_SHA256'] != plan.localCandidateSha256 ||
        markers['REMOTE_BACKUP_ID'] == null ||
        markers['SERVER_REPLACE_COMPLETE'] != '1') {
      await _writeReplacementAudit(
        plan,
        status: 'replace_failed_missing_server_confirmation',
        publisher: publisher,
      );
      throw WordAudioServerReplaceException(
        WordAudioServerReplaceFailure.publishMayHaveChanged,
        publisher: publisher,
      );
    }

    final audit = await _writeReplacementAudit(
      plan,
      status: 'replaced',
      publisher: publisher,
      serverBackupId: markers['REMOTE_BACKUP_ID']!,
      serverBackupPath: markers['REMOTE_BACKUP_PATH'],
      remoteMutationReported: true,
      verificationMethod: 'publisher_http_get_sha256',
    );
    return WordAudioServerOperationResult(
      action: WordAudioServerOperationAction.replace,
      outcome: WordAudioServerOperationOutcome.completed,
      publisher: publisher,
      auditFile: audit,
      serverBackupId: markers['REMOTE_BACKUP_ID']!,
      serverBackupPath: markers['REMOTE_BACKUP_PATH'],
    );
  }

  Future<WordAudioServerOperationResult?>
  _verifyReplacementAfterUncertainResult(
    WordAudioServerReplacementPlan plan,
    WordAudioServerPublisherResult publisher,
    Map<String, String> markers,
  ) async {
    try {
      final remote = await _readRemoteSnapshot(
        baseUrl: plan.baseUrl,
        word: plan.word,
        language: plan.language,
      );
      if (_sha256(remote.bytes) != plan.localCandidateSha256) return null;
      final audit = await _writeReplacementAudit(
        plan,
        status: 'replaced',
        publisher: publisher,
        serverBackupId: markers['REMOTE_BACKUP_ID'] ?? plan.operationId,
        serverBackupPath: markers['REMOTE_BACKUP_PATH'],
        remoteMutationReported: true,
        verificationMethod: 'app_get_after_publisher_error',
      );
      return WordAudioServerOperationResult(
        action: WordAudioServerOperationAction.replace,
        outcome: WordAudioServerOperationOutcome.completed,
        publisher: publisher,
        auditFile: audit,
        serverBackupId: markers['REMOTE_BACKUP_ID'] ?? plan.operationId,
        serverBackupPath: markers['REMOTE_BACKUP_PATH'],
      );
    } catch (_) {
      return null;
    }
  }

  Future<WordAudioServerOperationResult> _runRollbackInvocation(
    WordAudioServerRollbackPlan plan,
    WordAudioServerPublisherInvocation invocation,
  ) async {
    final publisher = await _publisher(invocation);
    if (isInteractiveSudoRequired(publisher)) {
      final audit = await _writeRollbackAudit(
        plan,
        status: 'interactive_sudo_required',
        publisher: publisher,
        remoteMutationReported: false,
      );
      return WordAudioServerOperationResult(
        action: WordAudioServerOperationAction.rollback,
        outcome: WordAudioServerOperationOutcome.interactiveSudoRequired,
        publisher: publisher,
        auditFile: audit,
      );
    }
    final markers = _publisherMarkers(publisher.output);
    final mutationReported = markers['REMOTE_ROLLED_BACK'] == '1';
    if (!publisher.succeeded) {
      if (mutationReported) {
        final recovered = await _verifyRollbackAfterUncertainResult(
          plan,
          publisher,
          markers,
        );
        if (recovered != null) return recovered;
      }
      await _writeRollbackAudit(
        plan,
        status: mutationReported
            ? 'remote_mutation_unverified'
            : 'rollback_failed_before_remote_mutation',
        publisher: publisher,
        serverBackupId: markers['REMOTE_BACKUP_ID'] ?? plan.rollbackBackupId,
        serverBackupPath: markers['REMOTE_BACKUP_PATH'],
        remoteMutationReported: mutationReported,
      );
      throw WordAudioServerReplaceException(
        mutationReported
            ? WordAudioServerReplaceFailure.publishMayHaveChanged
            : WordAudioServerReplaceFailure.publishFailed,
        publisher: publisher,
      );
    }
    if (!mutationReported ||
        markers['REMOTE_BEFORE_SHA256'] != plan.currentRemoteSha256 ||
        markers['REMOTE_AFTER_SHA256'] != plan.restoreSha256 ||
        markers['REMOTE_BACKUP_ID'] == null ||
        markers['SERVER_ROLLBACK_COMPLETE'] != '1') {
      await _writeRollbackAudit(
        plan,
        status: 'rollback_failed_missing_server_confirmation',
        publisher: publisher,
      );
      throw WordAudioServerReplaceException(
        WordAudioServerReplaceFailure.publishMayHaveChanged,
        publisher: publisher,
      );
    }

    final audit = await _completeRollback(
      plan,
      publisher: publisher,
      serverBackupId: markers['REMOTE_BACKUP_ID']!,
      serverBackupPath: markers['REMOTE_BACKUP_PATH'],
      verificationMethod: 'publisher_http_get_sha256',
    );
    return WordAudioServerOperationResult(
      action: WordAudioServerOperationAction.rollback,
      outcome: WordAudioServerOperationOutcome.completed,
      publisher: publisher,
      auditFile: audit,
      serverBackupId: markers['REMOTE_BACKUP_ID']!,
      serverBackupPath: markers['REMOTE_BACKUP_PATH'],
    );
  }

  Future<WordAudioServerOperationResult?> _verifyRollbackAfterUncertainResult(
    WordAudioServerRollbackPlan plan,
    WordAudioServerPublisherResult publisher,
    Map<String, String> markers,
  ) async {
    try {
      final remote = await _readRemoteSnapshot(
        baseUrl: plan.baseUrl,
        word: plan.word,
        language: plan.language,
      );
      if (_sha256(remote.bytes) != plan.restoreSha256) return null;
      final audit = await _completeRollback(
        plan,
        publisher: publisher,
        serverBackupId: markers['REMOTE_BACKUP_ID'] ?? plan.rollbackBackupId,
        serverBackupPath: markers['REMOTE_BACKUP_PATH'],
        verificationMethod: 'app_get_after_publisher_error',
      );
      return WordAudioServerOperationResult(
        action: WordAudioServerOperationAction.rollback,
        outcome: WordAudioServerOperationOutcome.completed,
        publisher: publisher,
        auditFile: audit,
        serverBackupId: markers['REMOTE_BACKUP_ID'] ?? plan.rollbackBackupId,
        serverBackupPath: markers['REMOTE_BACKUP_PATH'],
      );
    } catch (_) {
      return null;
    }
  }

  Future<WordAudioServerPublisherInvocation> _replacementInvocation(
    WordAudioServerReplacementPlan plan, {
    void Function(String line)? onLog,
  }) async {
    return WordAudioServerPublisherInvocation(
      script: await _publisherScriptLocator(),
      action: WordAudioServerOperationAction.replace,
      baseUrl: plan.baseUrl,
      audioFileName: plan.audioFileName,
      localCandidateFile: plan.localCandidateFile,
      expectedCurrentSha256: plan.remoteCurrentSha256,
      expectedResultSha256: plan.localCandidateSha256,
      expectedResultBytesLength: plan.localCandidateBytesLength,
      operationId: plan.operationId,
      serverBackupId: null,
      onLog: onLog,
    );
  }

  Future<WordAudioServerPublisherInvocation> _rollbackInvocation(
    WordAudioServerRollbackPlan plan, {
    void Function(String line)? onLog,
  }) async {
    return WordAudioServerPublisherInvocation(
      script: await _publisherScriptLocator(),
      action: WordAudioServerOperationAction.rollback,
      baseUrl: plan.baseUrl,
      audioFileName: plan.audioFileName,
      localCandidateFile: null,
      expectedCurrentSha256: plan.currentRemoteSha256,
      expectedResultSha256: plan.restoreSha256,
      expectedResultBytesLength: plan.restoreBytesLength,
      operationId: plan.operationId,
      serverBackupId: plan.serverBackupId,
      onLog: onLog,
    );
  }

  Future<void> _openInteractive(
    WordAudioServerPublisherInvocation invocation,
  ) async {
    final publisherArguments = _powerShellArguments(
      invocation,
      interactive: true,
    );
    final quotedArguments = publisherArguments
        .map(_powerShellSingleQuoted)
        .join(', ');
    final command =
        "${r'$ErrorActionPreference'} = 'Stop'; "
        "${r'$publisherArguments'} = @($quotedArguments); "
        'Start-Process -FilePath powershell.exe '
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
      final stdout = launcher.stdout?.toString() ?? '';
      final stderr = launcher.stderr?.toString() ?? '';
      throw WordAudioServerReplaceException(
        WordAudioServerReplaceFailure.publishFailed,
        diagnosticOutput: '$stdout\n$stderr',
      );
    }
  }

  Future<_RemoteSnapshot> _readRemoteSnapshot({
    required String baseUrl,
    required String word,
    required String language,
  }) async {
    final client = _clientFor(baseUrl);
    try {
      final bytes = await client.fetch(word, language: language);
      if (QwenTtsAdapter.wordAudioValidationFailure(bytes) != null) {
        throw const WordAudioServerReplaceException(
          WordAudioServerReplaceFailure.remoteAudioInvalid,
        );
      }
      return _RemoteSnapshot(
        client: client,
        uri: client.buildAudioUri(word, language: language),
        bytes: bytes,
      );
    } on WordAudioServerReplaceException {
      rethrow;
    } on RemoteWordAudioException catch (error) {
      throw WordAudioServerReplaceException(_failureForRemoteError(error));
    } catch (_) {
      throw const WordAudioServerReplaceException(
        WordAudioServerReplaceFailure.remoteUnavailable,
      );
    }
  }

  Future<Uint8List?> _readValidatedLocalCandidate(File file) async {
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

  RemoteWordAudioClient _clientFor(String rawBaseUrl) {
    try {
      return _remoteClientFactory(rawBaseUrl);
    } on RemoteWordAudioException catch (error) {
      throw WordAudioServerReplaceException(_failureForRemoteError(error));
    } catch (_) {
      throw const WordAudioServerReplaceException(
        WordAudioServerReplaceFailure.serverAddressInvalid,
      );
    }
  }

  String _normalizeBaseUrl(String rawBaseUrl) {
    try {
      return RemoteWordAudioClient.normalizeBaseUrl(rawBaseUrl);
    } on RemoteWordAudioException catch (error) {
      throw WordAudioServerReplaceException(_failureForRemoteError(error));
    }
  }

  WordAudioServerReplaceFailure _failureForRemoteError(
    RemoteWordAudioException error,
  ) {
    return switch (error.failure) {
      RemoteWordAudioFailure.notConfigured =>
        WordAudioServerReplaceFailure.serverNotConfigured,
      RemoteWordAudioFailure.invalidUrl =>
        WordAudioServerReplaceFailure.serverAddressInvalid,
      RemoteWordAudioFailure.notFound =>
        WordAudioServerReplaceFailure.remoteAudioMissing,
      RemoteWordAudioFailure.invalidAudio =>
        WordAudioServerReplaceFailure.remoteAudioInvalid,
      RemoteWordAudioFailure.timeout || RemoteWordAudioFailure.unavailable =>
        WordAudioServerReplaceFailure.remoteUnavailable,
    };
  }

  Future<File> _writeReplacementAudit(
    WordAudioServerReplacementPlan plan, {
    required String status,
    WordAudioServerPublisherResult? publisher,
    String? serverBackupId,
    String? serverBackupPath,
    bool? remoteMutationReported,
    String? verificationMethod,
  }) async {
    final file = await _auditFile(
      plan.word,
      action: WordAudioServerOperationAction.replace,
      operationId: plan.operationId,
    );
    final payload = <String, dynamic>{
      'schemaVersion': 1,
      'updatedAt': _now().toUtc().toIso8601String(),
      'operationId': plan.operationId,
      'action': 'replace',
      'status': status,
      'profileVersion': RemoteWordAudioClient.audioKeyProfileVersion,
      'word': plan.word,
      'language': plan.language,
      'localCandidate': {
        'path': plan.localCandidateFile.path,
        'sha256': plan.localCandidateSha256,
        'bytes': plan.localCandidateBytesLength,
      },
      'remote': {
        'baseUrl': plan.baseUrl,
        'uri': plan.remoteUri.toString(),
        'fileName': plan.audioFileName,
        'beforeSha256': plan.remoteCurrentSha256,
        'beforeBytes': plan.remoteCurrentBytesLength,
        'afterSha256': plan.localCandidateSha256,
        'afterBytes': plan.localCandidateBytesLength,
        'serverBackupId': serverBackupId,
        'serverBackupPath': serverBackupPath,
      },
      'publisher': {
        'exitCode': publisher?.exitCode,
        'remoteMutationReported': remoteMutationReported,
        'diagnosticOutput': publisher?.diagnosticOutput,
      },
      'verificationMethod': verificationMethod,
    };
    await _writeJsonAtomically(file, payload, plan.operationId);
    return file;
  }

  Future<File> _completeRollback(
    WordAudioServerRollbackPlan plan, {
    WordAudioServerPublisherResult? publisher,
    required String serverBackupId,
    String? serverBackupPath,
    required String verificationMethod,
  }) async {
    final audit = await _writeRollbackAudit(
      plan,
      status: 'rolled_back',
      publisher: publisher,
      serverBackupId: serverBackupId,
      serverBackupPath: serverBackupPath,
      remoteMutationReported: true,
      verificationMethod: verificationMethod,
    );
    try {
      await _markReplacementRolledBack(
        plan.replacement,
        audit,
        plan.operationId,
      );
    } catch (_) {
      // The completed rollback audit remains durable even if a secondary local
      // annotation cannot be written (for example, a temporary file lock).
    }
    return audit;
  }

  Future<File> _writeRollbackAudit(
    WordAudioServerRollbackPlan plan, {
    required String status,
    WordAudioServerPublisherResult? publisher,
    String? serverBackupId,
    String? serverBackupPath,
    bool? remoteMutationReported,
    String? verificationMethod,
  }) async {
    final file = await _auditFile(
      plan.word,
      action: WordAudioServerOperationAction.rollback,
      operationId: plan.operationId,
    );
    final payload = <String, dynamic>{
      'schemaVersion': 1,
      'updatedAt': _now().toUtc().toIso8601String(),
      'operationId': plan.operationId,
      'action': 'rollback',
      'status': status,
      'profileVersion': RemoteWordAudioClient.audioKeyProfileVersion,
      'word': plan.word,
      'language': plan.language,
      'sourceReplacement': {
        'operationId': plan.replacement.operationId,
        'auditFile': plan.replacement.auditFile.path,
        'serverBackupId': plan.serverBackupId,
      },
      'remote': {
        'baseUrl': plan.baseUrl,
        'uri': plan.remoteUri.toString(),
        'fileName': plan.audioFileName,
        'beforeSha256': plan.currentRemoteSha256,
        'beforeBytes': plan.currentRemoteBytes.length,
        'afterSha256': plan.restoreSha256,
        'afterBytes': plan.restoreBytesLength,
        'serverBackupId': serverBackupId,
        'serverBackupPath': serverBackupPath,
      },
      'publisher': {
        'exitCode': publisher?.exitCode,
        'remoteMutationReported': remoteMutationReported,
        'diagnosticOutput': publisher?.diagnosticOutput,
      },
      'verificationMethod': verificationMethod,
    };
    await _writeJsonAtomically(file, payload, plan.operationId);
    return file;
  }

  Future<void> _markReplacementRolledBack(
    WordAudioServerReplacementRecord record,
    File rollbackAudit,
    String rollbackOperationId,
  ) async {
    final raw = jsonDecode(await record.auditFile.readAsString());
    if (raw is! Map) return;
    final payload = Map<String, dynamic>.from(raw);
    payload['updatedAt'] = _now().toUtc().toIso8601String();
    payload['rollback'] = {
      'operationId': rollbackOperationId,
      'auditFile': rollbackAudit.path,
      'completedAt': _now().toUtc().toIso8601String(),
    };
    await _writeJsonAtomically(record.auditFile, payload, rollbackOperationId);
  }

  Future<WordAudioServerReplacementRecord?> _readReplacementRecord(
    File file,
  ) async {
    try {
      final raw = jsonDecode(await file.readAsString());
      if (raw is! Map ||
          raw['schemaVersion'] != 1 ||
          raw['action'] != 'replace' ||
          raw['profileVersion'] !=
              RemoteWordAudioClient.audioKeyProfileVersion) {
        return null;
      }
      final status = raw['status']?.toString();
      if (status != 'replaced' && status != 'remote_mutation_unverified') {
        return null;
      }
      final word = raw['word']?.toString();
      final language = raw['language']?.toString();
      final remote = raw['remote'];
      final updatedAt = DateTime.tryParse(raw['updatedAt']?.toString() ?? '');
      if (word == null ||
          language == null ||
          remote is! Map ||
          updatedAt == null) {
        return null;
      }
      final baseUrl = remote['baseUrl']?.toString();
      final fileName = remote['fileName']?.toString();
      final beforeSha256 = remote['beforeSha256']?.toString();
      final afterSha256 = remote['afterSha256']?.toString();
      final beforeBytes = _asInt(remote['beforeBytes']);
      final afterBytes = _asInt(remote['afterBytes']);
      final serverBackupId = remote['serverBackupId']?.toString();
      if (baseUrl == null ||
          fileName == null ||
          beforeSha256 == null ||
          afterSha256 == null ||
          beforeBytes == null ||
          afterBytes == null ||
          serverBackupId == null ||
          !RegExp(r'^[A-Za-z0-9_-]{8,120}$').hasMatch(serverBackupId) ||
          !RegExp(r'^[a-f0-9]{64}\.wav$').hasMatch(fileName) ||
          !_isSha256(beforeSha256) ||
          !_isSha256(afterSha256)) {
        return null;
      }
      return WordAudioServerReplacementRecord(
        auditFile: file,
        operationId: raw['operationId']?.toString() ?? '',
        word: RemoteWordAudioClient.normalizeWord(word),
        language: RemoteWordAudioClient.normalizeLanguage(language),
        baseUrl: _normalizeBaseUrl(baseUrl),
        audioFileName: fileName,
        previousSha256: beforeSha256,
        previousBytesLength: beforeBytes,
        activeSha256: afterSha256,
        activeBytesLength: afterBytes,
        serverBackupId: serverBackupId,
        serverBackupPath: remote['serverBackupPath']?.toString(),
        updatedAt: updatedAt.toUtc(),
        rolledBack: raw['rollback'] is Map,
        needsVerification: status == 'remote_mutation_unverified',
      );
    } catch (_) {
      return null;
    }
  }

  Future<File> _auditFile(
    String word, {
    required WordAudioServerOperationAction action,
    required String operationId,
  }) async {
    final directory = await _auditDirectory();
    return File(
      p.join(
        directory.path,
        '${_safeSlug(word)}_${action.name}_$operationId.json',
      ),
    );
  }

  Future<Directory> _auditDirectory() async {
    final root = await _dataDirProvider();
    if (!await root.exists()) await root.create(recursive: true);
    final directory = Directory(
      p.join(root.path, 'lingo_word_audio_server_replacement_audits'),
    );
    if (!await directory.exists()) await directory.create(recursive: true);
    return directory;
  }

  Future<void> _writeJsonAtomically(
    File target,
    Map<String, dynamic> payload,
    String operationId,
  ) async {
    final parent = Directory(p.dirname(target.path));
    if (!await parent.exists()) await parent.create(recursive: true);
    final temporary = File('${target.path}.$operationId.part');
    try {
      if (await temporary.exists()) await temporary.delete();
      await temporary.writeAsString(
        const JsonEncoder.withIndent('  ').convert(payload),
        flush: true,
      );
      if (await target.exists()) await target.delete();
      await temporary.rename(target.path);
    } finally {
      try {
        if (await temporary.exists()) await temporary.delete();
      } catch (_) {
        // A leftover temporary audit is safer than deleting an unrelated file.
      }
    }
  }

  Map<String, String> _publisherMarkers(String output) {
    final markers = <String, String>{};
    for (final line in const LineSplitter().convert(output)) {
      final match = RegExp(
        r'^([A-Z0-9_]+)=([^\r\n]+)$',
      ).firstMatch(line.trim());
      if (match != null) markers[match.group(1)!] = match.group(2)!;
    }
    return markers;
  }

  List<String> _powerShellArguments(
    WordAudioServerPublisherInvocation invocation, {
    bool interactive = false,
  }) {
    return [
      '-NoLogo',
      '-NoProfile',
      if (interactive) '-NoExit' else '-NonInteractive',
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      invocation.script.path,
      '-Action',
      invocation.action == WordAudioServerOperationAction.replace
          ? 'Replace'
          : 'Rollback',
      '-FileName',
      invocation.audioFileName,
      '-ExpectedCurrentSha256',
      invocation.expectedCurrentSha256,
      '-ExpectedResultSha256',
      invocation.expectedResultSha256,
      '-ExpectedResultBytes',
      invocation.expectedResultBytesLength.toString(),
      '-OperationId',
      invocation.operationId,
      '-BaseUrl',
      invocation.baseUrl,
      if (interactive) '-InteractiveSudo',
      if (invocation.localCandidateFile != null) ...[
        '-SourceFile',
        invocation.localCandidateFile!.path,
      ],
      if (invocation.serverBackupId != null) ...[
        '-ServerBackupId',
        invocation.serverBackupId!,
      ],
    ];
  }

  void _ensureWindows() {
    if (!_isWindows()) {
      throw const WordAudioServerReplaceException(
        WordAudioServerReplaceFailure.unsupportedPlatform,
      );
    }
  }

  String _sha256(Uint8List bytes) => sha256.convert(bytes).toString();

  bool _isSha256(String value) => RegExp(r'^[a-f0-9]{64}$').hasMatch(value);

  int? _asInt(Object? value) => value is num ? value.toInt() : null;

  String _newOperationId() {
    _operationCounter++;
    return '${_now().toUtc().microsecondsSinceEpoch}_$_operationCounter';
  }

  String _safeSlug(String value) {
    final normalized = value.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '_',
    );
    final trimmed = normalized.replaceAll(RegExp(r'^_+|_+$'), '');
    if (trimmed.isEmpty) return 'word';
    return trimmed.substring(0, trimmed.length > 48 ? 48 : trimmed.length);
  }

  String _powerShellSingleQuoted(String value) =>
      "'${value.replaceAll("'", "''")}'";

  static RemoteWordAudioClient _defaultRemoteClient(String baseUrl) =>
      RemoteWordAudioClient(baseUrl: baseUrl);

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
            'replace-word-audio.ps1',
          ),
        );
        if (await candidate.exists()) return candidate;
        final parent = directory.parent;
        if (p.equals(parent.path, directory.path)) break;
        directory = parent;
      }
    }
    throw const WordAudioServerReplaceException(
      WordAudioServerReplaceFailure.publishFailed,
    );
  }

  static Future<WordAudioServerPublisherResult> _runPowerShellPublisher(
    WordAudioServerPublisherInvocation invocation,
  ) async {
    final arguments = [
      '-NoLogo',
      '-NoProfile',
      '-NonInteractive',
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      invocation.script.path,
      '-Action',
      invocation.action == WordAudioServerOperationAction.replace
          ? 'Replace'
          : 'Rollback',
      '-FileName',
      invocation.audioFileName,
      '-ExpectedCurrentSha256',
      invocation.expectedCurrentSha256,
      '-ExpectedResultSha256',
      invocation.expectedResultSha256,
      '-ExpectedResultBytes',
      invocation.expectedResultBytesLength.toString(),
      '-OperationId',
      invocation.operationId,
      '-BaseUrl',
      invocation.baseUrl,
      if (invocation.localCandidateFile != null) ...[
        '-SourceFile',
        invocation.localCandidateFile!.path,
      ],
      if (invocation.serverBackupId != null) ...[
        '-ServerBackupId',
        invocation.serverBackupId!,
      ],
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
        await for (final chunk in stream.transform(
          const Utf8Decoder(allowMalformed: true),
        )) {
          output.write(chunk);
          for (final line in const LineSplitter().convert(chunk)) {
            final trimmed = line.trimRight();
            if (trimmed.isNotEmpty) {
              invocation.onLog?.call(_sanitizePublisherDiagnostic(trimmed));
            }
          }
        }
      }

      await Future.wait([collect(process.stdout), collect(process.stderr)]);
      return WordAudioServerPublisherResult(
        exitCode: await process.exitCode,
        output: output.toString(),
      );
    } on ProcessException catch (error) {
      return WordAudioServerPublisherResult(
        exitCode: -1,
        output: error.message,
      );
    }
  }
}

class _RemoteSnapshot {
  final RemoteWordAudioClient client;
  final Uri uri;
  final Uint8List bytes;

  const _RemoteSnapshot({
    required this.client,
    required this.uri,
    required this.bytes,
  });
}
