import '../../core/result/result.dart';
import '../entities/donation.dart';
import '../entities/money.dart';

/// Persistence contract for donations.
///
/// Note the SOLID flavour of the design:
/// * The use case only depends on this **abstract** contract (DIP).
/// * [Donation] and [Money] value objects guarantee a donation always carries
///   a validated amount and its currency (SRP + encapsulation).
/// * Payment authorisation itself is delegated to `PaymentGateway`, so adding a
///   second provider (Stripe, PayPal, ...) does not change a single line here
///   (OCP + LSP + ISP).
abstract interface class DonationRepository {
  /// Charges [money] through the injected gateway and stores the receipt.
  Future<Result<Donation>> donate({
    required String donorId,
    required String donorName,
    required Money money,
    String? message,
  });

  /// Real-time donation history of the whole community (newest first).
  Stream<Result<List<Donation>>> watchDonations();

  /// Donation history of a single member.
  Future<Result<List<Donation>>> getDonationsOf(String donorId);

  /// Total amount raised by the community.
  Future<Result<Money>> getTotalRaised();
}
