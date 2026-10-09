import '../../core/result/result.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Signs a member in with email + password.
class SignIn {
  const SignIn(this._repository);

  final UserRepository _repository;

  Future<Result<User>> call({required String email, required String password}) {
    return _repository.signIn(email: email.trim(), password: password);
  }
}
