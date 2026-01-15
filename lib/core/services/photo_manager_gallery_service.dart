import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import '../models/gallery_load_result.dart';
import 'gallery_service.dart';

class PhotoManagerGalleryService implements GalleryService {
  @override
  Future<GalleryLoadResult> loadGallery({
    required int videoPage,
    required int otherPage,
    required int videoCount,
    required int otherCount,
  }) async {
    final PermissionState permissionState =
        await PhotoManager.requestPermissionExtend();

    if (permissionState != PermissionState.authorized &&
        permissionState != PermissionState.limited) {
      return GalleryLoadResult(
        permissionState: permissionState,
        assets: const <AssetEntity>[],
        videos: const <AssetEntity>[],
        others: const <AssetEntity>[],
        totalAssets: 0,
      );
    }

    final List<AssetPathEntity> imagePaths =
        await PhotoManager.getAssetPathList(
          type: RequestType.image,
          hasAll: true,
        );
    final AssetPathEntity? imageAlbum = imagePaths.isNotEmpty
        ? imagePaths.first
        : null;
    final int imageTotal = imageAlbum == null
        ? 0
        : await imageAlbum.assetCountAsync;
    final List<AssetEntity> others = imageAlbum == null
        ? []
        : await imageAlbum.getAssetListPaged(page: otherPage, size: otherCount);

    bool hasVideoPermission = true;
    if (Platform.isAndroid) {
      final PermissionStatus videoStatus = await Permission.videos.request();
      hasVideoPermission = videoStatus.isGranted;
    }
    int videoTotal = 0;
    List<AssetEntity> videos = [];
    if (hasVideoPermission) {
      final List<AssetPathEntity> videoPaths =
          await PhotoManager.getAssetPathList(
            type: RequestType.video,
            hasAll: true,
          );
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
      permissionState: permissionState,
      assets: assets,
      videos: videos,
      others: others,
      totalAssets: imageTotal + videoTotal,
    );
  }

  @override
  Future<bool> openGallerySettings(PermissionState? currentState) async {
    if (Platform.isIOS && currentState == PermissionState.limited) {
      await PhotoManager.presentLimited(type: RequestType.image);
      return true;
    }

    if (Platform.isAndroid) {
      final PermissionStatus photosStatus = await Permission.photos.request();
      final PermissionStatus videosStatus = await Permission.videos.request();
      if (photosStatus.isGranted) {
        if (videosStatus.isGranted) {
          return true;
        }
        return true;
      }

      final PermissionStatus storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        return true;
      }

      await openAppSettings();
      return false;
    }

    await PhotoManager.openSetting();
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
      await PhotoManager.editor.deleteWithIds(assets.map((e) => e.id).toList());
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
