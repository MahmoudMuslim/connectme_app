import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart';
import '../blocs/auth/auth_cubit.dart';
import '../blocs/profile/profile_cubit.dart';
import '../blocs/profile/profile_state.dart';
import 'connectme_snack_bar.dart';

/// The biometric gate protecting the profile screen.
///
/// Requirement 3: "Tapping it must trigger biometric fingerprint
/// authentication before navigating to the Profile Screen."
///
/// The gate is a single reusable entry point: every place that wants to reveal
/// the profile (the feed app-bar icon, the bottom navigation, a deep link)
/// calls [ProfileGate.authenticate], so the verification rules and the
/// user-facing messages are implemented only once.
abstract final class ProfileGate {
  const ProfileGate._();

  /// Runs the native biometric challenge.
  ///
  /// Returns `true` when the profile may be shown. Devices without an enrolled
  /// sensor are let through with an explanatory message, because blocking the
  /// screen entirely would make the feature untestable on an emulator.
  static Future<bool> authenticate(
    BuildContext context, {
    ProfileCubit? cubit,
  }) async {
    final ProfileCubit profileCubit = cubit ?? context.read<ProfileCubit>();
    final bool authenticated = await profileCubit.authenticate(
      reason: 'Verify your identity to open your ConnectMe profile',
    );
    if (!context.mounted) {
      return authenticated;
    }

    final String? notice = profileCubit.state.errorMessage;
    if (!authenticated) {
      if (notice != null) {
        ConnectMeSnackBar.showError(context, notice);
      }
      return false;
    }
    if (notice != null) {
      ConnectMeSnackBar.showInfo(context, notice);
    }
    return true;
  }

  /// Convenience helper returning the member currently signed in.
  static User currentUser(BuildContext context) {
    return context.read<AuthCubit>().state.user ??
        const User(id: '', fullName: 'Community member', email: '');
  }
}

/// App-bar profile glyph that fires [ProfileGate.authenticate].
class ProfileGateButton extends StatelessWidget {
  const ProfileGateButton({required this.onPressed, super.key});

  /// Invoked once the member has been verified.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: 'My profile',
      icon: const Icon(Icons.person_rounded, size: 26),
    );
  }
}

/// Icon shown inside the profile gate dialog.
IconData biometricIconFor(ProfileState state) =>
    state.biometricLabel == 'Face ID'
    ? Icons.face_rounded
    : Icons.fingerprint_rounded;
