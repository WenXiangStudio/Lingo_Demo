// Local template-based scenario example generator.
//
// Generates natural English example sentences for vocabulary words using
// pre-written templates matched by part of speech. Deterministic: the same
// word always produces the same sentence. Instant, offline, zero API cost.
//
// Includes word-specific overrides for common words that do not fit templates
// well, and special handling for particle adverbs (off, on, up, etc.).

import 'templates_data.dart';

String generateScenarioExample(String word, String meaning) {
  // 1. Check override map first
  final key = word.toLowerCase();
  if (_overrides.containsKey(key)) return _overrides[key]!;

  // 2. Extract POS
  final pos = _extractPos(meaning);

  // 3. Route particle adverbs specially
  if (pos == 'adv' && _particleAdverbs.contains(key)) {
    final idx = _stableIndex(word, particleAdvTemplates.length);
    return particleAdvTemplates[idx]
        .replaceAll('{word}', word)
        .replaceAll('{Word}', _capitalize(word));
  }

  // 4. Standard template pool
  final templates = _poolForPos(pos);
  if (templates.isEmpty) return '';

  final index = _stableIndex(word, templates.length);
  final template = templates[index];

  return template
      .replaceAll('{word}', word)
      .replaceAll('{Word}', _capitalize(word));
}

// ---------------------------------------------------------------------------
// POS extraction
// ---------------------------------------------------------------------------

final _posRe = RegExp(
  r'^(n|v|vt|vi|adj|adv|prep|pron|num|int|conj|art|aux)\b',
  caseSensitive: false,
);

String _extractPos(String meaning) {
  final m = _posRe.firstMatch(meaning.trim());
  if (m == null) return '';
  final raw = m.group(1)!.toLowerCase();
  if (raw == 'vt' || raw == 'vi') return 'v';
  return raw;
}

List<String> _poolForPos(String pos) {
  switch (pos) {
    case 'n':
      return nounTemplates;
    case 'v':
      return verbTemplates;
    case 'adj':
      return adjTemplates;
    case 'adv':
      return advTemplates;
    case 'prep':
      return prepTemplates;
    case 'pron':
      return pronTemplates;
    default:
      return fallbackTemplates;
  }
}

int _stableIndex(String text, int max) {
  if (max <= 0) return 0;
  int total = 0;
  for (int i = 0; i < text.length; i++) {
    total = (total + text.codeUnitAt(i) * (i + 1)) % 9973;
  }
  return total % max;
}

String _capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

// ---------------------------------------------------------------------------
// Particle adverbs — these need verb-before-adverb patterns, not
// adverb-between-subject-and-verb patterns.
// ---------------------------------------------------------------------------

const _particleAdverbs = {
  'off',
  'on',
  'up',
  'down',
  'out',
  'in',
  'away',
  'back',
  'by',
  'over',
  'through',
  'along',
  'around',
  'about',
  'aside',
  'forth',
  'apart',
  'ahead',
  'behind',
};

// ---------------------------------------------------------------------------
// Word-specific overrides for common words where generic templates fail.
// Sorted alphabetically.
// ---------------------------------------------------------------------------

