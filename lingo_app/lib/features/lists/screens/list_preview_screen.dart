import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/services/tts_providers.dart';
import '../../../data/database/app_database.dart';
import '../../../data/providers.dart';
import '../../review_center/providers/review_center_provider.dart';
import '../providers/list_provider.dart';

class ListPreviewScreen extends ConsumerStatefulWidget {
  final int listId;
  final String returnPath;

  const ListPreviewScreen({
    super.key,
    required this.listId,
    this.returnPath = '/lists',
  });

  @override
  ConsumerState<ListPreviewScreen> createState() => _ListPreviewScreenState();
}

class _ListPreviewScreenState extends ConsumerState<ListPreviewScreen> {
  bool _autoShuffled = false;

  @override
  void initState() {
    super.initState();
    // Per design: "每次打开 list 都会使其在 list 内重新乱序" — auto-shuffle on
    // entry, no button required. Use a postFrame callback so providers are
    // ready before we call into them.
    WidgetsBinding.instance.addPostFrameCallback((_) => _runAutoShuffle());
  }

  Future<void> _runAutoShuffle() async {
    if (_autoShuffled) return;
    _autoShuffled = true;
    final controller = ref.read(shuffleControllerProvider(widget.listId));
    await controller.autoShuffle();
  }

  String _previewRoute() => widget.returnPath == '/'
      ? '/list/${widget.listId}?from=home'
      : '/list/${widget.listId}';

  String _practiceRoute(String suffix) =>
      '/practice/${widget.listId}/$suffix?returnPath=${Uri.encodeComponent(_previewRoute())}&exampleCueTracking=true';

