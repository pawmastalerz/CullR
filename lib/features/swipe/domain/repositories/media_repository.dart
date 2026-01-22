import 'dart:io';
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

abstract class MediaRepository {
  Future<Uint8List?> thumbnailFor(AssetEntity entity);
  Map<String, Uint8List> thumbnailSnapshot();
  void evictThumbnail(String id);
  String? cachedFileSizeLabel(String id);
  Future<int?> fileSizeBytesFor(AssetEntity entity);
  Future<String?> fileSizeLabelFor(AssetEntity entity);
  bool isAnimatedAsset(AssetEntity entity);
  Future<Uint8List?> animatedBytesFor(AssetEntity entity);
  File? preloadedFileFor(AssetEntity entity);
  Future<File?> cacheFullResFor(List<AssetEntity> assets, int index);
  Future<void> preloadFullRes({
    required List<AssetEntity> assets,
    required int index,
  });
  void reset();
}
