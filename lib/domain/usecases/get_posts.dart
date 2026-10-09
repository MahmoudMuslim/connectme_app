import '../../core/result/result.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

/// Streams the community feed in real time.
///
/// Single Responsibility: this class only *asks* for posts; it performs no
/// caching, no sorting and no error handling of its own — that is the
/// repository's job.
class GetPosts {
  const GetPosts(this._repository);

  final PostRepository _repository;

  /// Returns a broadcast-friendly stream that can be re-subscribed by the
  /// cubit whenever the selected [FeedFilter] or search query changes.
  Stream<Result<List<Post>>> call({
    FeedFilter filter = FeedFilter.popular,
    String? authorId,
    String searchQuery = '',
  }) {
    return _repository.watchPosts(
      filter: filter,
      authorId: authorId,
      searchQuery: searchQuery,
    );
  }

  /// One-shot variant used by the pull-to-refresh handler.
  Future<Result<List<Post>>> once({int limit = 25}) {
    return _repository.getPosts(limit: limit);
  }
}
