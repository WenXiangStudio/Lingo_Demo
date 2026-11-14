import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/data_dir.dart';
import '../../../data/providers.dart';
import '../models/narration_models.dart';
import '../providers/narration_provider.dart';

class NarrationHomeScreen extends ConsumerWidget {
  const NarrationHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final summary = ref.watch(narrationDashboardProvider);
    final sessions = ref.watch(narrationRecentSessionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('narration_title', lang)),
        actions: [
          IconButton(
            tooltip: AppStrings.get('narration_library', lang),
            onPressed: () => context.push('/narration/library'),
            icon: const Icon(Icons.school_outlined),
          ),
          IconButton(
            tooltip: AppStrings.get('narration_progress', lang),
            onPressed: () => context.push('/narration/progress'),
            icon: const Icon(Icons.show_chart),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                _exportData(context, ref, lang);
              } else if (value == 'delete_all') {
                _deleteAll(context, ref, lang);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'export',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.download_outlined),
                  title: Text(AppStrings.get('narration_export', lang)),
                ),
              ),
              PopupMenuItem(
                value: 'delete_all',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_forever_outlined),
                  title: Text(AppStrings.get('narration_delete_all', lang)),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(narrationFlowProvider.notifier).reset();
          context.push('/narration/new');
        },
        icon: const Icon(Icons.mic),
        label: Text(AppStrings.get('narration_new', lang)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(narrationDashboardProvider);
          ref.invalidate(narrationRecentSessionsProvider);
          await ref.read(narrationDashboardProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('narration_home_heading', lang),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(AppStrings.get('narration_home_intro', lang)),
                    const SizedBox(height: 18),
                    summary.when(
                      data: (value) => Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _StatChip(
                            icon: Icons.forum_outlined,
                            label: AppStrings.get('narration_sessions', lang),
                            value: value.sessionCount,
                          ),
                          _StatChip(
                            icon: Icons.translate,
                            label: AppStrings.get('narration_words', lang),
                            value: value.wordCount,
                          ),
                          _StatChip(
                            icon: Icons.lightbulb_outline,
                            label: AppStrings.get('narration_knowledge', lang),
                            value: value.knowledgeCount,
                          ),
                          _StatChip(
                            icon: Icons.event_available,
                            label: AppStrings.get('narration_due', lang),
                            value: value.dueCount,
                          ),
                        ],
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (error, stack) => Text(
                        AppStrings.get('narration_load_failed', lang),
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => context.push('/narration/review'),
                    icon: const Icon(Icons.replay),
                    label: Text(AppStrings.get('narration_review', lang)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => context.push('/narration/library'),
                    icon: const Icon(Icons.library_books_outlined),
                    label: Text(AppStrings.get('narration_library', lang)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              AppStrings.get('narration_recent', lang),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            sessions.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text(
                AppStrings.get('narration_load_failed', lang),
                style: TextStyle(color: theme.colorScheme.error),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return _EmptyCard(
                    icon: Icons.mic_none,
                    text: AppStrings.get('narration_no_sessions', lang),
                  );
                }
                return Column(
                  children: [
                    for (final item in items)
                      Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(
                              item.finalConfirmed
                                  ? Icons.check
                                  : Icons.edit_outlined,
                            ),
                          ),
                          title: Text(
                            item.rawTranscript,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${_statusLabel(item.status, lang)} · ${_date(item.updatedAt)}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            ref
                                .read(narrationFlowProvider.notifier)
                                .loadSession(item.id);
                            context.push('/narration/new?sessionId=${item.id}');
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(NarrationSessionStatus status, String lang) {
    final key = switch (status) {
      NarrationSessionStatus.transcriptReview =>
        'narration_status_transcript_review',
      NarrationSessionStatus.translation => 'narration_status_translation',
      NarrationSessionStatus.targetReview => 'narration_status_target_review',
      NarrationSessionStatus.analysed => 'narration_status_analysed',
      NarrationSessionStatus.confirmed => 'narration_status_confirmed',
    };
    return AppStrings.get(key, lang);
  }

  String _date(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} ${two(value.hour)}:${two(value.minute)}';
  }

  Future<void> _exportData(
    BuildContext context,
    WidgetRef ref,
    String lang,
  ) async {
    try {
      final json = await ref.read(narrationRepositoryProvider).exportJson();
      final root = await getLingoDataDir();
      final directory = Directory('${root.path}/narration_exports');
      await directory.create(recursive: true);
      final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${directory.path}/narration_export_$stamp.json');
      await file.writeAsString(json, flush: true);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.get(
              'narration_exported_to',
              lang,
              params: {'path': file.path},
            ),
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.get(
              'narration_export_failed',
              lang,
              params: {'error': error.toString()},
            ),
          ),
        ),
      );
    }
  }

  Future<void> _deleteAll(
    BuildContext context,
    WidgetRef ref,
    String lang,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.get('narration_delete_all_title', lang)),
        content: Text(AppStrings.get('narration_delete_all_body', lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.get('cancel', lang)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppStrings.get('narration_delete_all', lang)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final repository = ref.read(narrationRepositoryProvider);
    final audioPaths = await repository.getRetainedAudioPaths();
    for (final path in audioPaths) {
      await ref.read(narrationAudioVaultProvider).deleteEncrypted(path);
    }
    await repository.deleteAllNarrationData();
    ref.invalidate(narrationDashboardProvider);
    ref.invalidate(narrationRecentSessionsProvider);
    ref.invalidate(narrationDueItemsProvider);
    ref.invalidate(narrationLearningItemsProvider);
    ref.invalidate(narrationProgressProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.get('narration_all_deleted', lang))),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text('$label $value'));
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: Column(
            children: [
              Icon(icon, size: 42),
              const SizedBox(height: 12),
              Text(text, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
