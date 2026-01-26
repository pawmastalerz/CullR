import 'dart:math' as math;

import '../../domain/entities/delete_assets_result.dart';
import '../../domain/entities/gallery_load_result.dart';
import '../../domain/entities/gallery_permission.dart';
import '../../domain/entities/media_asset.dart';
import '../../domain/entities/media_details.dart';
import '../../domain/entities/media_kind.dart';
import '../../domain/repositories/gallery_repository.dart';
import 'picsum_gallery_source.dart';

class PicsumGalleryRepository implements GalleryRepository {
  PicsumGalleryRepository({required PicsumGallerySource source})
    : _source = source;

  final PicsumGallerySource _source;
  final Set<String> _deletedIds = <String>{};

  @override
  Future<GalleryLoadResult> loadGallery({
    required int videoPage,
    required int otherPage,
    required int videoCount,
    required int otherCount,
  }) async {
    final List<PicsumImage> all = await _source.loadAll();
    final List<PicsumImage> available = all
        .where((item) => !_deletedIds.contains(item.id))
        .toList();
    final int start = otherPage * otherCount;
    final int end = math.min(start + otherCount, available.length);
    final List<PicsumImage> slice = start < available.length
        ? available.sublist(start, end)
        : const <PicsumImage>[];
    final List<MediaAsset> assets = slice.map(_mapMediaAsset).toList();
    return GalleryLoadResult(
      permission: GalleryPermission.authorized,
      assets: assets,
      videos: const <MediaAsset>[],
      others: assets,
      totalAssets: available.length,
    );
  }

  @override
  Future<bool> openGallerySettings(GalleryPermission? currentState) async {
    return false;
  }

  @override
  Future<DeleteAssetsResult> deleteAssets(List<MediaAsset> assets) async {
    if (assets.isEmpty) {
      return const DeleteAssetsResult.empty();
    }
    final Set<String> ids = assets.map((asset) => asset.id).toSet();
    _deletedIds.addAll(ids);
    return DeleteAssetsResult(deletedIds: ids, deletedBytes: 0);
  }

  @override
  Future<MediaAsset?> loadAssetById(String id) async {
    final PicsumImage? image = await _source.findById(id);
    if (image == null || _deletedIds.contains(id)) {
      return null;
    }
    return _mapMediaAsset(image);
  }

  @override
  Future<MediaDetails> loadDetails(MediaAsset asset) async {
    final PicsumImage? image = await _source.findById(asset.id);
    return MediaDetails(
      id: asset.id,
      title: image?.author ?? asset.title ?? '',
      path: image?.downloadUrl.toString(),
      fileSizeBytes: null,
      width: asset.width,
      height: asset.height,
      createdAt: asset.createdAt,
      modifiedAt: asset.modifiedAt,
      kind: asset.kind,
      subtype: asset.subtype,
      duration: asset.duration,
      orientation: asset.orientation,
      latitude: asset.latitude,
      longitude: asset.longitude,
      mimeType: asset.mimeType ?? 'image/jpeg',
    );
  }

  MediaAsset _mapMediaAsset(PicsumImage image) {
    final DateTime now = DateTime.now();
    return MediaAsset(
      id: image.id,
      kind: MediaKind.photo,
      width: image.width,
      height: image.height,
      duration: 0,
      orientation: 0,
      subtype: 0,
      createdAt: now,
      modifiedAt: now,
      title: image.author,
      mimeType: 'image/jpeg',
    );
  }
}
