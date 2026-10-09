import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../models/post_model.dart';

/// `SharedPreferences` backed store for the cached posts.
///
/// Both post data sources share it, so a remote read and an offline read always
/// see the exact same payload and there is a single place to change the
/// persistence format.
class PostCacheStore {
  PostCacheStore(this.preferences);

  final SharedPreferences preferences;

  /// Broadcasts the cached payload to whoever is watching the feed offline.
  final StreamController<List<PostModel>> _updates =
      StreamController<List<PostModel>>.broadcast();

  /// Reads and decodes the cached posts, returning an empty list when the cache
  /// is empty or corrupted.
  List<PostModel> read() {
    final String raw = preferences.getString(AppConstants.cachedPostsKey) ?? '';
    if (raw.isEmpty) {
      return <PostModel>[];
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(PostModel.fromJson)
          .toList();
    } on Object {
      return <PostModel>[];
    }
  }

  /// Encodes and stores [posts], then notifies the cache listeners.
  Future<void> write(List<PostModel> posts) async {
    final List<Map<String, dynamic>> encoded = posts
        .map((PostModel post) => post.toJson())
        .toList();
    await preferences.setString(
      AppConstants.cachedPostsKey,
      jsonEncode(encoded),
    );
    if (!_updates.isClosed) {
      _updates.add(posts);
    }
  }

  /// Appends a single post, newest first.
  Future<void> append(PostModel post) async {
    final List<PostModel> current = read();
    current.removeWhere((PostModel item) => item.id == post.id);
    current.insert(0, post);
    await write(current);
  }

  /// Removes a post by id.
  Future<void> remove(String postId) async {
    final List<PostModel> current = read()
      ..removeWhere((PostModel item) => item.id == postId);
    await write(current);
  }

  /// Emits the cached payload immediately and on every later write.
  Stream<List<PostModel>> watch() async* {
    yield read();
    yield* _updates.stream;
  }

  /// Releases the broadcast stream.
  Future<void> dispose() => _updates.close();

  /// Fills the cache with a believable community feed the first time the app is
  /// opened without Firebase, so the demo build never shows an empty screen.
  Future<void> seedIfEmpty() async {
    if (read().isNotEmpty) {
      return;
    }
    await write(_seedPosts());
  }

  /// The demo roster used when no backend is reachable.
  static List<PostModel> demoSeed() => _seedPosts();

  static List<PostModel> _seedPosts() {
    final DateTime now = DateTime.now();
    final Random random = Random(7);
    return <PostModel>[
      PostModel.forNewPost(
        id: 'seed-1',
        authorId: 'seed-bruno',
        authorName: 'Bruno Pham',
        content:
            'Just wrapped the ConnectMe beta build. The biometric gate on the '
            'profile screen feels instant on a Pixel 8. Screenshots coming soon!',
        createdAt: now.subtract(const Duration(minutes: 42)),
      ),
      PostModel.forNewPost(
        id: 'seed-2',
        authorId: 'seed-amira',
        authorName: 'Amira Hassan',
        content:
            'Cairo chapter is hosting an open source sprint this Friday. '
            'Bring a laptop, we will review pull requests together.',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      PostModel.forNewPost(
        id: 'seed-3',
        authorId: 'seed-thanh',
        authorName: 'Thanh Pham',
        content:
            'Reminder: Firestore rules are now deployed on the community '
            'project. Reads stay public, writes require authentication.',
        createdAt: now.subtract(const Duration(hours: 7)),
      ),
      PostModel.forNewPost(
        id: 'seed-4',
        authorId: 'seed-lucas',
        authorName: 'Lucas Ferreira',
        content:
            'Clean Architecture pays off: swapping Firestore for a local cache '
            'was a 3 line change thanks to the repository factory.',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      PostModel.forNewPost(
        id: 'seed-5',
        authorId: 'seed-yuki',
        authorName: 'Yuki Tanaka',
        content:
            'Tokyo chapter, we translated the onboarding flow. The pill shaped '
            'fields match the design system perfectly.',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      PostModel(
        id: 'seed-6',
        authorId: 'seed-bruno',
        authorName: 'Bruno Pham',
        content:
            'Anyone else loving the 60dp gradient FAB? It reads as a button.',
        createdAt: now.subtract(const Duration(days: 4)),
        likeCount: 18 + random.nextInt(9),
        commentCount: 4 + random.nextInt(5),
      ),
    ];
  }
}
