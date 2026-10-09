import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../core/errors/failures.dart';
import '../core/errors/firebase_error_mapper.dart';
import '../core/result/result.dart';
import '../domain/usecases/verify_biometrics.dart';

/// **SINGLETON** wrapper around `local_auth`.
///
/// Requirement 3: "Tapping it must trigger biometric fingerprint
/// authentication before navigating to the Profile Screen."
///
/// Every platform error is converted into a [BiometricFailure] carrying a
/// user-friendly sentence, so the UI never has to inspect SDK types.
class BiometricService implements BiometricRepository {
  BiometricService();

  static BiometricService? _instance;

  /// The shared instance.
  static BiometricService get instance => _instance ??= BiometricService();

  /// Publishes an instance (used by tests).
  static void registerInstance(BiometricService service) {
    _instance = service;
  }

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Upper bound for a platform round-trip. A wedged biometric HAL must never
  /// freeze the UI, so every call below is wrapped in this timeout.
  static const Duration _platformTimeout = Duration(seconds: 3);

  @override
  Future<bool> isAvailable() async {
    try {
      final bool supported = await _localAuth.isDeviceSupported().timeout(
        _platformTimeout,
      );
      if (!supported) {
        return false;
      }
      return await _localAuth.canCheckBiometrics.timeout(_platformTimeout) ||
          (await _localAuth.getAvailableBiometrics().timeout(_platformTimeout))
              .isNotEmpty;
    } on Object {
      return false;
    }
  }

  @override
  Future<Result<bool>> authenticate({required String reason}) async {
    try {
      final bool authenticated = await _localAuth
          .authenticate(
            localizedReason: reason,
            biometricOnly: false,
            persistAcrossBackgrounding: true,
          )
          .timeout(_platformTimeout);
      return Success<bool>(authenticated);
    } on TimeoutException {
      return const ResultFailure<bool>(
        BiometricFailure(
          'The biometric sensor did not respond. Please try again.',
        ),
      );
    } on LocalAuthException catch (error) {
      if (error.code == LocalAuthExceptionCode.userCanceled ||
          error.code == LocalAuthExceptionCode.systemCanceled) {
        return const ResultFailure<bool>(
          BiometricFailure('Biometric verification was cancelled.'),
        );
      }
      return ResultFailure<bool>(FirebaseErrorMapper.map(error));
    } on PlatformException catch (error) {
      return ResultFailure<bool>(FirebaseErrorMapper.map(error));
    } on Object catch (error) {
      return ResultFailure<bool>(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<String> primaryBiometricLabel() async {
    try {
      final List<BiometricType> types = await _localAuth
          .getAvailableBiometrics()
          .timeout(_platformTimeout);
      if (types.contains(BiometricType.fingerprint)) {
        return 'Fingerprint';
      }
      if (types.contains(BiometricType.face)) {
        return 'Face ID';
      }
      if (types.contains(BiometricType.strong)) {
        return 'Biometrics';
      }
      if (types.contains(BiometricType.weak)) {
        return 'Biometrics';
      }
    } on Object {
      // Fall through to the platform default below.
    }
    return defaultTargetPlatform == TargetPlatform.iOS
        ? 'Face ID'
        : 'Biometrics';
  }
}
