import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:cullr/core/models/asset_details.dart';
import 'package:cullr/core/utils/asset_formatters.dart';

void main() {
  test('formatDuration pads minutes and seconds', () {
    expect(formatDuration(const Duration(seconds: 5)), '00:05');
    expect(formatDuration(const Duration(seconds: 65)), '01:05');
  });

  test('assetTypeLabel title cases enum value', () {
    expect(assetTypeLabel(AssetType.image), 'Image');
    expect(assetTypeLabel(AssetType.video), 'Video');
  });

  test('formatFileType prefers title extension', () {
    final AssetDetails details = AssetDetails(
      id: '1',
      title: 'image.jpeg',
      path: '/tmp/ignore.png',
      fileSizeBytes: null,
      width: 0,
      height: 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(0),
      type: AssetType.image,
      subtype: 0,
      duration: 0,
      orientation: 0,
      latLng: null,
      mimeType: 'image/png',
    );

    expect(formatFileType(details), 'JPEG');
  });

  test('formatFileType falls back to path extension', () {
    final AssetDetails details = AssetDetails(
      id: '1',
      title: '',
      path: '/tmp/video.mov',
      fileSizeBytes: null,
      width: 0,
      height: 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(0),
      type: AssetType.video,
      subtype: 0,
      duration: 0,
      orientation: 0,
      latLng: null,
      mimeType: null,
    );

    expect(formatFileType(details), 'MOV');
  });

  test('formatFileType uses mime subtype when no extension', () {
    final AssetDetails details = AssetDetails(
      id: '1',
      title: '',
      path: null,
      fileSizeBytes: null,
      width: 0,
      height: 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(0),
      type: AssetType.image,
      subtype: 0,
      duration: 0,
      orientation: 0,
      latLng: null,
      mimeType: 'image/jpeg',
    );

    expect(formatFileType(details), 'JPEG');
  });

  test('formatFileType returns null for unknown mime', () {
    final AssetDetails details = AssetDetails(
      id: '1',
      title: '',
      path: null,
      fileSizeBytes: null,
      width: 0,
      height: 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(0),
      type: AssetType.image,
      subtype: 0,
      duration: 0,
      orientation: 0,
      latLng: null,
      mimeType: 'invalid',
    );

    expect(formatFileType(details), isNull);
  });
}
