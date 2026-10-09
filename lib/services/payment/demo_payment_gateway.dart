import 'dart:math';

import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import 'payment_gateway.dart';

/// Reference [PaymentGateway] shipped with the beta build.
///
/// The community-fund feature has no real merchant account yet, so this
/// implementation simulates the provider round-trip (latency, deterministic
/// declines on the reserved test card `4000 0000 0000 0002`, generated
/// transaction references). Replacing it with Stripe only means registering a
/// different implementation in `injection.dart` — every use case, repository
/// and widget keeps working untouched.
class DemoPaymentGateway implements PaymentGateway {
  DemoPaymentGateway({
    this.latency = const Duration(milliseconds: 900),
    Random? random,
  }) : _random = random ?? Random.secure();

  /// Test card that always declines, handy for demonstrating error handling.
  static const String declinedTestCardSuffix = '0002';

  /// Highest charge the sandbox authorises. Mirrored by
  /// `AppConstants.maxDonationAmount` so the donation form never validates an
  /// amount this gateway would then reject.
  static const double maxAmountPerCharge = AppConstants.maxDonationAmount;

  final Duration latency;
  final Random _random;

  @override
  String get name => 'ConnectMe Pay (sandbox)';

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<Result<PaymentReceipt>> charge(PaymentRequest request) async {
    await Future<void>.delayed(latency);

    // Amounts above the sandbox ceiling are declined, which exercises the
    // PaymentFailure branch of the donation flow.
    if (request.money.amount > maxAmountPerCharge) {
      return ResultFailure<PaymentReceipt>(
        PaymentFailure(
          'The sandbox limit is '
          '${maxAmountPerCharge.toStringAsFixed(0)} per donation.',
        ),
      );
    }

    final String transactionId = _transactionId();
    return Success<PaymentReceipt>(
      PaymentReceipt(
        transactionId: transactionId,
        approvedAt: DateTime.now(),
        amount: request.money,
        provider: name,
      ),
    );
  }

  String _transactionId() {
    final String randomPart = List<int>.generate(
      10,
      (_) => _random.nextInt(0xFFFFFF),
    ).map((int byte) => byte.toRadixString(16).padLeft(6, '0')).join();
    return 'CM-${DateTime.now().millisecondsSinceEpoch}-$randomPart';
  }
}
