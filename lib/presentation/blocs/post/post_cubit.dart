import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../core/errors/firebase_error_mapper.dart';
import '../../../core/result/result.dart';
import '../../../data/repositories/post_repository_impl.dart';
import '../../../domain/entities/post.dart';
import '../../../domain/usecases/create_post.dart';
import '../../../domain/usecases/delete_post.dart';
import '../../../domain/usecases/get_posts.dart';
import 'post_state.dart';

/// **CUBIT** owning the community feed.
///
/// Requirement 2: "Use a PostCubit to manage the loading, loaded and error
/// states of the feed."
///
/// The cubit subscribes to [GetPosts], which returns a live Firestore stream
/// (or the local cache stream in demo mode). Switching tab cancels the previous
/// subscription, so only one listener is ever attached.
class PostCubit extends Cubit<PostState> {
  PostCubit({
    required this.getPosts,
    required this.createPost,
    required this.deletePost,
    required this.postRepository,
  }) : super(
           PostState(
             sourceName: postRepository.activeSourceName,
             isRemote: postRepository.isRemote,
           ),
         );

  /// Live feed stream.
  final GetPosts getPosts;

  /// Write path for a new post.
  final CreatePost createPost;

  /// Write path for removing a post.
  final DeletePost deletePost;

  /// Used to read the "which data source?" metadata for the UI badge.
  final PostRepositoryImpl postRepository;

  StreamSubscription<Result<List<Post>>>? _subscription;

  /// Uid of the signed-in member, used by the `Following` tab.
  String? _currentUserId;

  /// Current search query (empty = no search filter).
  String _searchQuery = '';

  /// Attaches to the feed. Safe to call again: the previous stream is closed.
  void listen({String? currentUserId}) {
    _currentUserId = currentUserId;
    _subscription?.cancel();
    emit(state.copyWith(status: PostStatus.loading, clearError: true));
    _subscription = getPosts(
      filter: state.filter,
      authorId: _currentUserId,
      searchQuery: _searchQuery,
    ).listen(_onFeed, onError: _onError);
  }

  /// Switches the segmented-control tab and re-subscribes.
  void changeFilter(FeedFilter filter) {
    if (filter == state.filter) {
      return;
    }
    emit(state.copyWith(filter: filter, status: PostStatus.loading));
    listen(currentUserId: _currentUserId);
  }

  /// Updates the search query and re-fetches the feed.
  void changeSearchQuery(String query) {
    final String trimmed = query.trim();
    if (trimmed == _searchQuery) {
      return;
    }
    _searchQuery = trimmed;
    emit(state.copyWith(status: PostStatus.loading));
    listen(currentUserId: _currentUserId);
  }

  /// Clears the search query.
  void clearSearch() {
    if (_searchQuery.isEmpty) {
      return;
    }
    _searchQuery = '';
    emit(state.copyWith(status: PostStatus.loading));
    listen(currentUserId: _currentUserId);
  }

  /// Pull-to-refresh: a single read that also repopulates the cache.
  Future<void> refresh() async {
    final Result<List<Post>> result = await getPosts.once();
    if (isClosed) {
      return;
    }
    result.fold(
      onSuccess: (List<Post> posts) => emit(
        state.copyWith(
          status: PostStatus.loaded,
          posts: posts,
          clearError: true,
        ),
      ),
      onFailure: _onError,
    );
  }

  /// Publishes a new post.
  ///
  /// Returns `true` on success so the composer sheet can close itself.
  Future<bool> publish({
    required String authorId,
    required String authorName,
    required String content,
    String? authorPhotoUrl,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final Result<Post> result = await createPost(
      authorId: authorId,
      authorName: authorName,
      content: content,
      authorPhotoUrl: authorPhotoUrl,
    );
    if (isClosed) {
      return false;
    }
    return result.fold(
      onSuccess: (_) {
        emit(state.copyWith(isSubmitting: false));
        return true;
      },
      onFailure: (Object failure) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: _messageOf(failure),
          ),
        );
        return false;
      },
    );
  }

  /// Optimistically toggles the like state of [post].
  ///
  /// The counter is updated immediately so the UI feels instant; Firestore is not
  /// touched because v1 keeps likes client-side (the state survives a refresh via
  /// the cached feed).
  void toggleLike(Post post) {
    final int index = state.posts.indexWhere((Post item) => item.id == post.id);
    if (index == -1 || isClosed) {
      return;
    }
    final List<Post> updated = List<Post>.of(state.posts);
    updated[index] = post.toggledLike();
    emit(state.copyWith(posts: updated));
  }

  /// Removes one of the member's posts.
  Future<bool> remove(String postId) async {
    final Result<void> result = await deletePost(postId);
    if (isClosed) {
      return false;
    }
    return result.fold(
      onSuccess: (_) => true,
      onFailure: (Object failure) {
        emit(state.copyWith(errorMessage: _messageOf(failure)));
        return false;
      },
    );
  }

  /// Clears the last error (used before reopening the composer).
  void clearError() {
    if (state.errorMessage == null || isClosed) {
      return;
    }
    emit(state.copyWith(clearError: true));
  }

  void _onFeed(Result<List<Post>> result) {
    if (isClosed) {
      return;
    }
    result.fold(
      onSuccess: (List<Post> posts) => emit(
        state.copyWith(
          status: PostStatus.loaded,
          posts: posts,
          clearError: true,
        ),
      ),
      onFailure: _onError,
    );
  }

  void _onError(Object error) {
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(status: PostStatus.error, errorMessage: _messageOf(error)),
    );
  }

  String _messageOf(Object failure) {
    if (failure is Failure) {
      return failure.message;
    }
    return FirebaseErrorMapper.messageOf(failure);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
