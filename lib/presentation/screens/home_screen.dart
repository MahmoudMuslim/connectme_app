import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../injection.dart';
import '../blocs/donation/donation_cubit.dart';
import '../blocs/post/post_cubit.dart';
import '../blocs/profile/profile_cubit.dart';
import '../widgets/home_bottom_navigation.dart';
import '../widgets/profile_gate.dart';
import 'create_post_screen.dart';
import 'donations_screen.dart';
import 'feed_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';

/// Home shell hosting the five-slot bottom navigation of the Figma design.
///
/// The three cubits are provided **above** the tab switcher so every tab can
/// reach the one it needs (the feed uses `ProfileCubit` to run the biometric
/// gate, for instance) and each cubit is disposed with the shell.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeTab _currentTab = HomeTab.feed;

  PostCubit? _postCubit;
  ProfileCubit? _profileCubit;
  DonationCubit? _donationCubit;

  @override
  void dispose() {
    _postCubit?.close();
    _profileCubit?.close();
    _donationCubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<PostCubit>.value(value: _post()),
        BlocProvider<ProfileCubit>.value(value: _profile()),
        BlocProvider<DonationCubit>.value(value: _donations()),
      ],
      child: Builder(
        builder: (BuildContext innerContext) {
          return Scaffold(
            backgroundColor: AppColors.screenBackground,
            extendBody: true,
            body: SafeArea(bottom: false, child: _buildBody()),
            bottomNavigationBar: HomeBottomNavigation(
              current: _currentTab,
              onTabSelected: (HomeTab tab) => _onTabSelected(innerContext, tab),
              onFabPressed: _openComposer,
            ),
          );
        },
      ),
    );
  }

  PostCubit _post() {
    return _postCubit ??= getIt<PostCubit>()
      ..listen(currentUserId: ProfileGate.currentUser(context).id);
  }

  ProfileCubit _profile() {
    return _profileCubit ??= getIt<ProfileCubit>()
      ..load(ProfileGate.currentUser(context));
  }

  DonationCubit _donations() {
    return _donationCubit ??= getIt<DonationCubit>()
      ..listen()
      ..loadTotalRaised();
  }

  Widget _buildBody() {
    return switch (_currentTab) {
      HomeTab.feed => FeedScreen(onOpenProfile: _showProfile),
      HomeTab.map => const MapScreen(),
      HomeTab.donations => const DonationsScreen(),
      HomeTab.profile => const ProfileScreen(),
    };
  }

  /// Every entry point to the profile goes through the biometric gate.
  Future<void> _onTabSelected(BuildContext innerContext, HomeTab tab) async {
    if (tab == HomeTab.profile && !await ProfileGate.authenticate(innerContext)) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _currentTab = tab);
  }

  /// Revealed by [FeedScreen] once its own biometric challenge succeeded.
  void _showProfile() {
    if (mounted) {
      setState(() => _currentTab = HomeTab.profile);
    }
  }

  Future<void> _openComposer() async {
    // The composer is pushed as a sibling route, so it needs the feed cubit
    // re-provided: the providers live below the Navigator.
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext routeContext) => BlocProvider<PostCubit>.value(
          value: _post(),
          child: const CreatePostScreen(),
        ),
      ),
    );
  }
}
