import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lingo_app/data/database/app_database.dart';
import 'package:lingo_app/data/providers.dart';
import 'package:lingo_app/features/lists/providers/list_provider.dart';
import 'package:lingo_app/features/lists/screens/home_screen.dart';
import 'package:lingo_app/features/review_center/providers/review_center_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  testWidgets('does not preload the review centre after the home first frame', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var reviewCentreLoaded = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          listOverviewProvider.overrideWith((ref) async => const []),
          bookOverviewProvider.overrideWith((ref) async => const []),
          reviewCenterDataProvider.overrideWith((ref) async {
            reviewCentreLoaded = true;
            throw StateError('Review centre must remain lazy on home.');
          }),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('LingoDemo'), findsOneWidget);
    expect(reviewCentreLoaded, isFalse);
  });
}
