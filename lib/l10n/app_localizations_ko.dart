// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'CullR';

  @override
  String get settingsTitle => '설정';

  @override
  String get deletePermanently => '영구 삭제';

  @override
  String get noPhotosMarked => '삭제할 사진이 없습니다.';

  @override
  String get galleryAccessNeeded => '갤러리 접근 권한 필요';

  @override
  String get galleryAccessMessage =>
      'CullR은 갤러리에 대한 접근 권한이 필요합니다.\n계속하려면 권한을 허용하세요.';

  @override
  String get settingsAction => '설정';

  @override
  String get tryAgainAction => '다시 시도';

  @override
  String get noPhotosFound => '사진을 찾을 수 없습니다';

  @override
  String get noPhotosMessage => '갤러리가 비어 있습니다. 사진을 추가한 후 다시 확인하세요.';

  @override
  String get tabDelete => '삭제';

  @override
  String get tabKeep => '보관';

  @override
  String get noPhotosKept => '보관할 사진이 없습니다.';

  @override
  String get confirmDeleteTitle => '사진을 삭제할까요?';

  @override
  String confirmDeleteMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count장의 사진을 삭제하시겠습니까?',
      one: '$count장의 사진을 삭제하시겠습니까?',
    );
    return '$_temp0';
  }

  @override
  String get cancelAction => '취소';

  @override
  String get deleteAction => '삭제';

  @override
  String get highResOriginalTab => '원본';

  @override
  String get highResDetailsTab => '세부 정보';

  @override
  String get metadataFilename => '파일 이름';

  @override
  String get metadataDimensions => '크기';

  @override
  String get metadataFileSize => '파일 크기';

  @override
  String get metadataFormat => '형식';

  @override
  String get metadataCreated => '생성됨';

  @override
  String get metadataModified => '수정됨';

  @override
  String get metadataType => '유형';

  @override
  String get metadataSubtype => '하위 유형';

  @override
  String get metadataDuration => '재생 시간';

  @override
  String get metadataOrientation => '방향';

  @override
  String get metadataLocation => '위치';

  @override
  String get metadataPath => '경로';

  @override
  String get metadataId => 'ID';

  @override
  String get reEvaluateKeepTitle => '보관된 항목을 다시 분석할까요?';

  @override
  String reEvaluateKeepMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개의 보관된 항목을 다시 분석할까요?',
      one: '$count개의 보관된 항목을 다시 분석할까요?',
    );
    return '$_temp0';
  }

  @override
  String get reEvaluateKeepAction => '다시 분석';

  @override
  String get totalSizeLabel => '총 크기';

  @override
  String get languageLabel => '언어';

  @override
  String get settingsSummaryTitle => '정리 통계';

  @override
  String get settingsSummarySwipes => '스와이프';

  @override
  String get settingsSummaryMarked => '표시됨';

  @override
  String get settingsSummaryKept => '보관됨';

  @override
  String get settingsSummaryDeleted => '삭제됨';

  @override
  String get settingsSummaryDeleteSize => '확보된 공간';

  @override
  String get allCaughtUpTitle => '모두 확인했습니다';

  @override
  String get allCaughtUpMessage => '지금은 검토할 사진이 없습니다.';

  @override
  String get milestoneTitle => '축하해요!';

  @override
  String milestoneClearedMessage(int mb) {
    return '${mb}MB를 정리했어요.';
  }
}
