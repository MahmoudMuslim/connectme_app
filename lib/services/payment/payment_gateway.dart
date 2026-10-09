import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../../domain/entities/money.dart';

/// Authorisation request handed to a [PaymentGateway].
class PaymentRequest {
  const PaymentRequest({
    required this.donorId,
    required this.money,
    this.reference = 'community-fund',
    this.description = 'ConnectMe community donation',
  });

  /// Id of the paying member.
  final String donorId;

  /// Validated amount + currency.
  final Money money;

  /// Merchant reference used for reconciliation.
  final String reference;

  /// Line item shown by the provider.
  final String description;

  @override
  String toString() =>
      'PaymentRequest($reference, ${money.compact}, donor: $donorId)';
}

/// Result of a successful authorisation.
class PaymentReceipt {
  const PaymentReceipt({
    required this.transactionId,
    required this.approvedAt,
    required this.amount,
    required this.provider,
  });

  final String transactionId;
  final DateTime approvedAt;
  final Money amount;

  /// Name of the gateway that approved the charge.
  final String provider;
}

/// **Interface Segregation + Dependency Inversion** — the domain depends only
/// on this tiny contract, never on a concrete payment SDK.
///
/// Because the contract is minimal, a new provider (Stripe, PayPal, ...) can be
/// introduced by adding one implementation class without touching a single
/// existing class (Open/Closed).
abstract interface class PaymentGateway {
  /// Human readable provider name, rendered on the donation receipt.
  String get name;

  /// Authorises [request].
  ///
  /// Returns `Success(PaymentReceipt)` when the charge is approved and a
  /// `PaymentFailure` carrying a user friendly message when it is declined.
  Future<Result<PaymentReceipt>> charge(PaymentRequest request);

  /// `true` when the provider can currently process a charge.
  Future<bool> isAvailable();
}

/// Declines every request — used as a null-object when no provider is
/// configured, so the UI always receives a [Result] instead of an exception.
class UnavailablePaymentGateway implements PaymentGateway {
  const UnavailablePaymentGateway();

  @override
  String get name => 'Unavailable';

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<Result<PaymentReceipt>> charge(PaymentRequest request) async {
    return const ResultFailure<PaymentReceipt>(
      PaymentFailure('No payment provider is configured for this build.'),
    );
  }
}
