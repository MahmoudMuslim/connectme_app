import 'package:equatable/equatable.dart';

import '../../core/errors/failures.dart';

/// Immutable money **value object** (SRP + encapsulation).
///
/// Wrapping the amount and the currency inside a single type guarantees that
/// an amount can never be passed around without its currency, and that the
/// legal range is validated exactly once — right where the value is created.
class Money extends Equatable implements Comparable<Money> {
  const Money._(this.amount, this.currency);

  /// Builds a validated [Money].
  ///
  /// Throws a [ValidationException] (converted into a `ValidationFailure` by
  /// the repository) when the amount is not a finite number inside
  /// `[{minAmount}, {maxAmount}]`.
  factory Money({
    required double amount,
    String currency = 'USD',
    double minAmount = 1,
    double maxAmount = 5000,
  }) {
    if (!amount.isFinite) {
      throw const ValidationException('Please enter a valid donation amount');
    }
    if (amount < minAmount) {
      throw ValidationException(
        'The minimum donation is ${_trim(minAmount)} $currency',
      );
    }
    if (amount > maxAmount) {
      throw ValidationException(
        'The maximum donation is ${_trim(maxAmount)} $currency',
      );
    }
    if (currency.trim().length != 3) {
      throw const ValidationException(
        'The currency must be a 3 letter ISO code such as USD',
      );
    }
    return Money._(
      double.parse(amount.toStringAsFixed(2)),
      currency.toUpperCase(),
    );
  }

  /// Convenience factory for the UI (parses user input).
  factory Money.parse(String raw, {String currency = 'USD'}) {
    final double? value = double.tryParse(raw.trim().replaceAll(',', '.'));
    if (value == null) {
      throw const ValidationException('Please enter a valid number');
    }
    return Money(amount: value, currency: currency);
  }

  /// Amount rounded to two decimals.
  final double amount;

  /// ISO-4217 currency code (uppercase).
  final String currency;

  /// `25.00 USD`
  String get formatted => '${amount.toStringAsFixed(2)} $currency';

  /// `25 USD` — drops the decimals when they are zero.
  String get compact => amount == amount.roundToDouble()
      ? '${amount.toStringAsFixed(0)} $currency'
      : formatted;

  Money operator +(Money other) {
    if (currency != other.currency) {
      throw ValidationException(
        'Cannot add $currency to ${other.currency}: currencies differ',
      );
    }
    return Money._(
      double.parse((amount + other.amount).toStringAsFixed(2)),
      currency,
    );
  }

  @override
  int compareTo(Money other) => amount.compareTo(other.amount);

  Map<String, dynamic> toMap() => <String, dynamic>{
    'amount': amount,
    'currency': currency,
  };

  @override
  List<Object?> get props => <Object?>[amount, currency];

  static String _trim(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';
}
