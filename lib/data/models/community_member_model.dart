import 'dart:convert';

import '../../domain/entities/community_member.dart';

/// JSON representation of [CommunityMember].
///
/// The seeded roster shipped with the app is cached as JSON so the map renders
/// instantly, offline and in tests.
class CommunityMemberModel extends CommunityMember {
  const CommunityMemberModel({
    required super.id,
    required super.name,
    required super.city,
    required super.country,
    required super.latitude,
    required super.longitude,
    super.interest,
    super.avatarUrl,
  });

  /// Rebuilds a member from a Firestore snapshot or from the local cache.
  factory CommunityMemberModel.fromJson(Map<String, dynamic> json) {
    return CommunityMemberModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Community member',
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      interest: json['interest'] as String? ?? 'Community member',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  /// Serialises the member for the cache and for Firestore.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'city': city,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
    'interest': interest,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
  };

  /// Builds a member without going through JSON.
  factory CommunityMemberModel.fromEntity(CommunityMember member) {
    return CommunityMemberModel(
      id: member.id,
      name: member.name,
      city: member.city,
      country: member.country,
      latitude: member.latitude,
      longitude: member.longitude,
      interest: member.interest,
      avatarUrl: member.avatarUrl,
    );
  }

  /// Deserialises a cached roster, falling back to the seed on any decode error.
  static List<CommunityMemberModel> listFromCacheJson(String raw) {
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      if (decoded.isEmpty) {
        return seeded;
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(CommunityMemberModel.fromJson)
          .toList();
    } on Object {
      return seeded;
    }
  }

  /// Encodes the seeded roster for the cache.
  static String seededJson() => jsonEncode(
    seeded.map((CommunityMemberModel member) => member.toJson()).toList(),
  );

  /// The roster rendered on the map before any backend call succeeds.
  ///
  /// Five members spread across five different cities, as required by the brief
  /// ("at least three hardcoded member locations across different cities").
  static List<CommunityMemberModel> get seeded => <CommunityMemberModel>[
    const CommunityMemberModel(
      id: 'seed-bruno',
      name: 'Bruno Pham',
      city: 'Da Nang',
      country: 'Vietnam',
      latitude: 16.0544,
      longitude: 108.2022,
      interest: 'Runs the Da Nang Flutter meet-up',
    ),
    const CommunityMemberModel(
      id: 'seed-thanh',
      name: 'Thanh Pham',
      city: 'Ho Chi Minh City',
      country: 'Vietnam',
      latitude: 10.8231,
      longitude: 106.6297,
      interest: 'Backend engineer, loves Firestore rules',
    ),
    const CommunityMemberModel(
      id: 'seed-amira',
      name: 'Amira Hassan',
      city: 'Cairo',
      country: 'Egypt',
      latitude: 30.0444,
      longitude: 31.2357,
      interest: 'Community lead and event organiser',
    ),
    const CommunityMemberModel(
      id: 'seed-lucas',
      name: 'Lucas Ferreira',
      city: 'Sao Paulo',
      country: 'Brazil',
      latitude: -23.5505,
      longitude: -46.6333,
      interest: 'Builds the ConnectMe beta releases',
    ),
    const CommunityMemberModel(
      id: 'seed-yuki',
      name: 'Yuki Tanaka',
      city: 'Tokyo',
      country: 'Japan',
      latitude: 35.6762,
      longitude: 139.6503,
      interest: 'Design systems and motion',
    ),
  ];

  static double _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }
}
