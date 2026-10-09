import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../../services/firestore_service.dart';
import '../models/post_model.dart';
import 'post_cache_store.dart';
import 'post_datasource.dart';

/// **REMOTE** post data source backed by Cloud Firestore.
///
/// Requirement 2: "Display a scrollable feed of community posts fetched in real
/// time from Cloud Firestore."
///
/// Every emission is mirrored into the local cache, which is what makes the feed
/// available offline.
class FirestorePostDataSource implements PostDataSource {
  FirestorePostDataSource({
    required this.firestoreService,
    required this.cacheStore,
  });

  /// Singleton injected by the factory.
  final FirestoreService firestoreService;

  /// Used to mirror every remote read into the offline cache.
  final PostCacheStore cacheStore;

  @override
  String get sourceName => 'Cloud Firestore';

  @override
  bool get isRemote => true;

  @override
  Stream<List<PostModel>> watchPosts({int limit = AppConstants.feedPageSize}) {
    try {
      return firestoreService.postsCollection
          .orderBy(AppConstants.createdAtField, descending: true)
          .limit(limit)
          .snapshots()
          .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
            final List<PostModel> posts = _toModels(snapshot.docs);
            unawaited(saveToCache(posts));
            return posts;
          });
    } on Object {
      // Any Firestore level problem is handled upstream by the repository,
      // which falls back to the local cache.
      return const Stream<List<PostModel>>.empty();
    }
  }

  @override
  Future<List<PostModel>> fetchPosts({
    int limit = AppConstants.feedPageSize,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await firestoreService
        .postsCollection
        .orderBy(AppConstants.createdAtField, descending: true)
        .limit(limit)
        .get();
    final List<PostModel> posts = _toModels(snapshot.docs);
    await saveToCache(posts);
    return posts;
  }

  @override
  Future<PostModel> insertPost(PostModel post) async {
    final DocumentReference<Map<String, dynamic>> reference = firestoreService
        .postsCollection
        .doc();
    final Map<String, dynamic> payload = post.toJson()..['id'] = reference.id;
    await reference.set(_toFirestore(payload));
    return PostModel.fromJson(payload);
  }

  @override
  Future<void> removePost(String postId) async {
    await firestoreService.postsCollection.doc(postId).delete();
  }

  @override
  Future<void> saveToCache(List<PostModel> posts) async {
    await cacheStore.write(posts);
  }

  @override
  Future<List<PostModel>> readCache() async => cacheStore.read();

  @override
  Stream<List<PostModel>> watchCache() => cacheStore.watch();

/// Builds the map sent to Cloud Firestore.
  ///
  /// `PostModel` serialises `createdAt` as an ISO-8601 string (so it can be
  /// reused by the local cache), but Firestore only orders **chronologically**
  /// on a native `Timestamp`. Writing the string instead makes
  /// `orderBy('createdAt')` sort lexicographically, which breaks the feed as
  /// soon as two members sit in different UTC offsets.
  Map<String, dynamic> _toFirestore(Map<String, dynamic> json) {
    final Object? createdAt = json[AppConstants.createdAtField];
    if (createdAt is String) {
      json[AppConstants.createdAtField] = Timestamp.fromDate(
        DateTime.tryParse(createdAt) ?? DateTime.now(),
      );
    } else if (createdAt is DateTime) {
      json[AppConstants.createdAtField] = Timestamp.fromDate(createdAt);
    }
    return json;
  }

  /// Inverse of [_toFirestore]: a native `Timestamp` becomes an ISO string so
  /// [PostModel.fromJson] can parse it. Without this the model would fall back
  /// to the epoch and every post would read "1 Jan 1970".
  Map<String, dynamic> _fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data();
    final Object? createdAt = data[AppConstants.createdAtField];
    return <String, dynamic>{
      'id': doc.id,
      ...data,
      if (createdAt is Timestamp)
        AppConstants.createdAtField: createdAt.toDate().toIso8601String(),
    };
  }

  List<PostModel> _toModels(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs.map((doc) => PostModel.fromJson(_fromFirestore(doc))).toList();
  }
}