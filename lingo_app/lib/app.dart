import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'data/providers.dart';
import 'features/lists/screens/home_screen.dart';
import 'features/lists/screens/list_overview_screen.dart';
import 'features/lists/screens/list_preview_screen.dart';
import 'features/import/screens/import_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/review_center/screens/review_center_screen.dart';
import 'features/review_center/screens/review_practice_screen.dart';
import 'features/practice/screens/practice_setup_screen.dart';
import 'features/practice/screens/practice_quiz_screen.dart';
import 'features/practice/screens/practice_result_screen.dart';
import 'features/practice/screens/deep_practice_setup_screen.dart';
import 'features/practice/screens/deep_practice_quiz_screen.dart';
import 'features/practice/screens/deep_practice_result_screen.dart';
import 'features/practice/screens/deep_practice_scope_screen.dart';
import 'features/practice/screens/error_word_review_screen.dart';
import 'features/practice/screens/forgotten_words_screen.dart';
import 'features/deep_learning/screens/dialogue_screen.dart';
import 'features/tts/screens/custom_tts_screen.dart';
import 'features/speaking/screens/speaking_practice_screen.dart';
import 'features/skills/screens/skills_screen.dart';
import 'features/labs/present_tense_diagnosis/screens/present_tense_diagnosis_lab_screen.dart';
import 'features/phonetics/screens/phonetics_screen.dart';
import 'features/narration/screens/narration_home_screen.dart';
import 'features/narration/screens/narration_flow_screen.dart';
import 'features/narration/screens/narration_library_screen.dart';
import 'features/narration/screens/narration_review_screen.dart';
import 'features/narration/screens/narration_progress_screen.dart';

List<int> _deepPracticeListIds(GoRouterState state, int fallbackListId) {
  final raw = state.uri.queryParameters['listIds'];
  final ids =
      raw?.split(',').map(int.tryParse).whereType<int>().toSet().toList() ??
      <int>[];
  return ids.isEmpty ? [fallbackListId] : ids;
}

