import 'dart:convert';

import '../models/ai_models.dart';

class AiPrompts {
  AiPrompts._();

  static String collocationsPrompt(
    List<String> words, {
    Map<String, String> targetMeanings = const {},
  }) {
    final vocabulary = const JsonEncoder.withIndent('  ').convert([
      for (final word in words)
        {
          'word': word,
          'dictionary_chinese_meanings': targetMeanings[word] ?? '',
        },
    ]);
    return '''You are an English language teacher helping students learn vocabulary through collocations.

For each vocabulary record below, generate exactly 3 common, useful English collocation chunks (固定搭配).

A collocation is a natural combination of words that native speakers commonly use together. Types include:
- adjective + noun (e.g., heavy traffic, strong coffee)
- verb + noun (e.g., make a decision, take a photo)
- noun + verb (e.g., war breaks out, the wind blows)
- adverb + adjective (e.g., deeply disappointed, bitterly cold)

Rules:
- Vary the three entries in structure, context, and partner words whenever possible.
- Prefer useful chunks of 2-5 words. An extended chunk such as "make an informed decision" is welcome when natural.
- The dictionary_chinese_meanings field is the vocabulary sense the learner is studying. Use only one of those senses for the target word.
- Prefer transparent lexical collocations whose Chinese translation makes that target-word sense explicit. The translation must include the provided Chinese meaning itself or a directly derived phrase, such as "野鸭" for the meaning "鸭".
- Never use an idiom, slang, proverb, figurative phrasal verb, or opaque fixed expression when its natural Chinese translation hides the target word's studied meaning.
- For example, when duck means "鸭；鸭子；鸭肉", return entries such as "wild duck" or "roast duck". Never return "duck out of" with a translation such as "逃避".
- Do not return a bare dictionary definition, a full sentence, or a generic template repeated for every word.
- Each chunk must contain the original target word in the same spelling, and chinese_translation must explain the same studied sense.

Vocabulary records to generate collocations for:
$vocabulary

Return ONLY a JSON array in this format:
[
  {
    "word": "<the original word>",
    "collocations": [
      {"english": "<collocation>", "chinese_translation": "<中文翻译>", "collocation_type": "<type>"}
    ]
  }
]''';
  }

  static String collocationOptionValidationPrompt(
    List<CollocationOptionRequest> requests, {
    bool jsonObjectWrapper = false,
  }) {
    final requestJson = jsonEncode(
      requests.map((request) => request.toPromptJson()).toList(),
    );
    final responseFormat = jsonObjectWrapper
        ? '''Return ONLY this JSON object:
{"items":[{"word_id":123,"distractors":["word1","word2","word3"]}]}'''
        : '''Return ONLY this JSON array:
[
  {"word_id": 123, "distractors": ["word1", "word2", "word3"]}
]''';
    return '''You are quality-checking multiple-choice English collocation questions.

For every request below, select 3-4 safe distractors ONLY from its candidate_words.

Rules:
- Never invent a word and never return the target_word.
- A distractor should be tempting enough to fit the blank grammatically when possible, but it MUST NOT make the original collocation a natural or acceptable alternative.
- Do not select a synonym, near-synonym, alternate word choice, or another answer that would make the completed phrase correct. For example, do not use "small" as a wrong option for a sentence where it naturally works instead of "tiny".
- Return fewer than 3 distractors rather than returning an ambiguous one.
- Keep the request word_id unchanged.

Requests:
$requestJson

$responseFormat''';
  }

  static String sentencesPrompt(List<String> words) {
    final wordList = words.map((w) => '- $w').join('\n');
    return '''You are an English language teacher. For each of the following words, generate exactly 3 natural example sentences that demonstrate typical usage.

Across the three sentences for each word, deliberately vary sentence structure, tense, subject, setting, and register. Use concrete situations from everyday life, study, work, travel, or relationships. Avoid repetitive teaching templates such as repeated "so ... that ...", "This is ...", or generic kitten/family examples. Keep every sentence clear, idiomatic, and useful for Chinese-speaking learners.

Each sentence must contain the original target word in the same spelling. Do not make a sentence whose blank has an obviously equally valid synonym unless that alternative is also genuinely useful to discuss.

Words:
$wordList

Return ONLY a JSON array:
[
  {
    "word": "<the original word>",
    "sentences": [
      {"english": "<sentence>", "chinese_translation": "<中文翻译>"}
    ]
  }
]''';
  }

