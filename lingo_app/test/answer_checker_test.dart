import 'package:flutter_test/flutter_test.dart';

import 'package:lingo_app/core/utils/answer_checker.dart';

void main() {
  group('fill-in Chinese meaning grading', () {
    test('ignores regional meaning prefixes', () {
      const meanings = '(英)饼干；(美)软饼';

      expect(AnswerChecker.isFillAnswerCorrect('饼干', meanings), isTrue);
      expect(AnswerChecker.isFillAnswerCorrect('软饼', meanings), isTrue);
      expect(AnswerChecker.isFillAnswerCorrect('饼干，软饼', meanings), isTrue);
    });

    test('accepts any valid meaning and unordered valid combinations', () {
      const meanings = '停止，放弃；离开，辞';

      expect(AnswerChecker.isFillAnswerCorrect('停止', meanings), isTrue);
      expect(AnswerChecker.isFillAnswerCorrect('辞', meanings), isTrue);
      expect(AnswerChecker.isFillAnswerCorrect('停止，辞', meanings), isTrue);
      expect(AnswerChecker.isFillAnswerCorrect('辞, 停止', meanings), isTrue);
    });

    test('rejects a multi-part answer containing an invalid meaning', () {
      const meanings = 'A,B;C;D';

      expect(AnswerChecker.isFillAnswerCorrect('D,A', meanings), isTrue);
      expect(AnswerChecker.isFillAnswerCorrect('C,D,F', meanings), isFalse);
      expect(AnswerChecker.invalidFillAnswerParts('C,D,F', meanings), ['F']);
    });
  });
}
