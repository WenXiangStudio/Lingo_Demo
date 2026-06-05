import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../data/providers.dart';
import '../providers/history_provider.dart';

class PracticeHistoryScreen extends ConsumerWidget {
  final int? listId;

  const PracticeHistoryScreen({super.key, this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final theme = Theme.of(context);

    if (listId != null) {
      return _buildListHistory(context, ref, theme, listId!, lang);
    }
    return _buildAllHistory(context, ref, theme, lang);
  }

  Widget _buildAllHistory(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    String lang,
  ) {
    final asyncData = ref.watch(allPracticeHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('practice_history_title', lang))),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('${AppStrings.get('error', lang)}: $e')),
        data: (summaries) {
          if (summaries.isEmpty) {
            return Center(child: Text(AppStrings.get('no_sessions', lang)));
          }
          return _buildSessionList(context, ref, summaries, theme, lang);
        },
      ),
    );
  }

  Widget _buildListHistory(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    int listId,
    String lang,
  ) {
    final asyncData = ref.watch(listPracticeHistoryProvider(listId));

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('list_history_title', lang))),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('${AppStrings.get('error', lang)}: $e')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(child: Text(AppStrings.get('no_list_sessions', lang)));
          }
          final summaries = sessions
              .map((s) => SessionSummary(session: s, listName: ''))
              .toList();
          return _buildSessionList(context, ref, summaries, theme, lang);
        },
      ),
    );
  }

  Widget _buildSessionList(
    BuildContext context,
    WidgetRef ref,
    List<SessionSummary> summaries,
    ThemeData theme,
    String lang,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allPracticeHistoryProvider);
        await ref.read(allPracticeHistoryProvider.future);
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: summaries.length,
        itemBuilder: (context, index) {
          final s = summaries[index];
          return _SessionCard(summary: s, lang: lang);
        },
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SessionSummary summary;
  final String lang;

  const _SessionCard({required this.summary, required this.lang});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = summary.session;
    final date = DateTime.fromMillisecondsSinceEpoch(s.startedAt);
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final accuracy = s.accuracy;
    final percentage = (accuracy * 100).round();
    final isPassed = accuracy >= 0.75;
    final modeLabel = _modeLabel(s.mode, lang);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isPassed
                    ? Colors.green.withValues(alpha: 0.12)
                    : Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '$percentage%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isPassed ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (summary.listName.isNotEmpty)
                    Text(
                      summary.listName,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  Row(
                    children: [
                      _chip(theme, modeLabel),
                      const SizedBox(width: 8),
                      Text(
                        '${s.correctCount}/${s.totalCount}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.4),
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

  Widget _chip(ThemeData theme, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }

  String _modeLabel(String mode, String lang) {
    switch (mode) {
      case 'choice':
        return AppStrings.get('mode_choice', lang);
      case 'fill':
        return AppStrings.get('mode_fill', lang);
      case 'dictation':
        return AppStrings.get('mode_dictation', lang);
      case 'deep_choice':
        return AppStrings.get('mode_deep_choice', lang);
      case 'deep_fill':
        return AppStrings.get('mode_deep_fill', lang);
      case 'deep_idioms':
        return AppStrings.get('mode_deep_idioms', lang);
      default:
        return mode;
    }
  }
}
