// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'CullR';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get deletePermanently => 'Elimina definitivamente';

  @override
  String get noPhotosMarked =>
      'Nessuna foto contrassegnata per l’eliminazione.';

  @override
  String get galleryAccessNeeded => 'Accesso alla galleria richiesto';

  @override
  String get galleryAccessMessage =>
      'CullR necessita dell’accesso alla galleria.\nConcedi l’autorizzazione per continuare.';

  @override
  String get settingsAction => 'Impostazioni';

  @override
  String get tryAgainAction => 'Riprova';

  @override
  String get noPhotosFound => 'Nessuna foto trovata';

  @override
  String get noPhotosMessage =>
      'La tua galleria è vuota. Aggiungi delle foto e torna per esaminarle.';

  @override
  String get tabDelete => 'Elimina';

  @override
  String get tabKeep => 'Mantieni';

  @override
  String get noPhotosKept => 'Nessuna foto da mantenere.';

  @override
  String get cancelAction => 'Annulla';

  @override
  String get deleteAction => 'Elimina';

  @override
  String get highResOriginalTab => 'Originale';

  @override
  String get highResDetailsTab => 'Dettagli';

  @override
  String get metadataFilename => 'Nome file';

  @override
  String get metadataDimensions => 'Dimensioni';

  @override
  String get metadataFileSize => 'Dimensione file';

  @override
  String get metadataFormat => 'Formato';

  @override
  String get metadataCreated => 'Creato';

  @override
  String get metadataModified => 'Modificato';

  @override
  String get metadataType => 'Tipo';

  @override
  String get metadataSubtype => 'Sottotipo';

  @override
  String get metadataDuration => 'Durata';

  @override
  String get metadataOrientation => 'Orientamento';

  @override
  String get metadataLocation => 'Posizione';

  @override
  String get metadataPath => 'Percorso';

  @override
  String get metadataId => 'ID';

  @override
  String get reEvaluateKeepTitle =>
      'Analizzare di nuovo gli elementi mantenuti?';

  @override
  String reEvaluateKeepMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Analizzare di nuovo $count elementi mantenuti?',
      one: 'Analizzare di nuovo $count elemento mantenuto?',
    );
    return '$_temp0';
  }

  @override
  String get reEvaluateKeepAction => 'Analizza di nuovo';

  @override
  String get totalSizeLabel => 'Dimensione totale';
  String get unknownDate => 'Sconosciuto';

  @override
  String get languageLabel => 'Lingua';

  @override
  String get settingsSummaryTitle => 'Statistiche di pulizia';

  @override
  String get settingsSummarySwipes => 'Scorrimenti';

  @override
  String get settingsSummaryMarked => 'Contrassegnati';

  @override
  String get settingsSummaryKept => 'Mantenuti';

  @override
  String get settingsSummaryDeleted => 'Eliminati';

  @override
  String get settingsSummaryDeleteSize => 'Spazio recuperato';

  @override
  String get allCaughtUpTitle => 'Sei al passo';

  @override
  String get allCaughtUpMessage =>
      'Al momento non ci sono altre foto da rivedere.';

  @override
  String get milestoneTitle => 'Complimenti!';

  @override
  String milestoneClearedMessage(int mb) {
    return 'Hai liberato $mb MB.';
  }
}
