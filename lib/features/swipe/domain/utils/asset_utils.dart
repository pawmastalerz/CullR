import '../entities/media_asset.dart';

bool isAnimatedAsset(MediaAsset asset) {
  final String? mime = asset.mimeType?.toLowerCase();
  if (mime != null && mime.contains('gif')) {
    return true;
  }
  final String? name = asset.title;
  if (name == null) {
    return false;
  }
  return name.toLowerCase().endsWith('.gif');
}
