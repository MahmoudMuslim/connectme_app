import 'package:equatable/equatable.dart';

import '../../../domain/entities/donation.dart';
import '../../../domain/entities/money.dart';

/// Status axis of [DonationCubit].
enum DonationLoadStatus {
  /// The donation history is loading.
  loading,

  /// The history is rendered.
  loaded,

  /// Something went wrong.
  error,
}

/// Immutable state of [DonationCubit].
class DonationState extends Equatable {
  const DonationState({
    this.status = DonationLoadStatus.loading,
    this.donations = const <Donation>[],
    this.totalRaised,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.lastDonation,
  });

  final DonationLoadStatus status;

  /// Community donation history, newest first.
  final List<Donation> donations;

  /// Sum of every donation, rendered in the progress banner.
  final Money? totalRaised;

  /// `true` while the gateway is charging.
  final bool isSubmitting;

  final String? errorMessage;
  final String? successMessage;

  /// The receipt produced by the last successful donation.
  final Donation? lastDonation;

  bool get isEmpty => status == DonationLoadStatus.loaded && donations.isEmpty;

  DonationState copyWith({
    DonationLoadStatus? status,
    List<Donation>? donations,
    Money? totalRaised,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    Donation? lastDonation,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return DonationState(
      status: status ?? this.status,
      donations: donations ?? this.donations,
      totalRaised: totalRaised ?? this.totalRaised,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      lastDonation: lastDonation ?? this.lastDonation,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    donations,
    totalRaised,
    isSubmitting,
    errorMessage,
    successMessage,
    lastDonation,
  ];
}
