import 'dart:math';

class ShuffleHelper {
  ShuffleHelper._();

  /// Fisher-Yates shuffle returning a new list of shuffled indices.
  static List<int> generateShuffledIndices(int length) {
    final rng = Random();
    final indices = List.generate(length, (i) => i);
    for (var i = indices.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final temp = indices[i];
      indices[i] = indices[j];
      indices[j] = temp;
    }
    return indices;
  }

  /// Reorder [items] according to [indices].
  static List<T> applyOrder<T>(List<T> items, List<int> indices) {
    return indices.map((i) => items[i]).toList();
  }
}
