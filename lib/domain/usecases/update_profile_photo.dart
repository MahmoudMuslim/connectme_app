import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Uploads a new profile picture and returns the refreshed [User].
///
/// Backs the "Update photo" button of the profile screen (requirement 3).
class UpdateProfilePhoto {
  const UpdateProfilePhoto(this._repository);

  final UserRepository _repository;

  Future<Result<User>> call({
    required String userId,
    required String photoUrl,
  }) {
    if (userId.isEmpty) {
      return Future<Result<User>>.value(
        const ResultFailure<User>(
          ValidationFailure('You must be signed in to update your photo.'),
        ),
      );
    }
    if (photoUrl.isEmpty) {
      return Future<Result<User>>.value(
        const ResultFailure<User>(
          ValidationFailure('The selected photo could not be read.'),
        ),
      );
    }
    return _repository.updateProfilePhoto(userId: userId, photoUrl: photoUrl);
  }
}
