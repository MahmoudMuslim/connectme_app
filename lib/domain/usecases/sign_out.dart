import '../../core/result/result.dart';
import '../repositories/user_repository.dart';

/// Ends the current session and clears the persisted token.
class SignOut {
  const SignOut(this._repository);

  final UserRepository _repository;

  Future<Result<void>> call() => _repository.signOut();
}
