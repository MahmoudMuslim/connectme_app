import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../core/errors/firebase_error_mapper.dart';
import '../../../core/result/result.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/restore_session.dart';
import '../../../domain/usecases/send_password_reset.dart';
import '../../../domain/usecases/sign_in.dart';
import '../../../domain/usecases/sign_out.dart';
import '../../../domain/usecases/sign_up.dart';
import '../../../domain/usecases/watch_auth_state.dart';
import '../../../services/auth_service.dart';
import 'auth_state.dart';

/// **CUBIT** owning the authentication state.
///
/// Requirement 1: "Manage authentication state using a dedicated AuthCubit."
///
/// The cubit contains no widget code and no Firebase import: it coordinates
/// four use cases and exposes an immutable [AuthState]. Every failure is
/// converted into a ready-to-display sentence by the repositories, so the cubit
/// can never emit a raw exception.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.sendPasswordResetUseCase,
    required this.signOutUseCase,
    required this.restoreSession,
    required this.watchAuthState,
    required this.authService,
  }) : super(const AuthState()) {
    _authSubscription = watchAuthState().listen(_onAuthStateChanged);
  }

  /// Email + password sign in.
  final SignIn signInUseCase;

  /// Account registration.
  final SignUp signUpUseCase;

  /// Password reset.
  final SendPasswordReset sendPasswordResetUseCase;

  /// Session termination.
  final SignOut signOutUseCase;

  /// Persisted-session restore performed by the splash screen.
  final RestoreSession restoreSession;

  /// Real-time authentication stream.
  final WatchAuthState watchAuthState;

  /// Read-only view of the backend the app is talking to.
  final AuthService authService;

  StreamSubscription<User?>? _authSubscription;

  /// Restores the persisted session. Called once from the splash screen.
  Future<void> bootstrap() async {
    final Result<User?> result = await restoreSession();
    if (isClosed) {
      return;
    }
    result.fold(
      onSuccess: (User? user) {
        if (user == null) {
          emit(
            state.copyWith(
              status: AuthStatus.unauthenticated,
              clearUser: true,
              clearError: true,
            ),
          );
          return;
        }
        // A stored session skips the login screen, exactly as required.
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            clearError: true,
          ),
        );
      },
      onFailure: (Object failure) {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            errorMessage: _messageOf(failure),
            clearUser: true,
          ),
        );
      },
    );
  }

  /// Signs in with email + password.
  Future<void> signIn({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.authenticating, clearError: true));
    final Result<User> result = await signInUseCase(
      email: email,
      password: password,
    );
    _emitForResult(result);
  }

  /// Registers a new member. The device details are captured by
  /// `GetDeviceInfo` before this call and forwarded to Firestore.
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    String? deviceModel,
    String? osVersion,
  }) async {
    emit(state.copyWith(status: AuthStatus.authenticating, clearError: true));
    final Result<User> result = await signUpUseCase(
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      deviceModel: deviceModel,
      osVersion: osVersion,
    );
    _emitForResult(result);
  }

  /// Ends the session.
  Future<void> signOut() async {
    final Result<void> result = await signOutUseCase();
    if (isClosed) {
      return;
    }
    result.fold(
      onSuccess: (_) =>
          emit(const AuthState(status: AuthStatus.unauthenticated)),
      onFailure: (Object failure) => emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          errorMessage: _messageOf(failure),
        ),
      ),
    );
  }

  /// Sends a password-reset email.
  Future<void> sendPasswordReset({required String email}) async {
    final Result<void> result = await sendPasswordResetUseCase(email: email);
    if (isClosed) {
      return;
    }
    result.fold(
      onSuccess: (_) => emit(
        state.copyWith(
          successMessage:
              'Password reset email sent to $email. Check your inbox.',
          clearError: true,
        ),
      ),
      onFailure: (Object failure) => emit(
        state.copyWith(
          errorMessage: _messageOf(failure),
          clearSuccess: true,
        ),
      ),
    );
  }

  /// Pushes a profile change (new photo / new name) into the session.
  void updateUser(User user) {
    if (isClosed) {
      return;
    }
    emit(state.copyWith(status: AuthStatus.authenticated, user: user));
  }

  /// Clears the last error / success message, used when the user starts typing.
  void clearError() {
    if (state.errorMessage == null && state.successMessage == null || isClosed) {
      return;
    }
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  void _onAuthStateChanged(User? user) {
    if (isClosed) {
      return;
    }
    if (user == null) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, clearUser: true));
      return;
    }
    emit(state.copyWith(status: AuthStatus.authenticated, user: user));
  }

  void _emitForResult(Result<User> result) {
    if (isClosed) {
      return;
    }
    result.fold(
      onSuccess: (User user) => emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        ),
      ),
      onFailure: (Object failure) => emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          errorMessage: _messageOf(failure),
        ),
      ),
    );
  }

  /// Failures already carry a user friendly message; anything unexpected falls
  /// back to a neutral sentence so no raw exception text is ever displayed.
  String _messageOf(Object failure) {
    if (failure is Failure) {
      return failure.message;
    }
    return FirebaseErrorMapper.messageOf(failure);
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
