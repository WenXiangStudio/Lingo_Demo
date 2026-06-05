import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../data/database/app_database.dart';
import '../../../data/providers.dart';
import '../../review_center/providers/review_center_provider.dart';
import '../providers/list_provider.dart';
import '../widgets/book_reset_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _didPreloadReviewCenter = false;

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
          _preloadReviewCenter();
          return _HomeContent(lists: lists);
        },
      ),
    );
  }

  void _preloadReviewCenter() {
    if (_didPreloadReviewCenter) return;
    _didPreloadReviewCenter = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(reviewBooksProvider.future).ignore();
      ref.read(reviewCenterDataProvider.future).ignore();
    });
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
    final passedListItems = lists
        .where((list) => list.isPassed == true)
        .toList();

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
                AppStrings.get('home_title', lang),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.get('home_subtitle', lang),
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
              icon: Icons.history,
              label: AppStrings.get('history', lang),
              detail: AppStrings.get('home_history_desc', lang),
              onTap: () => context.push('/history'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _HomeSectionTitle(
          label: AppStrings.get('home_section_ai_practice', lang),
        ),
        const SizedBox(height: 8),
        _HomeFeatureGrid(
          children: [
            _HomeFeatureCard(
              icon: Icons.auto_awesome,
              label: AppStrings.get('ai_deep_learn', lang),
              detail: AppStrings.get('home_ai_deep_desc', lang),
              onTap: () => _openPassedListFeature(
                context,
                lang,
                passedListItems,
                routeForList: (list) =>
                    '/deep-practice/${list.id}/setup?returnPath=${Uri.encodeComponent('/')}',
              ),
            ),
            _HomeFeatureCard(
              icon: Icons.chat_bubble_outline,
              label: AppStrings.get('ai_dialogue_btn', lang),
              detail: AppStrings.get('home_ai_dialogue_desc', lang),
              onTap: () => _openPassedListFeature(
                context,
                lang,
                passedListItems,
                routeForList: (list) => '/dialogue/${list.id}',
              ),
            ),
            _HomeFeatureCard(
              icon: Icons.record_voice_over_outlined,
              label: AppStrings.get('speaking_practice', lang),
              detail: AppStrings.get('home_speaking_desc', lang),
              onTap: () => _openPassedListFeature(
                context,
                lang,
                passedListItems,
                routeForList: (list) =>
                    '/speaking/${list.id}?returnPath=${Uri.encodeComponent('/')}',
              ),
            ),
            _HomeFeatureCard(
              icon: Icons.auto_fix_high,
              label: AppStrings.get('skills_title', lang),
              detail: AppStrings.get('home_skills_desc', lang),
              onTap: () => context.push('/skills'),
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
      ],
    );
  }

  Future<void> _openPassedListFeature(
    BuildContext context,
    String lang,
    List<WordList> passedLists, {
    required String Function(WordList list) routeForList,
  }) async {
    if (passedLists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('home_no_unlocked_lists', lang))),
      );
      return;
    }

    final selected = passedLists.length == 1
        ? passedLists.first
        : await showDialog<WordList>(
            context: context,
            builder: (ctx) => SimpleDialog(
              title: Text(AppStrings.get('home_choose_passed_list', lang)),
              children: [
                for (final list in passedLists)
                  SimpleDialogOption(
                    onPressed: () => Navigator.of(ctx).pop(list),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            list.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.get(
                            'n_words',
                            lang,
                            params: {'count': list.wordCount.toString()},
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );

    if (selected == null || !context.mounted) return;
    context.push(routeForList(selected));
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
