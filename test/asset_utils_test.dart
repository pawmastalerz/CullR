import 'package:flutter_test/flutter_test.dart';

import 'package:cullr/features/swipe/domain/utils/asset_utils.dart';
import 'package:cullr/features/swipe/domain/entities/media_asset.dart';
import 'package:cullr/features/swipe/domain/entities/media_kind.dart';

void main() {
  test('isAnimatedAsset true for gif mime', () {
    final MediaAsset asset = MediaAsset(
      id: 'a',
      kind: MediaKind.photo,
      width: 0,
      height: 0,
      duration: 0,
      orientation: 0,
      subtype: 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(0),
      mimeType: 'image/gif',
      title: 'image.png',
    );

    expect(isAnimatedAsset(asset), isTrue);
  });

  test('isAnimatedAsset true for gif title', () {
    final MediaAsset asset = MediaAsset(
      id: 'b',
      kind: MediaKind.photo,
      width: 0,
      height: 0,
      duration: 0,
      orientation: 0,
      subtype: 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(0),
      mimeType: 'image/png',
      title: 'clip.GIF',
    );

    expect(isAnimatedAsset(asset), isTrue);
  });

  test('isAnimatedAsset false when mime and title are not gif', () {
    final MediaAsset asset = MediaAsset(
      id: 'c',
      kind: MediaKind.photo,
      width: 0,
      height: 0,
      duration: 0,
      orientation: 0,
      subtype: 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(0),
      mimeType: 'image/png',
      title: 'photo.png',
    );

    expect(isAnimatedAsset(asset), isFalse);
  });

  test('isAnimatedAsset false when title is null', () {
    final MediaAsset asset = MediaAsset(
      id: 'd',
      kind: MediaKind.photo,
      width: 0,
      height: 0,
      duration: 0,
      orientation: 0,
      subtype: 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );

    expect(isAnimatedAsset(asset), isFalse);
  });
}
