import 'media_kind.dart';

class MediaAsset {
  const MediaAsset({
    required this.id,
    required this.kind,
    required this.width,
    required this.height,
    required this.duration,
    required this.orientation,
    required this.subtype,
    required this.createdAt,
    required this.modifiedAt,
    this.title,
    this.mimeType,
    this.latitude,
    this.longitude,
  });

  final String id;
  final MediaKind kind;
  final int width;
  final int height;
  final int duration;
  final int orientation;
  final int subtype;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String? title;
  final String? mimeType;
  final double? latitude;
  final double? longitude;

  bool get isVideo => kind == MediaKind.video;
}
