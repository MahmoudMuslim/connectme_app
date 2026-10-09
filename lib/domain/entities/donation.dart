import 'package:equatable/equatable.dart';

import 'money.dart';

/// Lifecycle of a donation transaction.
enum DonationStatus {
  /// The gateway authorised the charge.
  completed('Completed'),

  /// The donation was recorded locally but the gateway did not answer.
  pending('Pending'),

  /// The gateway declined the charge.
  failed('Failed');

  const DonationStatus(this.label);

  final String label;
}

/// A single donation made by a community member.
///
/// All payment related logic is modelled here with SOLID in mind:
/// * **S**ingle responsibility — this class only *describes* a donation, it does
///   not charge anybody.
/// * **O**pen/closed — [Donation] can grow new fields without touching the
///   [DonationRepository] contract.
/// * **L**iskov substitution — every gateway implementation returns a
///   `Donation` and can be swapped freely.
/// * **I**nterface segregation — the gateway contract only exposes `charge`.
/// * **D**ependency inversion — the use case depends on the abstract
///   `PaymentGateway`, never on a concrete SDK.
class Donation extends Equatable {
  const Donation({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.money,
    required this.createdAt,
    this.message,
    this.transactionId,
    this.status = DonationStatus.completed,
  });

  /// Firestore document id.
  final String id;

  /// Uid of the donor.
  final String donorId;

  /// Denormalised donor name, rendered in the history list.
  final String donorName;

  /// Validated amount + currency.
  final Money money;

  final DateTime createdAt;

  /// Optional message attached to the donation.
  final String? message;

  /// Reference returned by the payment gateway.
  final String? transactionId;

  final DonationStatus status;

  Donation copyWith({
    String? id,
    String? donorId,
    String? donorName,
    Money? money,
    DateTime? createdAt,
    String? message,
    String? transactionId,
    DonationStatus? status,
  }) {
    return Donation(
      id: id ?? this.id,
      donorId: donorId ?? this.donorId,
      donorName: donorName ?? this.donorName,
      money: money ?? this.money,
      createdAt: createdAt ?? this.createdAt,
      message: message ?? this.message,
      transactionId: transactionId ?? this.transactionId,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    donorId,
    donorName,
    money,
    createdAt,
    message,
    transactionId,
    status,
  ];
}
