import 'dart:async';

import '../models/post_model.dart';

/// In-memory store for cached posts (offline support during session).
///
/// Both post data sources share it, so a remote read and an offline read always
/// see the exact same payload and there is a single place to change the
/// persistence format.
class PostCacheStore {
  PostCacheStore();

  final List<PostModel> _posts = <PostModel>[];

  /// Broadcasts the cached payload to whoever is watching the feed offline.
  final StreamController<List<PostModel>> _updates =
      StreamController<List<PostModel>>.broadcast();

  /// Reads the cached posts.
  List<PostModel> read() => List<PostModel>.from(_posts);

  /// Stores [posts], then notifies the cache listeners.
  Future<void> write(List<PostModel> posts) async {
    _posts
      ..clear()
      ..addAll(posts);
    if (!_updates.isClosed) {
      _updates.add(read());
    }
  }

  /// Appends a single post, newest first.
  Future<void> append(PostModel post) async {
    _posts.removeWhere((PostModel item) => item.id == post.id);
    _posts.insert(0, post);
    if (!_updates.isClosed) {
      _updates.add(read());
    }
  }

  /// Removes a post by id.
  Future<void> remove(String postId) async {
    _posts.removeWhere((PostModel item) => item.id == postId);
    if (!_updates.isClosed) {
      _updates.add(read());
    }
  }

  /// Emits the cached payload immediately and on every later write.
  Stream<List<PostModel>> watch() async* {
    yield read();
    yield* _updates.stream;
  }

  /// Releases the broadcast stream.
  Future<void> dispose() => _updates.close();
}