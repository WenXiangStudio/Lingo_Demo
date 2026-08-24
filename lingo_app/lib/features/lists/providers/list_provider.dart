import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../core/utils/shuffle_helper.dart';
import '../../../data/database/app_database.dart';
import '../../../data/providers.dart';

final listOverviewProvider = FutureProvider<List<WordList>>((ref) async {
  final repo = ref.watch(wordListRepositoryProvider);
  return repo.getAllLists();
});

final bookOverviewProvider = FutureProvider<List<WordBook>>((ref) async {
  final repo = ref.watch(wordListRepositoryProvider);
  return repo.getAllBooks();
});

final listDetailProvider = FutureProvider.family<WordList?, int>((
  ref,
  listId,
) async {
  final repo = ref.watch(wordListRepositoryProvider);
  return repo.getList(listId);
});

final listWordsProvider = FutureProvider.family<List<Word>, int>((
  ref,
  listId,
) async {
  final repo = ref.watch(wordListRepositoryProvider);
  return repo.getWordsForList(listId);
});

final lastShuffleTimeProvider = StateProvider.family<DateTime?, int>(
  (ref, listId) => null,
);

/// Set of word IDs marked as forgotten within a given list.
/// Used by ListPreviewScreen word cards to seed their forgotten state from DB
/// rather than always defaulting to "not forgotten".
final forgottenWordIdsProvider = FutureProvider.family<Set<int>, int>((
  ref,
  listId,
) async {
  final repo = ref.watch(practiceRepositoryProvider);
  return repo.getForgottenWordIdsForList(listId);
});

/// Forgotten words detail (the Word rows themselves), used by the forgotten
/// words screen.
final forgottenWordsProvider = FutureProvider.family<List<Word>, int>((
  ref,
  listId,
) async {
  final repo = ref.watch(practiceRepositoryProvider);
  return repo.getForgottenWordsForList(listId);
});

/// Set of word IDs marked for cue-memory help within a given list.
final cueMemoryWordIdsProvider = FutureProvider.family<Set<int>, int>((
  ref,
  listId,
) async {
  final repo = ref.watch(practiceRepositoryProvider);
  return repo.getCueMemoryWordIdsForList(listId);
});

final shuffleControllerProvider = Provider.family<ShuffleController, int>((
  ref,
  listId,
) {
  return ShuffleController(ref, listId);
});

class ShuffleController {
  final Ref _ref;
  final int _listId;

  ShuffleController(this._ref, this._listId);

  bool get canShuffle {
    final lastShuffle = _ref.read(lastShuffleTimeProvider(_listId));
    if (lastShuffle == null) return true;
    return DateTime.now().difference(lastShuffle).inSeconds >=
        AppConstants.shuffleCooldownSeconds;
  }

  int get remainingCooldownSeconds {
    final lastShuffle = _ref.read(lastShuffleTimeProvider(_listId));
    if (lastShuffle == null) return 0;
    final remaining =
        AppConstants.shuffleCooldownSeconds -
        DateTime.now().difference(lastShuffle).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  Future<void> shuffle() async {
    if (!canShuffle) return;
    await _runShuffle(updateCooldown: true);
  }

  /// Auto-shuffle on list entry per design spec — bypasses cooldown.
  Future<void> autoShuffle() async {
    await _runShuffle(updateCooldown: false);
  }

  Future<void> _runShuffle({required bool updateCooldown}) async {
    final repo = _ref.read(wordListRepositoryProvider);
    final words = await repo.getWordsForList(_listId);
    if (words.length < 2) return;
    final newOrder = ShuffleHelper.generateShuffledIndices(words.length);
    await repo.shuffleList(_listId, newOrder);
    if (updateCooldown) {
      _ref.read(lastShuffleTimeProvider(_listId).notifier).state =
          DateTime.now();
    }
    _ref.invalidate(listWordsProvider(_listId));
  }
}
