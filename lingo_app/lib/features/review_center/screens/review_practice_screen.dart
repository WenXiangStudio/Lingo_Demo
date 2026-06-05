import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/utils/answer_checker.dart';
import '../../../data/database/app_database.dart';
import '../../../data/providers.dart';
import '../../lists/providers/list_provider.dart';
import '../providers/review_center_provider.dart';

class ReviewPracticeScreen extends ConsumerStatefulWidget {
  const ReviewPracticeScreen({super.key});

  @override
  ConsumerState<ReviewPracticeScreen> createState() =>
      _ReviewPracticeScreenState();
}

class _ReviewPracticeScreenState extends ConsumerState<ReviewPracticeScreen> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final _rng = Random();
  final Map<int, List<String>> _choiceOptionsCache = {};
  final List<_ReviewAnswerRecord> _answers = [];

  int _currentIndex = 0;
  bool _showFeedback = false;
  bool? _lastAnswerCorrect;
  bool _isSaving = false;
  bool _finished = false;
  int _clearedCount = 0;
  double _accuracy = 0;
  bool _passed = false;
  bool _savedOnce = false;

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    ref.read(reviewPracticeSessionProvider.notifier).state = null;
    super.dispose();
  }

  ReviewPracticeSession? get _session =>
      ref.read(reviewPracticeSessionProvider);

  List<ReviewWordStat> get _words => _session?.words ?? const [];

  ReviewWordStat? get _currentWord =>
      _currentIndex < _words.length ? _words[_currentIndex] : null;

  Future<double> _passThreshold() async {
    return ref.read(settingsRepositoryProvider).getPassThreshold();
  }

  List<String> _choiceOptionsFor(int index) {
    final cached = _choiceOptionsCache[index];
    if (cached != null) return cached;
    final correct = _words[index].word.chineseMeanings;
    final correctKey = AnswerChecker.normalizeMeaningKey(correct);
    final distractors = <String>[];
    final used = <String>{correctKey};
    final candidates = _words.map((w) => w.word.chineseMeanings).toList()
      ..shuffle(_rng);

    for (final meaning in candidates) {
      final key = AnswerChecker.normalizeMeaningKey(meaning);
      if (key.isEmpty || used.contains(key)) continue;
      used.add(key);
      distractors.add(meaning);
      if (distractors.length >= 4) break;
    }

    while (distractors.length < 4) {
      distractors.add('___${distractors.length + 1}___');
    }

    final options = [correct, ...distractors]..shuffle(_rng);
    _choiceOptionsCache[index] = options;
    return options;
  }

  void _submitChoice(String selected) {
    if (_showFeedback || _currentWord == null) return;
    final isCorrect = AnswerChecker.isChoiceAnswerCorrect(
      selected,
      _currentWord!.word.chineseMeanings,
    );
    setState(() {
      _lastAnswerCorrect = isCorrect;
      _showFeedback = true;
      _answers.add(
        _ReviewAnswerRecord(
          wordId: _currentWord!.word.id,
          isCorrect: isCorrect,
        ),
      );
    });
  }

  void _submitFill() {
    if (_showFeedback || _currentWord == null) return;
    final input = _textController.text.trim();
    final isCorrect = AnswerChecker.isFillAnswerCorrect(
      input,
      _currentWord!.word.chineseMeanings,
    );
    setState(() {
      _lastAnswerCorrect = isCorrect;
      _showFeedback = true;
      _answers.add(
        _ReviewAnswerRecord(
          wordId: _currentWord!.word.id,
          isCorrect: isCorrect,
        ),
      );
    });
    _focusNode.unfocus();
  }

  Future<void> _next() async {
    if (!_showFeedback) return;
    final nextIndex = _currentIndex + 1;
    if (nextIndex >= _words.length) {
      await _finishReview();
      return;
    }
    setState(() {
      _currentIndex = nextIndex;
      _showFeedback = false;
      _lastAnswerCorrect = null;
      _textController.clear();
    });
  }

  Future<void> _finishReview() async {
    if (_savedOnce) return;
    _savedOnce = true;
    final session = _session;
    if (session == null) return;

    final threshold = await _passThreshold();
    final correctIds = _answers
        .where((a) => a.isCorrect)
        .map((a) => a.wordId)
        .toList();
    _accuracy = _answers.isEmpty
        ? 0
        : _answers.where((a) => a.isCorrect).length / _answers.length;
    _passed = _accuracy >= threshold;

    setState(() => _isSaving = true);

    if (_passed && correctIds.isNotEmpty) {
      final db = ref.read(appDatabaseProvider);
      if (session.collectionType == ReviewCollectionType.errors) {
        await db.resolveErrorWords(correctIds, bookId: session.bookId);
      } else {
        await db.clearForgottenStatusForWordsInScope(
          correctIds,
          bookId: session.bookId,
        );
        final affectedListIds = await db.getListIdsContainingWordsInScope(
          correctIds,
          bookId: session.bookId,
        );
        for (final listId in affectedListIds) {
          ref.invalidate(listWordsProvider(listId));
          ref.invalidate(forgottenWordIdsProvider(listId));
          ref.invalidate(forgottenWordsProvider(listId));
          ref.invalidate(listDetailProvider(listId));
        }
      }
      _clearedCount = correctIds.length;
    }

    ref.invalidate(reviewCenterDataProvider);
    if (mounted) {
      setState(() {
        _isSaving = false;
        _finished = true;
      });
    }
  }

  void _leave() {
    ref.read(reviewPracticeSessionProvider.notifier).state = null;
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go('/review-center');
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final lang = ref.watch(languageProvider);
    final theme = Theme.of(context);

    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/review-center');
      });
      return const SizedBox.shrink();
    }

    if (_finished) {
      final passed = _passed;
      final title = session.collectionType == ReviewCollectionType.errors
          ? AppStrings.get('error_collection', lang)
          : AppStrings.get('forgotten_collection', lang);
      final clearedText = session.collectionType == ReviewCollectionType.errors
          ? AppStrings.get(
              'review_error_cleared_n',
              lang,
              params: {'count': _clearedCount.toString()},
            )
          : (_clearedCount > 0
              ? AppStrings.get(
                  'forgotten_cleared_n',
                  lang,
                  params: {'count': _clearedCount.toString()},
                )
              : AppStrings.get('forgotten_not_cleared', lang));

      return Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.get('review_practice_result', lang)),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _leave,
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: _accuracy,
                        strokeWidth: 12,
                        strokeCap: StrokeCap.round,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        color: passed ? Colors.green : Colors.orange,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(_accuracy * 100).round()}%',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: passed ? Colors.green : Colors.orange,
                          ),
                        ),
                        Text(
                          '${_answers.where((a) => a.isCorrect).length} / ${_answers.length}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Chip(
                label: Text(title),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passed
                          ? AppStrings.get('review_practice_passed', lang)
                          : AppStrings.get('review_practice_not_passed', lang),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(clearedText),
                    if (_isSaving) ...[
                      const SizedBox(height: 12),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _leave,
              icon: const Icon(Icons.arrow_back),
              label: Text(AppStrings.get('back_to_review', lang)),
            ),
          ],
        ),
      );
    }

    final word = _currentWord;
    if (word == null) {
      return Scaffold(
        body: Center(child: Text(AppStrings.get('no_words_practice', lang))),
      );
    }

    final isChoice = session.mode == ReviewQuizMode.choice;
    final progress = _words.isEmpty ? 0.0 : _currentIndex / _words.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentIndex + 1} / ${_words.length}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _leave,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
            child: LinearProgressIndicator(value: progress),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                      child: Column(
                        children: [
                          Text(
                            word.word.english,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (word.word.pronunciation != null &&
                              word.word.pronunciation!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text('/${word.word.pronunciation}/'),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isChoice)
                    ..._choiceOptionsFor(_currentIndex).map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _showFeedback
                                ? null
                                : () => _submitChoice(option),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(option),
                            ),
                          ),
                        ),
                      ),
                    )
                  else ...[
                    TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      enabled: !_showFeedback,
                      decoration: InputDecoration(
                        labelText: AppStrings.get('answer', lang),
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _submitFill(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _showFeedback ? null : _submitFill,
                        child: Text(AppStrings.get('submit', lang)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_showFeedback)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _lastAnswerCorrect == true
                    ? Colors.green.withValues(alpha: 0.08)
                    : Colors.orange.withValues(alpha: 0.08),
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _lastAnswerCorrect == true
                        ? Icons.check_circle
                        : Icons.info_outline,
                    color: _lastAnswerCorrect == true
                        ? Colors.green
                        : Colors.orange,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _lastAnswerCorrect == true
                          ? AppStrings.get('correct', lang)
                          : AppStrings.get('incorrect', lang),
                    ),
                  ),
                  FilledButton(
                    onPressed: _isSaving ? null : _next,
                    child: Text(AppStrings.get('next', lang)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ReviewAnswerRecord {
  final int wordId;
  final bool isCorrect;

  const _ReviewAnswerRecord({
    required this.wordId,
    required this.isCorrect,
  });
}
