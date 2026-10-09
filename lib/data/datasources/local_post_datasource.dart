import '../../core/constants/app_constants.dart';
import '../models/post_model.dart';
import 'post_cache_store.dart';
import 'post_datasource.dart';

/// **LOCAL** post data source: the offline cache.
///
/// Selected by `PostDataSourceFactory` when Firebase could not be started, so
/// the beta build still behaves like a real social feed (create, like and
/// delete all mutate the cache and are immediately reflected in the UI).
class LocalPostDataSource implements PostDataSource {
  LocalPostDataSource({required this.cacheStore});

  /// Shared with the remote source so both agree on the payload.
  final PostCacheStore cacheStore;

  @override
  String get sourceName => 'On-device cache';

  @override
  bool get isRemote => false;

  @override
  Stream<List<PostModel>> watchPosts({int limit = AppConstants.feedPageSize}) {
    return cacheStore.watch().map(
      (List<PostModel> posts) => posts.take(limit).toList(growable: false),
    );
  }

  @override
  Future<List<PostModel>> fetchPosts({
    int limit = AppConstants.feedPageSize,
  }) async {
    return cacheStore.read().take(limit).toList(growable: false);
  }

  @override
  Future<PostModel> insertPost(PostModel post) async {
    final PostModel stored = PostModel.forNewPost(
      id: post.id.isEmpty ? _generateId() : post.id,
      authorId: post.authorId,
      authorName: post.authorName,
      content: post.content,
      authorPhotoUrl: post.authorPhotoUrl,
      createdAt: post.createdAt,
    );
    await cacheStore.append(stored);
    return stored;
  }

  @override
  Future<void> removePost(String postId) => cacheStore.remove(postId);

  @override
  Future<void> saveToCache(List<PostModel> posts) => cacheStore.write(posts);

  @override
  Future<List<PostModel>> readCache() async => cacheStore.read();

  @override
  Stream<List<PostModel>> watchCache() => cacheStore.watch();

  String _generateId() => 'local-${DateTime.now().microsecondsSinceEpoch}';
}
