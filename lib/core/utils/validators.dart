/// Centralised validation rules.
///
/// Every form in the app delegates to these helpers so the *same* rule is never
/// implemented twice (requirement: "no duplicate code").
class Validators {
  const Validators._();

  /// Full name must be 3-40 characters and start with a capital letter.
  static String? fullName(String? value) {
    final String name = value?.trim() ?? '';
    if (name.isEmpty) {
      return 'Please enter your full name';
    }
    if (name.length < 3) {
      return 'Name must be at least 3 characters';
    }
    if (name.length > 40) {
      return 'Name must be at most 40 characters';
    }
    if (!RegExp(r'^[A-Z]').hasMatch(name)) {
      return 'Name must start with a capital letter';
    }
    if (!RegExp(r"^[A-Za-zÀ-ÿ' -]+$").hasMatch(name)) {
      return 'Name can only contain letters, spaces, apostrophes or dashes';
    }
    return null;
  }

  /// Email must contain a `@`, a domain and no spaces.
  static String? email(String? value) {
    final String email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Please enter your email address';
    }
    if (!email.contains('@')) {
      return 'Please enter a valid email address';
    }
    if (!RegExp(r'^[\w.!#$%&*+/=?^`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$')
        .hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Password must be at least 6 characters and contain a letter + a digit,
  /// which mirrors the Firebase default policy.
  static String? password(String? value) {
    final String password = value ?? '';
    if (password.isEmpty) {
      return 'Please enter a password';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
        !RegExp(r'\d').hasMatch(password)) {
      return 'Password must contain at least one letter and one number';
    }
    return null;
  }

  /// Confirm password must be identical to [password].
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Generic "this field is required" rule.
  static String? required(String? value, String fieldLabel) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldLabel is required';
    }
    return null;
  }

  /// Post body must not be empty and must respect the 280 character budget.
  static String? postContent(String? value, {required int maxLength}) {
    final String content = value?.trim() ?? '';
    if (content.isEmpty) {
      return 'Write something before posting';
    }
    if (content.length > maxLength) {
      return 'A post cannot exceed $maxLength characters';
    }
    return null;
  }

  /// Donation amount must be a positive, finite number inside the allowed range.
  static String? donationAmount(
    String? value, {
    required double min,
    required double max,
  }) {
    final String raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'Please enter a donation amount';
    }
    final double? amount = double.tryParse(raw);
    if (amount == null) {
      return 'Please enter a valid number';
    }
    if (!amount.isFinite) {
      return 'Please enter a valid number';
    }
    if (amount < min) {
      return 'The minimum donation is ${_format(min)}';
    }
    if (amount > max) {
      return 'The maximum donation is ${_format(max)}';
    }
    return null;
  }

  static String _format(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';
}
