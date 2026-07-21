import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/ai/ai_service.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/ai_models.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/repositories.dart';
import '../../lists/providers/list_provider.dart';

enum DeepPracticePhase { setup, generating, ready, quiz, feedback, finished }

enum DeepAnswerVerdict { targetCorrect, acceptableAlternative, incorrect }

class DeepQuestion {
  final Word word;
  final int sourceListId;
  final String displayText;
  final String sourceText;
  final String correctAnswer;
  final String chineseHint;
  final List<String> answerOptions;

  const DeepQuestion({
    required this.word,
    required this.sourceListId,
    required this.displayText,
    required this.sourceText,
    required this.correctAnswer,
    required this.chineseHint,
    this.answerOptions = const [],
  });

  DeepQuestion withAnswerOptions(List<String> options) {
    return DeepQuestion(
      word: word,
      sourceListId: sourceListId,
      displayText: displayText,
      sourceText: sourceText,
      correctAnswer: correctAnswer,
      chineseHint: chineseHint,
      answerOptions: List.unmodifiable(options),
    );
  }
}

class DeepAnswerRecord {
  final int questionIndex;
  final int wordId;
  final int sourceListId;
  final String? userAnswer;
  final String correctAnswer;
  final DeepAnswerVerdict verdict;
  final String feedback;

  const DeepAnswerRecord({
    required this.questionIndex,
    required this.wordId,
    required this.sourceListId,
    this.userAnswer,
    required this.correctAnswer,
    required this.verdict,
    this.feedback = '',
  });

  bool get isTargetCorrect => verdict == DeepAnswerVerdict.targetCorrect;

  bool get isAcceptableAlternative =>
      verdict == DeepAnswerVerdict.acceptableAlternative;

  bool get shouldRecordError => verdict == DeepAnswerVerdict.incorrect;
}

class DeepPracticeState {
  final DeepPracticePhase phase;
  final String? mode;
  final List<int> listIds;
  final int? bookId;
  final List<Word> words;
  final Map<int, int> sourceListIds;
  final int generatedCount;
  final int totalToGenerate;
  final String? generationErrorKey;
  final String? generationErrorDetail;
  final List<DeepQuestion> questions;
  final int currentIndex;
  final List<DeepAnswerRecord?> answers;
  final bool isEvaluatingAnswer;
  final String? answerEvaluationErrorKey;
  final String? answerEvaluationErrorDetail;
  final bool isSaving;
  final bool hasSaved;
  final bool collocationOptionValidationEnabled;

  const DeepPracticeState({
    this.phase = DeepPracticePhase.setup,
    this.mode,
    this.listIds = const [],
    this.bookId,
    this.words = const [],
    this.sourceListIds = const {},
    this.generatedCount = 0,
    this.totalToGenerate = 0,
    this.generationErrorKey,
    this.generationErrorDetail,
    this.questions = const [],
    this.currentIndex = 0,
    this.answers = const [],
    this.isEvaluatingAnswer = false,
    this.answerEvaluationErrorKey,
    this.answerEvaluationErrorDetail,
    this.isSaving = false,
    this.hasSaved = false,
    this.collocationOptionValidationEnabled = true,
  });

  int? get primaryListId => listIds.isEmpty ? null : listIds.first;

  DeepQuestion? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  DeepAnswerRecord? get currentAnswer =>
      currentIndex < answers.length ? answers[currentIndex] : null;

  Iterable<DeepAnswerRecord> get answeredRecords => answers.whereType();

  int get totalQuestions => questions.length;
  int get answeredCount => answeredRecords.length;
  int get correctCount =>
      answeredRecords.where((answer) => answer.isTargetCorrect).length;
  int get acceptableAlternativeCount =>
      answeredRecords.where((answer) => answer.isAcceptableAlternative).length;
  int get incorrectCount =>
      answeredRecords.where((answer) => answer.shouldRecordError).length;
  double get accuracy => answeredCount == 0 ? 0 : correctCount / answeredCount;
  bool get hasCollocationFillFallback =>
      mode == 'deep_choice' && questions.any((q) => q.answerOptions.isEmpty);
  bool get collocationOptionsDisabledBySetting =>
      mode == 'deep_choice' && !collocationOptionValidationEnabled;

