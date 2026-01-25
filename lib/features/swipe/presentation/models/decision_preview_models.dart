import '../../domain/entities/media_asset.dart';

class DecisionDateGroup {
  const DecisionDateGroup({
    required this.label,
    required this.items,
  });

  final String label;
  final List<MediaAsset> items;
}

class DecisionDatedAsset {
  const DecisionDatedAsset({
    required this.asset,
    required this.date,
    required this.key,
  });

  final MediaAsset asset;
  final DateTime date;
  final DateTime key;
}
