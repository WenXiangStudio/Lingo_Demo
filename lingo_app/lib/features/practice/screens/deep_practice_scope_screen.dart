import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../data/database/app_database.dart';
import '../../../data/providers.dart';
import '../../lists/providers/list_provider.dart';

/// Selects one continuous, already-passed List range for AI Deep Learning.
///
/// A range never crosses an unpassed List. This keeps the feature's pass gate
/// meaningful while still allowing a learner to work with several Lists at a
/// time.
class DeepPracticeScopeScreen extends ConsumerStatefulWidget {
  final String returnPath;
  final int? initialListId;

  const DeepPracticeScopeScreen({
    super.key,
    required this.returnPath,
    this.initialListId,
  });

  @override
  ConsumerState<DeepPracticeScopeScreen> createState() =>
      _DeepPracticeScopeScreenState();
}

class _DeepPracticeScopeScreenState
    extends ConsumerState<DeepPracticeScopeScreen> {
  String? _groupKey;
  int _segmentIndex = 0;
  int _startIndex = 0;
  int _endIndex = 0;
  bool _selectionQueued = false;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final theme = Theme.of(context);
    final listsAsync = ref.watch(listOverviewProvider);
    final booksAsync = ref.watch(bookOverviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('workflow_ai_learning', lang)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(widget.returnPath),
        ),
      ),
      body: listsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text(AppStrings.get('deep_scope_load_error', lang))),
        data: (lists) {
          final books = booksAsync.valueOrNull ?? const <WordBook>[];
          final groups = _buildGroups(lists, books);
          if (groups.isEmpty) {
            return _EmptyPassedLists(returnPath: widget.returnPath, lang: lang);
          }

          final group = _resolveGroup(groups);
          final segments = _passedSegments(group.lists);
          if (segments.isEmpty) {
            return _EmptyPassedLists(returnPath: widget.returnPath, lang: lang);
          }
          final selectedSegment =
              segments[_segmentIndex.clamp(0, segments.length - 1)];
          final startIndex = _startIndex.clamp(0, selectedSegment.length - 1);
          final endIndex = _endIndex.clamp(
            startIndex,
            selectedSegment.length - 1,
          );
          final selectedLists = selectedSegment.sublist(
            startIndex,
            endIndex + 1,
          );
          final wordCount = selectedLists.fold<int>(
            0,
            (total, list) => total + list.wordCount,
          );

          _queueSelectionRepair(
            group: group,
            segments: segments,
            startIndex: startIndex,
            endIndex: endIndex,
          );

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                AppStrings.get('deep_scope_title', lang),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.get('deep_scope_description', lang),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.get('deep_scope_book_label', lang),
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ValueKey('deep-scope-book-${group.key}'),
                initialValue: group.key,
                isExpanded: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: [
                  for (final item in groups)
                    DropdownMenuItem(
                      value: item.key,
                      child: Text(
                        item.displayName(lang),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _groupKey = value;
                    _segmentIndex = 0;
                    _startIndex = 0;
                    _endIndex = 0;
                  });
                },
              ),
              if (segments.length > 1) ...[
                const SizedBox(height: 20),
                Text(
                  AppStrings.get('deep_scope_passed_section_label', lang),
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  key: ValueKey(
                    'deep-scope-segment-${group.key}-${_segmentIndex.clamp(0, segments.length - 1)}',
                  ),
                  initialValue: _segmentIndex.clamp(0, segments.length - 1),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (var index = 0; index < segments.length; index++)
                      DropdownMenuItem(
                        value: index,
                        child: Text(
                          _segmentLabel(segments[index], lang),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _segmentIndex = value;
                      _startIndex = 0;
                      _endIndex = 0;
                    });
                  },
                ),
              ],
              const SizedBox(height: 20),
              Text(
                AppStrings.get('deep_scope_start_label', lang),
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                key: ValueKey('deep-scope-start-${group.key}-$startIndex'),
                initialValue: startIndex,
                isExpanded: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: [
                  for (var index = 0; index < selectedSegment.length; index++)
                    DropdownMenuItem(
                      value: index,
                      child: Text(_listLabel(selectedSegment[index], lang)),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _startIndex = value;
                    if (_endIndex < value) _endIndex = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.get('deep_scope_end_label', lang),
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                key: ValueKey(
                  'deep-scope-end-${group.key}-$startIndex-$endIndex',
                ),
                initialValue: endIndex,
                isExpanded: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: [
                  for (
                    var index = startIndex;
                    index < selectedSegment.length;
                    index++
                  )
                    DropdownMenuItem(
                      value: index,
                      child: Text(_listLabel(selectedSegment[index], lang)),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _endIndex = value);
                },
              ),
              const SizedBox(height: 24),
              Card(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.46,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get('deep_scope_selected_title', lang),
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(_segmentLabel(selectedLists, lang)),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.get(
                          'deep_scope_selected_count',
                          lang,
                          params: {
                            'lists': selectedLists.length.toString(),
                            'words': wordCount.toString(),
                          },
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () {
                  final listIds = selectedLists
                      .map((list) => list.id)
                      .join(',');
                  context.push(
                    '/deep-practice/${selectedLists.first.id}/setup?listIds=$listIds&returnPath=${Uri.encodeComponent(widget.returnPath)}',
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: Text(AppStrings.get('deep_scope_continue', lang)),
              ),
            ],
          );
        },
      ),
    );
  }

  _ScopeGroup _resolveGroup(List<_ScopeGroup> groups) {
    if (_groupKey == null && widget.initialListId != null) {
      final index = groups.indexWhere(
        (group) => group.lists.any((list) => list.id == widget.initialListId),
      );
      if (index >= 0) {
        final group = groups[index];
        final segments = _passedSegments(group.lists);
        final segmentIndex = segments.indexWhere(
          (segment) => segment.any((list) => list.id == widget.initialListId),
        );
        if (segmentIndex >= 0) {
          final listIndex = segments[segmentIndex].indexWhere(
            (list) => list.id == widget.initialListId,
          );
          _groupKey = group.key;
          _segmentIndex = segmentIndex;
          _startIndex = listIndex;
          _endIndex = listIndex;
        }
      }
    }
    return groups.firstWhere(
      (group) => group.key == _groupKey,
      orElse: () => groups.first,
    );
  }

  void _queueSelectionRepair({
    required _ScopeGroup group,
    required List<List<WordList>> segments,
    required int startIndex,
    required int endIndex,
  }) {
    final selectedSegmentIndex = _segmentIndex.clamp(0, segments.length - 1);
    if (_groupKey == group.key &&
        _segmentIndex == selectedSegmentIndex &&
        _startIndex == startIndex &&
        _endIndex == endIndex) {
      return;
    }
    if (_selectionQueued) return;
    _selectionQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selectionQueued = false;
        _groupKey = group.key;
        _segmentIndex = selectedSegmentIndex;
        _startIndex = startIndex;
        _endIndex = endIndex;
      });
    });
  }

  List<_ScopeGroup> _buildGroups(List<WordList> lists, List<WordBook> books) {
    final groups = <_ScopeGroup>[];
    for (final book in books) {
      final bookLists = lists.where((list) => list.bookId == book.id).toList();
      if (bookLists.any((list) => list.isPassed)) {
        groups.add(_ScopeGroup.book(book, bookLists));
      }
    }
    final unassigned = lists.where((list) => list.bookId == null).toList();
    if (unassigned.any((list) => list.isPassed)) {
      groups.add(_ScopeGroup.unassigned(unassigned));
    }
    return groups;
  }

  List<List<WordList>> _passedSegments(List<WordList> lists) {
    final segments = <List<WordList>>[];
    var current = <WordList>[];
    for (final list in lists) {
      if (list.isPassed) {
        current.add(list);
      } else if (current.isNotEmpty) {
        segments.add(current);
        current = <WordList>[];
      }
    }
    if (current.isNotEmpty) segments.add(current);
    return segments;
  }

  String _listLabel(WordList list, String lang) {
    return '${list.name} · ${AppStrings.get('n_words', lang, params: {'count': list.wordCount.toString()})}';
  }

  String _segmentLabel(List<WordList> lists, String lang) {
    if (lists.length == 1) return _listLabel(lists.first, lang);
    return AppStrings.get(
      'deep_scope_range_label',
      lang,
      params: {'start': lists.first.name, 'end': lists.last.name},
    );
  }
}

class _ScopeGroup {
  final String key;
  final WordBook? book;
  final List<WordList> lists;

  const _ScopeGroup._({
    required this.key,
    required this.book,
    required this.lists,
  });

  factory _ScopeGroup.book(WordBook book, List<WordList> lists) {
    return _ScopeGroup._(key: 'book-${book.id}', book: book, lists: lists);
  }

  factory _ScopeGroup.unassigned(List<WordList> lists) {
    return _ScopeGroup._(key: 'unassigned', book: null, lists: lists);
  }

  String displayName(String lang) =>
      book?.name ?? AppStrings.get('deep_scope_other_lists', lang);
}

class _EmptyPassedLists extends StatelessWidget {
  final String returnPath;
  final String lang;

  const _EmptyPassedLists({required this.returnPath, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48),
            const SizedBox(height: 16),
            Text(
              AppStrings.get('deep_scope_no_passed_lists', lang),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.go(returnPath),
              child: Text(AppStrings.get('back', lang)),
            ),
          ],
        ),
      ),
    );
  }
}
