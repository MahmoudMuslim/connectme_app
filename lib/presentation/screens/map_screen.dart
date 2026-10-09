import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/community_member.dart';
import '../../domain/usecases/get_community_members.dart';
import '../../injection.dart';
import '../widgets/error_view.dart';
import '../widgets/member_marker.dart';

/// **Community Map**.
///
/// Requirement 4: "Create a Map Screen with the title 'Community Map' in the
/// AppBar. Display a full-screen Google Map widget. Place a marker for at least
/// three hardcoded member locations across different cities. Tapping a marker
/// must show an info window with the member's name and city."
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  /// Handed over by `GoogleMap.onMapCreated` on the first frame.
  GoogleMapController? _mapController;

  List<CommunityMember> _members = const <CommunityMember>[];
  bool _isLoading = true;
  String? _errorMessage;
  MarkerId? _openMarkerId;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final Result<List<CommunityMember>> result =
        await getIt<GetCommunityMembers>()();
    if (!mounted) {
      return;
    }
    result.fold(
      onSuccess: (List<CommunityMember> members) {
        setState(() {
          _members = members;
          _isLoading = false;
        });
        // The roster usually resolves *after* `onMapCreated` (Firestore is
        // asynchronous), so frame the markers here too, not only at creation.
        _frameMarkers();
      },
      onFailure: (Object failure) => setState(() {
        _errorMessage = failure is Failure
            ? failure.message
            : 'We could not load the community map.';
        _isLoading = false;
      }),
    );
  }

  /// Opens the info window programmatically when a pin is tapped, which is the
  /// behaviour the requirement asks for.
  void _onMarkerTapped(MarkerId markerId) {
    _mapController?.showMarkerInfoWindow(markerId);
    setState(() => _openMarkerId = markerId);
  }

  /// Captures the controller handed over by the map on its first frame.
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _frameMarkers();
  }

  /// Moves the camera so every plotted member is visible.
  void _frameMarkers() {
    final GoogleMapController? controller = _mapController;
    if (controller == null || _members.isEmpty) {
      return;
    }
    controller.moveCamera(
      CameraUpdate.newLatLngBounds(
        _boundsOf(_members),
        _isCompactViewport() ? 90 : 140,
      ),
    );
  }

  bool _isCompactViewport() =>
      MediaQuery.sizeOf(context).width < 600 ||
      MediaQuery.sizeOf(context).height < 700;

  LatLngBounds _boundsOf(List<CommunityMember> members) {
    final double minLat = members
        .map((CommunityMember member) => member.latitude)
        .reduce((double a, double b) => a < b ? a : b);
    final double maxLat = members
        .map((CommunityMember member) => member.latitude)
        .reduce((double a, double b) => a > b ? a : b);
    final double minLng = members
        .map((CommunityMember member) => member.longitude)
        .reduce((double a, double b) => a < b ? a : b);
    final double maxLng = members
        .map((CommunityMember member) => member.longitude)
        .reduce((double a, double b) => a > b ? a : b);
    return LatLngBounds(
      southwest: LatLng(minLat - 4, minLng - 4),
      northeast: LatLng(maxLat + 4, maxLng + 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        title: const Text('Community Map'),
        actions: <Widget>[
          IconButton(
            onPressed: _loadMembers,
            tooltip: 'Refresh members',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryDark),
      );
    }
    if (_errorMessage != null) {
      return ErrorView(message: _errorMessage!, onRetry: _loadMembers);
    }

    return Stack(
      children: <Widget>[
        // Full-screen map widget, exactly as required.
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(20, 60),
              zoom: 1.4,
            ),
            onMapCreated: _onMapCreated,
            markers: MemberMarker.fromMembers(_members, onTap: _onMarkerTapped),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
          ),
        ),
        _MembersLegend(
          members: _members,
          activeMarkerId: _openMarkerId,
          onSelect: (CommunityMember member) {
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(member.latitude, member.longitude),
                4.5,
              ),
            );
            _onMarkerTapped(MarkerId(member.id));
          },
        ),
      ],
    );
  }
}

/// Bottom sheet listing every plotted member, tappable to focus the camera.
class _MembersLegend extends StatelessWidget {
  const _MembersLegend({
    required this.members,
    required this.activeMarkerId,
    required this.onSelect,
  });

  final List<CommunityMember> members;
  final MarkerId? activeMarkerId;

  /// Invoked when a row of the legend is tapped.
  final ValueChanged<CommunityMember> onSelect;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: DraggableScrollableSheet(
        initialChildSize: 0.28,
        minChildSize: 0.16,
        maxChildSize: 0.6,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            // `ListTile` paints its selection colour and ink splashes on the
            // nearest `Material`, so the sheet has to provide one.
            child: Material(
              color: AppColors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: members.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (BuildContext context, int index) {
                  final CommunityMember member = members[index];
                  final bool isActive = activeMarkerId?.value == member.id;
                  return ListTile(
                    onTap: () => onSelect(member),
                    selected: isActive,
                    selectedTileColor: AppColors.accentTint,
                    leading: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primaryDark,
                    ),
                    title: Text(
                      member.infoWindowTitle,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      member.interest,
                      style: AppTypography.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      member.country,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
