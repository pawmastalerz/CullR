import 'dart:math';

import 'package:flutter/material.dart';

import '../../../styles/colors.dart';
import '../../../styles/spacing.dart';
import '../../../styles/typography.dart';
import 'delete_labels.dart';
import 'keep_labels.dart';

class SwipeOverlay extends StatelessWidget {
  const SwipeOverlay({
    super.key,
    required this.horizontalOffsetPercent,
    required this.labelSeed,
  });

  final int horizontalOffsetPercent;
  final String labelSeed;

  @override
  Widget build(BuildContext context) {
    final double progress = (horizontalOffsetPercent.abs().clamp(0, 100) / 100);
    if (progress == 0) {
      return const SizedBox.shrink();
    }

    final bool isRight = horizontalOffsetPercent > 0;
    final List<String> labels = isRight ? keepLabels : deleteLabels;
    final int seed = labelSeed.hashCode ^ (isRight ? 0x9E3779B9 : 0x7F4A7C15);
    final Random rng = Random(seed);
    final String label = labels[rng.nextInt(labels.length)];
    final Color color = isRight ? AppColors.accentGreen : AppColors.accentRed;
    final double scale = 0.8 + (0.4 * progress);
    final double rotation = (isRight ? -0.12 : 0.12) * progress;

    return Positioned(
      top: AppSpacing.xl,
      left: isRight ? AppSpacing.xl : null,
      right: isRight ? null : AppSpacing.xl,
      child: Transform.rotate(
        angle: rotation,
        child: Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: progress,
            child: Container(
              padding: AppSpacing.insetButton,
              decoration: BoxDecoration(
                border: Border.all(
                  color: color,
                  width: AppSpacing.overlayBorder,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Text(label, style: AppTypography.swipeLabel(color)),
            ),
          ),
        ),
      ),
    );
  }
}
