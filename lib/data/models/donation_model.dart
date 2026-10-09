import '../../core/constants/app_constants.dart';
import '../../domain/entities/donation.dart';
import '../../domain/entities/money.dart';

/// Firestore/JSON representation of [Donation].
class DonationModel extends Donation {
  const DonationModel({
    required super.id,
    required super.donorId,
    required super.donorName,
    required super.money,
    required super.createdAt,
    super.message,
    super.transactionId,
    super.status,
  });

  /// Rebuilds a model from a Firestore snapshot.
  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json['id'] as String? ?? '',
      donorId: json[AppConstants.authorIdField] as String? ?? '',
      donorName: json[AppConstants.donorNameField] as String? ?? 'Member',
      money: Money(
        amount: _toDouble(json[AppConstants.amountField]),
        currency: json[AppConstants.currencyField] as String? ?? 'USD',
      ),
      createdAt: _toDate(json[AppConstants.createdAtField]),
      message: json[AppConstants.messageField] as String?,
      transactionId: json[AppConstants.transactionIdField] as String?,
      status: DonationStatus.values.firstWhere(
        (DonationStatus status) =>
            status.name == (json['status'] as String? ?? ''),
        orElse: () => DonationStatus.completed,
      ),
    );
  }

  /// Serialises the model for `Firestore.set` and for the local cache.
  /// `createdAt` is an ISO-8601 string so the model stays reusable by the local
  /// cache; `DonationRepositoryImpl` converts it to a native Firestore
  /// `Timestamp` at the boundary so `orderBy('createdAt')` stays chronological.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    AppConstants.authorIdField: donorId,
    AppConstants.donorNameField: donorName,
    AppConstants.amountField: money.amount,
    AppConstants.currencyField: money.currency,
    AppConstants.createdAtField: createdAt.toIso8601String(),
    if (message != null) AppConstants.messageField: message,
    if (transactionId != null) AppConstants.transactionIdField: transactionId,
    'status': status.name,
  };

  /// Converts a domain entity into its serialisable model.
  factory DonationModel.fromEntity(Donation donation) {
    return DonationModel(
      id: donation.id,
      donorId: donation.donorId,
      donorName: donation.donorName,
      money: donation.money,
      createdAt: donation.createdAt,
      message: donation.message,
      transactionId: donation.transactionId,
      status: donation.status,
    );
  }

  static double _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  static DateTime _toDate(Object? value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
