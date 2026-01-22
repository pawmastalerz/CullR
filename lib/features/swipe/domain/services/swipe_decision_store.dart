import '../../../../core/storage/key_value_store.dart';
import '../../../../core/storage/shared_preferences_store.dart';
import '../entities/media_asset.dart';
import '../entities/swipe_config.dart';

typedef MediaAssetLoader = Future<MediaAsset?> Function(String id);

class SwipeDecisionStore {
  SwipeDecisionStore({
    required SwipeConfig config,
    KeyValueStore? store,
    MediaAssetLoader? assetLoader,
  }) : _config = config,
       _store = store ?? SharedPreferencesStore(),
       _assetLoader = assetLoader;

  final SwipeConfig _config;
  final KeyValueStore _store;
  final MediaAssetLoader? _assetLoader;
  final _DecisionBucket _deleteBucket = _DecisionBucket();
  final _DecisionBucket _keepBucket = _DecisionBucket();
  final List<MediaAsset> _recentDecisions = [];
  Future<void> _persistQueue = Future<void>.value();
  static const String _keepStorageKey = 'keep_ids';
  static const String _deleteStorageKey = 'delete_ids';

  List<MediaAsset> get deleteCandidates => _deleteBucket.items;
  List<MediaAsset> get keepCandidates => _keepBucket.items;

  int get undoCredits => _recentDecisions.length;
  int get keepCount => _keepBucket.count;
  int get deleteCount => _deleteBucket.count;
  int get totalDecisionCount => keepCount + deleteCount;

  bool get hasDeleteCandidates => _deleteBucket.hasItems;
  bool get hasKeepCandidates => _keepBucket.hasItems;
  bool get hasAnyCandidates => hasDeleteCandidates || hasKeepCandidates;
  bool isKept(String id) => _keepBucket.containsId(id);
  bool isMarkedForDelete(String id) => _deleteBucket.containsId(id);

  void reset() {
    _deleteBucket.clear();
    _keepBucket.clear();
    _recentDecisions.clear();
  }

  void clearUndo() {
    _recentDecisions.clear();
  }

  Future<void> loadDecisions() async {
    if (_assetLoader == null) {
      return;
    }
    final List<String> keepIds =
        await _store.getStringList(_keepStorageKey) ?? [];
    final List<String> deleteIds =
        await _store.getStringList(_deleteStorageKey) ?? [];
    final List<MediaAsset> keepItems = await _loadAssetsForIds(keepIds);
    final Set<String> keepItemIds = keepItems.map((item) => item.id).toSet();
    final List<MediaAsset> deleteItems = (await _loadAssetsForIds(
      deleteIds,
    )).where((item) => !keepItemIds.contains(item.id)).toList();

    _keepBucket.replaceItems(keepItems);
    _deleteBucket.replaceItems(deleteItems);

    final bool keepChanged = !_idsMatch(keepItemIds, keepIds);
    final bool deleteChanged = !_idsMatch(
      deleteItems.map((item) => item.id).toSet(),
      deleteIds,
    );
    if (keepChanged) {
      await _persistKeeps();
    }
    if (deleteChanged) {
      await _persistDeletes();
    }
  }

  void registerDecision(MediaAsset asset) {
    _recentDecisions.add(asset);
    if (_recentDecisions.length > _config.swipeUndoLimit) {
      _recentDecisions.removeAt(0);
    }
  }

  bool consumeUndo() {
    if (_recentDecisions.isEmpty) {
      return false;
    }
    _recentDecisions.removeLast();
    return true;
  }

  Future<void> markForDelete(MediaAsset asset) {
    final bool removedKeep = _keepBucket.removeById(asset.id);
    final bool addedDelete = _deleteBucket.add(asset);
    return _persistChanges(
      keepChanged: removedKeep,
      deleteChanged: addedDelete,
    );
  }

  Future<void> unmarkDeleteById(String id) {
    final bool removed = _deleteBucket.removeById(id);
    return removed ? _persistDeletes() : Future<void>.value();
  }

  Future<void> removeCandidate(MediaAsset asset) {
    final bool removed = _deleteBucket.removeById(asset.id);
    return removed ? _persistDeletes() : Future<void>.value();
  }

  Future<void> markForKeep(MediaAsset asset) {
    final bool removedDelete = _deleteBucket.removeById(asset.id);
    final bool added = _keepBucket.add(asset);
    return _persistChanges(keepChanged: added, deleteChanged: removedDelete);
  }

  Future<void> unmarkKeepById(String id) {
    final bool removed = _keepBucket.removeById(id);
    return removed ? _persistKeeps() : Future<void>.value();
  }

  Future<void> removeKeepCandidate(MediaAsset asset) {
    return unmarkKeepById(asset.id);
  }

  Future<void> clearKeeps() {
    _keepBucket.clear();
    return _persistKeeps();
  }

  Future<void> _persistChanges({
    required bool keepChanged,
    required bool deleteChanged,
  }) {
    if (!keepChanged && !deleteChanged) {
      return Future<void>.value();
    }
    if (keepChanged && deleteChanged) {
      _persistQueue = _persistQueue.then((_) async {
        await _store.setStringList(_keepStorageKey, _keepBucket.ids.toList());
        await _store.setStringList(
          _deleteStorageKey,
          _deleteBucket.ids.toList(),
        );
      });
      return _persistQueue;
    }
    if (keepChanged) {
      return _persistKeeps();
    }
    return _persistDeletes();
  }

  Future<void> _persistKeeps() {
    _persistQueue = _persistQueue.then((_) async {
      await _store.setStringList(_keepStorageKey, _keepBucket.ids.toList());
    });
    return _persistQueue;
  }

  Future<void> _persistDeletes() {
    _persistQueue = _persistQueue.then((_) async {
      await _store.setStringList(_deleteStorageKey, _deleteBucket.ids.toList());
    });
    return _persistQueue;
  }

  Future<List<MediaAsset>> _loadAssetsForIds(Iterable<String> ids) async {
    final MediaAssetLoader? loader = _assetLoader;
    if (loader == null) {
      return <MediaAsset>[];
    }
    final List<Future<MediaAsset?>> futures = ids.map(loader).toList();
    final List<MediaAsset?> results = await Future.wait(futures);
    return results.whereType<MediaAsset>().toList();
  }

  bool _idsMatch(Set<String> ids, List<String> stored) {
    if (ids.length != stored.length) {
      return false;
    }
    for (final String id in stored) {
      if (!ids.contains(id)) {
        return false;
      }
    }
    return true;
  }
}

class _DecisionBucket {
  final List<MediaAsset> _items = [];
  final Set<String> _ids = {};

  List<MediaAsset> get items => List.unmodifiable(_items);
  Iterable<String> get ids => _ids;
  int get count => _ids.length;
  bool get hasItems => _items.isNotEmpty;
  bool containsId(String id) => _ids.contains(id);

  bool add(MediaAsset asset) {
    if (!_ids.add(asset.id)) {
      return false;
    }
    _items.add(asset);
    return true;
  }

  bool removeById(String id) {
    if (!_ids.remove(id)) {
      return false;
    }
    _items.removeWhere((asset) => asset.id == id);
    return true;
  }

  void replaceItems(Iterable<MediaAsset> items) {
    _items
      ..clear()
      ..addAll(items);
    _ids
      ..clear()
      ..addAll(items.map((asset) => asset.id));
  }

  void clear() {
    _items.clear();
    _ids.clear();
  }
}
