import 'dart:io';
import 'dart:typed_data';

import '../entities/media_asset.dart';

abstract class MediaRepository {
  Future<Uint8List?> thumbnailFor(MediaAsset asset);
  Map<String, Uint8List> thumbnailSnapshot();
  void evictThumbnail(String id);
  String? cachedFileSizeLabel(String id);
  Future<int?> fileSizeBytesFor(MediaAsset asset);
  Future<String?> fileSizeLabelFor(MediaAsset asset);
  bool isAnimatedAsset(MediaAsset asset);
  Future<Uint8List?> animatedBytesFor(MediaAsset asset);
  File? preloadedFileFor(MediaAsset asset);
  Future<File?> cacheFullResFor(List<MediaAsset> assets, int index);
  Future<void> preloadFullRes({
    required List<MediaAsset> assets,
    required int index,
  });
  Future<File?> originalFileFor(MediaAsset asset);
  void reset();
}
