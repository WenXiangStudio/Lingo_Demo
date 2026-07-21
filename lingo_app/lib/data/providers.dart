import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/i18n/locale_provider.dart';
import 'database/app_database.dart';
import 'language_tool/language_tool_client.dart';
import 'retrieval/retrieval_v2_client.dart';
import 'repositories/repositories.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier(ref.read(settingsRepositoryProvider));
});

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final wordRepositoryProvider = Provider<WordRepository>(
  (ref) => WordRepository(ref.watch(appDatabaseProvider)),
);

final wordListRepositoryProvider = Provider<WordListRepository>(
  (ref) => WordListRepository(ref.watch(appDatabaseProvider)),
);

final practiceRepositoryProvider = Provider<PracticeRepository>(
  (ref) => PracticeRepository(ref.watch(appDatabaseProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(appDatabaseProvider)),
);

final ttsRepositoryProvider = Provider<TtsRepository>(
  (ref) => TtsRepository(ref.watch(appDatabaseProvider)),
);

final aiContentRepositoryProvider = Provider<AiContentRepository>(
  (ref) => AiContentRepository(ref.watch(appDatabaseProvider)),
);

final retrievalV2ClientProvider = Provider<RetrievalV2Client>(
  (ref) => RetrievalV2Client(),
);

final languageToolClientProvider = FutureProvider<LanguageToolClient>((
  ref,
) async {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  final baseUrl = await settingsRepo.getLanguageToolBaseUrl();
  return LanguageToolClient(
    baseUrl: baseUrl == null || baseUrl.trim().isEmpty
        ? LanguageToolClient.defaultBaseUrl
        : baseUrl,
  );
});

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
