import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lingo_app/data/ai/ai_service.dart';
import 'package:lingo_app/data/database/app_database.dart';
import 'package:lingo_app/data/repositories/repositories.dart';

void main() {
  late AppDatabase database;
  late SettingsRepository settings;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    settings = SettingsRepository(database);
  });

  tearDown(() => database.close());

  test('migrates legacy DeepSeek Flash model names before requests', () async {
    await settings.setAiProvider('deepseek');
    await settings.setAiApiKey('test-key');
    await settings.setAiModel('deepseek-v4-flash');

    final provider = await AiService(settings).getProvider();

    expect(provider.modelName, 'deepseek-flash');
    expect(await settings.getAiModel(), 'deepseek-flash');
  });

  test('uses the available DeepSeek Flash model by default', () async {
    await settings.setAiProvider('deepseek');
    await settings.setAiApiKey('test-key');

    final provider = await AiService(settings).getProvider();

    expect(provider.modelName, 'deepseek-flash');
    expect(await settings.getAiModel(), 'deepseek-flash');
  });

  test('preserves an explicitly configured custom DeepSeek model', () async {
    await settings.setAiProvider('deepseek');
    await settings.setAiApiKey('test-key');
    await settings.setAiModel('deepseek-v4-pro');

    final provider = await AiService(settings).getProvider();

    expect(provider.modelName, 'deepseek-v4-pro');
    expect(await settings.getAiModel(), 'deepseek-v4-pro');
  });
}
