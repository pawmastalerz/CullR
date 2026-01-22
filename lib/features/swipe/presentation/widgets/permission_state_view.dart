import 'package:flutter/material.dart';

import '../../../../styles/colors.dart';
import '../../../../styles/spacing.dart';
import '../../../../styles/typography.dart';

class PermissionStateView extends StatelessWidget {
  const PermissionStateView({
    super.key,
    required this.title,
    required this.message,
    this.primaryAction,
    this.secondaryAction,
  });

  final String title;
  final String message;
  final PermissionAction? primaryAction;
  final PermissionAction? secondaryAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxCardWidth),
        child: Card(
          color: AppColors.bgSurface,
          child: Padding(
            padding: AppSpacing.insetAllXl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.md),
                Text(message, style: AppTypography.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xxl),
                if (primaryAction != null)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: primaryAction?.onPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentBlue,
                            foregroundColor: AppColors.accentBlueOn,
                          ),
                          child: Text(primaryAction!.label),
                        ),
                      ),
                      if (secondaryAction != null) ...[
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: secondaryAction?.onPressed,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.accentBlue,
                              side: const BorderSide(
                                color: AppColors.accentBlue,
                              ),
                            ),
                            child: Text(secondaryAction!.label),
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PermissionAction {
  const PermissionAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}
