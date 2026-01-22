class SwipeConfig {
  const SwipeConfig({
    required this.galleryVideoBatchSize,
    required this.galleryOtherBatchSize,
    required this.swipeBufferSize,
    required this.swipeBufferPhotoTarget,
    required this.swipeBufferVideoTarget,
    required this.swipeVisibleCards,
    required this.swipeUndoLimit,
    required this.fullResHistoryLimit,
    required this.thumbnailBytesCacheLimit,
    required this.fileSizeLabelCacheLimit,
    required this.fileSizeBytesCacheLimit,
    required this.animatedBytesCacheLimit,
    required this.deleteMilestoneBytes,
    required this.deleteMilestoneMinInterval,
  });

  final int galleryVideoBatchSize;
  final int galleryOtherBatchSize;
  final int swipeBufferSize;
  final int swipeBufferPhotoTarget;
  final int swipeBufferVideoTarget;
  final int swipeVisibleCards;
  final int swipeUndoLimit;
  final int fullResHistoryLimit;
  final int thumbnailBytesCacheLimit;
  final int fileSizeLabelCacheLimit;
  final int fileSizeBytesCacheLimit;
  final int animatedBytesCacheLimit;
  final int deleteMilestoneBytes;
  final Duration deleteMilestoneMinInterval;
}
