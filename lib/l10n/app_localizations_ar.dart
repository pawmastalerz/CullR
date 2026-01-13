// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'CullR';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get deletePermanently => 'حذف نهائي';

  @override
  String get noPhotosMarked => 'لا توجد صور محددة للحذف.';

  @override
  String get galleryAccessNeeded => 'مطلوب الوصول إلى المعرض';

  @override
  String get galleryAccessMessage =>
      'يحتاج CullR إلى الوصول إلى معرض الصور.\nيرجى منح الإذن للمتابعة.';

  @override
  String get settingsAction => 'الإعدادات';

  @override
  String get tryAgainAction => 'حاول مرة أخرى';

  @override
  String get noPhotosFound => 'لم يتم العثور على صور';

  @override
  String get noPhotosMessage => 'معرض الصور فارغ. أضف صورًا ثم عد لمراجعتها.';

  @override
  String get reloadAction => 'تحديث';

  @override
  String get tabDelete => 'حذف';

  @override
  String get tabKeep => 'احتفاظ';

  @override
  String get noPhotosKept => 'لا توجد صور للاحتفاظ بها.';

  @override
  String get confirmDeleteTitle => 'حذف الصور؟';

  @override
  String confirmDeleteMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'هل أنت متأكد من حذف $count صور؟',
      one: 'هل أنت متأكد من حذف صورة واحدة؟',
    );
    return '$_temp0';
  }

  @override
  String get cancelAction => 'إلغاء';

  @override
  String get deleteAction => 'حذف';

  @override
  String get highResOriginalTab => 'الأصل';

  @override
  String get highResDetailsTab => 'التفاصيل';

  @override
  String get metadataFilename => 'اسم الملف';

  @override
  String get metadataDimensions => 'الأبعاد';

  @override
  String get metadataFileSize => 'حجم الملف';

  @override
  String get metadataFormat => 'الصيغة';

  @override
  String get metadataCreated => 'تاريخ الإنشاء';

  @override
  String get metadataModified => 'تاريخ التعديل';

  @override
  String get metadataType => 'النوع';

  @override
  String get metadataSubtype => 'النوع الفرعي';

  @override
  String get metadataDuration => 'المدة';

  @override
  String get metadataOrientation => 'الاتجاه';

  @override
  String get metadataLocation => 'الموقع';

  @override
  String get metadataPath => 'المسار';

  @override
  String get metadataId => 'ID';

  @override
  String get reEvaluateKeepTitle => 'إعادة تحليل العناصر المحتفَظ بها؟';

  @override
  String reEvaluateKeepMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'إعادة تحليل $count عناصر محتفَظ بها؟',
      one: 'إعادة تحليل عنصر محتفَظ به واحد؟',
    );
    return '$_temp0';
  }

  @override
  String get reEvaluateKeepAction => 'إعادة التحليل';

  @override
  String get totalSizeLabel => 'الحجم الإجمالي';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get settingsSummaryTitle => 'إحصائيات التنظيف';

  @override
  String get settingsSummarySwipes => 'السحبات';

  @override
  String get settingsSummaryMarked => 'المعلَّمة';

  @override
  String get settingsSummaryKept => 'المحتفَظ بها';

  @override
  String get settingsSummaryDeleted => 'المحذوفة';

  @override
  String get settingsSummaryDeleteSize => 'المساحة المستردة';

  @override
  String get allCaughtUpTitle => 'أنت على اطلاع كامل';

  @override
  String get allCaughtUpMessage => 'لا توجد صور أخرى للمراجعة الآن.';
}
