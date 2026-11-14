import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../data/providers.dart';
import '../models/narration_models.dart';
import '../providers/narration_provider.dart';

class NarrationReviewScreen extends ConsumerStatefulWidget {
  const NarrationReviewScreen({super.key});

  @override
  ConsumerState<NarrationReviewScreen> createState() =>
      _NarrationReviewScreenState();
}

class _NarrationReviewScreenState extends ConsumerState<NarrationReviewScreen> {
  final _answerController = TextEditingController();
  var _index = 0;
  var _revealed = false;
  var _saving = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final due = ref.watch(narrationDueItemsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('narration_review', lang))),
      body: due.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text(AppStrings.get('narration_load_failed', lang))),
        data: (items) {
          if (items.isEmpty || _index >= items.length) {
            return _ReviewComplete(lang: lang);
          }
          return _ReviewCard(
            item: items[_index],
            position: _index + 1,
            total: items.length,
            lang: lang,
            controller: _answerController,
            revealed: _revealed,
            saving: _saving,
            onReveal: () => setState(() => _revealed = true),
            onResult: (passed) => _record(items[_index], passed),
          );
        },
      ),
    );
  }

  Future<void> _record(NarrationLearningItem item, bool passed) async {
    setState(() => _saving = true);
    await ref
        .read(narrationRepositoryProvider)
        .recordReview(
          itemId: item.id,
          layer: item.reviewLayer,
          passed: passed,
          answer: _answerController.text.trim(),
        );
    ref.invalidate(narrationLearningItemsProvider);
    ref.invalidate(narrationDashboardProvider);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _revealed = false;
      _index++;
      _answerController.clear();
    });
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.item,
    required this.position,
    required this.total,
    required this.lang,
    required this.controller,
    required this.revealed,
    required this.saving,
    required this.onReveal,
    required this.onResult,
  });

  final NarrationLearningItem item;
  final int position;
  final int total;
  final String lang;
  final TextEditingController controller;
  final bool revealed;
  final bool saving;
  final VoidCallback onReveal;
  final ValueChanged<bool> onResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recognition = item.reviewLayer == 'recognition';
    final prompt = recognition
        ? item.type == NarrationLearningItemType.word
              ? item.chinese
              : AppStrings.get(
                  'narration_fix_prompt',
                  lang,
                  params: {'point': item.english},
                )
        : AppStrings.get(
            'narration_apply_prompt',
            lang,
            params: {'item': item.english},
          );
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        LinearProgressIndicator(value: position / total),
        const SizedBox(height: 14),
        Text('$position / $total', textAlign: TextAlign.center),
        const SizedBox(height: 22),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Chip(
                  label: Text(
                    AppStrings.get(
                      recognition
                          ? 'narration_review_recognition'
                          : 'narration_review_application',
                      lang,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  prompt,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: controller,
          minLines: recognition ? 1 : 3,
          maxLines: 5,
          enabled: !revealed && !saving,
          decoration: InputDecoration(
            labelText: AppStrings.get('answer', lang),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        if (!revealed)
          FilledButton(
            onPressed: saving ? null : onReveal,
            child: Text(AppStrings.get('narration_reveal_answer', lang)),
          )
        else ...[
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    item.english,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (item.explanation.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(item.explanation),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: saving ? null : () => onResult(false),
                  icon: const Icon(Icons.refresh),
                  label: Text(AppStrings.get('narration_review_again', lang)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: saving ? null : () => onResult(true),
                  icon: const Icon(Icons.check),
                  label: Text(AppStrings.get('narration_review_passed', lang)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ReviewComplete extends StatelessWidget {
  const _ReviewComplete({required this.lang});

  final String lang;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              AppStrings.get('narration_review_complete', lang),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
