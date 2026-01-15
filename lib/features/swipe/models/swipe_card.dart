import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

class SwipeCard {
  SwipeCard({required this.asset, required this.thumbnailBytes});

  final AssetEntity asset;
  final Uint8List thumbnailBytes;
}
