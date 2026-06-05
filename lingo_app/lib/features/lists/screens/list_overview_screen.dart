import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../data/database/app_database.dart';
import '../../../data/providers.dart';
import '../../import/providers/built_in_books_provider.dart';
import '../../import/providers/import_provider.dart';
import '../providers/list_provider.dart';

class ListOverviewScreen extends ConsumerStatefulWidget {
  const ListOverviewScreen({super.key});

  @override
  ConsumerState<ListOverviewScreen> createState() =>
      _ListOverviewScreenState();
}

class _ListOverviewScreenState extends ConsumerState<ListOverviewScreen> {
  static const int _listsPerPage = 24;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final listsAsync = ref.watch(listOverviewProvider);
    final lang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: AppStrings.get('back_home', lang),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(AppStrings.get('app_title', lang)),
        actions: [
          IconButton(
            icon: const Icon(Icons.record_voice_over_outlined),
            tooltip: AppStrings.get('custom_tts_menu', lang),
            onPressed: () => context.push('/custom-tts'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: AppStrings.get('import_words', lang),
            onPressed: () => context.push('/import'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
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
          if (lists.isEmpty) {
            return _buildEmptyState(context, ref);
          }
          return _buildListContent(context, ref, lists, lang);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final builtInBooksAsync = ref.watch(builtInWordBooksProvider);
    final lang = ref.watch(languageProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Icon(
          Icons.menu_book_outlined,
          size: 72,
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 20),
        Text(
          AppStrings.get('no_lists_yet', lang),
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.get('tap_built_in', lang),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        // Built-in book cards
        builtInBooksAsync.when(
          loading: () => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          error: (e, s) => const SizedBox.shrink(),
          data: (books) => books.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  children: [
                    ...books.map(
                      (book) => _builtInBookCard(context, ref, book, theme),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 20),
        Center(
          child: OutlinedButton.icon(
            onPressed: () => context.push('/import'),
            icon: const Icon(Icons.folder_open, size: 18),
            label: Text(AppStrings.get('browse_files', lang)),
          ),
        ),
      ],
    );
  }

  Widget _buildListContent(
    BuildContext context,
    WidgetRef ref,
    List<WordList> lists,
    String lang,
  ) {
    final theme = Theme.of(context);
    final totalPages = (lists.length / _listsPerPage).ceil();
    final pageIndex = _currentPage.clamp(0, totalPages - 1).toInt();
    final startIndex = pageIndex * _listsPerPage;
    final endIndex = math.min(startIndex + _listsPerPage, lists.length);
    final visibleLists = lists.sublist(startIndex, endIndex);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(listOverviewProvider);
        await ref.read(listOverviewProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: pageIndex > 0
                      ? () => setState(() => _currentPage = pageIndex - 1)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  label: Text(AppStrings.get('previous_page', lang)),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      AppStrings.get(
                        'list_page_range',
                        lang,
                        params: {
                          'page': (pageIndex + 1).toString(),
                          'total': totalPages.toString(),
                          'start': (startIndex + 1).toString(),
                          'end': endIndex.toString(),
                        },
                      ),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: pageIndex < totalPages - 1
                      ? () => setState(() => _currentPage = pageIndex + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                  label: Text(AppStrings.get('next_page', lang)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          ...visibleLists.map((list) => _ListCard(list: list)),
        ],
      ),
    );
  }

  Widget _builtInBookCard(
    BuildContext context,
    WidgetRef ref,
    BuiltInWordBook book,
    ThemeData theme,
  ) {
    final lang = ref.watch(languageProvider);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          ref
              .read(importStateProvider.notifier)
              .loadBuiltInBook(book.assetPath, book.name);
          context.push('/import');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.get(
                        'n_words',
                        lang,
                        params: {'count': book.wordCount.toString()},
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListCard extends ConsumerWidget {
  final WordList list;
  const _ListCard({required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final theme = Theme.of(context);
    final isPassed = list.isPassed;
    final createdDate = DateTime.fromMillisecondsSinceEpoch(list.createdAt);
    final dateStr =
        '${createdDate.year}-${createdDate.month.toString().padLeft(2, '0')}-${createdDate.day.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/list/${list.id}'),
        onLongPress: () => _showDeleteDialog(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isPassed
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPassed ? Icons.check_circle : Icons.menu_book,
                  color: isPassed
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          AppStrings.get(
                            'n_words',
                            lang,
                            params: {'count': list.wordCount.toString()},
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          dateStr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Badge + chevron
              _PassBadge(
                isPassed: isPassed,
                threshold: list.passThreshold,
                lang: lang,
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    final lang = ref.read(languageProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.get('delete_list_title', lang)),
        content: Text(
          AppStrings.get('delete_confirm', lang, params: {'name': list.name}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppStrings.get('cancel', lang)),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(wordListRepositoryProvider).deleteList(list.id);
              ref.invalidate(listOverviewProvider);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(AppStrings.get('delete', lang)),
          ),
        ],
      ),
    );
  }
}

class _PassBadge extends StatelessWidget {
  final bool isPassed;
  final double threshold;
  final String lang;

  const _PassBadge({
    required this.isPassed,
    required this.threshold,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = isPassed
        ? AppStrings.get('pass_badge', lang)
        : '${(threshold * 100).round()}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPassed
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isPassed
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
