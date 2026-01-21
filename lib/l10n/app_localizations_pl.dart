// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'CullR';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get deletePermanently => 'Usuń trwale';

  @override
  String get noPhotosMarked => 'Brak zdjęć do usunięcia.';

  @override
  String get galleryAccessNeeded => 'Wymagany dostęp do galerii';

  @override
  String get galleryAccessMessage =>
      'CullR potrzebuje dostępu do galerii.\nNadaj uprawnienia, aby kontynuować.';

  @override
  String get settingsAction => 'Ustawienia';

  @override
  String get tryAgainAction => 'Spróbuj ponownie';

  @override
  String get noPhotosFound => 'Nie znaleziono zdjęć';

  @override
  String get noPhotosMessage =>
      'Twoja galeria jest pusta. Dodaj zdjęcia i wróć, aby przeglądać.';

  @override
  String get tabDelete => 'Usuń';

  @override
  String get tabKeep => 'Zachowaj';

  @override
  String get noPhotosKept => 'Brak zdjęć do zachowania.';

  @override
  String get cancelAction => 'Anuluj';

  @override
  String get deleteAction => 'Usuń';

  @override
  String get highResOriginalTab => 'Oryginał';

  @override
  String get highResDetailsTab => 'Szczegóły';

  @override
  String get metadataFilename => 'Nazwa pliku';

  @override
  String get metadataDimensions => 'Wymiary';

  @override
  String get metadataFileSize => 'Rozmiar pliku';

  @override
  String get metadataFormat => 'Format';

  @override
  String get metadataCreated => 'Utworzono';

  @override
  String get metadataModified => 'Zmieniono';

  @override
  String get metadataType => 'Typ';

  @override
  String get metadataSubtype => 'Podtyp';

  @override
  String get metadataDuration => 'Czas trwania';

  @override
  String get metadataOrientation => 'Orientacja';

  @override
  String get metadataLocation => 'Lokalizacja';

  @override
  String get metadataPath => 'Ścieżka';

  @override
  String get metadataId => 'ID';

  @override
  String get reEvaluateKeepTitle =>
      'Przeanalizować ponownie zachowane elementy?';

  @override
  String reEvaluateKeepMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Przeanalizować ponownie $count zachowanych elementów?',
      few: 'Przeanalizować ponownie $count zachowane elementy?',
      one: 'Przeanalizować ponownie $count zachowany element?',
    );
    return '$_temp0';
  }

  @override
  String get reEvaluateKeepAction => 'Przeanalizuj ponownie';

  @override
  String get totalSizeLabel => 'Łączny rozmiar';

  @override
  String get languageLabel => 'Język';

  @override
  String get settingsSummaryTitle => 'Statystyki czyszczenia';

  @override
  String get settingsSummarySwipes => 'Przesunięcia';

  @override
  String get settingsSummaryMarked => 'Oznaczone';

  @override
  String get settingsSummaryKept => 'Zachowane';

  @override
  String get settingsSummaryDeleted => 'Usunięte';

  @override
  String get settingsSummaryDeleteSize => 'Odzyskane miejsce';

  @override
  String get allCaughtUpTitle => 'Wszystko nadrobione';

  @override
  String get allCaughtUpMessage =>
      'Na razie nie ma więcej zdjęć do przejrzenia.';

  @override
  String get milestoneTitle => 'Gratulacje!';

  @override
  String milestoneClearedMessage(int mb) {
    return 'Udało Ci się zwolnić $mb MB.';
  }
}
