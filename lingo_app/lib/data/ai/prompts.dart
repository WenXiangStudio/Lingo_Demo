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
}
