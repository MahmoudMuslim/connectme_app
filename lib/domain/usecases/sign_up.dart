import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../../core/utils/validators.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Registers a new community member.
///
/// This use case owns the sign-up business rules so the UI, the repository and
/// Firebase never have to duplicate them.
class SignUp {
  const SignUp(this._repository);

  final UserRepository _repository;

  Future<Result<User>> call({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    String? deviceModel,
    String? osVersion,
  }) {
    final String? nameError = Validators.fullName(fullName);
    if (nameError != null) {
      return _fail(nameError);
    }
    final String? emailError = Validators.email(email);
    if (emailError != null) {
      return _fail(emailError);
    }
    final String? passwordError = Validators.password(password);
    if (passwordError != null) {
      return _fail(passwordError);
    }
    final String? confirmError = Validators.confirmPassword(
      confirmPassword,
      password,
    );
    if (confirmError != null) {
      return _fail(confirmError);
    }
    if (fullName.trim().length > AppConstants.maxNameLength) {
      return _fail(
        'Name must be at most ${AppConstants.maxNameLength} characters',
      );
    }

    return _repository.signUp(
      fullName: fullName.trim(),
      email: email.trim(),
      password: password,
      deviceModel: deviceModel,
      osVersion: osVersion,
    );
  }

  Future<Result<User>> _fail(String message) => Future<Result<User>>.value(
    ResultFailure<User>(ValidationFailure(message)),
  );
}
