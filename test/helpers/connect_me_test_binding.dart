import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectme_app/domain/usecases/get_device_info.dart';
import 'package:connectme_app/domain/usecases/verify_biometrics.dart';
import 'package:connectme_app/injection.dart';
import 'package:connectme_app/services/firestore_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'fake_platform_repositories.dart';

/// Mock classes for Firestore using mocktail
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference<T> extends Mock implements CollectionReference<T> {}

class MockDocumentReference<T> extends Mock implements DocumentReference<T> {}

class MockQuery<T> extends Mock implements Query<T> {}

class MockWriteBatch extends Mock implements WriteBatch {}

class MockTransaction extends Mock implements Transaction {}

class MockQuerySnapshot<T> extends Mock implements QuerySnapshot<T> {}

class MockDocumentSnapshot<T> extends Mock implements DocumentSnapshot<T> {}

/// Fake classes for fallback values (used by mocktail for `any()`)
class FakeDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {}

class FakeCollectionReference extends Fake
    implements CollectionReference<Map<String, dynamic>> {}

class FakeQuery extends Fake implements Query<Map<String, dynamic>> {}

class FakeWriteBatch extends Fake implements WriteBatch {}

/// Boots the whole ConnectMe object graph for widget tests.
///
/// `flutter test` must never touch the network or a platform channel, so this
/// helper injects a fake `FirestoreService` before `registerDependencies()` runs —
/// `injection.dart` keeps any registration that already exists.
Future<void> setUpConnectMe() async {
  await resetConnectMe();
}

/// Rebuilds the graph from scratch with mocked Firestore.
Future<void> resetConnectMe() async {
  // Register fallback values for mocktail's `any()` to work with complex types
  registerFallbackValue(FakeDocumentReference());
  registerFallbackValue(FakeCollectionReference());
  registerFallbackValue(FakeQuery());
  registerFallbackValue(FakeWriteBatch());

  await resetDependencies();

  final mockFirestore = MockFirebaseFirestore();
  final mockCollection = MockCollectionReference<Map<String, dynamic>>();
  final mockDoc = MockDocumentReference<Map<String, dynamic>>();
  final mockQuery = MockQuery<Map<String, dynamic>>();
  final mockBatch = MockWriteBatch();
  final mockTransaction = MockTransaction();
  final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
  final mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

  // Setup basic mock behaviors
  when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
  when(() => mockFirestore.doc(any())).thenReturn(mockDoc);
  when(() => mockFirestore.batch()).thenReturn(mockBatch);
  when(() => mockFirestore.runTransaction(any())).thenAnswer((
    invocation,
  ) async {
    final handler = invocation.positionalArguments.first as TransactionHandler;
    return await handler(mockTransaction);
  });
  when(() => mockFirestore.settings).thenReturn(const Settings());

  when(() => mockCollection.doc(any())).thenReturn(mockDoc);
  when(() => mockCollection.where(any())).thenReturn(mockQuery);
  when(
    () => mockCollection.orderBy(any(), descending: any(named: 'descending')),
  ).thenReturn(mockQuery);
  when(() => mockCollection.limit(any())).thenReturn(mockQuery);
  when(
    () => mockCollection.snapshots(
      includeMetadataChanges: any(named: 'includeMetadataChanges'),
    ),
  ).thenAnswer((_) => const Stream.empty());
  when(() => mockCollection.get(any()))
      .thenAnswer((_) async => mockQuerySnapshot);
  when(() => mockCollection.add(any())).thenAnswer((_) async => mockDoc);

  when(() => mockDoc.set(any(), any())).thenAnswer((_) async {});
  when(() => mockDoc.delete()).thenAnswer((_) async {});
  when(() => mockDoc.get(any())).thenAnswer((_) async => mockDocSnapshot);
  when(
    () => mockDoc.snapshots(
      includeMetadataChanges: any(named: 'includeMetadataChanges'),
    ),
  ).thenAnswer((_) => const Stream.empty());
  when(() => mockDoc.collection(any())).thenReturn(mockCollection);
  when(() => mockDoc.update(any())).thenAnswer((_) async {});

  when(
    () => mockQuery.snapshots(
      includeMetadataChanges: any(named: 'includeMetadataChanges'),
    ),
  ).thenAnswer((_) => const Stream.empty());
  when(() => mockQuery.get(any())).thenAnswer((_) async => mockQuerySnapshot);
  when(() => mockQuery.where(any())).thenReturn(mockQuery);
  when(() => mockQuery.orderBy(any(), descending: any(named: 'descending')))
      .thenReturn(mockQuery);
  when(() => mockQuery.limit(any())).thenReturn(mockQuery);

  when(() => mockBatch.set(any(), any(), any())).thenReturn(mockBatch);
  when(() => mockBatch.update(any(), any())).thenReturn(mockBatch);
  when(() => mockBatch.delete(any())).thenReturn(mockBatch);
  when(() => mockBatch.commit()).thenAnswer((_) async {});

  // Transaction methods commented out - not used by app tests
  // when(() => mockTransaction.doc(any())).thenReturn(mockDoc);
  // when(() => mockTransaction.collection(any())).thenReturn(mockCollection);

  when(() => mockQuerySnapshot.docs).thenReturn([]);
  when(() => mockDocSnapshot.exists).thenReturn(false);
  when(() => mockDocSnapshot.data()).thenReturn(null);

  FirestoreService.registerInstance(
    FirestoreService.forTesting(mockFirestore),
  );

  getIt
    ..registerSingleton<BiometricRepository>(FakeBiometricRepository())
    ..registerSingleton<DeviceInfoRepository>(FakeDeviceInfoRepository());
  await registerDependencies();
}