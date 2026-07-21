import 'package:flutter_test/flutter_test.dart';
import 'package:lingo_app/data/language_tool/language_tool_client.dart';

void main() {
  group('LanguageToolClient', () {
    test('normalizes service urls', () {
      expect(
        LanguageToolClient.normalizeBaseUrl(' https://example.com/v2/check '),
        'https://example.com',
      );
      expect(
        LanguageToolClient.normalizeBaseUrl('https://example.com/v2/'),
        'https://example.com',
      );
      expect(
        LanguageToolClient.normalizeBaseUrl(''),
        LanguageToolClient.defaultBaseUrl,
      );
    });

    test('parses check response matches', () {
      final result = LanguageToolResult.fromJson({
        'matches': [
          {
            'message': 'The verb does not agree with the subject.',
            'shortMessage': 'Agreement error',
            'offset': 4,
            'length': 2,
            'sentence': 'She go to school.',
            'context': {'text': 'She go to school.', 'offset': 4, 'length': 2},
            'replacements': [
              {'value': 'goes'},
            ],
            'rule': {
              'id': 'HE_VERB_AGR',
              'description': 'Subject-verb agreement',
              'issueType': 'grammar',
              'category': {'name': 'Grammar'},
            },
          },
        ],
      });

      expect(result.checked, isTrue);
      expect(result.hasMatches, isTrue);
      expect(result.matches.single.issueText, 'go');
      expect(result.matches.single.replacements, ['goes']);
      expect(
        result.toPromptContext('She go to school.'),
        contains('Suggested replacement(s): goes.'),
      );
    });
  });
}