  DeepPracticeState copyWith({
    DeepPracticePhase? phase,
    String? mode,
    List<int>? listIds,
    int? bookId,
    List<Word>? words,
    Map<int, int>? sourceListIds,
    int? generatedCount,
    int? totalToGenerate,
    String? generationErrorKey,
    String? generationErrorDetail,
    List<DeepQuestion>? questions,
    int? currentIndex,
    List<DeepAnswerRecord?>? answers,
    bool? isEvaluatingAnswer,
    String? answerEvaluationErrorKey,
    String? answerEvaluationErrorDetail,
    bool? isSaving,
    bool? hasSaved,
    bool? collocationOptionValidationEnabled,
    bool clearGenerationError = false,
    bool clearAnswerEvaluationError = false,
  }) {
    return DeepPracticeState(
      phase: phase ?? this.phase,
      mode: mode ?? this.mode,
      listIds: listIds ?? this.listIds,
      bookId: bookId ?? this.bookId,
      words: words ?? this.words,
      sourceListIds: sourceListIds ?? this.sourceListIds,
      generatedCount: generatedCount ?? this.generatedCount,
      totalToGenerate: totalToGenerate ?? this.totalToGenerate,
      generationErrorKey: clearGenerationError
          ? null
          : (generationErrorKey ?? this.generationErrorKey),
      generationErrorDetail: clearGenerationError
          ? null
          : (generationErrorDetail ?? this.generationErrorDetail),
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      isEvaluatingAnswer: isEvaluatingAnswer ?? this.isEvaluatingAnswer,
      answerEvaluationErrorKey: clearAnswerEvaluationError
          ? null
          : (answerEvaluationErrorKey ?? this.answerEvaluationErrorKey),
      answerEvaluationErrorDetail: clearAnswerEvaluationError
          ? null
          : (answerEvaluationErrorDetail ?? this.answerEvaluationErrorDetail),
      isSaving: isSaving ?? this.isSaving,
      hasSaved: hasSaved ?? this.hasSaved,
      collocationOptionValidationEnabled:
          collocationOptionValidationEnabled ??
          this.collocationOptionValidationEnabled,
    );
  }
}

final deepPracticeProvider =
    StateNotifierProvider<DeepPracticeNotifier, DeepPracticeState>((ref) {
      return DeepPracticeNotifier(ref);
    });

class DeepPracticeNotifier extends StateNotifier<DeepPracticeState> {
  static const _collocationContentType = 'collocation_v2';
  static const _sentenceContentType = 'sentence_v2';
  static const _idiomContentType = 'idiom_v1';
  static const _commonDistractorWords = <String>[
    'basic',
    'brief',
    'careful',
    'common',
    'direct',
    'formal',
    'general',
    'heavy',
    'local',
    'major',
    'ordinary',
    'private',
    'public',
    'quick',
    'regular',
    'simple',
    'strong',
    'take',
    'make',
    'give',
    'keep',
    'hold',
    'raise',
    'reach',
  ];

  final Ref _ref;
  final _rng = Random();

  DeepPracticeNotifier(this._ref) : super(const DeepPracticeState());

