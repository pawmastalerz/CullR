import 'package:flutter/material.dart';

import '../../../styles/colors.dart';
import '../../../styles/spacing.dart';

class PlayBadge extends StatelessWidget {
  const PlayBadge({
    super.key,
    this.size = AppSpacing.buttonSize,
    this.iconSize = AppSpacing.iconXl,
    this.withShadow = false,
  });

  final double size;
  final double iconSize;
  final bool withShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.bgSurface.withValues(alpha: 0.7),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: withShadow
            ? const [
                BoxShadow(
                  color: AppColors.shadowSoft,
                  blurRadius: AppSpacing.cardShadowBlur,
                  offset: Offset(0, AppSpacing.cardShadowYOffset),
                ),
              ]
            : const [],
      ),
      child: Icon(
        Icons.play_arrow_rounded,
        color: AppColors.textPrimary,
        size: iconSize,
      ),
    );
  }
}
