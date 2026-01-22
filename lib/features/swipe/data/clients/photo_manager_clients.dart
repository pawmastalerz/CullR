import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:photo_manager/photo_manager.dart';

abstract class PhotoManagerClient {
  Future<PermissionState> requestPermissionExtend();
  Future<List<AssetPathEntity>> getAssetPathList({
    required RequestType type,
    required bool hasAll,
  });
  Future<void> presentLimited({required RequestType type});
  Future<void> openSetting();
  Future<List<String>> deleteWithIds(List<String> ids);
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
  Future<List<String>> deleteWithIds(List<String> ids) {
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
