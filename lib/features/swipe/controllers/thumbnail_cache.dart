import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/async_lru_cache.dart';

class ThumbnailCache {
  final AsyncLruCache<String, Uint8List> _cache =
      AsyncLruCache<String, Uint8List>(
        capacity: AppConfig.thumbnailBytesCacheLimit,
      );

  Future<Uint8List?> load(AssetEntity entity) {
    return _cache.getOrLoad(entity.id, () {
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
