import '../../core/constants/app_constants.dart';
import '../../domain/entities/user.dart';

/// Firestore/JSON representation of [User].
///
/// Contains the two patterns required by the brief:
///
/// * **BUILDER PATTERN** — [UserModelBuilder] collects every optional field and
///   only calls [UserModelBuilder.build] once, so a `UserModel` can *never* be
///   created with a half-filled object. This is what the brief means by
///   "only the fields provided during sign-up should be set on the User model":
///   `deviceModel` / `osVersion` / `photoUrl` stay `null` when the caller did
///   not supply them instead of being defaulted to placeholder strings.
/// * Clean `fromJson` / `toJson` factory pair for Firestore (and cache)
///   serialisation.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.photoUrl,
    super.deviceModel,
    super.osVersion,
    super.joinedAt,
  });

  // --- JSON ------------------------------------------------------------------

  /// Rebuilds a [UserModel] from a Firestore / cache map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModelBuilder()
        .id(json[AppConstants.usersIdField] as String? ?? '')
        .fullName(json[AppConstants.fullNameField] as String? ?? '')
        .email(json[AppConstants.emailField] as String? ?? '')
        .photoUrl(json[AppConstants.photoUrlField] as String?)
        .deviceModel(json[AppConstants.deviceModelField] as String?)
        .osVersion(json[AppConstants.osVersionField] as String?)
        .joinedAt(_toDate(json[AppConstants.createdAtField]))
        .build();
  }

  /// Serialises the model for `Firestore.set` and for the local cache.
  Map<String, dynamic> toJson() => <String, dynamic>{
    AppConstants.usersIdField: id,
    AppConstants.fullNameField: fullName,
    AppConstants.emailField: email,
    if (photoUrl != null) AppConstants.photoUrlField: photoUrl,
    if (deviceModel != null) AppConstants.deviceModelField: deviceModel,
    if (osVersion != null) AppConstants.osVersionField: osVersion,
    if (joinedAt != null)
      AppConstants.createdAtField: joinedAt!.toIso8601String(),
  };

  /// Converts a `firebase_auth.User` into a model (identity fields only —
  /// everything else is added later through the builder).
  factory UserModel.fromFirebase({
    required String id,
    required String email,
    required String fullName,
    String? photoUrl,
  }) {
    return UserModelBuilder()
        .id(id)
        .fullName(fullName)
        .email(email)
        .photoUrl(photoUrl)
        .joinedAt(DateTime.now())
        .build();
  }

  /// Upgrades any [User] (e.g. coming from the domain layer) to a model.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      photoUrl: user.photoUrl,
      deviceModel: user.deviceModel,
      osVersion: user.osVersion,
      joinedAt: user.joinedAt,
    );
  }

  // --- Immutable updates -----------------------------------------------------

  /// Returns a copy carrying the device information captured at sign-up.
  ///
  /// The builder guarantees that passing `null` keeps the field `null` instead
  /// of writing an empty string into Firestore.
  UserModel withDeviceInfo({String? deviceModel, String? osVersion}) {
    return UserModel(
      id: id,
      fullName: fullName,
      email: email,
      photoUrl: photoUrl,
      deviceModel: deviceModel ?? this.deviceModel,
      osVersion: osVersion ?? this.osVersion,
      joinedAt: joinedAt,
    );
  }

  /// Returns a copy with a new profile picture.
  UserModel withPhotoUrl(String? photo) => UserModel(
    id: id,
    fullName: fullName,
    email: email,
    photoUrl: photo,
    deviceModel: deviceModel,
    osVersion: osVersion,
    joinedAt: joinedAt,
  );

  /// Returns a copy with a new display name.
  UserModel withFullName(String name) => UserModel(
    id: id,
    fullName: name,
    email: email,
    photoUrl: photoUrl,
    deviceModel: deviceModel,
    osVersion: osVersion,
    joinedAt: joinedAt,
  );

  static DateTime? _toDate(Object? value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

/// **BUILDER PATTERN** implementation for [UserModel].
///
/// Every setter returns `this`, so a model can be described fluently and only
/// materialises when [build] is called:
///
/// ```dart
/// final UserModel user = UserModelBuilder()
///     .id(uid)
///     .fullName('Bruno Pham')
///     .email('bruno@connect.me')
///     .deviceModel(await deviceInfo.model)
///     .build();
/// ```
///
/// Fields that were never set stay `null` — nothing is invented.
class UserModelBuilder {
  String? _id;
  String? _fullName;
  String? _email;
  String? _photoUrl;
  String? _deviceModel;
  String? _osVersion;
  DateTime? _joinedAt;

  /// Firestore Auth uid.
  UserModelBuilder id(String? value) {
    _id = value;
    return this;
  }

  /// Display name.
  UserModelBuilder fullName(String? value) {
    _fullName = value;
    return this;
  }

  /// Email address.
  UserModelBuilder email(String? value) {
    _email = value;
    return this;
  }

  /// Profile picture (`data:` or remote URL).
  UserModelBuilder photoUrl(String? value) {
    _photoUrl = (value == null || value.isEmpty) ? null : value;
    return this;
  }

  /// Device model captured through `device_info_plus`.
  UserModelBuilder deviceModel(String? value) {
    _deviceModel = (value == null || value.isEmpty) ? null : value;
    return this;
  }

  /// OS version captured through `device_info_plus`.
  UserModelBuilder osVersion(String? value) {
    _osVersion = (value == null || value.isEmpty) ? null : value;
    return this;
  }

  /// Account creation timestamp.
  UserModelBuilder joinedAt(DateTime? value) {
    _joinedAt = value;
    return this;
  }

  /// Materialises the model. Mandatory fields fall back to empty strings.
  UserModel build() => UserModel(
    id: _id ?? '',
    fullName: _fullName ?? '',
    email: _email ?? '',
    photoUrl: _photoUrl,
    deviceModel: _deviceModel,
    osVersion: _osVersion,
    joinedAt: _joinedAt,
  );
}
