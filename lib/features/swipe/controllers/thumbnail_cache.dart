import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

class ThumbnailCache {
  final Map<String, Future<Uint8List?>> _futureCache = {};
  final Map<String, Uint8List> _bytesCache = {};

  Future<Uint8List?> load(AssetEntity entity) {
    return _futureCache.putIfAbsent(
      entity.id,
      () => entity.thumbnailDataWithSize(const ThumbnailSize(1200, 1200)).then((
        Uint8List? data,
      ) {
        if (data != null) {
          _bytesCache[entity.id] = data;
        }
        return data;
      }),
    );
  }

  Uint8List? bytesFor(String id) => _bytesCache[id];

  Map<String, Uint8List> snapshot() => Map.unmodifiable(_bytesCache);

  void prefetch(List<AssetEntity> assets, int startIndex, int count) {
    if (startIndex < 0) {
      startIndex = 0;
    }
    int endIndex = startIndex + count;
    if (endIndex > assets.length) {
      endIndex = assets.length;
    }
    for (int i = startIndex; i < endIndex; i++) {
      load(assets[i]);
    }
  }

  void clear() {
    _futureCache.clear();
    _bytesCache.clear();
  }
}
