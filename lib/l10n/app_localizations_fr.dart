// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'CullR';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get deletePermanently => 'Supprimer définitivement';

  @override
  String get noPhotosMarked => 'Aucune photo marquée pour la suppression.';

  @override
  String get galleryAccessNeeded => 'Accès à la galerie requis';

  @override
  String get galleryAccessMessage =>
      'CullR a besoin d’accéder à votre galerie.\nAccordez l’autorisation pour continuer.';

  @override
  String get settingsAction => 'Paramètres';

  @override
  String get tryAgainAction => 'Réessayer';

  @override
  String get noPhotosFound => 'Aucune photo trouvée';

  @override
  String get noPhotosMessage =>
      'Votre galerie est vide. Ajoutez des photos et revenez pour les examiner.';

  @override
  String get tabDelete => 'Supprimer';

  @override
  String get tabKeep => 'Conserver';

  @override
  String get noPhotosKept => 'Aucune photo à conserver.';

  @override
  String get cancelAction => 'Annuler';

  @override
  String get deleteAction => 'Supprimer';

  @override
  String get highResOriginalTab => 'Original';

  @override
  String get highResDetailsTab => 'Détails';

  @override
  String get metadataFilename => 'Nom du fichier';

  @override
  String get metadataDimensions => 'Dimensions';

  @override
  String get metadataFileSize => 'Taille du fichier';

  @override
  String get metadataFormat => 'Format';

  @override
  String get metadataCreated => 'Créé';

  @override
  String get metadataModified => 'Modifié';

  @override
  String get metadataType => 'Type';

  @override
  String get metadataSubtype => 'Sous-type';

  @override
  String get metadataDuration => 'Durée';

  @override
  String get metadataOrientation => 'Orientation';

  @override
  String get metadataLocation => 'Emplacement';

  @override
  String get metadataPath => 'Chemin';

  @override
  String get metadataId => 'ID';

  @override
  String get reEvaluateKeepTitle =>
      'Analyser à nouveau les éléments conservés ?';

  @override
  String reEvaluateKeepMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Analyser à nouveau $count éléments conservés ?',
      one: 'Analyser à nouveau $count élément conservé ?',
    );
    return '$_temp0';
  }

  @override
  String get reEvaluateKeepAction => 'Analyser à nouveau';

  @override
  String get totalSizeLabel => 'Taille totale';

  @override
  String get languageLabel => 'Langue';

  @override
  String get settingsSummaryTitle => 'Statistiques de nettoyage';

  @override
  String get settingsSummarySwipes => 'Glissements';

  @override
  String get settingsSummaryMarked => 'Marqués';

  @override
  String get settingsSummaryKept => 'Conservés';

  @override
  String get settingsSummaryDeleted => 'Supprimés';

  @override
  String get settingsSummaryDeleteSize => 'Espace récupéré';

  @override
  String get allCaughtUpTitle => 'Vous êtes à jour';

  @override
  String get allCaughtUpMessage => 'Plus de photos à examiner pour le moment.';

  @override
  String get milestoneTitle => 'Bravo !';

  @override
  String milestoneClearedMessage(int mb) {
    return 'Tu as libéré $mb Mo.';
  }
}
