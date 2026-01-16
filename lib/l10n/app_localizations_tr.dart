// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'CullR';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get deletePermanently => 'Kalıcı olarak sil';

  @override
  String get noPhotosMarked => 'Silmek için işaretlenmiş fotoğraf yok.';

  @override
  String get galleryAccessNeeded => 'Galeri erişimi gerekli';

  @override
  String get galleryAccessMessage =>
      'CullR galerinize erişim gerektirir.\nDevam etmek için izin verin.';

  @override
  String get settingsAction => 'Ayarlar';

  @override
  String get tryAgainAction => 'Tekrar dene';

  @override
  String get noPhotosFound => 'Fotoğraf bulunamadı';

  @override
  String get noPhotosMessage =>
      'Galeriniz boş. Fotoğraf ekleyin ve incelemek için geri dönün.';

  @override
  String get tabDelete => 'Sil';

  @override
  String get tabKeep => 'Sakla';

  @override
  String get noPhotosKept => 'Saklanacak fotoğraf yok.';

  @override
  String get confirmDeleteTitle => 'Fotoğraflar silinsin mi?';

  @override
  String confirmDeleteMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotoğrafı silmek istediğinizden emin misiniz?',
      one: '$count fotoğrafı silmek istediğinizden emin misiniz?',
    );
    return '$_temp0';
  }

  @override
  String get cancelAction => 'İptal';

  @override
  String get deleteAction => 'Sil';

  @override
  String get highResOriginalTab => 'Orijinal';

  @override
  String get highResDetailsTab => 'Detaylar';

  @override
  String get metadataFilename => 'Dosya adı';

  @override
  String get metadataDimensions => 'Boyutlar';

  @override
  String get metadataFileSize => 'Dosya boyutu';

  @override
  String get metadataFormat => 'Format';

  @override
  String get metadataCreated => 'Oluşturulma';

  @override
  String get metadataModified => 'Değiştirilme';

  @override
  String get metadataType => 'Tür';

  @override
  String get metadataSubtype => 'Alt tür';

  @override
  String get metadataDuration => 'Süre';

  @override
  String get metadataOrientation => 'Yönlendirme';

  @override
  String get metadataLocation => 'Konum';

  @override
  String get metadataPath => 'Yol';

  @override
  String get metadataId => 'ID';

  @override
  String get reEvaluateKeepTitle =>
      'Saklanan öğeler yeniden analiz edilsin mi?';

  @override
  String reEvaluateKeepMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saklanan öğeler yeniden analiz edilsin mi?',
      one: '$count saklanan öğe yeniden analiz edilsin mi?',
    );
    return '$_temp0';
  }

  @override
  String get reEvaluateKeepAction => 'Yeniden analiz et';

  @override
  String get totalSizeLabel => 'Toplam boyut';

  @override
  String get languageLabel => 'Dil';

  @override
  String get settingsSummaryTitle => 'Temizleme istatistikleri';

  @override
  String get settingsSummarySwipes => 'Kaydırmalar';

  @override
  String get settingsSummaryMarked => 'İşaretlenenler';

  @override
  String get settingsSummaryKept => 'Saklananlar';

  @override
  String get settingsSummaryDeleted => 'Silinenler';

  @override
  String get settingsSummaryDeleteSize => 'Kazanılan alan';

  @override
  String get allCaughtUpTitle => 'Her şeyi gördün';

  @override
  String get allCaughtUpMessage => 'Şu anda incelenecek başka fotoğraf yok.';

  @override
  String get milestoneTitle => 'Tebrikler!';

  @override
  String milestoneClearedMessage(int mb) {
    return '$mb MB temizledin.';
  }
}
