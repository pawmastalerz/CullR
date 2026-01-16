import 'dart:io';

import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:photo_manager/photo_manager.dart';

import '../models/gallery_load_result.dart';
import 'gallery_service.dart';

abstract class PhotoManagerClient {
  Future<PermissionState> requestPermissionExtend();
  Future<List<AssetPathEntity>> getAssetPathList({
    required RequestType type,
    required bool hasAll,
  });
  Future<void> presentLimited({required RequestType type});
  Future<void> openSetting();
  Future<void> deleteWithIds(List<String> ids);
}

class DefaultPhotoManagerClient implements PhotoManagerClient {
  @override
  Future<PermissionState> requestPermissionExtend() {
    return PhotoManager.requestPermissionExtend();
  }

  @override
  Future<List<AssetPathEntity>> getAssetPathList({
    required RequestType type,
    required bool hasAll,
  }) {
    return PhotoManager.getAssetPathList(type: type, hasAll: hasAll);
  }

  @override
  Future<void> presentLimited({required RequestType type}) {
    return PhotoManager.presentLimited(type: type);
  }

  @override
  Future<void> openSetting() {
    return PhotoManager.openSetting();
  }

  @override
  Future<void> deleteWithIds(List<String> ids) {
    return PhotoManager.editor.deleteWithIds(ids);
  }
}

abstract class PermissionClient {
  Future<permission_handler.PermissionStatus> requestPhotos();
  Future<permission_handler.PermissionStatus> requestVideos();
  Future<permission_handler.PermissionStatus> photosStatus();
  Future<permission_handler.PermissionStatus> videosStatus();
  Future<void> openAppSettings();
}

class DefaultPermissionClient implements PermissionClient {
  @override
  Future<permission_handler.PermissionStatus> requestPhotos() {
    return permission_handler.Permission.photos.request();
  }

  @override
  Future<permission_handler.PermissionStatus> requestVideos() {
    return permission_handler.Permission.videos.request();
  }

  @override
  Future<permission_handler.PermissionStatus> photosStatus() {
    return permission_handler.Permission.photos.status;
  }

  @override
  Future<permission_handler.PermissionStatus> videosStatus() {
    return permission_handler.Permission.videos.status;
  }

  @override
  Future<void> openAppSettings() {
    return permission_handler.openAppSettings();
  }
}

class PhotoManagerGalleryService implements GalleryService {
  PhotoManagerGalleryService({
    PhotoManagerClient? photoManager,
    PermissionClient? permissionClient,
    bool? isAndroid,
    bool? isIOS,
  }) : _photoManager = photoManager ?? DefaultPhotoManagerClient(),
       _permissionClient = permissionClient ?? DefaultPermissionClient(),
       _isAndroid = isAndroid ?? Platform.isAndroid,
       _isIOS = isIOS ?? Platform.isIOS;

  final PhotoManagerClient _photoManager;
  final PermissionClient _permissionClient;
  final bool _isAndroid;
  final bool _isIOS;

  @override
  Future<GalleryLoadResult> loadGallery({
    required int videoPage,
    required int otherPage,
    required int videoCount,
    required int otherCount,
  }) async {
    final _PermissionContext permission = await _resolvePermissions();
    if (!permission.canLoad) {
      return _emptyResult(permission.permissionState);
    }

    final _AlbumLoadResult images = await _loadAlbum(
      type: RequestType.image,
      page: otherPage,
      size: otherCount,
      canLoad: permission.canLoadPhotos,
    );
    final _AlbumLoadResult videos = await _loadAlbum(
      type: RequestType.video,
      page: videoPage,
      size: videoCount,
      canLoad: permission.canLoadVideos,
    );

    final List<AssetEntity> shuffledImages = List.of(images.assets)..shuffle();
    final List<AssetEntity> shuffledVideos = List.of(videos.assets)..shuffle();
    final List<AssetEntity> assets = [...shuffledImages, ...shuffledVideos];

    return GalleryLoadResult(
      permissionState: permission.permissionState,
      assets: assets,
      videos: shuffledVideos,
      others: shuffledImages,
      totalAssets: images.total + videos.total,
    );
  }

