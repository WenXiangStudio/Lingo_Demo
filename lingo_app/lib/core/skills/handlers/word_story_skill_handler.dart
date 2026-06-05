import '../../../data/ai/ai_service.dart';
import '../../../data/models/ai_models.dart';
import '../../../data/repositories/repositories.dart';
import '../skill_definition.dart';
import '../skill_handler.dart';

class WordStorySkillHandler implements SkillHandler {
  final WordListRepository _wordListRepository;
  final SettingsRepository _settingsRepository;

  WordStorySkillHandler({
    required WordListRepository wordListRepository,
    required SettingsRepository settingsRepository,
  }) : _wordListRepository = wordListRepository,
       _settingsRepository = settingsRepository;

  @override
  Future<SkillRunResult> run(
    Map<String, Object?> inputs,
    SkillRunContext context,
  ) async {
    final listId = inputs['list_id'] as int?;
    if (listId == null) {
      throw const SkillException('skill_error_missing_list');
    }

    final requestedCount = inputs['word_count'] as int? ?? 8;
    final wordCount = requestedCount.clamp(3, 12);

    context.onProgress(
      const SkillRunProgress(messageKey: 'skill_progress_loading_words'),
    );
    final words = await _wordListRepository.getWordsForList(listId);
    context.throwIfCancelled();

    if (words.isEmpty) {
      throw const SkillException('skill_error_no_words');
    }

    final selectedWordEntries = words.take(wordCount).toList();
    final selectedWords = selectedWordEntries
        .map((word) => word.english)
        .toList();
    if (selectedWords.length < 3) {
      throw const SkillException('skill_error_need_three_words');
    }

    context.onProgress(
      SkillRunProgress(
        messageKey: 'skill_progress_generating_story',
        total: selectedWords.length,
        completed: 0,
      ),
    );

    final aiService = AiService(_settingsRepository);
    final provider = await aiService.getProvider();
    context.throwIfCancelled();
    final story = await provider.generateWordStory(selectedWords);
    context.throwIfCancelled();
    final translationHighlightTerms = _translationHighlightTerms(
      story,
      selectedWords,
      selectedWordEntries,
    );

    return SkillRunResult(
      skillId: 'word_story',
      summaryKey: 'skill_result_word_story_summary',
      summaryParams: {'count': selectedWords.length.toString()},
      sections: [
        SkillResultSection(
          titleKey: 'skill_result_words_used',
          lines: selectedWords.map(SkillResultLine.raw).toList(),
        ),
        SkillResultSection(
          titleKey: 'skill_result_story',
          bodyText: story.title,
          lines: [SkillResultLine.raw(story.english)],
          highlightTerms: selectedWords,
        ),
        SkillResultSection(
          titleKey: 'skill_result_translation',
          lines: [SkillResultLine.raw(story.chineseTranslation)],
          highlightTerms: translationHighlightTerms,
        ),
      ],
    );
  }

  static List<String> _translationHighlightTerms(
    WordStory story,
    List<String> selectedWords,
    List<dynamic> fallbackWords,
  ) {
    final selectedWordSet = selectedWords
        .map((word) => word.trim().toLowerCase())
        .where((word) => word.isNotEmpty)
        .toSet();
    final terms = <String>{};
    final alignedWords = <String>{};

    for (final alignment in story.translationAlignments) {
      final word = alignment.word.trim().toLowerCase();
      final span = alignment.chineseSpan.trim();
      if (!selectedWordSet.contains(word)) continue;
      if (!story.chineseTranslation.contains(span)) continue;
      terms.add(span);
      alignedWords.add(word);
    }

    if (alignedWords.length < selectedWordSet.length) {
      final fallbackEntries = fallbackWords
          .where((word) {
            final english = (word.english as String).trim().toLowerCase();
            return !alignedWords.contains(english);
          })
          .toList(growable: false);
      terms.addAll(_meaningTerms(fallbackEntries));
    }
    return terms.toList(growable: false);
  }

  static List<String> _meaningTerms(List<dynamic> words) {
    final terms = <String>{};
    for (final word in words) {
      final english = (word.english as String).trim().toLowerCase();
      final meanings = word.chineseMeanings as String;
      final parts = meanings
          .replaceAll(RegExp(r'\s+'), '')
          .split(RegExp(r'[；;，,、/()（）]'));
      for (final part in parts) {
        final cleaned = _cleanMeaningPart(part);
        _addMeaningTerm(terms, cleaned);
      }
      for (final term in _knownChineseVariants[english] ?? const <String>[]) {
        _addMeaningTerm(terms, term);
      }
    }
    return terms.toList(growable: false);
  }

  static String _cleanMeaningPart(String text) {
    return text
        .replaceFirst(RegExp(r'^[a-zA-Z&]+\.'), '')
        .replaceAll(RegExp(r'^[a-zA-Z]+'), '')
        .trim();
  }

  static void _addMeaningTerm(Set<String> terms, String term) {
    final cleaned = term.trim();
    if (cleaned.isEmpty) return;
    terms.add(cleaned);
  }

  static const Map<String, List<String>> _knownChineseVariants = {
    'close': ['关', '闭', '关闭', '关上', '结束', '接近', '靠近', '近', '亲近', '亲密'],
    'bean': ['豆', '豆子', '豆类', '蚕豆'],
    'extension': ['延长', '延伸', '延伸部分', '扩建', '扩展', '伸展', '分机', '分机号码'],
  };
}
