import 'package:photo_manager/photo_manager.dart';

class GalleryLoadResult {
  const GalleryLoadResult({
    required this.permissionState,
    required this.assets,
    required this.videos,
    required this.others,
  });

  final PermissionState permissionState;
  final List<AssetEntity> assets;
  final List<AssetEntity> videos;
  final List<AssetEntity> others;
}
