import 'dart:math' as math;

import 'package:photo_manager/photo_manager.dart';

import '../../../core/config/app_config.dart';
import '../../../core/models/gallery_load_result.dart';
import '../../../core/services/gallery_service.dart';
import '../../../core/services/logger_service.dart';
import 'swipe_decision_store.dart';
import 'swipe_media_cache.dart';

class SwipeHomeGalleryController {
  SwipeHomeGalleryController({
    required GalleryService galleryService,
    required SwipeDecisionStore decisionStore,
    required SwipeHomeMediaCache mediaCache,
  }) : _galleryService = galleryService,
       _decisionStore = decisionStore,
       _media = mediaCache;

  final GalleryService _galleryService;
  final SwipeDecisionStore _decisionStore;
  final SwipeHomeMediaCache _media;

  final List<AssetEntity> assets = [];
  PermissionState? permissionState;
  bool initialLoadHadAssets = false;
  int videoPage = 0;
  int otherPage = 0;
  bool hasMoreVideos = true;
  bool hasMoreOthers = true;
  bool loadingMore = false;
  int nonVideoInsertCounter = 0;
  int totalSwipeTarget = 0;

  Future<GalleryLoadResult> loadGallery() async {
    initialLoadHadAssets = false;
    assets.clear();
    _decisionStore.reset();
    _media.reset();
    videoPage = 0;
    otherPage = 0;
    hasMoreVideos = true;
    hasMoreOthers = true;
    loadingMore = false;
    nonVideoInsertCounter = 0;
    totalSwipeTarget = 0;

    final GalleryLoadResult result = await _galleryService.loadGallery(
      videoPage: videoPage,
      otherPage: otherPage,
      videoCount: AppConfig.galleryVideoBatchSize,
      otherCount: AppConfig.galleryOtherBatchSize,
    );
    initialLoadHadAssets = result.assets.isNotEmpty;
    await _decisionStore.loadKeeps();
    permissionState = result.permissionState;
    _applyBatch(result, reset: true);
    _decisionStore.syncKeeps(assets);
    return result;
  }

  Future<bool> maybeLoadMore({required int currentIndex}) async {
    if (loadingMore || (!hasMoreVideos && !hasMoreOthers)) {
      return false;
    }
    final RemainingCounts counts = remainingCounts(currentIndex);
    if (counts.videos > AppConfig.videoRefillThreshold ||
        counts.others > AppConfig.otherRefillThreshold) {
      AppLogger.info(
        'gallery.refill',
        'remaining videos=${counts.videos} others=${counts.others}',
      );
      return false;
    }
    AppLogger.warn(
      'gallery.refill',
      'threshold hit videos=${counts.videos}/${AppConfig.videoRefillThreshold} '
          'others=${counts.others}/${AppConfig.otherRefillThreshold}',
    );
    loadingMore = true;
    final GalleryLoadResult result = await _galleryService.loadGallery(
      videoPage: videoPage,
      otherPage: otherPage,
      videoCount: AppConfig.galleryVideoBatchSize,
      otherCount: AppConfig.galleryOtherBatchSize,
    );
    permissionState = result.permissionState;
    _applyBatch(result, reset: false);
    loadingMore = false;
    return true;
  }

  RemainingCounts remainingCounts(int currentIndex) {
    int videos = 0;
    int others = 0;
    final int safeIndex = math.max(0, currentIndex);
    for (int i = safeIndex; i < assets.length; i++) {
      if (assets[i].type == AssetType.video) {
        videos++;
      } else {
        others++;
      }
    }
    return RemainingCounts(videos: videos, others: others);
  }

  void _applyBatch(GalleryLoadResult result, {required bool reset}) {
    final List<AssetEntity> ordered = _interleaveBatch(
      result.others,
      result.videos,
    );
    final List<AssetEntity> filtered = ordered
        .where(
          (asset) =>
              !_decisionStore.isKept(asset.id) &&
              !_decisionStore.isMarkedForDelete(asset.id),
        )
        .toList();
    if (reset) {
      assets
        ..clear()
        ..addAll(filtered);
      totalSwipeTarget = math.max(
        0,
        result.totalAssets - _decisionStore.keepCount,
      );
    } else {
      assets.addAll(filtered);
    }
    if (result.videos.length < AppConfig.galleryVideoBatchSize) {
      hasMoreVideos = false;
    }
    if (result.others.length < AppConfig.galleryOtherBatchSize) {
      hasMoreOthers = false;
    }
    if (result.videos.isNotEmpty) {
      videoPage += 1;
    }
    if (result.others.isNotEmpty) {
      otherPage += 1;
    }
    _logBatch(result, reset);
  }

  List<AssetEntity> _interleaveBatch(
    List<AssetEntity> others,
    List<AssetEntity> videos,
  ) {
    if (videos.isEmpty) {
      nonVideoInsertCounter += others.length;
      return List<AssetEntity>.from(others);
    }
    final List<AssetEntity> ordered = [];
    int videoIndex = 0;
    for (final AssetEntity asset in others) {
      ordered.add(asset);
      nonVideoInsertCounter++;
      if (nonVideoInsertCounter % AppConfig.videoInsertInterval == 0 &&
          videoIndex < videos.length) {
        ordered.add(videos[videoIndex]);
        videoIndex++;
      }
    }
    while (videoIndex < videos.length) {
      ordered.add(videos[videoIndex]);
      videoIndex++;
    }
    return ordered;
  }

  void _logBatch(GalleryLoadResult result, bool reset) {
    AppLogger.batch(
      'gallery',
      '${reset ? 'initial' : 'append'} '
          'videos=${result.videos.length} others=${result.others.length} '
          'videoPage=$videoPage otherPage=$otherPage '
          'hasMoreVideos=$hasMoreVideos '
          'hasMoreOthers=$hasMoreOthers',
    );
    for (final AssetEntity asset in result.videos) {
      AppLogger.debug(
        'gallery.video',
        'id=${asset.id} title=${asset.title ?? ''} '
            'mime=${asset.mimeType ?? ''}',
      );
    }
    for (final AssetEntity asset in result.others) {
      AppLogger.debug(
        'gallery.other',
        'id=${asset.id} title=${asset.title ?? ''} '
            'mime=${asset.mimeType ?? ''} type=${asset.type}',
      );
    }
  }
}

class RemainingCounts {
  const RemainingCounts({required this.videos, required this.others});

  final int videos;
  final int others;
}
