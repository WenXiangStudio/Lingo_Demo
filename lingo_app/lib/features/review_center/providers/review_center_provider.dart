import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/providers.dart';

enum ReviewCollectionType { errors, forgotten }

enum ReviewQuizMode { choice, fill }

enum ReviewSortMode { errorCount, forgottenCount }

class ReviewPracticeSession {
  final ReviewCollectionType collectionType;
  final int? bookId;
  final ReviewQuizMode mode;
  final List<ReviewWordStat> words;

  const ReviewPracticeSession({
    required this.collectionType,
    required this.bookId,
    required this.mode,
    required this.words,
  });
}

class ReviewCenterData {
  final List<ReviewWordStat> allWords;
  final List<ReviewWordStat> activeErrorWords;
  final List<ReviewWordStat> activeForgottenWords;
  final int totalErrorCount;
  final int totalForgottenCount;
  final int activeErrorWordCount;
  final int activeForgottenWordCount;

  const ReviewCenterData({
    required this.allWords,
    required this.activeErrorWords,
    required this.activeForgottenWords,
    required this.totalErrorCount,
    required this.totalForgottenCount,
    required this.activeErrorWordCount,
    required this.activeForgottenWordCount,
  });
}

final reviewSelectedBookIdProvider = StateProvider<int?>((ref) => null);

final reviewSortModeProvider = StateProvider<ReviewSortMode>(
  (ref) => ReviewSortMode.errorCount,
);

final reviewPracticeSessionProvider =
    StateProvider<ReviewPracticeSession?>((ref) => null);

final reviewBooksProvider = FutureProvider<List<WordBook>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.getAllBooks();
});

final reviewCenterDataProvider = FutureProvider<ReviewCenterData>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final selectedBookId = ref.watch(reviewSelectedBookIdProvider);
  final words = await db.getReviewWordStats(bookId: selectedBookId);

  final activeErrorWords = words.where((w) => w.isErrorActive).toList()
    ..sort((a, b) {
      final cmp = b.errorCount.compareTo(a.errorCount);
      if (cmp != 0) return cmp;
      return a.word.english.toLowerCase().compareTo(
        b.word.english.toLowerCase(),
      );
    });
  final activeForgottenWords =
      words.where((w) => w.isForgottenActive).toList()
        ..sort((a, b) {
          final cmp = b.forgottenCount.compareTo(a.forgottenCount);
          if (cmp != 0) return cmp;
          return a.word.english.toLowerCase().compareTo(
            b.word.english.toLowerCase(),
          );
        });
  final totalErrorCount = words.fold<int>(0, (sum, w) => sum + w.errorCount);
  final totalForgottenCount =
      words.fold<int>(0, (sum, w) => sum + w.forgottenCount);

  return ReviewCenterData(
    allWords: words,
    activeErrorWords: activeErrorWords,
    activeForgottenWords: activeForgottenWords,
    totalErrorCount: totalErrorCount,
    totalForgottenCount: totalForgottenCount,
    activeErrorWordCount: activeErrorWords.length,
    activeForgottenWordCount: activeForgottenWords.length,
  );
});
