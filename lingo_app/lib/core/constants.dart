class AppConstants {
  AppConstants._();

  static const String appName = 'LingoDemo';

  // Practice modes
  static const String modeChoice = 'choice';
  static const String modeFill = 'fill';
  static const String modeDictation = 'dictation';
  static const String modeDeepChoice = 'deep_choice';
  static const String modeDeepFill = 'deep_fill';

  // AI content types
  static const String aiCollocation = 'collocation';
  static const String aiSentence = 'sentence';
  static const String aiDialogue = 'dialogue';

  // Defaults
  static const double defaultPassThreshold = 0.75;
  static const int defaultListSize = 30;
  static const int shuffleCooldownSeconds = 10;

  // Threshold range
  static const double minPassThreshold = 0.50;
  static const double maxPassThreshold = 1.00;

  // Meaning separator
  static const String meaningSeparator = '；';
}
