import 'package:connectme_app/core/errors/failures.dart';
import 'package:connectme_app/core/result/result.dart';
import 'package:connectme_app/domain/entities/post.dart';
import 'package:connectme_app/domain/repositories/post_repository.dart';
import 'package:connectme_app/domain/usecases/create_post.dart';
import 'package:connectme_app/domain/usecases/delete_post.dart';
import 'package:connectme_app/domain/usecases/get_posts.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory [PostRepository] used by every test in this file.
class FakePostRepository implements PostRepository {
  FakePostRepository({this.initialPosts = const <Post>[]});

  List<Post> initialPosts;

  final List<Post> createdPosts = <Post>[];
  final List<String> deletedIds = <String>[];

  bool failOnCreate = false;

  @override
  Future<Result<Post>> createPost(Post post) async {
    if (failOnCreate) {
      return ResultFailure<Post>(const FirestoreFailure('write failed'));
    }
    final Post stored = post.copyWith(id: 'generated-id');
    createdPosts.add(stored);
    return Success<Post>(stored);
  }

  @override
  Future<Result<void>> deletePost(String postId) async {
    deletedIds.add(postId);
    return const Success<void>(null);
  }

  @override
  Future<Result<List<Post>>> getCachedPosts() async =>
      Success<List<Post>>(initialPosts);

  @override
  Future<Result<List<Post>>> getPosts({int limit = 25}) async =>
      Success<List<Post>>(initialPosts.take(limit).toList());

  @override
  Future<Result<void>> cachePosts(List<Post> posts) async =>
      const Success<void>(null);

  @override
  Stream<Result<List<Post>>> watchPosts({
    FeedFilter filter = FeedFilter.popular,
    String? authorId,
    String searchQuery = '',
  }) => Stream<Result<List<Post>>>.value(Success<List<Post>>(initialPosts));
}

Post _post({
  String id = 'p1',
  String authorId = 'u1',
  String content = 'hello',
  int likeCount = 0,
  int commentCount = 0,
  DateTime? createdAt,
}) {
  return Post(
    id: id,
    authorId: authorId,
    authorName: 'Bruno Pham',
    content: content,
    createdAt: createdAt ?? DateTime.utc(2026, 3, 1),
    likeCount: likeCount,
    commentCount: commentCount,
  );
}

void main() {
  group('CreatePost', () {
    test('rejects empty content without touching the repository', () async {
      final FakePostRepository repository = FakePostRepository();
      final Result<Post> result = await CreatePost(repository)(
        authorId: 'u1',
        authorName: 'Bruno Pham',
        content: '   ',
      );

      expect(result.isSuccess, isFalse);
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(repository.createdPosts, isEmpty);
    });

    test('rejects content longer than the limit', () async {
      final FakePostRepository repository = FakePostRepository();
      final Result<Post> result = await CreatePost(repository)(
        authorId: 'u1',
        authorName: 'Bruno Pham',
        content: 'a' * 300,
      );

      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(repository.createdPosts, isEmpty);
    });

    test('rejects an anonymous author', () async {
      final FakePostRepository repository = FakePostRepository();
      final Result<Post> result = await CreatePost(repository)(
        authorId: '',
        authorName: 'Bruno Pham',
        content: 'hello',
      );

      expect(result.failureOrNull, isA<ValidationFailure>());
    });

    test('trims the content and delegates to the repository', () async {
      final FakePostRepository repository = FakePostRepository();
      final Result<Post> result = await CreatePost(repository)(
        authorId: 'u1',
        authorName: 'Bruno Pham',
        content: '  spaced out  ',
      );

      expect(result.isSuccess, isTrue);
      expect(repository.createdPosts.single.content, 'spaced out');
      expect(repository.createdPosts.single.id, 'generated-id');
    });

    test('propagates a repository failure', () async {
      final FakePostRepository repository = FakePostRepository()
        ..failOnCreate = true;
      final Result<Post> result = await CreatePost(repository)(
        authorId: 'u1',
        authorName: 'Bruno Pham',
        content: 'hello',
      );

      expect(result.failureOrNull, isA<FirestoreFailure>());
    });
  });

  group('DeletePost', () {
    test('rejects an empty id', () async {
      final FakePostRepository repository = FakePostRepository();
      final Result<void> result = await DeletePost(repository)('');

      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(repository.deletedIds, isEmpty);
    });

    test('deletes a valid id', () async {
      final FakePostRepository repository = FakePostRepository();
      final Result<void> result = await DeletePost(repository)('p1');

      expect(result.isSuccess, isTrue);
      expect(repository.deletedIds, <String>['p1']);
    });
  });

  group('GetPosts', () {
    test('streams the posts exposed by the repository', () async {
      final FakePostRepository repository = FakePostRepository(
        initialPosts: <Post>[
          _post(),
          _post(id: 'p2'),
        ],
      );

      final List<List<Post>> emissions = await GetPosts(
        repository,
      )().map((Result<List<Post>> result) => result.valueOrNull!).toList();

      expect(emissions.single.length, 2);
    });

    test('once() applies the requested limit', () async {
      final FakePostRepository repository = FakePostRepository(
        initialPosts: <Post>[
          _post(id: 'p1'),
          _post(id: 'p2'),
          _post(id: 'p3'),
        ],
      );

      final Result<List<Post>> result = await GetPosts(repository)
          .once(limit: 2);

      expect(result.valueOrNull!.length, 2);
    });
  });

  group('Post.toggledLike', () {
    test('increments the counter when liking', () {
      final Post post = _post(likeCount: 4);
      final Post liked = post.toggledLike();

      expect(liked.isLikedByCurrentUser, isTrue);
      expect(liked.likeCount, 5);
    });

    test('decrements the counter when unliking', () {
      final Post post = _post(likeCount: 4).toggledLike();
      final Post unliked = post.toggledLike();

      expect(unliked.isLikedByCurrentUser, isFalse);
      expect(unliked.likeCount, 4);
    });

    test('never drops the counter below zero', () {
      final Post post = _post(likeCount: 0).toggledLike().toggledLike();

      expect(post.likeCount, 0);
    });
  });
}
