import '../models/post_model.dart';

/// Contract every post data source must honour.
///
/// Two implementations exist:
/// * `FirestorePostDataSource` — the remote, real-time source.
/// * `LocalPostDataSource` — the `SharedPreferences` cache used offline.
///
/// `PostDataSourceFactory` picks one of them at start-up (**Factory Pattern**).
abstract interface class PostDataSource {
  /// Short identifier surfaced in the debug banner and in the logs.
  String get sourceName;

  /// `true` for the remote Firestore implementation.
  bool get isRemote;

  /// Real-time stream of posts ordered by publication date (newest first).
  Stream<List<PostModel>> watchPosts({int limit});

  /// One-shot read.
  Future<List<PostModel>> fetchPosts({int limit});

  /// Inserts [post] and returns the stored model (with its generated id).
  Future<PostModel> insertPost(PostModel post);

  /// Deletes the post identified by [postId].
  Future<void> removePost(String postId);

  /// Replaces the locally cached payload after a successful remote read.
  Future<void> saveToCache(List<PostModel> posts);

  /// Reads the cached payload; returns an empty list when nothing is cached.
  Future<List<PostModel>> readCache();

  /// Publishes the newest cached payload on [watchPosts] so the UI can be
  /// subscribed even when the remote source is unavailable.
  Stream<List<PostModel>> watchCache();
}
