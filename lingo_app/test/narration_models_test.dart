import 'package:flutter_test/flutter_test.dart';

import 'package:lingo_app/data/models/narration_ai_models.dart';
import 'package:lingo_app/data/ai/prompts.dart';
import 'package:lingo_app/core/i18n/app_strings.dart';

void main() {
  test('parses and reconciles a complete narration analysis', () {
    final analysis = NarrationAnalysis.fromJson({
      'normalized_transcript': 'I have a 苹果.',
      'sentence_pairs': [
        {
          'original': 'I have a 苹果.',
          'corrected': 'I have an apple.',
          'differences': [
            {
              'original': '苹果',
              'corrected': 'apple',
              'type': 'chinese_substitute',
              'reason': 'Vocabulary substitute',
            },
          ],
        },
      ],
      'errors': [
        {
          'grade': 'B',
          'original': 'a 苹果',
          'issue': 'Wrong article',
          'correction': 'an apple',
          'reason': 'Apple begins with a vowel sound.',
        },
      ],
      'collected_words': [
        {
          'stable_key': 'Apple',
          'chinese': '苹果',
          'english': 'apple',
          'part_of_speech': 'noun',
          'category': 'word',
        },
      ],
      'knowledge_points': [
        {
          'stable_key': 'articles_a_an',
          'title': 'a/an',
          'explanation': 'Use an before a vowel sound.',
          'level': 'core',
          'source': 'error',
          'review_required': true,
          'error_grade': 'B',
        },
      ],
      'speech_features': [],
      'corrected_expression': 'I have an apple.',
      'acceptable_variants': [],
      'self_check': {
        'iterations': 1,
        'needs_user_confirmation': false,
        'checks': [
          {'key': 'form', 'passed': true, 'detail': 'No form errors.'},
        ],
      },
      'metrics': {
        'english_word_count': 0,
        'sentence_count': 0,
        'chinese_substitute_count': 0,
        'error_a_count': 99,
        'error_b_count': 99,
        'error_c_count': 99,
        'complexity': 140,
      },
      'real_usage_events': [],
    });

    expect(analysis.collectedWords.single.stableKey, 'apple');
    expect(analysis.errors.single.grade, 'B');
    expect(analysis.metrics.errorACount, 0);
    expect(analysis.metrics.errorBCount, 1);
    expect(analysis.metrics.englishWordCount, 3);
    expect(analysis.metrics.sentenceCount, 1);
    expect(analysis.metrics.chineseSubstituteCount, 1);
    expect(analysis.metrics.complexity, 100);
  });

  test('rejects unsupported enum values with safe product defaults', () {
    final word = NarrationCollectedWord.fromJson({
      'stable_key': '',
      'chinese': '测试',
      'english': 'Test phrase',
      'category': 'unsupported',
    });
    final point = NarrationKnowledgePoint.fromJson({
      'stable_key': '',
      'title': 'Word order',
      'level': 'unsupported',
      'source': 'unsupported',
    });

    expect(word.stableKey, 'test_phrase');
    expect(word.category, 'word');
    expect(point.stableKey, 'word_order');
    expect(point.level, 'core');
    expect(point.reviewRequired, isTrue);
  });

  test('narration screens have English and Chinese translations', () {
    const keys = [
      'narration_title',
      'narration_new',
      'narration_review',
      'narration_library',
      'narration_progress',
      'narration_confidence_high',
      'narration_confidence_medium',
      'narration_confidence_low',
      'narration_status_transcript_review',
      'narration_status_translation',
      'narration_status_target_review',
      'narration_status_analysed',
      'narration_status_confirmed',
      'narration_grade_a',
      'narration_grade_b',
      'narration_grade_c',
      'narration_knowledge_core',
      'narration_knowledge_related',
      'narration_knowledge_extended',
      'narration_mastery_new',
      'narration_mastery_reviewing',
      'narration_mastery_pending_verification',
      'narration_mastery_mastered',
      'narration_mastery_suspected_forgotten',
      'narration_mastery_stable',
      'narration_mastery_needs_revalidation',
      'narration_check_semantics',
      'narration_check_form',
      'narration_check_naturalness',
      'narration_check_consistency',
      'narration_check_style',
    ];

    for (final key in keys) {
      expect(AppStrings.get(key, 'en'), isNot(key), reason: 'missing en $key');
      expect(AppStrings.get(key, 'zh'), isNot(key), reason: 'missing zh $key');
    }
  });

  test('narration AI prompts require Chinese explanatory prose', () {
    final targetPrompt = AiPrompts.narrationTargetPrompt(
      transcript: 'I study English.',
      chineseTranslation: '我学习英语。',
      accent: 'british',
      register: 'spoken',
    );
    final analysisPrompt = AiPrompts.narrationAnalysisPrompt(
      rawTranscript: 'I study English.',
      cleanedTranscript: 'I study English.',
      chineseTranslation: '我学习英语。',
      targetEnglish: 'I study English.',
      accent: 'british',
      register: 'spoken',
      existingLearningItems: const [],
    );

    expect(targetPrompt, contains('MUST be written in Simplified Chinese'));
    expect(
      targetPrompt,
      contains('alternatives[].difference and conflict_message'),
    );
    expect(
      targetPrompt,
      contains('Keep recommended and alternatives[].text in English'),
    );
    expect(analysisPrompt, contains('Mandatory output-language contract'));
    expect(analysisPrompt, contains('errors[].issue and errors[].reason'));
    expect(analysisPrompt, contains('knowledge_points[].title'));
    expect(analysisPrompt, contains('self_check.checks[].detail'));
    expect(analysisPrompt, contains('Do not return English explanatory prose'));
  });

  test('detects English explanatory prose and accepts Chinese prose', () {
    final englishTarget = NarrationTargetDraft(
      recommended: 'I study English.',
      alternatives: const [
        NarrationTargetAlternative(
          text: 'I am studying English.',
          difference: 'This emphasises an ongoing activity.',
        ),
      ],
    );
    final chineseTarget = NarrationTargetDraft(
      recommended: 'I study English.',
      alternatives: const [
        NarrationTargetAlternative(
          text: 'I am studying English.',
          difference: '这个版本更强调正在持续进行的学习。',
        ),
      ],
    );
    final englishAnalysis = NarrationAnalysis(
      normalizedTranscript: 'I study English.',
      correctedExpression: 'I study English.',
      errors: const [
        NarrationErrorItem(
          grade: 'C',
          original: 'English study',
          issue: 'Less idiomatic wording',
          correction: 'English studies',
          reason: 'The plural form is more natural here.',
        ),
      ],
      selfCheck: const NarrationSelfCheckReport(
        iterations: 1,
        needsUserConfirmation: false,
      ),
      metrics: const NarrationMetrics(),
    );
    final chineseAnalysis = NarrationAnalysis(
      normalizedTranscript: 'I study English.',
      correctedExpression: 'I study English.',
      errors: const [
        NarrationErrorItem(
          grade: 'C',
          original: 'English study',
          issue: '此处措辞不够地道',
          correction: 'English studies',
          reason: '这里使用复数形式更符合英语的自然表达习惯。',
        ),
      ],
      selfCheck: const NarrationSelfCheckReport(
        iterations: 1,
        needsUserConfirmation: false,
      ),
      metrics: const NarrationMetrics(),
    );

    expect(englishTarget.hasChineseExplanations, isFalse);
    expect(chineseTarget.hasChineseExplanations, isTrue);
    expect(englishAnalysis.hasChineseExplanations, isFalse);
    expect(chineseAnalysis.hasChineseExplanations, isTrue);
  });
}
