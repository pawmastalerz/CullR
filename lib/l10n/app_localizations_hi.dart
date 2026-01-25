// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'CullR';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get deletePermanently => 'स्थायी रूप से हटाएँ';

  @override
  String get noPhotosMarked => 'हटाने के लिए कोई फ़ोटो चिह्नित नहीं है।';

  @override
  String get galleryAccessNeeded => 'गैलरी की अनुमति आवश्यक है';

  @override
  String get galleryAccessMessage =>
      'CullR को आपकी गैलरी तक पहुँच की आवश्यकता है।\nजारी रखने के लिए अनुमति दें।';

  @override
  String get settingsAction => 'सेटिंग्स';

  @override
  String get tryAgainAction => 'फिर से प्रयास करें';

  @override
  String get noPhotosFound => 'कोई फ़ोटो नहीं मिली';

  @override
  String get noPhotosMessage =>
      'आपकी गैलरी खाली है। फ़ोटो जोड़ें और फिर से देखने के लिए लौटें।';

  @override
  String get tabDelete => 'हटाएँ';

  @override
  String get tabKeep => 'रखें';

  @override
  String get noPhotosKept => 'रखने के लिए कोई फ़ोटो नहीं है।';

  @override
  String get cancelAction => 'रद्द करें';

  @override
  String get deleteAction => 'हटाएँ';

  @override
  String get highResOriginalTab => 'मूल';

  @override
  String get highResDetailsTab => 'विवरण';

  @override
  String get metadataFilename => 'फ़ाइल नाम';

  @override
  String get metadataDimensions => 'आकार';

  @override
  String get metadataFileSize => 'फ़ाइल आकार';

  @override
  String get metadataFormat => 'फ़ॉर्मेट';

  @override
  String get metadataCreated => 'निर्मित';

  @override
  String get metadataModified => 'संशोधित';

  @override
  String get metadataType => 'प्रकार';

  @override
  String get metadataSubtype => 'उपप्रकार';

  @override
  String get metadataDuration => 'अवधि';

  @override
  String get metadataOrientation => 'ओरिएंटेशन';

  @override
  String get metadataLocation => 'स्थान';

  @override
  String get metadataPath => 'पथ';

  @override
  String get metadataId => 'ID';

  @override
  String get reEvaluateKeepTitle => 'सहेजे गए आइटम फिर से विश्लेषित करें?';

  @override
  String reEvaluateKeepMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सहेजे गए आइटम फिर से विश्लेषित करें?',
      one: '$count सहेजा गया आइटम फिर से विश्लेषित करें?',
    );
    return '$_temp0';
  }

  @override
  String get reEvaluateKeepAction => 'फिर से विश्लेषित करें';

  @override
  String get totalSizeLabel => 'कुल आकार';
  String get unknownDate => 'अज्ञात';

  @override
  String get languageLabel => 'भाषा';

  @override
  String get settingsSummaryTitle => 'साफ़-सफ़ाई आँकड़े';

  @override
  String get settingsSummarySwipes => 'स्वाइप';

  @override
  String get settingsSummaryMarked => 'चिह्नित';

  @override
  String get settingsSummaryKept => 'सहेजे गए';

  @override
  String get settingsSummaryDeleted => 'हटाए गए';

  @override
  String get settingsSummaryDeleteSize => 'पुनः प्राप्त स्थान';

  @override
  String get allCaughtUpTitle => 'सब देख लिया';

  @override
  String get allCaughtUpMessage => 'अभी समीक्षा करने के लिए और फोटो नहीं हैं।';

  @override
  String get milestoneTitle => 'बधाई!';

  @override
  String milestoneClearedMessage(int mb) {
    return 'आपने $mb MB साफ कर दिए।';
  }
}
