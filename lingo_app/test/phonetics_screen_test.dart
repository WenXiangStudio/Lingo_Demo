import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingo_app/data/database/app_database.dart';
import 'package:lingo_app/data/providers.dart';
import 'package:lingo_app/data/repositories/repositories.dart';
import 'package:lingo_app/features/phonetics/screens/phonetics_screen.dart';
import 'package:lingo_app/features/phonetics/services/phoneme_audio_player.dart';

class _FakePhonemeAudioPlayer implements PhonemeAudioPlayer {
  final playedPaths = <String>[];
  Completer<void>? _completion;
  bool failNext = false;

  @override
  Future<void> playAsset(String assetPath) {
    final previous = _completion;
    if (previous != null && !previous.isCompleted) previous.complete();
    playedPaths.add(assetPath);
    if (failNext) {
      failNext = false;
      return Future.error(Exception('missing test audio'));
    }
    _completion = Completer<void>();
    return _completion!.future;
  }

  void completePlayback() {
    final completion = _completion;
    if (completion != null && !completion.isCompleted) completion.complete();
  }

  @override
  Future<void> stop() async => completePlayback();

  @override
  Future<void> dispose() async => completePlayback();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late _FakePhonemeAudioPlayer audioPlayer;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    audioPlayer = _FakePhonemeAudioPlayer();
  });

  tearDown(() async {
    await database.close();
  });

  Widget testApp() => ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(database)],
    child: MaterialApp(home: PhoneticsScreen(audioPlayer: audioPlayer)),
  );

  testWidgets('shows the three phoneme groups and representative words', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();

    expect(find.text('Cambridge British English IPA'), findsOneWidget);
    expect(find.text('Monophthongs'), findsOneWidget);
    expect(find.text('/iː/'), findsOneWidget);
    expect(find.text('sheep'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Diphthongs'), 300);
    expect(find.text('Diphthongs'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Consonants'), 300);
    expect(find.text('Consonants'), findsOneWidget);
  });

  testWidgets('uses latest-tap-wins playback and updates active state', (
    tester,
  ) async {
    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('phoneme-i_long')));
    await tester.pump();
    expect(audioPlayer.playedPaths, ['assets/phonetics/british/i_long.wav']);
    expect(
      tester
          .widget<Icon>(find.byKey(const ValueKey('phoneme-audio-i_long')))
          .icon,
      Icons.volume_up_rounded,
    );

    await tester.tap(find.byKey(const ValueKey('phoneme-i_short')));
    await tester.pump();
    expect(audioPlayer.playedPaths, [
      'assets/phonetics/british/i_long.wav',
      'assets/phonetics/british/i_short.wav',
    ]);
    expect(
      tester
          .widget<Icon>(find.byKey(const ValueKey('phoneme-audio-i_short')))
          .icon,
      Icons.volume_up_rounded,
    );

    audioPlayer.completePlayback();
    await tester.pump();
    expect(
      tester
          .widget<Icon>(find.byKey(const ValueKey('phoneme-audio-i_short')))
          .icon,
      Icons.volume_up_outlined,
    );
  });

  testWidgets('shows a localized error when an asset cannot be played', (
    tester,
  ) async {
    audioPlayer.failNext = true;
    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('phoneme-i_long')));
    await tester.pump();

    expect(find.text('Could not play /iː/.'), findsOneWidget);
  });

  testWidgets('uses Chinese strings when Chinese is selected', (tester) async {
    await SettingsRepository(database).setAppLanguage('zh');
    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();

    expect(find.text('剑桥英式英语音标'), findsOneWidget);
    expect(find.text('单元音'), findsOneWidget);
    expect(find.text('双元音'), findsOneWidget);
    expect(find.text('辅音'), findsOneWidget);
  });
}
