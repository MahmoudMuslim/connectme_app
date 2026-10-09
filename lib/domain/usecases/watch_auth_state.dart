import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Emits the authentication state in real time (Firebase `authStateChanges` or
/// the local session in demo mode).
class WatchAuthState {
  const WatchAuthState(this._repository);

  final UserRepository _repository;

  Stream<User?> call() => _repository.authStateChanges();
}
