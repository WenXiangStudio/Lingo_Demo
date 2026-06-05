import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../core/utils/answer_checker.dart';
import '../../../data/database/app_database.dart';
import '../../../data/providers.dart';
import '../../review_center/providers/review_center_provider.dart';
import '../../lists/providers/list_provider.dart';

enum PracticeMode { choice, fill, dictation, audioChoice }

enum PracticePhase { setup, quiz, feedback, finished }

class AnswerRecord {
  final int wordId;
  final String? userAnswer;
  final String correctAnswer;
  final bool isCorrect;

  const AnswerRecord({
    required this.wordId,
    this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });
}

class PracticeState {
  final PracticePhase phase;
  final PracticeMode? mode;
  final int? listId;
  final bool onlyForgotten;
  final bool onlyErrors;
  final List<Word> words;
  final List<Word> choiceDistractorPool;
  final Set<String> blockedChoiceMeanings;
  final int currentIndex;
  final List<AnswerRecord> answers;
  final List<String>? currentOptions;
  final bool? lastAnswerCorrect;
  final int? sessionId;
  final bool isSaving;
  final String? saveError;
  final int? startedAt;
  final int clearedForgottenCount;

  const PracticeState({
    this.phase = PracticePhase.setup,
    this.mode,
    this.listId,
    this.onlyForgotten = false,
    this.onlyErrors = false,
    this.words = const [],
    this.choiceDistractorPool = const [],
    this.blockedChoiceMeanings = const {},
    this.currentIndex = 0,
    this.answers = const [],
    this.currentOptions,
    this.lastAnswerCorrect,
    this.sessionId,
    this.isSaving = false,
    this.saveError,
    this.startedAt,
    this.clearedForgottenCount = 0,
  });

  PracticeState copyWith({
    PracticePhase? phase,
    PracticeMode? mode,
    int? listId,
    bool? onlyForgotten,
    bool? onlyErrors,
    List<Word>? words,
    List<Word>? choiceDistractorPool,
    Set<String>? blockedChoiceMeanings,
    int? currentIndex,
    List<AnswerRecord>? answers,
    List<String>? currentOptions,
    bool? lastAnswerCorrect,
    int? sessionId,
    bool? isSaving,
    String? saveError,
    int? startedAt,
    int? clearedForgottenCount,
    bool clearOptions = false,
    bool clearLastAnswer = false,
    bool clearSaveError = false,
  }) {
    return PracticeState(
      phase: phase ?? this.phase,
      mode: mode ?? this.mode,
      listId: listId ?? this.listId,
      onlyForgotten: onlyForgotten ?? this.onlyForgotten,
      onlyErrors: onlyErrors ?? this.onlyErrors,
      words: words ?? this.words,
      choiceDistractorPool: choiceDistractorPool ?? this.choiceDistractorPool,
      blockedChoiceMeanings:
          blockedChoiceMeanings ?? this.blockedChoiceMeanings,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      currentOptions: clearOptions
          ? null
          : (currentOptions ?? this.currentOptions),
      lastAnswerCorrect: clearLastAnswer
          ? null
          : (lastAnswerCorrect ?? this.lastAnswerCorrect),
      sessionId: sessionId ?? this.sessionId,
      isSaving: isSaving ?? this.isSaving,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
      startedAt: startedAt ?? this.startedAt,
      clearedForgottenCount:
          clearedForgottenCount ?? this.clearedForgottenCount,
    );
  }

  Word? get currentWord =>
      currentIndex < words.length ? words[currentIndex] : null;

  int get totalQuestions => words.length;
  int get correctCount => answers.where((a) => a.isCorrect).length;
  int get incorrectCount => answers.where((a) => !a.isCorrect).length;
  double get accuracy => answers.isEmpty ? 0 : correctCount / answers.length;

  bool get isPassed {
    if (answers.isEmpty) return false;
    return accuracy >= AppConstants.defaultPassThreshold;
  }

