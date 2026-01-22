import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../styles/typography.dart';

class TotalSizeRow extends StatelessWidget {
  const TotalSizeRow({super.key, required this.totalFuture});

  final Future<String?> totalFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: totalFuture,
      builder: (context, snapshot) {
        final String value = snapshot.data ?? '—';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.totalSizeLabel,
              style: AppTypography.textTheme.bodyMedium,
            ),
            Text(value, style: AppTypography.textTheme.bodyLarge),
          ],
        );
      },
    );
  }
}
