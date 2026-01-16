import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';

class SwipeDecisionStore {
  final List<AssetEntity> _deleteCandidates = [];
  final Set<String> _deleteIds = {};
  final List<AssetEntity> _keepCandidates = [];
  final Set<String> _keepIds = {};
  final List<AssetEntity> _recentDecisions = [];
  Future<void> _persistQueue = Future<void>.value();
  static const String _keepStorageKey = 'keep_ids';

  List<AssetEntity> get deleteCandidates =>
      List.unmodifiable(_deleteCandidates);
  List<AssetEntity> get keepCandidates => List.unmodifiable(_keepCandidates);

  int get undoCredits => _recentDecisions.length;
  int get keepCount => _keepIds.length;

  bool get hasDeleteCandidates => _deleteCandidates.isNotEmpty;
  bool get hasKeepCandidates => _keepCandidates.isNotEmpty;
  bool get hasAnyCandidates => hasDeleteCandidates || hasKeepCandidates;
  bool isKept(String id) => _keepIds.contains(id);
  bool isMarkedForDelete(String id) => _deleteIds.contains(id);

  void reset() {
    _deleteCandidates.clear();
    _deleteIds.clear();
    _keepCandidates.clear();
    _keepIds.clear();
    _recentDecisions.clear();
  }

  void clearUndo() {
    _recentDecisions.clear();
  }

  Future<void> loadKeeps() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> ids = prefs.getStringList(_keepStorageKey) ?? [];
    _keepIds
      ..clear()
      ..addAll(ids);
  }

  void syncKeeps(List<AssetEntity> assets) {
    _keepCandidates
      ..clear()
      ..addAll(assets.where((entity) => _keepIds.contains(entity.id)));
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
    _removeFromKeeps(entity.id);
    final Future<void> persist = _persistKeeps();
    if (_deleteIds.add(entity.id)) {
      _deleteCandidates.add(entity);
    }
    return persist;
  }

  void unmarkDeleteById(String id) {
    _removeFromDeletes(id);
  }

  void removeCandidate(AssetEntity entity) {
    _removeFromDeletes(entity.id);
  }

  Future<void> markForKeep(AssetEntity entity) {
    _removeFromDeletes(entity.id);
    if (_keepIds.add(entity.id)) {
      _keepCandidates.add(entity);
    }
    return _persistKeeps();
  }

  Future<void> unmarkKeepById(String id) {
    _removeFromKeeps(id);
    return _persistKeeps();
  }

  Future<void> removeKeepCandidate(AssetEntity entity) {
    return unmarkKeepById(entity.id);
  }

  Future<void> clearKeeps() {
    _keepCandidates.clear();
    _keepIds.clear();
    return _persistKeeps();
  }

  Future<void> _persistKeeps() {
    _persistQueue = _persistQueue.then((_) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keepStorageKey, _keepIds.toList());
    });
    return _persistQueue;
  }

  void _removeFromKeeps(String id) {
    _keepIds.remove(id);
    _keepCandidates.removeWhere((entity) => entity.id == id);
  }

  void _removeFromDeletes(String id) {
    _deleteIds.remove(id);
    _deleteCandidates.removeWhere((entity) => entity.id == id);
  }
}
