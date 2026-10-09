import '../../core/result/result.dart';
import '../entities/post.dart';

/// Contract implemented by the data layer (Dependency Inversion Principle).
///
/// The domain — and therefore every use case and cubit — only knows this
/// interface, never `cloud_firestore` itself.
abstract interface class PostRepository {
  /// Real-time stream of community posts ordered by publication date.
  ///
  /// Falls back to the local cache when the device is offline.
  Stream<Result<List<Post>>> watchPosts({
    FeedFilter filter,
    String? authorId,
    String searchQuery,
  });

  /// One-shot read, used to hydrate the cache on cold start.
  Future<Result<List<Post>>> getPosts({int limit});

  /// Persists a new post and returns the stored entity (with its id).
  Future<Result<Post>> createPost(Post post);

  /// Removes a post previously created by the current member.
  Future<Result<void>> deletePost(String postId);

  /// Replaces the local cache, used by the data source after a successful read.
  Future<Result<void>> cachePosts(List<Post> posts);

  /// Reads the locally cached posts (offline first paint).
  Future<Result<List<Post>>> getCachedPosts();
}