const _overrides = {
  'abuse': 'We should never abuse our power or take advantage of others.',
  'arise': 'Please let me know if any urgent problems arise during the night.',
  'attribute':
      'She attributes her success to years of hard work and dedication.',
  'besides':
      'I do not feel like going out and besides I have too much work to do.',
  'blank':
      'His mind went completely blank when he stood up to give the speech.',
  'bud': 'The rose buds are just starting to open in the warm spring sunshine.',
  'chin': 'She rested her chin on her hand and stared out the window.',
  'close': 'Please close the door quietly so you do not wake the baby.',
  'clumsy': 'I felt so clumsy when I knocked over the display in the store.',
  'code': 'You need a special code to unlock the door after office hours.',
  'compromise':
      'A good relationship requires compromise and understanding from both sides.',
  'confident':
      'She felt confident and well prepared before her final university exam.',
  'critical':
      'It is critical that we find a solution before the deadline tomorrow.',
  'decay': 'Too much sugar can cause tooth decay over a long period of time.',
  'decline':
      'The company reported a sharp decline in sales during the last quarter.',
  'definition':
      'The dictionary provides a clear definition for each word in the book.',
  'demonstrate':
      'Let me demonstrate how this new coffee machine actually works.',
  'disable':
      'You can disable notifications in the settings menu of your phone.',
  'distress':
      'The ship sent out a distress signal as the storm grew more intense.',
  'division':
      'The company announced a major division restructuring to improve efficiency.',
  'double':
      'Please double check your answers before handing in the exam paper.',
  'economy':
      'The local economy depends heavily on tourism during the summer season.',
  'engage':
      'The teacher used games to engage the students in learning mathematics.',
  'enormous':
      'An enormous whale surfaced right next to our small fishing boat.',
  'envelope':
      'She sealed the envelope carefully and dropped it into the mailbox.',
  'establishment':
      'The restaurant has been a popular establishment in this area since 1995.',
  'exaggerate':
      'He tends to exaggerate his fishing stories to make them more exciting.',
  'exclude':
      'The membership fee seems high but does not exclude anyone from joining.',
  'expectation':
      'The movie exceeded every expectation I had and left me truly amazed.',
  'false': 'The rumors spreading online turned out to be completely false.',
  'farewell':
      'We threw a farewell party for our colleague who was moving abroad.',
  'flat': 'The tire went completely flat after driving over a sharp nail.',
  'forefinger': 'He pointed at the map with his forefinger to show our route.',
  'fragment':
      'I only caught a fragment of their conversation as I walked past.',
  'give': 'She decided to give her old books to the neighborhood library.',
  'granddaughter':
      'My granddaughter drew a colorful picture just for me at kindergarten.',
  'gulf': 'There is a growing gulf between the rich and the poor in society.',
  'hang': 'Please hang your coat on the hook by the front door.',
  'honeymoon': 'They spent their honeymoon on a quiet beach in Thailand.',
  'hydrogen': 'Hydrogen is the most abundant element in the entire universe.',
  'identity':
      'Your passport is the main document used to verify your identity.',
  'installation':
      'The installation of the new software took less than ten minutes.',
  'invariably':
      'She invariably arrives ten minutes early to every single meeting.',
  'lean': 'I like to lean back in my chair and relax after a long day.',
  'loose': 'One of the screws on the chair is loose and needs to be tightened.',
  'makeup': 'She prefers a natural makeup look with just a touch of lipstick.',
  'metric':
      'Most countries use the metric system for measuring distance and weight.',
  'military':
      'He spent twenty years serving in the military before retiring last year.',
  'ministry':
      'The ministry of education announced new reforms for the coming school year.',
  'moist': 'The cake turned out perfectly moist thanks to the extra butter.',
  'murder':
      'The detective spent months investigating the mysterious murder case.',
  'nightmare':
      'Waking up late for the exam was my worst nightmare coming true.',
  'none': 'None of the guests forgot to sign in at the front desk.',
  'occupy': 'Reading and painting occupy most of her free time on weekends.',
  'off': 'Please turn off the lights before you leave the room.',
  'plus':
      'The hotel room costs two hundred dollars per night plus a service fee.',
  'pronounce': 'Can you teach me how to pronounce this French word correctly?',
  'property':
      'They invested all their savings into buying a small property by the lake.',
  'prospect':
      'The prospect of starting a new life abroad was both exciting and terrifying.',
  'punctual':
      'Being punctual shows respect for other people time and schedule.',
  'raise':
      'The company decided to raise all employee salaries by five percent.',
  'ratio': 'The ideal ratio of water to rice is two to one.',
  'revenge':
      'He swore to take revenge on the people who had wronged his family.',
  'saddle': 'He adjusted the saddle on his bike before the long ride ahead.',
  'satellite':
      'The satellite orbits the Earth every ninety minutes collecting weather data.',
  'slam': 'Do not slam the door when you leave or you will wake the baby.',
  'specify':
      'Please specify your dietary requirements when you register for the event.',
  'splendid':
      'The view from the mountaintop was absolutely splendid at sunrise.',
  'stiff': 'My neck feels stiff after sitting at the computer all day.',
  'takeoff':
      'The plane accelerated down the runway in preparation for takeoff.',
  'thrive':
      'With enough sunlight and water these plants will thrive beautifully.',
  'tolerate':
      'I cannot tolerate loud chewing noises when I am trying to concentrate.',
  'torture':
      'Waiting for the exam results was pure torture for the anxious students.',
  'transform':
      'A fresh coat of paint can completely transform the look of a room.',
  'trim': 'I need to trim the hedge before it grows over the garden path.',
  'undergo':
      'All new employees must undergo a thorough background check before starting.',
  'undertake':
      'We are about to undertake a major renovation of the old building.',
  'union':
      'The labor union negotiated better working conditions for all factory employees.',
  'unique': 'Each snowflake has a unique pattern that will never be repeated.',
  'vain':
      'All his efforts proved vain when the project was suddenly cancelled.',
  'vibrate': 'My phone started to vibrate during the meeting so I silenced it.',
  'virus':
      'The computer virus infected thousands of machines within the first few hours.',
  'vocabulary':
      'Reading books is a great way to expand your English vocabulary.',
  'wicked':
      'The witch in the fairy tale was truly wicked and cruel to children.',
};
