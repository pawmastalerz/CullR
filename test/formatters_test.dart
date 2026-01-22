import 'package:flutter_test/flutter_test.dart';

import 'package:cullr/core/utils/formatters/asset_formatters.dart';
import 'package:cullr/features/swipe/domain/entities/media_details.dart';
import 'package:cullr/features/swipe/domain/entities/media_kind.dart';

void main() {
  test('formatDuration pads minutes and seconds', () {
    expect(formatDuration(const Duration(seconds: 5)), '00:05');
    expect(formatDuration(const Duration(seconds: 65)), '01:05');
  });

  test('assetTypeLabel title cases enum value', () {
    expect(assetTypeLabel(MediaKind.photo), 'Photo');
    expect(assetTypeLabel(MediaKind.video), 'Video');
  });

  test('formatFileType prefers title extension', () {
    final MediaDetails details = MediaDetails(
      id: '1',
      title: 'image.jpeg',
      path: '/tmp/ignore.png',
      fileSizeBytes: null,
      width: 0,
      height: 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(0),
      kind: MediaKind.photo,
      subtype: 0,
      duration: 0,
      orientation: 0,
      latitude: null,
      longitude: null,
      mimeType: 'image/png',
    );

    expect(formatFileType(details), 'JPEG');
  });

  test('formatFileType falls back to path extension', () {
    final MediaDetails details = MediaDetails(
      id: '1',
      title: '',
      path: '/tmp/video.mov',
      fileSizeBytes: null,
      width: 0,
      height: 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(0),
      kind: MediaKind.video,
      subtype: 0,
      duration: 0,
      orientation: 0,
      latitude: null,
      longitude: null,
      mimeType: null,
    );

    expect(formatFileType(details), 'MOV');
  });

  test('formatFileType uses mime subtype when no extension', () {
    final MediaDetails details = MediaDetails(
      id: '1',
      title: '',
      path: null,
      fileSizeBytes: null,
      width: 0,
      height: 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(0),
      kind: MediaKind.photo,
      subtype: 0,
      duration: 0,
      orientation: 0,
      latitude: null,
      longitude: null,
      mimeType: 'image/jpeg',
    );

    expect(formatFileType(details), 'JPEG');
  });

  test('formatFileType returns null for unknown mime', () {
    final MediaDetails details = MediaDetails(
      id: '1',
      title: '',
      path: null,
      fileSizeBytes: null,
      width: 0,
      height: 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(0),
      kind: MediaKind.photo,
      subtype: 0,
      duration: 0,
      orientation: 0,
      latitude: null,
      longitude: null,
      mimeType: 'invalid',
    );

    expect(formatFileType(details), isNull);
  });
}
