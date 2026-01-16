class AppConfig {
  // Number of videos to request per gallery page.
  static const int galleryVideoBatchSize = 12;
  // Number of non-video assets to request per gallery page.
  static const int galleryOtherBatchSize = 48;
  // Total number of cards kept in the swipe buffer.
  static const int swipeBufferSize = 10;
  // Target number of photos in the swipe buffer mix.
  static const int swipeBufferPhotoTarget = 8;
  // Target number of videos in the swipe buffer mix.
  static const int swipeBufferVideoTarget = 2;
  // Number of cards visually stacked at once.
  static const int swipeVisibleCards = 3;
  // Maximum number of swipes that can be undone.
  static const int swipeUndoLimit = 3;
  // Number of full-resolution files kept in memory.
  static const int fullResHistoryLimit = 4;
  // Maximum number of thumbnail byte entries cached.
  static const int thumbnailBytesCacheLimit = 60;
  // Maximum number of formatted file-size labels cached.
  static const int fileSizeLabelCacheLimit = 400;
  // Maximum number of file-size byte values cached.
  static const int fileSizeBytesCacheLimit = 400;
  // Maximum number of animated (GIF) byte entries cached.
  static const int animatedBytesCacheLimit = 30;
}
