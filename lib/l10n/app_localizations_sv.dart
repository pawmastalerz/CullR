// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appTitle => 'CullR';

  @override
  String get settingsTitle => 'Inställningar';

  @override
  String get deletePermanently => 'Ta bort permanent';

  @override
  String get noPhotosMarked => 'Inga foton markerade för borttagning.';

  @override
  String get galleryAccessNeeded => 'Åtkomst till galleri krävs';

  @override
  String get galleryAccessMessage =>
      'CullR behöver åtkomst till ditt galleri.\nGe behörighet för att fortsätta.';

  @override
  String get settingsAction => 'Inställningar';

  @override
  String get tryAgainAction => 'Försök igen';

  @override
  String get noPhotosFound => 'Inga foton hittades';

  @override
  String get noPhotosMessage =>
      'Ditt galleri är tomt. Lägg till foton och kom tillbaka för att granska dem.';

  @override
  String get tabDelete => 'Ta bort';

  @override
  String get tabKeep => 'Behåll';

  @override
  String get noPhotosKept => 'Inga foton att behålla.';

  @override
  String get cancelAction => 'Avbryt';

  @override
  String get deleteAction => 'Ta bort';

  @override
  String get highResOriginalTab => 'Original';

  @override
  String get highResDetailsTab => 'Detaljer';

  @override
  String get metadataFilename => 'Filnamn';

  @override
  String get metadataDimensions => 'Dimensioner';

  @override
  String get metadataFileSize => 'Filstorlek';

  @override
  String get metadataFormat => 'Format';

  @override
  String get metadataCreated => 'Skapad';

  @override
  String get metadataModified => 'Ändrad';

  @override
  String get metadataType => 'Typ';

  @override
  String get metadataSubtype => 'Undertyp';

  @override
  String get metadataDuration => 'Varaktighet';

  @override
  String get metadataOrientation => 'Orientering';

  @override
  String get metadataLocation => 'Plats';

  @override
  String get metadataPath => 'Sökväg';

  @override
  String get metadataId => 'ID';

  @override
  String get reEvaluateKeepTitle => 'Analysera sparade objekt igen?';

  @override
  String reEvaluateKeepMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Analysera $count sparade objekt igen?',
      one: 'Analysera $count sparat objekt igen?',
    );
    return '$_temp0';
  }

  @override
  String get reEvaluateKeepAction => 'Analysera igen';

  @override
  String get totalSizeLabel => 'Total storlek';
  String get unknownDate => 'Okänd';

  @override
  String get languageLabel => 'Språk';

  @override
  String get settingsSummaryTitle => 'Rensningsstatistik';

  @override
  String get settingsSummarySwipes => 'Svep';

  @override
  String get settingsSummaryMarked => 'Markerade';

  @override
  String get settingsSummaryKept => 'Behållna';

  @override
  String get settingsSummaryDeleted => 'Borttagna';

  @override
  String get settingsSummaryDeleteSize => 'Frigjort utrymme';

  @override
  String get allCaughtUpTitle => 'Du är ikapp';

  @override
  String get allCaughtUpMessage => 'Inga fler foton att granska just nu.';

  @override
  String get milestoneTitle => 'Grattis!';

  @override
  String milestoneClearedMessage(int mb) {
    return 'Du frigjorde $mb MB.';
  }
}