  Future<void> initSession({
    required List<int> listIds,
    required String mode,
  }) async {
    final uniqueListIds = <int>[];
    for (final listId in listIds) {
      if (!uniqueListIds.contains(listId)) uniqueListIds.add(listId);
    }
    if (uniqueListIds.isEmpty) {
      state = const DeepPracticeState(generationErrorKey: 'deep_scope_invalid');
      return;
    }

    final repo = _ref.read(wordListRepositoryProvider);
    final allLists = await repo.getAllLists();
    final byId = {for (final list in allLists) list.id: list};
    final selectedLists = <WordList>[];
    for (final listId in uniqueListIds) {
      final list = byId[listId];
      if (list == null || !list.isPassed) {
        state = const DeepPracticeState(
          generationErrorKey: 'deep_scope_requires_pass',
        );
        return;
      }
      selectedLists.add(list);
    }

    final bookIds = selectedLists.map((list) => list.bookId).toSet();
    if (bookIds.length != 1) {
      state = const DeepPracticeState(
        generationErrorKey: 'deep_scope_same_book_required',
      );
      return;
    }

    final words = <Word>[];
    final sourceListIds = <int, int>{};
    for (final list in selectedLists) {
      final listWords = await repo.getWordsForList(list.id);
      for (final word in listWords) {
        if (sourceListIds.containsKey(word.id)) continue;
        words.add(word);
        sourceListIds[word.id] = list.id;
      }
    }
    if (words.isEmpty) {
      state = const DeepPracticeState(
        generationErrorKey: 'deep_scope_no_words',
      );
      return;
    }

    state = DeepPracticeState(
      phase: DeepPracticePhase.setup,
      mode: mode,
      listIds: uniqueListIds,
      bookId: bookIds.first,
      words: words,
      sourceListIds: sourceListIds,
      totalToGenerate: words.length,
    );
  }

  Future<void> generateContent() async {
    if (state.phase != DeepPracticePhase.setup &&
        state.phase != DeepPracticePhase.ready) {
      return;
    }
    final mode = state.mode;
    if (mode == null || state.words.isEmpty) return;

    state = state.copyWith(
      phase: DeepPracticePhase.generating,
      generatedCount: 0,
      clearGenerationError: true,
    );

    final contentType = _contentTypeForMode(mode);
    final aiContentRepo = _ref.read(aiContentRepositoryProvider);
    final uncachedWords = <Word>[];
    for (final word in state.words) {
      final cached = await aiContentRepo.getContent(word.id, contentType);
      if (cached == null) uncachedWords.add(word);
    }

    try {
      final validateCollocationOptions = contentType == _collocationContentType
          ? await _ref
                .read(settingsRepositoryProvider)
                .getAiCollocationOptionValidationEnabled()
          : true;
      if (uncachedWords.isNotEmpty) {
        final aiService = AiService(_ref.read(settingsRepositoryProvider));
        final provider = await aiService.getProvider();
        const batchSize = 5;
        for (var i = 0; i < uncachedWords.length; i += batchSize) {
          final batchWords = uncachedWords.skip(i).take(batchSize).toList();
          final batch = batchWords.map((word) => word.english).toList();
          if (contentType == _collocationContentType) {
            final collocations = await provider.generateCollocations(batch);
            await _cacheCollocations(
              aiContentRepo,
              batchWords,
              collocations,
              contentType,
            );
          } else if (contentType == _idiomContentType) {
            final idioms = await provider.generateIdioms(batch);
            await _cacheTextItems(
              aiContentRepo,
              batchWords,
              idioms,
              contentType,
            );
          } else {
            final sentences = await provider.generateSentences(batch);
            await _cacheTextItems(
              aiContentRepo,
              batchWords,
              sentences,
              contentType,
            );
          }
          state = state.copyWith(
            generatedCount: (i + batchWords.length)
                .clamp(0, uncachedWords.length)
                .toInt(),
          );
        }
      }

      var questions = await _buildQuestions(contentType);
      if (contentType == _collocationContentType &&
          validateCollocationOptions &&
          questions.isNotEmpty) {
        questions = await _attachCollocationOptions(questions);
      }
      if (questions.isEmpty) {
        state = state.copyWith(
          phase: DeepPracticePhase.setup,
          generationErrorKey: 'deep_no_generated_content',
        );
        return;
      }

      state = state.copyWith(
        phase: DeepPracticePhase.ready,
        generatedCount: uncachedWords.length,
        questions: questions,
        collocationOptionValidationEnabled: validateCollocationOptions,
      );
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(
        phase: DeepPracticePhase.setup,
        generationErrorKey: error is FormatException
            ? 'deep_ai_response_invalid'
            : 'deep_generation_failed',
        generationErrorDetail: error is FormatException ? null : '$error',
      );
    }
  }

