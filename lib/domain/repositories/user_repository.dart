import '../../core/result/result.dart';
import '../entities/community_member.dart';
import '../entities/user.dart';

/// Authentication + profile contract.
///
/// Implemented by `UserRepositoryImpl`; consumed by the authentication use
/// cases, by `ProfileCubit` and by the post use cases (to stamp the author).
abstract interface class UserRepository {
  /// Emits the signed-in member (or `null`) whenever the session changes.
  Stream<User?> authStateChanges();

  /// Restores the persisted session once, at start-up.
  Future<Result<User?>> restoreSession();

  /// Email + password sign in.
  Future<Result<User>> signIn({
    required String email,
    required String password,
  });

  /// Creates a new account. [deviceModel] / [osVersion] are captured by
  /// `GetDeviceInfo` and stored on the profile document.
  Future<Result<User>> signUp({
    required String fullName,
    required String email,
    required String password,
    String? deviceModel,
    String? osVersion,
  });

  /// Ends the session and clears the persisted token.
  Future<Result<void>> signOut();

  /// Sends a password-reset email to the given address.
  Future<Result<void>> sendPasswordResetEmail({
    required String email,
  });

  /// Replaces the profile picture with a base64 `data:` URL.
  Future<Result<User>> updateProfilePhoto({
    required String userId,
    required String photoUrl,
  });

  /// Replaces the display name.
  Future<Result<User>> updateDisplayName({
    required String userId,
    required String fullName,
  });

  /// Reads a single profile (used by the post cards to resolve authors).
  Future<Result<User?>> getUserById(String userId);

  /// Writes the cached user so the app opens instantly on the next launch.
  Future<Result<void>> cacheUser(User? user);

  /// Members plotted on the Community Map screen.
  Future<Result<List<CommunityMember>>> getCommunityMembers();
}
