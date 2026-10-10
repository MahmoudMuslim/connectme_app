import 'dart:async';

import 'package:connectme_app/core/errors/failures.dart';
import 'package:connectme_app/core/result/result.dart';
import 'package:connectme_app/data/models/user_model.dart';
import 'package:connectme_app/domain/entities/device_info.dart';
import 'package:connectme_app/domain/entities/user.dart';
import 'package:connectme_app/domain/usecases/get_device_info.dart';
import 'package:connectme_app/domain/usecases/verify_biometrics.dart';
import 'package:connectme_app/services/auth_service.dart';
import 'package:connectme_app/services/firestore_service.dart';

/// Biometric stand-in used by the widget tests.
///
/// `local_auth` talks to the platform through a Pigeon channel that does not
/// answer inside the test VM, so the gate would never resolve. Registering this
/// fake through the `injection.dart` testing seam keeps the production code
/// completely untouched.
class FakeBiometricRepository implements BiometricRepository {
  FakeBiometricRepository({
    this.available = true,
    this.authenticationResult = true,
    this.label = 'Fingerprint',
  });

  /// Whether the device reports a usable sensor.
  bool available;

  /// Value returned by a successful challenge.
  bool authenticationResult;

  /// Label reported by [primaryBiometricLabel].
  String label;

  /// Number of times the challenge actually ran.
  int authenticateCalls = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<Result<bool>> authenticate({required String reason}) async {
    authenticateCalls++;
    if (!available) {
      return const ResultFailure<bool>(
        BiometricFailure(
          'Biometric authentication is not available on this device.',
        ),
      );
    }
    return Success<bool>(authenticationResult);
  }

  @override
  Future<String> primaryBiometricLabel() async => label;
}

/// Device information stand-in with deterministic values.
class FakeDeviceInfoRepository implements DeviceInfoRepository {
  FakeDeviceInfoRepository({this.info});

  /// Value returned by [read]; defaults to [sample].
  final DeviceInfo? info;

  static DeviceInfo get sample => DeviceInfo(
    model: 'Pixel 8 Pro',
    osVersion: 'Android 14 (API 34)',
    platformName: 'Android',
    deviceName: 'sdk_gphone64',
    manufacturer: 'Google',
    uniqueId: 'test-device-id',
    isPhysicalDevice: true,
  );

  @override
  Future<Result<DeviceInfo>> read() async =>
      Success<DeviceInfo>(info ?? sample);
}

/// In-memory [AuthService] used by the widget tests.
///
/// The real service resolves `FirebaseAuth.instance`, which throws
/// `[core/no-app]` inside the test VM. This fake mirrors the same session
/// contract (sign up / sign in publish a user, sign out clears it) without any
/// Firebase dependency, so the whole widget graph stays exercised.
class FakeAuthService implements AuthService {
  FakeAuthService({required this.firestoreService});

  @override
  final FirestoreService firestoreService;

  final StreamController<User?> _controller =
      StreamController<User?>.broadcast();

  User? _current;

  @override
  Stream<User?> authStateChanges() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<User?> restoreSession() async => _current;

  @override
  User? currentUser() => _current;

  @override
  Future<User> signIn({required String email, required String password}) async {
    final User user = _userFor(
      email: email,
      fullName: _nameFromEmail(email),
    );
    _setCurrent(user);
    return user;
  }

  @override
  Future<User> signUp({
    required String fullName,
    required String email,
    required String password,
    String? deviceModel,
    String? osVersion,
  }) async {
    final User user = _userFor(email: email, fullName: fullName)
        .withDeviceInfo(deviceModel: deviceModel, osVersion: osVersion);
    _setCurrent(user);
    return user;
  }

  @override
  Future<void> signOut() async => _setCurrent(null);

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> updateCurrentSession(User user) async => _setCurrent(user);

  @override
  Future<void> dispose() => _controller.close();

  void _setCurrent(User? user) {
    _current = user;
    if (!_controller.isClosed) {
      _controller.add(user);
    }
  }

  UserModel _userFor({required String email, required String fullName}) {
    return UserModel(
      id: 'fake-${email.hashCode.toUnsigned(32)}',
      fullName: fullName,
      email: email,
      joinedAt: DateTime.now(),
    );
  }

  String _nameFromEmail(String email) {
    final String local = email.split('@').first;
    return local.isEmpty ? 'Community member' : local;
  }
}
