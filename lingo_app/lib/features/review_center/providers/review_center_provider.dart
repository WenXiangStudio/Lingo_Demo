import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/providers.dart';

enum ReviewCollectionType { errors, forgotten, cueMemory }

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

class ReviewDashboardData {
  final List<ReviewWordStat> allWords;
  final List<ReviewWordStat> activeErrorWords;
  final List<ReviewWordStat> activeForgottenWords;
  final List<ReviewWordStat> activeCueMemoryWords;
  final int totalErrorCount;
  final int totalForgottenCount;
  final int totalCueMemoryCount;
  final int activeErrorWordCount;
  final int activeForgottenWordCount;
  final int activeCueMemoryWordCount;
  final DateTime selectedDate;
  final List<DailyListReview> listReviews;
  final DailyAiSummary aiSummary;
  final bool migrationNotice;

  const ReviewDashboardData({
    required this.allWords,
    required this.activeErrorWords,
    required this.activeForgottenWords,
    required this.activeCueMemoryWords,
    required this.totalErrorCount,
    required this.totalForgottenCount,
    required this.totalCueMemoryCount,
    required this.activeErrorWordCount,
    required this.activeForgottenWordCount,
    required this.activeCueMemoryWordCount,
    required this.selectedDate,
    required this.listReviews,
    required this.aiSummary,
    required this.migrationNotice,
  });
}

typedef ReviewCenterData = ReviewDashboardData;

final reviewSelectedBookIdProvider = StateProvider<int?>((ref) => null);

final reviewSelectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final reviewSortModeProvider = StateProvider<ReviewSortMode>(
  (ref) => ReviewSortMode.errorCount,
);

final reviewPracticeSessionProvider = StateProvider<ReviewPracticeSession?>(
  (ref) => null,
);

final reviewBooksProvider = FutureProvider<List<WordBook>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.getAllBooks();
});

final reviewMigrationNoticeProvider = FutureProvider<bool>((ref) async {
  final settings = ref.watch(settingsRepositoryProvider);
  final value = await settings.getString('review_data_reset_notice');
  return value == 'true';
});

final reviewCenterDataProvider = FutureProvider<ReviewDashboardData>((
  ref,
) async {
  final db = ref.watch(appDatabaseProvider);
  final selectedBookId = ref.watch(reviewSelectedBookIdProvider);
  final selectedDate = ref.watch(reviewSelectedDateProvider);
  final words = await db.getReviewWordStats(bookId: selectedBookId);

  final activeErrorWords = words.where((w) => w.isErrorActive).toList()
    ..sort((a, b) {
      final cmp = b.errorCount.compareTo(a.errorCount);
      if (cmp != 0) return cmp;
      return a.word.english.toLowerCase().compareTo(
        b.word.english.toLowerCase(),
      );
    });
  final activeForgottenWords = words.where((w) => w.isForgottenActive).toList()
    ..sort((a, b) {
      final cmp = b.forgottenCount.compareTo(a.forgottenCount);
      if (cmp != 0) return cmp;
      return a.word.english.toLowerCase().compareTo(
        b.word.english.toLowerCase(),
      );
    });
  final activeCueMemoryWords = words.where((w) => w.isCueMemoryActive).toList()
    ..sort((a, b) {
      final listCmp = (a.cueMemoryListCreatedAt ?? 0).compareTo(
        b.cueMemoryListCreatedAt ?? 0,
      );
      if (listCmp != 0) return listCmp;
      final listIdCmp = (a.cueMemoryListId ?? 0).compareTo(
        b.cueMemoryListId ?? 0,
      );
      if (listIdCmp != 0) return listIdCmp;
      final orderCmp = (a.cueMemoryListSortOrder ?? 0).compareTo(
        b.cueMemoryListSortOrder ?? 0,
      );
      if (orderCmp != 0) return orderCmp;
      return a.word.english.toLowerCase().compareTo(
        b.word.english.toLowerCase(),
      );
    });
  final totalErrorCount = words.fold<int>(0, (sum, w) => sum + w.errorCount);
  final totalForgottenCount = words.fold<int>(
    0,
    (sum, w) => sum + w.forgottenCount,
  );
  final totalCueMemoryCount = words.fold<int>(
    0,
    (sum, w) => sum + w.cueMemoryCount,
  );

  final listReviews = await db.getDailyListReview(
    selectedDate,
    bookId: selectedBookId,
  );
  final aiSummary = await db.getDailyAiSummary(
    selectedDate,
    bookId: selectedBookId,
  );
  final notice = await ref.read(reviewMigrationNoticeProvider.future);

  return ReviewDashboardData(
    allWords: words,
    activeErrorWords: activeErrorWords,
    activeForgottenWords: activeForgottenWords,
    activeCueMemoryWords: activeCueMemoryWords,
    totalErrorCount: totalErrorCount,
    totalForgottenCount: totalForgottenCount,
    totalCueMemoryCount: totalCueMemoryCount,
    activeErrorWordCount: activeErrorWords.length,
    activeForgottenWordCount: activeForgottenWords.length,
    activeCueMemoryWordCount: activeCueMemoryWords.length,
    selectedDate: selectedDate,
    listReviews: listReviews,
    aiSummary: aiSummary,
    migrationNotice: notice,
  );
});
