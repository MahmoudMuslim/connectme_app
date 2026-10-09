import 'package:shared_preferences/shared_preferences.dart';

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
  PostDataSourceFactory({
    required this.firestoreService,
    required this.preferences,
  });

  final FirestoreService firestoreService;
  final SharedPreferences preferences;

  /// Builds the data source matching [preference].
  ///
  /// * [DataSourcePreference.auto] — Firestore when it initialised, cache
  ///   otherwise. This is what the app uses in production.
  /// * [DataSourcePreference.remote] — forces Firestore (integration tests).
  /// * [DataSourcePreference.local] — forces the cache (offline demos, unit
  ///   tests).
  ///
  /// When the local source is selected, the cache is seeded with the demo feed
  /// so a reviewer opening the beta build without credentials still sees a
  /// populated, interactive community.
  Future<PostDataSource> create({
    DataSourcePreference preference = DataSourcePreference.auto,
  }) async {
    final PostDataSource dataSource = switch (preference) {
      DataSourcePreference.remote => _createRemote(),
      DataSourcePreference.local => _createLocal(),
      DataSourcePreference.auto =>
        firestoreService.isReady ? _createRemote() : _createLocal(),
    };
    if (!dataSource.isRemote) {
      await cacheStore.seedIfEmpty();
    }
    return dataSource;
  }

  /// The cache store shared by both implementations.
  PostCacheStore get cacheStore => PostCacheStore(preferences);

  PostDataSource _createRemote() => FirestorePostDataSource(
    firestoreService: firestoreService,
    preferences: preferences,
  );

  PostDataSource _createLocal() => LocalPostDataSource(cacheStore: cacheStore);
}

/// Explicit selection strategy accepted by [PostDataSourceFactory.create].
enum DataSourcePreference {
  /// Pick the best available source (the production behaviour).
  auto,

  /// Always use Cloud Firestore.
  remote,

  /// Always use the on-device cache.
  local,
}
