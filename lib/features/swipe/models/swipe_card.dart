import 'dart:typed_data';

import '../domain/entities/media_asset.dart';

enum SwipeCardKind { asset, milestone }

class SwipeCard {
  SwipeCard._({
    required this.kind,
    this.asset,
    this.thumbnailBytes,
    this.clearedBytes,
  });

  factory SwipeCard.asset({
    required MediaAsset asset,
    required Uint8List thumbnailBytes,
  }) {
    return SwipeCard._(
      kind: SwipeCardKind.asset,
      asset: asset,
      thumbnailBytes: thumbnailBytes,
    );
  }

  factory SwipeCard.milestone({required int clearedBytes}) {
    return SwipeCard._(
      kind: SwipeCardKind.milestone,
      clearedBytes: clearedBytes,
    );
  }

  final SwipeCardKind kind;
  final MediaAsset? asset;
  final Uint8List? thumbnailBytes;
  final int? clearedBytes;

  bool get isAsset => kind == SwipeCardKind.asset;
  bool get isMilestone => kind == SwipeCardKind.milestone;
}
