import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwipeDecisionStore {
  final List<AssetEntity> _deleteCandidates = [];
  final Set<String> _deleteIds = {};
  final List<AssetEntity> _keepCandidates = [];
  final Set<String> _keepIds = {};
  final List<AssetEntity> _recentDecisions = [];
  static const String _keepStorageKey = 'keep_ids';

  List<AssetEntity> get deleteCandidates =>
      List.unmodifiable(_deleteCandidates);
  List<AssetEntity> get keepCandidates => List.unmodifiable(_keepCandidates);

  int get undoCredits => _recentDecisions.length;

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
    if (_recentDecisions.length > 3) {
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

  void markForDelete(AssetEntity entity) {
    _keepIds.remove(entity.id);
    _keepCandidates.removeWhere((item) => item.id == entity.id);
    _persistKeeps();
    if (_deleteIds.add(entity.id)) {
      _deleteCandidates.add(entity);
    }
  }

  void unmarkDeleteById(String id) {
    _deleteIds.remove(id);
    _deleteCandidates.removeWhere((entity) => entity.id == id);
  }

  void removeCandidate(AssetEntity entity) {
    _deleteCandidates.removeWhere((item) => item.id == entity.id);
    _deleteIds.remove(entity.id);
  }

  void markForKeep(AssetEntity entity) {
    _deleteIds.remove(entity.id);
    _deleteCandidates.removeWhere((item) => item.id == entity.id);
    if (_keepIds.add(entity.id)) {
      _keepCandidates.add(entity);
    }
    _persistKeeps();
  }

  void unmarkKeepById(String id) {
    _keepIds.remove(id);
    _keepCandidates.removeWhere((entity) => entity.id == id);
    _persistKeeps();
  }

  void removeKeepCandidate(AssetEntity entity) {
    _keepCandidates.removeWhere((item) => item.id == entity.id);
    _keepIds.remove(entity.id);
    _persistKeeps();
  }

  void clearKeeps() {
    _keepCandidates.clear();
    _keepIds.clear();
    _persistKeeps();
  }

  void _persistKeeps() {
    () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keepStorageKey, _keepIds.toList());
    }();
  }
}
