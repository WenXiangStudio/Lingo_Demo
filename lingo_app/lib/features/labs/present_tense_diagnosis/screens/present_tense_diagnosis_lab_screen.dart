import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/app_strings.dart';
import '../../../../data/diagnosis/present_tense_diagnosis_client.dart';
import '../../../../data/providers.dart';
import '../models/diagnosis_lab_record.dart';
import '../providers/present_tense_diagnosis_lab_providers.dart';

class PresentTenseDiagnosisLabScreen extends ConsumerStatefulWidget {
  const PresentTenseDiagnosisLabScreen({super.key});

  @override
  ConsumerState<PresentTenseDiagnosisLabScreen> createState() =>
      _PresentTenseDiagnosisLabScreenState();
}

class _PresentTenseDiagnosisLabScreenState
    extends ConsumerState<PresentTenseDiagnosisLabScreen> {
  static const _questions = [
    _LabQuestion('lab_present_question_1'),
    _LabQuestion('lab_present_question_2'),
    _LabQuestion('lab_present_question_3'),
    _LabQuestion('lab_present_question_4'),
    _LabQuestion('lab_present_question_5'),
    _LabQuestion('lab_present_question_6'),
    _LabQuestion('lab_present_question_7'),
    _LabQuestion('lab_present_question_8'),
    _LabQuestion('lab_present_question_9'),
    _LabQuestion('lab_present_question_10'),
    _LabQuestion('lab_present_question_11'),
    _LabQuestion('lab_present_question_12'),
  ];

  static const _knownGapCases = [
    _KnownGapCase(
      labelKey: 'lab_present_known_gap_1_label',
      questionIndex: 10,
      answerKey: 'lab_present_known_gap_1_answer',
      expectedKey: 'lab_present_known_gap_1_expected',
      unitsKey: 'lab_present_known_gap_1_units',
    ),
    _KnownGapCase(
      labelKey: 'lab_present_known_gap_2_label',
      questionIndex: 4,
      answerKey: 'lab_present_known_gap_2_answer',
      expectedKey: 'lab_present_known_gap_2_expected',
      unitsKey: 'lab_present_known_gap_2_units',
    ),
  ];

  final _answerController = TextEditingController();
  final _jsonEncoder = const JsonEncoder.withIndent('  ');

  int _selectedQuestion = 0;
  bool _isSubmitting = false;
  String? _error;
  String? _recordsPath;
  PresentTenseDiagnosisResult? _result;
  DiagnosisLabRecord? _currentRecord;
  List<DiagnosisLabRecord> _recentRecords = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecentRecords();
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final theme = Theme.of(context);
    final question = AppStrings.get(_questions[_selectedQuestion].key, lang);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('lab_present_title', lang))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _SectionHeader(
            icon: Icons.science_outlined,
            title: AppStrings.get('lab_present_experiment_badge', lang),
            subtitle: AppStrings.get('lab_present_intro', lang),
          ),
          const SizedBox(height: 18),
          _QuestionSection(
            lang: lang,
            selectedQuestion: _selectedQuestion,
            questions: _questions,
            question: question,
            onChanged: _isSubmitting
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _selectedQuestion = value);
                  },
          ),
          const SizedBox(height: 20),
          _KnownGapCasesSection(
            lang: lang,
            cases: _knownGapCases,
            questions: _questions,
            onLoadCase: (caseItem) => _loadKnownGapCase(caseItem, lang),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _answerController,
            enabled: !_isSubmitting,
            minLines: 3,
            maxLines: 6,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              labelText: AppStrings.get('lab_present_answer_label', lang),
              hintText: AppStrings.get('lab_present_answer_hint', lang),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: AppStrings.get('lab_present_use_sample', lang),
                icon: const Icon(Icons.bolt_outlined),
                onPressed: _isSubmitting
                    ? null
                    : () {
                        _answerController.text = AppStrings.get(
                          'lab_present_sample_answer',
                          lang,
                        );
                      },
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _isSubmitting ? null : () => _submit(lang, question),
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined),
            label: Text(
              _isSubmitting
                  ? AppStrings.get('lab_present_submitting', lang)
                  : AppStrings.get('lab_present_submit', lang),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  AppStrings.get(
                    'lab_present_submit_failed',
                    lang,
                    params: {'error': _error!},
                  ),
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _FeedbackSection(result: _result, lang: lang),
          const SizedBox(height: 16),
          _RatingSection(
            record: _currentRecord,
            lang: lang,
            isEnabled: !_isSubmitting && _currentRecord != null,
            onRatingChanged: (rating) => _saveRating(lang, rating),
          ),
          const SizedBox(height: 16),
          _DebugSection(
            result: _result,
            currentRecord: _currentRecord,
            recentRecords: _recentRecords,
            recordsPath: _recordsPath,
            jsonEncoder: _jsonEncoder,
            lang: lang,
          ),
        ],
      ),
    );
  }

  Future<void> _loadRecentRecords() async {
    final store = ref.read(diagnosisLabRecordStoreProvider);
    final records = await store.loadRecords();
    final path = await store.recordsPath();
    if (!mounted) return;
    setState(() {
      _recentRecords = records;
      _recordsPath = path;
    });
  }

  void _loadKnownGapCase(_KnownGapCase caseItem, String lang) {
    setState(() {
      _selectedQuestion = caseItem.questionIndex;
      _answerController.text = AppStrings.get(caseItem.answerKey, lang);
      _error = null;
      _result = null;
      _currentRecord = null;
    });
  }

  Future<void> _submit(String lang, String question) async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('lab_present_empty_answer', lang)),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final result = await ref
          .read(presentTenseDiagnosisClientProvider)
          .diagnose(question: question, answer: answer);
      final now = DateTime.now();
      final record = DiagnosisLabRecord.fromResult(
        id: now.microsecondsSinceEpoch.toString(),
        result: result,
        createdAt: now,
      );
      final store = ref.read(diagnosisLabRecordStoreProvider);
      final savedRecord = await store.saveSubmission(record);
      final records = await store.loadRecords();
      final recordsPath = await store.recordsPath();
      if (!mounted) return;
      setState(() {
        _result = result;
        _currentRecord = savedRecord;
        _recentRecords = records;
        _recordsPath = recordsPath;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _saveRating(String lang, DiagnosisLabRating rating) async {
    final record = _currentRecord;
    if (record == null) return;
    try {
      final store = ref.read(diagnosisLabRecordStoreProvider);
      final updated = await store.saveRating(
        recordId: record.id,
        rating: rating,
      );
      final records = await store.loadRecords();
      if (!mounted) return;
      setState(() {
        _currentRecord = updated;
        _recentRecords = records;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.get(
              'lab_present_rating_failed',
              lang,
              params: {'error': error.toString()},
            ),
          ),
        ),
      );
    }
  }
}

