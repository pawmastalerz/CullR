import 'package:photo_manager/photo_manager.dart';

class AssetDetails {
  const AssetDetails({
    required this.id,
    required this.title,
    required this.path,
    required this.fileSizeBytes,
    required this.width,
    required this.height,
    required this.createdAt,
    required this.modifiedAt,
    required this.type,
    required this.subtype,
    required this.duration,
    required this.orientation,
    required this.latLng,
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
  final AssetType type;
  final int subtype;
  final int duration;
  final int orientation;
  final LatLng? latLng;
  final String? mimeType;
}
