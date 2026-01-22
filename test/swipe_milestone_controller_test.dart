import 'package:flutter_test/flutter_test.dart';

import 'package:cullr/core/storage/key_value_store.dart';
import 'package:cullr/features/swipe/domain/services/swipe_milestone_controller.dart';

class _MemoryStore implements KeyValueStore {
  _MemoryStore([Map<String, Object?>? initial])
    : _data = initial ?? <String, Object?>{};

  final Map<String, Object?> _data;

  @override
  Future<List<String>?> getStringList(String key) async {
    final Object? value = _data[key];
    if (value is List<String>) {
      return List<String>.from(value);
    }
    return null;
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    _data[key] = List<String>.from(value);
  }

  @override
  Future<int?> getInt(String key) async {
    final Object? value = _data[key];
    return value is int ? value : null;
  }

  @override
  Future<void> setInt(String key, int value) async {
    _data[key] = value;
  }

  @override
  Future<String?> getString(String key) async {
    final Object? value = _data[key];
    return value is String ? value : null;
  }

  @override
  Future<void> setString(String key, String value) async {
    _data[key] = value;
  }
}

void main() {
  test('handleDeletion triggers only when threshold crossed', () {
    final SwipeMilestoneController controller = SwipeMilestoneController(
      thresholdBytes: 100,
      minInterval: Duration.zero,
      store: _MemoryStore(),
    );

    expect(
      controller.handleDeletion(totalDeletedBytes: 99, hasMilestoneCard: false),
      isNull,
    );
    expect(
      controller.handleDeletion(
        totalDeletedBytes: 100,
        hasMilestoneCard: false,
      ),
      100,
    );
  });

  test('large delete reports total and respects incremental thresholds', () {
    final SwipeMilestoneController controller = SwipeMilestoneController(
      thresholdBytes: 100,
      minInterval: Duration.zero,
      store: _MemoryStore(),
    );

    expect(
      controller.handleDeletion(
        totalDeletedBytes: 420,
        hasMilestoneCard: false,
      ),
      420,
    );
    expect(
      controller.handleDeletion(
        totalDeletedBytes: 435,
        hasMilestoneCard: false,
      ),
      isNull,
    );
    expect(
      controller.handleDeletion(
        totalDeletedBytes: 510,
        hasMilestoneCard: false,
      ),
      510,
    );
  });

  test('pending milestone keeps latest when card already visible', () {
    final SwipeMilestoneController controller = SwipeMilestoneController(
      thresholdBytes: 100,
      minInterval: Duration.zero,
      store: _MemoryStore(),
    );

    expect(
      controller.handleDeletion(totalDeletedBytes: 120, hasMilestoneCard: true),
      isNull,
    );
    expect(
      controller.handleDeletion(totalDeletedBytes: 220, hasMilestoneCard: true),
      isNull,
    );
    expect(controller.onMilestoneDismissed(hasMilestoneCard: false), 220);
  });

  test('session cap blocks new milestones until interval passes', () async {
    final SwipeMilestoneController controller = SwipeMilestoneController(
      thresholdBytes: 100,
      minInterval: const Duration(minutes: 10),
      store: _MemoryStore(),
    );

    final int? first = controller.handleDeletion(
      totalDeletedBytes: 100,
      hasMilestoneCard: false,
    );
    expect(first, 100);
    await controller.markShown(totalDeletedBytes: 100);

    expect(
      controller.handleDeletion(
        totalDeletedBytes: 200,
        hasMilestoneCard: false,
      ),
      isNull,
    );
    expect(controller.onMilestoneDismissed(hasMilestoneCard: false), isNull);
  });

  test('zero interval allows multiple milestones in a session', () async {
    final SwipeMilestoneController controller = SwipeMilestoneController(
      thresholdBytes: 100,
      minInterval: Duration.zero,
      store: _MemoryStore(),
    );

    expect(
      controller.handleDeletion(
        totalDeletedBytes: 100,
        hasMilestoneCard: false,
      ),
      100,
    );
    await controller.markShown(totalDeletedBytes: 100);
    expect(
      controller.handleDeletion(
        totalDeletedBytes: 200,
        hasMilestoneCard: false,
      ),
      200,
    );
  });

  test('debugMilestone respects debug flag and card presence', () {
    final SwipeMilestoneController controller = SwipeMilestoneController(
      thresholdBytes: 100,
      minInterval: Duration.zero,
      debugShow: true,
      store: _MemoryStore(),
    );

    expect(controller.debugMilestone(hasMilestoneCard: false), 100);
    expect(controller.debugMilestone(hasMilestoneCard: true), isNull);
  });

  test('persisted totals are restored across sessions', () async {
    final KeyValueStore store = _MemoryStore();
    final SwipeMilestoneController controller = SwipeMilestoneController(
      thresholdBytes: 100,
      minInterval: Duration.zero,
      store: store,
    );

    await controller.persistTotal(250);

    final SwipeMilestoneController fresh = SwipeMilestoneController(
      thresholdBytes: 100,
      minInterval: Duration.zero,
      store: store,
    );
    final int restored = await fresh.loadTotalDeletedBytes();
    expect(restored, 250);
  });

  test('handles very large totals without overflow', () {
    final SwipeMilestoneController controller = SwipeMilestoneController(
      thresholdBytes: 100,
      minInterval: Duration.zero,
      store: _MemoryStore(),
    );
    final int huge = 9 * 1024 * 1024 * 1024;

    expect(
      controller.handleDeletion(
        totalDeletedBytes: huge,
        hasMilestoneCard: false,
      ),
      huge,
    );
  });
}
