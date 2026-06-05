import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../data/database/app_database.dart';
import '../../../data/providers.dart';
import '../providers/practice_provider.dart';

class ErrorWordReviewScreen extends ConsumerWidget {
  final int listId;

  const ErrorWordReviewScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final asyncData = ref.watch(errorWordsWithCountProvider(listId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('error_words_screen_title', lang)),
        actions: [
          if (asyncData.valueOrNull?.isNotEmpty == true)
            TextButton.icon(
              onPressed: () => _startRetest(context, ref),
              icon: const Icon(Icons.replay, size: 18),
              label: Text(AppStrings.get('retest', lang)),
            ),
        ],
      ),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('${AppStrings.get('error', lang)}: $e'),
            ],
          ),
        ),
        data: (errorWords) {
          if (errorWords.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.celebration,
                        size: 64,
                        color: Colors.green.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.get('no_error_words', lang),
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.get('great_job', lang),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return _buildErrorList(context, ref, errorWords, theme);
        },
      ),
    );
  }

  Widget _buildErrorList(
    BuildContext context,
    WidgetRef ref,
    List<ErrorWordWithCount> errorWords,
    ThemeData theme,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(errorWordsWithCountProvider(listId));
        await ref.read(errorWordsWithCountProvider(listId).future);
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: errorWords.length,
        itemBuilder: (context, index) {
          final ew = errorWords[index];
          return _ErrorWordCard(errorWord: ew);
        },
      ),
    );
  }

  void _startRetest(BuildContext context, WidgetRef ref) {
    final errorWords =
        ref.read(errorWordsWithCountProvider(listId)).valueOrNull ?? [];
    if (errorWords.isEmpty) return;

    final notifier = ref.read(practiceProvider.notifier);
    notifier.reset();
    context.push(
      '/practice/$listId/setup?errors=true&returnPath=${Uri.encodeComponent('/error-words/$listId')}',
    );
  }
}

class _ErrorWordCard extends StatelessWidget {
  final ErrorWordWithCount errorWord;

  const _ErrorWordCard({required this.errorWord});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = errorWord.word;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Error count badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: errorWord.errorCount > 2
                    ? Colors.red.withValues(alpha: 0.12)
                    : Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${errorWord.errorCount}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: errorWord.errorCount > 2
                        ? Colors.red
                        : Colors.orange,
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
                    w.english,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    w.chineseMeanings,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color:
                    theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}
