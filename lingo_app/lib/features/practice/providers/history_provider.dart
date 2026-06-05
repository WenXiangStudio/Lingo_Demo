import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/providers.dart';

class SessionSummary {
  final PracticeSession session;
  final String listName;

  const SessionSummary({
    required this.session,
    required this.listName,
  });
}

final allPracticeHistoryProvider = FutureProvider<List<SessionSummary>>((ref) async {
  final sessionRepo = ref.read(practiceRepositoryProvider);
  final listRepo = ref.read(wordListRepositoryProvider);

  final sessions = await sessionRepo.getAllSessions();
  final lists = await listRepo.getAllLists();
  final listNames = {for (final l in lists) l.id: l.name};

  return sessions
      .map((s) => SessionSummary(
            session: s,
            listName: listNames[s.listId] ?? 'Deleted List',
          ))
      .toList();
});

final listPracticeHistoryProvider =
    FutureProvider.family<List<PracticeSession>, int>((ref, listId) async {
  final repo = ref.read(practiceRepositoryProvider);
  return repo.getSessionsForList(listId);
});
