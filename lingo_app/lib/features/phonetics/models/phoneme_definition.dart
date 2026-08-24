enum PhonemeGroup {
  monophthongs('phonetics_monophthongs'),
  diphthongs('phonetics_diphthongs'),
  consonants('phonetics_consonants');

  const PhonemeGroup(this.labelKey);

  final String labelKey;
}

class PhonemeDefinition {
  const PhonemeDefinition({
    required this.id,
    required this.symbol,
    required this.example,
    required this.group,
  });

  final String id;
  final String symbol;
  final String example;
  final PhonemeGroup group;

  String get assetPath => 'assets/phonetics/british/$id.wav';
}
