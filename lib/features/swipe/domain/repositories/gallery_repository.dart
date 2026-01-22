import 'package:photo_manager/photo_manager.dart';

import '../entities/delete_assets_result.dart';
import '../entities/gallery_load_result.dart';
import '../entities/gallery_permission.dart';

abstract class GalleryRepository {
  Future<GalleryLoadResult> loadGallery({
    required int videoPage,
    required int otherPage,
    required int videoCount,
    required int otherCount,
  });

  Future<bool> openGallerySettings(GalleryPermission? currentState);

  Future<DeleteAssetsResult> deleteAssets(List<AssetEntity> assets);
}
