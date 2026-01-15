import 'package:flutter/material.dart';

import '../../../styles/colors.dart';
import '../../../styles/spacing.dart';

class FullscreenCloseButton extends StatelessWidget {
  const FullscreenCloseButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.modalCloseButton,
      height: AppSpacing.modalCloseButton,
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(
          Icons.close,
          color: AppColors.modalHandle,
          size: AppSpacing.modalCloseIcon,
        ),
        splashRadius: AppSpacing.modalCloseButton / 2,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: AppSpacing.modalCloseButton,
          minHeight: AppSpacing.modalCloseButton,
        ),
      ),
    );
  }
}
