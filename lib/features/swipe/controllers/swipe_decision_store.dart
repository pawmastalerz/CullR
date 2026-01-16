import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';

typedef AssetEntityLoader = Future<AssetEntity?> Function(String id);

class SwipeDecisionStore {
  SwipeDecisionStore({AssetEntityLoader? entityLoader})
    : _entityLoader = entityLoader ?? AssetEntity.fromId;

  final AssetEntityLoader _entityLoader;
  final _DecisionBucket _deleteBucket = _DecisionBucket();
  final _DecisionBucket _keepBucket = _DecisionBucket();
  final List<AssetEntity> _recentDecisions = [];
  Future<void> _persistQueue = Future<void>.value();
  static const String _keepStorageKey = 'keep_ids';
  static const String _deleteStorageKey = 'delete_ids';

  List<AssetEntity> get deleteCandidates => _deleteBucket.items;
  List<AssetEntity> get keepCandidates => _keepBucket.items;

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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> keepIds = prefs.getStringList(_keepStorageKey) ?? [];
    final List<String> deleteIds = prefs.getStringList(_deleteStorageKey) ?? [];
    final List<AssetEntity> keepItems = await _loadEntitiesForIds(keepIds);
    final Set<String> keepItemIds = keepItems.map((item) => item.id).toSet();
    final List<AssetEntity> deleteItems = (await _loadEntitiesForIds(deleteIds))
        .where((item) => !keepItemIds.contains(item.id))
        .toList();

    _keepBucket.replaceItems(keepItems);
    _deleteBucket.replaceItems(deleteItems);

    final bool keepChanged = !_idsMatch(keepItemIds, keepIds);
    final bool deleteChanged =
        !_idsMatch(deleteItems.map((item) => item.id).toSet(), deleteIds);
    if (keepChanged) {
      await _persistKeeps();
    }
    if (deleteChanged) {
      await _persistDeletes();
    }
  }

  void syncKeeps(List<AssetEntity> assets) {
    _keepBucket.syncItems(assets);
  }

  void registerDecision(AssetEntity entity) {
    _recentDecisions.add(entity);
    if (_recentDecisions.length > AppConfig.swipeUndoLimit) {
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

  Future<void> markForDelete(AssetEntity entity) {
    final bool removedKeep = _keepBucket.removeById(entity.id);
    final bool addedDelete = _deleteBucket.add(entity);
    return _persistChanges(
      keepChanged: removedKeep,
      deleteChanged: addedDelete,
    );
  }

  Future<void> unmarkDeleteById(String id) {
    final bool removed = _deleteBucket.removeById(id);
    return removed ? _persistDeletes() : Future<void>.value();
  }

  Future<void> removeCandidate(AssetEntity entity) {
    final bool removed = _deleteBucket.removeById(entity.id);
    return removed ? _persistDeletes() : Future<void>.value();
  }

  Future<void> markForKeep(AssetEntity entity) {
    final bool removedDelete = _deleteBucket.removeById(entity.id);
    final bool added = _keepBucket.add(entity);
    return _persistChanges(keepChanged: added, deleteChanged: removedDelete);
  }

  Future<void> unmarkKeepById(String id) {
    final bool removed = _keepBucket.removeById(id);
    return removed ? _persistKeeps() : Future<void>.value();
  }

  Future<void> removeKeepCandidate(AssetEntity entity) {
    return unmarkKeepById(entity.id);
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
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_keepStorageKey, _keepBucket.ids.toList());
        await prefs.setStringList(
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
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keepStorageKey, _keepBucket.ids.toList());
    });
    return _persistQueue;
  }

  Future<void> _persistDeletes() {
    _persistQueue = _persistQueue.then((_) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_deleteStorageKey, _deleteBucket.ids.toList());
    });
    return _persistQueue;
  }

  Future<List<AssetEntity>> _loadEntitiesForIds(Iterable<String> ids) async {
    final List<Future<AssetEntity?>> futures = ids
        .map(_entityLoader)
        .toList();
    final List<AssetEntity?> results = await Future.wait(futures);
    return results.whereType<AssetEntity>().toList();
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
  final List<AssetEntity> _items = [];
  final Set<String> _ids = {};

  List<AssetEntity> get items => List.unmodifiable(_items);
  Iterable<String> get ids => _ids;
  int get count => _ids.length;
  bool get hasItems => _items.isNotEmpty;
  bool containsId(String id) => _ids.contains(id);

  bool add(AssetEntity entity) {
    if (!_ids.add(entity.id)) {
      return false;
    }
    _items.add(entity);
    return true;
  }

  bool removeById(String id) {
    if (!_ids.remove(id)) {
      return false;
    }
    _items.removeWhere((entity) => entity.id == id);
    return true;
  }

  void replaceIds(Iterable<String> ids) {
    _ids
      ..clear()
      ..addAll(ids);
    _items.removeWhere((entity) => !_ids.contains(entity.id));
  }

  void replaceItems(Iterable<AssetEntity> items) {
    _items
      ..clear()
      ..addAll(items);
    _ids
      ..clear()
      ..addAll(items.map((entity) => entity.id));
  }

  void syncItems(Iterable<AssetEntity> assets) {
    _items
      ..clear()
      ..addAll(assets.where((entity) => _ids.contains(entity.id)));
  }

  void clear() {
    _items.clear();
    _ids.clear();
  }
}
