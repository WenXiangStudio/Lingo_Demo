import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingo_app/features/phonetics/data/british_phoneme_catalog.dart';
import 'package:lingo_app/features/phonetics/models/phoneme_definition.dart';

void main() {
  group('British phoneme catalog', () {
    test('contains the standard 44 phonemes in three groups', () {
      expect(britishPhonemes, hasLength(44));
      expect(phonemesFor(PhonemeGroup.monophthongs), hasLength(12));
      expect(phonemesFor(PhonemeGroup.diphthongs), hasLength(8));
      expect(phonemesFor(PhonemeGroup.consonants), hasLength(24));
    });

    test('has unique symbols, IDs, and stable WAV asset paths', () {
      expect(
        britishPhonemes.map((phoneme) => phoneme.symbol).toSet(),
        hasLength(44),
      );
      expect(
        britishPhonemes.map((phoneme) => phoneme.id).toSet(),
        hasLength(44),
      );

      for (final phoneme in britishPhonemes) {
        expect(phoneme.id, matches(RegExp(r'^[a-z0-9_]+$')));
        expect(phoneme.example, isNotEmpty);
        expect(phoneme.assetPath, 'assets/phonetics/british/${phoneme.id}.wav');
      }
    });

    testWidgets('bundles a valid WAV asset for every phoneme', (tester) async {
      for (final phoneme in britishPhonemes) {
        final data = await rootBundle.load(phoneme.assetPath);
        final bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        expect(bytes.length, greaterThan(44), reason: phoneme.assetPath);
        expect(
          String.fromCharCodes(bytes.take(4)),
          'RIFF',
          reason: phoneme.assetPath,
        );
        expect(
          String.fromCharCodes(bytes.skip(8).take(4)),
          'WAVE',
          reason: phoneme.assetPath,
        );
      }
    });

    test('keeps the Cambridge chart examples mapped to their symbols', () {
      final examples = {
        for (final phoneme in britishPhonemes) phoneme.symbol: phoneme.example,
      };

      expect(examples['iː'], 'sheep');
      expect(examples['ə'], 'teacher');
      expect(examples['ʊə'], 'tourist');
      expect(examples['θ'], 'think');
      expect(examples['ð'], 'this');
      expect(examples['ŋ'], 'sing');
      expect(examples['j'], 'yes');
    });
  });
}
