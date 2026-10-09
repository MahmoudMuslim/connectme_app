import '../../core/errors/failures.dart';
import '../../core/result/result.dart';

/// Native biometric service contract (fingerprint / face unlock).
///
/// Declared in the domain layer and implemented by
/// `lib/services/biometric_service.dart` so the cubits stay testable with a
/// fake implementation.
abstract interface class BiometricRepository {
  /// `true` when the device has a usable sensor.
  Future<bool> isAvailable();

  /// Shows the system biometric prompt.
  ///
  /// Returns `Success(true)` when the member was recognised,
  /// `Success(false)` when the challenge was simply dismissed and a
  /// `BiometricFailure` when the sensor is unavailable / locked out.
  Future<Result<bool>> authenticate({required String reason});

  /// Human readable label of the primary modality ("Fingerprint", "Face ID").
  Future<String> primaryBiometricLabel();
}

/// Use case guarding the profile screen behind a biometric challenge
/// (requirement 3: "Tapping it must trigger biometric authentication before
/// navigating to the Profile Screen").
class VerifyBiometrics {
  const VerifyBiometrics(this._repository);

  final BiometricRepository _repository;

  /// `true` when the device supports biometrics at all.
  Future<bool> isAvailable() => _repository.isAvailable();

  /// Runs the challenge. [reason] is shown inside the native prompt.
  Future<Result<bool>> call({required String reason}) {
    return _repository.authenticate(reason: reason);
  }

  /// Label of the modality, used in the pre-auth dialog.
  Future<String> label() => _repository.primaryBiometricLabel();
}

/// Raised when a biometric gate is enforced but no sensor exists.
const BiometricFailure biometricUnavailableFailure = BiometricFailure(
  'Biometric authentication is not available on this device.',
);
