import 'dart:io';

import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:photo_manager/photo_manager.dart';

import '../../domain/entities/gallery_permission.dart';
import '../clients/photo_manager_clients.dart';

class GalleryPermissionContext {
  const GalleryPermissionContext({
    required this.permission,
    required this.canLoadPhotos,
    required this.canLoadVideos,
    required this.canLoad,
  });

  const GalleryPermissionContext.allowed({
    required GalleryPermission permission,
    required bool canLoadPhotos,
    required bool canLoadVideos,
  }) : this(
         permission: permission,
         canLoadPhotos: canLoadPhotos,
         canLoadVideos: canLoadVideos,
         canLoad: canLoadPhotos || canLoadVideos,
       );

  const GalleryPermissionContext.denied(GalleryPermission permission)
    : this(
        permission: permission,
        canLoadPhotos: false,
        canLoadVideos: false,
        canLoad: false,
      );

  final GalleryPermission permission;
  final bool canLoadPhotos;
  final bool canLoadVideos;
  final bool canLoad;
}

abstract class GalleryPermissionService {
  Future<GalleryPermissionContext> resolvePermissions();
  Future<bool> openGallerySettings(GalleryPermission? currentState);
}

class PhotoManagerPermissionService implements GalleryPermissionService {
  PhotoManagerPermissionService({
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
  Future<GalleryPermissionContext> resolvePermissions() async {
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
        return GalleryPermissionContext.denied(_mapPermission(permissionState));
      }
      final PermissionState effectiveState =
          permissionState == PermissionState.authorized ||
              permissionState == PermissionState.limited
          ? permissionState
          : PermissionState.authorized;
      return GalleryPermissionContext.allowed(
        permission: _mapPermission(effectiveState),
        canLoadPhotos: canLoadPhotos,
        canLoadVideos: canLoadVideos,
      );
    }
    if (permissionState != PermissionState.authorized &&
        permissionState != PermissionState.limited) {
      return GalleryPermissionContext.denied(_mapPermission(permissionState));
    }
    return GalleryPermissionContext.allowed(
      permission: _mapPermission(permissionState),
      canLoadPhotos: true,
      canLoadVideos: true,
    );
  }

  @override
  Future<bool> openGallerySettings(GalleryPermission? currentState) async {
    if (_isIOS && currentState == GalleryPermission.limited) {
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

  GalleryPermission _mapPermission(PermissionState state) {
    if (state == PermissionState.limited) {
      return GalleryPermission.limited;
    }
    if (state == PermissionState.authorized) {
      return GalleryPermission.authorized;
    }
    return GalleryPermission.denied;
  }
}
