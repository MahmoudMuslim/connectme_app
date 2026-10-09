import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/validators.dart';
import '../blocs/auth/auth_cubit.dart';
import '../blocs/auth/auth_state.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_header_collage.dart';
import '../widgets/connectme_snack_bar.dart';

/// Email + password sign in.
///
/// Requirement 1: the screen is connected to Firebase Authentication through
/// [AuthCubit]; failures are surfaced through `AuthState.errorMessage`, which is
/// already a user friendly sentence produced by `FirebaseErrorMapper`.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: <Widget>[
          // Dark header collage, 312 dp tall in the Figma frame.
          const Positioned(
            left: 0,
            top: 0,
            right: 0,
            height: 312,
            child: AuthHeaderCollage(height: 312),
          ),
          SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: MediaQuery.paddingOf(context).top + 88,
                    ),
                    child: Responsive.constrainContent(
                      context,
                      child: _LoginSheet(
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        obscurePassword: _obscurePassword,
                        onTogglePassword: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        onSubmit: _submit,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final BuildContext? validContext = _formKey.currentContext;
    if (validContext == null) {
      return;
    }
    FocusScope.of(validContext).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await context.read<AuthCubit>().signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }
}

/// White rounded sheet holding the credentials form.
class _LoginSheet extends StatelessWidget {
  const _LoginSheet({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final double margin = Responsive.horizontalMargin(context) + 10;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: margin),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.sheet),
        ),
      ),
      child: Form(
        key: formKey,
        child: BlocConsumer<AuthCubit, AuthState>(
          listenWhen: (AuthState previous, AuthState current) =>
              previous.errorMessage != current.errorMessage ||
              previous.successMessage != current.successMessage ||
              previous.status != current.status,
          listener: (BuildContext context, AuthState state) {
            // A successful sign-in replaces the login screen with the shell.
            if (state.isAuthenticated) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
              return;
            }
            final String? error = state.errorMessage;
            if (error != null) {
              ConnectMeSnackBar.showError(context, error);
              context.read<AuthCubit>().clearError();
              return;
            }
            final String? success = state.successMessage;
            if (success != null) {
              ConnectMeSnackBar.showSuccess(context, success);
              context.read<AuthCubit>().clearError(); // also clears success
            }
          },
          builder: (BuildContext context, AuthState state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppTextField(
                  controller: emailController,
                  hint: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.none,
                  validator: Validators.email,
                  onChanged: (_) => context.read<AuthCubit>().clearError(),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: passwordController,
                  hint: 'Password',
                  obscureText: obscurePassword,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  validator: Validators.password,
                  onChanged: (_) => context.read<AuthCubit>().clearError(),
                  onSubmitted: (_) => onSubmit(),
                  suffixIcon: IconButton(
                    onPressed: onTogglePassword,
                    tooltip: obscurePassword
                        ? 'Show password'
                        : 'Hide password',
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 22,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context
                        .read<AuthCubit>()
                        .sendPasswordReset(email: emailController.text),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      textStyle: AppTypography.overline.copyWith(
                        color: AppColors.link,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    child: const Text('FORGOT PASSWORD'),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  label: 'Log in',
                  isLoading: state.isBusy,
                  onPressed: onSubmit,
                ),
                const SizedBox(height: AppSpacing.xl),
                Center(
                  child: Text('OR LOG IN BY', style: AppTypography.overline),
                ),
                const SizedBox(height: AppSpacing.sm + 2),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SocialLoginButton(
                      icon: Icons.g_mobiledata_rounded,
                      label: 'Sign in with Google',
                    ),
                    SizedBox(width: AppSpacing.lg),
                    SocialLoginButton(
                      icon: Icons.facebook_rounded,
                      label: 'Sign in with Facebook',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.xs,
                  children: <Widget>[
                    Text(
                      "Don't have an account?",
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.signUp),
                      child: Text(
                        'SIGN UP',
                        style: AppTypography.body.copyWith(
                          color: AppColors.link,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Explains how password recovery works, since v1 relies on the Firebase
/// console rather than shipping a custom reset flow.
@Deprecated('Use AuthCubit.sendPasswordReset instead')
Future<void> showForgotPasswordDialog(
  BuildContext context,
  String email,
) async {
  final String target = email.trim().isEmpty ? 'your account' : email.trim();
  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: const Text('Reset your password'),
      content: Text(
        'Password recovery emails are sent by Firebase Authentication. Open '
        '$target and enable the "Forgot password" template in the Firebase '
        'console, or contact the community admin.',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}

/// 40 dp circular social button, matching the Figma `#E3E3FC` pill.
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({required this.icon, required this.label, super.key});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: InkWell(
          // Google social sign-in is out of scope for v1; the button reports
          // the limitation instead of silently doing nothing.
          onTap: () => ConnectMeSnackBar.showInfo(
            context,
            '$label is coming in the next ConnectMe release.',
          ),
          customBorder: const CircleBorder(),
          child: Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
              color: AppColors.socialButton,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: AppColors.primaryDark),
          ),
        ),
      ),
    );
  }
}
