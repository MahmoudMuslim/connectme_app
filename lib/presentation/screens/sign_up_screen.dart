import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/device_info.dart';
import '../../domain/usecases/get_device_info.dart';
import '../../injection.dart';
import '../blocs/auth/auth_cubit.dart';
import '../blocs/auth/auth_state.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_header_collage.dart';
import '../widgets/connectme_snack_bar.dart';

/// Registration form.
///
/// Requirement 1: "Build a Sign Up Screen with full form validation: Full Name
/// (capital first letter), Email (must contain @), Password (min 6 characters),
/// Confirm Password (must match)."
///
/// Every rule lives in `Validators` / the `SignUp` use case, so the form only
/// has to display the message it receives — no rule is duplicated here.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  /// Device details captured by `device_info_plus` and stored on the profile.
  DeviceInfo? _deviceInfo;

  @override
  void initState() {
    super.initState();
    _readDeviceInfo();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _readDeviceInfo() async {
    final DeviceInfo? info = await getIt<GetDeviceInfo>().call().then(
      (result) => result.valueOrNull,
    );
    if (mounted) {
      setState(() => _deviceInfo = info);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: <Widget>[
          const Positioned(
            left: 0,
            top: 0,
            right: 0,
            height: 312,
            child: AuthHeaderCollage(height: 312),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 56,
              ),
              child: Responsive.constrainContent(
                context,
                child: _SignUpSheet(
                  formKey: _formKey,
                  fullNameController: _fullNameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  obscurePassword: _obscurePassword,
                  obscureConfirmPassword: _obscureConfirmPassword,
                  deviceInfo: _deviceInfo,
                  onTogglePassword: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  onToggleConfirmPassword: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                  onSubmit: _submit,
                ),
              ),
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
    await context.read<AuthCubit>().signUp(
      fullName: _fullNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      deviceModel: _deviceInfo?.model,
      osVersion: _deviceInfo?.osVersion,
    );
  }
}

/// White rounded sheet holding the registration form.
class _SignUpSheet extends StatelessWidget {
  const _SignUpSheet({
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.deviceInfo,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final DeviceInfo? deviceInfo;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
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
        AppSpacing.xl,
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
              previous.status != current.status,
          listener: (BuildContext context, AuthState state) {
            // A successful registration replaces the form with the shell.
            if (state.isAuthenticated) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
              return;
            }
            final String? error = state.errorMessage;
            if (error != null) {
              ConnectMeSnackBar.showError(context, error);
              context.read<AuthCubit>().clearError();
            }
          },
          builder: (BuildContext context, AuthState state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppTextField(
                  controller: fullNameController,
                  hint: 'Full Name',
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  maxLength: AppConstants.maxNameLength,
                  validator: Validators.fullName,
                  onChanged: (_) => context.read<AuthCubit>().clearError(),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: emailController,
                  hint: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                  onChanged: (_) => context.read<AuthCubit>().clearError(),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: passwordController,
                  hint: 'Password',
                  obscureText: obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: Validators.password,
                  onChanged: (_) => context.read<AuthCubit>().clearError(),
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
                AppTextField(
                  controller: confirmPasswordController,
                  hint: 'Confirm Password',
                  obscureText: obscureConfirmPassword,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  validator: (String? value) => Validators.confirmPassword(
                    value,
                    passwordController.text,
                  ),
                  onChanged: (_) => context.read<AuthCubit>().clearError(),
                  onSubmitted: (_) => onSubmit(),
                  suffixIcon: IconButton(
                    onPressed: onToggleConfirmPassword,
                    tooltip: obscureConfirmPassword
                        ? 'Show password'
                        : 'Hide password',
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 22,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                if (deviceInfo != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  _DeviceHint(deviceInfo: deviceInfo!),
                ],
                const SizedBox(height: AppSpacing.xl),
                AppPrimaryButton(
                  label: 'Sign up',
                  isLoading: state.isBusy,
                  onPressed: onSubmit,
                ),
                const SizedBox(height: AppSpacing.xl),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.xs,
                  children: <Widget>[
                    Text(
                      'Already have an account?',
                      style: AppTypography.body.copyWith(
                        color: AppColors.headerDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.login),
                      child: Text(
                        'SIGN IN',
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

/// Small inline hint confirming the device data captured at sign-up.
class _DeviceHint extends StatelessWidget {
  const _DeviceHint({required this.deviceInfo});

  final DeviceInfo deviceInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.screenBackground,
        borderRadius: BorderRadius.circular(AppRadii.tab),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.smartphone_rounded,
            size: 18,
            color: AppColors.primaryDark,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Signing up from ${deviceInfo.summary}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
