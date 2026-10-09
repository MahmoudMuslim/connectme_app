import 'package:equatable/equatable.dart';

import '../../../domain/entities/post.dart';

/// Status axis of [PostCubit] — the three states required by the brief:
/// "manage the loading, loaded and error states of the feed".
enum PostStatus {
  /// First load in progress — the skeleton is visible.
  loading,

  /// The feed is rendered.
  loaded,

  /// The feed failed and [PostState.errorMessage] holds the reason.
  error,
}

/// Immutable state of [PostCubit].
class PostState extends Equatable {
  const PostState({
    this.status = PostStatus.loading,
    this.posts = const <Post>[],
    this.filter = FeedFilter.popular,
    this.errorMessage,
    this.isSubmitting = false,
    this.sourceName = '',
    this.isRemote = false,
  });

  final PostStatus status;

  /// The rendered feed, already filtered by [filter].
  final List<Post> posts;

  /// Active segmented-control tab.
  final FeedFilter filter;

  /// User friendly error, already decoded by the repository layer.
  final String? errorMessage;

  /// `true` while a new post is being written.
  final bool isSubmitting;

  /// Name of the active data source, e.g. "Cloud Firestore".
  final String sourceName;

  /// `true` when the feed is served by Firestore rather than the local cache.
  final bool isRemote;

  bool get isEmpty => status == PostStatus.loaded && posts.isEmpty;

  PostState copyWith({
    PostStatus? status,
    List<Post>? posts,
    FeedFilter? filter,
    String? errorMessage,
    bool? isSubmitting,
    String? sourceName,
    bool? isRemote,
    bool clearError = false,
  }) {
    return PostState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      filter: filter ?? this.filter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      sourceName: sourceName ?? this.sourceName,
      isRemote: isRemote ?? this.isRemote,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    posts,
    filter,
    errorMessage,
    isSubmitting,
    sourceName,
    isRemote,
  ];
}
