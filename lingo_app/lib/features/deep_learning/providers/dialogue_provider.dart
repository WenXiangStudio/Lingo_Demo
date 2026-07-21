import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/ai/ai_service.dart';
import '../../../data/database/app_database.dart';
import '../../../data/language_tool/language_tool_client.dart';
import '../../../data/models/ai_models.dart';
import '../../../data/providers.dart';

enum DialoguePhase { setup, starting, active, sending, complete, error }

class DialogueScenario {
  final String id;
  final String labelKey;
  final String prompt;

  const DialogueScenario({
    required this.id,
    required this.labelKey,
    required this.prompt,
  });
}

const defaultDialogueScenario = DialogueScenario(
  id: 'daily',
  labelKey: 'dialogue_scenario_daily',
  prompt: 'Daily conversation',
);

const dialogueScenarios = [
  defaultDialogueScenario,
  DialogueScenario(
    id: 'shopping',
    labelKey: 'dialogue_scenario_shopping',
    prompt: 'Shopping',
  ),
  DialogueScenario(
    id: 'restaurant',
    labelKey: 'dialogue_scenario_restaurant',
    prompt: 'Ordering food at a restaurant',
  ),
  DialogueScenario(
    id: 'travel',
    labelKey: 'dialogue_scenario_travel',
    prompt: 'At the airport or while traveling',
  ),
  DialogueScenario(
    id: 'interview',
    labelKey: 'dialogue_scenario_interview',
    prompt: 'Job interview',
  ),
  DialogueScenario(
    id: 'doctor',
    labelKey: 'dialogue_scenario_doctor',
    prompt: 'At the doctor or hospital',
  ),
  DialogueScenario(
    id: 'phone',
    labelKey: 'dialogue_scenario_phone',
    prompt: 'Making a phone call',
  ),
  DialogueScenario(
    id: 'directions',
    labelKey: 'dialogue_scenario_directions',
    prompt: 'Asking for directions',
  ),
  DialogueScenario(
    id: 'hotel',
    labelKey: 'dialogue_scenario_hotel',
    prompt: 'At a hotel',
  ),
  DialogueScenario(
    id: 'meeting',
    labelKey: 'dialogue_scenario_meeting',
    prompt: 'Business meeting',
  ),
];

class DialogueState {
  final DialoguePhase phase;
  final int? listId;
  final List<Word> words;
  final List<String> selectedWords;
  final DialogueScenario scenario;
  final String title;
  final String aiRole;
  final String userRole;
  final List<InteractiveDialogueMessage> messages;
  final InteractiveDialogueFeedback? latestFeedback;
  final List<InteractiveDialogueFeedback> feedbacks;
  final List<String> usedWords;
  final List<String> nextTargetWords;
  final LanguageToolResult? latestLanguageToolResult;
  final String? errorKey;
  final Map<String, String> errorParams;
  final bool showTranslation;
  final int maxTurns;

  const DialogueState({
    this.phase = DialoguePhase.setup,
    this.listId,
    this.words = const [],
    this.selectedWords = const [],
    this.scenario = defaultDialogueScenario,
    this.title = '',
    this.aiRole = 'AI',
    this.userRole = 'You',
    this.messages = const [],
    this.latestFeedback,
    this.feedbacks = const [],
    this.usedWords = const [],
    this.nextTargetWords = const [],
    this.latestLanguageToolResult,
    this.errorKey,
    this.errorParams = const {},
    this.showTranslation = true,
    this.maxTurns = 6,
  });

  int get turnCount => feedbacks.length;

  bool get canSend =>
      phase == DialoguePhase.active &&
      messages.isNotEmpty &&
      turnCount < maxTurns;

