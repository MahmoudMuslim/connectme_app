/// Application-wide constants: Firestore collection paths, local storage keys,
/// validation limits and the hardcoded community roster shown on the map.
class AppConstants {
  const AppConstants._();

  // --- Firestore -------------------------------------------------------------

  /// Collection holding the user profile documents.
  static const String usersCollection = 'users';

  /// Collection holding the community posts.
  static const String postsCollection = 'posts';

  /// Sub-collection holding the donation receipts of a user.
  static const String donationsCollection = 'donations';

  // --- Firestore document fields --------------------------------------------
  /// Primary key of a `users` document.
  static const String usersIdField = 'id';

  static const String fullNameField = 'fullName';
  static const String emailField = 'email';
  static const String photoUrlField = 'photoUrl';
  static const String deviceModelField = 'deviceModel';
  static const String osVersionField = 'osVersion';
  static const String contentField = 'content';
  static const String createdAtField = 'createdAt';
  static const String authorIdField = 'authorId';
  static const String likeCountField = 'likeCount';
  static const String commentCountField = 'commentCount';
  static const String imageUrlField = 'imageUrl';
  static const String amountField = 'amount';
  static const String currencyField = 'currency';
  static const String messageField = 'message';
  static const String transactionIdField = 'transactionId';
  static const String donorNameField = 'donorName';

  // --- Local (SharedPreferences) keys ---------------------------------------
  static const String cachedPostsKey = 'cached_posts';
  static const String cachedMembersKey = 'cached_members';
  static const String localAccountsKey = 'local_accounts';
  static const String localSessionKey = 'local_session';
  static const String cachedDonationsKey = 'cached_donations';

  // --- Validation ------------------------------------------------------------
  static const int minPasswordLength = 6;
  static const int maxPostLength = 280;
  static const int minNameLength = 3;
  static const int maxNameLength = 40;

  // --- Profile photo ---------------------------------------------------------
  /// Profile photos are stored inside Firestore as a base64 data URL, therefore
  /// they are downscaled to fit inside this square before being encoded.
  static const int profilePhotoMaxDimension = 512;

  /// Firestore rejects documents larger than ~1 MiB; the base64 payload of a
  /// [profilePhotoMaxDimension] JPEG stays well below that ceiling.
  static const int maxProfilePhotoBytes = 400 * 1024;

  // --- Donations -------------------------------------------------------------
  // NOTE: `maxDonationAmount` mirrors `DemoPaymentGateway.maxAmountPerCharge`
  // so the form never accepts an amount the sandbox would then decline.
  static const double minDonationAmount = 1;
  static const double maxDonationAmount = 2500;
  static const String defaultCurrency = 'USD';

  // --- Pagination / caching --------------------------------------------------
  static const int feedPageSize = 25;
}
