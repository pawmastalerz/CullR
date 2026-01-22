import 'package:flutter_test/flutter_test.dart';

import 'package:cullr/features/swipe/application/services/swipe_home_gallery_controller.dart';
import 'package:cullr/features/swipe/application/models/swipe_card.dart';
import 'package:cullr/features/swipe/domain/entities/gallery_load_result.dart';
import 'package:cullr/features/swipe/domain/entities/gallery_permission.dart';
import 'package:cullr/features/swipe/domain/entities/media_kind.dart';
import 'package:cullr/features/swipe/domain/entities/swipe_config.dart';
import 'package:cullr/features/swipe/domain/services/swipe_decision_store.dart';

import 'support/swipe_test_utils.dart';

const SwipeConfig _config = SwipeConfig(
  galleryVideoBatchSize: 2,
  galleryOtherBatchSize: 2,
  swipeBufferSize: 2,
  swipeVisibleCards: 2,
  swipeUndoLimit: 2,
  fullResHistoryLimit: 2,
  thumbnailBytesCacheLimit: 10,
  fileSizeLabelCacheLimit: 10,
  fileSizeBytesCacheLimit: 10,
  animatedBytesCacheLimit: 10,
  deleteMilestoneBytes: 100,
  deleteMilestoneMinInterval: Duration.zero,
);

GalleryLoadResult _loadResult({
  required List<String> photoIds,
  required List<String> videoIds,
}) {
  final photos = photoIds.map((id) => testAsset(id)).toList();
  final videos = videoIds
      .map((id) => testAsset(id, kind: MediaKind.video))
      .toList();
  return GalleryLoadResult(
    permission: GalleryPermission.authorized,
    assets: [...photos, ...videos],
    videos: videos,
    others: photos,
    totalAssets: photos.length + videos.length,
  );
}

void main() {
  test('loadGallery fills buffer and sets initial state', () async {
    final GalleryLoadResult page = _loadResult(
      photoIds: ['p1', 'p2'],
      videoIds: ['v1'],
    );
    final FakeGalleryRepository repo = FakeGalleryRepository(
      pages: [page],
      assetsById: {
        'p1': testAsset('p1'),
        'p2': testAsset('p2'),
        'v1': testAsset('v1', kind: MediaKind.video),
      },
    );
    final SwipeDecisionStore store = SwipeDecisionStore(
      config: _config,
      store: MemoryStore(),
      assetLoader: repo.loadAssetById,
    );
    final FakeMediaRepository media = FakeMediaRepository();
    final SwipeHomeGalleryController controller = SwipeHomeGalleryController(
      galleryRepository: repo,
      decisionStore: store,
      mediaRepository: media,
      config: _config,
    );

    await controller.loadGallery();

    expect(controller.initialLoadHadAssets, isTrue);
    expect(controller.permissionState, GalleryPermission.authorized);
    expect(controller.totalSwipeTarget, 3);
    expect(controller.buffer.length, 2);
    expect(controller.buffer.every((card) => card.isAsset), isTrue);
  });

  test('skips assets already marked as keep', () async {
    final GalleryLoadResult page = _loadResult(
      photoIds: ['p1', 'p2'],
      videoIds: [],
    );
    final MemoryStore memoryStore = MemoryStore({
      'keep_ids': ['p1'],
    });
    final FakeGalleryRepository repo = FakeGalleryRepository(
      pages: [page],
      assetsById: {'p1': testAsset('p1'), 'p2': testAsset('p2')},
    );
    final SwipeDecisionStore store = SwipeDecisionStore(
      config: _config,
      store: memoryStore,
      assetLoader: repo.loadAssetById,
    );
    final SwipeHomeGalleryController controller = SwipeHomeGalleryController(
      galleryRepository: repo,
      decisionStore: store,
      mediaRepository: FakeMediaRepository(),
      config: _config,
    );

    await controller.loadGallery();

    final List<String> bufferIds = controller.buffer
        .where((SwipeCard card) => card.isAsset)
        .map((SwipeCard card) => card.asset!.id)
        .toList();
    expect(bufferIds, contains('p2'));
    expect(bufferIds, isNot(contains('p1')));
  });

  test('applyDeletion removes cards and evicts thumbnails', () async {
    final GalleryLoadResult page = _loadResult(
      photoIds: ['p1', 'p2'],
      videoIds: [],
    );
    final FakeGalleryRepository repo = FakeGalleryRepository(
      pages: [page],
      assetsById: {'p1': testAsset('p1'), 'p2': testAsset('p2')},
    );
    final SwipeDecisionStore store = SwipeDecisionStore(
      config: _config,
      store: MemoryStore(),
      assetLoader: repo.loadAssetById,
    );
    final FakeMediaRepository media = FakeMediaRepository();
    final SwipeHomeGalleryController controller = SwipeHomeGalleryController(
      galleryRepository: repo,
      decisionStore: store,
      mediaRepository: media,
      config: _config,
    );

    await controller.loadGallery();
    controller.applyDeletion({'p1'});

    final List<String> bufferIds = controller.buffer
        .where((SwipeCard card) => card.isAsset)
        .map((SwipeCard card) => card.asset!.id)
        .toList();
    expect(bufferIds, isNot(contains('p1')));
    expect(media.evicted, contains('p1'));
  });
}
