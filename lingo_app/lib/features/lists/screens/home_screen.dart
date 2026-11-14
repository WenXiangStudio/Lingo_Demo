import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../data/database/app_database.dart';
import '../../../data/providers.dart';
import '../../review_center/providers/review_center_provider.dart';
import '../providers/list_provider.dart';
import '../widgets/book_reset_dialog.dart';

final workflowSelectedListProvider = StateProvider<Set<int>>((ref) => <int>{});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final lang = ref.watch(languageProvider);
    final listsAsync = ref.watch(listOverviewProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('app_title', lang)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: AppStrings.get('settings', lang),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: listsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
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
                  error.toString(),
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(listOverviewProvider),
                  child: Text(AppStrings.get('retry', lang)),
                ),
              ],
            ),
          ),
        ),
        data: (lists) {
          return _HomeContent(lists: lists);
        },
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  final List<WordList> lists;

  const _HomeContent({required this.lists});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final theme = Theme.of(context);
    final booksAsync = ref.watch(bookOverviewProvider);
    final selectedListIds = ref.watch(workflowSelectedListProvider);
    final selectedLists = lists
        .where((list) => selectedListIds.contains(list.id))
        .toList();
    final hasSelectedLists = selectedLists.isNotEmpty;
    final allSelectedListsPassed =
        hasSelectedLists && selectedLists.every((list) => list.isPassed);
    final selectedListsShareBook =
        selectedLists.map((list) => list.bookId).toSet().length == 1;
    final books = booksAsync.valueOrNull ?? const <WordBook>[];
    final listsByBook = <int?, List<WordList>>{};
    for (final list in lists) {
      listsByBook.putIfAbsent(list.bookId, () => []).add(list);
    }
    final totalLists = lists.length;
    final passedLists = lists.where((list) => list.isPassed == true).length;
    final totalWords = lists.fold<int>(0, (sum, list) => sum + list.wordCount);
    WordList? nextList;
    for (final list in lists) {
      if (!list.isPassed) {
        nextList = list;
        break;
      }
    }
    if (nextList == null && lists.isNotEmpty) {
      nextList = lists.first;
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.get('workflow_title', lang),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.get('workflow_subtitle', lang),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _HomeStat(
                      label: AppStrings.get('home_lists_stat', lang),
                      value: '$passedLists/$totalLists',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HomeStat(
                      label: AppStrings.get('home_words_stat', lang),
                      value: totalWords.toString(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (nextList case final activeList?)
          FilledButton.icon(
            onPressed: () => context.push('/list/${activeList.id}?from=home'),
            icon: const Icon(Icons.play_arrow),
            label: Text(
              AppStrings.get(
                'home_continue_list',
                lang,
                params: {'name': activeList.name},
              ),
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          FilledButton.icon(
            onPressed: () => context.push('/import'),
            icon: const Icon(Icons.add),
            label: Text(AppStrings.get('import_words', lang)),
          ),
        const SizedBox(height: 18),
        Text(
          AppStrings.get('workflow_select_list', lang),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () =>
                _chooseWorkflowLists(context, ref, listsByBook, books, lang),
            icon: const Icon(Icons.checklist_outlined),
            label: Text(
              hasSelectedLists
                  ? AppStrings.get(
                      'workflow_selected_lists',
                      lang,
                      params: {'count': selectedLists.length.toString()},
                    )
                  : AppStrings.get('workflow_select_list', lang),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (!hasSelectedLists && nextList != null)
          Text(
            '${AppStrings.get('workflow_next_unpassed', lang)}: ${nextList.name}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        const SizedBox(height: 12),
        _WorkflowCard(
          icon: Icons.menu_book_outlined,
          title: AppStrings.get('workflow_memorization', lang),
          detail: AppStrings.get('workflow_memorization_desc', lang),
          locked: !hasSelectedLists,
          lockLabel: !hasSelectedLists
              ? AppStrings.get('workflow_select_list_required', lang)
              : null,
          onTap: !hasSelectedLists
              ? () => _showWorkflowSelectHint(context, lang)
              : () async {
                  final list = await _chooseSelectedWorkflowList(
                    context,
                    lang,
                    selectedLists,
                  );
                  if (list != null && context.mounted) {
                    context.push('/list/${list.id}?from=home');
                  }
                },
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _WorkflowCard(
                icon: Icons.auto_awesome,
                title: AppStrings.get('workflow_ai_learning', lang),
                detail: AppStrings.get('workflow_ai_learning_desc', lang),
                locked: !allSelectedListsPassed || !selectedListsShareBook,
                lockLabel: !hasSelectedLists
                    ? AppStrings.get('workflow_select_list_required', lang)
                    : !allSelectedListsPassed
                    ? AppStrings.get('workflow_lock_hint', lang)
                    : !selectedListsShareBook
                    ? AppStrings.get('workflow_same_book_required', lang)
                    : null,
                onTap: !allSelectedListsPassed || !selectedListsShareBook
                    ? () => _showWorkflowSelectHint(
                        context,
                        lang,
                        key: !hasSelectedLists
                            ? 'workflow_select_list_required'
                            : !allSelectedListsPassed
                            ? 'workflow_lock_hint'
                            : 'workflow_same_book_required',
                      )
                    : () => context.push(
                        '/deep-practice/${selectedLists.first.id}/setup?listIds=${selectedLists.map((list) => list.id).join(',')}&returnPath=${Uri.encodeComponent('/')}',
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _WorkflowCard(
                icon: Icons.chat_bubble_outline,
                title: AppStrings.get('workflow_ai_dialogue', lang),
                detail: AppStrings.get('workflow_ai_dialogue_desc', lang),
                locked: !allSelectedListsPassed,
                lockLabel: !hasSelectedLists
                    ? AppStrings.get('workflow_select_list_required', lang)
                    : !allSelectedListsPassed
                    ? AppStrings.get('workflow_lock_hint', lang)
                    : null,
                onTap: !allSelectedListsPassed
                    ? () => _showWorkflowSelectHint(
                        context,
                        lang,
                        key: !hasSelectedLists
                            ? 'workflow_select_list_required'
                            : 'workflow_lock_hint',
                      )
                    : () async {
                        final list = await _chooseSelectedWorkflowList(
                          context,
                          lang,
                          selectedLists,
                        );
                        if (list != null && context.mounted) {
                          context.push(
                            '/dialogue/${list.id}?listId=${list.id}',
                          );
                        }
                      },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _WorkflowCard(
                icon: Icons.auto_fix_high,
                title: AppStrings.get('workflow_skills', lang),
                detail: AppStrings.get('workflow_skills_desc', lang),
                locked: !allSelectedListsPassed,
                lockLabel: !hasSelectedLists
                    ? AppStrings.get('workflow_select_list_required', lang)
                    : !allSelectedListsPassed
                    ? AppStrings.get('workflow_lock_hint', lang)
                    : null,
                onTap: !allSelectedListsPassed
                    ? () => _showWorkflowSelectHint(
                        context,
                        lang,
                        key: !hasSelectedLists
                            ? 'workflow_select_list_required'
                            : 'workflow_lock_hint',
                      )
                    : () async {
                        final list = await _chooseSelectedWorkflowList(
                          context,
                          lang,
                          selectedLists,
                        );
                        if (list != null && context.mounted) {
                          context.push('/skills?listId=${list.id}');
                        }
                      },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _HomeSectionTitle(label: AppStrings.get('home_section_learning', lang)),
        const SizedBox(height: 8),
        _HomeFeatureGrid(
          children: [
            _HomeFeatureCard(
              icon: Icons.list_alt,
              label: AppStrings.get('home_word_lists', lang),
              detail: AppStrings.get('home_word_lists_desc', lang),
              onTap: () => context.push('/lists'),
            ),
            _HomeFeatureCard(
              icon: Icons.fact_check_outlined,
              label: AppStrings.get('review_center', lang),
              detail: AppStrings.get('review_center_desc', lang),
              onTap: () => context.push('/review-center'),
            ),
            _HomeFeatureCard(
              icon: Icons.graphic_eq,
              label: AppStrings.get('phonetics_menu', lang),
              detail: AppStrings.get('phonetics_menu_desc', lang),
              onTap: () => context.push('/phonetics'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _HomeSectionTitle(label: AppStrings.get('home_section_tools', lang)),
        const SizedBox(height: 8),
        _HomeFeatureGrid(
          children: [
            _HomeFeatureCard(
              icon: Icons.add_circle_outline,
              label: AppStrings.get('import_words', lang),
              detail: AppStrings.get('home_import_desc', lang),
              onTap: () => context.push('/import'),
            ),
            _HomeFeatureCard(
              icon: Icons.record_voice_over_outlined,
              label: AppStrings.get('custom_tts_menu', lang),
              detail: AppStrings.get('home_tts_desc', lang),
              onTap: () => context.push('/custom-tts'),
            ),
            _HomeFeatureCard(
              icon: Icons.mic_none_outlined,
              label: AppStrings.get('speaking_practice', lang),
              detail: AppStrings.get('home_speaking_desc', lang),
              onTap: () => _openSpeakingTool(context, lang, lists),
            ),
            _HomeFeatureCard(
              icon: Icons.record_voice_over_outlined,
              label: AppStrings.get('narration_title', lang),
              detail: AppStrings.get('narration_home_desc', lang),
              onTap: () => context.push('/narration'),
            ),
            booksAsync.maybeWhen(
              data: (books) => books.isEmpty
                  ? const SizedBox.shrink()
                  : _HomeFeatureCard(
                      icon: Icons.restart_alt,
                      label: AppStrings.get('reset_book_order_menu', lang),
                      detail: AppStrings.get('reset_book_order_desc', lang),
                      iconColor: theme.colorScheme.error,
                      labelColor: theme.colorScheme.error,
                      onTap: () =>
                          _resetBookOrder(context, ref, books, lists, lang),
                    ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _HomeSectionTitle(label: AppStrings.get('home_section_labs', lang)),
        const SizedBox(height: 8),
        _HomeFeatureGrid(
          children: [
            _HomeFeatureCard(
              icon: Icons.science_outlined,
              label: AppStrings.get('lab_present_menu', lang),
              detail: AppStrings.get('lab_present_menu_desc', lang),
              onTap: () => context.push('/labs/present-tense-diagnosis'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _chooseWorkflowLists(
    BuildContext context,
    WidgetRef ref,
    Map<int?, List<WordList>> listsByBook,
    List<WordBook> books,
    String lang,
  ) async {
    final initialIds = ref.read(workflowSelectedListProvider);
    final selected = await showDialog<Set<int>>(
      context: context,
      builder: (dialogContext) {
        final draftIds = Set<int>.from(initialIds);
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: Text(AppStrings.get('workflow_select_list', lang)),
            content: SizedBox(
              width: 420,
              height: 360,
              child: ListView(
                children: [
                  for (final entry in listsByBook.entries) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        entry.key == null
                            ? AppStrings.get('word_list', lang)
                            : books
                                      .where((book) => book.id == entry.key)
                                      .firstOrNull
                                      ?.name ??
                                  AppStrings.get('word_list', lang),
                        style: Theme.of(dialogContext).textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    for (final list in entry.value)
                      CheckboxListTile(
                        value: draftIds.contains(list.id),
                        onChanged: (checked) => setDialogState(() {
                          if (checked ?? false) {
                            draftIds.add(list.id);
                          } else {
                            draftIds.remove(list.id);
                          }
                        }),
                        secondary: Icon(
                          list.isPassed
                              ? Icons.check_circle_outline
                              : Icons.radio_button_unchecked,
                        ),
                        title: Text(list.name),
                        subtitle: Text(
                          AppStrings.get(
                            'n_words',
                            lang,
                            params: {'count': list.wordCount.toString()},
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => setDialogState(() {
                  draftIds
                    ..clear()
                    ..addAll(
                      listsByBook.values.expand(
                        (lists) => lists.map((list) => list.id),
                      ),
                    );
                }),
                child: Text(AppStrings.get('select_all', lang)),
              ),
              TextButton(
                onPressed: () => setDialogState(draftIds.clear),
                child: Text(AppStrings.get('deselect_all', lang)),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(AppStrings.get('cancel', lang)),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(Set<int>.from(draftIds)),
                child: Text(AppStrings.get('done', lang)),
              ),
            ],
          ),
        );
      },
    );
    if (selected == null) return;
    ref.read(workflowSelectedListProvider.notifier).state = selected;
  }

  Future<WordList?> _chooseSelectedWorkflowList(
    BuildContext context,
    String lang,
    List<WordList> selectedLists,
  ) {
    if (selectedLists.length == 1) return Future.value(selectedLists.single);
    return showDialog<WordList>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(AppStrings.get('workflow_choose_selected_list', lang)),
        children: [
          for (final list in selectedLists)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(list),
              child: Text(list.name),
            ),
        ],
      ),
    );
  }

  void _showWorkflowSelectHint(
    BuildContext context,
    String lang, {
    String key = 'workflow_select_list_required',
  }) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppStrings.get(key, lang))));
  }

  Future<void> _openSpeakingTool(
    BuildContext context,
    String lang,
    List<WordList> lists,
  ) async {
    final passed = lists.where((list) => list.isPassed).toList();
    if (passed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('home_no_unlocked_lists', lang))),
      );
      return;
    }
    final list = passed.length == 1
        ? passed.first
        : await showDialog<WordList>(
            context: context,
            builder: (dialogContext) => SimpleDialog(
              title: Text(AppStrings.get('home_choose_passed_list', lang)),
              children: [
                for (final item in passed)
                  SimpleDialogOption(
                    onPressed: () => Navigator.of(dialogContext).pop(item),
                    child: Text(item.name),
                  ),
              ],
            ),
          );
    if (list == null || !context.mounted) return;
    context.push('/speaking/${list.id}?returnPath=${Uri.encodeComponent('/')}');
  }

  Future<void> _resetBookOrder(
    BuildContext context,
    WidgetRef ref,
    List<WordBook> books,
    List<WordList> lists,
    String lang,
  ) async {
    if (books.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('reset_book_order_no_books', lang)),
        ),
      );
      return;
    }

    final selectedBook = books.length == 1
        ? books.first
        : await showDialog<WordBook>(
            context: context,
            builder: (ctx) => SimpleDialog(
              title: Text(
                AppStrings.get('reset_book_order_select_title', lang),
              ),
              children: [
                for (final book in books)
                  SimpleDialogOption(
                    onPressed: () => Navigator.of(ctx).pop(book),
                    child: Row(
                      children: [
                        const Icon(Icons.menu_book_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            book.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.get(
                            'n_words',
                            lang,
                            params: {'count': book.totalWords.toString()},
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );

    if (selectedBook == null || !context.mounted) return;

    final confirmed = await BookResetDialog.show(
      context,
      lang: lang,
      bookId: selectedBook.id,
    );
    if (confirmed != true || !context.mounted) return;

    final wordListRepo = ref.read(wordListRepositoryProvider);
    await wordListRepo.resetBookWordOrder(selectedBook.id);

    ref.invalidate(listOverviewProvider);
    ref.invalidate(bookOverviewProvider);
    ref.invalidate(reviewCenterDataProvider);

    for (final list in lists.where((list) => list.bookId == selectedBook.id)) {
      ref.invalidate(listWordsProvider(list.id));
      ref.invalidate(listDetailProvider(list.id));
      ref.invalidate(forgottenWordIdsProvider(list.id));
      ref.invalidate(forgottenWordsProvider(list.id));
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.get('reset_book_order_done', lang))),
    );
  }
}

class _HomeStat extends StatelessWidget {
  final String label;
  final String value;

  const _HomeStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
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

class _HomeSectionTitle extends StatelessWidget {
  final String label;

  const _HomeSectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
      ),
    );
  }
}

class _HomeFeatureGrid extends StatelessWidget {
  final List<Widget> children;

  const _HomeFeatureGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    final visibleChildren = children
        .where((child) => child is! SizedBox)
        .toList(growable: false);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 3 : 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: columns == 3 ? 2.15 : 1.42,
          children: visibleChildren,
        );
      },
    );
  }
}

class _HomeFeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _HomeFeatureCard({
    required this.icon,
    required this.label,
    required this.detail,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 3),
              Expanded(
                child: Text(
                  detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkflowCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final bool locked;
  final String? lockLabel;
  final VoidCallback onTap;

  const _WorkflowCard({
    required this.icon,
    required this.title,
    required this.detail,
    required this.locked,
    required this.onTap,
    this.lockLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.55);
    return Card(
      color: locked
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45)
          : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: locked ? muted : theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: locked ? muted : null,
                      ),
                    ),
                  ),
                  if (locked) Icon(Icons.lock_outline, size: 17, color: muted),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                locked ? (lockLabel ?? detail) : detail,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: locked
                      ? muted
                      : theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
