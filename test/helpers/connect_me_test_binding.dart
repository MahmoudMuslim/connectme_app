import 'package:connectme_app/domain/usecases/get_device_info.dart';
import 'package:connectme_app/domain/usecases/verify_biometrics.dart';
import 'package:connectme_app/injection.dart';
import 'package:connectme_app/services/firestore_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_platform_repositories.dart';

/// Boots the whole ConnectMe object graph for widget tests.
///
/// `flutter test` must never touch the network or a platform channel, so this
/// helper injects a fake `FirestoreService` before `registerDependencies()` runs —
/// `injection.dart` keeps any registration that already exists.
Future<void> setUpConnectMe() async {
  await resetConnectMe();
}

/// Rebuilds the graph from scratch with a fake Firestore.
Future<void> resetConnectMe() async {
  await resetDependencies();
  FirestoreService.registerInstance(
    FirestoreService.forTesting(_FakeFirestore()),
  );
  getIt
    ..registerSingleton<BiometricRepository>(FakeBiometricRepository())
    ..registerSingleton<DeviceInfoRepository>(FakeDeviceInfoRepository());
  await registerDependencies();
}

/// Minimal fake Firestore for testing - doesn't connect to real Firebase.
class _FakeFirestore {
  const _FakeFirestore();
}