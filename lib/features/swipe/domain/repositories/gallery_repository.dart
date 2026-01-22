import '../entities/delete_assets_result.dart';
import '../entities/gallery_load_result.dart';
import '../entities/gallery_permission.dart';
import '../entities/media_asset.dart';
import '../entities/media_details.dart';

abstract class GalleryRepository {
  Future<GalleryLoadResult> loadGallery({
    required int videoPage,
    required int otherPage,
    required int videoCount,
    required int otherCount,
  });

  Future<bool> openGallerySettings(GalleryPermission? currentState);

  Future<DeleteAssetsResult> deleteAssets(List<MediaAsset> assets);

  Future<MediaAsset?> loadAssetById(String id);

  Future<MediaDetails> loadDetails(MediaAsset asset);
}
