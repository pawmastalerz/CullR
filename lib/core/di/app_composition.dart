import '../../features/swipe/application/services/swipe_home_gallery_controller.dart';
import '../../features/swipe/application/state/swipe_session.dart';
import '../../features/swipe/data/cache/swipe_media_cache.dart';
import '../../features/swipe/data/photo_manager_gallery_repository.dart';
import '../../features/swipe/domain/entities/swipe_config.dart';
import '../../features/swipe/domain/repositories/gallery_repository.dart';
import '../../features/swipe/domain/repositories/media_repository.dart';
import '../../features/swipe/domain/services/swipe_decision_store.dart';
import '../../features/swipe/domain/services/swipe_milestone_controller.dart';
import '../config/app_config.dart';

class AppComposition {
  const AppComposition();

  SwipeSession buildSwipeSession({GalleryRepository? galleryRepository}) {
    final SwipeConfig config = _buildSwipeConfig();
    final GalleryRepository repository =
        galleryRepository ?? PhotoManagerGalleryRepository();
    final MediaRepository media = SwipeHomeMediaCache(config: config);
    final SwipeDecisionStore decisionStore = SwipeDecisionStore(
      config: config,
      assetLoader: repository.loadAssetById,
    );
    final SwipeMilestoneController milestones = SwipeMilestoneController(
      thresholdBytes: config.deleteMilestoneBytes,
      minInterval: config.deleteMilestoneMinInterval,
    );
    final SwipeHomeGalleryController galleryController =
        SwipeHomeGalleryController(
          galleryRepository: repository,
          decisionStore: decisionStore,
          mediaRepository: media,
          config: config,
        );
    return SwipeSession(
      galleryRepository: repository,
      config: config,
      decisionStore: decisionStore,
      mediaRepository: media,
      milestoneController: milestones,
      galleryController: galleryController,
    );
  }

  SwipeConfig _buildSwipeConfig() {
    return const SwipeConfig(
      galleryVideoBatchSize: AppConfig.galleryVideoBatchSize,
      galleryOtherBatchSize: AppConfig.galleryOtherBatchSize,
      swipeBufferSize: AppConfig.swipeBufferSize,
      swipeVisibleCards: AppConfig.swipeVisibleCards,
      swipeUndoLimit: AppConfig.swipeUndoLimit,
      fullResHistoryLimit: AppConfig.fullResHistoryLimit,
      thumbnailBytesCacheLimit: AppConfig.thumbnailBytesCacheLimit,
      fileSizeLabelCacheLimit: AppConfig.fileSizeLabelCacheLimit,
      fileSizeBytesCacheLimit: AppConfig.fileSizeBytesCacheLimit,
      animatedBytesCacheLimit: AppConfig.animatedBytesCacheLimit,
      deleteMilestoneBytes: AppConfig.deleteMilestoneBytes,
      deleteMilestoneMinInterval: AppConfig.deleteMilestoneMinInterval,
    );
  }
}
