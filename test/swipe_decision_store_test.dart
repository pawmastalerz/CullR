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

AssetEntityLoader _loaderFrom(Map<String, AssetEntity> assets) {
  return (String id) async => assets[id];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('markForKeep stores keep candidate and id', () async {
    final SwipeDecisionStore store = SwipeDecisionStore();
    final AssetEntity asset = _assetWithId('a');

    await store.markForKeep(asset);

    expect(store.keepCandidates, contains(asset));
    expect(store.isKept('a'), isTrue);
    expect(store.isMarkedForDelete('a'), isFalse);
  });

  test('markForDelete stores delete candidate and clears keep', () async {
    final SwipeDecisionStore store = SwipeDecisionStore();
    final AssetEntity asset = _assetWithId('a');

    await store.markForKeep(asset);
    await store.markForDelete(asset);

    expect(store.keepCandidates, isNot(contains(asset)));
    expect(store.isKept('a'), isFalse);
    expect(store.isMarkedForDelete('a'), isTrue);
  });

  test('removeCandidate clears delete candidate', () async {
    final SwipeDecisionStore store = SwipeDecisionStore();
    final AssetEntity asset = _assetWithId('a');

    await store.markForDelete(asset);
    await store.removeCandidate(asset);

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

  test('consumeUndo returns false when empty and caps credits', () {
    final SwipeDecisionStore store = SwipeDecisionStore();
    final AssetEntity assetA = _assetWithId('a');
    final AssetEntity assetB = _assetWithId('b');
    final AssetEntity assetC = _assetWithId('c');
    final AssetEntity assetD = _assetWithId('d');

    expect(store.consumeUndo(), isFalse);

    store
      ..registerDecision(assetA)
      ..registerDecision(assetB)
      ..registerDecision(assetC)
      ..registerDecision(assetD);

    expect(store.undoCredits, 3);
    expect(store.consumeUndo(), isTrue);
    expect(store.consumeUndo(), isTrue);
    expect(store.consumeUndo(), isTrue);
    expect(store.consumeUndo(), isFalse);
  });

  test('loadDecisions restores keep ids', () async {
    SharedPreferences.setMockInitialValues({
      'keep_ids': ['a', 'c'],
    });
    final AssetEntity assetA = _assetWithId('a');
    final AssetEntity assetB = _assetWithId('b');
    final AssetEntity assetC = _assetWithId('c');
    final SwipeDecisionStore store = SwipeDecisionStore(
      entityLoader: _loaderFrom({'a': assetA, 'b': assetB, 'c': assetC}),
    );

    await store.loadDecisions();

    expect(store.keepCandidates, containsAll([assetA, assetC]));
    expect(store.keepCandidates, isNot(contains(assetB)));
  });

  test('markForDelete then markForKeep reclassifies candidate', () async {
    final SwipeDecisionStore store = SwipeDecisionStore();
    final AssetEntity asset = _assetWithId('a');

    await store.markForDelete(asset);
    await store.markForKeep(asset);

    expect(store.isMarkedForDelete('a'), isFalse);
    expect(store.isKept('a'), isTrue);
    expect(store.deleteCandidates, isNot(contains(asset)));
    expect(store.keepCandidates, contains(asset));
  });

  test('markForKeep then markForDelete reclassifies candidate', () async {
    final SwipeDecisionStore store = SwipeDecisionStore();
    final AssetEntity asset = _assetWithId('a');

    await store.markForKeep(asset);
    await store.markForDelete(asset);

    expect(store.isKept('a'), isFalse);
    expect(store.isMarkedForDelete('a'), isTrue);
    expect(store.keepCandidates, isNot(contains(asset)));
    expect(store.deleteCandidates, contains(asset));
  });

  test('markForKeep is idempotent for candidates list', () async {
    final SwipeDecisionStore store = SwipeDecisionStore();
    final AssetEntity asset = _assetWithId('a');

    await store.markForKeep(asset);
    await store.markForKeep(asset);

    expect(store.keepCandidates.length, 1);
    expect(store.keepCandidates.single, asset);
  });

  test('clearKeeps persists and clears stored ids', () async {
    SharedPreferences.setMockInitialValues({
      'keep_ids': ['a', 'b'],
    });
    final AssetEntity assetA = _assetWithId('a');
    final AssetEntity assetB = _assetWithId('b');
    final SwipeDecisionStore store = SwipeDecisionStore(
      entityLoader: _loaderFrom({'a': assetA, 'b': assetB}),
    );

    await store.loadDecisions();
    await store.clearKeeps();

    final SwipeDecisionStore freshStore = SwipeDecisionStore(
      entityLoader: _loaderFrom({'a': assetA, 'b': assetB}),
    );
    await freshStore.loadDecisions();

    expect(freshStore.isKept('a'), isFalse);
    expect(freshStore.isKept('b'), isFalse);
  });

  test('unmarkKeepById persists removal', () async {
    SharedPreferences.setMockInitialValues({
      'keep_ids': ['a', 'b'],
    });
    final AssetEntity assetA = _assetWithId('a');
    final AssetEntity assetB = _assetWithId('b');
    final SwipeDecisionStore store = SwipeDecisionStore(
      entityLoader: _loaderFrom({'a': assetA, 'b': assetB}),
    );

    await store.loadDecisions();
    await store.unmarkKeepById('a');

    final SwipeDecisionStore freshStore = SwipeDecisionStore(
      entityLoader: _loaderFrom({'a': assetA, 'b': assetB}),
    );
    await freshStore.loadDecisions();

    expect(freshStore.isKept('a'), isFalse);
    expect(freshStore.isKept('b'), isTrue);
  });

  test('loadDecisions restores delete ids', () async {
    SharedPreferences.setMockInitialValues({
      'delete_ids': ['a', 'c'],
    });
    final AssetEntity assetA = _assetWithId('a');
    final AssetEntity assetB = _assetWithId('b');
    final AssetEntity assetC = _assetWithId('c');
    final SwipeDecisionStore store = SwipeDecisionStore(
      entityLoader: _loaderFrom({'a': assetA, 'b': assetB, 'c': assetC}),
    );

    await store.loadDecisions();

    expect(store.deleteCandidates, containsAll([assetA, assetC]));
    expect(store.deleteCandidates, isNot(contains(assetB)));
  });
}
