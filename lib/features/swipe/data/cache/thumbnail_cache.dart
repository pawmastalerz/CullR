import 'dart:typed_data';

import '../../../../core/utils/cache/async_lru_cache.dart';
import 'package:photo_manager/photo_manager.dart';

typedef AssetEntityLoader = Future<AssetEntity?> Function(String id);

class ThumbnailCache {
  ThumbnailCache({required int capacity, required AssetEntityLoader loader})
    : _loader = loader,
      _cache = AsyncLruCache<String, Uint8List>(capacity: capacity);

  final AssetEntityLoader _loader;
  final AsyncLruCache<String, Uint8List> _cache;

  Future<Uint8List?> load(String id) {
    return _cache.getOrLoad(id, () async {
      final AssetEntity? entity = await _loader(id);
      if (entity == null) {
        return null;
      }
      return entity.thumbnailDataWithSize(const ThumbnailSize(1200, 1200));
    });
  }

  Map<String, Uint8List> snapshot() => _cache.snapshot();

  void remove(String id) {
    _cache.remove(id);
  }

  void clear() {
    _cache.clear();
  }
}
