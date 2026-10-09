import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/errors/failures.dart';
import '../../core/errors/firebase_error_mapper.dart';
import '../../core/result/result.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../../services/firestore_service.dart';
import '../datasources/post_cache_store.dart';
import '../datasources/post_data_source_factory.dart';
import '../datasources/post_datasource.dart';
import '../models/post_model.dart';

/// Post repository backed by the data source chosen by the **FACTORY PATTERN**.
///
/// `injection.dart` calls [PostRepositoryImpl.create], which delegates the
/// choice between "Cloud Firestore" and "on-device cache" to
/// `PostDataSourceFactory`. The repository itself is agnostic: it only knows the
/// [PostDataSource] contract, and transparently degrades to the cache when the
/// remote stream fails so the feed is never blank.
class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl._({required this.dataSource, required this.cacheStore});

  /// Creates the repository with the Firestore data source.
  static Future<PostRepositoryImpl> create({
    required FirestoreService firestoreService,
    DataSourcePreference preference = DataSourcePreference.auto,
  }) async {
    final PostDataSourceFactory factory = PostDataSourceFactory(
      firestoreService: firestoreService,
    );
    final PostCacheStore cacheStore = factory.cacheStore;
    return PostRepositoryImpl._(
      dataSource: await factory.create(preference: preference),
      cacheStore: cacheStore,
    );
  }

  /// Test seam: injects a ready-made data source.
  @visibleForTesting
  factory PostRepositoryImpl.withDataSource(
    PostDataSource dataSource,
    PostCacheStore cacheStore,
  ) {
    return PostRepositoryImpl._(dataSource: dataSource, cacheStore: cacheStore);
  }

  /// The data source chosen by the factory.
  final PostDataSource dataSource;

  /// Offline cache, always available even when the remote source fails.
  final PostCacheStore cacheStore;

  /// Human readable name of the active source, shown in the debug banner.
  String get activeSourceName => dataSource.sourceName;

  /// `true` when the feed is served by Cloud Firestore.
  bool get isRemote => dataSource.isRemote;

@override
  Stream<Result<List<Post>>> watchPosts({
    FeedFilter filter = FeedFilter.popular,
    String? authorId,
    String searchQuery = '',
  }) {
    // A plain transformer (rather than an `async*` generator) keeps the stream
    // trivially cancellable, which matters because the cubit re-subscribes on
    // every tab change and on close.
    return dataSource.watchPosts().transform(
      StreamTransformer<List<PostModel>, Result<List<Post>>>.fromHandlers(
        handleData:
            (List<PostModel> posts, EventSink<Result<List<Post>>> sink) {
          sink.add(
            Success<List<Post>>(
              applyFilter(posts, filter, authorId, searchQuery),
            ),
          );
        },
        handleError:
            (
              Object error,
              StackTrace stackTrace,
              EventSink<Result<List<Post>>> sink,
            ) {
              // A failing remote stream degrades gracefully into the cache so the
              // feed is never blank.
              final List<PostModel> cached = cacheStore.read();
              sink.add(
                cached.isEmpty
                    ? ResultFailure<List<Post>>(FirebaseErrorMapper.map(error))
                    : Success<List<Post>>(
                        applyFilter(cached, filter, authorId, searchQuery),
                      ),
              );
            },
      ),
    );
  }

  @override
  Future<Result<List<Post>>> getPosts({int limit = 25}) async {
    try {
      final List<PostModel> posts = await dataSource.fetchPosts(limit: limit);
      // With a reachable backend an empty collection is a legitimate answer:
      // serving the cache here would resurrect the demo seed roster as if it
      // were real community content.
      if (posts.isEmpty && dataSource.isRemote) {
        return const Success<List<Post>>(<Post>[]);
      }
      return Success<List<Post>>(posts.isEmpty ? cacheStore.read() : posts);
    } on Object catch (error) {
      final List<PostModel> cached = cacheStore.read();
      if (cached.isNotEmpty) {
        return Success<List<Post>>(cached);
      }
      return ResultFailure<List<Post>>(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<Result<Post>> createPost(Post post) async {
    try {
      final PostModel stored = await dataSource.insertPost(
        PostModel.fromEntity(post),
      );
      await cacheStore.append(stored);
      return Success<Post>(stored);
    } on ValidationException catch (error) {
      return ResultFailure<Post>(ValidationFailure(error.message));
    } on Object catch (error) {
      return ResultFailure<Post>(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<Result<void>> deletePost(String postId) async {
    try {
      await dataSource.removePost(postId);
      await cacheStore.remove(postId);
      return const Success<void>(null);
    } on Object catch (error) {
      return ResultFailure<void>(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<Result<void>> cachePosts(List<Post> posts) async {
    try {
      await cacheStore.write(posts.map(PostModel.fromEntity).toList());
      return const Success<void>(null);
    } on Object catch (error) {
      return ResultFailure<void>(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<Result<List<Post>>> getCachedPosts() async {
    try {
      return Success<List<Post>>(cacheStore.read());
    } on Object catch (error) {
      return ResultFailure<List<Post>>(FirebaseErrorMapper.map(error));
    }
  }

  /// Applies the active tab filter and optional search query.
  /// `Popular` is newest-first, `Trending` is sorted by engagement and `Following`
  /// restricts the feed to the member.
  List<Post> applyFilter(
    List<PostModel> posts,
    FeedFilter filter,
    String? authorId,
    String searchQuery,
  ) {
    final List<PostModel> result = List<PostModel>.of(posts);

    // Apply search filter first (case-insensitive content match)
    if (searchQuery.isNotEmpty) {
      final String lowerQuery = searchQuery.toLowerCase();
      result.removeWhere(
        (PostModel post) => !post.content.toLowerCase().contains(lowerQuery),
      );
    }

    switch (filter) {
      case FeedFilter.popular:
        result.sort(
          (PostModel a, PostModel b) => b.createdAt.compareTo(a.createdAt),
        );
      case FeedFilter.trending:
        result.sort((PostModel a, PostModel b) {
          final int byLikes = b.likeCount.compareTo(a.likeCount);
          return byLikes != 0
              ? byLikes
              : b.commentCount.compareTo(a.commentCount);
        });
      case FeedFilter.following:
        if (authorId != null && authorId.isNotEmpty) {
          result.removeWhere((PostModel post) => post.authorId != authorId);
        }
        result.sort(
          (PostModel a, PostModel b) => b.createdAt.compareTo(a.createdAt),
        );
    }
    return result;
  }
}
