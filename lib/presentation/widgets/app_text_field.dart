import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';

/// Pill shaped text field with an optional trailing icon (used by the password
/// visibility toggle of the Figma login / sign-up forms).
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
    this.enabled = true,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.suffixIcon,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final int? maxLength;
  final TextCapitalization textCapitalization;

  /// Replaces the default suffix (eye toggle) when provided.
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: AppTypography.input,
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        suffixIcon: suffixIcon,
      ),
    );
  }
}