  Future<void> _cacheCollocations(
    AiContentRepository repo,
    List<Word> batchWords,
    List<Collocation> allCollocations,
    String contentType,
  ) async {
    for (final word in batchWords) {
      final matched = allCollocations.where((collocation) {
        final source = collocation.sourceWord.trim().toLowerCase();
        if (source.isNotEmpty) return source == word.english.toLowerCase();
        return _containsWord(collocation.english, word.english);
      }).toList();
      if (matched.isEmpty) continue;
      await repo.upsertContent(
        wordId: word.id,
        contentType: contentType,
        englishContent: json.encode(
          matched.map((item) => item.toJson()).toList(),
        ),
        chineseTranslation: '',
      );
    }
  }

  Future<void> _cacheTextItems(
    AiContentRepository repo,
    List<Word> batchWords,
    List<AiSentence> allItems,
    String contentType,
  ) async {
    for (final word in batchWords) {
      final matched = allItems.where((item) {
        final source = item.sourceWord.trim().toLowerCase();
        if (source.isNotEmpty) return source == word.english.toLowerCase();
        return _containsWord(item.english, word.english);
      }).toList();
      if (matched.isEmpty) continue;
      await repo.upsertContent(
        wordId: word.id,
        contentType: contentType,
        englishContent: json.encode(
          matched.map((item) => item.toJson()).toList(),
        ),
        chineseTranslation: '',
      );
    }
  }

  Future<List<DeepQuestion>> _buildQuestions(String contentType) async {
    final repo = _ref.read(aiContentRepositoryProvider);
    final questions = <DeepQuestion>[];
    for (final word in state.words) {
      final sourceListId = state.sourceListIds[word.id];
      if (sourceListId == null) continue;
      final cached = await repo.getContent(word.id, contentType);
      if (cached == null) continue;
      try {
        final rawItems = json.decode(cached.englishContent) as List;
        final items = rawItems
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .where(
              (item) =>
                  _containsWord(item['english'] as String? ?? '', word.english),
            )
            .toList();
        if (items.isEmpty) continue;
        final item = items[_rng.nextInt(items.length)];
        final sourceText = item['english'] as String? ?? '';
        final displayText = _blankWord(sourceText, word.english);
        if (displayText == null) continue;
        questions.add(
          DeepQuestion(
            word: word,
            sourceListId: sourceListId,
            displayText: displayText,
            sourceText: sourceText,
            correctAnswer: word.english,
            chineseHint: item['chinese_translation'] as String? ?? '',
          ),
        );
      } catch (_) {
        // Bad cached AI content is ignored and can be regenerated by the user.
      }
    }
    questions.shuffle(_rng);
    return questions;
  }