  static String fillAnswerEvaluationPrompt({
    required String sentenceWithBlank,
    required String targetWord,
    required String userAnswer,
  }) {
    return '''You are checking a vocabulary cloze answer from an English learner.

Sentence with one blank:
$sentenceWithBlank

The exercise target word is: $targetWord
The learner entered: $userAnswer

Decide whether the learner's answer is a grammatically and semantically acceptable alternative in this exact sentence. It can be acceptable even when it is not the target word, such as a genuine synonym. Do NOT accept a spelling mistake, an answer that changes the intended grammar, or an unnatural/incorrect sentence.

Return ONLY a JSON object:
{
  "classification": "acceptable_alternative" or "incorrect",
  "is_acceptable_alternative": true or false,
  "feedback": "<brief Chinese explanation, max 24 Chinese characters>"
}''';
  }

  static String idiomsPrompt(List<String> words) {
    final wordList = words.map((w) => '- $w').join('\n');
    return '''You are an English language teacher specialising in idiomatic English (俗语谚语). For each of the following words, generate ONE English idiom, fixed phrase, or proverb that naturally contains the word.

Prefer well-known idioms / proverbs. If the word doesn't fit a real idiom, generate a common fixed phrase that uses it figuratively. The output must follow the same JSON shape as sentences.

Words:
$wordList

Return ONLY a JSON array:
[
  {
    "word": "<the original word>",
    "sentences": [
      {"english": "<idiom or proverb>", "chinese_translation": "<中文翻译/解释>"}
    ]
  }
]''';
  }

  static String scenarioPrompt(String word, String meaning) {
    return 'Write a natural English sentence using the word "$word" (meaning: $meaning). '
        'Keep it under 20 words, show everyday usage. '
        'Return ONLY a JSON array: ["<your sentence here>"]';
  }

  static String dialoguePrompt(List<String> words, String scenario) {
    final wordList = words.map((w) => '- $w').join('\n');
    return '''You are an English language teacher. Create a realistic dialogue in the scenario: "$scenario".

Incorporate these vocabulary words naturally into the dialogue:
$wordList

Return ONLY a JSON object:
{
  "title": "<dialogue title>",
  "lines": [
    {"speaker": "<name>", "english": "<line>", "chinese_translation": "<中文翻译>"}
  ]
}''';
  }

  static String interactiveDialogueStartPrompt(
    List<String> words,
    String scenario,
  ) {
    final wordList = words.map((w) => '- $w').join('\n');
    return '''You are an English speaking-practice coach for Chinese-speaking vocabulary learners.

Start a short role-play conversation for this scenario:
$scenario

Target words:
$wordList

Rules:
- Create a realistic role-play, not a full scripted dialogue.
- The AI should speak first with one natural opening line.
- Do not use every target word in the opening line.
- Keep the opening line under 22 words.
- The user will reply in English in later turns.
- suggested_target_words should contain 1-2 useful words for the user's next reply.

Return ONLY a JSON object:
{
  "title": "<short role-play title>",
  "ai_role": "<AI role name>",
  "user_role": "<user role name>",
  "opening_line": "<AI opening line>",
  "opening_translation": "<中文翻译>",
  "suggested_target_words": ["<word>", "<word>"]
}''';
  }

