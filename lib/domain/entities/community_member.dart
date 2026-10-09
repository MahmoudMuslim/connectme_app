import 'package:equatable/equatable.dart';

/// A community member plotted on the "Community Map" screen.
class CommunityMember extends Equatable {
  const CommunityMember({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.interest = 'Community member',
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String city;
  final String country;
  final double latitude;
  final double longitude;

  /// Short pitch displayed in the marker info window.
  final String interest;

  final String? avatarUrl;

  /// `name, city` — exactly the two fields required by the info window.
  String get infoWindowTitle => '$name, $city';

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    city,
    country,
    latitude,
    longitude,
    interest,
    avatarUrl,
  ];
}
