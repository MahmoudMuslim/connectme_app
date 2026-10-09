import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/time_formatter.dart';
import '../../domain/entities/user.dart';
import '../blocs/auth/auth_cubit.dart';
import '../blocs/profile/profile_cubit.dart';
import '../blocs/profile/profile_state.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/connectme_snack_bar.dart';
import '../widgets/device_info_card.dart';
import '../widgets/error_view.dart';
import '../widgets/profile_header.dart';

/// Profile screen, always reached through the biometric gate.
///
/// Requirement 3: it displays the profile picture, full name, email, the device
/// model / OS version captured with `device_info_plus`, and a button that picks
/// a new photo from the gallery and uploads it to Firestore.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (ProfileState previous, ProfileState current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null,
        listener: (BuildContext context, ProfileState state) {
          ConnectMeSnackBar.showError(context, state.errorMessage!);
          context.read<ProfileCubit>().clearError();
        },
        builder: (BuildContext context, ProfileState state) {
          final User? user = state.user ?? context.read<AuthCubit>().state.user;
          if (user == null) {
            return ErrorView(
              message: 'We could not load your profile.',
              onRetry: () => context.read<AuthCubit>().bootstrap(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ProfileCubit>().load(user),
            color: AppColors.primaryDark,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Responsive.constrainContent(
                context,
                child: Column(
                  children: <Widget>[
                    ProfileHeader(user: user),
                    _ProfileInfoCard(user: user),
                    const SizedBox(height: AppSpacing.md),
                    DeviceInfoCard(
                      deviceInfo: state.deviceInfo,
                      isLoading: state.status == ProfileStatus.loading,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                      ),
                      // The Figma profile frame ends with a gradient "Donate"
                      // pill next to an outlined "Message" pill; for *my*
                      // profile the same layout hosts "Update photo" and
                      // "Sign out".
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: AppPrimaryButton(
                              label: 'Update photo',
                              icon: Icons.photo_camera_outlined,
                              isLoading: state.isUpdatingPhoto,
                              onPressed: _changePhoto,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppSecondaryButton(
                              label: 'Sign out',
                              icon: Icons.logout_rounded,
                              onPressed: _signOut,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _changePhoto() async {
    final bool uploaded = await context
        .read<ProfileCubit>()
        .pickAndUploadPhoto();
    if (uploaded && mounted) {
      ConnectMeSnackBar.showSuccess(context, 'Your profile photo was updated.');
    }
  }

  Future<void> _signOut() async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: const Text('Sign out of ConnectMe?'),
            content: const Text(
              'You will need your email and password to sign back in.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) {
      return;
    }
    final authCubit = context.read<AuthCubit>();
    final navigator = Navigator.of(context);
    await authCubit.signOut();
    navigator.pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }
}

/// Name, handle, email and membership date.
class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            user.fullName,
            style: AppTypography.displayName,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Center(
            child: Text(
              user.email,
              style: AppTypography.body.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
          if (user.joinedAt != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xxs),
            Center(
              child: Text(
                'Member since ${TimeFormatter.absolute(user.joinedAt!)}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