  static String interactiveDialogueTurnPrompt({
    required List<String> words,
    required String scenario,
    required List<Map<String, dynamic>> history,
    required String userReply,
    required List<String> usedWords,
    String? grammarContext,
  }) {
    final wordList = words.map((w) => '- $w').join('\n');
    final historyJson = const JsonEncoder.withIndent('  ').convert(history);
    final usedWordList = usedWords.isEmpty
        ? 'None yet'
        : usedWords.map((w) => '- $w').join('\n');
    final grammarBlock = grammarContext == null || grammarContext.trim().isEmpty
        ? ''
        : '''

Grammar reference for the user's latest reply:
${grammarContext.trim()}

Use this reference only when it is relevant to the user's grammar, correction,
better_version, or Chinese explanation. Do not mention internal card IDs to the
learner.
''';
    return '''You are an English speaking-practice coach for Chinese-speaking vocabulary learners.

Continue this interactive role-play.

Scenario:
$scenario

Target words:
$wordList

Already used target words:
$usedWordList

Conversation history:
$historyJson

User's latest reply:
$userReply
$grammarBlock

Rules:
- Reply as the AI role with exactly one natural English line.
- Keep ai_reply under 24 words.
- Do not end the role-play unless the user's reply clearly closes it.
- Evaluate only the user's latest reply.
- used_words must include only target words the user used correctly or nearly correctly in the latest reply.
- missed_opportunity_words should include 0-2 target words that would fit naturally next.
- next_target_words should include 1-2 target words for the user's next reply.
- correction is empty if there is no clear grammar/collocation error.
- better_version is empty if the user's reply is already natural.
- If a grammar reference is provided and relevant, use it to make the feedback more precise.
- Scores are integers from 1 to 5.
- Keep chinese_explanation short and practical.

Return ONLY a JSON object:
{
  "user_translation": "<中文翻译 of the user's latest reply>",
  "ai_reply": "<AI's next English line>",
  "ai_translation": "<中文翻译 of ai_reply>",
  "feedback": {
    "used_words": ["<target word used by user>"],
    "missed_opportunity_words": ["<target word that could fit next>"],
    "next_target_words": ["<target word to try next>"],
    "naturalness_score": 4,
    "context_fit_score": 5,
    "correction": "<brief correction or empty string>",
    "better_version": "<more natural version or empty string>",
    "chinese_explanation": "<简短中文反馈>"
  }
}''';
  }

  static String wordStoryPrompt(List<String> words) {
    final wordList = words.map((w) => '- $w').join('\n');
    return '''You are an English language teacher helping Chinese-speaking students remember vocabulary.

Create one short, natural English story that uses these words:
$wordList

Rules:
- Use every word naturally.
- Keep the English story under 140 words.
- Make it clear and useful for vocabulary review.
- Provide a fluent Chinese translation.
- Provide translation_alignments for Chinese highlighting.
- For each vocabulary word, set chinese_span to the exact Chinese phrase copied
  from chinese_translation that expresses the word in this story context.
- Do not force dictionary meanings into the story or translation; use the
  contextual Chinese meaning from the fluent translation.

Return ONLY a JSON object:
{
  "title": "<short story title>",
  "english": "<English story>",
  "chinese_translation": "<中文翻译>",
  "translation_alignments": [
    {"word": "<original word>", "chinese_span": "<exact substring from chinese_translation>"}
  ]
}''';
  }

  static String narrationTargetPrompt({
    required String transcript,
    required String chineseTranslation,
    required String accent,
    required String register,
  }) {
    final input = jsonEncode({
      'corrected_or_user_cleaned_transcript': transcript,
      'user_confirmed_chinese_intent': chineseTranslation,
      'accent': accent,
      'register': register,
    });
    return '''You are preparing the English intent anchor for a spoken-English learner.

The user-confirmed Chinese translation is the ONLY authority for intended meaning. English grammar, usage, collocation, spelling and naturalness are judged only by English rules. Do not silently reconcile a serious conflict between the Chinese intent and the transcript: report it for user confirmation.

Input:
$input

Requirements:
- Produce one main recommended English rendering of every idea in the confirmed Chinese material.
- Default to idiomatic British English and a natural spoken register unless the input explicitly requests another accent or register.
- Preserve tone, emphasis and reasonable personal speaking style. Do not turn ordinary speech into academic prose.
- You may provide at most two genuinely useful acceptable alternatives. Explain only their material difference (wording, order, tone or formality).
- A Chinese word or short phrase embedded in otherwise English speech is evidence of missing English vocabulary, not an error by itself.
- Set conflict_detected when transcript and Chinese intent differ materially. Explain the exact conflict without guessing which is right.

Mandatory output-language contract:
- All user-facing analysis or explanatory prose MUST be written in Simplified Chinese, regardless of the app interface language.
- In this response, alternatives[].difference and conflict_message MUST be Simplified Chinese.
- Keep recommended and alternatives[].text in English because they are English expressions being learned.
- Do not return English explanatory prose in any Chinese-required field.

Return ONLY this JSON object:
{
  "recommended": "<complete target English expression>",
  "alternatives": [
    {"text": "<acceptable alternative in English>", "difference": "<用简体中文说明差异>"}
  ],
  "conflict_detected": false,
  "conflict_message": "<如有冲突，用简体中文说明；否则为空>",
  "needs_user_confirmation": false
}''';
  }

