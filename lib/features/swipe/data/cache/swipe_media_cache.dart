import 'dart:io';
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

import '../../../../core/utils/cache/async_lru_cache.dart';
import '../../domain/utils/asset_utils.dart' as asset_utils;
import '../../../../core/utils/formatters/file_size_formatter.dart';
import '../../../../core/utils/cache/lru_cache.dart';
import '../../domain/entities/media_asset.dart';
import '../../domain/entities/swipe_config.dart';
import '../../domain/repositories/media_repository.dart';
import 'thumbnail_cache.dart';

class SwipeHomeMediaCache implements MediaRepository {
  SwipeHomeMediaCache({
    required SwipeConfig config,
    AssetEntityLoader? assetLoader,
  }) : _assetLoader = assetLoader ?? AssetEntity.fromId,
       _thumbnailCache = ThumbnailCache(
         capacity: config.thumbnailBytesCacheLimit,
         loader: assetLoader ?? AssetEntity.fromId,
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

  final AssetEntityLoader _assetLoader;
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
  Future<Uint8List?> thumbnailFor(MediaAsset asset) {
    return _thumbnailCache.load(asset.id);
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
  Future<int?> fileSizeBytesFor(MediaAsset asset) {
    return _fileSizeBytesCache.getOrLoad(asset.id, () async {
      final File? file = await _fileFor(asset.id);
      if (file == null) {
        return null;
      }
      return file.length();
    });
  }

  @override
  Future<String?> fileSizeLabelFor(MediaAsset asset) {
    return _fileSizeCache.getOrLoad(asset.id, () async {
      final int? bytes = await fileSizeBytesFor(asset);
      if (bytes == null) {
        return null;
      }
      return formatFileSize(bytes);
    });
  }

  @override
  bool isAnimatedAsset(MediaAsset asset) {
    return asset_utils.isAnimatedAsset(asset);
  }

  @override
  Future<Uint8List?> animatedBytesFor(MediaAsset asset) {
    return _animatedBytesCache.getOrLoad(asset.id, () async {
      final AssetEntity? entity = await _assetLoader(asset.id);
      return entity?.originBytes;
    });
  }

  @override
  File? preloadedFileFor(MediaAsset asset) {
    if (_fullResId == asset.id) {
      return _fullResFile;
    }
    return _fullResCache.get(asset.id);
  }

  @override
  Future<File?> cacheFullResFor(List<MediaAsset> assets, int index) async {
    if (index < 0 || index >= assets.length) {
      return null;
    }
    final MediaAsset asset = assets[index];
    final File? cached = _fullResCache.get(asset.id);
    if (cached != null) {
      return cached;
    }
    final File? file = await _fileFor(asset.id);
    if (file != null) {
      _fullResCache.set(asset.id, file);
    }
    return file;
  }

  @override
  Future<void> preloadFullRes({
    required List<MediaAsset> assets,
    required int index,
  }) async {
    if (index < 0 || index >= assets.length) {
      _fullResId = null;
      _fullResFile = null;
      return;
    }
    final MediaAsset asset = assets[index];
    _fullResId = asset.id;
    _fullResFile = _fullResCache.get(asset.id);
    final File? file = await cacheFullResFor(assets, index);
    if (_fullResId == asset.id && file != null) {
      _fullResFile = file;
    }
  }

  @override
  Future<File?> originalFileFor(MediaAsset asset) async {
    final File? cached = preloadedFileFor(asset);
    if (cached != null) {
      return cached;
    }
    return _fileFor(asset.id);
  }

  Future<File?> _fileFor(String id) async {
    final AssetEntity? entity = await _assetLoader(id);
    if (entity == null) {
      return null;
    }
    return await entity.originFile ?? await entity.file;
  }
}
