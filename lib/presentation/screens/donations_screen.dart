import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/time_formatter.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/donation.dart';
import '../../domain/entities/money.dart';
import '../../domain/entities/user.dart';
import '../blocs/donation/donation_cubit.dart';
import '../blocs/donation/donation_state.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/connectme_snack_bar.dart';
import '../widgets/donation_card.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_view.dart';
import '../widgets/profile_gate.dart';

/// Community fund screen.
///
/// The whole payment flow is SOLID: the screen only collects an amount, the
/// `Money` value object validates it, the `CreateDonation` use case applies the
/// business rules and the `PaymentGateway` implementation performs the charge.
class DonationsScreen extends StatelessWidget {
  const DonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(title: const Text('Community Fund')),
      body: BlocConsumer<DonationCubit, DonationState>(
        listenWhen: (DonationState previous, DonationState current) =>
            (previous.errorMessage != current.errorMessage &&
                current.errorMessage != null) ||
            (previous.successMessage != current.successMessage &&
                current.successMessage != null),
        listener: (BuildContext context, DonationState state) {
          if (state.errorMessage != null) {
            ConnectMeSnackBar.showError(context, state.errorMessage!);
            context.read<DonationCubit>().clearError();
          }
          if (state.successMessage != null) {
            ConnectMeSnackBar.showSuccess(context, state.successMessage!);
            context.read<DonationCubit>().clearSuccess();
          }
        },
        builder: (BuildContext context, DonationState state) {
          return RefreshIndicator(
            onRefresh: () async {
              await context.read<DonationCubit>().loadTotalRaised();
            },
            color: AppColors.primaryDark,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.md,
                AppSpacing.screenHorizontal,
                96,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                DonationTotalBanner(totalRaised: state.totalRaised),
                const SizedBox(height: AppSpacing.md),
                _DonationComposer(isSubmitting: state.isSubmitting),
                const SizedBox(height: AppSpacing.lg),
                Text('Recent support', style: AppTypography.sectionTitle),
                const SizedBox(height: AppSpacing.sm),
                _DonationHistory(state: state),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Gradient banner with the total amount raised.
class DonationTotalBanner extends StatelessWidget {
  const DonationTotalBanner({required this.totalRaised, super.key});

  final Money? totalRaised;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.volunteer_activism_rounded,
            color: AppColors.white,
            size: 30,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Raised by the community',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  totalRaised?.compact ?? '—',
                  style: AppTypography.displayName.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Amount + message form that triggers the charge.
class _DonationComposer extends StatefulWidget {
  const _DonationComposer({required this.isSubmitting});

  final bool isSubmitting;

  @override
  State<_DonationComposer> createState() => _DonationComposerState();
}

class _DonationComposerState extends State<_DonationComposer> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  static const List<double> _presets = <double>[5, 20, 50];

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Support the community', style: AppTypography.sectionTitle),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              children: _presets
                  .map(
                    (double amount) => ActionChip(
                      label: Text(amount.toStringAsFixed(0)),
                      backgroundColor: AppColors.accentTint,
                      labelStyle: AppTypography.caption.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                      onPressed: () =>
                          _amountController.text = amount.toStringAsFixed(0),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: 'Amount',
                prefixText: '${AppConstants.defaultCurrency} ',
                prefixStyle: AppTypography.body,
              ),
              validator: (String? value) => Validators.donationAmount(
                value,
                min: AppConstants.minDonationAmount,
                max: AppConstants.maxDonationAmount,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _messageController,
              maxLength: 140,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Add a message (optional)',
                counterText: '',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppPrimaryButton(
              label: 'Donate now',
              icon: Icons.favorite_rounded,
              isLoading: widget.isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final User user = ProfileGate.currentUser(context);
    Money money;
    try {
      // The value object is the only place the amount rules are enforced.
      money = Money.parse(
        _amountController.text,
        currency: AppConstants.defaultCurrency,
      );
    } on ValidationException catch (error) {
      ConnectMeSnackBar.showError(context, error.message);
      return;
    }

    final bool charged = await context.read<DonationCubit>().donate(
      donorId: user.id,
      donorName: user.fullName,
      money: money,
      message: _messageController.text,
    );
    if (charged && mounted) {
      _amountController.clear();
      _messageController.clear();
    }
  }
}

/// Community donation history.
class _DonationHistory extends StatelessWidget {
  const _DonationHistory({required this.state});

  final DonationState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == DonationLoadStatus.loading && state.donations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryDark),
        ),
      );
    }
    if (state.status == DonationLoadStatus.error) {
      return ErrorView(message: state.errorMessage ?? 'Donations unavailable.');
    }
    if (state.donations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: EmptyStateView(
          icon: Icons.volunteer_activism_outlined,
          title: 'No donations yet',
          message: 'Be the first member to support the community fund.',
        ),
      );
    }
    return Column(
      children: state.donations
          .map(
            (Donation donation) => DonationCard(
              donation: donation,
              timestampLabel: TimeFormatter.relative(donation.createdAt),
            ),
          )
          .toList(),
    );
  }
}
