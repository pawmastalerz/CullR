// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'CullR';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get deletePermanently => 'Permanent verwijderen';

  @override
  String get noPhotosMarked => 'Geen foto’s gemarkeerd voor verwijdering.';

  @override
  String get galleryAccessNeeded => 'Toegang tot galerij vereist';

  @override
  String get galleryAccessMessage =>
      'CullR heeft toegang tot je galerij nodig.\nGeef toestemming om verder te gaan.';

  @override
  String get settingsAction => 'Instellingen';

  @override
  String get tryAgainAction => 'Opnieuw proberen';

  @override
  String get noPhotosFound => 'Geen foto’s gevonden';

  @override
  String get noPhotosMessage =>
      'Je galerij is leeg. Voeg foto’s toe en kom terug om ze te bekijken.';

  @override
  String get tabDelete => 'Verwijderen';

  @override
  String get tabKeep => 'Bewaren';

  @override
  String get noPhotosKept => 'Geen foto’s om te bewaren.';

  @override
  String get confirmDeleteTitle => 'Foto’s verwijderen?';

  @override
  String confirmDeleteMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Weet je zeker dat je $count foto’s wilt verwijderen?',
      one: 'Weet je zeker dat je $count foto wilt verwijderen?',
    );
    return '$_temp0';
  }

  @override
  String get cancelAction => 'Annuleren';

  @override
  String get deleteAction => 'Verwijderen';

  @override
  String get highResOriginalTab => 'Origineel';

  @override
  String get highResDetailsTab => 'Details';

  @override
  String get metadataFilename => 'Bestandsnaam';

  @override
  String get metadataDimensions => 'Afmetingen';

  @override
  String get metadataFileSize => 'Bestandsgrootte';

  @override
  String get metadataFormat => 'Formaat';

  @override
  String get metadataCreated => 'Aangemaakt';

  @override
  String get metadataModified => 'Gewijzigd';

  @override
  String get metadataType => 'Type';

  @override
  String get metadataSubtype => 'Subtype';

  @override
  String get metadataDuration => 'Duur';

  @override
  String get metadataOrientation => 'Oriëntatie';

  @override
  String get metadataLocation => 'Locatie';

  @override
  String get metadataPath => 'Pad';

  @override
  String get metadataId => 'ID';

  @override
  String get reEvaluateKeepTitle => 'Bewaarde items opnieuw analyseren?';

  @override
  String reEvaluateKeepMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bewaarde items opnieuw analyseren?',
      one: '$count bewaard item opnieuw analyseren?',
    );
    return '$_temp0';
  }

  @override
  String get reEvaluateKeepAction => 'Opnieuw analyseren';

  @override
  String get totalSizeLabel => 'Totale grootte';

  @override
  String get languageLabel => 'Taal';

  @override
  String get settingsSummaryTitle => 'Opschoonstatistieken';

  @override
  String get settingsSummarySwipes => 'Swipes';

  @override
  String get settingsSummaryMarked => 'Gemarkeerd';

  @override
  String get settingsSummaryKept => 'Bewaard';

  @override
  String get settingsSummaryDeleted => 'Verwijderd';

  @override
  String get settingsSummaryDeleteSize => 'Vrijgemaakte ruimte';

  @override
  String get allCaughtUpTitle => 'Je bent helemaal bij';

  @override
  String get allCaughtUpMessage =>
      'Er zijn nu geen foto\'s meer om te bekijken.';

  @override
  String get milestoneTitle => 'Gefeliciteerd!';

  @override
  String milestoneClearedMessage(int mb) {
    return 'Je hebt $mb MB vrijgemaakt.';
  }
}
