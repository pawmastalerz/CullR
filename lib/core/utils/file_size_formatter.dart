String formatFileSize(int bytes) {
  const int kB = 1024;
  const int mB = kB * 1024;
  const int gB = mB * 1024;
  if (bytes >= gB) {
    return '${(bytes / gB).toStringAsFixed(2)} GB';
  }
  if (bytes >= mB) {
    return '${(bytes / mB).toStringAsFixed(2)} MB';
  }
  if (bytes >= kB) {
    return '${(bytes / kB).toStringAsFixed(1)} KB';
  }
  return '$bytes B';
}

String? formatFileSizeNullable(int? bytes) {
  if (bytes == null) {
    return null;
  }
  return formatFileSize(bytes);
}
