import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../data/providers.dart';
import '../models/narration_models.dart';
import '../providers/narration_provider.dart';

class NarrationLibraryScreen extends ConsumerWidget {
  const NarrationLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final items = ref.watch(narrationLearningItemsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.get('narration_library', lang)),
          bottom: TabBar(
            tabs: [
              Tab(text: AppStrings.get('narration_word_library', lang)),
              Tab(text: AppStrings.get('narration_knowledge_library', lang)),
            ],
          ),
        ),
        body: items.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(AppStrings.get('narration_load_failed', lang)),
          ),
          data: (all) => TabBarView(
            children: [
              _LearningList(
                items: all
                    .where(
                      (item) => item.type == NarrationLearningItemType.word,
                    )
                    .toList(),
                lang: lang,
                onMarkKnown: (item) => _markKnown(context, ref, lang, item),
              ),
              _LearningList(
                items: all
                    .where(
                      (item) =>
                          item.type == NarrationLearningItemType.knowledge,
                    )
                    .toList(),
                lang: lang,
                onMarkKnown: (item) => _markKnown(context, ref, lang, item),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markKnown(
    BuildContext context,
    WidgetRef ref,
    String lang,
    NarrationLearningItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.get('narration_mark_known_title', lang)),
        content: Text(AppStrings.get('narration_mark_known_body', lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.get('cancel', lang)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppStrings.get('narration_mark_known', lang)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(narrationRepositoryProvider).markLearningItemKnown(item.id);
    ref.invalidate(narrationLearningItemsProvider);
    ref.invalidate(narrationDueItemsProvider);
    ref.invalidate(narrationDashboardProvider);
  }
}

class _LearningList extends StatelessWidget {
  const _LearningList({
    required this.items,
    required this.lang,
    required this.onMarkKnown,
  });

  final List<NarrationLearningItem> items;
  final String lang;
  final ValueChanged<NarrationLearningItem> onMarkKnown;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(AppStrings.get('narration_library_empty', lang)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: ExpansionTile(
            leading: CircleAvatar(
              child: Icon(
                item.type == NarrationLearningItemType.word
                    ? Icons.translate
                    : Icons.lightbulb_outline,
              ),
            ),
            title: Text(item.english),
            subtitle: Text(item.chinese),
            trailing: _MasteryChip(item: item, lang: lang),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.partOfSpeech.isNotEmpty)
                Text(
                  '${AppStrings.get('narration_part_of_speech', lang)}: ${item.partOfSpeech}',
                ),
              if (item.knowledgeLevel.isNotEmpty)
                Text(
                  '${AppStrings.get('narration_level', lang)}: ${AppStrings.get('narration_knowledge_${item.knowledgeLevel}', lang)}',
                ),
              if (item.explanation.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(item.explanation),
              ],
              const SizedBox(height: 8),
              Text(
                AppStrings.get(
                  'narration_item_stats',
                  lang,
                  params: {
                    'appearances': item.occurrenceCount.toString(),
                    'successes': item.realUseSuccessCount.toString(),
                    'failures': item.realUseFailureCount.toString(),
                  },
                ),
              ),
              if (!item.reviewRequired)
                Text(
                  AppStrings.get('narration_optional_review', lang),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: item.userConfirmed
                      ? null
                      : () => onMarkKnown(item),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    item.userConfirmed
                        ? AppStrings.get('narration_marked_known', lang)
                        : AppStrings.get('narration_mark_known', lang),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MasteryChip extends StatelessWidget {
  const _MasteryChip({required this.item, required this.lang});

  final NarrationLearningItem item;
  final String lang;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        AppStrings.get('narration_mastery_${item.masteryState.code}', lang),
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}
