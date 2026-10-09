import 'package:connectme_app/core/errors/failures.dart';
import 'package:connectme_app/core/result/result.dart';
import 'package:connectme_app/domain/entities/device_info.dart';
import 'package:connectme_app/domain/usecases/get_device_info.dart';
import 'package:connectme_app/domain/usecases/verify_biometrics.dart';

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
