import 'dart:io';

import 'package:photo_manager/photo_manager.dart';

import '../../domain/entities/media_asset.dart';
import '../../domain/entities/media_details.dart';
import '../../domain/entities/media_kind.dart';

MediaKind mapMediaKind(AssetType type) {
  switch (type) {
    case AssetType.image:
      return MediaKind.photo;
    case AssetType.video:
      return MediaKind.video;
    default:
      return MediaKind.other;
  }
}

MediaAsset mapMediaAsset(AssetEntity entity) {
  return MediaAsset(
    id: entity.id,
    kind: mapMediaKind(entity.type),
    width: entity.width,
    height: entity.height,
    duration: entity.duration,
    orientation: entity.orientation,
    subtype: entity.subtype,
    createdAt: entity.createDateTime,
    modifiedAt: entity.modifiedDateTime,
    title: entity.title,
    mimeType: entity.mimeType,
    latitude: entity.latLng?.latitude,
    longitude: entity.latLng?.longitude,
  );
}

Future<MediaDetails> mapMediaDetails(AssetEntity entity, {File? file}) async {
  final String title = entity.title ?? await entity.titleAsync;
  final int? fileSizeBytes = file == null ? null : await file.length();
  return MediaDetails(
    id: entity.id,
    title: title,
    path: file?.path,
    fileSizeBytes: fileSizeBytes,
    width: entity.width,
    height: entity.height,
    createdAt: entity.createDateTime,
    modifiedAt: entity.modifiedDateTime,
    kind: mapMediaKind(entity.type),
    subtype: entity.subtype,
    duration: entity.duration,
    orientation: entity.orientation,
    latitude: entity.latLng?.latitude,
    longitude: entity.latLng?.longitude,
    mimeType: entity.mimeType,
  );
}