  static String narrationAnalysisPrompt({
    required String rawTranscript,
    required String cleanedTranscript,
    required String chineseTranslation,
    required String targetEnglish,
    required String accent,
    required String register,
    required List<Map<String, dynamic>> existingLearningItems,
  }) {
    final input = const JsonEncoder.withIndent('  ').convert({
      'raw_transcript': rawTranscript,
      'user_cleaned_transcript': cleanedTranscript,
      'user_confirmed_chinese_intent': chineseTranslation,
      'user_confirmed_target_english': targetEnglish,
      'accent': accent,
      'register': register,
      'existing_learning_items': existingLearningItems,
    });
    return '''You are the deterministic analysis engine for a spoken-English learning product. Analyse the supplied record completely and return structured data only.

Two-track standard:
1. The user-confirmed Chinese material is the ONLY authority for what the user intended.
2. English rules are the ONLY authority for whether the English form is correct and idiomatic.

Mandatory output-language contract:
- ALL user-facing analysis, diagnosis, reasons, explanations, notes, labels and self-check prose MUST be written in Simplified Chinese, regardless of the app interface language.
- The following fields MUST be Simplified Chinese whenever non-empty:
  sentence_pairs[].differences[].reason;
  errors[].issue and errors[].reason;
  collected_words[].part_of_speech and collected_words[].note;
  knowledge_points[].title and knowledge_points[].explanation;
  speech_features[].type and speech_features[].note;
  acceptable_variants[].difference;
  self_check.checks[].detail, self_check.modifications[], self_check.uncertainties[], self_check.target_difference and self_check.naturalness_basis.
- Keep raw/cleaned/original English spans, corrected English spans, target expressions, corrected_expression, acceptable_variants[].text, collected_words[].english, stable keys and exact evidence in their source/English form.
- Do not return English explanatory prose in any Chinese-required field. English linguistic tokens such as “a/an”, quoted source words or corrected example fragments may appear inside an otherwise Chinese explanation when necessary.

Input:
$input

Alignment and cleaning:
- Preserve raw_transcript conceptually; never rewrite it in place.
- Build normalized_transcript by removing meaningless repetitions, fillers and abandoned fragments when safe.
- Keep emphatic repetition. For self-correction, keep the final intended part but analyse the discarded error when useful.
- Align against both Chinese intent and the confirmed target English.

Error analysis:
- List EVERY A, B and C issue. A blocks understanding or changes core meaning. B is a clear grammar/usage error. C is grammatical but unnatural or worth optimising. Keep C separate through its grade.
- Never list D-level spoken phenomena (fillers, pauses, meaningless repetition, self-correction) as errors. Put them only in speech_features.
- A Chinese substitute itself is NOT an error and must not be described as code-switching, spelling, grammar or usage error.
- English grammar around a substitute is still analysed using the intended English replacement. Example: "a 苹果" yields apple in collected_words and an a/an B error.
- Sort errors by grade A, B, C, then communication impact, recurrence, relation to a Chinese substitute, and foundational impact.

Word collection:
- Collect a Chinese word or short/fixed phrase used where English was intended. Use the British-English lemma as stable_key.
- Do not collect an entire Chinese sentence; the target expression handles it.
- Function words, proper nouns, numbers and time expressions are allowed and must have a category.
- Do not force a translation for a Chinese particle with no English equivalent.
- Do not collect redundant Chinese repetition after an already correct English word unless the evidence clearly shows replacement intent.

Knowledge points:
- Include only points directly driven by an error, collected word, or C-level optimisation. Do not decompose every correct target sentence.
- Deduplicate by stable_key. Levels: core, related, extended. Core is review-required; related/extended are optional and normally review_required=false.
- D-level speech features are never formal knowledge points and never review tasks.

Corrected expression and self-check:
- Produce one main corrected_expression faithful to Chinese intent, English rules and the user's reasonable spoken style.
- Default to idiomatic British spoken English.
- Optionally give at most two acceptable variants with a short material distinction.
- Internally self-check semantics, form, naturalness, consistency with target English, and preservation of style. Correct problems and iterate at most three times.
- Report all five checks. If still uncertain after three iterations, set needs_user_confirmation and describe the uncertainty; do not fabricate certainty.

Real-use detection:
- Compare this natural, unprompted narration with existing_learning_items.
- Emit success only when an existing item is used spontaneously, correctly and naturally.
- Emit failure when a known word is again replaced in Chinese or a known knowledge error clearly recurs.
- No mention means no event. Do not treat a forced, unnatural insertion as success.

Metrics:
- english_word_count counts English words in normalized_transcript.
- sentence_count counts meaningful spoken sentences.
- chinese_substitute_count counts only collected substitutes, not whole Chinese sentences.
- complexity is a conservative 0-100 structural indicator used only for trends, never an absolute ability score.

Return ONLY this JSON object, with empty arrays rather than omitted fields:
{
  "normalized_transcript": "<clean aligned transcript>",
  "sentence_pairs": [
    {
      "original": "<original sentence>",
      "corrected": "<corrected sentence>",
      "differences": [
        {
          "original": "<changed or empty span>",
          "corrected": "<replacement or empty span>",
          "type": "chinese_substitute|grammar|addition|deletion|naturalness",
          "reason": "<用简体中文简要解释原因>"
        }
      ]
    }
  ],
  "errors": [
    {
      "grade": "A|B|C",
      "original": "<source span or sentence>",
      "issue": "<用简体中文说明具体问题>",
      "correction": "<correct expression>",
      "reason": "<用简体中文解释修改原因>",
      "sentence_index": 0
    }
  ],
  "collected_words": [
    {
      "stable_key": "<British lemma or canonical phrase>",
      "chinese": "<exact substitute>",
      "english": "<context-correct English>",
      "part_of_speech": "<用简体中文写词性>",
      "category": "word|phrase|function_word|proper_noun|number|time",
      "note": "<用简体中文写简短语境说明>"
    }
  ],
  "knowledge_points": [
    {
      "stable_key": "<short stable snake_case identifier>",
      "title": "<用简体中文概括知识点，可保留必要的英文术语>",
      "explanation": "<用简体中文解释相关知识>",
      "level": "core|related|extended",
      "source": "error|word|optimisation",
      "review_required": true,
      "error_grade": "A|B|C|"
    }
  ],
  "speech_features": [
    {"type": "<用简体中文写D级口语现象>", "example": "<source span>", "note": "<用简体中文写简短说明>"}
  ],
  "corrected_expression": "<main recommendation>",
  "acceptable_variants": [
    {"text": "<English variant>", "difference": "<用简体中文说明措辞、语序、语气或正式程度差异>"}
  ],
  "self_check": {
    "iterations": 1,
    "needs_user_confirmation": false,
    "checks": [
      {"key": "semantics", "passed": true, "detail": "<用简体中文说明检查结果>"},
      {"key": "form", "passed": true, "detail": "<用简体中文说明检查结果>"},
      {"key": "naturalness", "passed": true, "detail": "<用简体中文说明检查结果>"},
      {"key": "consistency", "passed": true, "detail": "<用简体中文说明检查结果>"},
      {"key": "style", "passed": true, "detail": "<用简体中文说明检查结果>"}
    ],
    "modifications": ["<用简体中文说明自检时所做修改>"],
    "uncertainties": [],
    "target_difference": "<用简体中文说明与目标表达的显著差异；无差异则为空>",
    "naturalness_basis": "<用简体中文简述英式口语地道性依据>"
  },
  "metrics": {
    "english_word_count": 0,
    "sentence_count": 0,
    "chinese_substitute_count": 0,
    "error_a_count": 0,
    "error_b_count": 0,
    "error_c_count": 0,
    "complexity": 0
  },
  "real_usage_events": [
    {
      "item_type": "word|knowledge",
      "stable_key": "<existing stable_key only>",
      "outcome": "success|failure",
      "evidence": "<exact evidence>",
      "guided": false
    }
  ]
}''';
  }
}
