import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lingo_app/data/database/app_database.dart';
import 'package:lingo_app/data/providers.dart';
import 'package:lingo_app/data/repositories/narration_repository.dart';
import 'package:lingo_app/features/narration/models/narration_models.dart';
import 'package:lingo_app/features/narration/screens/narration_flow_screen.dart';
import 'package:lingo_app/features/speaking/providers/speaking_provider.dart';
import 'package:lingo_app/features/speaking/services/speaking_asr_model_manager.dart';

class _FakeAsrModelManager extends SpeakingAsrModelManager {
  @override
  Future<void> checkStatus() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late NarrationRepository repository;
  late _FakeAsrModelManager asrModelManager;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = NarrationRepository(database);
    asrModelManager = _FakeAsrModelManager();
  });

  tearDown(() async {
    asrModelManager.dispose();
    await database.close();
  });

  testWidgets(
    'enables target generation after entering confirmed Chinese intent',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1100, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final sessionId = await repository.createSession(
        rawTranscript: 'Hi, this is my first recording.',
        cleanedTranscript: 'Hi, this is my first recording.',
        confidence: NarrationTranscriptConfidence.medium,
      );
      await repository.confirmTranscript(
        sessionId: sessionId,
        cleanedTranscript: 'Hi, this is my first recording.',
        confidence: NarrationTranscriptConfidence.medium,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            speakingAsrModelManagerProvider.overrideWithValue(asrModelManager),
          ],
          child: MaterialApp(home: NarrationFlowScreen(sessionId: sessionId)),
        ),
      );
      await tester.pumpAndSettle();

      final generateButton = find.widgetWithText(
        FilledButton,
        'Confirm Intent and Generate Target English',
      );
      expect(generateButton, findsOneWidget);
      expect(tester.widget<FilledButton>(generateButton).onPressed, isNull);

      final translationField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Confirmed Chinese translation',
      );
      expect(translationField, findsOneWidget);

      await tester.enterText(translationField, '嗨，这是今天英语学习的第一条录音。');
      await tester.pump();

      expect(find.text('嗨，这是今天英语学习的第一条录音。'), findsOneWidget);
      expect(tester.widget<FilledButton>(generateButton).onPressed, isNotNull);
    },
  );
}
