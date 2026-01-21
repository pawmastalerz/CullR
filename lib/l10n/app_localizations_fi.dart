// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appTitle => 'CullR';

  @override
  String get settingsTitle => 'Asetukset';

  @override
  String get deletePermanently => 'Poista pysyvästi';

  @override
  String get noPhotosMarked => 'Ei poistettavaksi merkittyjä kuvia.';

  @override
  String get galleryAccessNeeded => 'Gallerian käyttöoikeus vaaditaan';

  @override
  String get galleryAccessMessage =>
      'CullR tarvitsee pääsyn galleriaasi.\nAnna lupa jatkaaksesi.';

  @override
  String get settingsAction => 'Asetukset';

  @override
  String get tryAgainAction => 'Yritä uudelleen';

  @override
  String get noPhotosFound => 'Kuvia ei löytynyt';

  @override
  String get noPhotosMessage =>
      'Galleriasi on tyhjä. Lisää kuvia ja palaa tarkastelemaan niitä.';

  @override
  String get tabDelete => 'Poista';

  @override
  String get tabKeep => 'Säilytä';

  @override
  String get noPhotosKept => 'Ei säilytettäviä kuvia.';

  @override
  String get cancelAction => 'Peruuta';

  @override
  String get deleteAction => 'Poista';

  @override
  String get highResOriginalTab => 'Alkuperäinen';

  @override
  String get highResDetailsTab => 'Tiedot';

  @override
  String get metadataFilename => 'Tiedostonimi';

  @override
  String get metadataDimensions => 'Mitat';

  @override
  String get metadataFileSize => 'Tiedoston koko';

  @override
  String get metadataFormat => 'Muoto';

  @override
  String get metadataCreated => 'Luotu';

  @override
  String get metadataModified => 'Muokattu';

  @override
  String get metadataType => 'Tyyppi';

  @override
  String get metadataSubtype => 'Alatyyppi';

  @override
  String get metadataDuration => 'Kesto';

  @override
  String get metadataOrientation => 'Suunta';

  @override
  String get metadataLocation => 'Sijainti';

  @override
  String get metadataPath => 'Polku';

  @override
  String get metadataId => 'ID';

  @override
  String get reEvaluateKeepTitle =>
      'Analysoidaanko säilytetyt kohteet uudelleen?';

  @override
  String reEvaluateKeepMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Analysoidaanko $count säilytettyä kohdetta uudelleen?',
      one: 'Analysoidaanko $count säilytetty kohde uudelleen?',
    );
    return '$_temp0';
  }

  @override
  String get reEvaluateKeepAction => 'Analysoi uudelleen';

  @override
  String get totalSizeLabel => 'Kokonaiskoko';

  @override
  String get languageLabel => 'Kieli';

  @override
  String get settingsSummaryTitle => 'Puhdistustilastot';

  @override
  String get settingsSummarySwipes => 'Pyyhkäisyt';

  @override
  String get settingsSummaryMarked => 'Merkitty';

  @override
  String get settingsSummaryKept => 'Säilytetty';

  @override
  String get settingsSummaryDeleted => 'Poistettu';

  @override
  String get settingsSummaryDeleteSize => 'Vapautettu tila';

  @override
  String get allCaughtUpTitle => 'Olet ajan tasalla';

  @override
  String get allCaughtUpMessage =>
      'Ei enempää kuvia tarkistettavaksi juuri nyt.';

  @override
  String get milestoneTitle => 'Onneksi olkoon!';

  @override
  String milestoneClearedMessage(int mb) {
    return 'Sait vapautettua $mb Mt.';
  }
}