  Future<List<DeepQuestion>> _attachCollocationOptions(
    List<DeepQuestion> questions,
  ) async {
    final repo = _ref.read(aiContentRepositoryProvider);
    final optionContentType = _collocationOptionContentType();
    final resolvedByWordId = <int, DeepQuestion>{};
    final missing = <DeepQuestion>[];

    for (final question in questions) {
      final cached = await repo.getContent(question.word.id, optionContentType);
      final cachedOptions = _readCachedCollocationOptions(
        cached?.englishContent,
        question,
      );
      if (cachedOptions.validationUnavailable) {
        resolvedByWordId[question.word.id] = question;
      } else if (cachedOptions.distractors.length >= 2) {
        resolvedByWordId[question.word.id] = question.withAnswerOptions(
          _shuffleOptions(question, cachedOptions.distractors),
        );
      } else {
        missing.add(question);
      }
    }

    if (missing.isNotEmpty) {
      try {
        final pools = await _loadDistractorPools();
        final requests = <CollocationOptionRequest>[];
        final candidatesByWordId = <int, List<String>>{};
        for (final question in missing) {
          final candidates = _candidateWordsFor(question, pools);
          if (candidates.length < 2) continue;
          candidatesByWordId[question.word.id] = candidates;
          requests.add(
            CollocationOptionRequest(
              wordId: question.word.id,
              targetWord: question.correctAnswer,
              collocation: question.sourceText,
              displayText: question.displayText,
              candidateWords: candidates,
            ),
          );
        }

        if (requests.isNotEmpty) {
          final aiService = AiService(_ref.read(settingsRepositoryProvider));
          final provider = await aiService.getProvider();
          // Keep each structured validation request compact enough for Flash
          // models to return one complete JSON object reliably.
          const batchSize = 3;
          final questionByWordId = {
            for (final question in missing) question.word.id: question,
          };
          for (var i = 0; i < requests.length; i += batchSize) {
            final batch = requests.skip(i).take(batchSize).toList();
            final validations = await provider.validateCollocationOptions(
              batch,
            );
            final validationByWordId = {
              for (final validation in validations)
                validation.wordId: validation,
            };
            for (final request in batch) {
              final question = questionByWordId[request.wordId];
              final validation = validationByWordId[request.wordId];
              if (question == null || validation == null) continue;
              final distractors = _approvedDistractors(
                validation.distractors,
                candidatesByWordId[request.wordId] ?? const [],
                question.correctAnswer,
              );
              if (distractors.length < 2) continue;
              await repo.upsertContent(
                wordId: question.word.id,
                contentType: optionContentType,
                englishContent: json.encode({
                  'collocation': question.sourceText,
                  'distractors': distractors,
                }),
                chineseTranslation: '',
              );
              resolvedByWordId[question.word.id] = question.withAnswerOptions(
                _shuffleOptions(question, distractors),
              );
            }
          }
        }
      } catch (_) {
        // Option validation is an enhancement. DeepSeek Flash can generate the
        // collocation itself but may return an empty response for this extra
        // validation request, so it must never block the whole practice flow.
      }

      final unresolved = questions
          .where((question) => !resolvedByWordId.containsKey(question.word.id))
          .toList();
      await _cacheCollocationFillFallbacks(repo, optionContentType, unresolved);
    }

    return questions
        .map((question) => resolvedByWordId[question.word.id] ?? question)
        .toList(growable: false);
  }

  Future<_DistractorPools> _loadDistractorPools() async {
    final repo = _ref.read(wordListRepositoryProvider);
    final allLists = state.bookId == null
        ? await repo.getAllLists()
        : await repo.getListsForBook(state.bookId!);
    final selectedIds = state.listIds.toSet();
    final selectedWordIds = state.words.map((word) => word.id).toSet();
    final passedIds = allLists
        .where((list) => list.isPassed && !selectedIds.contains(list.id))
        .map((list) => list.id)
        .toList();
    final unpassedIds = allLists
        .where((list) => !list.isPassed && !selectedIds.contains(list.id))
        .map((list) => list.id)
        .toList();
    final preferredWords = await repo.getWordsForLists(passedIds);
    final fallbackWords = await repo.getWordsForLists(unpassedIds);
    return _DistractorPools(
      preferred: _uniqueEnglish(preferredWords, selectedWordIds),
      fallback: _uniqueEnglish(fallbackWords, selectedWordIds),
    );
  }

  List<String> _uniqueEnglish(List<Word> words, Set<int> excludedWordIds) {
    final seen = <String>{};
    final result = <String>[];
    for (final word in words) {
      if (excludedWordIds.contains(word.id)) continue;
      final value = word.english.trim();
      final key = value.toLowerCase();
      if (value.isEmpty || !seen.add(key)) continue;
      result.add(value);
    }
    return result;
  }

  List<String> _candidateWordsFor(
    DeepQuestion question,
    _DistractorPools pools,
  ) {
    final target = question.correctAnswer.toLowerCase();
    final candidates = <String>[];
    void addSample(List<String> source, int count) {
      final usable = source
          .where((word) => word.toLowerCase() != target)
          .where(
            (word) => !candidates.any(
              (item) => item.toLowerCase() == word.toLowerCase(),
            ),
          )
          .toList();
      usable.shuffle(_rng);
      candidates.addAll(usable.take(count));
    }

    // 18 candidates are enough to find 3-4 safe alternatives while keeping
    // the structured validation request small and inexpensive.
    addSample(pools.preferred, 8);
    addSample(pools.fallback, 6);
    addSample(_commonDistractorWords, 4);
    return candidates;
  }

