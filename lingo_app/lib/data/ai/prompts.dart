class AiPrompts {
  AiPrompts._();

  static String collocationsPrompt(List<String> words) {
    final wordList = words.map((w) => '- $w').join('\n');
    return '''You are an English language teacher helping students learn vocabulary through collocations.

For each of the following words, generate 2-3 common English collocations (固定搭配).

A collocation is a natural combination of words that native speakers commonly use together. Types include:
- adjective + noun (e.g., heavy traffic, strong coffee)
- verb + noun (e.g., make a decision, take a photo)
- noun + verb (e.g., war breaks out, the wind blows)
- adverb + adjective (e.g., deeply disappointed, bitterly cold)
- verb + preposition / phrasal verb (e.g., look forward to, give up)

Words to generate collocations for:
$wordList

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

  static String sentencesPrompt(List<String> words) {
    final wordList = words.map((w) => '- $w').join('\n');
    return '''You are an English language teacher. For each of the following words, generate one natural example sentence that demonstrates typical usage.

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
