import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cullr/features/swipe/controllers/swipe_milestone_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('handleDeletion triggers only when threshold crossed', () {
    final SwipeMilestoneController controller = SwipeMilestoneController(
      thresholdBytes: 100,
      minInterval: Duration.zero,
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
    );

    expect(controller.debugMilestone(hasMilestoneCard: false), 100);
    expect(controller.debugMilestone(hasMilestoneCard: true), isNull);
  });

  test('persisted totals are restored across sessions', () async {
    final SwipeMilestoneController controller = SwipeMilestoneController(
      thresholdBytes: 100,
      minInterval: Duration.zero,
    );

    await controller.persistTotal(250);

    final SwipeMilestoneController fresh = SwipeMilestoneController(
      thresholdBytes: 100,
      minInterval: Duration.zero,
    );
    final int restored = await fresh.loadTotalDeletedBytes();
    expect(restored, 250);
  });

  test('handles very large totals without overflow', () {
    final SwipeMilestoneController controller = SwipeMilestoneController(
      thresholdBytes: 100,
      minInterval: Duration.zero,
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
