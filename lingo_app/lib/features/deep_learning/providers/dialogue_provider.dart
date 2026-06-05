import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/ai/ai_service.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/ai_models.dart';
import '../../../data/providers.dart';

enum DialoguePhase { setup, generating, ready, error }

class DialogueState {
  final DialoguePhase phase;
  final int? listId;
  final List<Word> words;
  final List<String> selectedWords;
  final String scenario;
  final Dialogue? dialogue;
  final String? error;
  final bool showTranslation;

  const DialogueState({
    this.phase = DialoguePhase.setup,
    this.listId,
    this.words = const [],
    this.selectedWords = const [],
    this.scenario = 'Daily conversation',
    this.dialogue,
    this.error,
    this.showTranslation = true,
  });

  DialogueState copyWith({
    DialoguePhase? phase,
    int? listId,
    List<Word>? words,
    List<String>? selectedWords,
    String? scenario,
    Dialogue? dialogue,
    String? error,
    bool? showTranslation,
    bool clearError = false,
  }) {
    return DialogueState(
      phase: phase ?? this.phase,
      listId: listId ?? this.listId,
      words: words ?? this.words,
      selectedWords: selectedWords ?? this.selectedWords,
      scenario: scenario ?? this.scenario,
      dialogue: dialogue ?? this.dialogue,
      error: clearError ? null : (error ?? this.error),
      showTranslation: showTranslation ?? this.showTranslation,
    );
  }
}

final dialogueProvider =
    StateNotifierProvider<DialogueNotifier, DialogueState>((ref) {
  return DialogueNotifier(ref);
});

final dialogueScenarios = [
  'Daily conversation',
  'Shopping',
  'Ordering food at a restaurant',
  'At the airport / Travel',
  'Job interview',
  'At the doctor / Hospital',
  'Making a phone call',
  'Asking for directions',
  'At a hotel',
  'Business meeting',
];

class DialogueNotifier extends StateNotifier<DialogueState> {
  final Ref _ref;

  DialogueNotifier(this._ref) : super(const DialogueState());

  Future<void> init(int listId) async {
    final repo = _ref.read(wordListRepositoryProvider);
    final words = await repo.getWordsForList(listId);
    if (words.isEmpty) return;

    state = DialogueState(
      listId: listId,
      words: words,
      selectedWords: words.take(8).map((w) => w.english).toList(),
      scenario: dialogueScenarios.first,
    );
  }

  void toggleWord(String word) {
    final selected = List<String>.from(state.selectedWords);
    if (selected.contains(word)) {
      selected.remove(word);
    } else {
      selected.add(word);
    }
    state = state.copyWith(selectedWords: selected);
  }

  void selectAll() {
    state = state.copyWith(
      selectedWords: state.words.map((w) => w.english).toList(),
    );
  }

  void deselectAll() {
    state = state.copyWith(selectedWords: []);
  }

  void setScenario(String scenario) {
    state = state.copyWith(scenario: scenario);
  }

  void toggleTranslation() {
    state = state.copyWith(showTranslation: !state.showTranslation);
  }

  Future<void> generate() async {
    if (state.selectedWords.isEmpty) {
      state = state.copyWith(error: 'Please select at least one word.');
      return;
    }

    state = state.copyWith(phase: DialoguePhase.generating, clearError: true);

    try {
      final aiService = AiService(_ref.read(settingsRepositoryProvider));
      final provider = await aiService.getProvider();
      final dialogue = await provider.generateDialogue(
          state.selectedWords, state.scenario);
      if (mounted) {
        state = state.copyWith(phase: DialoguePhase.ready, dialogue: dialogue);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          phase: DialoguePhase.error,
          error: 'Failed to generate dialogue: $e',
        );
      }
    }
  }

  void reset() {
    state = const DialogueState();
  }
}
