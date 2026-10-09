import 'package:equatable/equatable.dart';

/// Base class of every recoverable error raised by the data layer.
///
/// Repositories translate low level exceptions (`FirebaseException`,
/// `PlatformException`, `FileSystemException`, ...) into a [Failure] so the
/// presentation layer never has to know about a third-party SDK. Every
/// failure already carries a **user friendly** [message] which is rendered
/// directly inside the UI.
sealed class Failure extends Equatable {
  const Failure(this.message, {this.cause});

  /// Sentence shown to the user through a `SnackBar` / error view.
  final String message;

  /// Original error kept for logging purposes only.
  final Object? cause;

  @override
  List<Object?> get props => <Object?>[message, cause];

  @override
  String toString() => '$runtimeType($message)';
}

/// The device could not reach the backend (no internet, timeout, ...).
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message =
        'No internet connection. Please check your network and try again.',
  ]);
}

/// Firebase Authentication rejected the request, e.g. wrong password.
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.cause});
}

/// The request was syntactically valid but semantically wrong
/// (empty post, malformed amount, ...).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.cause});
}

/// A Firestore read/write failed.
class FirestoreFailure extends Failure {
  const FirestoreFailure(super.message, {super.cause});
}

/// Reading or writing the local cache failed.
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.cause});
}

/// Biometric hardware is missing, disabled or the sensor is locked out.
class BiometricFailure extends Failure {
  const BiometricFailure(super.message, {super.cause});
}

/// The payment gateway rejected the transaction.
class PaymentFailure extends Failure {
  const PaymentFailure(super.message, {super.cause});
}

/// Reading device information failed.
class DeviceFailure extends Failure {
  const DeviceFailure(super.message, {super.cause});
}

/// Any unexpected error that the app could not classify.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'Something went wrong. Please try again.',
    Object? cause,
  ]) : super(cause: cause);
}

/// Thrown by validators/use cases when a value is rejected before it reaches
/// Firebase. Repositories catch it and convert it to a [ValidationFailure].
class ValidationException implements Exception {
  const ValidationException(this.message);

  final String message;

  @override
  String toString() => 'ValidationException: $message';
}
