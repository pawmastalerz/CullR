import 'dart:collection';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

import '../../../../core/services/logger_service.dart';
import '../entities/gallery_permission.dart';
import '../entities/gallery_load_result.dart';
import '../entities/swipe_config.dart';
import '../repositories/gallery_repository.dart';
import '../repositories/media_repository.dart';
import 'swipe_decision_store.dart';
import '../../models/swipe_card.dart';

class SwipeHomeGalleryController {
  SwipeHomeGalleryController({
    required GalleryRepository galleryRepository,
    required SwipeDecisionStore decisionStore,
    required MediaRepository mediaRepository,
    required SwipeConfig config,
  }) : _galleryRepository = galleryRepository,
       _decisionStore = decisionStore,
       _media = mediaRepository,
       _config = config;

  final GalleryRepository _galleryRepository;
  final SwipeDecisionStore _decisionStore;
  final MediaRepository _media;
  final SwipeConfig _config;

  final List<SwipeCard> _buffer = [];
  final List<AssetEntity> _photoPool = [];
  final List<AssetEntity> _videoPool = [];
  final List<SwipeCard> _undoWindow = [];

  GalleryPermission? _permissionState;
  bool _initialLoadHadAssets = false;
  int _videoPage = 0;
  int _otherPage = 0;
  bool _hasMoreVideos = true;
  bool _hasMoreOthers = true;
  bool _loadingMore = false;
  bool _filling = false;
  int _totalSwipeTarget = 0;

  List<SwipeCard> get buffer => UnmodifiableListView(_buffer);
  GalleryPermission? get permissionState => _permissionState;
  bool get initialLoadHadAssets => _initialLoadHadAssets;
  bool get hasMoreVideos => _hasMoreVideos;
  bool get hasMoreOthers => _hasMoreOthers;
  bool get loadingMore => _loadingMore;
  int get totalSwipeTarget => _totalSwipeTarget;
  bool get hasMilestoneCard => _buffer.any((card) => card.isMilestone);
  bool get canSwipeNow {
    return _buffer.isNotEmpty &&
        (_buffer.length >= 2 || !_hasPotentialNextCard);
  }

  bool get _hasPotentialNextCard {
    return _photoPool.isNotEmpty ||
        _videoPool.isNotEmpty ||
        _hasMoreVideos ||
        _hasMoreOthers ||
        _loadingMore ||
        _filling;
  }

  Future<GalleryLoadResult> loadGallery() async {
    _initialLoadHadAssets = false;
    _buffer.clear();
    _photoPool.clear();
    _videoPool.clear();
    _undoWindow.clear();
    _decisionStore.reset();
    _media.reset();
    _videoPage = 0;
    _otherPage = 0;
    _hasMoreVideos = true;
    _hasMoreOthers = true;
    _loadingMore = false;
    _filling = false;
    _totalSwipeTarget = 0;

    final GalleryLoadResult result = await _loadNextPage();
    _permissionState = result.permission;
    await _decisionStore.loadDecisions();
    _totalSwipeTarget = math.max(0, result.totalAssets);
    _appendPools(result);
    await fillBuffer();
    _initialLoadHadAssets = _buffer.isNotEmpty;
    return result;
  }

  Future<bool> ensureBuffer() async {
    if (_loadingMore || _filling) {
      return false;
    }
    if (_assetBufferCount() >= _config.swipeBufferSize) {
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
      while (_assetBufferCount() < _config.swipeBufferSize) {
        if (_photoPool.isEmpty && _videoPool.isEmpty) {
          if (!_hasMoreVideos && !_hasMoreOthers) {
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
        final Uint8List? bytes = await _media.thumbnailFor(next);
        if (bytes == null) {
          continue;
        }
        _buffer.add(SwipeCard.asset(asset: next, thumbnailBytes: bytes));
      }
      _reconcileTargetIfExhausted();
    } finally {
      _filling = false;
    }
  }

  int _assetBufferCount() => _buffer.where((card) => card.isAsset).length;

  SwipeCard? popForSwipe() {
    if (_buffer.isEmpty) {
      return null;
    }
    final SwipeCard card = _buffer.removeAt(0);
    if (card.isMilestone) {
      return card;
    }
    _undoWindow.add(card);
    while (_undoWindow.length > _config.swipeUndoLimit) {
      final SwipeCard removed = _undoWindow.removeAt(0);
      _media.evictThumbnail(removed.asset!.id);
    }
    return card;
  }

  void _reconcileTargetIfExhausted() {
    if (_hasMoreVideos ||
        _hasMoreOthers ||
        _photoPool.isNotEmpty ||
        _videoPool.isNotEmpty) {
      return;
    }
    final int decidedCount = _decisionStore.totalDecisionCount;
    final int remainingCount = _assetBufferCount();
    final int adjustedTarget = decidedCount + remainingCount;
    _totalSwipeTarget = math.min(_totalSwipeTarget, adjustedTarget);
  }

  SwipeCard? undoSwipe() {
    if (_undoWindow.isEmpty) {
      return null;
    }
    final SwipeCard card = _undoWindow.removeLast();
    _buffer.insert(0, card);
    while (_buffer.length > _config.swipeBufferSize) {
      final SwipeCard removed = _buffer.removeLast();
      _media.evictThumbnail(removed.asset!.id);
    }
    return card;
  }

  void applyDeletion(Set<String> ids) {
    _totalSwipeTarget = math.max(0, _totalSwipeTarget - ids.length);
    _removeAssetsById(ids);
  }

  void insertMilestoneCard({required int clearedBytes}) {
    if (_buffer.any((card) => card.isMilestone)) {
      return;
    }
    _buffer.insert(0, SwipeCard.milestone(clearedBytes: clearedBytes));
  }

  void _removeAssetsById(Set<String> ids) {
    _buffer.removeWhere((card) => card.isAsset && ids.contains(card.asset!.id));
    _photoPool.removeWhere((asset) => ids.contains(asset.id));
    _videoPool.removeWhere((asset) => ids.contains(asset.id));
    _undoWindow.removeWhere(
      (card) => card.isAsset && ids.contains(card.asset!.id),
    );
    for (final String id in ids) {
      _media.evictThumbnail(id);
    }
  }

  Future<GalleryLoadResult> _loadNextPage() async {
    _loadingMore = true;
    final GalleryLoadResult result = await _galleryRepository.loadGallery(
      videoPage: _videoPage,
      otherPage: _otherPage,
      videoCount: _config.galleryVideoBatchSize,
      otherCount: _config.galleryOtherBatchSize,
    );
    _permissionState = result.permission;
    if (result.videos.length < _config.galleryVideoBatchSize) {
      _hasMoreVideos = false;
    }
    if (result.others.length < _config.galleryOtherBatchSize) {
      _hasMoreOthers = false;
    }
    if (result.videos.isNotEmpty) {
      _videoPage += 1;
    }
    if (result.others.isNotEmpty) {
      _otherPage += 1;
    }
    _logBatch(result);
    _loadingMore = false;
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
    final int targetVideos = _config.swipeBufferVideoTarget;
    final int targetPhotos = _config.swipeBufferPhotoTarget;
    final int currentVideos = _buffer
        .where((card) => card.isAsset && card.asset!.type == AssetType.video)
        .length;
    final int currentPhotos = _assetBufferCount() - currentVideos;

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
          'videoPage=$_videoPage otherPage=$_otherPage '
          'hasMoreVideos=$_hasMoreVideos '
          'hasMoreOthers=$_hasMoreOthers',
    );
  }
}
