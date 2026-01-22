import 'gallery_permission.dart';
import 'media_asset.dart';

class GalleryLoadResult {
  const GalleryLoadResult({
    required this.permission,
    required this.assets,
    required this.videos,
    required this.others,
    required this.totalAssets,
  });

  final GalleryPermission permission;
  final List<MediaAsset> assets;
  final List<MediaAsset> videos;
  final List<MediaAsset> others;
  final int totalAssets;
}
