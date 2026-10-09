import 'package:equatable/equatable.dart';

/// A single community post rendered by [PostCard].
class Post extends Equatable {
  const Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.authorPhotoUrl,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLikedByCurrentUser = false,
  });

  /// Firestore document id.
  final String id;

  /// Uid of the member who published the post.
  final String authorId;

  /// Denormalised author name, so the feed renders without a second read.
  final String authorName;

  /// Body of the post (max 280 characters).
  final String content;

  /// Publication timestamp, ordered server-side by Firestore.
  final DateTime createdAt;

  /// Cached avatar of the author so the card renders offline too.
  final String? authorPhotoUrl;

  final int likeCount;
  final int commentCount;
  final bool isLikedByCurrentUser;

  Post copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? content,
    DateTime? createdAt,
    String? authorPhotoUrl,
    int? likeCount,
    int? commentCount,
    bool? isLikedByCurrentUser,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }

  /// Toggles the like state and keeps the counter consistent.
  Post toggledLike() {
    if (isLikedByCurrentUser) {
      return copyWith(
        isLikedByCurrentUser: false,
        likeCount: likeCount > 0 ? likeCount - 1 : 0,
      );
    }
    return copyWith(isLikedByCurrentUser: true, likeCount: likeCount + 1);
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    authorId,
    authorName,
    content,
    createdAt,
    authorPhotoUrl,
    likeCount,
    commentCount,
    isLikedByCurrentUser,
  ];
}

/// Feed filters exposed by the three tabs of the home screen
/// (`Popular`, `Trending`, `Following` in the Figma design).
enum FeedFilter {
  /// Newest first — the default tab.
  popular('Popular'),

  /// Most liked first.
  trending('Trending'),

  /// Only the posts written by the signed-in member.
  following('Following');

  const FeedFilter(this.label);

  /// Label rendered inside the segmented control.
  final String label;
}
