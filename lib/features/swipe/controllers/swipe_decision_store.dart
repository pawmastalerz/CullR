import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';

class SwipeDecisionStore {
  final _DecisionBucket _deleteBucket = _DecisionBucket();
  final _DecisionBucket _keepBucket = _DecisionBucket();
  final List<AssetEntity> _recentDecisions = [];
  Future<void> _persistQueue = Future<void>.value();
  static const String _keepStorageKey = 'keep_ids';

  List<AssetEntity> get deleteCandidates => _deleteBucket.items;
  List<AssetEntity> get keepCandidates => _keepBucket.items;

  int get undoCredits => _recentDecisions.length;
  int get keepCount => _keepBucket.count;

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

  Future<void> loadKeeps() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> ids = prefs.getStringList(_keepStorageKey) ?? [];
    _keepBucket.replaceIds(ids);
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
    _deleteBucket.add(entity);
    return removedKeep ? _persistKeeps() : Future<void>.value();
  }

  void unmarkDeleteById(String id) {
    _deleteBucket.removeById(id);
  }

  void removeCandidate(AssetEntity entity) {
    _deleteBucket.removeById(entity.id);
  }

  Future<void> markForKeep(AssetEntity entity) {
    _deleteBucket.removeById(entity.id);
    final bool added = _keepBucket.add(entity);
    return added ? _persistKeeps() : Future<void>.value();
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

  Future<void> _persistKeeps() {
    _persistQueue = _persistQueue.then((_) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keepStorageKey, _keepBucket.ids.toList());
    });
    return _persistQueue;
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
