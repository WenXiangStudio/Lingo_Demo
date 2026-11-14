import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/app_database.dart' as db;
import '../models/narration_ai_models.dart';
import '../../features/narration/models/narration_models.dart';

class NarrationRepository {
  NarrationRepository(this._db);

  final db.AppDatabase _db;

  static const reviewIntervals = <Duration>[
    Duration(days: 1),
    Duration(days: 3),
    Duration(days: 7),
    Duration(days: 14),
    Duration(days: 30),
    Duration(days: 60),
    Duration(days: 90),
  ];

  Future<int> createSession({
    required String rawTranscript,
    required String cleanedTranscript,
    required NarrationTranscriptConfidence confidence,
    List<NarrationUncertainSegment> uncertainSegments = const [],
    String? audioPath,
    bool audioRetained = false,
    String accent = 'british',
    String register = 'spoken',
    bool thinkingEnabled = true,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final uncertainJson = jsonEncode(
      uncertainSegments.map((item) => item.toJson()).toList(),
    );
    return _db.transaction(() async {
      await _activateSleepingQueue(now);
      final sessionId = await _db
          .into(_db.narrationSessions)
          .insert(
            db.NarrationSessionsCompanion.insert(
              status: NarrationSessionStatus.transcriptReview.name,
              rawTranscript: rawTranscript,
              cleanedTranscript: Value(cleanedTranscript),
              transcriptConfidence: Value(confidence.name),
              uncertainSegmentsJson: Value(uncertainJson),
              audioPath: Value.absentIfNull(audioPath),
              audioRetained: Value(audioRetained),
              accent: Value(accent),
              speechRegister: Value(register),
              thinkingEnabled: Value(thinkingEnabled),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _db
          .into(_db.narrationTranscriptionLogs)
          .insert(
            db.NarrationTranscriptionLogsCompanion.insert(
              sessionId: sessionId,
              rawTranscript: rawTranscript,
              correctedTranscript: Value(cleanedTranscript),
              confidence: confidence.name,
              uncertainSegmentsJson: uncertainJson,
              confirmationResult: 'pending',
              createdAt: now,
            ),
          );
      return sessionId;
    });
  }

  Future<NarrationSession?> getSession(int id) async {
    final row = await (_db.select(
      _db.narrationSessions,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _mapSession(row);
  }

  Future<List<NarrationSession>> getRecentSessions({int limit = 30}) async {
    final rows =
        await (_db.select(_db.narrationSessions)
              ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])
              ..limit(limit))
            .get();
    return rows.map(_mapSession).toList(growable: false);
  }

  Future<void> confirmTranscript({
    required int sessionId,
    required String cleanedTranscript,
    required NarrationTranscriptConfidence confidence,
    List<NarrationUncertainSegment> uncertainSegments = const [],
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final uncertainJson = jsonEncode(
      uncertainSegments.map((item) => item.toJson()).toList(),
    );
    await _db.transaction(() async {
      await (_db.update(
        _db.narrationSessions,
      )..where((table) => table.id.equals(sessionId))).write(
        db.NarrationSessionsCompanion(
          status: Value(NarrationSessionStatus.translation.name),
          cleanedTranscript: Value(cleanedTranscript),
          transcriptConfidence: Value(confidence.name),
          uncertainSegmentsJson: Value(uncertainJson),
          updatedAt: Value(now),
        ),
      );
      await _db
          .into(_db.narrationTranscriptionLogs)
          .insert(
            db.NarrationTranscriptionLogsCompanion.insert(
              sessionId: sessionId,
              rawTranscript: (await getSession(sessionId))?.rawTranscript ?? '',
              correctedTranscript: Value(cleanedTranscript),
              confidence: confidence.name,
              uncertainSegmentsJson: uncertainJson,
              confirmationResult: 'confirmed',
              manualCleanupJson: const Value('{"applied":true}'),
              createdAt: now,
            ),
          );
    });
  }

  Future<void> saveConfirmedTranslation({
    required int sessionId,
    required String chineseTranslation,
  }) async {
    await (_db.update(
      _db.narrationSessions,
    )..where((table) => table.id.equals(sessionId))).write(
      db.NarrationSessionsCompanion(
        status: Value(NarrationSessionStatus.translation.name),
        chineseTranslation: Value(chineseTranslation),
        translationConfirmed: const Value(true),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> saveTargetDraft({
    required int sessionId,
    required NarrationTargetDraft target,
    bool confirmed = false,
  }) async {
    await (_db.update(
      _db.narrationSessions,
    )..where((table) => table.id.equals(sessionId))).write(
      db.NarrationSessionsCompanion(
        status: Value(NarrationSessionStatus.targetReview.name),
        targetEnglish: Value(target.recommended),
        targetAlternativesJson: Value(
          jsonEncode(target.alternatives.map((item) => item.toJson()).toList()),
        ),
        targetConfirmed: Value(confirmed),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> confirmTarget({
    required int sessionId,
    required String targetEnglish,
  }) async {
    await (_db.update(
      _db.narrationSessions,
    )..where((table) => table.id.equals(sessionId))).write(
      db.NarrationSessionsCompanion(
        targetEnglish: Value(targetEnglish),
        targetConfirmed: const Value(true),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> saveAnalysis({
    required int sessionId,
    required NarrationAnalysis analysis,
    int? durationMs,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.transaction(() async {
      await (_db.update(
        _db.narrationSessions,
      )..where((table) => table.id.equals(sessionId))).write(
        db.NarrationSessionsCompanion(
          status: Value(NarrationSessionStatus.analysed.name),
          normalizedTranscript: Value(analysis.normalizedTranscript),
          analysisJson: Value(jsonEncode(analysis.toJson())),
          correctedExpression: Value(analysis.correctedExpression),
          finalExpression: Value(analysis.correctedExpression),
          analysisDurationMs: Value.absentIfNull(durationMs),
          updatedAt: Value(now),
        ),
      );
      await _db
          .into(_db.narrationSelfCheckLogs)
          .insert(
            db.NarrationSelfCheckLogsCompanion.insert(
              sessionId: sessionId,
              reportJson: jsonEncode(analysis.selfCheck.toJson()),
              iterationCount: analysis.selfCheck.iterations,
              passed:
                  !analysis.selfCheck.needsUserConfirmation &&
                  analysis.selfCheck.checks.every((item) => item.passed),
              createdAt: now,
            ),
          );
    });
  }

  Future<void> confirmFinalExpression({
    required int sessionId,
    required String finalExpression,
  }) async {
    final session = await getSession(sessionId);
    final analysis = session?.analysis;
    if (session == null || analysis == null) {
      throw StateError('narration_analysis_missing');
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.transaction(() async {
      await (_db.update(
        _db.narrationSessions,
      )..where((table) => table.id.equals(sessionId))).write(
        db.NarrationSessionsCompanion(
          status: Value(NarrationSessionStatus.confirmed.name),
          finalExpression: Value(finalExpression),
          finalConfirmed: const Value(true),
          updatedAt: Value(now),
        ),
      );

      final preExistingRows = await _db
          .select(_db.narrationLearningItems)
          .get();
      final preExistingKeys = {
        for (final row in preExistingRows) '${row.itemType}|${row.stableKey}',
      };

      for (final event in analysis.realUsageEvents) {
        final type = NarrationLearningItemType.fromCode(event.itemType);
        if (!preExistingKeys.contains('${type.name}|${event.stableKey}')) {
          continue;
        }
        final existing =
            await (_db.select(_db.narrationLearningItems)..where(
                  (table) =>
                      table.itemType.equals(type.name) &
                      table.stableKey.equals(event.stableKey),
                ))
                .getSingleOrNull();
        if (existing == null) continue;
        final success = event.outcome == 'success';
        await (_db.update(
          _db.narrationLearningItems,
        )..where((table) => table.id.equals(existing.id))).write(
          db.NarrationLearningItemsCompanion(
            masteryState: Value(
              success
                  ? NarrationMasteryState.mastered.code
                  : NarrationMasteryState.suspectedForgotten.code,
            ),
            realUseSuccessCount: Value(
              existing.realUseSuccessCount + (success ? 1 : 0),
            ),
            realUseFailureCount: Value(
              existing.realUseFailureCount + (success ? 0 : 1),
            ),
            nextReviewAt: Value(
              success
                  ? DateTime.fromMillisecondsSinceEpoch(
                      now,
                    ).add(const Duration(days: 30)).millisecondsSinceEpoch
                  : DateTime.fromMillisecondsSinceEpoch(
                      now,
                    ).add(const Duration(days: 1)).millisecondsSinceEpoch,
            ),
            lastTriggerAt: Value(now),
            lastFailureAt: success ? const Value.absent() : Value(now),
            queueState: Value(
              success
                  ? NarrationQueueState.lowFrequency.code
                  : NarrationQueueState.active.code,
            ),
          ),
        );
        await _db
            .into(_db.narrationReviewRecords)
            .insert(
              db.NarrationReviewRecordsCompanion.insert(
                learningItemId: existing.id,
                layer: 'real_output',
                outcome: event.outcome,
                guided: Value(event.guided),
                evidence: Value(event.evidence),
                reviewedAt: now,
              ),
            );
      }

      for (final word in analysis.collectedWords) {
        await _mergeLearningItem(
          sessionId: sessionId,
          itemType: NarrationLearningItemType.word,
          stableKey: word.stableKey,
          english: word.english,
          chinese: word.chinese,
          partOfSpeech: word.partOfSpeech,
          classification: word.category,
          explanation: word.note,
          knowledgeLevel: '',
          reviewRequired: true,
          sourceType: 'word',
          errorGrade: '',
          evidence: word.chinese,
          now: now,
        );
      }
      for (final point in analysis.knowledgePoints) {
        await _mergeLearningItem(
          sessionId: sessionId,
          itemType: NarrationLearningItemType.knowledge,
          stableKey: point.stableKey,
          english: point.title,
          chinese: point.explanation,
          partOfSpeech: '',
          classification: point.source,
          explanation: point.explanation,
          knowledgeLevel: point.level,
          reviewRequired: point.reviewRequired,
          sourceType: point.source,
          errorGrade: point.errorGrade,
          evidence: point.title,
          now: now,
        );
      }

      final metrics = analysis.metrics;
      await _db
          .into(_db.narrationProgressRecords)
          .insertOnConflictUpdate(
            db.NarrationProgressRecordsCompanion.insert(
              sessionId: sessionId,
              errorACount: metrics.errorACount,
              errorBCount: metrics.errorBCount,
              errorCCount: metrics.errorCCount,
              collectedWordCount: analysis.collectedWords.length,
              coreKnowledgeCount: analysis.knowledgePoints
                  .where((item) => item.level == 'core')
                  .length,
              realUseSuccessCount: analysis.realUsageEvents
                  .where((item) => item.outcome == 'success')
                  .length,
              realUseFailureCount: analysis.realUsageEvents
                  .where((item) => item.outcome == 'failure')
                  .length,
              englishWordCount: metrics.englishWordCount,
              sentenceCount: metrics.sentenceCount,
              chineseSubstituteCount: metrics.chineseSubstituteCount,
              complexity: metrics.complexity,
              createdAt: now,
            ),
          );
    });
  }

  Future<List<NarrationLearningItem>> getLearningItems({
    NarrationLearningItemType? type,
  }) async {
    final query = _db.select(_db.narrationLearningItems)
      ..orderBy([
        (table) => OrderingTerm.desc(table.lastSeenAt),
        (table) => OrderingTerm.asc(table.english),
      ]);
    if (type != null) {
      query.where((table) => table.itemType.equals(type.name));
    }
    return (await query.get()).map(_mapLearningItem).toList(growable: false);
  }

  Future<List<NarrationLearningItem>> getExistingItemsForAnalysis() async {
    await updateDormancy();
    return getLearningItems();
  }

  Future<List<NarrationLearningItem>> getDueItems({
    DateTime? at,
    bool includeOptional = false,
  }) async {
    await updateDormancy();
    await _applyStableMasteryRules(at ?? DateTime.now());
    final now = (at ?? DateTime.now()).millisecondsSinceEpoch;
    final rows =
        await (_db.select(_db.narrationLearningItems)..where(
              (table) =>
                  table.nextReviewAt.isSmallerOrEqualValue(now) &
                  table.queueState.isNotIn(['sleeping', 'removed']),
            ))
            .get();
    final items = rows
        .map(_mapLearningItem)
        .where((item) => includeOptional || item.reviewRequired)
        .toList();
    items.sort((a, b) {
      int priority(NarrationLearningItem item) {
        if (item.masteryState == NarrationMasteryState.suspectedForgotten) {
          return 0;
        }
        if (item.nextReviewAt != null &&
            item.nextReviewAt!.isBefore(at ?? DateTime.now())) {
          return 1;
        }
        if (item.occurrenceCount > 1) return 2;
        if (item.masteryState == NarrationMasteryState.newlyAdded) return 3;
        return 4;
      }

      final byPriority = priority(a).compareTo(priority(b));
      if (byPriority != 0) return byPriority;
      return (a.nextReviewAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(b.nextReviewAt ?? DateTime.fromMillisecondsSinceEpoch(0));
    });
    return items;
  }

  Future<void> recordReview({
    required int itemId,
    required String layer,
    required bool passed,
    String? answer,
    String? evidence,
    bool guided = false,
  }) async {
    final row = await (_db.select(
      _db.narrationLearningItems,
    )..where((table) => table.id.equals(itemId))).getSingleOrNull();
    if (row == null) return;
    final nowDate = DateTime.now();
    final now = nowDate.millisecondsSinceEpoch;
    final recognition = layer == 'recognition' && passed
        ? true
        : row.recognitionPassed;
    final application = layer == 'application' && passed
        ? true
        : row.applicationPassed;
    final nextIndex = passed
        ? (row.reviewIntervalIndex + 1).clamp(0, reviewIntervals.length - 1)
        : (row.reviewIntervalIndex - 1).clamp(0, reviewIntervals.length - 1);
    final passCount = row.reviewPassCount + (passed ? 1 : 0);
    final mastery = !passed
        ? (row.masteryState == NarrationMasteryState.mastered.code
              ? NarrationMasteryState.suspectedForgotten
              : NarrationMasteryState.reviewing)
        : row.realUseSuccessCount > 0
        ? NarrationMasteryState.mastered
        : recognition && application && passCount >= 2
        ? NarrationMasteryState.pendingVerification
        : NarrationMasteryState.reviewing;
    await _db.transaction(() async {
      await _db
          .into(_db.narrationReviewRecords)
          .insert(
            db.NarrationReviewRecordsCompanion.insert(
              learningItemId: itemId,
              layer: layer,
              outcome: passed ? 'passed' : 'failed',
              guided: Value(guided),
              answer: Value.absentIfNull(answer),
              evidence: Value.absentIfNull(evidence),
              reviewedAt: now,
            ),
          );
      await (_db.update(
        _db.narrationLearningItems,
      )..where((table) => table.id.equals(itemId))).write(
        db.NarrationLearningItemsCompanion(
          masteryState: Value(mastery.code),
          reviewPassCount: Value(passCount),
          recognitionPassed: Value(recognition),
          applicationPassed: Value(application),
          reviewIntervalIndex: Value(nextIndex),
          nextReviewAt: Value(
            nowDate.add(reviewIntervals[nextIndex]).millisecondsSinceEpoch,
          ),
          lastTriggerAt: Value(now),
          lastFailureAt: passed ? const Value.absent() : Value(now),
          queueState: Value(
            mastery == NarrationMasteryState.mastered
                ? NarrationQueueState.lowFrequency.code
                : NarrationQueueState.active.code,
          ),
        ),
      );
    });
  }

  Future<void> recordFeedback({
    int? sessionId,
    int? learningItemId,
    required String stage,
    required String originalJudgement,
    required String resolution,
    String? systemExplanation,
    String? userReason,
    String? customResult,
  }) async {
    await _db
        .into(_db.narrationFeedbackLogs)
        .insert(
          db.NarrationFeedbackLogsCompanion.insert(
            sessionId: Value.absentIfNull(sessionId),
            learningItemId: Value.absentIfNull(learningItemId),
            stage: stage,
            originalJudgement: originalJudgement,
            systemExplanation: Value.absentIfNull(systemExplanation),
            userReason: Value.absentIfNull(userReason),
            resolution: resolution,
            customResult: Value.absentIfNull(customResult),
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  Future<void> markLearningItemKnown(int itemId) async {
    final now = DateTime.now();
    await (_db.update(
      _db.narrationLearningItems,
    )..where((table) => table.id.equals(itemId))).write(
      db.NarrationLearningItemsCompanion(
        userConfirmed: const Value(true),
        queueState: Value(NarrationQueueState.lowFrequency.code),
        nextReviewAt: Value(
          now.add(const Duration(days: 30)).millisecondsSinceEpoch,
        ),
        notes: const Value('User confirmed this item is already known.'),
      ),
    );
    await recordFeedback(
      learningItemId: itemId,
      stage: 'learning_item',
      originalJudgement: 'Scheduled for ordinary review frequency.',
      systemExplanation:
          'Real use remains the highest mastery signal; user confirmation lowers review frequency.',
      resolution: 'user_confirmed_known',
    );
  }

  Future<void> recordConsent({
    required String consentType,
    required bool granted,
    String policyVersion = 'narration-1.0',
  }) async {
    await _db
        .into(_db.narrationConsentRecords)
        .insert(
          db.NarrationConsentRecordsCompanion.insert(
            consentType: consentType,
            policyVersion: policyVersion,
            granted: granted,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  Future<bool> hasGrantedConsent(String consentType) async {
    final row =
        await (_db.select(_db.narrationConsentRecords)
              ..where((table) => table.consentType.equals(consentType))
              ..orderBy([(table) => OrderingTerm.desc(table.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    return row?.granted == true && row?.revokedAt == null;
  }

  Future<List<NarrationProgressPoint>> getProgress({DateTime? since}) async {
    final query = _db.select(_db.narrationProgressRecords)
      ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]);
    if (since != null) {
      query.where(
        (table) =>
            table.createdAt.isBiggerOrEqualValue(since.millisecondsSinceEpoch),
      );
    }
    return (await query.get())
        .map(
          (row) => NarrationProgressPoint(
            sessionId: row.sessionId,
            createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
            errorACount: row.errorACount,
            errorBCount: row.errorBCount,
            errorCCount: row.errorCCount,
            collectedWordCount: row.collectedWordCount,
            coreKnowledgeCount: row.coreKnowledgeCount,
            realUseSuccessCount: row.realUseSuccessCount,
            realUseFailureCount: row.realUseFailureCount,
            englishWordCount: row.englishWordCount,
            sentenceCount: row.sentenceCount,
            chineseSubstituteCount: row.chineseSubstituteCount,
            complexity: row.complexity,
          ),
        )
        .toList(growable: false);
  }

  Future<NarrationDashboardSummary> getDashboardSummary() async {
    await _applyStableMasteryRules(DateTime.now());
    final sessions = await _db.select(_db.narrationSessions).get();
    final items = await getLearningItems();
    final due = await getDueItems(includeOptional: true);
    return NarrationDashboardSummary(
      sessionCount: sessions
          .where((row) => row.status == NarrationSessionStatus.confirmed.name)
          .length,
      wordCount: items
          .where((item) => item.type == NarrationLearningItemType.word)
          .length,
      knowledgeCount: items
          .where((item) => item.type == NarrationLearningItemType.knowledge)
          .length,
      dueCount: due.length,
      masteredCount: items
          .where(
            (item) =>
                item.masteryState == NarrationMasteryState.mastered ||
                item.masteryState == NarrationMasteryState.stable,
          )
          .length,
      realUseSuccessCount: items.fold(
        0,
        (sum, item) => sum + item.realUseSuccessCount,
      ),
    );
  }

  Future<String> exportJson() async {
    final sessions = await _db.select(_db.narrationSessions).get();
    final transcriptionLogs = await _db
        .select(_db.narrationTranscriptionLogs)
        .get();
    final selfCheckLogs = await _db.select(_db.narrationSelfCheckLogs).get();
    final feedbackLogs = await _db.select(_db.narrationFeedbackLogs).get();
    final items = await _db.select(_db.narrationLearningItems).get();
    final sources = await _db.select(_db.narrationLearningSources).get();
    final reviews = await _db.select(_db.narrationReviewRecords).get();
    final progress = await _db.select(_db.narrationProgressRecords).get();
    final consent = await _db.select(_db.narrationConsentRecords).get();
    return const JsonEncoder.withIndent('  ').convert({
      'exported_at': DateTime.now().toIso8601String(),
      'sessions': sessions.map((row) => row.toJson()).toList(),
      'transcription_logs': transcriptionLogs
          .map((row) => row.toJson())
          .toList(),
      'self_check_logs': selfCheckLogs.map((row) => row.toJson()).toList(),
      'feedback_logs': feedbackLogs.map((row) => row.toJson()).toList(),
      'learning_items': items.map((row) => row.toJson()).toList(),
      'learning_sources': sources.map((row) => row.toJson()).toList(),
      'review_records': reviews.map((row) => row.toJson()).toList(),
      'progress_records': progress.map((row) => row.toJson()).toList(),
      'consent_records': consent.map((row) => row.toJson()).toList(),
    });
  }

  Future<void> deleteSession(int sessionId) async {
    await (_db.delete(
      _db.narrationSessions,
    )..where((table) => table.id.equals(sessionId))).go();
  }

  Future<List<String>> getRetainedAudioPaths() async {
    final rows =
        await (_db.select(_db.narrationSessions)..where(
              (table) =>
                  table.audioRetained.equals(true) &
                  table.audioPath.isNotNull(),
            ))
            .get();
    return rows.map((row) => row.audioPath).whereType<String>().toList();
  }

  Future<void> deleteAllNarrationData() async {
    await _db.transaction(() async {
      await _db.delete(_db.narrationReviewRecords).go();
      await _db.delete(_db.narrationLearningSources).go();
      await _db.delete(_db.narrationLearningItems).go();
      await _db.delete(_db.narrationFeedbackLogs).go();
      await _db.delete(_db.narrationSelfCheckLogs).go();
      await _db.delete(_db.narrationTranscriptionLogs).go();
      await _db.delete(_db.narrationProgressRecords).go();
      await _db.delete(_db.narrationConsentRecords).go();
      await _db.delete(_db.narrationSessions).go();
    });
  }

  Future<void> updateDormancy() async {
    final latestSession =
        await (_db.select(_db.narrationSessions)
              ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])
              ..limit(1))
            .getSingleOrNull();
    final latestReview =
        await (_db.select(_db.narrationReviewRecords)
              ..orderBy([(table) => OrderingTerm.desc(table.reviewedAt)])
              ..limit(1))
            .getSingleOrNull();
    final lastActive = [latestSession?.updatedAt, latestReview?.reviewedAt]
        .whereType<int>()
        .fold<int?>(null, (latest, value) {
          if (latest == null || value > latest) return value;
          return latest;
        });
    if (lastActive == null) return;
    final inactiveFor = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(lastActive),
    );
    if (inactiveFor < const Duration(days: 60)) return;
    await _db.transaction(() async {
      await (_db.update(_db.narrationLearningItems)..where(
            (table) => table.queueState.isNotIn(['removed', 'sleeping']),
          ))
          .write(
            db.NarrationLearningItemsCompanion(
              queueState: Value(NarrationQueueState.sleeping.code),
            ),
          );
      await (_db.update(_db.narrationLearningItems)..where(
            (table) =>
                table.masteryState.equals(NarrationMasteryState.mastered.code),
          ))
          .write(
            db.NarrationLearningItemsCompanion(
              masteryState: Value(NarrationMasteryState.needsRevalidation.code),
            ),
          );
    });
  }

  Future<void> _applyStableMasteryRules(DateTime now) async {
    final cutoff = now.subtract(const Duration(days: 90));
    final rows =
        await (_db.select(_db.narrationLearningItems)..where(
              (table) =>
                  table.masteryState.equals(
                    NarrationMasteryState.mastered.code,
                  ) &
                  table.queueState.isNotIn(['sleeping', 'removed']),
            ))
            .get();
    for (final row in rows) {
      final trigger = row.lastTriggerAt;
      final oldEnough = row.firstSeenAt <= cutoff.millisecondsSinceEpoch;
      final recentlyTriggered =
          trigger != null && trigger >= cutoff.millisecondsSinceEpoch;
      final triggerSucceeded =
          trigger != null &&
          (row.lastFailureAt == null || row.lastFailureAt! < trigger);
      if (!oldEnough || !recentlyTriggered || !triggerSucceeded) continue;
      await (_db.update(
        _db.narrationLearningItems,
      )..where((table) => table.id.equals(row.id))).write(
        db.NarrationLearningItemsCompanion(
          masteryState: Value(NarrationMasteryState.stable.code),
          queueState: Value(NarrationQueueState.removed.code),
          nextReviewAt: const Value(null),
        ),
      );
    }
  }

  Future<void> _activateSleepingQueue(int now) async {
    await (_db.update(
      _db.narrationLearningItems,
    )..where((table) => table.queueState.equals('sleeping'))).write(
      db.NarrationLearningItemsCompanion(
        queueState: Value(NarrationQueueState.active.code),
        nextReviewAt: Value(now),
      ),
    );
  }

  Future<int> _mergeLearningItem({
    required int sessionId,
    required NarrationLearningItemType itemType,
    required String stableKey,
    required String english,
    required String chinese,
    required String partOfSpeech,
    required String classification,
    required String knowledgeLevel,
    required String explanation,
    required bool reviewRequired,
    required String sourceType,
    required String errorGrade,
    required String evidence,
    required int now,
  }) async {
    final normalizedKey = stableKey.trim().toLowerCase();
    final existing =
        await (_db.select(_db.narrationLearningItems)..where(
              (table) =>
                  table.itemType.equals(itemType.name) &
                  table.stableKey.equals(normalizedKey),
            ))
            .getSingleOrNull();
    late final int itemId;
    if (existing == null) {
      itemId = await _db
          .into(_db.narrationLearningItems)
          .insert(
            db.NarrationLearningItemsCompanion.insert(
              itemType: itemType.name,
              stableKey: normalizedKey,
              english: english,
              chinese: chinese,
              partOfSpeech: Value(partOfSpeech),
              classification: Value(classification),
              knowledgeLevel: Value(knowledgeLevel),
              explanation: Value(explanation),
              reviewRequired: Value(reviewRequired),
              firstSeenAt: now,
              lastSeenAt: now,
              nextReviewAt: reviewRequired
                  ? Value(
                      DateTime.fromMillisecondsSinceEpoch(
                        now,
                      ).add(reviewIntervals.first).millisecondsSinceEpoch,
                    )
                  : const Value.absent(),
            ),
          );
    } else {
      itemId = existing.id;
      await (_db.update(
        _db.narrationLearningItems,
      )..where((table) => table.id.equals(itemId))).write(
        db.NarrationLearningItemsCompanion(
          english: Value(english),
          chinese: Value(chinese),
          partOfSpeech: Value(partOfSpeech),
          classification: Value(classification),
          knowledgeLevel: Value(knowledgeLevel),
          explanation: Value(explanation),
          reviewRequired: Value(reviewRequired),
          lastSeenAt: Value(now),
          occurrenceCount: Value(existing.occurrenceCount + 1),
          queueState: existing.queueState == 'removed'
              ? Value(NarrationQueueState.active.code)
              : const Value.absent(),
        ),
      );
    }
    await _db
        .into(_db.narrationLearningSources)
        .insert(
          db.NarrationLearningSourcesCompanion.insert(
            learningItemId: itemId,
            sessionId: sessionId,
            sourceType: sourceType,
            errorGrade: Value(errorGrade),
            evidence: Value(evidence),
            createdAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    return itemId;
  }

  NarrationSession _mapSession(db.NarrationSession row) {
    NarrationAnalysis? analysis;
    if (row.analysisJson != null && row.analysisJson!.isNotEmpty) {
      try {
        analysis = NarrationAnalysis.fromJson(
          Map<String, dynamic>.from(jsonDecode(row.analysisJson!) as Map),
        );
      } on FormatException {
        analysis = null;
      }
    }
    return NarrationSession(
      id: row.id,
      status: NarrationSessionStatus.fromCode(row.status),
      rawTranscript: row.rawTranscript,
      cleanedTranscript: row.cleanedTranscript,
      transcriptConfidence: NarrationTranscriptConfidence.fromCode(
        row.transcriptConfidence,
      ),
      uncertainSegments: _decodeMaps(
        row.uncertainSegmentsJson,
      ).map(NarrationUncertainSegment.fromJson).toList(growable: false),
      chineseTranslation: row.chineseTranslation,
      translationConfirmed: row.translationConfirmed,
      targetEnglish: row.targetEnglish,
      targetAlternatives: _decodeMaps(
        row.targetAlternativesJson,
      ).map(NarrationTargetAlternative.fromJson).toList(growable: false),
      targetConfirmed: row.targetConfirmed,
      normalizedTranscript: row.normalizedTranscript,
      analysis: analysis,
      correctedExpression: row.correctedExpression,
      finalExpression: row.finalExpression,
      finalConfirmed: row.finalConfirmed,
      audioPath: row.audioPath,
      audioRetained: row.audioRetained,
      accent: row.accent,
      register: row.speechRegister,
      thinkingEnabled: row.thinkingEnabled,
      analysisDurationMs: row.analysisDurationMs,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
    );
  }

  NarrationLearningItem _mapLearningItem(db.NarrationLearningItem row) {
    DateTime? date(int? value) =>
        value == null ? null : DateTime.fromMillisecondsSinceEpoch(value);
    return NarrationLearningItem(
      id: row.id,
      type: NarrationLearningItemType.fromCode(row.itemType),
      stableKey: row.stableKey,
      english: row.english,
      chinese: row.chinese,
      partOfSpeech: row.partOfSpeech,
      classification: row.classification,
      knowledgeLevel: row.knowledgeLevel,
      explanation: row.explanation,
      reviewRequired: row.reviewRequired,
      firstSeenAt: DateTime.fromMillisecondsSinceEpoch(row.firstSeenAt),
      lastSeenAt: DateTime.fromMillisecondsSinceEpoch(row.lastSeenAt),
      occurrenceCount: row.occurrenceCount,
      masteryState: NarrationMasteryState.fromCode(row.masteryState),
      reviewPassCount: row.reviewPassCount,
      recognitionPassed: row.recognitionPassed,
      applicationPassed: row.applicationPassed,
      realUseSuccessCount: row.realUseSuccessCount,
      realUseFailureCount: row.realUseFailureCount,
      nextReviewAt: date(row.nextReviewAt),
      reviewIntervalIndex: row.reviewIntervalIndex,
      lastTriggerAt: date(row.lastTriggerAt),
      lastFailureAt: date(row.lastFailureAt),
      queueState: NarrationQueueState.fromCode(row.queueState),
      userConfirmed: row.userConfirmed,
      notes: row.notes,
    );
  }

  List<Map<String, dynamic>> _decodeMaps(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is! List) return const [];
      return decoded.whereType<Map>().map(Map<String, dynamic>.from).toList();
    } on FormatException {
      return const [];
    }
  }
}
