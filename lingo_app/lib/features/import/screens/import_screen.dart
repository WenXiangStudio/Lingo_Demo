import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../data/providers.dart';
import '../providers/built_in_books_provider.dart';
import '../providers/import_provider.dart';

class ImportScreen extends ConsumerWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importStateProvider);
    final lang = ref.watch(languageProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('import_words_title', lang))),
      body: state.isImporting && !state.genScenarios
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(AppStrings.get('importing', lang)),
                ],
              ),
            )
          : state.previewWords.isEmpty
          ? _buildFilePicker(context, ref, state, theme, lang)
          : _buildPreview(context, ref, state, theme, lang),
    );
  }

  Widget _buildFilePicker(
    BuildContext context,
    WidgetRef ref,
    ImportState state,
    ThemeData theme,
    String lang,
  ) {
    final builtInBooksAsync = ref.watch(builtInWordBooksProvider);
    final notifier = ref.read(importStateProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Built-in word books section
        builtInBooksAsync.when(
          loading: () => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.get('loading_built_in_books', lang),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          error: (e, s) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        e.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          data: (builtInBooks) {
            if (builtInBooks.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.library_books,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.get('built_in_books', lang),
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.get('tap_to_import', lang),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 12),
                ...builtInBooks.map(
                  (book) => _builtInBookCard(context, ref, book, theme, lang),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        AppStrings.get('or_import_file', lang),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
        Center(
          child: OutlinedButton.icon(
            onPressed: () => notifier.pickAndParseFile(),
            icon: const Icon(Icons.folder_open),
            label: Text(AppStrings.get('browse_files', lang)),
          ),
        ),
        if (state.error != null) ...[
          const SizedBox(height: 16),
          _errorCard(context, state.error!, () {
            notifier.clearError();
          }),
        ],
      ],
    );
  }

  Widget _builtInBookCard(
    BuildContext context,
    WidgetRef ref,
    BuiltInWordBook book,
    ThemeData theme,
    String lang,
  ) {
    final displayName = AppStrings.get(book.nameKey, lang);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          ref
              .read(importStateProvider.notifier)
              .loadBuiltInBook(book.assetPath, displayName);
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
                      displayName,
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

  Widget _buildPreview(
    BuildContext context,
    WidgetRef ref,
    ImportState state,
    ThemeData theme,
    String lang,
  ) {
    final displayed = state.displayedWords;
    final hasMore = state.wordCount > 10;
    final notifier = ref.read(importStateProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.fileName ?? '',
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        notifier.pickAndParseFile();
                      },
                      child: Text(AppStrings.get('change', lang)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.get(
                    'n_words_found',
                    lang,
                    params: {'count': state.wordCount.toString()},
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // List name
        TextField(
          controller: TextEditingController(text: state.listName)
            ..selection = TextSelection(
              baseOffset: 0,
              extentOffset: state.listName.length,
            ),
          onChanged: (v) => notifier.updateListName(v),
          decoration: InputDecoration(
            labelText: AppStrings.get('list_name', lang),
            hintText: AppStrings.get('list_name_hint', lang),
            prefixIcon: const Icon(Icons.label_outline),
          ),
        ),

        const SizedBox(height: 16),

        // List size
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.format_list_numbered),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.get('list_size_label', lang),
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    Text(
                      '${state.listSize}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.get(
                    'splits_into',
                    lang,
                    params: {'count': state.listCount.toString()},
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: state.listSize.toDouble(),
                  min: 5,
                  max: 100,
                  divisions: 19,
                  onChanged: (v) => notifier.updateListSize(v.round()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '5',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                    Text(
                      '100',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        AppStrings.get('list_size_warning', lang),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Pass threshold
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.get('pass_threshold', lang),
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    Text(
                      '${(state.passThreshold * 100).round()}%',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: state.passThreshold,
                  min: AppConstants.minPassThreshold,
                  max: AppConstants.maxPassThreshold,
                  divisions: 10,
                  onChanged: (v) => notifier.updatePassThreshold(v),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '50%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      '100%',
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
        ),

        const SizedBox(height: 16),

        // AI scenario generation toggle
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(AppStrings.get('ai_gen_scenarios', lang)),
              subtitle: Text(
                AppStrings.get('ai_gen_scenarios_desc', lang),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              value: state.genScenarios,
              onChanged: (_) => notifier.toggleGenScenarios(),
              secondary: const Icon(Icons.auto_awesome),
            ),
          ),
        ),

        // Show scenario generation progress during import
        if (state.isImporting &&
            state.genScenarios &&
            state.scenariosTotal > 0) ...[
          const SizedBox(height: 12),
          Card(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.get(
                        'gen_scenarios_progress',
                        lang,
                        params: {
                          'done': state.scenariosDone.toString(),
                          'total': state.scenariosTotal.toString(),
                        },
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Preview header
        Row(
          children: [
            Text(
              AppStrings.get('preview', lang),
              style: theme.textTheme.titleSmall,
            ),
            const Spacer(),
            if (hasMore)
              TextButton(
                onPressed: () => notifier.toggleShowAllPreview(),
                child: Text(
                  state.showAllPreview
                      ? AppStrings.get('show_less', lang)
                      : AppStrings.get('show_all', lang),
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        // Preview table
        Card(
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                theme.colorScheme.surfaceContainerHighest,
              ),
              columns: [
                DataColumn(label: Text('#')),
                DataColumn(label: Text(AppStrings.get('english_col', lang))),
                DataColumn(label: Text(AppStrings.get('chinese_col', lang))),
                DataColumn(
                  label: Text(AppStrings.get('pronunciation_col', lang)),
                ),
              ],
              rows: List.generate(displayed.length, (i) {
                final w = displayed[i];
                return DataRow(
                  cells: [
                    DataCell(Text('${i + 1}')),
                    DataCell(Text(w.english)),
                    DataCell(Text(w.chineseMeanings)),
                    DataCell(Text(w.pronunciation ?? '-')),
                  ],
                );
              }),
            ),
          ),
        ),

        if (hasMore && !state.showAllPreview)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              AppStrings.get(
                'more_words',
                lang,
                params: {'count': (state.wordCount - 10).toString()},
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ),

        const SizedBox(height: 16),

        // Error
        if (state.error != null) ...[
          _errorCard(context, state.error!, () {
            ref.read(importStateProvider.notifier).clearError();
          }),
          const SizedBox(height: 16),
        ],

        // Import button
        FilledButton.icon(
          onPressed: state.isImporting
              ? null
              : () async {
                  final success = await ref
                      .read(importStateProvider.notifier)
                      .executeImport();
                  if (success && context.mounted) {
                    ref.read(importStateProvider.notifier).reset();
                    context.pop();
                  }
                },
          icon: state.isImporting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.cloud_upload_outlined),
          label: Text(
            state.isImporting
                ? AppStrings.get('importing', lang)
                : AppStrings.get(
                    'import_n_words',
                    lang,
                    params: {'count': state.wordCount.toString()},
                  ),
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _errorCard(
    BuildContext context,
    String message,
    VoidCallback onDismiss,
  ) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}