  _CachedCollocationOptions _readCachedCollocationOptions(
    String? raw,
    DeepQuestion question,
  ) {
    if (raw == null) return const _CachedCollocationOptions();
    try {
      final jsonValue = json.decode(raw);
      if (jsonValue is! Map) return const _CachedCollocationOptions();
      final data = Map<String, dynamic>.from(jsonValue);
      if ((data['collocation'] as String? ?? '').toLowerCase() !=
          question.sourceText.toLowerCase()) {
        return const _CachedCollocationOptions();
      }
      return _CachedCollocationOptions(
        validationUnavailable: data['validation_unavailable'] == true,
        distractors: _approvedDistractors(
          (data['distractors'] as List?)?.whereType<String>().toList(
                growable: false,
              ) ??
              const [],
          const [],
          question.correctAnswer,
          allowAnyCandidate: true,
        ),
      );
    } catch (_) {
      return const _CachedCollocationOptions();
    }
  }

  Future<void> _cacheCollocationFillFallbacks(
    AiContentRepository repo,
    String contentType,
    List<DeepQuestion> questions,
  ) async {
    for (final question in questions) {
      try {
        await repo.upsertContent(
          wordId: question.word.id,
          contentType: contentType,
          englishContent: json.encode({
            'collocation': question.sourceText,
            'validation_unavailable': true,
            'distractors': const <String>[],
          }),
          chineseTranslation: '',
        );
      } catch (_) {
        // The exercise itself still works even if a fallback marker cannot be
        // persisted; it simply may try validation again next time.
      }
    }
  }

  List<String> _approvedDistractors(
    List<String> proposed,
    List<String> candidates,
    String correctAnswer, {
    bool allowAnyCandidate = false,
  }) {
    final candidateByKey = {
      for (final candidate in candidates) candidate.toLowerCase(): candidate,
    };
    final result = <String>[];
    for (final item in proposed) {
      final key = item.trim().toLowerCase();
      if (key.isEmpty || key == correctAnswer.toLowerCase()) continue;
      final canonical =
          candidateByKey[key] ?? (allowAnyCandidate ? item.trim() : null);
      if (canonical == null ||
          result.any(
            (value) => value.toLowerCase() == canonical.toLowerCase(),
          )) {
        continue;
      }
      result.add(canonical);
      if (result.length == 4) break;
    }
    return result;
  }

  List<String> _shuffleOptions(
    DeepQuestion question,
    List<String> distractors,
  ) {
    final options = [question.correctAnswer, ...distractors];
    options.shuffle(_rng);
    return options;
  }

  String _collocationOptionContentType() {
    final ids = [...state.listIds]..sort();
    final hash = sha1
        .convert(utf8.encode('coopt-v3-json-object:${ids.join(',')}'))
        .toString();
    return 'coopt3_${hash.substring(0, 12)}';
  }

  String _fillEvaluationContentType(DeepQuestion question, String answer) {
    final hash = sha1
        .convert(
          utf8.encode(
            '${question.sourceText}|${question.correctAnswer}|$answer',
          ),
        )
        .toString();
    return 'fillv1_${hash.substring(0, 12)}';
  }

  String _contentTypeForMode(String mode) {
    switch (mode) {
      case 'deep_choice':
        return _collocationContentType;
      case 'deep_idioms':
        return _idiomContentType;
      default:
        return _sentenceContentType;
    }
  }

  bool _containsWord(String text, String word) {
    return RegExp(
      '\\b${RegExp.escape(word)}\\b',
      caseSensitive: false,
    ).hasMatch(text);
  }

