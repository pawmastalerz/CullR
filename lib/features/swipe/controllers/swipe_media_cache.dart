import 'dart:io';
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/async_lru_cache.dart';
import '../../../core/utils/asset_utils.dart' as asset_utils;
import '../../../core/utils/file_size_formatter.dart';
import '../../../core/utils/lru_cache.dart';
import 'thumbnail_cache.dart';

class SwipeHomeMediaCache {
  final ThumbnailCache _thumbnailCache = ThumbnailCache();
  final AsyncLruCache<String, String> _fileSizeCache =
      AsyncLruCache<String, String>(
        capacity: AppConfig.fileSizeLabelCacheLimit,
      );
  final AsyncLruCache<String, int> _fileSizeBytesCache =
      AsyncLruCache<String, int>(capacity: AppConfig.fileSizeBytesCacheLimit);
  final AsyncLruCache<String, Uint8List> _animatedBytesCache =
      AsyncLruCache<String, Uint8List>(
        capacity: AppConfig.animatedBytesCacheLimit,
      );
  final LruCache<String, File> _fullResCache = LruCache<String, File>(
    AppConfig.fullResHistoryLimit,
  );
  String? _fullResId;
  File? _fullResFile;

  void reset() {
    _thumbnailCache.clear();
    _fileSizeCache.clear();
    _fileSizeBytesCache.clear();
    _animatedBytesCache.clear();
    _fullResCache.clear();
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
    return _fileSizeBytesCache.getOrLoad(entity.id, () async {
      final File? file = await entity.originFile ?? await entity.file;
      if (file == null) {
        return null;
      }
      return file.length();
    });
  }

  Future<String?> fileSizeFutureFor(AssetEntity entity) {
    return _fileSizeCache.getOrLoad(entity.id, () async {
      final int? bytes = await fileSizeBytesFutureFor(entity);
      if (bytes == null) {
        return null;
      }
      return formatFileSize(bytes);
    });
  }

  bool isAnimatedAsset(AssetEntity entity) {
    return asset_utils.isAnimatedAsset(entity);
  }

  Future<Uint8List?> animatedBytesFutureFor(AssetEntity entity) {
    return _animatedBytesCache.getOrLoad(entity.id, () => entity.originBytes);
  }

  File? preloadedFileFor(AssetEntity entity) {
    if (_fullResId == entity.id) {
      return _fullResFile;
    }
    return _fullResCache.get(entity.id);
  }

  Future<File?> cacheFullResFor(List<AssetEntity> assets, int index) async {
    if (index < 0 || index >= assets.length) {
      return null;
    }
    final AssetEntity entity = assets[index];
    final File? cached = _fullResCache.get(entity.id);
    if (cached != null) {
      return cached;
    }
    final File? file = await entity.originFile ?? await entity.file;
    if (file != null) {
      _fullResCache.set(entity.id, file);
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
    _fullResFile = _fullResCache.get(entity.id);
    final File? file = await cacheFullResFor(assets, index);
    if (_fullResId == entity.id && file != null) {
      _fullResFile = file;
    }
  }
}
