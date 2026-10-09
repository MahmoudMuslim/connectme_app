import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../../core/utils/validators.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

/// Creates a community post.
///
/// The use case is the single authority for the *business* rules of a post
/// (who may publish, how long the text may be). It never touches Firebase,
/// which keeps the rule testable in isolation — see
/// `test/domain/usecases/create_post_test.dart`.
class CreatePost {
  const CreatePost(this._repository);

  final PostRepository _repository;

  Future<Result<Post>> call({
    required String authorId,
    required String authorName,
    required String content,
    String? authorPhotoUrl,
  }) {
    final String? contentError = Validators.postContent(
      content,
      maxLength: AppConstants.maxPostLength,
    );
    if (contentError != null) {
      return Future<Result<Post>>.value(
        ResultFailure<Post>(ValidationFailure(contentError)),
      );
    }
    if (authorId.isEmpty) {
      return Future<Result<Post>>.value(
        const ResultFailure<Post>(
          ValidationFailure('You must be signed in to publish a post.'),
        ),
      );
    }

    final Post post = Post(
      id: '',
      authorId: authorId,
      authorName: authorName.trim(),
      authorPhotoUrl: authorPhotoUrl,
      content: content.trim(),
      createdAt: DateTime.now(),
    );
    return _repository.createPost(post);
  }
}
