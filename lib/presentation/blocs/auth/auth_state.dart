import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';

/// Status axis of [AuthCubit].
enum AuthStatus {
  /// The persisted session is being restored (splash screen).
  unknown,

  /// No member is signed in — show the login screen.
  unauthenticated,

  /// A sign-in / sign-up request is in flight.
  authenticating,

  /// A member is signed in — show the home shell.
  authenticated,
}

/// Immutable state of [AuthCubit].
class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.errorMessage,
    this.successMessage,
    this.isDemoMode = false,
  });

  final AuthStatus status;

  /// The signed-in member, `null` while signed out.
  final User? user;

  /// User friendly message of the last failure, already decoded by
  /// `FirebaseErrorMapper`.
  final String? errorMessage;

  /// User friendly success message (e.g. password reset sent).
  final String? successMessage;

  /// `true` when the app runs without a Firebase project (local accounts).
  final bool isDemoMode;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  bool get isBusy => status == AuthStatus.authenticating;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    String? successMessage,
    bool? isDemoMode,
    bool clearError = false,
    bool clearUser = false,
    bool clearSuccess = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      isDemoMode: isDemoMode ?? this.isDemoMode,
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[status, user, errorMessage, successMessage, isDemoMode];
}
