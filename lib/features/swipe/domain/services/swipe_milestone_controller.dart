import '../../../../core/storage/key_value_store.dart';
import '../../../../core/storage/shared_preferences_store.dart';

class SwipeMilestoneController {
  SwipeMilestoneController({
    required int thresholdBytes,
    required Duration minInterval,
    bool debugShow = false,
    KeyValueStore? store,
  }) : _thresholdBytes = thresholdBytes,
       _minInterval = minInterval,
       _debugShow = debugShow,
       _store = store ?? SharedPreferencesStore();

  static const String _totalDeletedKey = 'milestone_total_deleted_bytes';
  static const String _milestoneIndexKey = 'milestone_index';
  static const String _lastShownKey = 'milestone_last_shown_at';

  final int _thresholdBytes;
  final Duration _minInterval;
  final bool _debugShow;
  final KeyValueStore _store;
  int _milestoneIndex = 0;
  int? _pendingBytes;
  int _lastShownAtMs = 0;
  bool _shownThisSession = false;

  Future<int> loadTotalDeletedBytes() async {
    _milestoneIndex = await _store.getInt(_milestoneIndexKey) ?? 0;
    _lastShownAtMs = await _store.getInt(_lastShownKey) ?? 0;
    return await _store.getInt(_totalDeletedKey) ?? 0;
  }

  Future<void> persistTotal(int totalDeletedBytes) async {
    await _store.setInt(_totalDeletedKey, totalDeletedBytes);
    await _store.setInt(_milestoneIndexKey, _milestoneIndex);
    await _store.setInt(_lastShownKey, _lastShownAtMs);
  }

  Future<void> markShown({required int totalDeletedBytes}) async {
    _shownThisSession = true;
    _lastShownAtMs = DateTime.now().millisecondsSinceEpoch;
    await persistTotal(totalDeletedBytes);
  }

  void syncWithTotal(int totalDeletedBytes) {
    if (_thresholdBytes <= 0) {
      _milestoneIndex = 0;
      _pendingBytes = null;
      return;
    }
    _milestoneIndex = totalDeletedBytes ~/ _thresholdBytes;
    _pendingBytes = null;
  }

  int? handleDeletion({
    required int totalDeletedBytes,
    required bool hasMilestoneCard,
  }) {
    if (_thresholdBytes <= 0) {
      return null;
    }
    final int nextIndex = totalDeletedBytes ~/ _thresholdBytes;
    if (nextIndex <= _milestoneIndex) {
      return null;
    }
    _milestoneIndex = nextIndex;
    return _queueOrHold(totalDeletedBytes, hasMilestoneCard);
  }

  int? debugMilestone({required bool hasMilestoneCard}) {
    if (!_debugShow) {
      return null;
    }
    return _queueOrHold(_thresholdBytes, hasMilestoneCard);
  }

  int? onMilestoneDismissed({required bool hasMilestoneCard}) {
    if (hasMilestoneCard || _pendingBytes == null) {
      return null;
    }
    if (!_canShowNow()) {
      return null;
    }
    final int bytes = _pendingBytes!;
    _pendingBytes = null;
    return bytes;
  }

  int? _queueOrHold(int bytes, bool hasMilestoneCard) {
    if (hasMilestoneCard || !_canShowNow()) {
      _pendingBytes = bytes;
      return null;
    }
    _pendingBytes = null;
    return bytes;
  }

  bool _canShowNow() {
    if (!_shownThisSession) {
      return true;
    }
    if (_minInterval == Duration.zero) {
      return true;
    }
    final int now = DateTime.now().millisecondsSinceEpoch;
    return now - _lastShownAtMs >= _minInterval.inMilliseconds;
  }
}
