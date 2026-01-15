// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CullR';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get deletePermanently => 'Delete permanently';

  @override
  String get noPhotosMarked => 'No photos marked for deletion.';

  @override
  String get galleryAccessNeeded => 'Gallery access required';

  @override
  String get galleryAccessMessage =>
      'CullR needs access to your gallery.\nGrant permission to continue.';

  @override
  String get settingsAction => 'Settings';

  @override
  String get tryAgainAction => 'Try again';

  @override
  String get noPhotosFound => 'No photos found';

  @override
  String get noPhotosMessage =>
      'Your gallery is empty. Add photos and come back to review them.';

  @override
  String get tabDelete => 'Delete';

  @override
  String get tabKeep => 'Keep';

  @override
  String get noPhotosKept => 'No photos to keep.';

  @override
  String get confirmDeleteTitle => 'Delete photos?';

  @override
  String confirmDeleteMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Are you sure you want to delete $count photos?',
      one: 'Are you sure you want to delete $count photo?',
    );
    return '$_temp0';
  }

  @override
  String get cancelAction => 'Cancel';

  @override
  String get deleteAction => 'Delete';

  @override
  String get highResOriginalTab => 'Original';

  @override
  String get highResDetailsTab => 'Details';

  @override
  String get metadataFilename => 'Filename';

  @override
  String get metadataDimensions => 'Dimensions';

  @override
  String get metadataFileSize => 'File size';

  @override
  String get metadataFormat => 'Format';

  @override
  String get metadataCreated => 'Created';

  @override
  String get metadataModified => 'Modified';

  @override
  String get metadataType => 'Type';

  @override
  String get metadataSubtype => 'Subtype';

  @override
  String get metadataDuration => 'Duration';

  @override
  String get metadataOrientation => 'Orientation';

  @override
  String get metadataLocation => 'Location';

  @override
  String get metadataPath => 'Path';

  @override
  String get metadataId => 'ID';

  @override
  String get reEvaluateKeepTitle => 'Re-analyze kept items?';

  @override
  String reEvaluateKeepMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Re-analyze $count kept items?',
      one: 'Re-analyze $count kept item?',
    );
    return '$_temp0';
  }

  @override
  String get reEvaluateKeepAction => 'Re-analyze';

  @override
  String get totalSizeLabel => 'Total size';

  @override
  String get languageLabel => 'Language';

  @override
  String get settingsSummaryTitle => 'Cleanup statistics';

  @override
  String get settingsSummarySwipes => 'Swipes';

  @override
  String get settingsSummaryMarked => 'Marked';

  @override
  String get settingsSummaryKept => 'Kept';

  @override
  String get settingsSummaryDeleted => 'Deleted';

  @override
  String get settingsSummaryDeleteSize => 'Recovered space';

  @override
  String get allCaughtUpTitle => 'You are all caught up';

  @override
  String get allCaughtUpMessage => 'No more photos to review right now.';
}
