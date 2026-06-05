import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/ai/ai_service.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/ai_models.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/repositories.dart';
import '../../lists/providers/list_provider.dart';

enum DeepPracticePhase { setup, generating, ready, quiz, feedback, finished }

class DeepQuestion {
  final Word word;
  final String displayText;
  final String correctAnswer;
  final String chineseHint;

  const DeepQuestion({
    required this.word,
    required this.displayText,
    required this.correctAnswer,
    required this.chineseHint,
  });
}

class DeepAnswerRecord {
  final int wordId;
  final String? userAnswer;
  final String correctAnswer;
  final bool isCorrect;

  const DeepAnswerRecord({
    required this.wordId,
    this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });
}

class DeepPracticeState {
  final DeepPracticePhase phase;
  final String? mode;
  final int? listId;
  final List<Word> words;
  final int generatedCount;
  final int totalToGenerate;
  final String? generationError;
  final List<DeepQuestion> questions;
  final int currentIndex;
  final List<DeepAnswerRecord> answers;
  final List<String>? currentOptions;
  final bool? lastAnswerCorrect;
  final int? sessionId;
  final bool isSaving;

  const DeepPracticeState({
    this.phase = DeepPracticePhase.setup,
    this.mode,
    this.listId,
    this.words = const [],
    this.generatedCount = 0,
    this.totalToGenerate = 0,
    this.generationError,
    this.questions = const [],
    this.currentIndex = 0,
    this.answers = const [],
    this.currentOptions,
    this.lastAnswerCorrect,
    this.sessionId,
    this.isSaving = false,
  });

