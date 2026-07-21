import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:lingo_app/core/i18n/app_strings.dart';
import 'package:lingo_app/core/services/tts_engines/supertonic_tts_engine.dart';
import 'package:lingo_app/core/utils/answer_checker.dart';
import 'package:lingo_app/core/utils/text_normalizer.dart';

void main() {
  group('AppStrings.get', () {
    test('returns English translation', () {
      expect(AppStrings.get('settings', 'en'), 'Settings');
      expect(AppStrings.get('save', 'en'), 'Save');
    });

    test('returns Chinese translation', () {
      expect(AppStrings.get('settings', 'zh'), '设置');
      expect(AppStrings.get('save', 'zh'), '保存');
    });

    test('falls back to English when language missing', () {
      expect(AppStrings.get('settings', 'fr'), 'Settings');
    });

    test('falls back to the key when key missing', () {
      expect(AppStrings.get('no_such_key', 'en'), 'no_such_key');
    });

    test('interpolates params with {name} placeholders', () {
      expect(
        AppStrings.get('n_words', 'en', params: {'count': '7'}),
        '7 words',
      );
      expect(AppStrings.get('n_words', 'zh', params: {'count': '7'}), '7 个单词');
    });
  });

  group('TextNormalizer', () {
    test('normalizes curly quote and apostrophe variants', () {
      expect(
        TextNormalizer.normalizeQuotes('“Don’t” and ‘can’t’'),
        '"Don\'t" and \'can\'t\'',
      );
      expect(
        TextNormalizer.normalizeQuotes('＂quote＂ ＇mark＇'),
        '"quote" \'mark\'',
      );
    });
  });

  group('AnswerChecker', () {
    test('compares meanings after quote and separator normalization', () {
      expect(AnswerChecker.isAnswerCorrect('don’t', "don't"), isTrue);
      expect(AnswerChecker.isAnswerCorrect('装满', '装满;盛满'), isTrue);
      expect(AnswerChecker.isFillAnswerCorrect('盛满', '装满;盛满'), isTrue);
      expect(AnswerChecker.isAnswerCorrect(' v. 装满 ', 'v.装满；占满'), isTrue);
      expect(AnswerChecker.isAnswerCorrect('微小的', 'adj. 微小的'), isTrue);
      expect(AnswerChecker.missingMeanings('don’t', "don't；can't"), ["can't"]);
    });
  });

  group('SupertonicTtsEngine text preparation', () {
    test('normalizes ellipses and semicolons', () {
      expect(
        SupertonicTtsEngine.preprocessText('Wait... go；then; stop'),
        'Wait, go,then, stop',
      );
    });

    test('normalizes curly quotes before synthesis', () {
      expect(
        SupertonicTtsEngine.preprocessText('“Don’t”； stop'),
        '"Don\'t", stop',
      );
    });

    test('adds a terminal boundary to a bare word', () {
      expect(SupertonicTtsEngine.preprocessSingleWord('tame'), 'tame.');
      expect(SupertonicTtsEngine.preprocessSingleWord('Don’t'), "Don't.");
      expect(
        SupertonicTtsEngine.preprocessSingleWord('ice cream'),
        'ice cream',
      );
      expect(SupertonicTtsEngine.preprocessSingleWord('tame!'), 'tame!');
    });

    test('splits long form text into bounded chunks', () {
      const paragraph =
          'The soldier with a wound decided to wind his watch; he did not '
          'want to desert the desert, but he had to refuse the refuse because '
          'the lead pipe was too heavy to lead the parade. The farm produce '
          'was used to produce a perfect record, but can you record that '
          'record?';
      const text = '$paragraph $paragraph';

      final chunks = SupertonicTtsEngine.splitLongFormText(text);

      expect(chunks.length, greaterThan(1));
      expect(
        chunks.every(
          (chunk) => chunk.length <= SupertonicTtsEngine.longFormMaxChars,
        ),
        isTrue,
      );
      expect(chunks.join(' '), isNot(contains(';')));
    });

    test('keeps short sentence runs together without overfilling chunks', () {
      const text =
          "Don't refuse the refuse bin. "
          'The live band gave a live broadcast. '
          'He is content with the content. '
          'We need to minute the minute details. '
          'The console helped console the mother. '
          'A row of houses faced a row. '
          'The dove dove into the bushes. '
          'She will record the record. '
          'The wind began to wind down. '
          'The shed was a bright shed color. '
          'He was close to closing the close door.';

      final chunks = SupertonicTtsEngine.splitLongFormText(text);

      expect(
        chunks.every(
          (chunk) => chunk.length <= SupertonicTtsEngine.longFormMaxChars,
        ),
        isTrue,
      );
      expect(
        chunks.any(
          (chunk) =>
              chunk.contains('The wind began to wind down.') &&
              chunk.contains('The shed was a bright shed color.'),
        ),
        isTrue,
      );
    });

    test('trims only trailing silence without cutting internal pauses', () {
      final samples = Float32List(500);
      for (var i = 60; i < 100; i++) {
        samples[i] = 0.5;
      }
      for (var i = 260; i < 300; i++) {
        samples[i] = 0.5;
      }

      final trimmed = SupertonicTtsEngine.trimTailSilence(
        samples,
        1000,
        threshold: 0.1,
        holdMs: 60,
      );

      expect(trimmed.length, lessThan(samples.length));
      expect(trimmed.length, greaterThan(300));
      expect(trimmed[260], 0.5);
    });
  });
}
