// The Firestore query/reference types are `sealed`; mocktail necessarily
// implements them to stub the Firestore surface. This is the standard way to
// fake the SDK and is confined to the test folder. `unnecessary_lambdas` is a
// false positive here: mocktail's `when` needs the callback to capture the call.
// ignore_for_file: subtype_of_sealed_class, unnecessary_lambdas

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectme_app/data/datasources/local_post_datasource.dart';
import 'package:connectme_app/data/datasources/post_cache_store.dart';
import 'package:connectme_app/data/models/post_model.dart';
import 'package:connectme_app/data/repositories/post_repository_impl.dart';
import 'package:connectme_app/domain/usecases/get_device_info.dart';
import 'package:connectme_app/domain/usecases/verify_biometrics.dart';
import 'package:connectme_app/injection.dart';
import 'package:connectme_app/services/auth_service.dart';
import 'package:connectme_app/services/firestore_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'fake_platform_repositories.dart';

/// Mock classes for Firestore using mocktail.
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference<T> extends Mock
    implements CollectionReference<T> {}

class MockDocumentReference<T> extends Mock implements DocumentReference<T> {}

class MockQuery<T> extends Mock implements Query<T> {}

class MockQuerySnapshot<T> extends Mock implements QuerySnapshot<T> {}

class MockDocumentSnapshot<T> extends Mock implements DocumentSnapshot<T> {}

/// Boots the whole ConnectMe object graph for widget tests.
///
/// `flutter test` must never touch the network or a platform channel, so this
/// helper publishes fakes through the `injection.dart` testing seams before
/// `registerDependencies()` runs: a mocked Firestore, an in-memory
/// [FakeAuthService] and a feed backed by the local cache.
Future<void> setUpConnectMe() async {
  await resetConnectMe();
}

/// Rebuilds the graph from scratch with fakes.
Future<void> resetConnectMe() async {
  await resetDependencies();

  final MockFirebaseFirestore mockFirestore = MockFirebaseFirestore();
  final MockCollectionReference<Map<String, dynamic>> mockCollection =
      MockCollectionReference<Map<String, dynamic>>();
  final MockDocumentReference<Map<String, dynamic>> mockDoc =
      MockDocumentReference<Map<String, dynamic>>();
  final MockQuery<Map<String, dynamic>> mockQuery =
      MockQuery<Map<String, dynamic>>();
  final MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot =
      MockQuerySnapshot<Map<String, dynamic>>();
  final MockDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot =
      MockDocumentSnapshot<Map<String, dynamic>>();

  when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
  when(() => mockFirestore.doc(any())).thenReturn(mockDoc);

  when(() => mockCollection.doc(any())).thenReturn(mockDoc);
  when(
    () => mockCollection.where(
      any(),
      isEqualTo: any(named: 'isEqualTo'),
    ),
  ).thenReturn(mockQuery);
  when(
    () => mockCollection.orderBy(any(), descending: any(named: 'descending')),
  ).thenReturn(mockQuery);
  when(() => mockCollection.limit(any())).thenReturn(mockQuery);
  when(
    () => mockCollection.snapshots(
      includeMetadataChanges: any(named: 'includeMetadataChanges'),
    ),
  ).thenAnswer(
    (_) => Stream<QuerySnapshot<Map<String, dynamic>>>.value(mockQuerySnapshot),
  );
  when(() => mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);

  when(() => mockDoc.set(any())).thenAnswer((_) async {});
  when(() => mockDoc.set(any(), any())).thenAnswer((_) async {});
  when(() => mockDoc.delete()).thenAnswer((_) async {});
  when(() => mockDoc.get()).thenAnswer((_) async => mockDocSnapshot);

  when(
    () => mockQuery.where(any(), isEqualTo: any(named: 'isEqualTo')),
  ).thenReturn(mockQuery);
  when(
    () => mockQuery.orderBy(any(), descending: any(named: 'descending')),
  ).thenReturn(mockQuery);
  when(() => mockQuery.limit(any())).thenReturn(mockQuery);
  when(
    () => mockQuery.snapshots(
      includeMetadataChanges: any(named: 'includeMetadataChanges'),
    ),
  ).thenAnswer(
    (_) => Stream<QuerySnapshot<Map<String, dynamic>>>.value(mockQuerySnapshot),
  );
  when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

  when(() => mockQuerySnapshot.docs).thenReturn(
    const <QueryDocumentSnapshot<Map<String, dynamic>>>[],
  );
  when(() => mockDocSnapshot.exists).thenReturn(false);
  when(() => mockDocSnapshot.data()).thenReturn(null);

  final FirestoreService firestoreService = FirestoreService.forTesting(
    mockFirestore,
  );
  FirestoreService.registerInstance(firestoreService);

  final PostCacheStore cacheStore = PostCacheStore();
  for (final PostModel post in _seedPosts()) {
    await cacheStore.append(post);
  }

  getIt
    ..registerSingleton<BiometricRepository>(FakeBiometricRepository())
    ..registerSingleton<DeviceInfoRepository>(FakeDeviceInfoRepository())
    ..registerSingleton<AuthService>(
      FakeAuthService(firestoreService: firestoreService),
    )
    ..registerSingleton<PostRepositoryImpl>(
      PostRepositoryImpl.withDataSource(
        LocalPostDataSource(cacheStore: cacheStore),
        cacheStore,
      ),
    );

  await registerDependencies();
}

/// A small deterministic feed so widget tests do not need a live Firestore.
List<PostModel> _seedPosts() {
  final DateTime now = DateTime.now();
  return <PostModel>[
    PostModel.forNewPost(
      id: 'seed-1',
      authorId: 'seed-bruno',
      authorName: 'Bruno Pham',
      content: 'Just wrapped the ConnectMe beta build. Screenshots coming soon!',
      createdAt: now.subtract(const Duration(minutes: 42)),
    ),
    PostModel.forNewPost(
      id: 'seed-2',
      authorId: 'seed-amira',
      authorName: 'Amira Hassan',
      content: 'Cairo chapter is hosting an open source sprint this Friday.',
      createdAt: now.subtract(const Duration(hours: 3)),
    ),
    PostModel.forNewPost(
      id: 'seed-3',
      authorId: 'seed-thanh',
      authorName: 'Thanh Pham',
      content: 'Reminder: Firestore rules are now deployed on the project.',
      createdAt: now.subtract(const Duration(hours: 7)),
    ),
  ];
}
