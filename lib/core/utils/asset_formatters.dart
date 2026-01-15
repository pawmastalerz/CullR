import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';

import '../models/asset_details.dart';

String formatDate(DateTime date, String locale) {
  final DateFormat formatter = DateFormat.yMMMd(locale).add_Hm();
  return formatter.format(date);
}

String formatDuration(Duration duration) {
  final int minutes = duration.inMinutes;
  final int seconds = duration.inSeconds.remainder(60);
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

String assetTypeLabel(AssetType type) {
  final String raw = type.toString().split('.').last;
  if (raw.isEmpty) {
    return '—';
  }
  return '${raw[0].toUpperCase()}${raw.substring(1)}';
}

String? formatFileType(AssetDetails details) {
  final String? name = details.title.isNotEmpty ? details.title : null;
  final String? path = details.path;
  final String? ext = _extractExtension(name) ?? _extractExtension(path);
  if (ext != null) {
    return ext.toUpperCase();
  }
  final String? mime = details.mimeType;
  if (mime == null || !mime.contains('/')) {
    return null;
  }
  final String subtype = mime.split('/').last;
  return subtype.toUpperCase();
}

String? _extractExtension(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  final int dot = value.lastIndexOf('.');
  if (dot == -1 || dot == value.length - 1) {
    return null;
  }
  return value.substring(dot + 1);
}
