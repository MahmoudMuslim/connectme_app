import 'package:connectme_app/domain/usecases/get_device_info.dart';
import 'package:connectme_app/domain/usecases/verify_biometrics.dart';
import 'package:connectme_app/injection.dart';
import 'package:connectme_app/services/firestore_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_platform_repositories.dart';

/// Boots the whole ConnectMe object graph in demo mode for widget tests.
///
/// `flutter test` must never touch the network or a platform channel, so this
/// helper forces the on-device cache (whatever `firebase_options.dart` the
/// repository contains) and publishes the `local_auth` / `device_info_plus`
/// stand-ins *before* `registerDependencies()` runs — `injection.dart` keeps
/// any registration that already exists.
Future<void> setUpConnectMe() async {
  await resetConnectMe();
}

/// Rebuilds the graph from scratch in demo mode.
Future<void> resetConnectMe() async {
  await resetDependencies();
  FirestoreService.useDemoMode();
  SharedPreferences.setMockInitialValues(<String, Object>{});
  getIt
    ..registerSingleton<BiometricRepository>(FakeBiometricRepository())
    ..registerSingleton<DeviceInfoRepository>(FakeDeviceInfoRepository());
  await registerDependencies();
}
