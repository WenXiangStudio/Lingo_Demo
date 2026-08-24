import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../data/database/app_database.dart';
import '../../../data/providers.dart';
import '../providers/review_center_provider.dart';

class ReviewCenterScreen extends ConsumerStatefulWidget {
  const ReviewCenterScreen({super.key});

  @override
  ConsumerState<ReviewCenterScreen> createState() => _ReviewCenterScreenState();
}

class _ReviewCenterScreenState extends ConsumerState<ReviewCenterScreen> {
  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final booksAsync = ref.watch(reviewBooksProvider);
    final dataAsync = ref.watch(reviewCenterDataProvider);
    final selectedBookId = ref.watch(reviewSelectedBookIdProvider);
    final selectedDate = ref.watch(reviewSelectedDateProvider);
    final sortMode = ref.watch(reviewSortModeProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: AppStrings.get('back_home', lang),
          onPressed: () => context.go('/'),
        ),
        title: Text(AppStrings.get('review_center', lang)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppStrings.get('refresh', lang),
            onPressed: () {
              ref.invalidate(reviewBooksProvider);
              ref.invalidate(reviewCenterDataProvider);
            },
          ),
        ],
      ),
      body: _buildBody(
        context,
        ref,
        booksAsync: booksAsync,
        dataAsync: dataAsync,
        selectedBookId: selectedBookId,
        selectedDate: selectedDate,
        sortMode: sortMode,
        lang: lang,
        theme: theme,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref, {
    required AsyncValue<List<WordBook>> booksAsync,
    required AsyncValue<ReviewCenterData> dataAsync,
    required int? selectedBookId,
    required DateTime selectedDate,
    required ReviewSortMode sortMode,
    required String lang,
    required ThemeData theme,
  }) {
    final data = dataAsync.valueOrNull;
    if (dataAsync.hasError && data == null && !dataAsync.isLoading) {
      final error = dataAsync.error?.toString() ?? '';
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                AppStrings.get('failed_lists', lang),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(reviewCenterDataProvider),
                child: Text(AppStrings.get('retry', lang)),
              ),
            ],
          ),
        ),
      );
    }

    final isLoading = data == null;
    final activeErrorWordCount = isLoading
        ? AppStrings.get('loading', lang)
        : data.activeErrorWordCount.toString();
    final activeForgottenWordCount = isLoading
        ? AppStrings.get('loading', lang)
        : data.activeForgottenWordCount.toString();
    final activeCueMemoryWordCount = isLoading
        ? AppStrings.get('loading', lang)
        : data.activeCueMemoryWordCount.toString();

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: _buildTopControls(
              context,
              ref,
              booksAsync,
              selectedBookId,
              selectedDate,
              lang,
            ),
          ),
          if (data != null) ...[
            _buildDashboardOverview(context, data, lang, theme),
            if (data.migrationNotice)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _MigrationNotice(
                  lang: lang,
                  onDismiss: () async {
                    await ref
                        .read(settingsRepositoryProvider)
                        .setString('review_data_reset_notice', 'false');
                    ref.invalidate(reviewMigrationNoticeProvider);
                    ref.invalidate(reviewCenterDataProvider);
                  },
                ),
              ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryTile(
                    label: AppStrings.get('active_error_words', lang),
                    value: activeErrorWordCount,
                    icon: Icons.bookmark_outline,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryTile(
                    label: AppStrings.get('active_forgotten_words', lang),
                    value: activeForgottenWordCount,
                    icon: Icons.flag,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryTile(
                    label: AppStrings.get('active_cue_memory_words', lang),
                    value: activeCueMemoryWordCount,
                    icon: Icons.bookmark_added_outlined,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: AppStrings.get('error_collection', lang)),
              Tab(text: AppStrings.get('forgotten_collection', lang)),
              Tab(text: AppStrings.get('cue_memory_collection', lang)),
              Tab(text: AppStrings.get('learning_stats', lang)),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                isLoading
                    ? _LoadingReviewTab(label: AppStrings.get('loading', lang))
                    : _ReviewWordListSection(
                        emptyLabel: AppStrings.get('no_review_data', lang),
                        words: data.activeErrorWords,
                        collectionType: ReviewCollectionType.errors,
                        lang: lang,
                        onPractice: (mode) => _startReview(
                          context,
                          ref,
                          collectionType: ReviewCollectionType.errors,
                          mode: mode,
                          words: data.activeErrorWords,
                          bookId: selectedBookId,
                        ),
                      ),
                isLoading
                    ? _LoadingReviewTab(label: AppStrings.get('loading', lang))
                    : _ReviewWordListSection(
                        emptyLabel: AppStrings.get('no_review_data', lang),
                        words: data.activeForgottenWords,
                        collectionType: ReviewCollectionType.forgotten,
                        lang: lang,
                        onPractice: (mode) => _startReview(
                          context,
                          ref,
                          collectionType: ReviewCollectionType.forgotten,
                          mode: mode,
                          words: data.activeForgottenWords,
                          bookId: selectedBookId,
                        ),
                      ),
                isLoading
                    ? _LoadingReviewTab(label: AppStrings.get('loading', lang))
                    : _ReviewWordListSection(
                        emptyLabel: AppStrings.get('no_review_data', lang),
                        words: data.activeCueMemoryWords,
                        collectionType: ReviewCollectionType.cueMemory,
                        lang: lang,
                      ),
                isLoading
                    ? _LoadingReviewTab(label: AppStrings.get('loading', lang))
                    : _ReviewStatsSection(
                        words: data.allWords,
                        sortMode: sortMode,
                        lang: lang,
                        onSortModeChanged: (mode) =>
                            ref.read(reviewSortModeProvider.notifier).state =
                                mode,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopControls(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<WordBook>> booksAsync,
    int? selectedBookId,
    DateTime selectedDate,
    String lang,
  ) {
    final books = booksAsync.valueOrNull ?? const <WordBook>[];
    final options = [
      DropdownMenuItem<int?>(
        value: null,
        child: Text(AppStrings.get('all_books', lang)),
      ),
      ...books.map(
        (book) =>
            DropdownMenuItem<int?>(value: book.id, child: Text(book.name)),
      ),
    ];
    if (selectedBookId != null &&
        books.every((book) => book.id != selectedBookId)) {
      options.add(
        DropdownMenuItem<int?>(
          value: selectedBookId,
          child: Text(AppStrings.get('loading', lang)),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int?>(
            initialValue: selectedBookId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: AppStrings.get('selected_book', lang),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            items: options,
            onChanged: (value) {
              ref.read(reviewSelectedBookIdProvider.notifier).state = value;
              ref.invalidate(reviewCenterDataProvider);
            },
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked == null) return;
            ref.read(reviewSelectedDateProvider.notifier).state = DateTime(
              picked.year,
              picked.month,
              picked.day,
            );
          },
          icon: const Icon(Icons.calendar_today_outlined),
          label: Text(
            '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () {
            ref.invalidate(reviewBooksProvider);
            ref.invalidate(reviewCenterDataProvider);
          },
          icon: const Icon(Icons.refresh),
          label: Text(AppStrings.get('refresh', lang)),
        ),
      ],
    );
  }

  void _startReview(
    BuildContext context,
    WidgetRef ref, {
    required ReviewCollectionType collectionType,
    required ReviewQuizMode mode,
    required List<ReviewWordStat> words,
    required int? bookId,
  }) {
    if (words.isEmpty) return;
    ref
        .read(reviewPracticeSessionProvider.notifier)
        .state = ReviewPracticeSession(
      collectionType: collectionType,
      bookId: bookId,
      mode: mode,
      words: words,
    );
    context.push('/review-center/quiz');
  }

  Widget _buildDashboardOverview(
    BuildContext context,
    ReviewDashboardData data,
    String lang,
    ThemeData theme,
  ) {
    final recordedListReviews = data.listReviews
        .where((item) => item.practiceCount > 0)
        .toList();
    return SizedBox(
      height: 218,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        children: [
          SizedBox(
            width: 360,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('review_list_progress', lang),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: recordedListReviews.isEmpty
                          ? Center(
                              child: Text(
                                AppStrings.get('no_lists_yet', lang),
                                style: theme.textTheme.bodySmall,
                              ),
                            )
                          : ListView.builder(
                              itemCount: recordedListReviews.length,
                              itemBuilder: (context, index) {
                                final item = recordedListReviews[index];
                                final accuracy = item.totalAnswerCount == 0
                                    ? AppStrings.get('not_available', lang)
                                    : '${(item.accuracy * 100).round()}%';
                                return ExpansionTile(
                                  dense: true,
                                  tilePadding: EdgeInsets.zero,
                                  leading: Icon(
                                    item.metPassThreshold
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: item.metPassThreshold
                                        ? Colors.green
                                        : theme.colorScheme.outline,
                                    size: 20,
                                  ),
                                  title: Text(
                                    item.list.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    AppStrings.get(
                                      'review_list_stats',
                                      lang,
                                      params: {
                                        'sessions': item.practiceCount
                                            .toString(),
                                        'covered': item.coveredWordCount
                                            .toString(),
                                        'total': item.totalWordCount.toString(),
                                      },
                                    ),
                                  ),
                                  trailing: Text(accuracy),
                                  children: [
                                    if (item.words.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          0,
                                          16,
                                          8,
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            AppStrings.get(
                                              'review_no_word_details',
                                              lang,
                                            ),
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ),
                                      )
                                    else
                                      for (final word in item.words)
                                        ListTile(
                                          dense: true,
                                          contentPadding: const EdgeInsets.only(
                                            left: 32,
                                          ),
                                          title: Text(word.word.english),
                                          subtitle: Text(
                                            AppStrings.get(
                                              'review_word_detail',
                                              lang,
                                              params: {
                                                'answers': word.answerCount
                                                    .toString(),
                                                'correct': word.correctCount
                                                    .toString(),
                                                'incorrect': word.incorrectCount
                                                    .toString(),
                                              },
                                            ),
                                          ),
                                          trailing: Icon(
                                            word.latestCorrect == true
                                                ? Icons.check_circle_outline
                                                : Icons.cancel_outlined,
                                            color: word.latestCorrect == true
                                                ? Colors.green
                                                : Colors.red,
                                            size: 18,
                                          ),
                                        ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 330,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('review_ai_analysis', lang),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final type in const [
                      LearningActivityType.aiLearning,
                      LearningActivityType.dialogue,
                      LearningActivityType.skill,
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                AppStrings.get('review_ai_type_$type', lang),
                              ),
                            ),
                            Text(
                              '${data.aiSummary.completedCount(type)} · ${data.aiSummary.involvedWordCount(type)}',
                              style: theme.textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),
                    if (data.aiSummary.aiLearningQuestionCount > 0)
                      Text(
                        AppStrings.get(
                          'review_ai_questions',
                          lang,
                          params: {
                            'questions': data.aiSummary.aiLearningQuestionCount
                                .toString(),
                            'accuracy':
                                '${(data.aiSummary.aiLearningAccuracy * 100).round()}%',
                          },
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    if (data.aiSummary.dialogueTurnCount > 0)
                      Text(
                        AppStrings.get(
                          'review_dialogue_metrics',
                          lang,
                          params: {
                            'turns': data.aiSummary.dialogueTurnCount
                                .toString(),
                            'used': data.aiSummary.dialogueTargetWordUseCount
                                .toString(),
                          },
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    if (data.aiSummary.skillRunCount > 0)
                      Text(
                        AppStrings.get(
                          'review_skill_metrics',
                          lang,
                          params: {
                            'runs': data.aiSummary.skillRunCount.toString(),
                          },
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    const Spacer(),
                    Text(
                      data.aiSummary.focusWords.isEmpty
                          ? AppStrings.get('review_focus_words_empty', lang)
                          : AppStrings.get(
                              'review_focus_words',
                              lang,
                              params: {
                                'words': data.aiSummary.focusWords
                                    .take(4)
                                    .map((item) => item.word.english)
                                    .join(', '),
                              },
                            ),
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 260,
            child: Card(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.45,
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.record_voice_over_outlined, size: 26),
                    const SizedBox(height: 10),
                    Text(
                      AppStrings.get('speaking_check', lang),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(AppStrings.get('coming_soon', lang)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MigrationNotice extends StatelessWidget {
  final String lang;
  final VoidCallback onDismiss;

  const _MigrationNotice({required this.lang, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text(AppStrings.get('review_data_reset_notice', lang)),
      leading: const Icon(Icons.info_outline),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: Text(AppStrings.get('dismiss', lang)),
        ),
      ],
    );
  }
}

class _LoadingReviewTab extends StatelessWidget {
  final String label;

  const _LoadingReviewTab({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 72),
        const Center(child: CircularProgressIndicator()),
        const SizedBox(height: 12),
        Center(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.55,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewWordListSection extends StatelessWidget {
  final List<ReviewWordStat> words;
  final ReviewCollectionType collectionType;
  final String emptyLabel;
  final String lang;
  final ValueChanged<ReviewQuizMode>? onPractice;

  const _ReviewWordListSection({
    required this.words,
    required this.collectionType,
    required this.emptyLabel,
    required this.lang,
    this.onPractice,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (onPractice != null) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: words.isEmpty
                    ? null
                    : () => onPractice!(ReviewQuizMode.choice),
                icon: const Icon(Icons.touch_app_outlined),
                label: Text(AppStrings.get('review_choice', lang)),
              ),
              OutlinedButton.icon(
                onPressed: words.isEmpty
                    ? null
                    : () => onPractice!(ReviewQuizMode.fill),
                icon: const Icon(Icons.edit_outlined),
                label: Text(AppStrings.get('review_fill', lang)),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (words.isEmpty)
          _EmptyReviewState(label: emptyLabel)
        else
          ...words.map(
            (word) => _ReviewWordCard(
              stat: word,
              collectionType: collectionType,
              lang: lang,
            ),
          ),
      ],
    );
  }
}

class _ReviewStatsSection extends StatelessWidget {
  final List<ReviewWordStat> words;
  final ReviewSortMode sortMode;
  final String lang;
  final ValueChanged<ReviewSortMode> onSortModeChanged;

  const _ReviewStatsSection({
    required this.words,
    required this.sortMode,
    required this.lang,
    required this.onSortModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sortedWords = List<ReviewWordStat>.of(words)
      ..sort((a, b) {
        final cmp = switch (sortMode) {
          ReviewSortMode.errorCount => b.errorCount.compareTo(a.errorCount),
          ReviewSortMode.forgottenCount => b.forgottenCount.compareTo(
            a.forgottenCount,
          ),
        };
        if (cmp != 0) return cmp;
        return a.word.english.toLowerCase().compareTo(
          b.word.english.toLowerCase(),
        );
      });
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        SegmentedButton<ReviewSortMode>(
          segments: [
            ButtonSegment(
              value: ReviewSortMode.errorCount,
              label: Text(AppStrings.get('sort_by_error_count', lang)),
            ),
            ButtonSegment(
              value: ReviewSortMode.forgottenCount,
              label: Text(AppStrings.get('sort_by_forgotten_count', lang)),
            ),
          ],
          selected: {sortMode},
          onSelectionChanged: (selection) {
            if (selection.isEmpty) return;
            onSortModeChanged(selection.first);
          },
        ),
        const SizedBox(height: 12),
        if (sortedWords.isEmpty)
          _EmptyReviewState(label: AppStrings.get('no_review_data', lang))
        else
          ...sortedWords.map(
            (word) => _ReviewWordCard(
              stat: word,
              collectionType: ReviewCollectionType.errors,
              lang: lang,
            ),
          ),
      ],
    );
  }
}

class _ReviewWordCard extends StatelessWidget {
  final ReviewWordStat stat;
  final ReviewCollectionType collectionType;
  final String lang;

  const _ReviewWordCard({
    required this.stat,
    required this.collectionType,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final word = stat.word;
    final subtitle = word.chineseMeanings;
    final primaryCount = switch (collectionType) {
      ReviewCollectionType.errors => stat.errorCount,
      ReviewCollectionType.forgotten => stat.forgottenCount,
      ReviewCollectionType.cueMemory => stat.cueMemoryCount,
    };
    final collectionColor = switch (collectionType) {
      ReviewCollectionType.errors => Colors.red,
      ReviewCollectionType.forgotten => Colors.deepOrange,
      ReviewCollectionType.cueMemory => theme.colorScheme.tertiary,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: collectionColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$primaryCount',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: collectionColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.english,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _CountChip(
                        label: AppStrings.get('error_count_label', lang),
                        value: stat.errorCount,
                      ),
                      _CountChip(
                        label: AppStrings.get('forgotten_count_label', lang),
                        value: stat.forgottenCount,
                      ),
                      _CountChip(
                        label: AppStrings.get('cue_memory_count_label', lang),
                        value: stat.cueMemoryCount,
                      ),
                    ],
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

class _CountChip extends StatelessWidget {
  final String label;
  final int value;

  const _CountChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$label $value', style: theme.textTheme.labelSmall),
    );
  }
}

class _EmptyReviewState extends StatelessWidget {
  final String label;

  const _EmptyReviewState({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 56,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
