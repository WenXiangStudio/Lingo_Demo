import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/services/tts_providers.dart';
import '../../../core/services/word_audio_repair_service.dart';
import '../../../core/services/word_audio_server_replace_service.dart';
import '../../../data/database/app_database.dart';
import '../../../data/providers.dart';
import '../services/word_audio_repair_job.dart';
import '../services/word_audio_server_replace_job.dart';

/// A maintenance UI for reviewing one word WAV locally, then optionally using
/// a separate, explicitly confirmed server replacement workflow.
class WordAudioRepairScreen extends ConsumerStatefulWidget {
  const WordAudioRepairScreen({super.key});

  @override
  ConsumerState<WordAudioRepairScreen> createState() =>
      _WordAudioRepairScreenState();
}

class _WordAudioRepairScreenState extends ConsumerState<WordAudioRepairScreen> {
  final _searchController = TextEditingController();
  final _partOfSpeechController = TextEditingController();
  final _ipaController = TextEditingController();
  final _noteController = TextEditingController();

  Timer? _searchDebounce;
  List<Word> _searchResults = const [];
  Word? _selectedWord;
  bool _isSearching = false;
  int _searchGeneration = 0;
  bool _currentLocalCandidatePreviewed = false;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _partOfSpeechController.dispose();
    _ipaController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      _searchGeneration++;
      setState(() {
        _isSearching = false;
        _searchResults = const [];
      });
      return;
    }
    setState(() => _isSearching = true);
    _searchDebounce = Timer(
      const Duration(milliseconds: 220),
      () => _searchWords(query),
    );
  }

  Future<void> _searchWords(String query) async {
    final generation = ++_searchGeneration;
    try {
      final results = await ref.read(wordRepositoryProvider).searchWords(query);
      if (!mounted || generation != _searchGeneration) return;
      setState(() {
        _isSearching = false;
        _searchResults = results.take(20).toList(growable: false);
      });
    } catch (_) {
      if (!mounted || generation != _searchGeneration) return;
      setState(() {
        _isSearching = false;
        _searchResults = const [];
      });
    }
  }

  void _selectWord(Word word) {
    final job = ref.read(wordAudioRepairJobProvider);
    if (job.isBusy || job.staged != null || job.applied != null) return;
    ref.read(wordAudioRepairJobProvider.notifier).reset();
    ref.read(wordAudioServerReplaceJobProvider.notifier).reset();
    setState(() {
      _selectedWord = word;
      _searchController.clear();
      _searchResults = const [];
      _ipaController.text = word.pronunciation ?? '';
      _partOfSpeechController.clear();
      _noteController.clear();
      _currentLocalCandidatePreviewed = false;
    });
  }

  void _changeWord() {
    final job = ref.read(wordAudioRepairJobProvider);
    if (job.isBusy || job.staged != null || job.applied != null) return;
    ref.read(wordAudioRepairJobProvider.notifier).reset();
    ref.read(wordAudioServerReplaceJobProvider.notifier).reset();
    setState(() {
      _selectedWord = null;
      _ipaController.clear();
      _partOfSpeechController.clear();
      _noteController.clear();
      _currentLocalCandidatePreviewed = false;
    });
  }

  void _onRepairInputChanged(String _) {
    ref.read(wordAudioRepairJobProvider.notifier).reset();
    ref.read(wordAudioServerReplaceJobProvider.notifier).reset();
    setState(() => _currentLocalCandidatePreviewed = false);
  }

  WordAudioRepairRequest? _repairRequest() {
    final word = _selectedWord;
    if (word == null) return null;
    return WordAudioRepairRequest(
      word: word.english,
      partOfSpeech: _partOfSpeechController.text,
      ipa: _ipaController.text,
      note: _noteController.text,
    );
  }

  Future<void> _preparePlan() async {
    final request = _repairRequest();
    if (request == null) return;
    ref.read(wordAudioServerReplaceJobProvider.notifier).reset();
    if (mounted) setState(() => _currentLocalCandidatePreviewed = false);
    await ref.read(wordAudioRepairJobProvider.notifier).preparePlan(request);
  }

  Future<void> _previewStaged(
    WordAudioRepairStagedAudio staged,
    String lang,
  ) async {
    final played = await ref
        .read(ttsServiceProvider)
        .previewWordAudioBytes(staged.audioBytes);
    if (!mounted || played) return;
    _showMessage('word_audio_repair_preview_failed', lang);
  }

  Future<void> _previewCurrent(String lang) async {
    final bytes = await ref
        .read(wordAudioRepairJobProvider.notifier)
        .readCurrentAudio();
    if (!mounted) return;
    if (bytes == null) {
      _showMessage('word_audio_repair_current_missing', lang);
      return;
    }
    final played = await ref
        .read(ttsServiceProvider)
        .previewWordAudioBytes(bytes);
    if (!mounted) return;
    if (played) {
      setState(() => _currentLocalCandidatePreviewed = true);
      return;
    }
    _showMessage('word_audio_repair_preview_failed', lang);
  }

  Future<void> _previewServerAudio(Uint8List bytes, String lang) async {
    final played = await ref
        .read(ttsServiceProvider)
        .previewWordAudioBytes(bytes);
    if (!mounted || played) return;
    _showMessage('word_audio_repair_preview_failed', lang);
  }

  Future<void> _applyStagedAudio() async {
    await ref.read(wordAudioRepairJobProvider.notifier).applyStagedAudio();
    if (mounted) setState(() => _currentLocalCandidatePreviewed = false);
  }

  Future<void> _restorePreviousLocalAudio() async {
    await ref.read(wordAudioRepairJobProvider.notifier).restorePreviousAudio();
    if (mounted) {
      ref.read(wordAudioServerReplaceJobProvider.notifier).reset();
      setState(() => _currentLocalCandidatePreviewed = false);
    }
  }

  Future<void> _prepareServerReplacement() async {
    final plan = ref.read(wordAudioRepairJobProvider).plan;
    if (plan == null) return;
    await ref
        .read(wordAudioServerReplaceJobProvider.notifier)
        .prepareReplacement(plan);
  }

  Future<void> _prepareServerRollback() async {
    final word = _selectedWord;
    if (word == null) return;
    await ref
        .read(wordAudioServerReplaceJobProvider.notifier)
        .prepareRollback(word: word.english, language: 'en');
  }

  void _discardServerPlan() {
    final job = ref.read(wordAudioServerReplaceJobProvider);
    if (job.isBusy) return;
    ref.read(wordAudioServerReplaceJobProvider.notifier).reset();
    if (mounted) setState(() {});
  }

  Future<void> _confirmAndReplaceServer(
    WordAudioServerReplacementPlan plan,
    String lang,
  ) async {
    final confirmed = await _confirmServerAction(
      lang: lang,
      titleKey: 'word_audio_server_replace_confirm_title',
      descriptionKey: 'word_audio_server_replace_confirm_desc',
      actionKey: 'word_audio_server_replace_confirm_action',
      params: {
        'word': plan.word,
        'url': plan.remoteUri.toString(),
        'old_hash': _shortHash(plan.remoteCurrentSha256),
        'new_hash': _shortHash(plan.localCandidateSha256),
      },
    );
    if (!confirmed || !mounted) return;
    await ref.read(wordAudioServerReplaceJobProvider.notifier).replace();
  }

  Future<void> _confirmAndRollbackServer(
    WordAudioServerRollbackPlan plan,
    String lang,
  ) async {
    final confirmed = await _confirmServerAction(
      lang: lang,
      titleKey: 'word_audio_server_rollback_confirm_title',
      descriptionKey: 'word_audio_server_rollback_confirm_desc',
      actionKey: 'word_audio_server_rollback_confirm_action',
      params: {
        'word': plan.word,
        'url': plan.remoteUri.toString(),
        'active_hash': _shortHash(plan.currentRemoteSha256),
        'restore_hash': _shortHash(plan.restoreSha256),
      },
    );
    if (!confirmed || !mounted) return;
    await ref.read(wordAudioServerReplaceJobProvider.notifier).rollback();
  }

  Future<bool> _confirmServerAction({
    required String lang,
    required String titleKey,
    required String descriptionKey,
    required String actionKey,
    required Map<String, String> params,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.get(titleKey, lang)),
        content: Text(AppStrings.get(descriptionKey, lang, params: params)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.get('cancel', lang)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppStrings.get(actionKey, lang)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _showMessage(String key, String lang) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppStrings.get(key, lang))));
  }

  void _startAnotherRepair() {
    final job = ref.read(wordAudioRepairJobProvider);
    if (job.isBusy) return;
    ref.read(wordAudioRepairJobProvider.notifier).reset();
    ref.read(wordAudioServerReplaceJobProvider.notifier).reset();
    setState(() {
      _selectedWord = null;
      _searchController.clear();
      _searchResults = const [];
      _partOfSpeechController.clear();
      _ipaController.clear();
      _noteController.clear();
      _currentLocalCandidatePreviewed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final job = ref.watch(wordAudioRepairJobProvider);
    final serverJob = ref.watch(wordAudioServerReplaceJobProvider);
    final theme = Theme.of(context);
    final inputLocked =
        job.isBusy ||
        job.staged != null ||
        job.applied != null ||
        serverJob.isBusy ||
        serverJob.replacementPlan != null ||
        serverJob.rollbackPlan != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('word_audio_repair_title', lang)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _infoCard(
              theme: theme,
              icon: Icons.info_outline,
              text: AppStrings.get('word_audio_repair_intro', lang),
            ),
            const SizedBox(height: 12),
            _infoCard(
              theme: theme,
              icon: Icons.shield_outlined,
              text: AppStrings.get('word_audio_repair_local_only', lang),
            ),
            const SizedBox(height: 16),
            if (_selectedWord == null)
              _buildWordSearch(theme, lang, job)
            else ...[
              _buildSelectedWord(theme, lang, job, serverJob),
              const SizedBox(height: 12),
              _buildPronunciationInputs(theme, lang, inputLocked),
              const SizedBox(height: 8),
              Text(
                AppStrings.get('word_audio_repair_ipa_guidance', lang),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 16),
              _buildWorkflow(
                theme,
                lang,
                job,
                serverOperationLocked:
                    serverJob.isBusy ||
                    serverJob.replacementPlan != null ||
                    serverJob.rollbackPlan != null,
              ),
              if (job.plan != null &&
                  (job.staged == null || job.applied != null)) ...[
                const SizedBox(height: 16),
                _buildServerWorkflow(theme, lang, job, serverJob),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required ThemeData theme,
    required IconData icon,
    required String text,
  }) {
    return Card(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
          ],
        ),
      ),
    );
  }

  Widget _buildWordSearch(
    ThemeData theme,
    String lang,
    WordAudioRepairJobState job,
  ) {
    final hasQuery = _searchController.text.trim().isNotEmpty;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              enabled: !job.isBusy,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                labelText: AppStrings.get(
                  'word_audio_repair_search_label',
                  lang,
                ),
                hintText: AppStrings.get('word_audio_repair_search_hint', lang),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ),
            if (hasQuery && !_isSearching && _searchResults.isEmpty) ...[
              const SizedBox(height: 12),
              Text(
                AppStrings.get('word_audio_repair_search_empty', lang),
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (_searchResults.isNotEmpty) ...[
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _searchResults.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final word = _searchResults[index];
                  final pronunciation = word.pronunciation?.trim();
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () => _selectWord(word),
                    title: Text(word.english),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (pronunciation != null && pronunciation.isNotEmpty)
                          Text(pronunciation),
                        Text(word.chineseMeanings),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedWord(
    ThemeData theme,
    String lang,
    WordAudioRepairJobState job,
    WordAudioServerReplaceJobState serverJob,
  ) {
    final word = _selectedWord!;
    final pronunciation = word.pronunciation?.trim();
    final canChange =
        !job.isBusy &&
        !serverJob.isBusy &&
        job.staged == null &&
        job.applied == null &&
        serverJob.replacementPlan == null &&
        serverJob.rollbackPlan == null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get('word_audio_repair_selected_word', lang),
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 6),
            Text(word.english, style: theme.textTheme.headlineSmall),
            if (pronunciation != null && pronunciation.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(pronunciation, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 4),
            Text(word.chineseMeanings, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: canChange ? _changeWord : null,
                icon: const Icon(Icons.swap_horiz),
                label: Text(
                  AppStrings.get('word_audio_repair_change_word', lang),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPronunciationInputs(
    ThemeData theme,
    String lang,
    bool inputLocked,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _partOfSpeechController,
              enabled: !inputLocked,
              onChanged: _onRepairInputChanged,
              maxLength: 80,
              decoration: InputDecoration(
                labelText: AppStrings.get(
                  'word_audio_repair_part_of_speech_label',
                  lang,
                ),
                hintText: AppStrings.get(
                  'word_audio_repair_part_of_speech_hint',
                  lang,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ipaController,
              enabled: !inputLocked,
              onChanged: _onRepairInputChanged,
              maxLength: 120,
              decoration: InputDecoration(
                labelText: AppStrings.get(
                  'word_audio_repair_target_ipa_label',
                  lang,
                ),
                hintText: AppStrings.get(
                  'word_audio_repair_target_ipa_hint',
                  lang,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              enabled: !inputLocked,
              onChanged: _onRepairInputChanged,
              maxLines: 3,
              maxLength: 300,
              decoration: InputDecoration(
                labelText: AppStrings.get('word_audio_repair_note_label', lang),
                hintText: AppStrings.get('word_audio_repair_note_hint', lang),
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflow(
    ThemeData theme,
    String lang,
    WordAudioRepairJobState job, {
    required bool serverOperationLocked,
  }) {
    final plan = job.plan;
    final staged = job.staged;
    final applied = job.applied;
    final progress = job.progress;
    final widgets = <Widget>[];

    if (job.failure != null) {
      widgets.add(_buildFailureCard(theme, lang, job.failure!));
      widgets.add(const SizedBox(height: 12));
    }

    if (plan == null) {
      widgets.add(
        FilledButton.icon(
          onPressed: job.isBusy || serverOperationLocked ? null : _preparePlan,
          icon: job.stage == WordAudioRepairJobStage.planning
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.fact_check_outlined),
          label: Text(AppStrings.get('word_audio_repair_review_plan', lang)),
        ),
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widgets,
      );
    }

    widgets.add(_buildPlanCard(theme, lang, plan));
    widgets.add(const SizedBox(height: 12));

    if (job.stage == WordAudioRepairJobStage.generating) {
      widgets.add(
        _buildRunningCard(
          theme,
          AppStrings.get(
            'word_audio_repair_generating',
            lang,
            params: {
              'attempt': (progress?.attempt ?? 1).toString(),
              'max': (progress?.maxAttempts ?? plan.maxAttempts).toString(),
            },
          ),
        ),
      );
      if (job.canCancel) {
        widgets.add(const SizedBox(height: 12));
        widgets.add(
          OutlinedButton.icon(
            onPressed: job.cancelRequested
                ? null
                : () => ref.read(wordAudioRepairJobProvider.notifier).cancel(),
            icon: const Icon(Icons.cancel_outlined),
            label: Text(
              AppStrings.get('word_audio_repair_cancel_generation', lang),
            ),
          ),
        );
      }
    } else if (staged == null) {
      widgets.add(
        FilledButton.icon(
          onPressed: job.isBusy || serverOperationLocked
              ? null
              : () => ref
                    .read(wordAudioRepairJobProvider.notifier)
                    .generateStagedAudio(),
          icon: const Icon(Icons.auto_awesome_outlined),
          label: Text(AppStrings.get('word_audio_repair_generate', lang)),
        ),
      );
    }

    if (staged != null && applied == null) {
      widgets.add(const SizedBox(height: 12));
      widgets.add(
        _buildStagedCard(
          theme,
          lang,
          staged,
          job,
          serverOperationLocked: serverOperationLocked,
        ),
      );
    }

    if (applied != null) {
      widgets.add(const SizedBox(height: 12));
      widgets.add(
        _buildAppliedCard(
          theme,
          lang,
          applied,
          job,
          serverOperationLocked: serverOperationLocked,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  Widget _buildPlanCard(
    ThemeData theme,
    String lang,
    WordAudioRepairPlan plan,
  ) {
    final cacheKey = plan.hasExistingFile
        ? plan.existingFileIsValid
              ? 'word_audio_repair_plan_existing_valid'
              : 'word_audio_repair_plan_existing_invalid'
        : 'word_audio_repair_plan_existing_missing';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get('word_audio_repair_plan_title', lang),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.get(
                'word_audio_repair_plan_calls',
                lang,
                params: {
                  'calls': plan.normalCalls.toString(),
                  'attempts': plan.maxAttempts.toString(),
                },
              ),
            ),
            const SizedBox(height: 6),
            Text(AppStrings.get(cacheKey, lang)),
            const SizedBox(height: 12),
            Text(
              AppStrings.get('word_audio_repair_plan_instruction', lang),
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            SelectableText(plan.instruction, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildRunningCard(ThemeData theme, String text) {
    return Card(
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
            Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
          ],
        ),
      ),
    );
  }

  Widget _buildStagedCard(
    ThemeData theme,
    String lang,
    WordAudioRepairStagedAudio staged,
    WordAudioRepairJobState job, {
    required bool serverOperationLocked,
  }) {
    return Card(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get('word_audio_repair_staged_title', lang),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.get(
                'word_audio_repair_staged_desc',
                lang,
                params: {
                  'calls': staged.apiCalls.toString(),
                  'bytes': staged.audioBytes.length.toString(),
                },
              ),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: job.isBusy || serverOperationLocked
                      ? null
                      : () => _previewCurrent(lang),
                  icon: const Icon(Icons.volume_down_outlined),
                  label: Text(
                    AppStrings.get('word_audio_repair_preview_current', lang),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: job.isBusy || serverOperationLocked
                      ? null
                      : () => _previewStaged(staged, lang),
                  icon: const Icon(Icons.volume_up_outlined),
                  label: Text(
                    AppStrings.get('word_audio_repair_preview_staged', lang),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (job.stage == WordAudioRepairJobStage.applying)
              _buildRunningCard(
                theme,
                AppStrings.get('word_audio_repair_applying', lang),
              )
            else ...[
              FilledButton.icon(
                onPressed: job.isBusy || serverOperationLocked
                    ? null
                    : _applyStagedAudio,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(AppStrings.get('word_audio_repair_apply', lang)),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: job.isBusy || serverOperationLocked
                    ? null
                    : () => ref
                          .read(wordAudioRepairJobProvider.notifier)
                          .discardStagedAudio(),
                icon: const Icon(Icons.delete_outline),
                label: Text(
                  AppStrings.get('word_audio_repair_discard_staged', lang),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppliedCard(
    ThemeData theme,
    String lang,
    WordAudioRepairApplyResult applied,
    WordAudioRepairJobState job, {
    required bool serverOperationLocked,
  }) {
    final restored = job.restored != null;
    final titleKey = restored
        ? 'word_audio_repair_restored_title'
        : 'word_audio_repair_applied_title';
    final descriptionKey = restored
        ? 'word_audio_repair_restored_desc'
        : applied.replacedExistingAudio
        ? 'word_audio_repair_applied_with_backup'
        : 'word_audio_repair_applied_without_backup';

    return Card(
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.55),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get(titleKey, lang),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.get(descriptionKey, lang),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: job.isBusy || serverOperationLocked
                      ? null
                      : () => _previewCurrent(lang),
                  icon: const Icon(Icons.volume_up_outlined),
                  label: Text(
                    AppStrings.get('word_audio_repair_preview_current', lang),
                  ),
                ),
                if (applied.backupFile != null && !restored)
                  OutlinedButton.icon(
                    onPressed: job.isBusy || serverOperationLocked
                        ? null
                        : _restorePreviousLocalAudio,
                    icon: const Icon(Icons.restore),
                    label: Text(
                      AppStrings.get('word_audio_repair_restore', lang),
                    ),
                  ),
              ],
            ),
            if (job.stage == WordAudioRepairJobStage.restoring) ...[
              const SizedBox(height: 12),
              _buildRunningCard(
                theme,
                AppStrings.get('word_audio_repair_restoring', lang),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: job.isBusy ? null : _startAnotherRepair,
              icon: const Icon(Icons.add),
              label: Text(AppStrings.get('word_audio_repair_start_new', lang)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerWorkflow(
    ThemeData theme,
    String lang,
    WordAudioRepairJobState localJob,
    WordAudioServerReplaceJobState serverJob,
  ) {
    final localPlan = localJob.plan!;
    final replacement = serverJob.replacementPlan;
    final rollback = serverJob.rollbackPlan;
    final hasActiveLocalCandidate =
        (localJob.applied != null && localJob.restored == null) ||
        (localJob.staged == null && localPlan.existingFileIsValid);
    final canPrepareReplacement =
        hasActiveLocalCandidate &&
        localJob.restored == null &&
        !localJob.isBusy &&
        !serverJob.isBusy;
    final canPrepareRollback =
        !localJob.isBusy &&
        !serverJob.isBusy &&
        serverJob.stage != WordAudioServerReplaceJobStage.replacementReady &&
        serverJob.stage != WordAudioServerReplaceJobStage.rollbackReady &&
        serverJob.stage !=
            WordAudioServerReplaceJobStage.interactiveSudoRequired &&
        serverJob.stage !=
            WordAudioServerReplaceJobStage.interactivePublisherOpened;
    final shouldShowDiagnostics =
        serverJob.diagnosticOutput?.isNotEmpty == true &&
        (serverJob.failure != null ||
            serverJob.stage ==
                WordAudioServerReplaceJobStage.interactiveSudoRequired ||
            serverJob.stage ==
                WordAudioServerReplaceJobStage.interactivePublisherOpened);
    final children = <Widget>[
      Text(
        AppStrings.get('word_audio_server_replace_title', lang),
        style: theme.textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      Text(
        AppStrings.get('word_audio_server_replace_intro', lang),
        style: theme.textTheme.bodySmall,
      ),
      const SizedBox(height: 12),
      Text(
        AppStrings.get(
          _currentLocalCandidatePreviewed
              ? 'word_audio_server_replace_local_reviewed'
              : 'word_audio_server_replace_local_review_needed',
          lang,
        ),
        style: theme.textTheme.bodySmall?.copyWith(
          color: _currentLocalCandidatePreviewed
              ? Colors.green
              : theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: hasActiveLocalCandidate && !serverJob.isBusy
                ? () => _previewCurrent(lang)
                : null,
            icon: const Icon(Icons.volume_up_outlined),
            label: Text(
              AppStrings.get('word_audio_server_replace_preview_local', lang),
            ),
          ),
          if (replacement == null && rollback == null)
            FilledButton.icon(
              onPressed:
                  canPrepareReplacement && _currentLocalCandidatePreviewed
                  ? _prepareServerReplacement
                  : null,
              icon: const Icon(Icons.compare_arrows_outlined),
              label: Text(
                AppStrings.get('word_audio_server_replace_compare', lang),
              ),
            ),
        ],
      ),
    ];

    if (!hasActiveLocalCandidate) {
      children.add(const SizedBox(height: 12));
      children.add(
        Text(
          AppStrings.get('word_audio_server_replace_no_local_candidate', lang),
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange),
        ),
      );
    }

    if (serverJob.failure != null) {
      children.add(const SizedBox(height: 12));
      children.add(_buildServerFailureCard(theme, lang, serverJob.failure!));
    }
    if (serverJob.notice != null) {
      children.add(const SizedBox(height: 12));
      children.add(
        Text(
          AppStrings.get(
            'word_audio_server_replace_interactive_not_completed',
            lang,
          ),
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange),
        ),
      );
    }
    if (shouldShowDiagnostics) {
      children.add(const SizedBox(height: 12));
      children.add(
        _buildServerDiagnosticCard(theme, lang, serverJob.diagnosticOutput!),
      );
    }

    if (serverJob.isBusy) {
      children.add(const SizedBox(height: 12));
      children.add(
        _buildRunningCard(theme, _serverStageText(serverJob.stage, lang)),
      );
    }

    if (serverJob.stage == WordAudioServerReplaceJobStage.replacementReady &&
        replacement != null) {
      children.add(const SizedBox(height: 12));
      children.add(
        _buildReplacementPlanCard(theme, lang, replacement, serverJob),
      );
    } else if (serverJob.stage ==
            WordAudioServerReplaceJobStage.alreadyPublished &&
        replacement != null) {
      children.add(const SizedBox(height: 12));
      children.add(
        _serverInfoCard(
          theme: theme,
          icon: Icons.verified_outlined,
          text: AppStrings.get(
            'word_audio_server_replace_already_current',
            lang,
          ),
          color: Colors.green,
        ),
      );
    } else if (serverJob.stage ==
            WordAudioServerReplaceJobStage.replacementSucceeded &&
        replacement != null) {
      children.add(const SizedBox(height: 12));
      children.add(
        _serverInfoCard(
          theme: theme,
          icon: Icons.cloud_done_outlined,
          text: AppStrings.get(
            'word_audio_server_replace_succeeded',
            lang,
            params: {
              'backup':
                  serverJob.result?.serverBackupId ?? replacement.operationId,
            },
          ),
          color: Colors.green,
        ),
      );
      children.add(const SizedBox(height: 8));
      children.add(
        OutlinedButton.icon(
          onPressed: () =>
              _previewServerAudio(replacement.localCandidateBytes, lang),
          icon: const Icon(Icons.volume_up_outlined),
          label: Text(
            AppStrings.get('word_audio_server_replace_preview_published', lang),
          ),
        ),
      );
    } else if (serverJob.stage ==
            WordAudioServerReplaceJobStage.rollbackReady &&
        rollback != null) {
      children.add(const SizedBox(height: 12));
      children.add(_buildRollbackPlanCard(theme, lang, rollback, serverJob));
    } else if (serverJob.stage ==
            WordAudioServerReplaceJobStage.rollbackSucceeded &&
        rollback != null) {
      children.add(const SizedBox(height: 12));
      children.add(
        _serverInfoCard(
          theme: theme,
          icon: Icons.restore_outlined,
          text: AppStrings.get(
            'word_audio_server_rollback_succeeded',
            lang,
            params: {
              'backup':
                  serverJob.result?.serverBackupId ?? rollback.rollbackBackupId,
            },
          ),
          color: Colors.green,
        ),
      );
    } else if (serverJob.stage ==
        WordAudioServerReplaceJobStage.interactiveSudoRequired) {
      children.add(const SizedBox(height: 12));
      children.add(
        _serverInfoCard(
          theme: theme,
          icon: Icons.password_outlined,
          text: AppStrings.get('word_audio_server_replace_sudo_required', lang),
          color: Colors.orange,
        ),
      );
      children.add(const SizedBox(height: 8));
      children.add(
        FilledButton.icon(
          onPressed: serverJob.isBusy
              ? null
              : () => ref
                    .read(wordAudioServerReplaceJobProvider.notifier)
                    .openInteractivePublisher(),
          icon: const Icon(Icons.terminal_outlined),
          label: Text(
            AppStrings.get('word_audio_server_replace_open_interactive', lang),
          ),
        ),
      );
    } else if (serverJob.stage ==
        WordAudioServerReplaceJobStage.interactivePublisherOpened) {
      children.add(const SizedBox(height: 12));
      children.add(
        _serverInfoCard(
          theme: theme,
          icon: Icons.terminal_outlined,
          text: AppStrings.get(
            'word_audio_server_replace_interactive_opened',
            lang,
          ),
          color: Colors.orange,
        ),
      );
      children.add(const SizedBox(height: 8));
      children.add(
        FilledButton.icon(
          onPressed: () => ref
              .read(wordAudioServerReplaceJobProvider.notifier)
              .confirmInteractiveResult(),
          icon: const Icon(Icons.verified_outlined),
          label: Text(
            AppStrings.get('word_audio_server_replace_check_interactive', lang),
          ),
        ),
      );
    }

    if (canPrepareRollback ||
        serverJob.stage ==
            WordAudioServerReplaceJobStage.replacementSucceeded ||
        serverJob.stage == WordAudioServerReplaceJobStage.alreadyPublished ||
        serverJob.stage == WordAudioServerReplaceJobStage.rollbackSucceeded) {
      children.add(const SizedBox(height: 12));
      children.add(
        OutlinedButton.icon(
          onPressed: serverJob.isBusy ? null : _prepareServerRollback,
          icon: const Icon(Icons.history_outlined),
          label: Text(
            AppStrings.get('word_audio_server_rollback_prepare', lang),
          ),
        ),
      );
    }

    if (!serverJob.isBusy &&
        (replacement != null || rollback != null) &&
        serverJob.stage !=
            WordAudioServerReplaceJobStage.interactiveSudoRequired &&
        serverJob.stage !=
            WordAudioServerReplaceJobStage.interactivePublisherOpened) {
      children.add(const SizedBox(height: 8));
      children.add(
        TextButton.icon(
          onPressed: _discardServerPlan,
          icon: const Icon(Icons.close_outlined),
          label: Text(
            AppStrings.get('word_audio_server_replace_discard_plan', lang),
          ),
        ),
      );
    }

    return Card(
      color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.38),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildReplacementPlanCard(
    ThemeData theme,
    String lang,
    WordAudioServerReplacementPlan plan,
    WordAudioServerReplaceJobState serverJob,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('word_audio_server_replace_plan_title', lang),
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.get(
              'word_audio_server_replace_plan_desc',
              lang,
              params: {
                'word': plan.word,
                'old_bytes': plan.remoteCurrentBytesLength.toString(),
                'new_bytes': plan.localCandidateBytesLength.toString(),
                'old_hash': _shortHash(plan.remoteCurrentSha256),
                'new_hash': _shortHash(plan.localCandidateSha256),
              },
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.get('word_audio_server_replace_fixed_url', lang),
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 3),
          SelectableText(
            plan.remoteUri.toString(),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: serverJob.isBusy
                    ? null
                    : () => _previewServerAudio(plan.remoteCurrentBytes, lang),
                icon: const Icon(Icons.volume_down_outlined),
                label: Text(
                  AppStrings.get(
                    'word_audio_server_replace_preview_server',
                    lang,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: serverJob.isBusy ? null : _prepareServerReplacement,
                icon: const Icon(Icons.refresh_outlined),
                label: Text(
                  AppStrings.get(
                    'word_audio_server_replace_refresh_compare',
                    lang,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: serverJob.isBusy
                    ? null
                    : () => _confirmAndReplaceServer(plan, lang),
                icon: const Icon(Icons.cloud_upload_outlined),
                label: Text(
                  AppStrings.get('word_audio_server_replace_action', lang),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRollbackPlanCard(
    ThemeData theme,
    String lang,
    WordAudioServerRollbackPlan plan,
    WordAudioServerReplaceJobState serverJob,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('word_audio_server_rollback_plan_title', lang),
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.get(
              'word_audio_server_rollback_plan_desc',
              lang,
              params: {
                'backup': plan.serverBackupId,
                'active_hash': _shortHash(plan.currentRemoteSha256),
                'restore_hash': _shortHash(plan.restoreSha256),
              },
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          SelectableText(
            plan.remoteUri.toString(),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: serverJob.isBusy
                    ? null
                    : () => _previewServerAudio(plan.currentRemoteBytes, lang),
                icon: const Icon(Icons.volume_up_outlined),
                label: Text(
                  AppStrings.get(
                    'word_audio_server_replace_preview_server',
                    lang,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: serverJob.isBusy
                    ? null
                    : () => _confirmAndRollbackServer(plan, lang),
                icon: const Icon(Icons.restore_outlined),
                label: Text(
                  AppStrings.get('word_audio_server_rollback_action', lang),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serverInfoCard({
    required ThemeData theme,
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }

  Widget _buildServerFailureCard(
    ThemeData theme,
    String lang,
    WordAudioServerReplaceFailure failure,
  ) {
    return _serverInfoCard(
      theme: theme,
      icon: Icons.error_outline,
      text: AppStrings.get(_serverFailureKey(failure), lang),
      color: theme.colorScheme.error,
    );
  }

  Widget _buildServerDiagnosticCard(
    ThemeData theme,
    String lang,
    String diagnostic,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 10),
        leading: const Icon(Icons.receipt_long_outlined),
        title: Text(
          AppStrings.get('word_audio_server_replace_diagnostics_title', lang),
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Text(
          AppStrings.get('word_audio_server_replace_diagnostics_desc', lang),
          style: theme.textTheme.bodySmall,
        ),
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 230),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.45,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                diagnostic,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _copyServerDiagnostic(diagnostic, lang),
              icon: const Icon(Icons.copy_outlined),
              label: Text(
                AppStrings.get(
                  'word_audio_server_replace_diagnostics_copy',
                  lang,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyServerDiagnostic(String diagnostic, String lang) async {
    try {
      await Clipboard.setData(ClipboardData(text: diagnostic));
    } catch (_) {
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.get('word_audio_server_replace_diagnostics_copied', lang),
        ),
      ),
    );
  }

  String _serverStageText(WordAudioServerReplaceJobStage stage, String lang) {
    final key = switch (stage) {
      WordAudioServerReplaceJobStage.preparingReplacement =>
        'word_audio_server_replace_stage_comparing',
      WordAudioServerReplaceJobStage.replacing =>
        'word_audio_server_replace_stage_replacing',
      WordAudioServerReplaceJobStage.preparingRollback =>
        'word_audio_server_replace_stage_checking_rollback',
      WordAudioServerReplaceJobStage.rollingBack =>
        'word_audio_server_replace_stage_rolling_back',
      WordAudioServerReplaceJobStage.checkingInteractiveResult =>
        'word_audio_server_replace_stage_checking_result',
      _ => 'word_audio_server_replace_stage_working',
    };
    return AppStrings.get(key, lang);
  }

  String _serverFailureKey(WordAudioServerReplaceFailure failure) {
    return switch (failure) {
      WordAudioServerReplaceFailure.unsupportedPlatform =>
        'word_audio_server_replace_error_unsupported',
      WordAudioServerReplaceFailure.localCandidateMissing =>
        'word_audio_server_replace_error_local_missing',
      WordAudioServerReplaceFailure.localCandidateInvalid =>
        'word_audio_server_replace_error_local_invalid',
      WordAudioServerReplaceFailure.serverNotConfigured =>
        'word_audio_server_replace_error_server_not_configured',
      WordAudioServerReplaceFailure.serverAddressInvalid =>
        'word_audio_server_replace_error_server_address_invalid',
      WordAudioServerReplaceFailure.remoteAudioMissing =>
        'word_audio_server_replace_error_remote_missing',
      WordAudioServerReplaceFailure.remoteAudioInvalid =>
        'word_audio_server_replace_error_remote_invalid',
      WordAudioServerReplaceFailure.remoteUnavailable =>
        'word_audio_server_replace_error_remote_unavailable',
      WordAudioServerReplaceFailure.remoteChanged =>
        'word_audio_server_replace_error_remote_changed',
      WordAudioServerReplaceFailure.serverAddressChanged =>
        'word_audio_server_replace_error_server_address_changed',
      WordAudioServerReplaceFailure.rollbackUnavailable =>
        'word_audio_server_replace_error_rollback_unavailable',
      WordAudioServerReplaceFailure.publishFailed =>
        'word_audio_server_replace_error_publish_failed',
      WordAudioServerReplaceFailure.publishMayHaveChanged =>
        'word_audio_server_replace_error_publish_may_have_changed',
      WordAudioServerReplaceFailure.unknown =>
        'word_audio_server_replace_error_unknown',
    };
  }

  String _shortHash(String value) => value.length <= 16
      ? value
      : '${value.substring(0, 12)}…${value.substring(value.length - 4)}';

  Widget _buildFailureCard(
    ThemeData theme,
    String lang,
    WordAudioRepairFailure failure,
  ) {
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppStrings.get(_failureKey(failure), lang),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _failureKey(WordAudioRepairFailure failure) {
    return switch (failure) {
      WordAudioRepairFailure.invalidWord =>
        'word_audio_repair_error_invalid_word',
      WordAudioRepairFailure.missingApiKey =>
        'word_audio_repair_error_missing_api_key',
      WordAudioRepairFailure.missingWorkspaceId =>
        'word_audio_repair_error_missing_workspace',
      WordAudioRepairFailure.synthesisFailed =>
        'word_audio_repair_error_synthesis_failed',
      WordAudioRepairFailure.invalidStagedAudio =>
        'word_audio_repair_error_invalid_staged_audio',
      WordAudioRepairFailure.stagedAudioMissing =>
        'word_audio_repair_error_staged_missing',
      WordAudioRepairFailure.applyFailed =>
        'word_audio_repair_error_apply_failed',
      WordAudioRepairFailure.restoreUnavailable =>
        'word_audio_repair_error_restore_unavailable',
      WordAudioRepairFailure.restoreFailed =>
        'word_audio_repair_error_restore_failed',
      WordAudioRepairFailure.cancelled => 'word_audio_repair_error_cancelled',
      WordAudioRepairFailure.unknown => 'word_audio_repair_error_unknown',
    };
  }
}
