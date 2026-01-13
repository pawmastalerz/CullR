import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cullr/features/swipe/controllers/swipe_decision_store.dart';

class _MockAssetEntity extends Mock implements AssetEntity {}

AssetEntity _assetWithId(String id) {
  final _MockAssetEntity asset = _MockAssetEntity();
  when(() => asset.id).thenReturn(id);
  when(() => asset.type).thenReturn(AssetType.image);
  return asset;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('markForKeep stores keep candidate and id', () {
    final SwipeDecisionStore store = SwipeDecisionStore();
    final AssetEntity asset = _assetWithId('a');

    store.markForKeep(asset);

    expect(store.keepCandidates, contains(asset));
    expect(store.isKept('a'), isTrue);
    expect(store.isMarkedForDelete('a'), isFalse);
  });

  test('markForDelete stores delete candidate and clears keep', () {
    final SwipeDecisionStore store = SwipeDecisionStore();
    final AssetEntity asset = _assetWithId('a');

    store.markForKeep(asset);
    store.markForDelete(asset);

    expect(store.keepCandidates, isNot(contains(asset)));
    expect(store.isKept('a'), isFalse);
    expect(store.isMarkedForDelete('a'), isTrue);
  });

  test('removeCandidate clears delete candidate', () {
    final SwipeDecisionStore store = SwipeDecisionStore();
    final AssetEntity asset = _assetWithId('a');

    store.markForDelete(asset);
    store.removeCandidate(asset);

    expect(store.deleteCandidates, isEmpty);
    expect(store.isMarkedForDelete('a'), isFalse);
  });

  test('registerDecision and undo credits', () {
    final SwipeDecisionStore store = SwipeDecisionStore();
    final AssetEntity asset = _assetWithId('a');

    store.registerDecision(asset);
    expect(store.undoCredits, 1);
    expect(store.consumeUndo(), isTrue);
    expect(store.undoCredits, 0);
  });

  test('loadKeeps and syncKeeps use stored ids', () async {
    SharedPreferences.setMockInitialValues({
      'keep_ids': ['a', 'c'],
    });
    final SwipeDecisionStore store = SwipeDecisionStore();
    final AssetEntity assetA = _assetWithId('a');
    final AssetEntity assetB = _assetWithId('b');
    final AssetEntity assetC = _assetWithId('c');

    await store.loadKeeps();
    store.syncKeeps([assetA, assetB, assetC]);

    expect(store.keepCandidates, containsAll([assetA, assetC]));
    expect(store.keepCandidates, isNot(contains(assetB)));
  });
}
