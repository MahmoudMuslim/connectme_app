import '../../core/result/result.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Restores the persisted session at start-up so a member who is already
/// signed in skips the login screen (requirement 1: "persist auth state").
class RestoreSession {
  const RestoreSession(this._repository);

  final UserRepository _repository;

  Future<Result<User?>> call() => _repository.restoreSession();
}
