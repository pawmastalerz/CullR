class DeleteAssetsResult {
  const DeleteAssetsResult({
    required this.deletedIds,
    required this.deletedBytes,
  });

  const DeleteAssetsResult.empty() : deletedIds = const {}, deletedBytes = 0;

  final Set<String> deletedIds;
  final int deletedBytes;

  bool get hasDeletions => deletedIds.isNotEmpty;
}
