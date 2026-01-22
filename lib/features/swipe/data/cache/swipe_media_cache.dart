import 'dart:io';
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

import '../../../../core/utils/async_lru_cache.dart';
import '../../../../core/utils/asset_utils.dart' as asset_utils;
import '../../../../core/utils/file_size_formatter.dart';
import '../../../../core/utils/lru_cache.dart';
import '../../domain/entities/swipe_config.dart';
import '../../domain/repositories/media_repository.dart';
import 'thumbnail_cache.dart';

class SwipeHomeMediaCache implements MediaRepository {
  SwipeHomeMediaCache({required SwipeConfig config})
    : _thumbnailCache = ThumbnailCache(
        capacity: config.thumbnailBytesCacheLimit,
      ),
      _fileSizeCache = AsyncLruCache<String, String>(
        capacity: config.fileSizeLabelCacheLimit,
      ),
      _fileSizeBytesCache = AsyncLruCache<String, int>(
        capacity: config.fileSizeBytesCacheLimit,
      ),
      _animatedBytesCache = AsyncLruCache<String, Uint8List>(
        capacity: config.animatedBytesCacheLimit,
      ),
      _fullResCache = LruCache<String, File>(config.fullResHistoryLimit);

  final ThumbnailCache _thumbnailCache;
  final AsyncLruCache<String, String> _fileSizeCache;
  final AsyncLruCache<String, int> _fileSizeBytesCache;
  final AsyncLruCache<String, Uint8List> _animatedBytesCache;
  final LruCache<String, File> _fullResCache;
  String? _fullResId;
  File? _fullResFile;

  @override
  void reset() {
    _thumbnailCache.clear();
    _fileSizeCache.clear();
    _fileSizeBytesCache.clear();
    _animatedBytesCache.clear();
    _fullResCache.clear();
    _fullResId = null;
    _fullResFile = null;
  }

  @override
  Future<Uint8List?> thumbnailFor(AssetEntity entity) {
    return _thumbnailCache.load(entity);
  }

  @override
  Map<String, Uint8List> thumbnailSnapshot() => _thumbnailCache.snapshot();

  @override
  void evictThumbnail(String id) {
    _thumbnailCache.remove(id);
  }

  @override
  String? cachedFileSizeLabel(String id) => _fileSizeCache.get(id);

  @override
  Future<int?> fileSizeBytesFor(AssetEntity entity) {
    return _fileSizeBytesCache.getOrLoad(entity.id, () async {
      final File? file = await entity.originFile ?? await entity.file;
      if (file == null) {
        return null;
      }
      return file.length();
    });
  }

  @override
  Future<String?> fileSizeLabelFor(AssetEntity entity) {
    return _fileSizeCache.getOrLoad(entity.id, () async {
      final int? bytes = await fileSizeBytesFor(entity);
      if (bytes == null) {
        return null;
      }
      return formatFileSize(bytes);
    });
  }

  @override
  bool isAnimatedAsset(AssetEntity entity) {
    return asset_utils.isAnimatedAsset(entity);
  }

  @override
  Future<Uint8List?> animatedBytesFor(AssetEntity entity) {
    return _animatedBytesCache.getOrLoad(entity.id, () => entity.originBytes);
  }

  @override
  File? preloadedFileFor(AssetEntity entity) {
    if (_fullResId == entity.id) {
      return _fullResFile;
    }
    return _fullResCache.get(entity.id);
  }

  @override
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

  @override
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
