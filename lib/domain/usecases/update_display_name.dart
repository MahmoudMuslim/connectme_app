import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../../core/utils/validators.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Renames a member, re-validating the Figma sign-up rules (capital letter).
class UpdateDisplayName {
  const UpdateDisplayName(this._repository);

  final UserRepository _repository;

  Future<Result<User>> call({
    required String userId,
    required String fullName,
  }) {
    final String? error = Validators.fullName(fullName);
    if (error != null) {
      return Future<Result<User>>.value(
        ResultFailure<User>(ValidationFailure(error)),
      );
    }
    return _repository.updateDisplayName(
      userId: userId,
      fullName: fullName.trim(),
    );
  }
}
