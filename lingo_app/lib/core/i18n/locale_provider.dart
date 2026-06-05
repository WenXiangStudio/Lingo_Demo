import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/repositories.dart';

class LanguageNotifier extends StateNotifier<String> {
  final SettingsRepository _settingsRepo;

  LanguageNotifier(this._settingsRepo) : super('en') {
    _load();
  }

  Future<void> _load() async {
    final saved = await _settingsRepo.getAppLanguage();
    if (saved != null) {
      state = saved;
    }
  }

  Future<void> setLanguage(String lang) async {
    await _settingsRepo.setAppLanguage(lang);
    state = lang;
  }
}
