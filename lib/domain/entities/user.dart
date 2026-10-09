import 'package:equatable/equatable.dart';

/// Pure domain representation of a ConnectMe member.
///
/// Domain entities stay free of any Firebase / `json_serializable` concern:
/// serialisation lives in `data/models/user_model.dart`.
class User extends Equatable {
  const User({
    required this.id,
    required this.fullName,
    required this.email,
    this.photoUrl,
    this.deviceModel,
    this.osVersion,
    this.joinedAt,
  });

  /// Firebase Auth uid (or the locally generated id in demo mode).
  final String id;

  /// Display name. Always stored with a capital first letter.
  final String fullName;

  /// Verified email address.
  final String email;

  /// `data:` URL (or remote URL) of the profile picture, `null` when unset.
  final String? photoUrl;

  /// Device model captured at sign-up time via `device_info_plus`.
  final String? deviceModel;

  /// Operating system version captured at sign-up time.
  final String? osVersion;

  /// Account creation timestamp.
  final DateTime? joinedAt;

  /// Up to two letters used by the avatar placeholder.
  String get initials {
    final List<String> parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  /// Display name without the last name, used as the app-bar handle
  /// (`@brunopham` in the Figma profile screen).
  String get handle {
    final List<String> parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '@member';
    }
    return '@${parts.last.toLowerCase()}';
  }

  /// `true` once the member picked a profile picture.
  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;

  @override
  List<Object?> get props => <Object?>[
    id,
    fullName,
    email,
    photoUrl,
    deviceModel,
    osVersion,
    joinedAt,
  ];
}
