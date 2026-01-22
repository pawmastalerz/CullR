import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:photo_manager/photo_manager.dart';

import 'package:cullr/features/swipe/data/photo_manager_gallery_repository.dart';
import 'package:cullr/features/swipe/domain/entities/media_asset.dart';

class _FakePhotoManagerClient implements PhotoManagerClient {
  PermissionState permissionState = PermissionState.authorized;
  List<AssetPathEntity> imagePaths = [];
  List<AssetPathEntity> videoPaths = [];
  bool presentLimitedCalled = false;
  bool openSettingCalled = false;
  List<String> deletedIds = [];

  @override
  Future<PermissionState> requestPermissionExtend() async {
    return permissionState;
  }

  @override
  Future<List<AssetPathEntity>> getAssetPathList({
    required RequestType type,
    required bool hasAll,
  }) async {
    return type == RequestType.image ? imagePaths : videoPaths;
  }

  @override
  Future<void> presentLimited({required RequestType type}) async {
    presentLimitedCalled = true;
  }

  @override
  Future<void> openSetting() async {
    openSettingCalled = true;
  }

  @override
  Future<List<String>> deleteWithIds(List<String> ids) async {
    deletedIds = List<String>.from(ids);
    return deletedIds;
  }
}

class _FakePermissionClient implements PermissionClient {
  permission_handler.PermissionStatus photosStatusValue =
      permission_handler.PermissionStatus.denied;
  permission_handler.PermissionStatus videosStatusValue =
      permission_handler.PermissionStatus.denied;
  int openSettingsCalls = 0;

  @override
  Future<permission_handler.PermissionStatus> requestPhotos() async {
    return photosStatusValue;
  }

  @override
  Future<permission_handler.PermissionStatus> requestVideos() async {
    return videosStatusValue;
  }

  @override
  Future<permission_handler.PermissionStatus> photosStatus() async {
    return photosStatusValue;
  }

  @override
  Future<permission_handler.PermissionStatus> videosStatus() async {
    return videosStatusValue;
  }

  @override
  Future<void> openAppSettings() async {
    openSettingsCalls += 1;
  }
}

class _MockAssetPathEntity extends Mock implements AssetPathEntity {}

class _MockAssetEntity extends Mock implements AssetEntity {}

void _stubAssetEntityBasics(
  _MockAssetEntity entity, {
  required String id,
  required AssetType type,
  String? title,
  String? mimeType,
  int width = 120,
  int height = 80,
  int duration = 0,
  int orientation = 0,
  int subtype = 0,
  DateTime? createdAt,
  DateTime? modifiedAt,
}) {
  when(() => entity.id).thenReturn(id);
  when(() => entity.type).thenReturn(type);
  when(() => entity.width).thenReturn(width);
  when(() => entity.height).thenReturn(height);
  when(() => entity.duration).thenReturn(duration);
  when(() => entity.orientation).thenReturn(orientation);
  when(() => entity.subtype).thenReturn(subtype);
  when(
    () => entity.createDateTime,
  ).thenReturn(createdAt ?? DateTime(2024, 1, 1));
  when(
    () => entity.modifiedDateTime,
  ).thenReturn(modifiedAt ?? DateTime(2024, 1, 2));
  when(() => entity.title).thenReturn(title);
  when(() => entity.mimeType).thenReturn(mimeType);
}

void main() {
  test('loadGallery returns empty when permission is denied', () async {
    final _FakePhotoManagerClient photoManager = _FakePhotoManagerClient()
      ..permissionState = PermissionState.denied;
    final _FakePermissionClient permissionClient = _FakePermissionClient();

    final PhotoManagerGalleryRepository service = PhotoManagerGalleryRepository(
      photoManager: photoManager,
      permissionClient: permissionClient,
      isAndroid: false,
      isIOS: false,
    );

    final result = await service.loadGallery(
      videoPage: 0,
      otherPage: 0,
      videoCount: 10,
      otherCount: 10,
    );

    expect(result.assets, isEmpty);
    expect(result.videos, isEmpty);
    expect(result.others, isEmpty);
    expect(result.totalAssets, 0);
    expect(photoManager.imagePaths, isEmpty);
    expect(photoManager.videoPaths, isEmpty);
  });

  test('loadGallery returns assets and totals when authorized', () async {
    final _FakePhotoManagerClient photoManager = _FakePhotoManagerClient();
    final _FakePermissionClient permissionClient = _FakePermissionClient();
    final _MockAssetPathEntity imagePath = _MockAssetPathEntity();
    final _MockAssetPathEntity videoPath = _MockAssetPathEntity();
    final _MockAssetEntity imageA = _MockAssetEntity();
    final _MockAssetEntity imageB = _MockAssetEntity();
    final _MockAssetEntity videoA = _MockAssetEntity();
    _stubAssetEntityBasics(
      imageA,
      id: 'image-a',
      type: AssetType.image,
      mimeType: 'image/jpeg',
    );
    _stubAssetEntityBasics(
      imageB,
      id: 'image-b',
      type: AssetType.image,
      mimeType: 'image/jpeg',
    );
    _stubAssetEntityBasics(
      videoA,
      id: 'video-a',
      type: AssetType.video,
      mimeType: 'video/mp4',
      duration: 12,
    );

    photoManager.permissionState = PermissionState.authorized;
    photoManager.imagePaths = [imagePath];
    photoManager.videoPaths = [videoPath];
    when(() => imagePath.assetCountAsync).thenAnswer((_) async => 2);
    when(() => videoPath.assetCountAsync).thenAnswer((_) async => 1);
    when(
      () => imagePath.getAssetListPaged(page: 0, size: 10),
    ).thenAnswer((_) async => [imageA, imageB]);
    when(
      () => videoPath.getAssetListPaged(page: 0, size: 10),
    ).thenAnswer((_) async => [videoA]);

    final PhotoManagerGalleryRepository service = PhotoManagerGalleryRepository(
      photoManager: photoManager,
      permissionClient: permissionClient,
      isAndroid: false,
      isIOS: false,
    );

    final result = await service.loadGallery(
      videoPage: 0,
      otherPage: 0,
      videoCount: 10,
      otherCount: 10,
    );

    expect(result.totalAssets, 3);
    expect(
      result.videos.map((MediaAsset asset) => asset.id),
      contains('video-a'),
    );
    expect(
      result.others.map((MediaAsset asset) => asset.id),
      containsAll(['image-a', 'image-b']),
    );
    expect(result.assets.length, 3);
  });

  test(
    'openGallerySettings on Android reloads only when permissions granted',
    () async {
      final _FakePhotoManagerClient photoManager = _FakePhotoManagerClient();
      final _FakePermissionClient permissionClient = _FakePermissionClient()
        ..photosStatusValue = permission_handler.PermissionStatus.granted
        ..videosStatusValue = permission_handler.PermissionStatus.denied;

      final PhotoManagerGalleryRepository service =
          PhotoManagerGalleryRepository(
            photoManager: photoManager,
            permissionClient: permissionClient,
            isAndroid: true,
            isIOS: false,
          );

      final bool shouldReload = await service.openGallerySettings(null);

      expect(shouldReload, isFalse);
      expect(permissionClient.openSettingsCalls, 1);
    },
  );
}
