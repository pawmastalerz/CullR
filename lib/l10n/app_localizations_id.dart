// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'CullR';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get deletePermanently => 'Hapus permanen';

  @override
  String get noPhotosMarked => 'Tidak ada foto yang ditandai untuk dihapus.';

  @override
  String get galleryAccessNeeded => 'Akses galeri diperlukan';

  @override
  String get galleryAccessMessage =>
      'CullR memerlukan akses ke galeri Anda.\nBerikan izin untuk melanjutkan.';

  @override
  String get settingsAction => 'Pengaturan';

  @override
  String get tryAgainAction => 'Coba lagi';

  @override
  String get noPhotosFound => 'Tidak ada foto ditemukan';

  @override
  String get noPhotosMessage =>
      'Galeri Anda kosong. Tambahkan foto lalu kembali untuk meninjau.';

  @override
  String get tabDelete => 'Hapus';

  @override
  String get tabKeep => 'Simpan';

  @override
  String get noPhotosKept => 'Tidak ada foto untuk disimpan.';

  @override
  String get cancelAction => 'Batal';

  @override
  String get deleteAction => 'Hapus';

  @override
  String get highResOriginalTab => 'Asli';

  @override
  String get highResDetailsTab => 'Detail';

  @override
  String get metadataFilename => 'Nama file';

  @override
  String get metadataDimensions => 'Dimensi';

  @override
  String get metadataFileSize => 'Ukuran file';

  @override
  String get metadataFormat => 'Format';

  @override
  String get metadataCreated => 'Dibuat';

  @override
  String get metadataModified => 'Diubah';

  @override
  String get metadataType => 'Jenis';

  @override
  String get metadataSubtype => 'Subjenis';

  @override
  String get metadataDuration => 'Durasi';

  @override
  String get metadataOrientation => 'Orientasi';

  @override
  String get metadataLocation => 'Lokasi';

  @override
  String get metadataPath => 'Path';

  @override
  String get metadataId => 'ID';

  @override
  String get reEvaluateKeepTitle => 'Analisis ulang item yang disimpan?';

  @override
  String reEvaluateKeepMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Analisis ulang $count item yang disimpan?',
      one: 'Analisis ulang $count item yang disimpan?',
    );
    return '$_temp0';
  }

  @override
  String get reEvaluateKeepAction => 'Analisis ulang';

  @override
  String get totalSizeLabel => 'Ukuran total';

  @override
  String get languageLabel => 'Bahasa';

  @override
  String get settingsSummaryTitle => 'Statistik pembersihan';

  @override
  String get settingsSummarySwipes => 'Geser';

  @override
  String get settingsSummaryMarked => 'Ditandai';

  @override
  String get settingsSummaryKept => 'Disimpan';

  @override
  String get settingsSummaryDeleted => 'Dihapus';

  @override
  String get settingsSummaryDeleteSize => 'Ruang yang dipulihkan';

  @override
  String get allCaughtUpTitle => 'Semua sudah ditinjau';

  @override
  String get allCaughtUpMessage =>
      'Saat ini tidak ada foto lagi untuk ditinjau.';

  @override
  String get milestoneTitle => 'Selamat!';

  @override
  String milestoneClearedMessage(int mb) {
    return 'Kamu berhasil mengosongkan $mb MB.';
  }
}
