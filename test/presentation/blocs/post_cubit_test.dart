import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connectme_app/core/errors/failures.dart';
import 'package:connectme_app/data/datasources/post_cache_store.dart';
import 'package:connectme_app/data/datasources/post_datasource.dart';
import 'package:connectme_app/data/models/post_model.dart';
import 'package:connectme_app/data/repositories/post_repository_impl.dart';
import 'package:connectme_app/domain/entities/post.dart';
import 'package:connectme_app/domain/usecases/create_post.dart';
import 'package:connectme_app/domain/usecases/delete_post.dart';
import 'package:connectme_app/domain/usecases/get_posts.dart';
import 'package:connectme_app/presentation/blocs/post/post_cubit.dart';
import 'package:connectme_app/presentation/blocs/post/post_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fake data source so [PostCubit] can be tested without Firebase.
class FakePostDataSource implements PostDataSource {
  FakePostDataSource(this.posts);

  List<PostModel> posts;
  bool throwOnFetch = false;

  final StreamController<List<PostModel>> _controller =
      StreamController<List<PostModel>>.broadcast();

  void emit(List<PostModel> value) {
    posts = value;
    _controller.add(value);
  }

  @override
  String get sourceName => 'Fake source';

  @override
  bool get isRemote => false;

  @override
  Future<void> removePost(String postId) async {
    posts = posts.where((PostModel p) => p.id != postId).toList();
    emit(posts);
  }

  @override
  Future<List<PostModel>> fetchPosts({int limit = 25}) async {
    if (throwOnFetch) {
      throw const FirestoreFailure('network down');
    }
    return posts;
  }

  @override
  Future<PostModel> insertPost(PostModel post) async {
    emit(<PostModel>[post, ...posts]);
    return post;
  }

  @override
  Future<List<PostModel>> readCache() async => posts;

  @override
  Future<void> saveToCache(List<PostModel> posts) async {
    this.posts = posts;
  }

  @override
  Stream<List<PostModel>> watchCache() => watchPosts();

  /// Emits the current list on every subscription, then forwards mutations.
  @override
  Stream<List<PostModel>> watchPosts({int limit = 25}) {
    return Stream<List<PostModel>>.multi((
      MultiStreamController<List<PostModel>> controller,
    ) {
      controller.add(posts);
      final StreamSubscription<List<PostModel>> subscription = _controller
          .stream
          .listen(controller.add, onError: controller.addError);
      controller.onCancel = subscription.cancel;
    });
  }

  Future<void> dispose() => _controller.close();
}

PostModel _model(String id, {int likeCount = 0, int commentCount = 0}) {
  return PostModel(
    id: id,
    authorId: 'u1',
    authorName: 'Bruno Pham',
    content: 'post $id',
    createdAt: DateTime.utc(2026, 3, 1),
    likeCount: likeCount,
    commentCount: commentCount,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePostDataSource dataSource;
  late PostCacheStore cacheStore;
  late PostRepositoryImpl repository;
  late PostCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    dataSource = FakePostDataSource(<PostModel>[_model('p1')]);
    cacheStore = PostCacheStore(await SharedPreferences.getInstance());
    repository = PostRepositoryImpl.withDataSource(dataSource, cacheStore);
    cubit = PostCubit(
      getPosts: GetPosts(repository),
      createPost: CreatePost(repository),
      deletePost: DeletePost(repository),
      postRepository: repository,
    );
  });

  tearDown(() async {
    await cubit.close();
    await dataSource.dispose();
    await cacheStore.dispose();
  });

  test('starts in the loading state', () {
    expect(cubit.state.status, PostStatus.loading);
  });

  test('exposes the active data source name from the factory decision', () {
    expect(cubit.state.sourceName, 'Fake source');
    expect(cubit.state.isRemote, isFalse);
  });

  test('listen() emits loading then loaded with the posts', () async {
    final List<PostState> states = <PostState>[];
    final StreamSubscription<PostState> subscription = cubit.stream.listen(
      states.add,
    );
    dataSource.posts = <PostModel>[_model('p1'), _model('p2')];

    cubit.listen();
    await Future<void>.delayed(Duration.zero);

    expect(states.first.status, PostStatus.loading);
    expect(states.last.status, PostStatus.loaded);
    expect(states.last.posts.length, 2);
    await subscription.cancel();
  });

  test('changeFilter() switches the tab and resets to loading', () async {
    cubit.listen();
    cubit.changeFilter(FeedFilter.trending);
    expect(cubit.state.filter, FeedFilter.trending);
    expect(cubit.state.status, PostStatus.loading);
  });

  test('changeFilter() is a no-op when the filter is unchanged', () async {
    cubit.listen();
    cubit.changeFilter(FeedFilter.popular);
    // The state must not have flipped to loading a second time.
    expect(cubit.state.filter, FeedFilter.popular);
  });

  test('publish() returns true and resets isSubmitting', () async {
    cubit.listen();
    await Future<void>.delayed(Duration.zero);

    final bool published = await cubit.publish(
      authorId: 'u1',
      authorName: 'Bruno Pham',
      content: 'new post',
    );

    expect(published, isTrue);
    expect(cubit.state.isSubmitting, isFalse);
    expect(dataSource.posts.first.content, 'new post');
  });

  test('publish() surfaces the validation message and returns false', () async {
    cubit.listen();

    final bool published = await cubit.publish(
      authorId: 'u1',
      authorName: 'Bruno Pham',
      content: '',
    );

    expect(published, isFalse);
    expect(cubit.state.errorMessage, contains('Write something'));
    expect(cubit.state.isSubmitting, isFalse);
  });

  test('remove() deletes through the data source', () async {
    cubit.listen();
    await Future<void>.delayed(Duration.zero);
    dataSource.posts = <PostModel>[_model('p1'), _model('p2')];
    dataSource.emit(dataSource.posts);
    await Future<void>.delayed(Duration.zero);

    final bool removed = await cubit.remove('p1');

    expect(removed, isTrue);
    expect(dataSource.posts.single.id, 'p2');
  });

  test('toggleLike() updates the counter optimistically', () async {
    cubit.listen();
    await Future<void>.delayed(Duration.zero);
    dataSource.emit(<PostModel>[_model('p1', likeCount: 3)]);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.posts.first.likeCount, 3);
    final Post target = cubit.state.posts.first;
    cubit.toggleLike(target);

    expect(cubit.state.posts.first.likeCount, 4);
    expect(cubit.state.posts.first.isLikedByCurrentUser, isTrue);
  });

  blocTest<PostCubit, PostState>(
    'clearError() removes the message',
    build: () => cubit,
    seed: () => cubit.state.copyWith(errorMessage: 'boom'),
    act: (PostCubit bloc) => bloc.clearError(),
    expect: () => <PostState>[cubit.state.copyWith(clearError: true)],
  );
}
