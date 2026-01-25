// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'CullR';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get deletePermanently => 'Eliminar permanentemente';

  @override
  String get noPhotosMarked => 'No hay fotos marcadas para eliminar.';

  @override
  String get galleryAccessNeeded => 'Se requiere acceso a la galería';

  @override
  String get galleryAccessMessage =>
      'CullR necesita acceso a tu galería.\nConcede el permiso para continuar.';

  @override
  String get settingsAction => 'Ajustes';

  @override
  String get tryAgainAction => 'Intentar de nuevo';

  @override
  String get noPhotosFound => 'No se encontraron fotos';

  @override
  String get noPhotosMessage =>
      'Tu galería está vacía. Añade fotos y vuelve para revisarlas.';

  @override
  String get tabDelete => 'Eliminar';

  @override
  String get tabKeep => 'Conservar';

  @override
  String get noPhotosKept => 'No hay fotos para conservar.';

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get highResOriginalTab => 'Original';

  @override
  String get highResDetailsTab => 'Detalles';

  @override
  String get metadataFilename => 'Nombre del archivo';

  @override
  String get metadataDimensions => 'Dimensiones';

  @override
  String get metadataFileSize => 'Tamaño del archivo';

  @override
  String get metadataFormat => 'Formato';

  @override
  String get metadataCreated => 'Creado';

  @override
  String get metadataModified => 'Modificado';

  @override
  String get metadataType => 'Tipo';

  @override
  String get metadataSubtype => 'Subtipo';

  @override
  String get metadataDuration => 'Duración';

  @override
  String get metadataOrientation => 'Orientación';

  @override
  String get metadataLocation => 'Ubicación';

  @override
  String get metadataPath => 'Ruta';

  @override
  String get metadataId => 'ID';

  @override
  String get reEvaluateKeepTitle =>
      '¿Analizar de nuevo los elementos conservados?';

  @override
  String reEvaluateKeepMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Analizar de nuevo $count elementos conservados?',
      one: '¿Analizar de nuevo $count elemento conservado?',
    );
    return '$_temp0';
  }

  @override
  String get reEvaluateKeepAction => 'Analizar de nuevo';

  @override
  String get totalSizeLabel => 'Tamaño total';
  String get unknownDate => 'Desconocido';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get settingsSummaryTitle => 'Estadísticas de limpieza';

  @override
  String get settingsSummarySwipes => 'Deslizamientos';

  @override
  String get settingsSummaryMarked => 'Marcados';

  @override
  String get settingsSummaryKept => 'Conservados';

  @override
  String get settingsSummaryDeleted => 'Eliminados';

  @override
  String get settingsSummaryDeleteSize => 'Espacio recuperado';

  @override
  String get allCaughtUpTitle => 'Estás al día';

  @override
  String get allCaughtUpMessage => 'No hay más fotos para revisar ahora.';

  @override
  String get milestoneTitle => '¡Felicidades!';

  @override
  String milestoneClearedMessage(int mb) {
    return 'Lograste liberar $mb MB.';
  }
}