  DialogueState copyWith({
    DialoguePhase? phase,
    int? listId,
    List<Word>? words,
    List<String>? selectedWords,
    DialogueScenario? scenario,
    String? title,
    String? aiRole,
    String? userRole,
    List<InteractiveDialogueMessage>? messages,
    InteractiveDialogueFeedback? latestFeedback,
    List<InteractiveDialogueFeedback>? feedbacks,
    List<String>? usedWords,
    List<String>? nextTargetWords,
    LanguageToolResult? latestLanguageToolResult,
    String? errorKey,
    Map<String, String>? errorParams,
    bool? showTranslation,
    int? maxTurns,
    bool clearError = false,
    bool clearLatestFeedback = false,
    bool clearLatestLanguageToolResult = false,
  }) {
    return DialogueState(
      phase: phase ?? this.phase,
      listId: listId ?? this.listId,
      words: words ?? this.words,
      selectedWords: selectedWords ?? this.selectedWords,
      scenario: scenario ?? this.scenario,
      title: title ?? this.title,
      aiRole: aiRole ?? this.aiRole,
      userRole: userRole ?? this.userRole,
      messages: messages ?? this.messages,
      latestFeedback: clearLatestFeedback
          ? null
          : (latestFeedback ?? this.latestFeedback),
      feedbacks: feedbacks ?? this.feedbacks,
      usedWords: usedWords ?? this.usedWords,
      nextTargetWords: nextTargetWords ?? this.nextTargetWords,
      latestLanguageToolResult: clearLatestLanguageToolResult
          ? null
          : (latestLanguageToolResult ?? this.latestLanguageToolResult),
      errorKey: clearError ? null : (errorKey ?? this.errorKey),
      errorParams: clearError ? const {} : (errorParams ?? this.errorParams),
      showTranslation: showTranslation ?? this.showTranslation,
      maxTurns: maxTurns ?? this.maxTurns,
    );
  }
}