  @override
  Future<bool> openGallerySettings(PermissionState? currentState) async {
    if (_isIOS && currentState == PermissionState.limited) {
      await _photoManager.presentLimited(type: RequestType.image);
      return true;
    }

    if (_isAndroid) {
      final permission_handler.PermissionStatus photosStatus =
          await _permissionClient.requestPhotos();
      final permission_handler.PermissionStatus videosStatus =
          await _permissionClient.requestVideos();
      if (photosStatus.isGranted && videosStatus.isGranted) {
        return true;
      }

      await _permissionClient.openAppSettings();
      return false;
    }

    await _photoManager.openSetting();
    return false;
  }

  @override
  Future<int> deleteAssets(List<AssetEntity> assets) async {
    if (assets.isEmpty) {
      return 0;
    }
    int deletedBytes = 0;
    try {
      final List<Future<int?>> futures = assets.map(_fileSizeFor).toList();
      final List<int?> sizes = await Future.wait(futures);
      deletedBytes = sizes.whereType<int>().fold(0, (sum, v) => sum + v);
      await _photoManager.deleteWithIds(assets.map((e) => e.id).toList());
    } catch (_) {}
    return deletedBytes;
  }

  Future<int?> _fileSizeFor(AssetEntity entity) async {
    final File? file = await entity.originFile ?? await entity.file;
    if (file == null) {
      return null;
    }
    return file.length();
  }

  Future<_PermissionContext> _resolvePermissions() async {
    final PermissionState permissionState = await _photoManager
        .requestPermissionExtend();
    if (_isAndroid) {
      final permission_handler.PermissionStatus photosStatus =
          await _permissionClient.photosStatus();
      final permission_handler.PermissionStatus videosStatus =
          await _permissionClient.videosStatus();
      final bool canLoadPhotos = photosStatus.isGranted;
      final bool canLoadVideos = videosStatus.isGranted;
      if (!canLoadPhotos && !canLoadVideos) {
        return _PermissionContext.denied(permissionState);
      }
      final PermissionState effectiveState =
          permissionState == PermissionState.authorized ||
              permissionState == PermissionState.limited
          ? permissionState
          : PermissionState.authorized;
      return _PermissionContext.allowed(
        permissionState: effectiveState,
        canLoadPhotos: canLoadPhotos,
        canLoadVideos: canLoadVideos,
      );
    }
    if (permissionState != PermissionState.authorized &&
        permissionState != PermissionState.limited) {
      return _PermissionContext.denied(permissionState);
    }
    return _PermissionContext.allowed(
      permissionState: permissionState,
      canLoadPhotos: true,
      canLoadVideos: true,
    );
  }

  GalleryLoadResult _emptyResult(PermissionState permissionState) {
    return GalleryLoadResult(
      permissionState: permissionState,
      assets: const <AssetEntity>[],
      videos: const <AssetEntity>[],
      others: const <AssetEntity>[],
      totalAssets: 0,
    );
  }

  Future<_AlbumLoadResult> _loadAlbum({
    required RequestType type,
    required int page,
    required int size,
    required bool canLoad,
  }) async {
    if (!canLoad) {
      return const _AlbumLoadResult.empty();
    }
    final List<AssetPathEntity> paths = await _photoManager.getAssetPathList(
      type: type,
      hasAll: true,
    );
    final AssetPathEntity? album = paths.isNotEmpty ? paths.first : null;
    if (album == null) {
      return const _AlbumLoadResult.empty();
    }
    final int total = await album.assetCountAsync;
    final List<AssetEntity> assets = await album.getAssetListPaged(
      page: page,
      size: size,
    );
    return _AlbumLoadResult(total: total, assets: assets);
  }
}

class _AlbumLoadResult {
  const _AlbumLoadResult({required this.total, required this.assets});

  const _AlbumLoadResult.empty() : total = 0, assets = const <AssetEntity>[];

  final int total;
  final List<AssetEntity> assets;
}

class _PermissionContext {
  const _PermissionContext({
    required this.permissionState,
    required this.canLoadPhotos,
    required this.canLoadVideos,
    required this.canLoad,
  });

  const _PermissionContext.allowed({
    required PermissionState permissionState,
    required bool canLoadPhotos,
    required bool canLoadVideos,
  }) : this(
         permissionState: permissionState,
         canLoadPhotos: canLoadPhotos,
         canLoadVideos: canLoadVideos,
         canLoad: canLoadPhotos || canLoadVideos,
       );

  const _PermissionContext.denied(PermissionState permissionState)
    : this(
        permissionState: permissionState,
        canLoadPhotos: false,
        canLoadVideos: false,
        canLoad: false,
      );

  final PermissionState permissionState;
  final bool canLoadPhotos;
  final bool canLoadVideos;
  final bool canLoad;
}
