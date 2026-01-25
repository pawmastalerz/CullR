// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'CullR';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get deletePermanently => 'Dauerhaft löschen';

  @override
  String get noPhotosMarked => 'Keine Fotos zum Löschen markiert.';

  @override
  String get galleryAccessNeeded => 'Zugriff auf Galerie erforderlich';

  @override
  String get galleryAccessMessage =>
      'CullR benötigt Zugriff auf deine Galerie.\nErteile die Berechtigung, um fortzufahren.';

  @override
  String get settingsAction => 'Einstellungen';

  @override
  String get tryAgainAction => 'Erneut versuchen';

  @override
  String get noPhotosFound => 'Keine Fotos gefunden';

  @override
  String get noPhotosMessage =>
      'Deine Galerie ist leer. Füge Fotos hinzu und kehre zurück, um sie zu überprüfen.';

  @override
  String get tabDelete => 'Löschen';

  @override
  String get tabKeep => 'Behalten';

  @override
  String get noPhotosKept => 'Keine Fotos zum Behalten.';

  @override
  String get cancelAction => 'Abbrechen';

  @override
  String get deleteAction => 'Löschen';

  @override
  String get highResOriginalTab => 'Original';

  @override
  String get highResDetailsTab => 'Details';

  @override
  String get metadataFilename => 'Dateiname';

  @override
  String get metadataDimensions => 'Abmessungen';

  @override
  String get metadataFileSize => 'Dateigröße';

  @override
  String get metadataFormat => 'Format';

  @override
  String get metadataCreated => 'Erstellt';

  @override
  String get metadataModified => 'Geändert';

  @override
  String get metadataType => 'Typ';

  @override
  String get metadataSubtype => 'Untertyp';

  @override
  String get metadataDuration => 'Dauer';

  @override
  String get metadataOrientation => 'Ausrichtung';

  @override
  String get metadataLocation => 'Standort';

  @override
  String get metadataPath => 'Pfad';

  @override
  String get metadataId => 'ID';

  @override
  String get reEvaluateKeepTitle => 'Behaltene Elemente erneut analysieren?';

  @override
  String reEvaluateKeepMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Erneut $count behaltene Elemente analysieren?',
      one: 'Erneut $count behaltenes Element analysieren?',
    );
    return '$_temp0';
  }

  @override
  String get reEvaluateKeepAction => 'Erneut analysieren';

  @override
  String get totalSizeLabel => 'Gesamtgröße';

  @override
  String get unknownDate => 'Unbekannt';

  @override
  String get languageLabel => 'Sprache';

  @override
  String get settingsSummaryTitle => 'Bereinigungsstatistiken';

  @override
  String get settingsSummarySwipes => 'Wischbewegungen';

  @override
  String get settingsSummaryMarked => 'Markiert';

  @override
  String get settingsSummaryKept => 'Behalten';

  @override
  String get settingsSummaryDeleted => 'Gelöscht';

  @override
  String get settingsSummaryDeleteSize => 'Freigegebener Speicherplatz';

  @override
  String get allCaughtUpTitle => 'Du bist auf dem neuesten Stand';

  @override
  String get allCaughtUpMessage =>
      'Keine weiteren Fotos zum Durchsehen im Moment.';

  @override
  String get milestoneTitle => 'Glückwunsch!';

  @override
  String milestoneClearedMessage(int mb) {
    return 'Du hast $mb MB gelöscht.';
  }
}