  int get elapsedSeconds => startedAt != null
      ? DateTime.now()
            .difference(DateTime.fromMillisecondsSinceEpoch(startedAt!))
            .inSeconds
      : 0;
}

final practiceProvider = StateNotifierProvider<PracticeNotifier, PracticeState>(
  (ref) {
    return PracticeNotifier(ref);
  },
);

final errorWordsWithCountProvider =
    FutureProvider.family<List<ErrorWordWithCount>, int>((ref, listId) async {
  final repo = ref.read(practiceRepositoryProvider);
  return repo.getErrorWordsWithCounts(listId);
});

class _ScoredDistractor {
  final String meaning;
  final int sharedChars;
  const _ScoredDistractor(this.meaning, this.sharedChars);
}

String _normalizeMeaning(String value) {
  return AnswerChecker.normalizeMeaningKey(value);
}

int _countSharedChineseChars(String a, String b) {
  int count = 0;
  for (final c in a.runes) {
    if (c >= 0x4E00 && b.contains(String.fromCharCode(c))) count++;
  }
  return count;
}

class PracticeNotifier extends StateNotifier<PracticeState> {
  final Ref _ref;
  final _rng = Random();

  PracticeNotifier(this._ref) : super(const PracticeState());

  // ─── Setup ──────────────────────────────────────────────────────────────────

  void selectMode(PracticeMode mode) {
    state = PracticeState(mode: mode);
  }

