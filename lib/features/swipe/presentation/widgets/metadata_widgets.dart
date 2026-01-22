import 'package:flutter/material.dart';

import '../../../../styles/colors.dart';
import '../../../../styles/spacing.dart';
import '../../../../styles/typography.dart';
import 'metadata_models.dart';

class MetadataTile extends StatelessWidget {
  const MetadataTile({super.key, required this.entry});

  final MetadataEntry entry;

  @override
  Widget build(BuildContext context) {
    final String value = entry.value?.trim().isNotEmpty == true
        ? entry.value!.trim()
        : '—';
    return Container(
      padding: AppSpacing.insetAllLg,
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.label, style: AppTypography.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTypography.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