  DeepPracticeState copyWith({
    DeepPracticePhase? phase,
    String? mode,
    int? listId,
    List<Word>? words,
    int? generatedCount,
    int? totalToGenerate,
    String? generationError,
    List<DeepQuestion>? questions,
    int? currentIndex,
    List<DeepAnswerRecord>? answers,
    List<String>? currentOptions,
    bool? lastAnswerCorrect,
    int? sessionId,
    bool? isSaving,
    bool clearOptions = false,
    bool clearLastAnswer = false,
    bool clearError = false,
  }) {
    return DeepPracticeState(
      phase: phase ?? this.phase,
      mode: mode ?? this.mode,
      listId: listId ?? this.listId,
      words: words ?? this.words,
      generatedCount: generatedCount ?? this.generatedCount,
      totalToGenerate: totalToGenerate ?? this.totalToGenerate,
      generationError: clearError ? null : (generationError ?? this.generationError),
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      currentOptions: clearOptions ? null : (currentOptions ?? this.currentOptions),
      lastAnswerCorrect:
          clearLastAnswer ? null : (lastAnswerCorrect ?? this.lastAnswerCorrect),
      sessionId: sessionId ?? this.sessionId,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  DeepQuestion? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  int get totalQuestions => questions.length;
  int get correctCount => answers.where((a) => a.isCorrect).length;
  double get accuracy => answers.isEmpty ? 0 : correctCount / answers.length;
}

final deepPracticeProvider =
    StateNotifierProvider<DeepPracticeNotifier, DeepPracticeState>((ref) {
  return DeepPracticeNotifier(ref);
});

class DeepPracticeNotifier extends StateNotifier<DeepPracticeState> {
  final Ref _ref;
  final _rng = Random();

  DeepPracticeNotifier(this._ref) : super(const DeepPracticeState());

  // ─── Init ────────────────────────────────────────────────────────────────────

  Future<void> initSession({
    required int listId,
    required String mode,
  }) async {
    final repo = _ref.read(wordListRepositoryProvider);
    final words = await repo.getWordsForList(listId);
    if (words.isEmpty) return;

    state = DeepPracticeState(
      phase: DeepPracticePhase.setup,
      mode: mode,
      listId: listId,
      words: words,
      totalToGenerate: words.length,
    );
  }

  // ─── Generate AI content ────────────────────────────────────────────────────

  Future<void> generateContent() async {
    if (state.phase != DeepPracticePhase.setup &&
        state.phase != DeepPracticePhase.ready) {
      return;
    }

    state = state.copyWith(
      phase: DeepPracticePhase.generating,
      generatedCount: 0,
      clearError: true,
    );

    final contentType = state.mode == 'deep_choice'
        ? 'collocation'
        : state.mode == 'deep_idioms'
            ? 'idiom'
            : 'sentence';
    final aiContentRepo = _ref.read(aiContentRepositoryProvider);
    final uncachedWords = <Word>[];

    // Check cache first
    for (final word in state.words) {
      final cached = await aiContentRepo.getContent(word.id, contentType);
      if (cached == null) {
        uncachedWords.add(word);
      }
    }

    // Generate for uncached words in batches
    if (uncachedWords.isNotEmpty) {
      try {
        final aiService = AiService(_ref.read(settingsRepositoryProvider));
        final provider = await aiService.getProvider();

        const batchSize = 5;
        for (var i = 0; i < uncachedWords.length; i += batchSize) {
          final batch = uncachedWords
              .skip(i)
              .take(batchSize)
              .map((w) => w.english)
              .toList();

          if (contentType == 'collocation') {
            final collocations = await provider.generateCollocations(batch);
            await _cacheCollocations(aiContentRepo, batch, collocations);
          } else if (contentType == 'idiom') {
            final idioms = await provider.generateIdioms(batch);
            await _cacheTextItems(aiContentRepo, batch, idioms, 'idiom');
          } else {
            final sentences = await provider.generateSentences(batch);
            await _cacheTextItems(aiContentRepo, batch, sentences, 'sentence');
          }

          state = state.copyWith(
            generatedCount: (i + batch.length).clamp(0, uncachedWords.length),
          );
        }
      } catch (e) {
        if (mounted) {
          state = state.copyWith(
            phase: DeepPracticePhase.setup,
            generationError: 'Generation failed: $e',
          );
        }
        return;
      }
    }

    // Build questions from all cached content
    final questions = await _buildQuestions(contentType);
    if (questions.isEmpty) {
      state = state.copyWith(
        phase: DeepPracticePhase.setup,
        generationError: 'No content was generated. Check your API key.',
      );
      return;
    }

    state = state.copyWith(
      phase: DeepPracticePhase.ready,
      generatedCount: uncachedWords.length,
      questions: questions,
    );
  }

  Future<void> _cacheCollocations(
    AiContentRepository repo,
    List<String> batchWords,
    List<Collocation> allCollocations,
  ) async {
    // Group collocations by the word they belong to
    // The AI returns collocations for each word, but the Collocation model
    // doesn't carry the source word. We need to match collocations to words.
    // Approach: for each word, find collocations whose english contains the word.
    for (final wordEnglish in batchWords) {
      final word = state.words.firstWhere(
        (w) => w.english.toLowerCase() == wordEnglish.toLowerCase(),
      );
      final matched = allCollocations.where((c) {
        // Check if the collocation contains the target word (case-insensitive)
        final lowerCollocation = c.english.toLowerCase();
        final lowerWord = wordEnglish.toLowerCase();
        // Match as whole word or substring
        return lowerCollocation.contains(lowerWord);
      }).toList();

      if (matched.isNotEmpty) {
        final collocationsJson = json.encode(
          matched
              .map((c) => {
                    'english': c.english,
                    'chinese_translation': c.chineseTranslation,
                    'collocation_type': c.collocationType,
                  })
              .toList(),
        );
        await repo.upsertContent(
          wordId: word.id,
          contentType: 'collocation',
          englishContent: collocationsJson,
          chineseTranslation: '',
        );
      }
    }
  }

  Future<void> _cacheTextItems(
    AiContentRepository repo,
    List<String> batchWords,
    List<AiSentence> allItems,
    String contentType,
  ) async {
    for (final wordEnglish in batchWords) {
      final word = state.words.firstWhere(
        (w) => w.english.toLowerCase() == wordEnglish.toLowerCase(),
      );
      final matched = allItems.where((s) {
        return s.english.toLowerCase().contains(wordEnglish.toLowerCase());
      }).toList();

      if (matched.isNotEmpty) {
        final itemsJson = json.encode(
          matched
              .map((s) => {
                    'english': s.english,
                    'chinese_translation': s.chineseTranslation,
                  })
              .toList(),
        );
        await repo.upsertContent(
          wordId: word.id,
          contentType: contentType,
          englishContent: itemsJson,
          chineseTranslation: '',
        );
      }
    }
  }

  // ─── Build questions from cached content ─────────────────────────────────────

  Future<List<DeepQuestion>> _buildQuestions(String contentType) async {
    final aiContentRepo = _ref.read(aiContentRepositoryProvider);
    final questions = <DeepQuestion>[];

    for (final word in state.words) {
      final cached = await aiContentRepo.getContent(word.id, contentType);
      if (cached == null) continue;

      try {
        final items = json.decode(cached.englishContent) as List;

        if (contentType == 'collocation' && items.isNotEmpty) {
          // Pick the first collocation for the question
          final first = items.first as Map<String, dynamic>;
          final collocationEnglish = first['english'] as String;
          final chineseHint = first['chinese_translation'] as String? ?? '';

          // Blank out the target word from the collocation
          final displayText = _blankWord(collocationEnglish, word.english);
          if (displayText != null) {
            questions.add(DeepQuestion(
              word: word,
              displayText: displayText,
              correctAnswer: word.english,
              chineseHint: chineseHint,
            ));
          }
        } else if ((contentType == 'sentence' || contentType == 'idiom') &&
            items.isNotEmpty) {
          final first = items.first as Map<String, dynamic>;
          final sentenceEnglish = first['english'] as String;
          final chineseHint = first['chinese_translation'] as String? ?? '';

          final displayText = _blankWord(sentenceEnglish, word.english);
          if (displayText != null) {
            questions.add(DeepQuestion(
              word: word,
              displayText: displayText,
              correctAnswer: word.english,
              chineseHint: chineseHint,
            ));
          }
        }
      } catch (_) {
        // Skip malformed cached content
      }
    }

    questions.shuffle(_rng);
    return questions;
  }

  /// Replace the target word in [text] with "_____", case-insensitive.
  String? _blankWord(String text, String word) {
    final pattern = RegExp(
      '\\b${RegExp.escape(word)}\\b',
      caseSensitive: false,
    );
    if (pattern.hasMatch(text)) {
      return text.replaceAll(pattern, '_____');
    }
    // If no word boundary match, try simple replacement
    if (text.toLowerCase().contains(word.toLowerCase())) {
      final idx = text.toLowerCase().indexOf(word.toLowerCase());
      return '${text.substring(0, idx)}_____${text.substring(idx + word.length)}';
    }
    return null;
  }

  // ─── Start quiz ──────────────────────────────────────────────────────────────

  void startQuiz() {
    if (state.phase != DeepPracticePhase.ready) return;

    state = state.copyWith(
      phase: DeepPracticePhase.quiz,
      currentIndex: 0,
      currentOptions:
          (state.mode == 'deep_choice' || state.mode == 'deep_idioms')
              ? _generateOptions(0)
              : null,
    );
  }

  List<String> _generateOptions(int qIdx) {
    final question = state.questions[qIdx];
    final correct = question.correctAnswer;
    final distractors = <String>[];

    // Pick distractors from other question answers
    final otherAnswers = state.questions
        .where((q) => q.word.id != question.word.id)
        .map((q) => q.correctAnswer)
        .toList();
    otherAnswers.shuffle(_rng);

    for (final a in otherAnswers) {
      if (distractors.length >= 5) break;
      if (a.toLowerCase() != correct.toLowerCase() &&
          !distractors.any((d) => d.toLowerCase() == a.toLowerCase())) {
        distractors.add(a);
      }
    }

    while (distractors.length < 5) {
      distractors.add('___${distractors.length + 1}___');
    }

    final options = [correct, ...distractors];
    options.shuffle(_rng);
    return options;
  }

  // ─── Answer ──────────────────────────────────────────────────────────────────

  void submitChoiceAnswer(String selectedOption) {
    if (state.phase != DeepPracticePhase.quiz) return;
    final question = state.currentQuestion!;
    final isCorrect =
        selectedOption.toLowerCase() == question.correctAnswer.toLowerCase();

    state = state.copyWith(
      phase: DeepPracticePhase.feedback,
      lastAnswerCorrect: isCorrect,
      answers: [
        ...state.answers,
        DeepAnswerRecord(
          wordId: question.word.id,
          userAnswer: selectedOption,
          correctAnswer: question.correctAnswer,
          isCorrect: isCorrect,
        ),
      ],
    );
  }

  void submitTextAnswer(String userInput) {
    if (state.phase != DeepPracticePhase.quiz) return;
    final question = state.currentQuestion!;
    final trimmed = userInput.trim();
    final isCorrect =
        trimmed.toLowerCase() == question.correctAnswer.toLowerCase();

    state = state.copyWith(
      phase: DeepPracticePhase.feedback,
      lastAnswerCorrect: isCorrect,
      answers: [
        ...state.answers,
        DeepAnswerRecord(
          wordId: question.word.id,
          userAnswer: trimmed.isEmpty ? null : trimmed,
          correctAnswer: question.correctAnswer,
          isCorrect: isCorrect,
        ),
      ],
    );
  }

  // ─── Navigation ──────────────────────────────────────────────────────────────

  void nextQuestion() {
    if (state.phase != DeepPracticePhase.feedback) return;
    final nextIdx = state.currentIndex + 1;

    if (nextIdx >= state.questions.length) {
      state = state.copyWith(
        phase: DeepPracticePhase.finished,
        clearOptions: true,
        clearLastAnswer: true,
      );
      return;
    }

    state = state.copyWith(
      phase: DeepPracticePhase.quiz,
      currentIndex: nextIdx,
      currentOptions:
          (state.mode == 'deep_choice' || state.mode == 'deep_idioms')
              ? _generateOptions(nextIdx)
              : null,
      clearLastAnswer: true,
    );
  }

  // ─── Save ────────────────────────────────────────────────────────────────────

  Future<void> saveSession() async {
    if (state.isSaving || state.sessionId != null) return;
    state = state.copyWith(isSaving: true);

    final practiceRepo = _ref.read(practiceRepositoryProvider);
    final accuracy = state.accuracy;

    final sessionId = await practiceRepo.createSession(
      listId: state.listId!,
      mode: state.mode!,
      totalCount: state.totalQuestions,
      correctCount: state.correctCount,
      accuracy: accuracy,
    );

    final answerCompanions = state.answers.map((a) {
      return PracticeAnswersCompanion(
        sessionId: Value(sessionId),
        wordId: Value(a.wordId),
        isCorrect: Value(a.isCorrect),
        userAnswer: Value.absentIfNull(a.userAnswer),
        correctAnswer: Value(a.correctAnswer),
        answeredAt: Value(DateTime.now().millisecondsSinceEpoch),
      );
    }).toList();

    await practiceRepo.recordAnswers(answerCompanions);

    // Record error words
    for (final a in state.answers) {
      if (!a.isCorrect) {
        await practiceRepo.recordErrorWord(a.wordId, state.listId!);
      }
    }

    _ref.invalidate(listOverviewProvider);

    state = state.copyWith(sessionId: sessionId, isSaving: false);
  }

  void reset() {
    state = const DeepPracticeState();
  }
}
