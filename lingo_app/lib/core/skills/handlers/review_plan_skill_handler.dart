import '../../../data/database/app_database.dart';
import '../../../data/repositories/repositories.dart';
import '../skill_definition.dart';
import '../skill_handler.dart';

class ReviewPlanSkillHandler implements SkillHandler {
  final WordListRepository _wordListRepository;
  final PracticeRepository _practiceRepository;

  ReviewPlanSkillHandler({
    required WordListRepository wordListRepository,
    required PracticeRepository practiceRepository,
  }) : _wordListRepository = wordListRepository,
       _practiceRepository = practiceRepository;

  @override
  Future<SkillRunResult> run(
    Map<String, Object?> inputs,
    SkillRunContext context,
  ) async {
    final listId = inputs['list_id'] as int?;
    if (listId == null) {
      throw const SkillException('skill_error_missing_list');
    }

    context.onProgress(
      const SkillRunProgress(messageKey: 'skill_progress_loading_review_data'),
    );

    final list = await _wordListRepository.getList(listId);
    if (list == null) {
      throw const SkillException('skill_error_missing_list');
    }

    final stats = await _practiceRepository.getReviewWordStats();
    final listWords = await _wordListRepository.getWordsForList(listId);
    final listWordIds = listWords.map((word) => word.id).toSet();
    final listStats =
        stats.where((stat) => listWordIds.contains(stat.word.id)).toList()
          ..sort(_compareReviewPriority);
    final sessions = await _practiceRepository.getSessionsForList(listId);
    context.throwIfCancelled();

    final activeErrorCount = listStats
        .where((stat) => stat.isErrorActive)
        .length;
    final activeForgottenCount = listStats
        .where((stat) => stat.isForgottenActive)
        .length;
    final focusWords = listStats
        .where((stat) => stat.isErrorActive || stat.isForgottenActive)
        .take(10)
        .map(_formatFocusWord)
        .toList();
    final recentSessions = sessions.take(3).toList();
    final avgAccuracy = _averageAccuracy(recentSessions);

    final sections = <SkillResultSection>[
      SkillResultSection(
        titleKey: 'skill_result_review_summary',
        lines: [
          SkillResultLine.key(
            'skill_review_plan_list_line',
            params: {'name': list.name},
          ),
          SkillResultLine.key(
            'skill_review_plan_words_line',
            params: {'count': list.wordCount.toString()},
          ),
          SkillResultLine.key(
            'skill_review_plan_errors_line',
            params: {'count': activeErrorCount.toString()},
          ),
          SkillResultLine.key(
            'skill_review_plan_forgotten_line',
            params: {'count': activeForgottenCount.toString()},
          ),
          avgAccuracy == null
              ? const SkillResultLine.key(
                  'skill_review_plan_accuracy_none_line',
                )
              : SkillResultLine.key(
                  'skill_review_plan_accuracy_line',
                  params: {'accuracy': _formatPercent(avgAccuracy)},
                ),
        ],
      ),
      SkillResultSection(
        titleKey: 'skill_result_review_next_steps',
        lines: _buildNextSteps(
          activeErrorCount: activeErrorCount,
          activeForgottenCount: activeForgottenCount,
          avgAccuracy: avgAccuracy,
          hasSessions: sessions.isNotEmpty,
        ),
      ),
      SkillResultSection(
        titleKey: 'skill_result_review_focus_words',
        lines: focusWords.isEmpty
            ? [const SkillResultLine.key('skill_review_plan_no_focus_words')]
            : focusWords,
      ),
    ];

    if (recentSessions.isNotEmpty) {
      sections.add(
        SkillResultSection(
          titleKey: 'skill_result_recent_sessions',
          lines: recentSessions.map(_formatSession).toList(),
        ),
      );
    }

    return SkillRunResult(
      skillId: 'review_plan',
      summaryKey: 'skill_result_review_plan_summary',
      summaryParams: {
        'errors': activeErrorCount.toString(),
        'forgotten': activeForgottenCount.toString(),
      },
      sections: sections,
    );
  }

  static int _compareReviewPriority(ReviewWordStat a, ReviewWordStat b) {
    final aScore = a.errorCount * 2 + a.forgottenCount;
    final bScore = b.errorCount * 2 + b.forgottenCount;
    final cmp = bScore.compareTo(aScore);
    if (cmp != 0) return cmp;
    return a.word.english.toLowerCase().compareTo(b.word.english.toLowerCase());
  }

  static SkillResultLine _formatFocusWord(ReviewWordStat stat) {
    return SkillResultLine.key(
      'skill_review_plan_focus_word_line',
      params: {
        'word': stat.word.english,
        'errors': stat.errorCount.toString(),
        'forgotten': stat.forgottenCount.toString(),
      },
    );
  }

  static double? _averageAccuracy(List<PracticeSession> sessions) {
    if (sessions.isEmpty) return null;
    final total = sessions.fold<double>(
      0,
      (sum, session) => sum + session.accuracy,
    );
    return total / sessions.length;
  }

  static String _formatPercent(double value) {
    return '${(value * 100).round()}%';
  }

  static List<SkillResultLine> _buildNextSteps({
    required int activeErrorCount,
    required int activeForgottenCount,
    required double? avgAccuracy,
    required bool hasSessions,
  }) {
    final steps = <SkillResultLine>[];
    if (activeForgottenCount > 0) {
      steps.add(const SkillResultLine.key('skill_review_plan_step_forgotten'));
    }
    if (activeErrorCount > 0) {
      steps.add(const SkillResultLine.key('skill_review_plan_step_errors'));
    }
    if (!hasSessions) {
      steps.add(const SkillResultLine.key('skill_review_plan_step_baseline'));
    } else if (avgAccuracy != null && avgAccuracy < 0.75) {
      steps.add(
        const SkillResultLine.key('skill_review_plan_step_low_accuracy'),
      );
    } else {
      steps.add(
        const SkillResultLine.key('skill_review_plan_step_high_accuracy'),
      );
    }
    if (activeErrorCount == 0 && activeForgottenCount == 0) {
      steps.add(const SkillResultLine.key('skill_review_plan_step_clear'));
    }
    return steps;
  }

  static SkillResultLine _formatSession(PracticeSession session) {
    final accuracy = (session.accuracy * 100).round();
    return SkillResultLine.key(
      'skill_review_plan_session_line',
      paramKeys: {'mode': _modeKey(session.mode)},
      params: {
        'accuracy': '$accuracy%',
        'correct': session.correctCount.toString(),
        'total': session.totalCount.toString(),
      },
    );
  }

  static String _modeKey(String mode) {
    return switch (mode) {
      'choice' => 'mode_choice',
      'fill' => 'mode_fill',
      'dictation' => 'mode_dictation',
      'deep_choice' => 'mode_deep_choice',
      'deep_fill' => 'mode_deep_fill',
      'deep_idioms' => 'mode_deep_idioms',
      'audioChoice' => 'audio_choice',
      _ => 'practice_section',
    };
  }
}
