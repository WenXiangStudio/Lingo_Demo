import '../models/speaking_models.dart';

class SpeakingAlignment {
  const SpeakingAlignment._();

  static SpeakingAssessmentResult assess({
    required String referenceText,
    required String transcript,
  }) {
    final referenceTokens = _tokenize(referenceText);
    final spokenTokens = _tokenize(transcript);
    final alignment = _align(referenceTokens, spokenTokens);

    final tokenResults = <SpeakingTokenResult>[];
    final extraWords = <String>[];
    var correct = 0;
    var maybeWrong = 0;
    var missing = 0;

    for (final pair in alignment) {
      final ref = pair.reference;
      final spoken = pair.spoken;
      if (ref == null && spoken != null) {
        extraWords.add(spoken.original);
        continue;
      }
      if (ref == null) continue;

      if (spoken == null) {
        missing++;
        tokenResults.add(
          SpeakingTokenResult(
            reference: ref.original,
            spoken: null,
            status: SpeakingTokenStatus.missing,
          ),
        );
        continue;
      }

      final status = ref.normalized == spoken.normalized
          ? SpeakingTokenStatus.correct
          : SpeakingTokenStatus.maybeWrong;
      if (status == SpeakingTokenStatus.correct) {
        correct++;
      } else {
        maybeWrong++;
      }
      tokenResults.add(
        SpeakingTokenResult(
          reference: ref.original,
          spoken: spoken.original,
          status: status,
        ),
      );
    }

    final targetCount = referenceTokens.length;
    final raw = targetCount == 0
        ? 0.0
        : ((correct + maybeWrong * 0.35) / targetCount) * 100;
    final penalty = (extraWords.length * 4) + (missing * 6);
    final score = (raw - penalty).clamp(0, 100).toDouble();

    return SpeakingAssessmentResult(
      referenceText: referenceText,
      transcript: transcript.trim(),
      tokens: tokenResults,
      extraWords: extraWords,
      score: score,
    );
  }

  static List<_Token> _tokenize(String text) {
    final matches = RegExp(r"[A-Za-z]+(?:'[A-Za-z]+)?|\d+").allMatches(text);
    return [
      for (final match in matches)
        _Token(
          original: match.group(0)!,
          normalized: _normalize(match.group(0)!),
        ),
    ].where((token) => token.normalized.isNotEmpty).toList();
  }

  static String _normalize(String value) {
    final lower = value.toLowerCase().trim();
    final expanded = switch (lower) {
      "i'm" => 'im',
      "you're" => 'youre',
      "he's" ||
      "she's" ||
      "it's" ||
      "that's" ||
      "what's" => lower.replaceAll("'", ''),
      "don't" => 'dont',
      "can't" => 'cant',
      "won't" => 'wont',
      _ => lower.replaceAll("'", ''),
    };
    return expanded.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static List<_AlignedToken> _align(
    List<_Token> reference,
    List<_Token> spoken,
  ) {
    final rows = reference.length + 1;
    final cols = spoken.length + 1;
    final dp = List.generate(rows, (_) => List<int>.filled(cols, 0));

    for (var i = 0; i <= reference.length; i++) {
      dp[i][0] = i;
    }
    for (var j = 0; j <= spoken.length; j++) {
      dp[0][j] = j;
    }

    for (var i = 1; i <= reference.length; i++) {
      for (var j = 1; j <= spoken.length; j++) {
        final substitutionCost =
            reference[i - 1].normalized == spoken[j - 1].normalized ? 0 : 1;
        final deleteCost = dp[i - 1][j] + 1;
        final insertCost = dp[i][j - 1] + 1;
        final substituteCost = dp[i - 1][j - 1] + substitutionCost;
        dp[i][j] = _min3(deleteCost, insertCost, substituteCost);
      }
    }

    final aligned = <_AlignedToken>[];
    var i = reference.length;
    var j = spoken.length;
    while (i > 0 || j > 0) {
      if (i > 0 && j > 0) {
        final substitutionCost =
            reference[i - 1].normalized == spoken[j - 1].normalized ? 0 : 1;
        if (dp[i][j] == dp[i - 1][j - 1] + substitutionCost) {
          aligned.add(
            _AlignedToken(reference: reference[i - 1], spoken: spoken[j - 1]),
          );
          i--;
          j--;
          continue;
        }
      }
      if (i > 0 && dp[i][j] == dp[i - 1][j] + 1) {
        aligned.add(_AlignedToken(reference: reference[i - 1], spoken: null));
        i--;
        continue;
      }
      if (j > 0) {
        aligned.add(_AlignedToken(reference: null, spoken: spoken[j - 1]));
        j--;
      }
    }
    return aligned.reversed.toList();
  }

  static int _min3(int a, int b, int c) =>
      a < b ? (a < c ? a : c) : (b < c ? b : c);
}

class _Token {
  const _Token({required this.original, required this.normalized});

  final String original;
  final String normalized;
}

class _AlignedToken {
  const _AlignedToken({required this.reference, required this.spoken});

  final _Token? reference;
  final _Token? spoken;
}
