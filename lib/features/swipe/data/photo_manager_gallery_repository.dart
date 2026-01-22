import 'dart:io';

import 'package:photo_manager/photo_manager.dart';

import '../domain/entities/delete_assets_result.dart';
import '../domain/entities/gallery_load_result.dart';
import '../domain/entities/gallery_permission.dart';
import '../domain/entities/media_asset.dart';
import '../domain/entities/media_details.dart';
import '../domain/repositories/gallery_repository.dart';
import 'clients/photo_manager_clients.dart';
import 'datasources/photo_library_data_source.dart';
import 'mappers/photo_manager_media_mapper.dart';
import 'services/gallery_permission_service.dart';

class PhotoManagerGalleryRepository implements GalleryRepository {
  PhotoManagerGalleryRepository({
    PhotoManagerClient? photoManager,
    PermissionClient? permissionClient,
    PhotoLibraryDataSource? libraryDataSource,
    GalleryPermissionService? permissionService,
    bool? isAndroid,
    bool? isIOS,
  }) : _library = _resolveLibrary(libraryDataSource, photoManager),
       _permissionService = _resolvePermissionService(
         permissionService,
         photoManager,
         permissionClient,
         isAndroid,
         isIOS,
       );

  final PhotoLibraryDataSource _library;
  final GalleryPermissionService _permissionService;

  static PhotoLibraryDataSource _resolveLibrary(
    PhotoLibraryDataSource? library,
    PhotoManagerClient? photoManager,
  ) {
    if (library != null) {
      return library;
    }
    final PhotoManagerClient effective =
        photoManager ?? DefaultPhotoManagerClient();
    return PhotoManagerDataSource(photoManager: effective);
  }

  static GalleryPermissionService _resolvePermissionService(
    GalleryPermissionService? service,
    PhotoManagerClient? photoManager,
    PermissionClient? permissionClient,
    bool? isAndroid,
    bool? isIOS,
  ) {
    if (service != null) {
      return service;
    }
    final PhotoManagerClient effectivePhotoManager =
        photoManager ?? DefaultPhotoManagerClient();
    final PermissionClient effectivePermissionClient =
        permissionClient ?? DefaultPermissionClient();
    return PhotoManagerPermissionService(
      photoManager: effectivePhotoManager,
      permissionClient: effectivePermissionClient,
      isAndroid: isAndroid,
      isIOS: isIOS,
    );
  }

  @override
  Future<GalleryLoadResult> loadGallery({
    required int videoPage,
    required int otherPage,
    required int videoCount,
    required int otherCount,
  }) async {
    final GalleryPermissionContext permission = await _permissionService
        .resolvePermissions();
    if (!permission.canLoad) {
      return _emptyResult(permission.permission);
    }

    final AlbumLoadResult images = permission.canLoadPhotos
        ? await _library.loadAlbum(
            type: RequestType.image,
            page: otherPage,
            size: otherCount,
          )
        : const AlbumLoadResult.empty();
    final AlbumLoadResult videos = permission.canLoadVideos
        ? await _library.loadAlbum(
            type: RequestType.video,
            page: videoPage,
            size: videoCount,
          )
        : const AlbumLoadResult.empty();

    final List<AssetEntity> shuffledImages = List.of(images.assets)..shuffle();
    final List<AssetEntity> shuffledVideos = List.of(videos.assets)..shuffle();
    final List<MediaAsset> mappedImages = shuffledImages
        .map(mapMediaAsset)
        .toList();
    final List<MediaAsset> mappedVideos = shuffledVideos
        .map(mapMediaAsset)
        .toList();
    final List<MediaAsset> assets = [...mappedImages, ...mappedVideos];

    return GalleryLoadResult(
      permission: permission.permission,
      assets: assets,
      videos: mappedVideos,
      others: mappedImages,
      totalAssets: images.total + videos.total,
    );
  }

  @override
  Future<bool> openGallerySettings(GalleryPermission? currentState) {
    return _permissionService.openGallerySettings(currentState);
  }

  @override
  Future<DeleteAssetsResult> deleteAssets(List<MediaAsset> assets) async {
    if (assets.isEmpty) {
      return const DeleteAssetsResult.empty();
    }
    try {
      final List<AssetEntity> entities = await _library.loadEntitiesFor(assets);
      if (entities.isEmpty) {
        return const DeleteAssetsResult.empty();
      }
      final List<String> deletedIds = await _library.deleteWithIds(
        entities.map((e) => e.id).toList(),
      );
      final Set<String> deletedIdSet = await _verifyDeletedIds(
        assets: entities,
        deletedIds: deletedIds.toSet(),
      );
      if (deletedIdSet.isEmpty) {
        return const DeleteAssetsResult.empty();
      }
      final Iterable<AssetEntity> deletedAssets = entities.where(
        (asset) => deletedIdSet.contains(asset.id),
      );
      int deletedBytes = 0;
      try {
        final List<Future<int?>> futures = deletedAssets
            .map(_fileSizeFor)
            .toList();
        final List<int?> sizes = await Future.wait(futures);
        deletedBytes = sizes.whereType<int>().fold(0, (sum, v) => sum + v);
      } catch (_) {}
      return DeleteAssetsResult(
        deletedIds: deletedIdSet,
        deletedBytes: deletedBytes,
      );
    } catch (_) {
      return const DeleteAssetsResult.empty();
    }
  }

  @override
  Future<MediaAsset?> loadAssetById(String id) async {
    final AssetEntity? entity = await _library.loadEntityById(id);
    if (entity == null) {
      return null;
    }
    return mapMediaAsset(entity);
  }

  @override
  Future<MediaDetails> loadDetails(MediaAsset asset) async {
    final AssetEntity? entity = await _library.loadEntityById(asset.id);
    if (entity == null) {
      return MediaDetails(
        id: asset.id,
        title: asset.title ?? '',
        path: null,
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
        mimeType: asset.mimeType,
      );
    }
    final File? file = await _library.loadFileFor(entity);
    return mapMediaDetails(entity, file: file);
  }

  Future<Set<String>> _verifyDeletedIds({
    required List<AssetEntity> assets,
    required Set<String> deletedIds,
  }) async {
    if (deletedIds.length == assets.length || assets.isEmpty) {
      return deletedIds;
    }
    final List<AssetEntity> remainingAssets = assets
        .where((asset) => !deletedIds.contains(asset.id))
        .toList();
    if (remainingAssets.isEmpty) {
      return deletedIds;
    }
    final Set<String> verifiedIds = {...deletedIds};
    for (int attempt = 0; attempt < 2; attempt += 1) {
      final List<Future<String?>> checks = remainingAssets.map((asset) async {
        final bool exists = await asset.exists;
        return exists ? null : asset.id;
      }).toList();
      final List<String?> verified = await Future.wait(checks);
      verifiedIds.addAll(verified.whereType<String>());
      if (verifiedIds.isNotEmpty) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
    return verifiedIds;
  }

  Future<int?> _fileSizeFor(AssetEntity entity) async {
    final File? file = await _library.loadFileFor(entity);
    if (file == null) {
      return null;
    }
    return file.length();
  }

  GalleryLoadResult _emptyResult(GalleryPermission permission) {
    return GalleryLoadResult(
      permission: permission,
      assets: const <MediaAsset>[],
      videos: const <MediaAsset>[],
      others: const <MediaAsset>[],
      totalAssets: 0,
    );
  }
}
