// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'CullR';

  @override
  String get settingsTitle => 'Definições';

  @override
  String get deletePermanently => 'Eliminar permanentemente';

  @override
  String get noPhotosMarked => 'Nenhuma foto marcada para eliminação.';

  @override
  String get galleryAccessNeeded => 'Acesso à galeria necessário';

  @override
  String get galleryAccessMessage =>
      'O CullR precisa de acesso à galeria.\nConceda a permissão para continuar.';

  @override
  String get settingsAction => 'Definições';

  @override
  String get tryAgainAction => 'Tentar novamente';

  @override
  String get noPhotosFound => 'Nenhuma foto encontrada';

  @override
  String get noPhotosMessage =>
      'A sua galeria está vazia. Adicione fotos e volte para as analisar.';

  @override
  String get tabDelete => 'Eliminar';

  @override
  String get tabKeep => 'Manter';

  @override
  String get noPhotosKept => 'Nenhuma foto para manter.';

  @override
  String get confirmDeleteTitle => 'Eliminar fotos?';

  @override
  String confirmDeleteMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tem a certeza de que deseja eliminar $count fotos?',
      one: 'Tem a certeza de que deseja eliminar $count foto?',
    );
    return '$_temp0';
  }

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get highResOriginalTab => 'Original';

  @override
  String get highResDetailsTab => 'Detalhes';

  @override
  String get metadataFilename => 'Nome do ficheiro';

  @override
  String get metadataDimensions => 'Dimensões';

  @override
  String get metadataFileSize => 'Tamanho do ficheiro';

  @override
  String get metadataFormat => 'Formato';

  @override
  String get metadataCreated => 'Criado';

  @override
  String get metadataModified => 'Modificado';

  @override
  String get metadataType => 'Tipo';

  @override
  String get metadataSubtype => 'Subtipo';

  @override
  String get metadataDuration => 'Duração';

  @override
  String get metadataOrientation => 'Orientação';

  @override
  String get metadataLocation => 'Localização';

  @override
  String get metadataPath => 'Caminho';

  @override
  String get metadataId => 'ID';

  @override
  String get reEvaluateKeepTitle => 'Analisar novamente os itens mantidos?';

  @override
  String reEvaluateKeepMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Analisar novamente $count itens mantidos?',
      one: 'Analisar novamente $count item mantido?',
    );
    return '$_temp0';
  }

  @override
  String get reEvaluateKeepAction => 'Analisar novamente';

  @override
  String get totalSizeLabel => 'Tamanho total';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get settingsSummaryTitle => 'Estatísticas de limpeza';

  @override
  String get settingsSummarySwipes => 'Deslizamentos';

  @override
  String get settingsSummaryMarked => 'Marcados';

  @override
  String get settingsSummaryKept => 'Mantidos';

  @override
  String get settingsSummaryDeleted => 'Eliminados';

  @override
  String get settingsSummaryDeleteSize => 'Espaço recuperado';

  @override
  String get allCaughtUpTitle => 'Você está em dia';

  @override
  String get allCaughtUpMessage => 'Não há mais fotos para revisar agora.';

  @override
  String get milestoneTitle => 'Parabéns!';

  @override
  String milestoneClearedMessage(int mb) {
    return 'Você liberou $mb MB.';
  }
}
