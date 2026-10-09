import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../repositories/post_repository.dart';

/// Removes one of the current member's posts.
class DeletePost {
  const DeletePost(this._repository);

  final PostRepository _repository;

  Future<Result<void>> call(String postId) {
    if (postId.isEmpty) {
      return Future<Result<void>>.value(
        const ResultFailure<void>(
          ValidationFailure('The post identifier is missing.'),
        ),
      );
    }
    return _repository.deletePost(postId);
  }
}