final _routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/lists',
        builder: (context, state) => const ListOverviewScreen(),
      ),
      GoRoute(
        path: '/import',
        builder: (context, state) => const ImportScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/review-center',
        builder: (context, state) => const ReviewCenterScreen(),
      ),
      GoRoute(
        path: '/review-center/quiz',
        builder: (context, state) => const ReviewPracticeScreen(),
      ),
      GoRoute(
        path: '/list/:listId',
        builder: (context, state) {
          final listId = int.parse(state.pathParameters['listId']!);
          final fromHome = state.uri.queryParameters['from'] == 'home';
          return ListPreviewScreen(
            listId: listId,
            returnPath: fromHome ? '/' : '/lists',
          );
        },
      ),
      GoRoute(
        path: '/practice/:listId/setup',
        builder: (context, state) {
          final listId = int.parse(state.pathParameters['listId']!);
          final onlyForgotten =
              state.uri.queryParameters['forgotten'] == 'true';
          final onlyErrors = state.uri.queryParameters['errors'] == 'true';
          final trackExampleReveals =
              state.uri.queryParameters['exampleCueTracking'] == 'true';
          final returnPath =
              state.uri.queryParameters['returnPath'] ?? '/list/$listId';
          return PracticeSetupScreen(
            listId: listId,
            onlyForgotten: onlyForgotten,
            onlyErrors: onlyErrors,
            trackExampleReveals: trackExampleReveals,
            returnPath: returnPath,
          );
        },
      ),
      GoRoute(
        path: '/practice/:listId/quiz',
        builder: (context, state) {
          final listId = int.parse(state.pathParameters['listId']!);
          final returnPath =
              state.uri.queryParameters['returnPath'] ?? '/list/$listId';
          return PracticeQuizScreen(listId: listId, returnPath: returnPath);
        },
      ),
      GoRoute(
        path: '/practice/:listId/result',
        builder: (context, state) {
          final listId = int.parse(state.pathParameters['listId']!);
          final returnPath =
              state.uri.queryParameters['returnPath'] ?? '/list/$listId';
          return PracticeResultScreen(listId: listId, returnPath: returnPath);
        },
      ),
      GoRoute(
        path: '/deep-practice/scope',
        builder: (context, state) {
          final returnPath = state.uri.queryParameters['returnPath'] ?? '/';
          return DeepPracticeScopeScreen(
            returnPath: returnPath,
            initialListId: int.tryParse(
              state.uri.queryParameters['initialListId'] ??
                  state.uri.queryParameters['listId'] ??
                  '',
            ),
          );
        },
      ),
      GoRoute(
        path: '/deep-practice/:listId/setup',
        builder: (context, state) {
          final listId = int.parse(state.pathParameters['listId']!);
          final listIds = _deepPracticeListIds(state, listId);
          final returnPath =
              state.uri.queryParameters['returnPath'] ?? '/list/$listId';
          return DeepPracticeSetupScreen(
            listIds: listIds,
            returnPath: returnPath,
          );
        },
      ),
      GoRoute(
        path: '/deep-practice/:listId/quiz',
        builder: (context, state) {
          final listId = int.parse(state.pathParameters['listId']!);
          final listIds = _deepPracticeListIds(state, listId);
          final returnPath =
              state.uri.queryParameters['returnPath'] ?? '/list/$listId';
          return DeepPracticeQuizScreen(
            listId: listId,
            listIds: listIds,
            returnPath: returnPath,
          );
        },
      ),
      GoRoute(
        path: '/deep-practice/:listId/result',
        builder: (context, state) {
          final listId = int.parse(state.pathParameters['listId']!);
          final listIds = _deepPracticeListIds(state, listId);
          final returnPath =
              state.uri.queryParameters['returnPath'] ?? '/list/$listId';
          return DeepPracticeResultScreen(
            listId: listId,
            listIds: listIds,
            returnPath: returnPath,
          );
        },
      ),
      GoRoute(
        path: '/error-words/:listId',
        builder: (context, state) {
          final listId = int.parse(state.pathParameters['listId']!);
          return ErrorWordReviewScreen(listId: listId);
        },
      ),
      GoRoute(
        path: '/forgotten/:listId',
        builder: (context, state) {
          final listId = int.parse(state.pathParameters['listId']!);
          return ForgottenWordsScreen(listId: listId);
        },
      ),
      GoRoute(
        path: '/custom-tts',
        builder: (context, state) => const CustomTtsScreen(),
      ),
      GoRoute(
        path: '/phonetics',
        builder: (context, state) => const PhoneticsScreen(),
      ),
      GoRoute(
        path: '/skills',
        builder: (context, state) => SkillsScreen(
          initialListId: int.tryParse(
            state.uri.queryParameters['initialListId'] ??
                state.uri.queryParameters['listId'] ??
                '',
          ),
        ),
      ),
      GoRoute(
        path: '/labs/present-tense-diagnosis',
        builder: (context, state) => const PresentTenseDiagnosisLabScreen(),
      ),
      GoRoute(
        path: '/dialogue/:listId',
        builder: (context, state) {
          final listId = int.parse(state.pathParameters['listId']!);
          return DialogueScreen(listId: listId);
        },
      ),
      GoRoute(
        path: '/speaking/:listId',
        builder: (context, state) {
          final listId = int.parse(state.pathParameters['listId']!);
          final returnPath =
              state.uri.queryParameters['returnPath'] ?? '/list/$listId';
          return SpeakingPracticeScreen(listId: listId, returnPath: returnPath);
        },
      ),
      GoRoute(
        path: '/narration',
        builder: (context, state) => const NarrationHomeScreen(),
      ),
      GoRoute(
        path: '/narration/new',
        builder: (context, state) => NarrationFlowScreen(
          sessionId: int.tryParse(state.uri.queryParameters['sessionId'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/narration/library',
        builder: (context, state) => const NarrationLibraryScreen(),
      ),
      GoRoute(
        path: '/narration/review',
        builder: (context, state) => const NarrationReviewScreen(),
      ),
      GoRoute(
        path: '/narration/progress',
        builder: (context, state) => const NarrationProgressScreen(),
      ),
    ],
  );
});

class LingoApp extends ConsumerWidget {
  const LingoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    ref.watch(languageProvider);

    return MaterialApp.router(
      title: 'LingoDemo',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
