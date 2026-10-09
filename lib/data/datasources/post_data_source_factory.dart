import '../../services/firestore_service.dart';
import 'firestore_post_datasource.dart';
import 'local_post_datasource.dart';
import 'post_cache_store.dart';
import 'post_datasource.dart';

/// **FACTORY PATTERN**
///
/// Requirement 2 & 5: "The PostRepository must follow the Factory Pattern to
/// instantiate the correct data source (remote Firestore vs. local cache)."
///
/// The repository never decides *which* backend it talks to: it asks this
/// factory, which encapsulates the creation logic and hides the concrete
/// classes behind the [PostDataSource] interface. Adding a third backend (an
/// HTTP API, a Room database) only means writing a new [PostDataSource] and one
/// extra branch here — nothing else in the app changes (Open/Closed).
class PostDataSourceFactory {
  PostDataSourceFactory({required this.firestoreService});

  final FirestoreService firestoreService;

  /// Builds the data source matching [preference].
  ///
  /// * [DataSourcePreference.auto] / [DataSourcePreference.remote] — Firestore
  /// * [DataSourcePreference.local] — local cache (for unit tests only)
  Future<PostDataSource> create({
    DataSourcePreference preference = DataSourcePreference.auto,
  }) async {
    final PostDataSource dataSource = switch (preference) {
      DataSourcePreference.remote => _createRemote(),
      DataSourcePreference.local => _createLocal(),
      DataSourcePreference.auto => _createRemote(),
    };
    return dataSource;
  }

  /// The cache store used by the remote data source for offline support.
  PostCacheStore get cacheStore => PostCacheStore();

  PostDataSource _createRemote() => FirestorePostDataSource(
        firestoreService: firestoreService,
        cacheStore: cacheStore,
      );

  PostDataSource _createLocal() => LocalPostDataSource(cacheStore: cacheStore);
}

/// Explicit selection strategy accepted by [PostDataSourceFactory.create].
enum DataSourcePreference {
  /// Pick the best available source (the production behaviour).
  auto,

  /// Always use Cloud Firestore.
  remote,

  /// Always use the on-device cache (unit tests only).
  local,
}