  String? _blankWord(String text, String word) {
    final pattern = RegExp(
      '\\b${RegExp.escape(word)}\\b',
      caseSensitive: false,
    );
    if (!pattern.hasMatch(text)) return null;
    return text.replaceAll(pattern, '_____');
  }

  void startQuiz() {
    if (state.phase != DeepPracticePhase.ready) return;
    state = state.copyWith(
      phase: DeepPracticePhase.quiz,
      currentIndex: 0,
      answers: List<DeepAnswerRecord?>.filled(state.questions.length, null),
      clearAnswerEvaluationError: true,
    );
  }

  void submitChoiceAnswer(String selectedOption) {
    if (state.phase != DeepPracticePhase.quiz || state.isEvaluatingAnswer) {
      return;
    }
    final question = state.currentQuestion;
    if (question == null) return;
    final correct =
        selectedOption.toLowerCase() == question.correctAnswer.toLowerCase();
    _recordAnswer(
      DeepAnswerRecord(
        questionIndex: state.currentIndex,
        wordId: question.word.id,
        sourceListId: question.sourceListId,
        userAnswer: selectedOption,
        correctAnswer: question.correctAnswer,
        verdict: correct
            ? DeepAnswerVerdict.targetCorrect
            : DeepAnswerVerdict.incorrect,
      ),
    );
  }

