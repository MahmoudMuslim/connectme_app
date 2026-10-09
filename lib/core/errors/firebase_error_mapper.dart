import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../errors/failures.dart';

/// Translates every third-party exception into one of the app's [Failure]s.
///
/// This is the single place where Firebase / platform error codes are decoded
/// into sentences a non technical user can understand, which guarantees that
/// **no raw exception ever reaches the UI**.
class FirebaseErrorMapper {
  const FirebaseErrorMapper._();

  /// Maps [error] to the matching [Failure].
  static Failure map(Object error) {
    return switch (error) {
      FirebaseAuthException() => _mapAuth(error),
      FirebaseException() => _mapFirestore(error),
      LocalAuthException() => _mapLocalAuth(error),
      PlatformException(:final String? code) => _mapPlatform(code, error),
      FileSystemException() => const CacheFailure(
        'We could not read the local cache. Please try again.',
      ),
      FormatException() => const CacheFailure(
        'Stored data is corrupted and could not be parsed.',
      ),
      ValidationException(:final String message) => ValidationFailure(message),
      SocketException() => const NetworkFailure(),
      _ => UnexpectedFailure('Something went wrong. Please try again.', error),
    };
  }

  /// Shortcut returning only the message a [Failure] should display.
  static String messageOf(Object error) => map(error).message;

  static Failure _mapAuth(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-email' => const AuthFailure(
        'That email address looks invalid. Please check it and try again.',
      ),
      'user-disabled' => const AuthFailure(
        'This account has been disabled. Please contact support.',
      ),
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' ||
      'invalid-login-credentials' => const AuthFailure(
        'Incorrect email or password. Please try again.',
      ),
      'email-already-in-use' => const AuthFailure(
        'An account already exists with this email. Try signing in instead.',
      ),
      'weak-password' => const AuthFailure(
        'Please choose a stronger password (at least 6 characters).',
      ),
      'operation-not-allowed' => const AuthFailure(
        'Email/password sign-in is disabled for this project.',
      ),
      'too-many-requests' => const AuthFailure(
        'Too many attempts. Please wait a moment and try again.',
      ),
      'network-request-failed' => const NetworkFailure(),
      _ => AuthFailure(
        error.message ?? 'We could not sign you in. Please try again.',
        cause: error,
      ),
    };
  }

  static Failure _mapFirestore(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' => const FirestoreFailure(
        'You do not have permission to perform this action.',
      ),
      'not-found' => const FirestoreFailure(
        'The requested item was not found.',
      ),
      'unavailable' || 'deadline-exceeded' => const NetworkFailure(),
      'failed-precondition' => const FirestoreFailure(
        'The server rejected the request. Please try again later.',
      ),
      'unauthenticated' => const AuthFailure(
        'Your session expired. Please sign in again.',
      ),
      'quota-exceeded' => const FirestoreFailure(
        'The database quota has been reached. Please try again later.',
      ),
      _ => FirestoreFailure(
        error.message ?? 'We could not reach the community server.',
        cause: error,
      ),
    };
  }

  static Failure _mapLocalAuth(LocalAuthException error) {
    return switch (error.code) {
      LocalAuthExceptionCode.noBiometricHardware => const BiometricFailure(
        'Biometric authentication is not available on this device.',
      ),
      LocalAuthExceptionCode.noBiometricsEnrolled => const BiometricFailure(
        'No fingerprint or face is enrolled. Add one in your device settings first.',
      ),
      LocalAuthExceptionCode.noCredentialsSet => const BiometricFailure(
        'Set a device passcode to use biometric authentication.',
      ),
      LocalAuthExceptionCode.temporaryLockout => const BiometricFailure(
        'Too many failed attempts. Unlock your device and try again later.',
      ),
      LocalAuthExceptionCode.biometricLockout => const BiometricFailure(
        'Biometrics are locked. Unlock your device with your PIN and try again.',
      ),
      LocalAuthExceptionCode.userCanceled ||
      LocalAuthExceptionCode.systemCanceled => const BiometricFailure(
        'Biometric verification was cancelled.',
      ),
      LocalAuthExceptionCode.timeout => const BiometricFailure(
        'The biometric prompt timed out. Please try again.',
      ),
      _ => BiometricFailure(
        error.description ?? 'Biometric authentication failed.',
        cause: error,
      ),
    };
  }

  static Failure _mapPlatform(String? code, Object error) {
    return switch (code) {
      'PhotoAccessDenied' ||
      'PhotoAccessDeniedWithoutPrompt' => const UnexpectedFailure(
        'ConnectMe needs photo library access to update your profile picture.',
      ),
      'camera_access_denied' ||
      'camera_access_denied_without_prompt' => const UnexpectedFailure(
        'ConnectMe needs camera access to take a new profile picture.',
      ),
      'already_active' => const UnexpectedFailure(
        'The image picker is already open. Please try again.',
      ),
      _ => UnexpectedFailure(
        'This device could not complete the request.',
        error,
      ),
    };
  }
}
