import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:lingo_app/core/services/remote_word_audio_client.dart';
import 'package:lingo_app/core/services/word_audio_repair_service.dart';
import 'package:lingo_app/core/services/word_audio_server_replace_service.dart';

Uint8List _pcmWav({int durationMilliseconds = 250, int amplitude = 1600}) {
  const sampleRate = 48000;
  const channels = 1;
  const bitsPerSample = 16;
  final sampleCount = sampleRate * durationMilliseconds ~/ 1000;
  final dataLength = sampleCount * channels * bitsPerSample ~/ 8;
  final bytes = Uint8List(44 + dataLength);
  final data = ByteData.sublistView(bytes);

  bytes.setRange(0, 4, const [0x52, 0x49, 0x46, 0x46]);
  data.setUint32(4, bytes.length - 8, Endian.little);
  bytes.setRange(8, 12, const [0x57, 0x41, 0x56, 0x45]);
  bytes.setRange(12, 16, const [0x66, 0x6d, 0x74, 0x20]);
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, channels, Endian.little);
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, sampleRate * channels * bitsPerSample ~/ 8, Endian.little);
  data.setUint16(32, channels * bitsPerSample ~/ 8, Endian.little);
  data.setUint16(34, bitsPerSample, Endian.little);
  bytes.setRange(36, 40, const [0x64, 0x61, 0x74, 0x61]);
  data.setUint32(40, dataLength, Endian.little);
  for (var offset = 44; offset < bytes.length; offset += 2) {
    data.setInt16(offset, amplitude, Endian.little);
  }
  return bytes;
}

