part of 'swipe_home_page.dart';

class _SwipeHomeGallery {
  _SwipeHomeGallery(this._state);

  final _SwipeHomePageState _state;

  Future<void> loadGallery() async {
    _state._markNeedsBuild(() {
      _state._loading = true;
    });

    _state._initialLoadHadAssets = false;
    _state._assets.clear();
    _state._decisionStore.reset();
    _state._media.reset();
    _state._videoPage = 0;
    _state._otherPage = 0;
    _state._hasMoreVideos = true;
    _state._hasMoreOthers = true;
    _state._loadingMore = false;
    _state._nonVideoInsertCounter = 0;
    _state._totalSwipeTarget = 0;
    _state._progressSwipeCount = 0;

    final GalleryLoadResult result = await _state._galleryService.loadGallery(
      videoPage: _state._videoPage,
      otherPage: _state._otherPage,
      videoCount: AppConfig.galleryVideoBatchSize,
      otherCount: AppConfig.galleryOtherBatchSize,
    );
    _state._initialLoadHadAssets = result.assets.isNotEmpty;
    await _state._decisionStore.loadKeeps();
    if (!_state.mounted) {
      return;
    }
    _state._permissionState = result.permissionState;
    _applyBatch(result, reset: true);
    _state._decisionStore.syncKeeps(_state._assets);
    _state._currentIndex = 0;
    _state._media.prefetchThumbnails(
      _state._assets,
      _state._currentIndex,
      AppConfig.thumbnailPrefetchCount,
    );
    _state._initialPreloadFuture = _state._preloadFullRes(_state._currentIndex);
    maybeLoadMore();

    _state._markNeedsBuild(() {
      _state._loading = false;
    });
  }

  Future<void> openGallerySettings() async {
    final bool shouldReload = await _state._galleryService.openGallerySettings(
      _state._permissionState,
    );
    if (shouldReload) {
      await loadGallery();
    }
  }

  void _applyBatch(GalleryLoadResult result, {required bool reset}) {
    final List<AssetEntity> ordered = _interleaveBatch(
      result.others,
      result.videos,
    );
    final List<AssetEntity> filtered = ordered
        .where(
          (asset) =>
              !_state._decisionStore.isKept(asset.id) &&
              !_state._decisionStore.isMarkedForDelete(asset.id),
        )
        .toList();
    if (reset) {
      _state._assets
        ..clear()
        ..addAll(filtered);
      _state._totalSwipeTarget = math.max(
        0,
        result.totalAssets - _state._decisionStore.keepCount,
      );
    } else {
      _state._assets.addAll(filtered);
    }
    if (result.videos.length < AppConfig.galleryVideoBatchSize) {
      _state._hasMoreVideos = false;
    }
    if (result.others.length < AppConfig.galleryOtherBatchSize) {
      _state._hasMoreOthers = false;
    }
    if (result.videos.isNotEmpty) {
      _state._videoPage += 1;
    }
    if (result.others.isNotEmpty) {
      _state._otherPage += 1;
    }
    _logBatch(result, reset);
  }

  List<AssetEntity> _interleaveBatch(
    List<AssetEntity> others,
    List<AssetEntity> videos,
  ) {
    if (videos.isEmpty) {
      _state._nonVideoInsertCounter += others.length;
      return List<AssetEntity>.from(others);
    }
    final List<AssetEntity> ordered = [];
    int videoIndex = 0;
    for (final AssetEntity asset in others) {
      ordered.add(asset);
      _state._nonVideoInsertCounter++;
      if (_state._nonVideoInsertCounter % AppConfig.videoInsertInterval == 0 &&
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

  _RemainingCounts _remainingCounts() {
    int videos = 0;
    int others = 0;
    for (int i = _state._currentIndex; i < _state._assets.length; i++) {
      if (_state._assets[i].type == AssetType.video) {
        videos++;
      } else {
        others++;
      }
    }
    return _RemainingCounts(videos: videos, others: others);
  }

  Future<void> maybeLoadMore() async {
    if (_state._loadingMore ||
        (!_state._hasMoreVideos && !_state._hasMoreOthers)) {
      return;
    }
    final _RemainingCounts counts = _remainingCounts();
    if (counts.videos > AppConfig.videoRefillThreshold ||
        counts.others > AppConfig.otherRefillThreshold) {
      AppLogger.info(
        'gallery.refill',
        'remaining videos=${counts.videos} others=${counts.others}',
      );
      return;
    }
    AppLogger.warn(
      'gallery.refill',
      'threshold hit videos=${counts.videos}/${AppConfig.videoRefillThreshold} '
          'others=${counts.others}/${AppConfig.otherRefillThreshold}',
    );
    _state._loadingMore = true;
    final GalleryLoadResult result = await _state._galleryService.loadGallery(
      videoPage: _state._videoPage,
      otherPage: _state._otherPage,
      videoCount: AppConfig.galleryVideoBatchSize,
      otherCount: AppConfig.galleryOtherBatchSize,
    );
    _state._permissionState = result.permissionState;
    _applyBatch(result, reset: false);
    _state._loadingMore = false;
    _state._markNeedsBuild();
  }

  void _logBatch(GalleryLoadResult result, bool reset) {
    if (!_state.mounted) {
      return;
    }
    AppLogger.batch(
      'gallery',
      '${reset ? 'initial' : 'append'} '
          'videos=${result.videos.length} others=${result.others.length} '
          'videoPage=${_state._videoPage} otherPage=${_state._otherPage} '
          'hasMoreVideos=${_state._hasMoreVideos} '
          'hasMoreOthers=${_state._hasMoreOthers}',
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
