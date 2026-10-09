import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/firebase_error_mapper.dart';
import '../../core/result/result.dart';
import '../../domain/entities/donation.dart';
import '../../domain/entities/money.dart';
import '../../domain/repositories/donation_repository.dart';
import '../../services/firestore_service.dart';
import '../../services/payment/payment_gateway.dart';
import '../models/donation_model.dart';

/// Donation persistence.
///
/// SOLID summary:
/// * **S**ingle Responsibility — charging lives in the injected
///   [PaymentGateway]; this class only persists receipts.
/// * **O**pen/Closed — a new provider only requires a new gateway
///   implementation, this file never changes.
/// * **L**iskov Substitution — every gateway returns a [Result], so any of them
///   can be injected.
/// * **I**nterface Segregation — the gateway contract exposes only `charge`,
///   `isAvailable` and `name`.
/// * **D**ependency Inversion — the domain depends on the abstract
///   [DonationRepository] and [PaymentGateway], never on Firestore.
class DonationRepositoryImpl implements DonationRepository {
  DonationRepositoryImpl({
    required this.gateway,
    required this.firestoreService,
    required this.preferences,
  });

  final PaymentGateway gateway;
  final FirestoreService firestoreService;
  final SharedPreferences preferences;

  @override
  Future<Result<Donation>> donate({
    required String donorId,
    required String donorName,
    required Money money,
    String? message,
  }) async {
    try {
      if (!await gateway.isAvailable()) {
        return const ResultFailure<Donation>(
          PaymentFailure('No payment provider is configured for this build.'),
        );
      }

      // 1) Authorise with the provider.
      final Result<PaymentReceipt> receipt = await gateway.charge(
        PaymentRequest(donorId: donorId, money: money),
      );
      if (!receipt.isSuccess) {
        return ResultFailure<Donation>(_asFailure(receipt.failureOrNull));
      }
      final PaymentReceipt paymentReceipt = receipt.valueOrNull!;

      // 2) Persist the receipt only once the charge succeeded.
      final DonationModel donation = DonationModel.fromEntity(
        Donation(
          id: _generateId(),
          donorId: donorId,
          donorName: donorName,
          money: money,
          createdAt: paymentReceipt.approvedAt,
          message: message,
          transactionId: paymentReceipt.transactionId,
        ),
      );

      if (firestoreService.isReady) {
        await firestoreService.donationsCollection
            .doc(donation.id)
            .set(_toFirestore(donation.toJson()));
      } else {
        await _appendToCache(donation);
      }
      return Success<Donation>(donation);
    } on Object catch (error) {
      return ResultFailure<Donation>(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Stream<Result<List<Donation>>> watchDonations() async* {
    try {
      if (firestoreService.isReady) {
        await for (final QuerySnapshot<Map<String, dynamic>> snapshot
            in firestoreService.donationsCollection
                .orderBy(AppConstants.createdAtField, descending: true)
                .limit(AppConstants.feedPageSize)
                .snapshots()) {
          yield Success<List<Donation>>(
            snapshot.docs.map(_fromFirestore).toList(),
          );
        }
        return;
      }

      yield Success<List<Donation>>(_readCache());
    } on Object catch (error) {
      yield ResultFailure<List<Donation>>(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<Result<List<Donation>>> getDonationsOf(String donorId) async {
    try {
      List<DonationModel> donations;
      if (firestoreService.isReady) {
        final QuerySnapshot<Map<String, dynamic>> snapshot =
            await firestoreService.donationsCollection
                .where(AppConstants.authorIdField, isEqualTo: donorId)
                .orderBy(AppConstants.createdAtField, descending: true)
                .get();
        donations = snapshot.docs.map(_fromFirestore).toList();
      } else {
        donations = _readCache();
      }
      return Success<List<Donation>>(
        donations
            .where((DonationModel donation) => donation.donorId == donorId)
            .toList(),
      );
    } on Object catch (error) {
      return ResultFailure<List<Donation>>(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<Result<Money>> getTotalRaised() async {
    try {
      double total = 0;
      String currency = AppConstants.defaultCurrency;
      if (firestoreService.isReady) {
        final QuerySnapshot<Map<String, dynamic>> snapshot =
            await firestoreService.donationsCollection.get();
        for (final DocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
          final DonationModel donation = _fromFirestore(doc);
          total += donation.money.amount;
          currency = donation.money.currency;
        }
      } else {
        for (final DonationModel donation in _readCache()) {
          total += donation.money.amount;
          currency = donation.money.currency;
        }
      }
      return Success<Money>(
        Money(
          amount: total,
          currency: currency,
          minAmount: 0,
          maxAmount: 100000000,
        ),
      );
    } on Object catch (error) {
      return ResultFailure<Money>(FirebaseErrorMapper.map(error));
    }
  }

  // --- Internals -------------------------------------------------------------

  /// Converts the ISO-8601 `createdAt` of [json] into a native
  /// [Timestamp] so the donation history stays ordered chronologically.
  Map<String, dynamic> _toFirestore(Map<String, dynamic> json) {
    final Object? createdAt = json[AppConstants.createdAtField];
    if (createdAt is String) {
      json[AppConstants.createdAtField] = Timestamp.fromDate(
        DateTime.tryParse(createdAt) ?? DateTime.now(),
      );
    } else if (createdAt is DateTime) {
      json[AppConstants.createdAtField] = Timestamp.fromDate(createdAt);
    }
    return json;
  }

  /// Inverse of [_toFirestore]: a `Timestamp` becomes an ISO-8601 string so
  /// `DonationModel.fromJson` can parse it instead of falling back to the epoch.
  DonationModel _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    final Object? createdAt = data[AppConstants.createdAtField];
    return DonationModel.fromJson(<String, dynamic>{
      'id': doc.id,
      ...data,
      if (createdAt is Timestamp)
        AppConstants.createdAtField: createdAt.toDate().toIso8601String(),
    });
  }

  List<DonationModel> _readCache() {
    final String raw =
        preferences.getString(AppConstants.cachedDonationsKey) ?? '';
    if (raw.isEmpty) {
      return <DonationModel>[];
    }
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(DonationModel.fromJson)
          .toList();
    } on Object {
      return <DonationModel>[];
    }
  }

  Future<void> _appendToCache(DonationModel donation) async {
    final List<DonationModel> donations = _readCache()
      ..removeWhere((DonationModel item) => item.id == donation.id)
      ..insert(0, donation);
    await preferences.setString(
      AppConstants.cachedDonationsKey,
      jsonEncode(donations.map((DonationModel item) => item.toJson()).toList()),
    );
  }

  Failure _asFailure(Object? error) {
    if (error is Failure) {
      return error;
    }
    return error == null
        ? const PaymentFailure('The payment provider did not answer.')
        : FirebaseErrorMapper.map(error);
  }

  String _generateId() => 'don-${DateTime.now().microsecondsSinceEpoch}';
}
