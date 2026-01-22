import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import 'package:cullr/features/swipe/application/services/swipe_home_gallery_controller.dart';
import 'package:cullr/features/swipe/application/state/swipe_session.dart';
import 'package:cullr/features/swipe/domain/entities/delete_assets_result.dart';
import 'package:cullr/features/swipe/domain/entities/gallery_load_result.dart';
import 'package:cullr/features/swipe/domain/entities/gallery_permission.dart';
import 'package:cullr/features/swipe/domain/entities/swipe_config.dart';
import 'package:cullr/features/swipe/domain/services/swipe_decision_store.dart';
import 'package:cullr/features/swipe/domain/services/swipe_milestone_controller.dart';

import 'support/swipe_test_utils.dart';

const SwipeConfig _config = SwipeConfig(
  galleryVideoBatchSize: 1,
  galleryOtherBatchSize: 1,
  swipeBufferSize: 1,
  swipeVisibleCards: 1,
  swipeUndoLimit: 2,
  fullResHistoryLimit: 2,
  thumbnailBytesCacheLimit: 10,
  fileSizeLabelCacheLimit: 10,
  fileSizeBytesCacheLimit: 10,
  animatedBytesCacheLimit: 10,
  deleteMilestoneBytes: 100,
  deleteMilestoneMinInterval: Duration.zero,
);

GalleryLoadResult _singleAssetResult(String id) {
  final asset = testAsset(id);
  return GalleryLoadResult(
    permission: GalleryPermission.authorized,
    assets: [asset],
    videos: const [],
    others: [asset],
    totalAssets: 1,
  );
}

SwipeSession _buildSession({
  required FakeGalleryRepository repo,
  required SwipeDecisionStore store,
  FakeMediaRepository? media,
}) {
  final FakeMediaRepository mediaRepo = media ?? FakeMediaRepository();
  final SwipeHomeGalleryController controller = SwipeHomeGalleryController(
    galleryRepository: repo,
    decisionStore: store,
    mediaRepository: mediaRepo,
    config: _config,
  );
  return SwipeSession(
    galleryRepository: repo,
    config: _config,
    decisionStore: store,
    mediaRepository: mediaRepo,
    milestoneController: SwipeMilestoneController(
      thresholdBytes: _config.deleteMilestoneBytes,
      minInterval: _config.deleteMilestoneMinInterval,
      store: MemoryStore(),
    ),
    galleryController: controller,
  );
}

void main() {
  test('handleSwipe left marks delete and increments counts', () async {
    final String id = 'p1';
    final FakeGalleryRepository repo = FakeGalleryRepository(
      pages: [_singleAssetResult(id)],
      assetsById: {id: testAsset(id)},
    );
    final SwipeDecisionStore store = SwipeDecisionStore(
      config: _config,
      store: MemoryStore(),
      assetLoader: repo.loadAssetById,
    );
    final SwipeSession session = _buildSession(repo: repo, store: store);

    await session.initialize();
    final SwipeOutcome outcome = session.handleSwipe(CardSwiperDirection.left);

    expect(outcome.handled, isTrue);
    expect(session.swipeCount, 1);
    expect(session.progressSwipeCount, 1);
    expect(store.isMarkedForDelete(id), isTrue);
  });

  test('handleUndo reverses last swipe decision', () async {
    final String id = 'p2';
    final FakeGalleryRepository repo = FakeGalleryRepository(
      pages: [_singleAssetResult(id)],
      assetsById: {id: testAsset(id)},
    );
    final SwipeDecisionStore store = SwipeDecisionStore(
      config: _config,
      store: MemoryStore(),
      assetLoader: repo.loadAssetById,
    );
    final SwipeSession session = _buildSession(repo: repo, store: store);

    await session.initialize();
    session.handleSwipe(CardSwiperDirection.left);
    final UndoResult? undo = session.handleUndo();

    expect(undo, isNotNull);
    expect(store.isMarkedForDelete(id), isFalse);
    expect(session.progressSwipeCount, 0);
  });

  test('deleteAssets updates counters and clears decision state', () async {
    final String id = 'p3';
    final FakeGalleryRepository repo = FakeGalleryRepository(
      pages: [_singleAssetResult(id)],
      deleteResult: DeleteAssetsResult(deletedIds: {id}, deletedBytes: 12),
      assetsById: {id: testAsset(id)},
    );
    final SwipeDecisionStore store = SwipeDecisionStore(
      config: _config,
      store: MemoryStore(),
      assetLoader: repo.loadAssetById,
    );
    final SwipeSession session = _buildSession(repo: repo, store: store);

    await session.initialize();
    session.handleSwipe(CardSwiperDirection.left);
    final bool deleted = await session.deleteAssets([testAsset(id)]);

    expect(deleted, isTrue);
    expect(session.deletedCount, 1);
    expect(session.deletedBytes, 12);
    expect(store.isMarkedForDelete(id), isFalse);
  });
}
