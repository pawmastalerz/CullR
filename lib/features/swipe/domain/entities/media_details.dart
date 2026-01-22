import 'media_kind.dart';

class MediaDetails {
  const MediaDetails({
    required this.id,
    required this.title,
    required this.path,
    required this.fileSizeBytes,
    required this.width,
    required this.height,
    required this.createdAt,
    required this.modifiedAt,
    required this.kind,
    required this.subtype,
    required this.duration,
    required this.orientation,
    required this.latitude,
    required this.longitude,
    required this.mimeType,
  });

  final String id;
  final String title;
  final String? path;
  final int? fileSizeBytes;
  final int width;
  final int height;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final MediaKind kind;
  final int subtype;
  final int duration;
  final int orientation;
  final double? latitude;
  final double? longitude;
  final String? mimeType;
}