  Future<void> _onMenuSelected(String value) async {
    switch (value) {
      case 'errors':
        context.push('/error-words/${widget.listId}');
      case 'forgotten':
        context.push('/forgotten/${widget.listId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(listDetailProvider(widget.listId));
    final wordsAsync = ref.watch(listWordsProvider(widget.listId));
    final lang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: widget.returnPath == '/'
              ? AppStrings.get('back_home', lang)
              : AppStrings.get('back_to_lists', lang),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(widget.returnPath);
            }
          },
        ),
        title: listAsync.when(
          data: (list) => Text(list?.name ?? AppStrings.get('word_list', lang)),
          loading: () => Text(AppStrings.get('loading', lang)),
          error: (_, _) => Text(AppStrings.get('error', lang)),
        ),
        actions: [
          if (listAsync.valueOrNull?.isPassed == true)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Chip(
                avatar: const Icon(Icons.check_circle, size: 18),
                label: Text(AppStrings.get('passed_badge', lang)),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          PopupMenuButton<String>(
            onSelected: _onMenuSelected,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'errors',
                child: ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: Text(AppStrings.get('error_words_title', lang)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'forgotten',
                child: ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: Text(AppStrings.get('forgotten_words_menu', lang)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: wordsAsync.when(
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
                  AppStrings.get('failed_words', lang),
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
                  onPressed: () =>
                      ref.invalidate(listWordsProvider(widget.listId)),
                  child: Text(AppStrings.get('retry', lang)),
                ),
              ],
            ),
          ),
        ),
        data: (words) {
          if (words.isEmpty) {
            return Center(child: Text(AppStrings.get('no_words', lang)));
          }
          return _buildWordList(context, words, lang);
        },
      ),
    );
  }

  Widget _buildWordList(BuildContext context, List<Word> words, String lang) {
    final isShuffled =
        ref.watch(listDetailProvider(widget.listId)).valueOrNull?.isShuffled ??
        false;
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.push(_practiceRoute('setup')),
              icon: const Icon(Icons.play_arrow),
              label: Text(AppStrings.get('start_practice', lang)),
            ),
          ),
        ),
        if (isShuffled)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Icon(
                  Icons.shuffle,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  AppStrings.get('shuffled_order', lang),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: words.length,
            itemBuilder: (context, index) {
              return _WordCard(
                word: words[index],
                index: index,
                listId: widget.listId,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WordCard extends ConsumerWidget {
  final Word word;
  final int index;
  final int listId;

  const _WordCard({
    required this.word,
    required this.index,
    required this.listId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forgottenIdsAsync = ref.watch(forgottenWordIdsProvider(listId));
    final isForgotten =
        forgottenIdsAsync.valueOrNull?.contains(word.id) ?? false;
    return _WordCardBody(
      word: word,
      index: index,
      listId: listId,
      isForgottenInitial: isForgotten,
    );
  }
}

class _WordCardBody extends ConsumerStatefulWidget {
  final Word word;
  final int index;
  final int listId;
  final bool isForgottenInitial;

  const _WordCardBody({
    required this.word,
    required this.index,
    required this.listId,
    required this.isForgottenInitial,
  });

  @override
  ConsumerState<_WordCardBody> createState() => _WordCardBodyState();
}

class _WordCardBodyState extends ConsumerState<_WordCardBody> {
  // Per design: fuzzy button "default ON" means Chinese is hidden until tap.
  bool _showChinese = false;
  late bool _isForgotten;

  @override
  void initState() {
    super.initState();
    _isForgotten = widget.isForgottenInitial;
  }

  @override
  void didUpdateWidget(covariant _WordCardBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isForgottenInitial != widget.isForgottenInitial) {
      _isForgotten = widget.isForgottenInitial;
    }
  }

  Future<void> _speak(String text, {bool exampleSentence = false}) async {
    final tts = ref.read(ttsServiceProvider);
    final result = exampleSentence
        ? await tts.speakExampleSentence(text)
        : await tts.speakWord(text);
    if (!mounted) return;
    final lang = ref.read(languageProvider);
    if (!result.played) {
      final key = exampleSentence
          ? _exampleAudioErrorKey(result.provider, result.source)
          : _wordAudioErrorKey(result.provider, result.source);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.get(key, lang, params: {'msg': result.message ?? ''}),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    if (result.provider != 'doubao') return;
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

  String _wordAudioErrorKey(String provider, String source) {
    if (provider == 'remote_word_audio') {
      return switch (source) {
        'remote_not_configured' => 'word_audio_server_not_configured',
        'remote_invalid_url' => 'word_audio_server_invalid_url',
        'remote_not_found' => 'word_audio_file_not_found',
        'remote_timeout' => 'word_audio_timeout',
        'remote_invalid_audio' => 'word_audio_invalid_file',
        'blocked' => 'word_audio_busy',
        'not_ready' => 'word_audio_not_ready',
        _ => 'word_audio_unavailable',
      };
    }

    if (provider == 'qwen') {
      return switch (source) {
        'not_configured' => 'tts_qwen_not_configured',
        'api_failed' => 'tts_qwen_api_failed_detail',
        'blocked' => 'word_audio_busy',
        'not_ready' => 'word_audio_not_ready',
        _ => 'word_audio_direct_failed',
      };
    }

    if (provider == 'doubao') {
      return switch (source) {
        'not_configured' => 'word_audio_direct_not_configured',
        'api_disabled_missing_cache' => 'tts_doubao_cache_missing_api_disabled',
        'api_failed' => 'tts_doubao_api_failed',
        'blocked' => 'word_audio_busy',
        'not_ready' => 'word_audio_not_ready',
        _ => 'word_audio_direct_failed',
      };
    }

    return switch (source) {
      'not_configured' => 'word_audio_direct_not_configured',
      'blocked' => 'word_audio_busy',
      'not_ready' => 'word_audio_not_ready',
      _ => 'word_audio_direct_failed',
    };
  }

  String _exampleAudioErrorKey(String provider, String source) {
    if (provider == 'remote_example_audio') {
      return switch (source) {
        'remote_example_not_configured' =>
          'example_audio_server_not_configured',
        'remote_example_invalid_url' => 'example_audio_server_invalid_url',
        'remote_example_not_found' => 'example_audio_file_not_found',
        'remote_example_timeout' => 'example_audio_timeout',
        'remote_example_invalid_audio' => 'example_audio_invalid_file',
        'blocked' => 'word_audio_busy',
        'not_ready' => 'word_audio_not_ready',
        _ => 'example_audio_unavailable',
      };
    }
    return switch (source) {
      'not_configured' => 'example_audio_direct_not_configured',
      'blocked' => 'word_audio_busy',
      'not_ready' => 'word_audio_not_ready',
      _ => 'example_audio_direct_failed',
    };
  }

  Future<void> _confirmAndMarkForgotten() async {
    final lang = ref.read(languageProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.flag, color: Colors.red, size: 32),
        title: Text(AppStrings.get('mark_forgotten', lang)),
        content: Text(AppStrings.get('forgotten_mode_locked', lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppStrings.get('cancel', lang)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppStrings.get('mark_forgotten', lang)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(practiceRepositoryProvider)
        .markWordForgotten(widget.word.id, widget.listId);
    if (!mounted) return;
    setState(() => _isForgotten = true);
    ref.invalidate(forgottenWordIdsProvider(widget.listId));
    ref.invalidate(forgottenWordsProvider(widget.listId));
    ref.invalidate(reviewCenterDataProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = ref.watch(languageProvider);
    final word = widget.word;
    final hasPronunciation =
        word.pronunciation != null && word.pronunciation!.isNotEmpty;
    final hasScenario =
        word.scenarioExample != null && word.scenarioExample!.isNotEmpty;
    final scenarioTranslation =
        word.scenarioTranslation != null && word.scenarioTranslation!.isNotEmpty
        ? word.scenarioTranslation!
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _isForgotten
                        ? Colors.red.withValues(alpha: 0.15)
                        : theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${widget.index + 1}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: _isForgotten
                          ? Colors.red
                          : theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word.english,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (hasPronunciation) ...[
                        const SizedBox(height: 4),
                        Text(
                          '/${word.pronunciation}/',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _WordActionButton(
                            icon: Icons.volume_up,
                            label: AppStrings.get('pronounce', lang),
                            onPressed: () => _speak(word.english),
                          ),
                          _WordActionButton(
                            icon: _showChinese
                                ? Icons.visibility
                                : Icons.visibility_off,
                            label: _showChinese
                                ? AppStrings.get('hide_chinese', lang)
                                : AppStrings.get('show_chinese', lang),
                            onPressed: () =>
                                setState(() => _showChinese = !_showChinese),
                          ),
                          _WordActionButton(
                            icon: Icons.flag,
                            label: _isForgotten
                                ? AppStrings.get('forgotten_label', lang)
                                : AppStrings.get('mark_forgotten_short', lang),
                            onPressed: _isForgotten
                                ? null
                                : _confirmAndMarkForgotten,
                            selected: _isForgotten,
                          ),
                        ],
                      ),
                      if (_showChinese) ...[
                        const SizedBox(height: 10),
                        Text(
                          word.chineseMeanings,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (hasScenario) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiaryContainer
                                .withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: _ScenarioExample(
                            text: word.scenarioExample!,
                            targetWord: word.english,
                            targetChineseMeanings: word.chineseMeanings,
                            chineseTranslation: scenarioTranslation,
                            showChineseMeaning: _showChinese,
                            lang: lang,
                            onSpeak: () => _speak(
                              word.scenarioExample!,
                              exampleSentence: true,
                            ),
                          ),
                        ),
                      ],
                      if (_isForgotten) ...[
                        const SizedBox(height: 6),
                        Chip(
                          avatar: const Icon(Icons.flag, size: 14),
                          label: Text(
                            AppStrings.get('forgotten_label', lang),
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                          side: const BorderSide(color: Colors.red),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WordActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool selected;

  const _WordActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = selected ? Colors.red : theme.colorScheme.primary;

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: onPressed == null ? null : foreground),
      label: Text(label, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        foregroundColor: foreground,
        side: BorderSide(
          color: selected
              ? Colors.red
              : theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
        visualDensity: VisualDensity.compact,
        textStyle: theme.textTheme.labelMedium,
      ),
    );
  }
}

/// Renders the scenario example with the target English word highlighted.
class _ScenarioExample extends StatelessWidget {
  final String text;
  final String targetWord;
  final String targetChineseMeanings;
  final String? chineseTranslation;
  final bool showChineseMeaning;
  final String lang;
  final VoidCallback onSpeak;

  const _ScenarioExample({
    required this.text,
    required this.targetWord,
    required this.targetChineseMeanings,
    required this.chineseTranslation,
    required this.showChineseMeaning,
    required this.lang,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.tertiary;
    final base = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.tertiary.withValues(alpha: 0.85),
    );
    final highlight = base?.copyWith(
      color: accent,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
      decorationColor: accent,
      decorationThickness: 1.5,
    );

    final pattern = RegExp(
      r'\b' + RegExp.escape(targetWord) + r'\b',
      caseSensitive: false,
    );

    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final m in pattern.allMatches(text)) {
      if (m.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, m.start), style: base));
      }
      spans.add(
        TextSpan(text: text.substring(m.start, m.end), style: highlight),
      );
      cursor = m.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: base));
    }
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: base));
    }
    final translationSpans = _translationSpans(
      label: AppStrings.get('scenario_translation_label', lang),
      translation: chineseTranslation,
      targetChineseMeanings: targetChineseMeanings,
      baseStyle: base,
      highlightStyle: highlight,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text.rich(TextSpan(children: spans))),
            const SizedBox(width: 4),
            Tooltip(
              message: AppStrings.get('pronounce_example', lang),
              child: IconButton(
                onPressed: onSpeak,
                icon: const Icon(Icons.volume_up),
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.45),
                  foregroundColor: accent,
                ),
              ),
            ),
          ],
        ),
        if (showChineseMeaning && chineseTranslation != null) ...[
          const SizedBox(height: 2),
          Text.rich(TextSpan(children: translationSpans)),
        ],
      ],
    );
  }

  static List<InlineSpan> _translationSpans({
    required String label,
    required String? translation,
    required String targetChineseMeanings,
    required TextStyle? baseStyle,
    required TextStyle? highlightStyle,
  }) {
    final text = translation ?? '';
    final spans = <InlineSpan>[TextSpan(text: '$label：', style: baseStyle)];
    if (text.isEmpty) return spans;

    final terms = _highlightTerms(
      targetChineseMeanings,
    ).where((term) => text.contains(term)).toList();
    if (terms.isEmpty) {
      spans.add(TextSpan(text: text, style: baseStyle));
      return spans;
    }

    final pattern = RegExp(terms.map(RegExp.escape).join('|'));
    var cursor = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(
          TextSpan(text: text.substring(cursor, match.start), style: baseStyle),
        );
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: highlightStyle,
        ),
      );
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: baseStyle));
    }
    return spans;
  }

  static List<String> _highlightTerms(String chineseMeanings) {
    final withoutPartsOfSpeech = chineseMeanings.replaceAll(
      RegExp(
        r'\b(?:n|v|vt|vi|adj|adv|pron|prep|conj|num|art|abbr|pl|int)\.?\s*',
        caseSensitive: false,
      ),
      ' ',
    );
    final rawTerms = withoutPartsOfSpeech
        .split(RegExp(r'[\s,，;；、/|()（）:：.!！?？]+'))
        .map((term) => term.trim())
        .where((term) => term.isNotEmpty);

    final terms = <String>{};
    for (final raw in rawTerms) {
      final normalized = raw.replaceAll(RegExp(r'^[的地得]+|[的地得]+$'), '');
      if (_containsChinese(normalized)) {
        terms.add(normalized);
        terms.addAll(_commonTranslationVariants(normalized));
      }
      if (raw.endsWith('的') && raw.length > 1) {
        final withoutDe = raw.substring(0, raw.length - 1);
        if (_containsChinese(withoutDe)) {
          terms.add(withoutDe);
          terms.addAll(_commonTranslationVariants(withoutDe));
        }
      }
    }

    return terms.toList()..sort((a, b) {
      final lengthCompare = b.length.compareTo(a.length);
      if (lengthCompare != 0) return lengthCompare;
      return a.compareTo(b);
    });
  }

  static bool _containsChinese(String text) {
    return RegExp(r'[\u4e00-\u9fff]').hasMatch(text);
  }

  static Iterable<String> _commonTranslationVariants(String term) sync* {
    const gradableAdjectiveEndings = {
      '小',
      '大',
      '高',
      '低',
      '长',
      '短',
      '快',
      '慢',
      '好',
      '坏',
      '强',
      '弱',
      '新',
      '旧',
      '热',
      '冷',
      '早',
      '晚',
      '难',
      '易',
    };
    if (term.length < 2) return;
    final lastChar = term.substring(term.length - 1);
    if (!gradableAdjectiveEndings.contains(lastChar)) return;
    yield '很$lastChar';
    yield '非常$lastChar';
    yield '特别$lastChar';
    yield '十分$lastChar';
  }
}
