import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../blocs/auth/auth_cubit.dart';
import '../blocs/auth/auth_state.dart';

/// Brand splash shown while [AuthCubit.bootstrap] restores the persisted
/// session.
///
/// Reproduces the Figma splash frame: the vertical brand gradient (dark bottom →
/// light top), a 40 % indigo veil and the `WELCOME` headline. Once the session
/// is known the widget replaces itself with either the home shell or the login
/// screen, which is how requirement 1 ("skip the login screen on app restart")
/// is implemented.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          previous.status != current.status,
      listener: (BuildContext context, AuthState state) => _redirect(state),
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (BuildContext context, AuthState state) {
          // Handle the case where the session was already restored before the
          // listener was attached.
          WidgetsBinding.instance.addPostFrameCallback((_) => _redirect(state));
          return const _SplashView();
        },
      ),
    );
  }

  void _redirect(AuthState state) {
    if (_hasNavigated || state.status == AuthStatus.unknown) {
      return;
    }
    if (state.status == AuthStatus.authenticating) {
      return;
    }
    _hasNavigated = true;
    final String route = state.isAuthenticated
        ? AppRoutes.home
        : AppRoutes.login;
    Navigator.of(context).pushReplacementNamed(route);
  }
}

/// Purely visual part of the splash screen.
class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: <Widget>[
            // 40 % brand veil, as in the Figma frame.
            Positioned.fill(
              child: Container(
                color: AppColors.primaryDark.withValues(alpha: 0.4),
              ),
            ),
            // Rotated gradient card that "emerges" from the bottom.
            Positioned(
              left: MediaQuery.sizeOf(context).width * 0.38,
              top: MediaQuery.sizeOf(context).height * 0.30,
              child: Transform.rotate(
                angle: 0.78,
                child: Container(
                  width: 136,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment(1.03, -0.02),
                      end: Alignment(0, 1),
                      colors: <Color>[AppColors.primaryDark, Color(0x005151C6)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'WELCOME',
                      textAlign: TextAlign.center,
                      style: AppTypography.hero.copyWith(
                        fontSize: 40 * MediaQuery.sizeOf(context).width / 375,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Connect with your community',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 48,
              child: Center(
                child: SizedBox.square(
                  dimension: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
