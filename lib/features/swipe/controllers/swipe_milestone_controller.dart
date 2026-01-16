import 'package:shared_preferences/shared_preferences.dart';

class SwipeMilestoneController {
  SwipeMilestoneController({
    required int thresholdBytes,
    required Duration minInterval,
    bool debugShow = false,
  }) : _thresholdBytes = thresholdBytes,
       _minInterval = minInterval,
       _debugShow = debugShow;

  static const String _totalDeletedKey = 'milestone_total_deleted_bytes';
  static const String _milestoneIndexKey = 'milestone_index';
  static const String _lastShownKey = 'milestone_last_shown_at';

  final int _thresholdBytes;
  final Duration _minInterval;
  final bool _debugShow;
  int _milestoneIndex = 0;
  int? _pendingBytes;
  int _lastShownAtMs = 0;
  bool _shownThisSession = false;

  Future<int> loadTotalDeletedBytes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _milestoneIndex = prefs.getInt(_milestoneIndexKey) ?? 0;
    _lastShownAtMs = prefs.getInt(_lastShownKey) ?? 0;
    return prefs.getInt(_totalDeletedKey) ?? 0;
  }

  Future<void> persistTotal(int totalDeletedBytes) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_totalDeletedKey, totalDeletedBytes);
    await prefs.setInt(_milestoneIndexKey, _milestoneIndex);
    await prefs.setInt(_lastShownKey, _lastShownAtMs);
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
