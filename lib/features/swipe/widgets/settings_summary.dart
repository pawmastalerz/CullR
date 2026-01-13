import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../styles/colors.dart';
import '../../../styles/spacing.dart';
import '../../../styles/typography.dart';

class SettingsSummary extends StatelessWidget {
  const SettingsSummary({
    super.key,
    required this.swipes,
    required this.deleted,
    required this.deleteBytes,
    required this.formatBytes,
  });

  final int swipes;
  final int deleted;
  final int deleteBytes;
  final String Function(int bytes) formatBytes;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
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
          Text(
            strings.settingsSummaryTitle,
            style: AppTypography.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            label: strings.settingsSummarySwipes,
            value: swipes.toString(),
          ),
          _SummaryRow(
            label: strings.settingsSummaryDeleted,
            value: deleted.toString(),
          ),
          _SummaryRow(
            label: strings.settingsSummaryDeleteSize,
            value: formatBytes(deleteBytes),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.textTheme.bodyMedium),
          Text(value, style: AppTypography.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
