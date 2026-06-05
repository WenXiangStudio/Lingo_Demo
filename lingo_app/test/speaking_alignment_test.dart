import 'package:flutter_test/flutter_test.dart';
import 'package:lingo_app/features/speaking/models/speaking_models.dart';
import 'package:lingo_app/features/speaking/services/speaking_alignment.dart';

void main() {
  test('marks every word correct when transcript matches reference', () {
    final result = SpeakingAlignment.assess(
      referenceText: 'Which room is at the front?',
      transcript: 'which room is at the front',
    );

    expect(result.score, 100);
    expect(result.tokens, hasLength(6));
    expect(
      result.tokens.every((t) => t.status == SpeakingTokenStatus.correct),
      isTrue,
    );
    expect(result.extraWords, isEmpty);
  });

  test('marks omitted reference words as missing', () {
    final result = SpeakingAlignment.assess(
      referenceText: 'Which room is at the front?',
      transcript: 'which room at the front',
    );

    expect(
      result.tokens.singleWhere((t) => t.reference == 'is').status,
      SpeakingTokenStatus.missing,
    );
    expect(result.score, lessThan(100));
  });

  test('records inserted spoken words as extras', () {
    final result = SpeakingAlignment.assess(
      referenceText: 'Follow the example.',
      transcript: 'follow the good example',
    );

    expect(result.extraWords, ['good']);
    expect(result.score, lessThan(100));
  });
}
