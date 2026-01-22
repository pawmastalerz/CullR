import 'package:photo_manager/photo_manager.dart';

import 'gallery_permission.dart';

class GalleryLoadResult {
  const GalleryLoadResult({
    required this.permission,
    required this.assets,
    required this.videos,
    required this.others,
    required this.totalAssets,
  });

  final GalleryPermission permission;
  final List<AssetEntity> assets;
  final List<AssetEntity> videos;
  final List<AssetEntity> others;
  final int totalAssets;
}
