/// Named routes used by the application router.
///
/// Keeping them in a single place prevents typos and makes navigation
/// discoverable while reviewing the codebase.
class AppRoutes {
  const AppRoutes._();

  /// Shown while the persisted authentication session is restored.
  static const String splash = '/';

  /// Email + password sign in.
  static const String login = '/login';

  /// Registration form.
  static const String signUp = '/sign-up';

  /// The shell hosting the bottom navigation bar.
  static const String home = '/home';

  /// Community feed tab (also reachable directly for deep links).
  static const String feed = '/home/feed';

  /// Google Maps tab.
  static const String map = '/home/map';

  /// Donations tab.
  static const String donations = '/home/donations';

  /// Profile tab, reachable **only** after a successful biometric challenge.
  static const String profile = '/home/profile';

  /// Modal sheet used to compose a new post.
  static const String createPost = '/create-post';
}
