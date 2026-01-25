// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'CullR';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get deletePermanently => 'Видалити назавжди';

  @override
  String get noPhotosMarked => 'Немає фотографій для видалення.';

  @override
  String get galleryAccessNeeded => 'Потрібен доступ до галереї';

  @override
  String get galleryAccessMessage =>
      'CullR потребує доступу до вашої галереї.\nНадайте дозвіл, щоб продовжити.';

  @override
  String get settingsAction => 'Налаштування';

  @override
  String get tryAgainAction => 'Спробувати знову';

  @override
  String get noPhotosFound => 'Фотографій не знайдено';

  @override
  String get noPhotosMessage =>
      'Ваша галерея порожня. Додайте фотографії та поверніться, щоб переглянути їх.';

  @override
  String get tabDelete => 'Видалити';

  @override
  String get tabKeep => 'Зберегти';

  @override
  String get noPhotosKept => 'Немає фотографій для збереження.';

  @override
  String get cancelAction => 'Скасувати';

  @override
  String get deleteAction => 'Видалити';

  @override
  String get highResOriginalTab => 'Оригінал';

  @override
  String get highResDetailsTab => 'Деталі';

  @override
  String get metadataFilename => 'Назва файлу';

  @override
  String get metadataDimensions => 'Розміри';

  @override
  String get metadataFileSize => 'Розмір файлу';

  @override
  String get metadataFormat => 'Формат';

  @override
  String get metadataCreated => 'Створено';

  @override
  String get metadataModified => 'Змінено';

  @override
  String get metadataType => 'Тип';

  @override
  String get metadataSubtype => 'Підтип';

  @override
  String get metadataDuration => 'Тривалість';

  @override
  String get metadataOrientation => 'Орієнтація';

  @override
  String get metadataLocation => 'Місцезнаходження';

  @override
  String get metadataPath => 'Шлях';

  @override
  String get metadataId => 'ID';

  @override
  String get reEvaluateKeepTitle =>
      'Повторно проаналізувати збережені елементи?';

  @override
  String reEvaluateKeepMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Повторно проаналізувати $count збережених елементів?',
      many: 'Повторно проаналізувати $count збережених елементів?',
      few: 'Повторно проаналізувати $count збережені елементи?',
      one: 'Повторно проаналізувати $count збережений елемент?',
    );
    return '$_temp0';
  }

  @override
  String get reEvaluateKeepAction => 'Проаналізувати повторно';

  @override
  String get totalSizeLabel => 'Загальний розмір';
  String get unknownDate => 'Невідомо';

  @override
  String get languageLabel => 'Мова';

  @override
  String get settingsSummaryTitle => 'Статистика очищення';

  @override
  String get settingsSummarySwipes => 'Свайпи';

  @override
  String get settingsSummaryMarked => 'Позначені';

  @override
  String get settingsSummaryKept => 'Збережені';

  @override
  String get settingsSummaryDeleted => 'Видалені';

  @override
  String get settingsSummaryDeleteSize => 'Звільнене місце';

  @override
  String get allCaughtUpTitle => 'Ви все переглянули';

  @override
  String get allCaughtUpMessage => 'Наразі більше немає фото для перегляду.';

  @override
  String get milestoneTitle => 'Вітаємо!';

  @override
  String milestoneClearedMessage(int mb) {
    return 'Вам вдалося звільнити $mb МБ.';
  }
}
