import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../core/errors/firebase_error_mapper.dart';
import '../../../core/result/result.dart';
import '../../../domain/entities/donation.dart';
import '../../../domain/entities/money.dart';
import '../../../domain/usecases/create_donation.dart';
import '../../../domain/usecases/get_donations.dart';
import 'donation_state.dart';

/// **CUBIT** driving the community-fund screen.
///
/// Like every other cubit it only orchestrates use cases: the payment rules
/// live in `CreateDonation`, the gateway call in `DonationRepositoryImpl` and
/// the money rules in the `Money` value object.
class DonationCubit extends Cubit<DonationState> {
  DonationCubit({required this.createDonation, required this.getDonations})
    : super(const DonationState());

  /// Charges a donation and stores the receipt.
  final CreateDonation createDonation;

  /// Reads the donation history.
  final GetDonations getDonations;

  StreamSubscription<Result<List<Donation>>>? _subscription;

  /// Subscribes to the real-time donation history.
  void listen() {
    _subscription?.cancel();
    emit(state.copyWith(status: DonationLoadStatus.loading, clearError: true));
    _subscription = getDonations.watchAll().listen(
      _onDonations,
      onError: _onError,
    );
  }

  /// Loads the total amount raised (the progress banner).
  Future<void> loadTotalRaised() async {
    final Result<Money> result = await getDonations.totalRaised();
    if (isClosed) {
      return;
    }
    result.fold(
      onSuccess: (Money total) => emit(state.copyWith(totalRaised: total)),
      onFailure: _onError,
    );
  }

  /// Charges the donation.
  Future<bool> donate({
    required String donorId,
    required String donorName,
    required Money money,
    String? message,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final Result<Donation> result = await createDonation(
      donorId: donorId,
      donorName: donorName,
      money: money,
      message: message,
    );
    if (isClosed) {
      return false;
    }
    return result.fold(
      onSuccess: (Donation donation) {
        emit(
          state.copyWith(
            isSubmitting: false,
            lastDonation: donation,
            successMessage: 'Thank you! ${money.compact} received.',
          ),
        );
        return true;
      },
      onFailure: (Object failure) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: _messageOf(failure),
          ),
        );
        return false;
      },
    );
  }

  /// Dismisses the success banner.
  void clearSuccess() {
    if (state.successMessage == null || isClosed) {
      return;
    }
    emit(state.copyWith(clearSuccess: true));
  }

  /// Clears the last error.
  void clearError() {
    if (state.errorMessage == null || isClosed) {
      return;
    }
    emit(state.copyWith(clearError: true));
  }

  void _onDonations(Result<List<Donation>> result) {
    if (isClosed) {
      return;
    }
    result.fold(
      onSuccess: (List<Donation> donations) => emit(
        state.copyWith(
          status: DonationLoadStatus.loaded,
          donations: donations,
          clearError: true,
        ),
      ),
      onFailure: _onError,
    );
  }

  void _onError(Object failure) {
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        status: DonationLoadStatus.error,
        errorMessage: _messageOf(failure),
      ),
    );
  }

  String _messageOf(Object failure) {
    if (failure is Failure) {
      return failure.message;
    }
    return FirebaseErrorMapper.messageOf(failure);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
