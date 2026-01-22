import 'package:flutter_test/flutter_test.dart';

import 'package:cullr/core/storage/key_value_store.dart';
import 'package:cullr/features/swipe/domain/services/swipe_decision_store.dart';
import 'package:cullr/features/swipe/domain/entities/media_asset.dart';
import 'package:cullr/features/swipe/domain/entities/media_kind.dart';
import 'package:cullr/features/swipe/domain/entities/swipe_config.dart';

MediaAsset _assetWithId(String id) {
  return MediaAsset(
    id: id,
    kind: MediaKind.photo,
    width: 0,
    height: 0,
    duration: 0,
    orientation: 0,
    subtype: 0,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    modifiedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );
}

MediaAssetLoader _loaderFrom(Map<String, MediaAsset> assets) {
  return (String id) async => assets[id];
}

const SwipeConfig _testConfig = SwipeConfig(
  galleryVideoBatchSize: 2,
  galleryOtherBatchSize: 2,
  swipeBufferSize: 4,
  swipeBufferPhotoTarget: 3,
  swipeBufferVideoTarget: 1,
  swipeVisibleCards: 2,
  swipeUndoLimit: 3,
  fullResHistoryLimit: 2,
  thumbnailBytesCacheLimit: 10,
  fileSizeLabelCacheLimit: 10,
  fileSizeBytesCacheLimit: 10,
  animatedBytesCacheLimit: 10,
  deleteMilestoneBytes: 100,
  deleteMilestoneMinInterval: Duration.zero,
);

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
  test('markForKeep stores keep candidate and id', () async {
    final SwipeDecisionStore store = SwipeDecisionStore(
      config: _testConfig,
      store: _MemoryStore(),
    );
    final MediaAsset asset = _assetWithId('a');

    await store.markForKeep(asset);

    expect(store.keepCandidates, contains(asset));
    expect(store.isKept('a'), isTrue);
    expect(store.isMarkedForDelete('a'), isFalse);
  });

  test('markForDelete stores delete candidate and clears keep', () async {
    final SwipeDecisionStore store = SwipeDecisionStore(
      config: _testConfig,
      store: _MemoryStore(),
    );
    final MediaAsset asset = _assetWithId('a');

    await store.markForKeep(asset);
    await store.markForDelete(asset);

    expect(store.keepCandidates, isNot(contains(asset)));
    expect(store.isKept('a'), isFalse);
    expect(store.isMarkedForDelete('a'), isTrue);
  });

  test('removeCandidate clears delete candidate', () async {
    final SwipeDecisionStore store = SwipeDecisionStore(
      config: _testConfig,
      store: _MemoryStore(),
    );
    final MediaAsset asset = _assetWithId('a');

    await store.markForDelete(asset);
    await store.removeCandidate(asset);

    expect(store.deleteCandidates, isEmpty);
    expect(store.isMarkedForDelete('a'), isFalse);
  });

  test('registerDecision and undo credits', () {
    final SwipeDecisionStore store = SwipeDecisionStore(
      config: _testConfig,
      store: _MemoryStore(),
    );
    final MediaAsset asset = _assetWithId('a');

    store.registerDecision(asset);
    expect(store.undoCredits, 1);
    expect(store.consumeUndo(), isTrue);
    expect(store.undoCredits, 0);
  });

  test('consumeUndo returns false when empty and caps credits', () {
    final SwipeDecisionStore store = SwipeDecisionStore(
      config: _testConfig,
      store: _MemoryStore(),
    );
    final MediaAsset assetA = _assetWithId('a');
    final MediaAsset assetB = _assetWithId('b');
    final MediaAsset assetC = _assetWithId('c');
    final MediaAsset assetD = _assetWithId('d');

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
    final KeyValueStore kvStore = _MemoryStore({
      'keep_ids': ['a', 'c'],
    });
    final MediaAsset assetA = _assetWithId('a');
    final MediaAsset assetB = _assetWithId('b');
    final MediaAsset assetC = _assetWithId('c');
    final SwipeDecisionStore store = SwipeDecisionStore(
      config: _testConfig,
      store: kvStore,
      assetLoader: _loaderFrom({'a': assetA, 'b': assetB, 'c': assetC}),
    );

    await store.loadDecisions();

    expect(store.keepCandidates, containsAll([assetA, assetC]));
    expect(store.keepCandidates, isNot(contains(assetB)));
  });

  test('markForDelete then markForKeep reclassifies candidate', () async {
    final SwipeDecisionStore store = SwipeDecisionStore(
      config: _testConfig,
      store: _MemoryStore(),
    );
    final MediaAsset asset = _assetWithId('a');

    await store.markForDelete(asset);
    await store.markForKeep(asset);

    expect(store.isMarkedForDelete('a'), isFalse);
    expect(store.isKept('a'), isTrue);
    expect(store.deleteCandidates, isNot(contains(asset)));
    expect(store.keepCandidates, contains(asset));
  });

  test('markForKeep then markForDelete reclassifies candidate', () async {
    final SwipeDecisionStore store = SwipeDecisionStore(
      config: _testConfig,
      store: _MemoryStore(),
    );
    final MediaAsset asset = _assetWithId('a');

    await store.markForKeep(asset);
    await store.markForDelete(asset);

    expect(store.isKept('a'), isFalse);
    expect(store.isMarkedForDelete('a'), isTrue);
    expect(store.keepCandidates, isNot(contains(asset)));
    expect(store.deleteCandidates, contains(asset));
  });

  test('markForKeep is idempotent for candidates list', () async {
    final SwipeDecisionStore store = SwipeDecisionStore(
      config: _testConfig,
      store: _MemoryStore(),
    );
    final MediaAsset asset = _assetWithId('a');

    await store.markForKeep(asset);
    await store.markForKeep(asset);

    expect(store.keepCandidates.length, 1);
    expect(store.keepCandidates.single, asset);
  });

  test('clearKeeps persists and clears stored ids', () async {
    final KeyValueStore kvStore = _MemoryStore({
      'keep_ids': ['a', 'b'],
    });
    final MediaAsset assetA = _assetWithId('a');
    final MediaAsset assetB = _assetWithId('b');
    final SwipeDecisionStore store = SwipeDecisionStore(
      config: _testConfig,
      store: kvStore,
      assetLoader: _loaderFrom({'a': assetA, 'b': assetB}),
    );

    await store.loadDecisions();
    await store.clearKeeps();

    final SwipeDecisionStore freshStore = SwipeDecisionStore(
      config: _testConfig,
      store: kvStore,
      assetLoader: _loaderFrom({'a': assetA, 'b': assetB}),
    );
    await freshStore.loadDecisions();

    expect(freshStore.isKept('a'), isFalse);
    expect(freshStore.isKept('b'), isFalse);
  });

  test('unmarkKeepById persists removal', () async {
    final KeyValueStore kvStore = _MemoryStore({
      'keep_ids': ['a', 'b'],
    });
    final MediaAsset assetA = _assetWithId('a');
    final MediaAsset assetB = _assetWithId('b');
    final SwipeDecisionStore store = SwipeDecisionStore(
      config: _testConfig,
      store: kvStore,
      assetLoader: _loaderFrom({'a': assetA, 'b': assetB}),
    );

    await store.loadDecisions();
    await store.unmarkKeepById('a');

    final SwipeDecisionStore freshStore = SwipeDecisionStore(
      config: _testConfig,
      store: kvStore,
      assetLoader: _loaderFrom({'a': assetA, 'b': assetB}),
    );
    await freshStore.loadDecisions();

    expect(freshStore.isKept('a'), isFalse);
    expect(freshStore.isKept('b'), isTrue);
  });

  test('loadDecisions restores delete ids', () async {
    final KeyValueStore kvStore = _MemoryStore({
      'delete_ids': ['a', 'c'],
    });
    final MediaAsset assetA = _assetWithId('a');
    final MediaAsset assetB = _assetWithId('b');
    final MediaAsset assetC = _assetWithId('c');
    final SwipeDecisionStore store = SwipeDecisionStore(
      config: _testConfig,
      store: kvStore,
      assetLoader: _loaderFrom({'a': assetA, 'b': assetB, 'c': assetC}),
    );

    await store.loadDecisions();

    expect(store.deleteCandidates, containsAll([assetA, assetC]));
    expect(store.deleteCandidates, isNot(contains(assetB)));
  });
}
