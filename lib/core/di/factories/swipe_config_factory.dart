import '../../config/app_config.dart';
import '../../../features/swipe/domain/entities/swipe_config.dart';

abstract class SwipeConfigFactory {
  const SwipeConfigFactory();

  SwipeConfig create();
}

class DefaultSwipeConfigFactory implements SwipeConfigFactory {
  const DefaultSwipeConfigFactory();

  @override
  SwipeConfig create() {
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
