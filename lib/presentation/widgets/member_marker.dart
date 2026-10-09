import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/community_member.dart';

/// Factory turning a [CommunityMember] into a Google Maps [Marker].
///
/// Requirement 4: "Place a marker for at least three hardcoded member
/// locations across different cities. Tapping a marker must show an info window
/// with the member's name and city."
///
/// Keeping the conversion here guarantees every marker is styled identically and
/// that the info window always carries the member's name and city.
class MemberMarker {
  const MemberMarker._();

  /// Brand indigo hue applied to the default Google pin.
  static const double brandHue = BitmapDescriptor.hueViolet;

  /// Builds the marker for [member].
  ///
  /// [onTap] receives the marker id so the screen can programmatically open the
  /// info window when the pin is tapped.
  static Marker fromMember(
    CommunityMember member, {
    void Function(MarkerId markerId)? onTap,
  }) {
    final MarkerId markerId = MarkerId(member.id);
    return Marker(
      markerId: markerId,
      position: LatLng(member.latitude, member.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(brandHue),
      infoWindow: InfoWindow(title: member.name, snippet: member.city),
      onTap: () => onTap?.call(markerId),
    );
  }

  /// Builds every marker of the roster at once.
  static Set<Marker> fromMembers(
    List<CommunityMember> members, {
    void Function(MarkerId markerId)? onTap,
  }) {
    return members
        .map((CommunityMember member) => fromMember(member, onTap: onTap))
        .toSet();
  }
}
