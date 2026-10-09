import '../../core/constants/app_constants.dart';
import '../../domain/entities/post.dart';

/// Firestore/JSON representation of [Post].
///
/// Implements the "clean `fromJson` / `toJson` factory constructor"
/// requirement and keeps the denormalised author fields so the feed renders
/// without a second read.
class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.authorId,
    required super.authorName,
    required super.content,
    required super.createdAt,
    super.authorPhotoUrl,
    super.likeCount,
    super.commentCount,
    super.isLikedByCurrentUser,
  });

  /// Rebuilds a model from a Firestore snapshot.
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String? ?? '',
      authorId: json[AppConstants.authorIdField] as String? ?? '',
      authorName: json['authorName'] as String? ?? 'Community member',
      content: json[AppConstants.contentField] as String? ?? '',
      createdAt: _toDate(json[AppConstants.createdAtField]),
      authorPhotoUrl: json['authorPhotoUrl'] as String?,
      likeCount: _toInt(json[AppConstants.likeCountField]),
      commentCount: _toInt(json[AppConstants.commentCountField]),
      isLikedByCurrentUser: json['isLiked'] as bool? ?? false,
    );
  }

  /// Serialises the model for `Firestore.set` and for the local cache.
  /// `createdAt` is serialised as an ISO-8601 **string** here so the model stays
  /// dependency free and directly reusable by the local cache.
  ///
  /// Cloud Firestore needs a native `Timestamp` for `orderBy` to sort
  /// chronologically, so [FirestorePostDataSource] converts at the boundary.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    AppConstants.authorIdField: authorId,
    'authorName': authorName,
    AppConstants.contentField: content,
    AppConstants.createdAtField: createdAt.toIso8601String(),
    if (authorPhotoUrl != null) 'authorPhotoUrl': authorPhotoUrl,
    AppConstants.likeCountField: likeCount,
    AppConstants.commentCountField: commentCount,
  };

  /// Converts a domain entity into its serialisable model.
  factory PostModel.fromEntity(Post post) {
    return PostModel(
      id: post.id,
      authorId: post.authorId,
      authorName: post.authorName,
      content: post.content,
      createdAt: post.createdAt,
      authorPhotoUrl: post.authorPhotoUrl,
      likeCount: post.likeCount,
      commentCount: post.commentCount,
      isLikedByCurrentUser: post.isLikedByCurrentUser,
    );
  }

  /// Builds the model written to Firestore when a member publishes a post.
  factory PostModel.forNewPost({
    required String id,
    required String authorId,
    required String authorName,
    required String content,
    String? authorPhotoUrl,
    DateTime? createdAt,
  }) {
    return PostModel(
      id: id,
      authorId: authorId,
      authorName: authorName,
      content: content,
      createdAt: createdAt ?? DateTime.now(),
      authorPhotoUrl: authorPhotoUrl,
    );
  }

  static DateTime _toDate(Object? value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static int _toInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