  Future<void> initSession({
    required int listId,
    required PracticeMode mode,
    int? wordCount,
    bool onlyForgotten = false,
    bool onlyErrors = false,
  }) async {
    final wordListRepo = _ref.read(wordListRepositoryProvider);
    final listWords = await wordListRepo.getWordsForList(listId);
    final practiceRepo = _ref.read(practiceRepositoryProvider);
    var words = listWords;
    if (onlyErrors) {
      words = await practiceRepo.getErrorWordsForList(listId);
    } else if (onlyForgotten) {
      words = await practiceRepo.getForgottenWordsForList(listId);
    }
    if (words.isEmpty) return;

    final choiceDistractorPool = await wordListRepo
        .getChoiceDistractorWordsForList(listId);
    final blockedChoiceMeanings = listWords
        .map((w) => _normalizeMeaning(w.chineseMeanings))
        .where((m) => m.isNotEmpty)
        .toSet();

    words = List.from(words);
    words.shuffle(_rng);
    if (wordCount != null && wordCount < words.length) {
      words = words.take(wordCount).toList();
    }

    state = PracticeState(
      phase: PracticePhase.quiz,
      mode: mode,
      listId: listId,
      onlyForgotten: onlyForgotten,
      onlyErrors: onlyErrors,
      words: words,
      choiceDistractorPool: choiceDistractorPool,
      blockedChoiceMeanings: blockedChoiceMeanings,
      currentIndex: 0,
      currentOptions:
          (mode == PracticeMode.choice || mode == PracticeMode.audioChoice)
          ? _generateChoiceOptions(
              words,
              0,
              choiceDistractorPool: choiceDistractorPool,
              blockedChoiceMeanings: blockedChoiceMeanings,
            )
          : null,
      startedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  // ─── Options for choice mode ───────────────────────────────────────────────

  List<String> _generateChoiceOptions(
    List<Word> words,
    int currentIdx, {
    required List<Word> choiceDistractorPool,
    required Set<String> blockedChoiceMeanings,
  }) {
    final correct = words[currentIdx].chineseMeanings;
    final correctKey = _normalizeMeaning(correct);
    final distractors = <String>[];
    final usedMeaningKeys = <String>{correctKey};
    final candidates = choiceDistractorPool.toList()..shuffle(_rng);

    // Distractors must come from outside the current list. Exact duplicate
    // meanings are filtered after normalization to avoid repeated options.
    final scored = <_ScoredDistractor>[];
    for (final w in candidates) {
      final m = w.chineseMeanings;
      final meaningKey = _normalizeMeaning(m);
      if (meaningKey.isEmpty ||
          meaningKey == correctKey ||
          usedMeaningKeys.contains(meaningKey) ||
          blockedChoiceMeanings.contains(meaningKey)) {
        continue;
      }
      usedMeaningKeys.add(meaningKey);
      final sharedChars = _countSharedChineseChars(
        m.toLowerCase(),
        correct.toLowerCase(),
      );
      scored.add(_ScoredDistractor(m, sharedChars));
    }
    scored.sort((a, b) => a.sharedChars.compareTo(b.sharedChars));

    for (final s in scored) {
      if (distractors.length >= 4) break;
      distractors.add(s.meaning);
    }

    while (distractors.length < 4) {
      final filler = '___${distractors.length + 1}___';
      if (!distractors.contains(filler)) {
        distractors.add(filler);
      }
    }

    final options = [correct, ...distractors];
    options.shuffle(_rng);
    return options;
  }

  // ─── Answer ────────────────────────────────────────────────────────────────

  void submitChoiceAnswer(String selectedOption) {
    if (state.phase != PracticePhase.quiz) return;
    final word = state.currentWord!;
    final isCorrect = AnswerChecker.isChoiceAnswerCorrect(
      selectedOption,
      word.chineseMeanings,
    );

    state = state.copyWith(
      phase: PracticePhase.feedback,
      lastAnswerCorrect: isCorrect,
      answers: [
        ...state.answers,
        AnswerRecord(
          wordId: word.id,
          userAnswer: selectedOption,
          correctAnswer: word.chineseMeanings,
          isCorrect: isCorrect,
        ),
      ],
    );
  }

  void submitTextAnswer(String userInput) {
    if (state.phase != PracticePhase.quiz) return;
    final word = state.currentWord!;
    final trimmed = userInput.trim();
    final isCorrect = AnswerChecker.isFillAnswerCorrect(
      trimmed,
      word.chineseMeanings,
    );

    state = state.copyWith(
      phase: PracticePhase.feedback,
      lastAnswerCorrect: isCorrect,
      answers: [
        ...state.answers,
        AnswerRecord(
          wordId: word.id,
          userAnswer: trimmed.isEmpty ? null : trimmed,
          correctAnswer: word.chineseMeanings,
          isCorrect: isCorrect,
        ),
      ],
    );
  }

  // ─── Navigation ────────────────────────────────────────────────────────────

  void nextQuestion() {
    if (state.phase != PracticePhase.feedback) return;
    final nextIdx = state.currentIndex + 1;

    if (nextIdx >= state.words.length) {
      state = state.copyWith(
        phase: PracticePhase.finished,
        clearOptions: true,
        clearLastAnswer: true,
      );
      return;
    }

    state = state.copyWith(
      phase: PracticePhase.quiz,
      currentIndex: nextIdx,
      currentOptions:
          (state.mode == PracticeMode.choice ||
              state.mode == PracticeMode.audioChoice)
          ? _generateChoiceOptions(
              state.words,
              nextIdx,
              choiceDistractorPool: state.choiceDistractorPool,
              blockedChoiceMeanings: state.blockedChoiceMeanings,
            )
          : null,
      clearLastAnswer: true,
    );
  }

  // ─── Save ──────────────────────────────────────────────────────────────────

  Future<double> _passThresholdForList(int listId) async {
    final listRepo = _ref.read(wordListRepositoryProvider);
    final list = await listRepo.getList(listId);
    if (list != null) return list.passThreshold;
    return _ref.read(settingsRepositoryProvider).getPassThreshold();
  }

  Future<bool> markListPassedIfEligible([PracticeState? source]) async {
    final snapshot = source ?? state;
    if (snapshot.onlyForgotten ||
        snapshot.onlyErrors ||
        snapshot.listId == null ||
        snapshot.answers.isEmpty) {
      return false;
    }

    final threshold = await _passThresholdForList(snapshot.listId!);
    if (snapshot.accuracy < threshold) return false;

    final listRepo = _ref.read(wordListRepositoryProvider);
    await listRepo.markListPassed(snapshot.listId!, true);
    _ref.invalidate(listDetailProvider(snapshot.listId!));
    _ref.invalidate(listOverviewProvider);
    return true;
  }

  void markSaveFailed(String message) {
    state = state.copyWith(isSaving: false, saveError: message);
  }

  Future<void> saveSession() async {
    if (state.isSaving || state.sessionId != null) return;
    final snapshot = state;
    if (snapshot.listId == null ||
        snapshot.mode == null ||
        snapshot.answers.isEmpty) {
      return;
    }

    state = state.copyWith(isSaving: true, clearSaveError: true);
    final practiceRepo = _ref.read(practiceRepositoryProvider);
    final accuracy = snapshot.accuracy;
    int? sessionId;
    var cleared = 0;
    String? saveError;

    try {
      // Pass/unlock is core progress and should not depend on the longer
      // practice-history write completing successfully.
      await markListPassedIfEligible(snapshot);

      final newSessionId = await practiceRepo.createSession(
        listId: snapshot.listId!,
        mode: snapshot.mode!.name,
        totalCount: snapshot.totalQuestions,
        correctCount: snapshot.correctCount,
        accuracy: accuracy,
        startedAt: snapshot.startedAt ?? DateTime.now().millisecondsSinceEpoch,
        finishedAt: DateTime.now().millisecondsSinceEpoch,
      );
      sessionId = newSessionId;

      final answerCompanions = snapshot.answers.map((a) {
        return PracticeAnswersCompanion(
          sessionId: Value(newSessionId),
          wordId: Value(a.wordId),
          isCorrect: Value(a.isCorrect),
          userAnswer: Value.absentIfNull(a.userAnswer),
          correctAnswer: Value(a.correctAnswer),
          answeredAt: Value(DateTime.now().millisecondsSinceEpoch),
        );
      }).toList();

      await practiceRepo.recordAnswers(answerCompanions);

      // Record error words
      for (final a in snapshot.answers) {
        if (!a.isCorrect) {
          await practiceRepo.recordErrorWord(a.wordId, snapshot.listId!);
        }
      }

      // For forgotten-words sessions that pass: clear forgotten flag for
      // correctly-answered words. Design: "必须在遗忘系统进行二次背诵过关后
      // 才可以消除已遗忘状态".
      if (snapshot.onlyForgotten) {
        final threshold = await _passThresholdForList(snapshot.listId!);
        if (accuracy >= threshold) {
          final correctIds = snapshot.answers
              .where((a) => a.isCorrect)
              .map((a) => a.wordId)
              .toList();
          await practiceRepo.clearForgottenStatusForWords(
            correctIds,
            snapshot.listId!,
          );
          cleared = correctIds.length;
        }
      }

      if (snapshot.onlyErrors) {
        final threshold = await _passThresholdForList(snapshot.listId!);
        if (accuracy >= threshold) {
          final correctIds = snapshot.answers
              .where((a) => a.isCorrect)
              .map((a) => a.wordId)
              .toList();
          await practiceRepo.resolveErrorWords(
            correctIds,
            listId: snapshot.listId!,
          );
          cleared = correctIds.length;
        }
      }
    } catch (e) {
      saveError = e.toString();
    } finally {
      _ref.invalidate(listOverviewProvider);
      _ref.invalidate(listWordsProvider(snapshot.listId!));
      _ref.invalidate(forgottenWordIdsProvider(snapshot.listId!));
      _ref.invalidate(forgottenWordsProvider(snapshot.listId!));
      _ref.invalidate(errorWordsWithCountProvider(snapshot.listId!));
      _ref.invalidate(reviewCenterDataProvider);

      if (mounted &&
          state.listId == snapshot.listId &&
          state.startedAt == snapshot.startedAt) {
        state = state.copyWith(
          sessionId: sessionId,
          isSaving: false,
          clearedForgottenCount: cleared,
          saveError: saveError,
          clearSaveError: saveError == null,
        );
      }
    }
  }

  void reset() {
    state = const PracticeState();
  }
}
