import '../../core/result/result.dart';
import '../entities/donation.dart';
import '../entities/money.dart';
import '../repositories/donation_repository.dart';

/// Donation history of the whole community, streamed in real time.
class GetDonations {
  const GetDonations(this._repository);

  final DonationRepository _repository;

  Stream<Result<List<Donation>>> watchAll() => _repository.watchDonations();

  Future<Result<List<Donation>>> of(String donorId) =>
      _repository.getDonationsOf(donorId);

  /// Total amount raised, used by the progress banner.
  Future<Result<Money>> totalRaised() => _repository.getTotalRaised();
}
