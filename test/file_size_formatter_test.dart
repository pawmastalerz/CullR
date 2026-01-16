import 'package:flutter_test/flutter_test.dart';

import 'package:cullr/core/utils/file_size_formatter.dart';

void main() {
  test('formatFileSize renders bytes', () {
    expect(formatFileSize(0), '0 B');
    expect(formatFileSize(999), '999 B');
  });

  test('formatFileSize renders KB', () {
    expect(formatFileSize(1024), '1.0 KB');
    expect(formatFileSize(1536), '1.5 KB');
  });

  test('formatFileSize renders MB', () {
    expect(formatFileSize(1024 * 1024), '1.00 MB');
    expect(formatFileSize(5 * 1024 * 1024), '5.00 MB');
  });

  test('formatFileSize renders GB', () {
    expect(formatFileSize(1024 * 1024 * 1024), '1.00 GB');
  });
}