void main() {
  late Directory tempDir;
  late File script;
  late File localCandidate;
  late Uint8List remoteBytes;
  late Uint8List oldServerBytes;
  late Uint8List newLocalBytes;

  setUp(() async {
    tempDir = await Directory.current.createTemp(
      'word_audio_server_replace_test_',
    );
    script = File(p.join(tempDir.path, 'replace-word-audio.ps1'));
    await script.writeAsString('# test publisher');
    oldServerBytes = _pcmWav(amplitude: 1100);
    newLocalBytes = _pcmWav(amplitude: 2600);
    remoteBytes = oldServerBytes;
    final cache = Directory(p.join(tempDir.path, 'lingo_tts_cache'));
    await cache.create(recursive: true);
    localCandidate = File(
      p.join(cache.path, RemoteWordAudioClient.audioFileNameFor('steep')),
    );
    await localCandidate.writeAsBytes(newLocalBytes, flush: true);
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  WordAudioRepairPlan repairPlan() => WordAudioRepairPlan(
    request: const WordAudioRepairRequest(word: 'steep'),
    word: 'steep',
    language: 'en',
    instruction: 'Read steep once.',
    targetFile: localCandidate,
    hasExistingFile: true,
    existingFileIsValid: true,
  );

  WordAudioServerReplaceService service({
    required WordAudioServerPublisher publisher,
  }) {
    return WordAudioServerReplaceService(
      dataDirProvider: () async => tempDir,
      isWindows: () => true,
      publisher: publisher,
      publisherScriptLocator: () async => script,
      remoteClientFactory: (baseUrl) => RemoteWordAudioClient(
        baseUrl: baseUrl,
        request: (_) async => RemoteWordAudioResponse(
          statusCode: 200,
          bytes: remoteBytes,
          contentType: 'audio/wav',
        ),
      ),
      now: () => DateTime.utc(2026, 8, 2, 12),
    );
  }

  test(
    'replaces one fixed key only after a reviewed comparison and retains a rollback record',
    () async {
      final invocations = <WordAudioServerPublisherInvocation>[];
      final replacement = service(
        publisher: (invocation) async {
          invocations.add(invocation);
          if (invocation.action == WordAudioServerOperationAction.replace) {
            expect(invocation.localCandidateFile, localCandidate);
            expect(
              invocation.expectedCurrentSha256,
              isNot(invocation.expectedResultSha256),
            );
            remoteBytes = newLocalBytes;
            return WordAudioServerPublisherResult(
              exitCode: 0,
              output:
                  'REMOTE_BACKUP_ID=${invocation.operationId}\n'
                  'REMOTE_BACKUP_PATH=/var/lib/lingo/backups/old.wav\n'
                  'REMOTE_BEFORE_SHA256=${invocation.expectedCurrentSha256}\n'
                  'REMOTE_AFTER_SHA256=${invocation.expectedResultSha256}\n'
                  'REMOTE_REPLACED=1\n'
                  'SERVER_REPLACE_COMPLETE=1\n'
                  'HTTP GET checked: 1',
            );
          }

          expect(invocation.serverBackupId, isNotEmpty);
          expect(invocation.expectedCurrentSha256, isNotEmpty);
          remoteBytes = oldServerBytes;
          return WordAudioServerPublisherResult(
            exitCode: 0,
            output:
                'REMOTE_BACKUP_ID=rollback_${invocation.operationId}\n'
                'REMOTE_BACKUP_PATH=/var/lib/lingo/backups/current.wav\n'
                'REMOTE_BEFORE_SHA256=${invocation.expectedCurrentSha256}\n'
                'REMOTE_AFTER_SHA256=${invocation.expectedResultSha256}\n'
                'REMOTE_ROLLED_BACK=1\n'
                'SERVER_ROLLBACK_COMPLETE=1\n'
                'HTTP GET checked: 1',
          );
        },
      );

      final plan = await replacement.createReplacementPlan(
        repairPlan: repairPlan(),
        remoteBaseUrl: 'https://audio.example.test/audio/',
      );

      expect(plan.isAlreadyPublished, isFalse);
      expect(plan.audioFileName, localCandidate.uri.pathSegments.last);
      expect(
        plan.remoteUri.toString(),
        'https://audio.example.test/audio/v1/en/${plan.audioFileName}',
      );

      final replaceResult = await replacement.replace(plan);

      expect(replaceResult.outcome, WordAudioServerOperationOutcome.completed);
      expect(replaceResult.auditFile, isNotNull);
      expect(await replaceResult.auditFile!.exists(), isTrue);
      final replaceAudit =
          jsonDecode(await replaceResult.auditFile!.readAsString())
              as Map<String, dynamic>;
      expect(replaceAudit['status'], 'replaced');
      expect(replaceAudit['remote']['beforeSha256'], plan.remoteCurrentSha256);
      expect(replaceAudit['remote']['afterSha256'], plan.localCandidateSha256);

      final rollbackPlan = await replacement.createRollbackPlan(
        word: 'steep',
        language: 'en',
        remoteBaseUrl: 'https://audio.example.test/audio',
      );
      expect(rollbackPlan.serverBackupId, plan.operationId);
      expect(rollbackPlan.currentRemoteSha256, plan.localCandidateSha256);
      expect(rollbackPlan.restoreSha256, plan.remoteCurrentSha256);

      final rollbackResult = await replacement.rollback(rollbackPlan);

      expect(rollbackResult.outcome, WordAudioServerOperationOutcome.completed);
      expect(invocations, hasLength(2));
      expect(invocations.last.action, WordAudioServerOperationAction.rollback);
      expect(await rollbackResult.auditFile!.exists(), isTrue);
      final replacedAuditAfterRollback =
          jsonDecode(await replaceResult.auditFile!.readAsString())
              as Map<String, dynamic>;
      expect(
        replacedAuditAfterRollback['rollback'],
        isA<Map<String, dynamic>>(),
      );
      await expectLater(
        replacement.loadLatestRollbackCandidate(word: 'steep', language: 'en'),
        throwsA(
          isA<WordAudioServerReplaceException>().having(
            (error) => error.failure,
            'failure',
            WordAudioServerReplaceFailure.rollbackUnavailable,
          ),
        ),
      );
    },
  );

  test(
    'does not invoke a publisher when the fixed-key body already matches',
    () async {
      remoteBytes = newLocalBytes;
      var publisherCalls = 0;
      final replacement = service(
        publisher: (_) async {
          publisherCalls++;
          return const WordAudioServerPublisherResult(
            exitCode: 0,
            output: 'done',
          );
        },
      );

      final plan = await replacement.createReplacementPlan(
        repairPlan: repairPlan(),
        remoteBaseUrl: 'https://audio.example.test/audio',
      );
      final result = await replacement.replace(plan);

      expect(plan.isAlreadyPublished, isTrue);
      expect(result.outcome, WordAudioServerOperationOutcome.completed);
      expect(publisherCalls, 0);
      final audit = jsonDecode(await result.auditFile!.readAsString());
      expect(audit['status'], 'already_published');
    },
  );

  test(
    'refuses a rollback when the server no longer has the reviewed active hash',
    () async {
      final replacement = service(
        publisher: (invocation) async {
          remoteBytes = newLocalBytes;
          return WordAudioServerPublisherResult(
            exitCode: 0,
            output:
                'REMOTE_BACKUP_ID=${invocation.operationId}\n'
                'REMOTE_BEFORE_SHA256=${invocation.expectedCurrentSha256}\n'
                'REMOTE_AFTER_SHA256=${invocation.expectedResultSha256}\n'
                'REMOTE_REPLACED=1\n'
                'SERVER_REPLACE_COMPLETE=1',
          );
        },
      );
      final plan = await replacement.createReplacementPlan(
        repairPlan: repairPlan(),
        remoteBaseUrl: 'https://audio.example.test/audio',
      );
      await replacement.replace(plan);
      remoteBytes = _pcmWav(amplitude: 3200);

      await expectLater(
        replacement.createRollbackPlan(
          word: 'steep',
          language: 'en',
          remoteBaseUrl: 'https://audio.example.test/audio',
        ),
        throwsA(
          isA<WordAudioServerReplaceException>().having(
            (error) => error.failure,
            'failure',
            WordAudioServerReplaceFailure.remoteChanged,
          ),
        ),
      );
    },
  );

  test('recognizes a sudo prompt without opening an interactive process', () {
    final replacement = service(
      publisher: (_) async =>
          const WordAudioServerPublisherResult(exitCode: 0, output: 'unused'),
    );

    expect(
      replacement.isInteractiveSudoRequired(
        const WordAudioServerPublisherResult(
          exitCode: 1,
          output:
              'sudo: a password is required\n'
              'sudo: a terminal is required to read the password\n',
        ),
      ),
      isTrue,
    );
  });

  test(
    'PowerShell publisher keeps the root heredoc on explicit line boundaries',
    () {
      var directory = Directory.current;
      File? publisherScript;
      for (var depth = 0; depth < 8; depth++) {
        final candidate = File(
          p.join(
            directory.path,
            'deploy',
            'lighthouse',
            'replace-word-audio.ps1',
          ),
        );
        if (candidate.existsSync()) {
          publisherScript = candidate;
          break;
        }
        final parent = directory.parent;
        if (p.equals(parent.path, directory.path)) break;
        directory = parent;
      }

      expect(publisherScript, isNotNull);
      final source = publisherScript!.readAsStringSync();
      expect(source, contains(r'$remoteScriptParts'));
      expect(
        source,
        contains(r'$remoteScript = ($remoteScriptParts -join "`n") + "`n"'),
      );
      expect(
        source,
        contains(
          r'''$expectedHereDocumentStart = "<<'LINGO_ROOT'`nset -eu`n"''',
        ),
      );
      expect(source, contains('Internal remote-script assembly error'));
      expect(source, isNot(contains(r'$remoteSudoPrefix + @')));
      expect(
        source,
        contains(
          r'''$remoteBackupArgument = if ($Action -ceq 'Rollback') { $ServerBackupId } else { '-' }''',
        ),
      );
      expect(source, contains(r'server_backup_id="${1-}"'));
    },
  );

  test(
    'uses the stable sudo marker and records a redacted interactive audit',
    () async {
      final replacement = service(
        publisher: (_) async => const WordAudioServerPublisherResult(
          exitCode: 70,
          output: r'''INTERACTIVE_SUDO_REQUIRED=1
sudo: a password is required
IdentityFile C:\private\lingo_lighthouse_ed25519
Password: do-not-save-this
''',
        ),
      );
      final plan = await replacement.createReplacementPlan(
        repairPlan: repairPlan(),
        remoteBaseUrl: 'https://audio.example.test/audio',
      );

      final result = await replacement.replace(plan);

      expect(
        result.outcome,
        WordAudioServerOperationOutcome.interactiveSudoRequired,
      );
      expect(result.auditFile, isNotNull);
      final diagnostic = result.publisher!.diagnosticOutput;
      expect(diagnostic, contains('INTERACTIVE_SUDO_REQUIRED=1'));
      expect(diagnostic, contains('sudo: a password is required'));
      expect(diagnostic, contains('<redacted-identity-file>'));
      expect(diagnostic, contains('<redacted-credential>'));
      expect(
        diagnostic,
        isNot(contains(r'C:\private\lingo_lighthouse_ed25519')),
      );
      expect(diagnostic, isNot(contains('do-not-save-this')));

      final audit =
          jsonDecode(await result.auditFile!.readAsString())
              as Map<String, dynamic>;
      expect(audit['status'], 'interactive_sudo_required');
      expect(audit['publisher']['remoteMutationReported'], isFalse);
      expect(audit['publisher']['diagnosticOutput'], diagnostic);
    },
  );

  test(
    'uses the stable sudo marker before a rollback can mutate the server',
    () async {
      final replacement = service(
        publisher: (invocation) async {
          if (invocation.action == WordAudioServerOperationAction.replace) {
            remoteBytes = newLocalBytes;
            return WordAudioServerPublisherResult(
              exitCode: 0,
              output:
                  'REMOTE_BACKUP_ID=${invocation.operationId}\n'
                  'REMOTE_BEFORE_SHA256=${invocation.expectedCurrentSha256}\n'
                  'REMOTE_AFTER_SHA256=${invocation.expectedResultSha256}\n'
                  'REMOTE_REPLACED=1\n'
                  'SERVER_REPLACE_COMPLETE=1',
            );
          }
          return const WordAudioServerPublisherResult(
            exitCode: 70,
            output: 'INTERACTIVE_SUDO_REQUIRED=1',
          );
        },
      );
      final replacementPlan = await replacement.createReplacementPlan(
        repairPlan: repairPlan(),
        remoteBaseUrl: 'https://audio.example.test/audio',
      );
      await replacement.replace(replacementPlan);
      final rollbackPlan = await replacement.createRollbackPlan(
        word: 'steep',
        language: 'en',
        remoteBaseUrl: 'https://audio.example.test/audio',
      );

      final result = await replacement.rollback(rollbackPlan);

      expect(
        result.outcome,
        WordAudioServerOperationOutcome.interactiveSudoRequired,
      );
      expect(remoteBytes, newLocalBytes);
      final audit =
          jsonDecode(await result.auditFile!.readAsString())
              as Map<String, dynamic>;
      expect(audit['action'], 'rollback');
      expect(audit['status'], 'interactive_sudo_required');
      expect(audit['publisher']['remoteMutationReported'], isFalse);
    },
  );

  test(
    'keeps failed publisher diagnostics redacted and bounded in its audit',
    () async {
      final verboseOutput = List<String>.filled(12, 'x' * 1000).join('\n');
      final replacement = service(
        publisher: (_) async => WordAudioServerPublisherResult(
          exitCode: 1,
          output:
              '$verboseOutput\n'
              r'IdentityFile C:\private\lingo_lighthouse_ed25519'
              '\n'
              'Token: do-not-save-this',
        ),
      );
      final plan = await replacement.createReplacementPlan(
        repairPlan: repairPlan(),
        remoteBaseUrl: 'https://audio.example.test/audio',
      );

      WordAudioServerReplaceException? failure;
      try {
        await replacement.replace(plan);
        fail('Expected a publisher failure.');
      } on WordAudioServerReplaceException catch (error) {
        failure = error;
      }

      expect(failure.failure, WordAudioServerReplaceFailure.publishFailed);
      final diagnostic = failure.safeDiagnosticOutput!;
      expect(diagnostic.length, lessThanOrEqualTo(8100));
      expect(diagnostic, contains('<redacted-identity-file>'));
      expect(diagnostic, contains('<redacted-credential>'));
      expect(
        diagnostic,
        isNot(contains(r'C:\private\lingo_lighthouse_ed25519')),
      );
      expect(diagnostic, isNot(contains('do-not-save-this')));

      final auditFile = File(
        p.join(
          tempDir.path,
          'lingo_word_audio_server_replacement_audits',
          'steep_replace_${plan.operationId}.json',
        ),
      );
      final audit =
          jsonDecode(await auditFile.readAsString()) as Map<String, dynamic>;
      expect(audit['status'], 'replace_failed_before_remote_mutation');
      expect(audit['publisher']['diagnosticOutput'], diagnostic);
    },
  );
}
