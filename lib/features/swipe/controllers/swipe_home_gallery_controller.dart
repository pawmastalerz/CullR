import 'dart:math' as math;
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

import '../../../core/config/app_config.dart';
import '../../../core/models/gallery_load_result.dart';
import '../../../core/services/gallery_service.dart';
import '../../../core/services/logger_service.dart';
import 'swipe_decision_store.dart';
import 'swipe_media_cache.dart';
import '../models/swipe_card.dart';

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

  final List<SwipeCard> buffer = [];
  final List<AssetEntity> _photoPool = [];
  final List<AssetEntity> _videoPool = [];
  final List<SwipeCard> _undoWindow = [];

  PermissionState? permissionState;
  bool initialLoadHadAssets = false;
  int videoPage = 0;
  int otherPage = 0;
  bool hasMoreVideos = true;
  bool hasMoreOthers = true;
  bool loadingMore = false;
  bool _filling = false;
  int totalSwipeTarget = 0;

  Future<GalleryLoadResult> loadGallery() async {
    initialLoadHadAssets = false;
    buffer.clear();
    _photoPool.clear();
    _videoPool.clear();
    _undoWindow.clear();
    _decisionStore.reset();
    _media.reset();
    videoPage = 0;
    otherPage = 0;
    hasMoreVideos = true;
    hasMoreOthers = true;
    loadingMore = false;
    _filling = false;
    totalSwipeTarget = 0;

    final GalleryLoadResult result = await _loadNextPage();
    permissionState = result.permissionState;
    await _decisionStore.loadDecisions();
    totalSwipeTarget = math.max(0, result.totalAssets);
    _appendPools(result);
    await fillBuffer();
    initialLoadHadAssets = buffer.isNotEmpty;
    return result;
  }

  Future<bool> ensureBuffer() async {
    if (loadingMore || _filling) {
      return false;
    }
    if (buffer.length >= AppConfig.swipeBufferSize) {
      return false;
    }
    await fillBuffer();
    return true;
  }

  Future<void> fillBuffer() async {
    if (_filling) {
      return;
    }
    _filling = true;
    try {
      while (buffer.length < AppConfig.swipeBufferSize) {
        if (_photoPool.isEmpty && _videoPool.isEmpty) {
          if (!hasMoreVideos && !hasMoreOthers) {
            break;
          }
          final GalleryLoadResult result = await _loadNextPage();
          _appendPools(result);
        }
        final AssetEntity? next = _nextFromPools();
        if (next == null) {
          break;
        }
        if (_decisionStore.isKept(next.id) ||
            _decisionStore.isMarkedForDelete(next.id)) {
          continue;
        }
        final Uint8List? bytes = await _media.thumbnailFutureFor(next);
        if (bytes == null) {
          continue;
        }
        buffer.add(SwipeCard(asset: next, thumbnailBytes: bytes));
      }
    } finally {
      _filling = false;
    }
  }

  SwipeCard? popForSwipe() {
    if (buffer.isEmpty) {
      return null;
    }
    final SwipeCard card = buffer.removeAt(0);
    _undoWindow.add(card);
    while (_undoWindow.length > AppConfig.swipeUndoLimit) {
      final SwipeCard removed = _undoWindow.removeAt(0);
      _media.evictThumbnail(removed.asset.id);
    }
    return card;
  }

  SwipeCard? undoSwipe() {
    if (_undoWindow.isEmpty) {
      return null;
    }
    final SwipeCard card = _undoWindow.removeLast();
    buffer.insert(0, card);
    while (buffer.length > AppConfig.swipeBufferSize) {
      final SwipeCard removed = buffer.removeLast();
      _media.evictThumbnail(removed.asset.id);
    }
    return card;
  }

  void removeAssetsById(Set<String> ids) {
    buffer.removeWhere((card) => ids.contains(card.asset.id));
    _photoPool.removeWhere((asset) => ids.contains(asset.id));
    _videoPool.removeWhere((asset) => ids.contains(asset.id));
    _undoWindow.removeWhere((card) => ids.contains(card.asset.id));
    for (final String id in ids) {
      _media.evictThumbnail(id);
    }
  }

  Future<GalleryLoadResult> _loadNextPage() async {
    loadingMore = true;
    final GalleryLoadResult result = await _galleryService.loadGallery(
      videoPage: videoPage,
      otherPage: otherPage,
      videoCount: AppConfig.galleryVideoBatchSize,
      otherCount: AppConfig.galleryOtherBatchSize,
    );
    permissionState = result.permissionState;
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
    _logBatch(result);
    loadingMore = false;
    return result;
  }

  void _appendPools(GalleryLoadResult result) {
    if (result.videos.isNotEmpty) {
      _videoPool.addAll(result.videos);
    }
    if (result.others.isNotEmpty) {
      _photoPool.addAll(result.others);
    }
  }

  AssetEntity? _nextFromPools() {
    final int targetVideos = AppConfig.swipeBufferVideoTarget;
    final int targetPhotos = AppConfig.swipeBufferPhotoTarget;
    final int currentVideos = buffer
        .where((card) => card.asset.type == AssetType.video)
        .length;
    final int currentPhotos = buffer.length - currentVideos;

    final bool needVideo =
        currentVideos < targetVideos && _videoPool.isNotEmpty;
    final bool needPhoto =
        currentPhotos < targetPhotos && _photoPool.isNotEmpty;

    if (needVideo) {
      return _videoPool.removeAt(0);
    }
    if (needPhoto) {
      return _photoPool.removeAt(0);
    }
    if (_photoPool.isNotEmpty) {
      return _photoPool.removeAt(0);
    }
    if (_videoPool.isNotEmpty) {
      return _videoPool.removeAt(0);
    }
    return null;
  }

  void _logBatch(GalleryLoadResult result) {
    AppLogger.batch(
      'gallery',
      'append videos=${result.videos.length} others=${result.others.length} '
          'videoPage=$videoPage otherPage=$otherPage '
          'hasMoreVideos=$hasMoreVideos '
          'hasMoreOthers=$hasMoreOthers',
    );
  }
}
