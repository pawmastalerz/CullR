import 'package:photo_manager/photo_manager.dart';

import '../models/gallery_load_result.dart';

abstract class GalleryService {
  Future<GalleryLoadResult> loadGallery({
    required int videoPage,
    required int otherPage,
    required int videoCount,
    required int otherCount,
  });

  Future<bool> openGallerySettings(PermissionState? currentState);

  Future<int> deleteAssets(List<AssetEntity> assets);
}
