import 'package:flutter_test/flutter_test.dart';

import 'package:lingo_app/features/settings/services/word_audio_release_job.dart';

void main() {
  test(
    'tracks Qwen3 example cache completeness separately from server status',
    () {
      const incomplete = WordAudioReleaseListCacheStatus(
        listId: 7,
        listNumber: 2,
        listName: 'List 2',
        totalItems: 30,
        cachedItems: 29,
      );
      const complete = WordAudioReleaseListCacheStatus(
        listId: 7,
        listNumber: 2,
        listName: 'List 2',
        totalItems: 30,
        cachedItems: 30,
      );

      expect(incomplete.isComplete, isFalse);
      expect(incomplete.missingItems, 1);
      expect(incomplete.cachedWords, 29);
      expect(complete.isComplete, isTrue);
      expect(complete.missingWords, 0);
    },
  );

  WordAudioServerListStatus status({
    int total = 30,
    int checked = 30,
    int uploaded = 0,
    int missing = 0,
    int unavailable = 0,
  }) {
    return WordAudioServerListStatus(
      listId: 1,
      totalWords: total,
      checkedWords: checked,
      uploadedWords: uploaded,
      missingWords: missing,
      unavailableWords: unavailable,
    );
  }

  group('WordAudioServerListStatus', () {
    test(
      'distinguishes checking, uploaded, missing, partial, and unavailable Lists',
      () {
        expect(
          status(checked: 12, uploaded: 12).uploadState,
          WordAudioServerListUploadState.checking,
        );
        expect(
          status(uploaded: 30).uploadState,
          WordAudioServerListUploadState.uploaded,
        );
        expect(
          status(missing: 30).uploadState,
          WordAudioServerListUploadState.notUploaded,
        );
        expect(
          status(uploaded: 12, missing: 18).uploadState,
          WordAudioServerListUploadState.partiallyUploaded,
        );
        expect(
          status(uploaded: 29, unavailable: 1).uploadState,
          WordAudioServerListUploadState.unavailable,
        );
      },
    );
  });
}
