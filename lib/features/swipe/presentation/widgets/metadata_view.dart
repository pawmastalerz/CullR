import 'package:flutter/material.dart';
import '../../../../core/utils/formatters/formatters.dart';
import '../../../../styles/colors.dart';
import '../../../../styles/spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/media_details.dart';
import 'metadata_models.dart';
import 'metadata_widgets.dart';

class MetadataView extends StatelessWidget {
  const MetadataView({super.key, required this.loadDetails});

  final Future<MediaDetails> Function() loadDetails;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final String locale = Localizations.localeOf(context).toString();
    return FutureBuilder<MediaDetails>(
      future: loadDetails(),
      builder: (context, snapshot) {
        final MediaDetails? details = snapshot.data;
        if (details == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accentBlue),
          );
        }
        final List<MetadataEntry> entries = [
          MetadataEntry(label: strings.metadataFilename, value: details.title),
          MetadataEntry(
            label: strings.metadataDimensions,
            value: details.width > 0 && details.height > 0
                ? '${details.width} × ${details.height}px'
                : null,
          ),
          MetadataEntry(
            label: strings.metadataFileSize,
            value: details.fileSizeBytes != null && details.fileSizeBytes! > 0
                ? formatFileSize(details.fileSizeBytes!)
                : null,
          ),
          MetadataEntry(
            label: strings.metadataFormat,
            value: formatFileType(details),
          ),
          MetadataEntry(
            label: strings.metadataCreated,
            value: formatDate(details.createdAt, locale),
          ),
          MetadataEntry(
            label: strings.metadataModified,
            value: formatDate(details.modifiedAt, locale),
          ),
          MetadataEntry(
            label: strings.metadataType,
            value: assetTypeLabel(details.kind),
          ),
          MetadataEntry(
            label: strings.metadataSubtype,
            value: details.subtype > 0 ? details.subtype.toString() : null,
          ),
          MetadataEntry(
            label: strings.metadataDuration,
            value: details.duration > 0
                ? formatDuration(Duration(seconds: details.duration))
                : null,
          ),
          MetadataEntry(
            label: strings.metadataOrientation,
            value: details.orientation != 0
                ? details.orientation.toString()
                : null,
          ),
          MetadataEntry(
            label: strings.metadataLocation,
            value: details.latitude == null || details.longitude == null
                ? null
                : '${details.latitude!.toStringAsFixed(5)}, ${details.longitude!.toStringAsFixed(5)}',
          ),
          MetadataEntry(label: strings.metadataPath, value: details.path),
          MetadataEntry(label: strings.metadataId, value: details.id),
        ];
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          itemCount: entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final MetadataEntry entry = entries[index];
            return MetadataTile(entry: entry);
          },
        );
      },
    );
  }
}
