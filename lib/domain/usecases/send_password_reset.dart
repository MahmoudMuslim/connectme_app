import '../../core/result/result.dart';
import '../repositories/user_repository.dart';

/// Sends a password-reset email to the given address.
class SendPasswordReset {
  const SendPasswordReset(this._repository);

  final UserRepository _repository;

  Future<Result<void>> call({required String email}) {
    return _repository.sendPasswordResetEmail(email: email.trim());
  }
}