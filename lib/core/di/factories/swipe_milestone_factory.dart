import '../../../features/swipe/domain/entities/swipe_config.dart';
import '../../../features/swipe/domain/services/swipe_milestone_controller.dart';

abstract class SwipeMilestoneFactory {
  const SwipeMilestoneFactory();

  SwipeMilestoneController create({required SwipeConfig config});
}

class DefaultSwipeMilestoneFactory implements SwipeMilestoneFactory {
  const DefaultSwipeMilestoneFactory();

  @override
  SwipeMilestoneController create({required SwipeConfig config}) {
    return SwipeMilestoneController(
      thresholdBytes: config.deleteMilestoneBytes,
      minInterval: config.deleteMilestoneMinInterval,
    );
  }
}
