import 'package:photo_manager/photo_manager.dart';

bool isAnimatedAsset(AssetEntity entity) {
  final String? mime = entity.mimeType?.toLowerCase();
  if (mime != null && mime.contains('gif')) {
    return true;
  }
  final String? name = entity.title;
  if (name == null) {
    return false;
  }
  return name.toLowerCase().endsWith('.gif');
}