  Future<void> submitTextAnswer(String userInput) async {
    if (state.phase != DeepPracticePhase.quiz || state.isEvaluatingAnswer) {
      return;
    }
    final question = state.currentQuestion;
    if (question == null) return;
    final answer = userInput.trim();
    if (answer.isEmpty) {
      _recordAnswer(
        DeepAnswerRecord(
          questionIndex: state.currentIndex,
          wordId: question.word.id,
          sourceListId: question.sourceListId,
          userAnswer: null,
          correctAnswer: question.correctAnswer,
          verdict: DeepAnswerVerdict.incorrect,
        ),
      );
      return;
    }
    if (answer.toLowerCase() == question.correctAnswer.toLowerCase()) {
      _recordAnswer(
        DeepAnswerRecord(
          questionIndex: state.currentIndex,
          wordId: question.word.id,
          sourceListId: question.sourceListId,
          userAnswer: answer,
          correctAnswer: question.correctAnswer,
          verdict: DeepAnswerVerdict.targetCorrect,
        ),
      );
      return;
    }

    state = state.copyWith(
      isEvaluatingAnswer: true,
      clearAnswerEvaluationError: true,
    );
    try {
      final repo = _ref.read(aiContentRepositoryProvider);
      final cacheType = _fillEvaluationContentType(question, answer);
      final cached = await repo.getContent(question.word.id, cacheType);
      FillAnswerEvaluation evaluation;
      if (cached != null) {
        evaluation = FillAnswerEvaluation.fromJson(
          Map<String, dynamic>.from(json.decode(cached.englishContent) as Map),
        );
      } else {
        final aiService = AiService(_ref.read(settingsRepositoryProvider));
        final provider = await aiService.getProvider();
        evaluation = await provider.evaluateFillAnswer(
          sentenceWithBlank: question.displayText,
          targetWord: question.correctAnswer,
          userAnswer: answer,
        );
        await repo.upsertContent(
          wordId: question.word.id,
          contentType: cacheType,
          englishContent: json.encode({
            'is_acceptable_alternative': evaluation.isAcceptableAlternative,
            'feedback': evaluation.feedback,
          }),
          chineseTranslation: '',
        );
      }
      if (!mounted) return;
      _recordAnswer(
        DeepAnswerRecord(
          questionIndex: state.currentIndex,
          wordId: question.word.id,
          sourceListId: question.sourceListId,
          userAnswer: answer,
          correctAnswer: question.correctAnswer,
          verdict: evaluation.isAcceptableAlternative
              ? DeepAnswerVerdict.acceptableAlternative
              : DeepAnswerVerdict.incorrect,
          feedback: evaluation.feedback,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(
        isEvaluatingAnswer: false,
        answerEvaluationErrorKey: 'deep_answer_check_failed',
        answerEvaluationErrorDetail: '$error',
      );
    }
  }

  void _recordAnswer(DeepAnswerRecord answer) {
    final records = List<DeepAnswerRecord?>.from(state.answers);
    if (answer.questionIndex >= records.length) return;
    records[answer.questionIndex] = answer;
    state = state.copyWith(
      phase: DeepPracticePhase.feedback,
      answers: records,
      isEvaluatingAnswer: false,
      clearAnswerEvaluationError: true,
    );
  }

  void editCurrentAnswer() {
    if (state.phase != DeepPracticePhase.feedback ||
        state.currentAnswer == null) {
      return;
    }
    state = state.copyWith(
      phase: DeepPracticePhase.quiz,
      clearAnswerEvaluationError: true,
    );
  }

  void previousQuestion() {
    if (state.currentIndex <= 0) return;
    final index = state.currentIndex - 1;
    state = state.copyWith(
      currentIndex: index,
      phase: state.answers[index] == null
          ? DeepPracticePhase.quiz
          : DeepPracticePhase.feedback,
      isEvaluatingAnswer: false,
      clearAnswerEvaluationError: true,
    );
  }

  void nextQuestion() {
    if (state.phase != DeepPracticePhase.feedback) return;
    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.questions.length) {
      state = state.copyWith(
        phase: DeepPracticePhase.finished,
        isEvaluatingAnswer: false,
        clearAnswerEvaluationError: true,
      );
      return;
    }
    state = state.copyWith(
      currentIndex: nextIndex,
      phase: state.answers[nextIndex] == null
          ? DeepPracticePhase.quiz
          : DeepPracticePhase.feedback,
      isEvaluatingAnswer: false,
      clearAnswerEvaluationError: true,
    );
  }

  Future<void> saveSession() async {
    if (state.isSaving ||
        state.hasSaved ||
        state.phase != DeepPracticePhase.finished) {
      return;
    }
    state = state.copyWith(isSaving: true);
    try {
      final repo = _ref.read(practiceRepositoryProvider);
      final now = DateTime.now().millisecondsSinceEpoch;
      final recordsByList = <int, List<DeepAnswerRecord>>{};
      for (final record in state.answeredRecords) {
        recordsByList.putIfAbsent(record.sourceListId, () => []).add(record);
      }
      for (final entry in recordsByList.entries) {
        final records = entry.value;
        final correctCount = records
            .where((record) => record.isTargetCorrect)
            .length;
        final sessionId = await repo.createSession(
          listId: entry.key,
          mode: state.mode!,
          totalCount: records.length,
          correctCount: correctCount,
          accuracy: records.isEmpty ? 0 : correctCount / records.length,
          startedAt: now,
          finishedAt: now,
        );
        await repo.recordAnswers(
          records
              .map(
                (record) => PracticeAnswersCompanion(
                  sessionId: Value(sessionId),
                  wordId: Value(record.wordId),
                  isCorrect: Value(record.isTargetCorrect),
                  userAnswer: Value.absentIfNull(record.userAnswer),
                  correctAnswer: Value(record.correctAnswer),
                  answeredAt: Value(now),
                ),
              )
              .toList(),
        );
        for (final record in records) {
          if (record.shouldRecordError) {
            await repo.recordErrorWord(record.wordId, record.sourceListId);
          }
        }
      }
      _ref.invalidate(listOverviewProvider);
      state = state.copyWith(isSaving: false, hasSaved: true);
    } catch (_) {
      if (mounted) state = state.copyWith(isSaving: false);
    }
  }

  void reset() {
    state = const DeepPracticeState();
  }
}

class _DistractorPools {
  final List<String> preferred;
  final List<String> fallback;

  const _DistractorPools({required this.preferred, required this.fallback});
}

class _CachedCollocationOptions {
  final List<String> distractors;
  final bool validationUnavailable;

  const _CachedCollocationOptions({
    this.distractors = const [],
    this.validationUnavailable = false,
  });
}
