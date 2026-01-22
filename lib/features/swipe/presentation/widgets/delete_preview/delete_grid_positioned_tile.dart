import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../../../styles/colors.dart';
import '../../../../../styles/spacing.dart';
import '../../../domain/entities/media_asset.dart';
import 'delete_grid_tile.dart';
import 'poof_painter.dart';

class DeleteGridPositionedTile extends StatelessWidget {
  const DeleteGridPositionedTile({
    super.key,
    required this.asset,
    required this.cachedBytes,
    required this.thumbnailFuture,
    required this.onRemove,
    this.onTap,
    this.onLongPress,
    required this.showCheckbox,
    required this.selected,
    required this.removing,
    required this.tileSize,
    required this.spacing,
    required this.columns,
    required this.index,
    required this.fadeDuration,
    required this.reflowDuration,
  });

  final MediaAsset asset;
  final Uint8List? cachedBytes;
  final Future<Uint8List?> thumbnailFuture;
  final VoidCallback onRemove;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showCheckbox;
  final bool selected;
  final bool removing;
  final double tileSize;
  final double spacing;
  final int columns;
  final int index;
  final Duration fadeDuration;
  final Duration reflowDuration;

  @override
  Widget build(BuildContext context) {
    final int row = index ~/ columns;
    final int col = index % columns;
    final double top = row * (tileSize + spacing);
    final double left = col * (tileSize + spacing);

    return AnimatedPositioned(
      duration: reflowDuration,
      curve: Curves.easeInOut,
      top: top,
      left: left,
      width: tileSize,
      height: tileSize,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: removing ? 1.0 : 0.0),
        duration: fadeDuration,
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: 1 - value,
            child: Transform.translate(
              offset: Offset(0, -AppSpacing.poofLift * value),
              child: Transform.scale(
                scale: 1 - (0.22 * value),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: AppSpacing.poofBlur * value,
                        sigmaY: AppSpacing.poofBlur * value,
                      ),
                      child: child,
                    ),
                    if (value > 0)
                      IgnorePointer(
                        child: CustomPaint(
                          painter: PoofPainter(
                            progress: value,
                            seed: asset.id.hashCode,
                            color: AppColors.poofTint,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
        child: DeleteGridTile(
          asset: asset,
          cachedBytes: cachedBytes,
          thumbnailFuture: thumbnailFuture,
          onRemove: removing ? null : onRemove,
          onTap: onTap,
          onLongPress: onLongPress,
          showCheckbox: showCheckbox,
          selected: selected,
        ),
      ),
    );
  }
}
