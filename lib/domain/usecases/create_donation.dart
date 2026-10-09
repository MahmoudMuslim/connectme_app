import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/result/result.dart';
import '../entities/donation.dart';
import '../entities/money.dart';
import '../repositories/donation_repository.dart';

/// Charges a donation and stores its receipt.
///
/// The use case performs **no** payment work of its own: it only validates that
/// a donor is known and then delegates to the [DonationRepository], which in
/// turn uses the injected `PaymentGateway` (Single Responsibility).
class CreateDonation {
  const CreateDonation(this._repository);

  final DonationRepository _repository;

  Future<Result<Donation>> call({
    required String donorId,
    required String donorName,
    required Money money,
    String? message,
  }) {
    if (donorId.isEmpty) {
      return _fail(DonationMessages.signInRequired);
    }
    if (money.amount < AppConstants.minDonationAmount) {
      return _fail(DonationMessages.tooSmall);
    }
    return _repository.donate(
      donorId: donorId,
      donorName: donorName.trim(),
      money: money,
      message: (message == null || message.trim().isEmpty)
          ? null
          : message.trim(),
    );
  }

  Future<Result<Donation>> _fail(String message) =>
      Future<Result<Donation>>.value(
        ResultFailure<Donation>(ValidationFailure(message)),
      );
}

/// Centralised donation validation messages.
///
/// Keeping them here avoids repeating the same sentence in the use case, the
/// repository and the form.
abstract final class DonationMessages {
  static const String signInRequired =
      'You must be signed in to support the community.';

  static final String tooSmall =
      'The minimum donation is '
      '${AppConstants.minDonationAmount.toStringAsFixed(0)} '
      '${AppConstants.defaultCurrency}';
}
