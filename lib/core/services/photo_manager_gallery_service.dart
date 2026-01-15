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
    final PermissionState permissionState = await _photoManager
        .requestPermissionExtend();

    bool canLoadPhotos = true;
    bool canLoadVideos = true;
    PermissionState effectivePermissionState = permissionState;
    if (_isAndroid) {
      final permission_handler.PermissionStatus photosStatus =
          await _permissionClient.photosStatus();
      final permission_handler.PermissionStatus videosStatus =
          await _permissionClient.videosStatus();
      canLoadPhotos = photosStatus.isGranted;
      canLoadVideos = videosStatus.isGranted;
      if (!canLoadPhotos && !canLoadVideos) {
        return GalleryLoadResult(
          permissionState: permissionState,
          assets: const <AssetEntity>[],
          videos: const <AssetEntity>[],
          others: const <AssetEntity>[],
          totalAssets: 0,
        );
      }
      if (permissionState != PermissionState.authorized &&
          permissionState != PermissionState.limited) {
        effectivePermissionState = PermissionState.authorized;
      }
    } else if (permissionState != PermissionState.authorized &&
        permissionState != PermissionState.limited) {
      return GalleryLoadResult(
        permissionState: permissionState,
        assets: const <AssetEntity>[],
        videos: const <AssetEntity>[],
        others: const <AssetEntity>[],
        totalAssets: 0,
      );
    }

    int imageTotal = 0;
    List<AssetEntity> others = [];
    if (canLoadPhotos) {
      final List<AssetPathEntity> imagePaths = await _photoManager
          .getAssetPathList(type: RequestType.image, hasAll: true);
      final AssetPathEntity? imageAlbum = imagePaths.isNotEmpty
          ? imagePaths.first
          : null;
      imageTotal = imageAlbum == null
          ? 0
          : await imageAlbum.assetCountAsync;
      others = imageAlbum == null
          ? []
          : await imageAlbum.getAssetListPaged(
              page: otherPage,
              size: otherCount,
            );
    }

    int videoTotal = 0;
    List<AssetEntity> videos = [];
    if (canLoadVideos) {
      final List<AssetPathEntity> videoPaths = await _photoManager
          .getAssetPathList(type: RequestType.video, hasAll: true);
      final AssetPathEntity? videoAlbum = videoPaths.isNotEmpty
          ? videoPaths.first
          : null;
      if (videoAlbum != null) {
        videoTotal = await videoAlbum.assetCountAsync;
        videos = await videoAlbum.getAssetListPaged(
          page: videoPage,
          size: videoCount,
        );
      }
    }

    others.shuffle();
    videos.shuffle();
    final List<AssetEntity> assets = [...others, ...videos];

    return GalleryLoadResult(
      permissionState: effectivePermissionState,
      assets: assets,
      videos: videos,
      others: others,
      totalAssets: imageTotal + videoTotal,
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
}
