import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:cullr/core/utils/asset_utils.dart';

class _MockAssetEntity extends Mock implements AssetEntity {}

void main() {
  test('isAnimatedAsset true for gif mime', () {
    final _MockAssetEntity asset = _MockAssetEntity();
    when(() => asset.mimeType).thenReturn('image/gif');
    when(() => asset.title).thenReturn('image.png');

    expect(isAnimatedAsset(asset), isTrue);
  });

  test('isAnimatedAsset true for gif title', () {
    final _MockAssetEntity asset = _MockAssetEntity();
    when(() => asset.mimeType).thenReturn('image/png');
    when(() => asset.title).thenReturn('clip.GIF');

    expect(isAnimatedAsset(asset), isTrue);
  });

  test('isAnimatedAsset false when mime and title are not gif', () {
    final _MockAssetEntity asset = _MockAssetEntity();
    when(() => asset.mimeType).thenReturn('image/png');
    when(() => asset.title).thenReturn('photo.png');

    expect(isAnimatedAsset(asset), isFalse);
  });

  test('isAnimatedAsset false when title is null', () {
    final _MockAssetEntity asset = _MockAssetEntity();
    when(() => asset.mimeType).thenReturn(null);
    when(() => asset.title).thenReturn(null);

    expect(isAnimatedAsset(asset), isFalse);
  });
}
