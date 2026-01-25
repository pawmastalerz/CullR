// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'CullR';

  @override
  String get settingsTitle => '設定';

  @override
  String get deletePermanently => '完全に削除';

  @override
  String get noPhotosMarked => '削除する写真はありません。';

  @override
  String get galleryAccessNeeded => 'ギャラリーへのアクセスが必要です';

  @override
  String get galleryAccessMessage =>
      'CullRはギャラリーへのアクセスが必要です。\n続行するには権限を許可してください。';

  @override
  String get settingsAction => '設定';

  @override
  String get tryAgainAction => '再試行';

  @override
  String get noPhotosFound => '写真が見つかりません';

  @override
  String get noPhotosMessage => 'ギャラリーは空です。写真を追加してから戻って確認してください。';

  @override
  String get tabDelete => '削除';

  @override
  String get tabKeep => '保持';

  @override
  String get noPhotosKept => '保持する写真はありません。';

  @override
  String get cancelAction => 'キャンセル';

  @override
  String get deleteAction => '削除';

  @override
  String get highResOriginalTab => 'オリジナル';

  @override
  String get highResDetailsTab => '詳細';

  @override
  String get metadataFilename => 'ファイル名';

  @override
  String get metadataDimensions => 'サイズ';

  @override
  String get metadataFileSize => 'ファイルサイズ';

  @override
  String get metadataFormat => '形式';

  @override
  String get metadataCreated => '作成日時';

  @override
  String get metadataModified => '更新日時';

  @override
  String get metadataType => '種類';

  @override
  String get metadataSubtype => 'サブタイプ';

  @override
  String get metadataDuration => '再生時間';

  @override
  String get metadataOrientation => '向き';

  @override
  String get metadataLocation => '場所';

  @override
  String get metadataPath => 'パス';

  @override
  String get metadataId => 'ID';

  @override
  String get reEvaluateKeepTitle => '保持した項目を再解析しますか？';

  @override
  String reEvaluateKeepMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件の保持した項目を再解析しますか？',
      one: '$count件の保持した項目を再解析しますか？',
    );
    return '$_temp0';
  }

  @override
  String get reEvaluateKeepAction => '再解析';

  @override
  String get totalSizeLabel => '合計サイズ';

  @override
  String get unknownDate => '不明';

  @override
  String get languageLabel => '言語';

  @override
  String get settingsSummaryTitle => 'クリーンアップ統計';

  @override
  String get settingsSummarySwipes => 'スワイプ';

  @override
  String get settingsSummaryMarked => 'マーク済み';

  @override
  String get settingsSummaryKept => '保持';

  @override
  String get settingsSummaryDeleted => '削除済み';

  @override
  String get settingsSummaryDeleteSize => '回復した容量';

  @override
  String get allCaughtUpTitle => 'すべて確認済みです';

  @override
  String get allCaughtUpMessage => '今のところ確認する写真はありません。';

  @override
  String get milestoneTitle => 'おめでとう！';

  @override
  String milestoneClearedMessage(int mb) {
    return '${mb}MB を削除できました。';
  }
}
