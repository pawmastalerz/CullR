import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fi'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('sv'),
    Locale('tr'),
    Locale('uk'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CullR'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deletePermanently;

  /// No description provided for @noPhotosMarked.
  ///
  /// In en, this message translates to:
  /// **'No photos marked for deletion.'**
  String get noPhotosMarked;

  /// No description provided for @galleryAccessNeeded.
  ///
  /// In en, this message translates to:
  /// **'Gallery access required'**
  String get galleryAccessNeeded;

  /// No description provided for @galleryAccessMessage.
  ///
  /// In en, this message translates to:
  /// **'CullR needs access to your gallery.\nGrant permission to continue.'**
  String get galleryAccessMessage;

  /// No description provided for @settingsAction.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsAction;

  /// No description provided for @tryAgainAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgainAction;

  /// No description provided for @noPhotosFound.
  ///
  /// In en, this message translates to:
  /// **'No photos found'**
  String get noPhotosFound;

  /// No description provided for @noPhotosMessage.
  ///
  /// In en, this message translates to:
  /// **'Your gallery is empty. Add photos and come back to review them.'**
  String get noPhotosMessage;

  /// No description provided for @tabDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get tabDelete;

  /// No description provided for @tabKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get tabKeep;

  /// No description provided for @noPhotosKept.
  ///
  /// In en, this message translates to:
  /// **'No photos to keep.'**
  String get noPhotosKept;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @highResOriginalTab.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get highResOriginalTab;

  /// No description provided for @highResDetailsTab.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get highResDetailsTab;

  /// No description provided for @metadataFilename.
  ///
  /// In en, this message translates to:
  /// **'Filename'**
  String get metadataFilename;

  /// No description provided for @metadataDimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get metadataDimensions;

  /// No description provided for @metadataFileSize.
  ///
  /// In en, this message translates to:
  /// **'File size'**
  String get metadataFileSize;

  /// No description provided for @metadataFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get metadataFormat;

  /// No description provided for @metadataCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get metadataCreated;

  /// No description provided for @metadataModified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get metadataModified;

  /// No description provided for @metadataType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get metadataType;

  /// No description provided for @metadataSubtype.
  ///
  /// In en, this message translates to:
  /// **'Subtype'**
  String get metadataSubtype;

  /// No description provided for @metadataDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get metadataDuration;

  /// No description provided for @metadataOrientation.
  ///
  /// In en, this message translates to:
  /// **'Orientation'**
  String get metadataOrientation;

  /// No description provided for @metadataLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get metadataLocation;

  /// No description provided for @metadataPath.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get metadataPath;

  /// No description provided for @metadataId.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get metadataId;

  /// No description provided for @reEvaluateKeepTitle.
  ///
  /// In en, this message translates to:
  /// **'Re-analyze kept items?'**
  String get reEvaluateKeepTitle;

  /// No description provided for @reEvaluateKeepMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Re-analyze {count} kept item?} other{Re-analyze {count} kept items?}}'**
  String reEvaluateKeepMessage(int count);

  /// No description provided for @reEvaluateKeepAction.
  ///
  /// In en, this message translates to:
  /// **'Re-analyze'**
  String get reEvaluateKeepAction;

  /// No description provided for @totalSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Total size'**
  String get totalSizeLabel;
  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownDate;


  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @settingsSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Cleanup statistics'**
  String get settingsSummaryTitle;

  /// No description provided for @settingsSummarySwipes.
  ///
  /// In en, this message translates to:
  /// **'Swipes'**
  String get settingsSummarySwipes;

  /// No description provided for @settingsSummaryMarked.
  ///
  /// In en, this message translates to:
  /// **'Marked'**
  String get settingsSummaryMarked;

  /// No description provided for @settingsSummaryKept.
  ///
  /// In en, this message translates to:
  /// **'Kept'**
  String get settingsSummaryKept;

  /// No description provided for @settingsSummaryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get settingsSummaryDeleted;

  /// No description provided for @settingsSummaryDeleteSize.
  ///
  /// In en, this message translates to:
  /// **'Recovered space'**
  String get settingsSummaryDeleteSize;

  /// No description provided for @allCaughtUpTitle.
  ///
  /// In en, this message translates to:
  /// **'You are all caught up'**
  String get allCaughtUpTitle;

  /// No description provided for @allCaughtUpMessage.
  ///
  /// In en, this message translates to:
  /// **'No more photos to review right now.'**
  String get allCaughtUpMessage;

  /// No description provided for @milestoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Congrats!'**
  String get milestoneTitle;

  /// No description provided for @milestoneClearedMessage.
  ///
  /// In en, this message translates to:
  /// **'You managed to clear {mb} MB.'**
  String milestoneClearedMessage(int mb);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fi',
    'fr',
    'hi',
    'id',
    'it',
    'ja',
    'ko',
    'nl',
    'pl',
    'pt',
    'sv',
    'tr',
    'uk',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'sv':
      return AppLocalizationsSv();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
