import 'package:connectme_app/core/constants/app_constants.dart';
import 'package:connectme_app/core/errors/failures.dart';
import 'package:connectme_app/core/result/result.dart';
import 'package:connectme_app/domain/entities/donation.dart';
import 'package:connectme_app/domain/entities/money.dart';
import 'package:connectme_app/domain/repositories/donation_repository.dart';
import 'package:connectme_app/domain/usecases/create_donation.dart';
import 'package:connectme_app/services/payment/demo_payment_gateway.dart';
import 'package:connectme_app/services/payment/payment_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

/// Gateway that always fails, used to prove the use case surfaces a
/// `PaymentFailure` instead of an exception.
class _DecliningGateway implements PaymentGateway {
  @override
  String get name => 'Declining test gateway';

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<Result<PaymentReceipt>> charge(PaymentRequest request) async {
    return const ResultFailure<PaymentReceipt>(
      PaymentFailure('Your card was declined.'),
    );
  }
}

class _RecordingRepository implements DonationRepository {
  final List<Donation> received = <Donation>[];

  @override
  Future<Result<Donation>> donate({
    required String donorId,
    required String donorName,
    required Money money,
    String? message,
  }) async {
    final Donation donation = Donation(
      id: 'd1',
      donorId: donorId,
      donorName: donorName,
      money: money,
      createdAt: DateTime.utc(2026, 3, 1),
      message: message,
    );
    received.add(donation);
    return Success<Donation>(donation);
  }

  @override
  Future<Result<List<Donation>>> getDonationsOf(String donorId) async =>
      const Success<List<Donation>>(<Donation>[]);

  @override
  Future<Result<Money>> getTotalRaised() async =>
      Success<Money>(Money(amount: 0, minAmount: 0, maxAmount: 1));

  @override
  Stream<Result<List<Donation>>> watchDonations() =>
      const Stream<Result<List<Donation>>>.empty();
}

void main() {
  group('Money value object', () {
    test('rejects a non finite amount', () {
      expect(
        () => Money(amount: double.nan),
        throwsA(isA<ValidationException>()),
      );
    });

    test('rejects an amount below the minimum', () {
      expect(() => Money(amount: 0.5), throwsA(isA<ValidationException>()));
    });

    test('rejects an amount above the maximum', () {
      expect(() => Money(amount: 100000), throwsA(isA<ValidationException>()));
    });

    test('rejects a currency that is not a 3 letter ISO code', () {
      expect(
        () => Money(amount: 10, currency: 'DOLLARS'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('rounds the amount to two decimals and uppercases the currency', () {
      final Money money = Money(amount: 25.129, currency: 'usd');

      expect(money.amount, 25.13);
      expect(money.currency, 'USD');
    });

    test('parse() accepts a comma decimal separator', () {
      expect(Money.parse('25,50').amount, 25.5);
    });

    test('parse() rejects garbage', () {
      expect(() => Money.parse('abc'), throwsA(isA<ValidationException>()));
    });

    test('formatted always shows two decimals', () {
      expect(Money(amount: 5).formatted, '5.00 USD');
    });

    test('compact drops a zero decimal part', () {
      expect(Money(amount: 5).compact, '5 USD');
      expect(Money(amount: 5.5).compact, '5.50 USD');
    });

    test('addition refuses to mix currencies', () {
      expect(
        () => Money(amount: 5) + Money(amount: 5, currency: 'EUR'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('DemoPaymentGateway', () {
    test('approves a charge and returns a transaction id', () async {
      final DemoPaymentGateway gateway = DemoPaymentGateway(
        latency: Duration.zero,
      );

      final Result<PaymentReceipt> result = await gateway.charge(
        PaymentRequest(donorId: 'u1', money: Money(amount: 25)),
      );

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.transactionId, startsWith('CM-'));
      expect(result.valueOrNull!.provider, contains('sandbox'));
    });

    test('declines amounts above the sandbox ceiling', () async {
      final DemoPaymentGateway gateway = DemoPaymentGateway(
        latency: Duration.zero,
      );

      final Result<PaymentReceipt> result = await gateway.charge(
        PaymentRequest(donorId: 'u1', money: Money(amount: 3000)),
      );

      expect(result.isSuccess, isFalse);
      expect(result.failureOrNull, isA<PaymentFailure>());
    });
  });

  group('CreateDonation', () {
    test('rejects an anonymous donor', () async {
      final _RecordingRepository repository = _RecordingRepository();

      final Result<Donation> result = await CreateDonation(repository)(
        donorId: '',
        donorName: 'Bruno',
        money: Money(amount: 10),
      );

      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(repository.received, isEmpty);
    });

    test('rejects an amount below the application minimum', () async {
      final _RecordingRepository repository = _RecordingRepository();

      // `minAmount: 0` lets the value object accept an amount that the use case
      // (which enforces AppConstants.minDonationAmount) must then reject.
      final Result<Donation> result = await CreateDonation(repository)(
        donorId: 'u1',
        donorName: 'Bruno',
        money: Money(amount: 0.5, minAmount: 0),
      );

      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(repository.received, isEmpty);
    });

    test('trims the donor name and the message', () async {
      final _RecordingRepository repository = _RecordingRepository();

      final Result<Donation> result = await CreateDonation(repository)(
        donorId: 'u1',
        donorName: '  Bruno Pham  ',
        money: Money(amount: 10),
        message: '  keep building  ',
      );

      expect(result.isSuccess, isTrue);
      expect(repository.received.single.donorName, 'Bruno Pham');
      expect(repository.received.single.message, 'keep building');
    });

    test('stores a null message when the member typed nothing', () async {
      final _RecordingRepository repository = _RecordingRepository();

      await CreateDonation(repository)(
        donorId: 'u1',
        donorName: 'Bruno',
        money: Money(amount: 10),
        message: '   ',
      );

      expect(repository.received.single.message, isNull);
    });
  });

  group('AppConstants donation limits', () {
    test('are coherent with the domain defaults', () {
      expect(AppConstants.minDonationAmount, lessThan(50));
      expect(AppConstants.maxDonationAmount, greaterThan(50));
      expect(AppConstants.defaultCurrency, 'USD');
    });
  });

  group('UnavailablePaymentGateway', () {
    test('returns a PaymentFailure rather than throwing', () async {
      const UnavailablePaymentGateway gateway = UnavailablePaymentGateway();

      final Result<PaymentReceipt> result = await gateway.charge(
        PaymentRequest(donorId: 'u1', money: Money(amount: 10)),
      );

      expect(result.failureOrNull, isA<PaymentFailure>());
      expect(await gateway.isAvailable(), isFalse);
    });
  });

  group('_DecliningGateway', () {
    test('is substitutable for any other gateway (LSP)', () async {
      final PaymentGateway gateway = _DecliningGateway();

      expect(await gateway.isAvailable(), isTrue);
      final Result<PaymentReceipt> result = await gateway.charge(
        PaymentRequest(donorId: 'u1', money: Money(amount: 10)),
      );
      expect(result.failureOrNull, isA<PaymentFailure>());
    });
  });
}
