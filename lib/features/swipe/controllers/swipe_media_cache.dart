import 'dart:io';
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/asset_utils.dart' as asset_utils;
import '../../../core/utils/file_size_formatter.dart';
import '../../../core/utils/lru_cache.dart';
import 'thumbnail_cache.dart';

class SwipeHomeMediaCache {
  final ThumbnailCache _thumbnailCache = ThumbnailCache();
  final LruCache<String, String> _fileSizeCache = LruCache<String, String>(
    AppConfig.fileSizeLabelCacheLimit,
  );
  final Map<String, Future<String?>> _fileSizeFutures =
      <String, Future<String?>>{};
  final LruCache<String, int> _fileSizeBytesCache = LruCache<String, int>(
    AppConfig.fileSizeBytesCacheLimit,
  );
  final Map<String, Future<int?>> _fileSizeBytesFutures =
      <String, Future<int?>>{};
  final LruCache<String, Uint8List> _animatedBytesCache =
      LruCache<String, Uint8List>(AppConfig.animatedBytesCacheLimit);
  final Map<String, Future<Uint8List?>> _animatedBytesFutures =
      <String, Future<Uint8List?>>{};
  final Map<String, File> _fullResCache = {};
  final List<String> _fullResCacheOrder = [];
  String? _fullResId;
  File? _fullResFile;

  void reset() {
    _thumbnailCache.clear();
    _fileSizeCache.clear();
    _fileSizeFutures.clear();
    _fileSizeBytesCache.clear();
    _fileSizeBytesFutures.clear();
    _animatedBytesCache.clear();
    _animatedBytesFutures.clear();
    _fullResCache.clear();
    _fullResCacheOrder.clear();
    _fullResId = null;
    _fullResFile = null;
  }

  Future<Uint8List?> thumbnailFutureFor(AssetEntity entity) {
    return _thumbnailCache.load(entity);
  }

  Map<String, Uint8List> thumbnailSnapshot() => _thumbnailCache.snapshot();

  void evictThumbnail(String id) {
    _thumbnailCache.remove(id);
  }

  String? cachedFileSizeLabel(String id) => _fileSizeCache.get(id);

  Future<int?> fileSizeBytesFutureFor(AssetEntity entity) {
    return _getOrLoad(
      id: entity.id,
      cache: _fileSizeBytesCache,
      inflight: _fileSizeBytesFutures,
      loader: () async {
        final File? file = await entity.originFile ?? await entity.file;
        if (file == null) {
          return null;
        }
        final int bytes = await file.length();
        _fileSizeBytesCache.set(entity.id, bytes);
        return bytes;
      },
    );
  }

  Future<String?> fileSizeFutureFor(AssetEntity entity) {
    return _getOrLoad(
      id: entity.id,
      cache: _fileSizeCache,
      inflight: _fileSizeFutures,
      loader: () async {
        final int? bytes = await fileSizeBytesFutureFor(entity);
        if (bytes == null) {
          return null;
        }
        final String label = formatFileSize(bytes);
        _fileSizeCache.set(entity.id, label);
        return label;
      },
    );
  }

  bool isAnimatedAsset(AssetEntity entity) {
    return asset_utils.isAnimatedAsset(entity);
  }

  Future<Uint8List?> animatedBytesFutureFor(AssetEntity entity) {
    return _getOrLoad(
      id: entity.id,
      cache: _animatedBytesCache,
      inflight: _animatedBytesFutures,
      loader: () async {
        final Uint8List? bytes = await entity.originBytes;
        if (bytes != null) {
          _animatedBytesCache.set(entity.id, bytes);
        }
        return bytes;
      },
    );
  }

  File? preloadedFileFor(AssetEntity entity) {
    if (_fullResId == entity.id) {
      return _fullResFile;
    }
    return _fullResCache[entity.id];
  }

  Future<File?> cacheFullResFor(List<AssetEntity> assets, int index) async {
    if (index < 0 || index >= assets.length) {
      return null;
    }
    final AssetEntity entity = assets[index];
    final File? cached = _fullResCache[entity.id];
    if (cached != null) {
      return cached;
    }
    final File? file = await entity.originFile ?? await entity.file;
    if (file != null) {
      _rememberFullRes(entity.id, file);
    }
    return file;
  }

  Future<void> preloadFullRes({
    required List<AssetEntity> assets,
    required int index,
  }) async {
    if (index < 0 || index >= assets.length) {
      _fullResId = null;
      _fullResFile = null;
      return;
    }
    final AssetEntity entity = assets[index];
    _fullResId = entity.id;
    _fullResFile = _fullResCache[entity.id];
    final File? file = await cacheFullResFor(assets, index);
    if (_fullResId == entity.id && file != null) {
      _fullResFile = file;
    }
  }

  void _rememberFullRes(String id, File file) {
    _fullResCache[id] = file;
    _fullResCacheOrder.remove(id);
    _fullResCacheOrder.add(id);
    while (_fullResCacheOrder.length > AppConfig.fullResHistoryLimit) {
      final String removedId = _fullResCacheOrder.removeAt(0);
      _fullResCache.remove(removedId);
    }
  }

  Future<T?> _getOrLoad<T>({
    required String id,
    required LruCache<String, T> cache,
    required Map<String, Future<T?>> inflight,
    required Future<T?> Function() loader,
  }) {
    final T? cached = cache.get(id);
    if (cached != null) {
      return Future<T?>.value(cached);
    }
    final Future<T?>? existing = inflight[id];
    if (existing != null) {
      return existing;
    }
    final Future<T?> future = loader();
    inflight[id] = future;
    future.whenComplete(() {
      inflight.remove(id);
    });
    return future;
  }
}