final dialogueProvider = StateNotifierProvider<DialogueNotifier, DialogueState>(
  (ref) {
    return DialogueNotifier(ref);
  },
);

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
      selectedWords: words.take(5).map((w) => w.english).toList(),
      scenario: defaultDialogueScenario,
    );
  }

  void toggleWord(String word) {
    final selected = List<String>.from(state.selectedWords);
    if (selected.contains(word)) {
      selected.remove(word);
      state = state.copyWith(selectedWords: selected, clearError: true);
      return;
    }
    if (selected.length >= 5) {
      state = state.copyWith(errorKey: 'dialogue_error_max_words');
      return;
    }
    selected.add(word);
    state = state.copyWith(selectedWords: selected, clearError: true);
  }

  void selectRecommended() {
    state = state.copyWith(
      selectedWords: state.words.take(5).map((w) => w.english).toList(),
      clearError: true,
    );
  }

  void deselectAll() {
    state = state.copyWith(selectedWords: [], clearError: true);
  }

  void setScenario(DialogueScenario scenario) {
    state = state.copyWith(scenario: scenario, clearError: true);
  }

  void toggleTranslation() {
    state = state.copyWith(showTranslation: !state.showTranslation);
  }

  Future<void> startPractice() async {
    if (state.selectedWords.length < 3) {
      state = state.copyWith(errorKey: 'dialogue_error_min_words');
      return;
    }

    state = state.copyWith(
      phase: DialoguePhase.starting,
      clearError: true,
      clearLatestFeedback: true,
      messages: const [],
      feedbacks: const [],
      usedWords: const [],
      nextTargetWords: const [],
      clearLatestLanguageToolResult: true,
    );

    try {
      final aiService = AiService(_ref.read(settingsRepositoryProvider));
      final provider = await aiService.getProvider();
      final start = await provider.startInteractiveDialogue(
        state.selectedWords,
        state.scenario.prompt,
      );
      if (!mounted) return;

      final opening = InteractiveDialogueMessage(
        speaker: start.aiRole,
        english: start.openingLine,
        chineseTranslation: start.openingTranslation,
        isUser: false,
      );
      state = state.copyWith(
        phase: DialoguePhase.active,
        title: start.title,
        aiRole: start.aiRole,
        userRole: start.userRole,
        messages: [opening],
        nextTargetWords: _validTargetWords(start.suggestedTargetWords),
        clearError: true,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        phase: DialoguePhase.error,
        errorKey: 'dialogue_start_failed',
        errorParams: {'error': e.toString()},
      );
    }
  }

  Future<void> sendReply(String reply) async {
    final trimmed = reply.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(errorKey: 'dialogue_error_empty_reply');
      return;
    }
    if (!state.canSend) return;

    final previousState = state;
    state = state.copyWith(phase: DialoguePhase.sending, clearError: true);

    try {
      final aiService = AiService(_ref.read(settingsRepositoryProvider));
      final provider = await aiService.getProvider();
      final languageToolResult = await _checkReplyWithLanguageTool(trimmed);
      final grammarContext = await _grammarContextForReply(
        trimmed,
        languageToolResult: languageToolResult,
      );
      final turn = await provider.continueInteractiveDialogue(
        words: previousState.selectedWords,
        scenario: previousState.scenario.prompt,
        history: previousState.messages,
        userReply: trimmed,
        usedWords: previousState.usedWords,
        grammarContext: grammarContext,
      );
      if (!mounted) return;

      final feedback = _validatedFeedback(turn.feedback);
      final usedWords = _mergeUsedWords(
        previousState.usedWords,
        feedback.usedWords,
      );
      final messages = [
        ...previousState.messages,
        InteractiveDialogueMessage(
          speaker: previousState.userRole,
          english: trimmed,
          chineseTranslation: turn.userTranslation,
          isUser: true,
        ),
        InteractiveDialogueMessage(
          speaker: previousState.aiRole,
          english: turn.aiReply,
          chineseTranslation: turn.aiTranslation,
          isUser: false,
        ),
      ];
      final feedbacks = [...previousState.feedbacks, feedback];
      final isComplete =
          feedbacks.length >= previousState.maxTurns ||
          usedWords.length >= previousState.selectedWords.length;

      state = previousState.copyWith(
        phase: isComplete ? DialoguePhase.complete : DialoguePhase.active,
        messages: messages,
        latestFeedback: feedback,
        latestLanguageToolResult: languageToolResult,
        feedbacks: feedbacks,
        usedWords: usedWords,
        nextTargetWords: _validTargetWords(feedback.nextTargetWords),
        clearError: true,
      );
    } catch (e) {
      if (!mounted) return;
      state = previousState.copyWith(
        phase: DialoguePhase.error,
        errorKey: 'dialogue_turn_failed',
        errorParams: {'error': e.toString()},
      );
    }
  }

  void backToSetup() {
    state = DialogueState(
      listId: state.listId,
      words: state.words,
      selectedWords: state.selectedWords,
      scenario: state.scenario,
      showTranslation: state.showTranslation,
    );
  }

  Future<String?> _grammarContextForReply(
    String reply, {
    LanguageToolResult? languageToolResult,
  }) async {
    final contexts = <String>[];
    final languageToolContext = languageToolResult?.toPromptContext(reply);
    if (languageToolContext != null && languageToolContext.trim().isNotEmpty) {
      contexts.add(languageToolContext);
    }
    try {
      final bundle = await _ref
          .read(retrievalV2ClientProvider)
          .buildBundle(
            query: 'How do I correct "$reply"?',
            topK: 5,
            candidateK: 20,
            maxEvidenceExamples: 2,
          );
      final context = bundle.toPromptContext(
        maxCards: 2,
        maxExamplesPerCard: 2,
      );
      if (context.isNotEmpty) contexts.add(context);
    } catch (_) {
      // Retrieval is optional context for AI feedback.
    }
    return contexts.isEmpty ? null : contexts.join('\n\n');
  }

  Future<LanguageToolResult?> _checkReplyWithLanguageTool(String reply) async {
    final settingsRepo = _ref.read(settingsRepositoryProvider);
    final enabled = await settingsRepo.getLanguageToolEnabled();
    if (!enabled) return null;
    try {
      final client = await _ref.read(languageToolClientProvider.future);
      return client.check(reply);
    } catch (e) {
      return LanguageToolResult.failed(e.toString());
    }
  }

  List<String> _validTargetWords(List<String> words) {
    final selected = state.selectedWords.map((w) => w.toLowerCase()).toSet();
    return words
        .where((word) => selected.contains(word.toLowerCase()))
        .toList(growable: false);
  }

  InteractiveDialogueFeedback _validatedFeedback(
    InteractiveDialogueFeedback feedback,
  ) {
    return InteractiveDialogueFeedback(
      usedWords: _validTargetWords(feedback.usedWords),
      missedOpportunityWords: _validTargetWords(
        feedback.missedOpportunityWords,
      ),
      nextTargetWords: _validTargetWords(feedback.nextTargetWords),
      naturalnessScore: feedback.naturalnessScore,
      contextFitScore: feedback.contextFitScore,
      correction: feedback.correction,
      betterVersion: feedback.betterVersion,
      chineseExplanation: feedback.chineseExplanation,
    );
  }

  List<String> _mergeUsedWords(List<String> current, List<String> latest) {
    final selectedByLower = {
      for (final word in state.selectedWords) word.toLowerCase(): word,
    };
    final merged = <String>{...current};
    for (final word in latest) {
      final selected = selectedByLower[word.toLowerCase()];
      if (selected != null) merged.add(selected);
    }
    return merged.toList(growable: false);
  }
}
