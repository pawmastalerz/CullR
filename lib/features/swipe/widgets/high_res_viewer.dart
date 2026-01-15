import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../../core/widgets/zoomable_viewer.dart';
import '../../../styles/colors.dart';
import '../../../styles/spacing.dart';
import 'video_viewer.dart';

class HighResViewer extends StatelessWidget {
  const HighResViewer({
    super.key,
    required this.preloadedFile,
    required this.loadFile,
    required this.isAnimated,
    required this.loadAnimatedBytes,
    required this.isVideo,
    required this.onInteraction,
  });

  final File? preloadedFile;
  final Future<File?> Function() loadFile;
  final bool isAnimated;
  final Future<Uint8List?> Function() loadAnimatedBytes;
  final bool isVideo;
  final ValueChanged<bool> onInteraction;

  @override
  Widget build(BuildContext context) {
    final Widget viewer = isVideo
        ? VideoViewer(preloadedFile: preloadedFile, loadFile: loadFile)
        : isAnimated
        ? FutureBuilder<Uint8List?>(
            future: loadAnimatedBytes(),
            builder: (context, snapshot) {
              final Uint8List? bytes = snapshot.data;
              if (bytes == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accentBlue),
                );
              }
              return ZoomableViewer(
                onInteraction: onInteraction,
                child: Center(
                  child: Image.memory(
                    bytes,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    gaplessPlayback: true,
                  ),
                ),
              );
            },
          )
        : preloadedFile != null
        ? ZoomableViewer(
            onInteraction: onInteraction,
            child: Center(
              child: Image.file(
                preloadedFile!,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          )
        : FutureBuilder<File?>(
            future: loadFile(),
            builder: (context, snapshot) {
              final File? file = snapshot.data;
              if (file == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accentBlue),
                );
              }
              return ZoomableViewer(
                onInteraction: onInteraction,
                child: Center(
                  child: Image.file(
                    file,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              );
            },
          );
    return Container(padding: AppSpacing.insetAllLg, child: viewer);
  }
}