class _LabQuestion {
  final String key;

  const _LabQuestion(this.key);
}

class _KnownGapCase {
  final String labelKey;
  final int questionIndex;
  final String answerKey;
  final String expectedKey;
  final String unitsKey;

  const _KnownGapCase({
    required this.labelKey,
    required this.questionIndex,
    required this.answerKey,
    required this.expectedKey,
    required this.unitsKey,
  });
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.72,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionSection extends StatelessWidget {
  final String lang;
  final int selectedQuestion;
  final List<_LabQuestion> questions;
  final String question;
  final ValueChanged<int?>? onChanged;

  const _QuestionSection({
    required this.lang,
    required this.selectedQuestion,
    required this.questions,
    required this.question,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('lab_present_question_section', lang),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          key: ValueKey(selectedQuestion),
          initialValue: selectedQuestion,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: AppStrings.get('lab_present_question_picker', lang),
            border: const OutlineInputBorder(),
          ),
          items: [
            for (var i = 0; i < questions.length; i++)
              DropdownMenuItem(
                value: i,
                child: Text(
                  AppStrings.get(questions[i].key, lang),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.help_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _KnownGapCasesSection extends StatelessWidget {
  final String lang;
  final List<_KnownGapCase> cases;
  final List<_LabQuestion> questions;
  final ValueChanged<_KnownGapCase> onLoadCase;

  const _KnownGapCasesSection({
    required this.lang,
    required this.cases,
    required this.questions,
    required this.onLoadCase,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: Text(
        AppStrings.get('lab_present_known_gap_section', lang),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(AppStrings.get('lab_present_known_gap_desc', lang)),
      children: [
        for (final caseItem in cases) ...[
          _KnownGapCaseTile(
            lang: lang,
            caseItem: caseItem,
            question: AppStrings.get(
              questions[caseItem.questionIndex].key,
              lang,
            ),
            onLoadCase: onLoadCase,
          ),
          if (caseItem != cases.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _KnownGapCaseTile extends StatelessWidget {
  final String lang;
  final _KnownGapCase caseItem;
  final String question;
  final ValueChanged<_KnownGapCase> onLoadCase;

  const _KnownGapCaseTile({
    required this.lang,
    required this.caseItem,
    required this.question,
    required this.onLoadCase,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get(caseItem.labelKey, lang),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _FeedbackLine(
              label: AppStrings.get('lab_present_question_section', lang),
              value: question,
            ),
            _FeedbackLine(
              label: AppStrings.get('lab_present_known_gap_answer', lang),
              value: AppStrings.get(caseItem.answerKey, lang),
            ),
            _FeedbackLine(
              label: AppStrings.get('lab_present_known_gap_expected', lang),
              value: AppStrings.get(caseItem.expectedKey, lang),
            ),
            _FeedbackLine(
              label: AppStrings.get('lab_present_known_gap_units', lang),
              value: AppStrings.get(caseItem.unitsKey, lang),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => onLoadCase(caseItem),
                icon: const Icon(Icons.playlist_add_check_outlined),
                label: Text(AppStrings.get('lab_present_known_gap_load', lang)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackSection extends StatelessWidget {
  final PresentTenseDiagnosisResult? result;
  final String lang;

  const _FeedbackSection({required this.result, required this.lang});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = this.result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('lab_present_feedback_section', lang),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        if (result == null)
          Text(
            AppStrings.get('lab_present_feedback_empty', lang),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
            ),
          )
        else ...[
          _StatusBanner(hasError: result.hasError, lang: lang),
          if (result.errors.isNotEmpty) ...[
            const SizedBox(height: 14),
            for (var i = 0; i < result.errors.length; i++) ...[
              _ErrorBlock(index: i + 1, error: result.errors[i], lang: lang),
              if (i != result.errors.length - 1) const SizedBox(height: 12),
            ],
          ],
          if (result.correctedAnswer.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              AppStrings.get('lab_present_corrected_answer', lang),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            SelectableText(result.correctedAnswer),
          ],
        ],
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final bool hasError;
  final String lang;

  const _StatusBanner({required this.hasError, required this.lang});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = hasError
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.primaryContainer;
    final textColor = hasError
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onPrimaryContainer;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              hasError ? Icons.error_outline : Icons.check_circle_outline,
              color: textColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasError
                    ? AppStrings.get('lab_present_has_error', lang)
                    : AppStrings.get('lab_present_no_error', lang),
                style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final int index;
  final PresentTenseDiagnosisError error;
  final String lang;

  const _ErrorBlock({
    required this.index,
    required this.error,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get(
                'lab_present_error_n',
                lang,
                params: {'index': index.toString()},
              ),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (error.span.isNotEmpty)
              _FeedbackLine(
                label: AppStrings.get('lab_present_error_span', lang),
                value: error.span,
              ),
            if (error.errorType.isNotEmpty)
              _FeedbackLine(
                label: AppStrings.get('lab_present_error_type', lang),
                value: error.errorType,
              ),
            if (error.grammarRule.isNotEmpty)
              _FeedbackLine(
                label: AppStrings.get('lab_present_grammar_rule', lang),
                value: error.grammarRule,
              ),
            if (error.reasoning.isNotEmpty)
              _FeedbackLine(
                label: AppStrings.get('lab_present_reasoning', lang),
                value: error.reasoning,
              ),
            if (error.correction.isNotEmpty)
              _FeedbackLine(
                label: AppStrings.get('lab_present_correction', lang),
                value: error.correction,
              ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackLine extends StatelessWidget {
  final String label;
  final String value;

  const _FeedbackLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  final DiagnosisLabRecord? record;
  final String lang;
  final bool isEnabled;
  final ValueChanged<DiagnosisLabRating> onRatingChanged;

  const _RatingSection({
    required this.record,
    required this.lang,
    required this.isEnabled,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('lab_present_manual_rating', lang),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final rating in DiagnosisLabRating.values)
              ChoiceChip(
                label: Text(_ratingLabel(rating, lang)),
                selected: record?.manualRating == rating,
                onSelected: isEnabled ? (_) => onRatingChanged(rating) : null,
              ),
          ],
        ),
      ],
    );
  }

  String _ratingLabel(DiagnosisLabRating rating, String lang) {
    return switch (rating) {
      DiagnosisLabRating.good => AppStrings.get(
        'lab_present_rating_good',
        lang,
      ),
      DiagnosisLabRating.acceptable => AppStrings.get(
        'lab_present_rating_acceptable',
        lang,
      ),
      DiagnosisLabRating.failed => AppStrings.get(
        'lab_present_rating_failed_label',
        lang,
      ),
    };
  }
}

class _DebugSection extends StatelessWidget {
  final PresentTenseDiagnosisResult? result;
  final DiagnosisLabRecord? currentRecord;
  final List<DiagnosisLabRecord> recentRecords;
  final String? recordsPath;
  final JsonEncoder jsonEncoder;
  final String lang;

  const _DebugSection({
    required this.result,
    required this.currentRecord,
    required this.recentRecords,
    required this.recordsPath,
    required this.jsonEncoder,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = this.result;
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: Text(
        AppStrings.get('lab_present_debug_section', lang),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DebugLine(
                label: AppStrings.get('lab_present_central_cards', lang),
                value: _ids(result?.retrieval.centralCards),
              ),
              _DebugLine(
                label: AppStrings.get('lab_present_supporting_cards', lang),
                value: _ids(result?.retrieval.supportingCards),
              ),
              _DebugLine(
                label: AppStrings.get('lab_present_fallback', lang),
                value: result == null
                    ? '-'
                    : result.retrieval.fallback.toString(),
              ),
              if (currentRecord != null)
                _DebugLine(
                  label: AppStrings.get('lab_present_record_id', lang),
                  value: currentRecord!.id,
                ),
              if (recordsPath != null)
                _DebugLine(
                  label: AppStrings.get('lab_present_records_path', lang),
                  value: recordsPath!,
                ),
              const SizedBox(height: 12),
              Text(
                AppStrings.get('lab_present_raw_json', lang),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.55,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    result == null
                        ? AppStrings.get('lab_present_raw_json_empty', lang)
                        : jsonEncoder.convert(result.raw),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              if (recentRecords.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  AppStrings.get('lab_present_recent_records', lang),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                for (final record in recentRecords.take(5))
                  _RecentRecordLine(record: record, lang: lang),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _ids(List<String>? ids) {
    if (ids == null || ids.isEmpty) return '-';
    return ids.join(', ');
  }
}

class _DebugLine extends StatelessWidget {
  final String label;
  final String value;

  const _DebugLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: SelectableText('$label: $value'),
    );
  }
}

class _RecentRecordLine extends StatelessWidget {
  final DiagnosisLabRecord record;
  final String lang;

  const _RecentRecordLine({required this.record, required this.lang});

  @override
  Widget build(BuildContext context) {
    final rating = record.manualRating == null
        ? AppStrings.get('lab_present_rating_unset', lang)
        : record.manualRating!.name;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        AppStrings.get(
          'lab_present_recent_record_line',
          lang,
          params: {
            'time': _formatTime(record.createdAt),
            'cards': record.centralCards.isEmpty
                ? '-'
                : record.centralCards.join(', '),
            'rating': rating,
          },
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}
