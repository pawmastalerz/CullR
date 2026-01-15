import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/lru_cache.dart';

class ThumbnailCache {
  final Map<String, Future<Uint8List?>> _futureCache =
      <String, Future<Uint8List?>>{};
  final LruCache<String, Uint8List> _bytesCache = LruCache<String, Uint8List>(
    AppConfig.thumbnailBytesCacheLimit,
  );

  Future<Uint8List?> load(AssetEntity entity) {
    final Uint8List? cached = _bytesCache.get(entity.id);
    if (cached != null) {
      return Future<Uint8List?>.value(cached);
    }
    return _futureCache.putIfAbsent(entity.id, () {
      final Future<Uint8List?> future = entity
          .thumbnailDataWithSize(const ThumbnailSize(1200, 1200))
          .then((Uint8List? data) {
            if (data != null) {
              _bytesCache.set(entity.id, data);
            }
            return data;
          });
      return future.whenComplete(() {
        _futureCache.remove(entity.id);
      });
    });
  }

  Uint8List? bytesFor(String id) => _bytesCache.get(id);

  Map<String, Uint8List> snapshot() => _bytesCache.snapshot();

  void remove(String id) {
    _bytesCache.remove(id);
    _futureCache.remove(id);
  }

  void clear() {
    _futureCache.clear();
    _bytesCache.clear();
  }
}
