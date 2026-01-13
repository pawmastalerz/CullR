import 'package:flutter/material.dart';

import '../../../styles/colors.dart';
import '../../../styles/spacing.dart';
import '../../../styles/typography.dart';

class SwipeOverlay extends StatelessWidget {
  const SwipeOverlay({
    super.key,
    required this.horizontalOffsetPercent,
    required this.cardIndex,
  });

  final int horizontalOffsetPercent;
  final int cardIndex;

  static const List<String> _nopeLabels = [
    'DELETE',
    'NAH',
    'NO WAY',
    'TRASH',
    'PASS',
    'BYE',
    'NOPE AF',
    'WHY',
    'YIKES',
    'MEH',
    'GONE',
    'BIN',
    'HARD NO',
    'NUKE',
    'MISS',
    'EWW',
    'NOT TODAY',
    'YEET',
    'BANISH',
    'NO SIR',
  ];
  static const List<String> _keepLabels = [
    'KEEP',
    'SAVE',
    'YES',
    'NICE',
    'GOOD',
    'OKAY',
    'YEP',
    'FAV',
    'WIN',
    'GOLD',
    'HOLD',
    'THIS',
    'CLEAN',
    'SAFE',
    'LOCK',
    'MINE',
    'LEGIT',
    'STAY',
    'COOL',
    'BASED',
  ];

  @override
  Widget build(BuildContext context) {
    final double progress = (horizontalOffsetPercent.abs().clamp(0, 100) / 100);
    if (progress == 0) {
      return const SizedBox.shrink();
    }

    final bool isRight = horizontalOffsetPercent > 0;
    final int safeIndex = cardIndex.abs();
    final String label = isRight
        ? _keepLabels[safeIndex % _keepLabels.length]
        : _nopeLabels[safeIndex % _nopeLabels.length];
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
