import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/services/tts_providers.dart';
import '../../../data/providers.dart';
import '../providers/dialogue_provider.dart';

class DialogueScreen extends ConsumerStatefulWidget {
  final int listId;

  const DialogueScreen({super.key, required this.listId});

  @override
  ConsumerState<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends ConsumerState<DialogueScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dialogueProvider.notifier).init(widget.listId);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _speak(String text) async {
    final result = await ref.read(ttsServiceProvider).speak(text);
    if (!mounted || result.provider != 'doubao') return;
    final lang = ref.read(languageProvider);
    final key = switch (result.source) {
      'cache' => 'tts_played_doubao_cache',
      'api' => 'tts_played_doubao_api',
      'api_disabled_missing_cache' => 'tts_doubao_cache_missing_api_disabled',
      'api_failed' => 'tts_doubao_api_failed',
      _ => null,
    };
    if (key == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.get(key, lang)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dialogueProvider);
    final lang = ref.watch(languageProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('ai_dialogue_title', lang)),
        actions: [
          if (state.phase == DialoguePhase.ready)
            IconButton(
              icon: Icon(
                state.showTranslation
                    ? Icons.translate
                    : Icons.translate_outlined,
              ),
              tooltip: AppStrings.get('toggle_translation', lang),
              onPressed: () =>
                  ref.read(dialogueProvider.notifier).toggleTranslation(),
            ),
        ],
      ),
      body: switch (state.phase) {
        DialoguePhase.setup => _buildSetup(context, state, lang, theme),
        DialoguePhase.generating => _buildGenerating(
          context,
          state,
          lang,
          theme,
        ),
        DialoguePhase.ready => _buildDialogue(context, state, lang, theme),
        DialoguePhase.error => _buildError(context, state, lang, theme),
      },
    );
  }

  Widget _buildSetup(
    BuildContext context,
    DialogueState state,
    String lang,
    ThemeData theme,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          AppStrings.get('dialogue_scenario', lang),
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: DropdownButtonFormField<String>(
              initialValue: state.scenario,
              decoration: const InputDecoration(border: InputBorder.none),
              items: dialogueScenarios.map((s) {
                return DropdownMenuItem(value: s, child: Text(s));
              }).toList(),
              onChanged: (v) {
                if (v != null) {
                  ref.read(dialogueProvider.notifier).setScenario(v);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.get(
                  'select_words_for_dialogue',
                  lang,
                  params: {'count': state.selectedWords.length.toString()},
                ),
                style: theme.textTheme.titleSmall,
              ),
            ),
            TextButton(
              onPressed: () => ref.read(dialogueProvider.notifier).selectAll(),
              child: Text(AppStrings.get('select_all', lang)),
            ),
            TextButton(
              onPressed: () =>
                  ref.read(dialogueProvider.notifier).deselectAll(),
              child: Text(AppStrings.get('deselect_all', lang)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: state.words.map((word) {
            final isSelected = state.selectedWords.contains(word.english);
            return FilterChip(
              label: Text(word.english),
              selected: isSelected,
              onSelected: (_) =>
                  ref.read(dialogueProvider.notifier).toggleWord(word.english),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: state.selectedWords.isEmpty
                ? null
                : () => ref.read(dialogueProvider.notifier).generate(),
            icon: const Icon(Icons.auto_awesome),
            label: Text(AppStrings.get('generate_dialogue', lang)),
          ),
        ),
      ],
    );
  }

  Widget _buildGenerating(
    BuildContext context,
    DialogueState state,
    String lang,
    ThemeData theme,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            AppStrings.get('generating_dialogue', lang),
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildDialogue(
    BuildContext context,
    DialogueState state,
    String lang,
    ThemeData theme,
  ) {
    final dialogue = state.dialogue!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dialogue.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${dialogue.lines.length} ${AppStrings.get('lines_count', lang)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () =>
                        ref.read(dialogueProvider.notifier).generate(),
                    icon: const Icon(Icons.refresh),
                    tooltip: AppStrings.get('regenerate', lang),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: dialogue.lines.length,
            itemBuilder: (context, index) {
              final line = dialogue.lines[index];
              return _DialogueBubble(
                speaker: line.speaker,
                english: line.english,
                chineseTranslation: line.chineseTranslation,
                showTranslation: state.showTranslation,
                onSpeak: () => _speak(line.english),
                theme: theme,
                lang: lang,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildError(
    BuildContext context,
    DialogueState state,
    String lang,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.error ?? AppStrings.get('error', lang),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.read(dialogueProvider.notifier).generate(),
              child: Text(AppStrings.get('retry', lang)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogueBubble extends StatelessWidget {
  final String speaker;
  final String english;
  final String chineseTranslation;
  final bool showTranslation;
  final VoidCallback onSpeak;
  final ThemeData theme;
  final String lang;

  const _DialogueBubble({
    required this.speaker,
    required this.english,
    required this.chineseTranslation,
    required this.showTranslation,
    required this.onSpeak,
    required this.theme,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.secondaryContainer,
            child: Text(
              speaker.substring(0, 1).toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.4,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            speaker,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: onSpeak,
                          borderRadius: BorderRadius.circular(12),
                          child: Icon(
                            Icons.volume_up,
                            size: 18,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(english, style: theme.textTheme.bodyMedium),
                    if (showTranslation) ...[
                      const SizedBox(height: 4),
                      Text(
                        chineseTranslation,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
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
