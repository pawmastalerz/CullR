import 'dart:io';
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/asset_utils.dart' as asset_utils;
import '../../../core/utils/file_size_formatter.dart';
import 'thumbnail_cache.dart';

class SwipeHomeMediaCache {
  final ThumbnailCache _thumbnailCache = ThumbnailCache();
  final Map<String, String> _fileSizeCache = {};
  final Map<String, Future<String?>> _fileSizeFutures = {};
  final Map<String, int> _fileSizeBytesCache = {};
  final Map<String, Future<int?>> _fileSizeBytesFutures = {};
  final Map<String, Uint8List> _animatedBytesCache = {};
  final Map<String, Future<Uint8List?>> _animatedBytesFutures = {};
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

  Uint8List? cachedThumbnailBytes(String id) => _thumbnailCache.bytesFor(id);

  Map<String, Uint8List> thumbnailSnapshot() => _thumbnailCache.snapshot();

  String? cachedFileSizeLabel(String id) => _fileSizeCache[id];

  Future<int?> fileSizeBytesFutureFor(AssetEntity entity) {
    final int? cached = _fileSizeBytesCache[entity.id];
    if (cached != null) {
      return Future<int?>.value(cached);
    }
    final Future<int?>? existing = _fileSizeBytesFutures[entity.id];
    if (existing != null) {
      return existing;
    }
    final Future<int?> future = () async {
      final File? file = await entity.originFile ?? await entity.file;
      if (file == null) {
        return null;
      }
      final int bytes = await file.length();
      _fileSizeBytesCache[entity.id] = bytes;
      return bytes;
    }();
    _fileSizeBytesFutures[entity.id] = future;
    return future;
  }

  Future<String?> fileSizeFutureFor(AssetEntity entity) {
    final String? cached = _fileSizeCache[entity.id];
    if (cached != null) {
      return Future<String?>.value(cached);
    }
    final Future<String?>? existing = _fileSizeFutures[entity.id];
    if (existing != null) {
      return existing;
    }
    final Future<String?> future = () async {
      final int? bytes = await fileSizeBytesFutureFor(entity);
      if (bytes == null) {
        return null;
      }
      final String label = formatFileSize(bytes);
      _fileSizeCache[entity.id] = label;
      return label;
    }();
    _fileSizeFutures[entity.id] = future;
    return future;
  }

  bool isAnimatedAsset(AssetEntity entity) {
    return asset_utils.isAnimatedAsset(entity);
  }

  Future<Uint8List?> animatedBytesFutureFor(AssetEntity entity) {
    final Uint8List? cached = _animatedBytesCache[entity.id];
    if (cached != null) {
      return Future<Uint8List?>.value(cached);
    }
    final Future<Uint8List?>? existing = _animatedBytesFutures[entity.id];
    if (existing != null) {
      return existing;
    }
    final Future<Uint8List?> future = () async {
      final Uint8List? bytes = await entity.originBytes;
      if (bytes != null) {
        _animatedBytesCache[entity.id] = bytes;
      }
      return bytes;
    }();
    _animatedBytesFutures[entity.id] = future;
    return future;
  }

  void prefetchThumbnails(List<AssetEntity> assets, int startIndex, int count) {
    _thumbnailCache.prefetch(assets, startIndex, count);
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

  Future<FullResLoadResult?> preloadFullRes({
    required List<AssetEntity> assets,
    required int index,
  }) async {
    if (index < 0 || index >= assets.length) {
      _fullResId = null;
      _fullResFile = null;
      return null;
    }
    final AssetEntity entity = assets[index];
    _fullResId = entity.id;
    _fullResFile = _fullResCache[entity.id];
    final File? file = await cacheFullResFor(assets, index);
    if (_fullResId == entity.id && file != null) {
      _fullResFile = file;
      return FullResLoadResult(
        id: entity.id,
        file: file,
        isVideo: entity.type == AssetType.video,
      );
    }
    return null;
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
}

class FullResLoadResult {
  const FullResLoadResult({
    required this.id,
    required this.file,
    required this.isVideo,
  });

  final String id;
  final File file;
  final bool isVideo;
}
