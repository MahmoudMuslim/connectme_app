import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/device_info.dart';

/// Card showing the device model and OS version captured with
/// `device_info_plus`.
///
/// Requirement 3: "The Profile Screen must display ... their device model and OS
/// version fetched using device_info_plus."
class DeviceInfoCard extends StatelessWidget {
  const DeviceInfoCard({
    required this.deviceInfo,
    this.isLoading = false,
    super.key,
  });

  /// `null` while the plugin is still answering.
  final DeviceInfo? deviceInfo;

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final DeviceInfo? info = deviceInfo;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.screenBackground,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.devices_rounded,
                size: 20,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('This device', style: AppTypography.sectionTitle),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isLoading && info == null)
            const _DeviceRow(label: 'Reading device information...')
          else if (info == null)
            const _DeviceRow(label: 'Device information is unavailable.')
          else ...<Widget>[
            _DeviceRow(
              label: 'Model',
              value: info.summary,
              icon: Icons.smartphone_rounded,
            ),
            const Divider(height: AppSpacing.lg),
            _DeviceRow(
              label: 'OS version',
              value: info.osVersion,
              icon: Icons.memory_rounded,
            ),
            const Divider(height: AppSpacing.lg),
            _DeviceRow(
              label: 'Device name',
              value: info.deviceName,
              icon: Icons.badge_outlined,
            ),
            const Divider(height: AppSpacing.lg),
            _DeviceRow(
              label: 'Manufacturer',
              value: info.manufacturer.isEmpty ? 'Unknown' : info.manufacturer,
              icon: Icons.factory_outlined,
            ),
            const Divider(height: AppSpacing.lg),
            _DeviceRow(
              label: 'Device type',
              value: info.isPhysicalDevice ? 'Physical device' : 'Emulator',
              icon: Icons.phonelink_setup_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

/// `label : value` row of the device card.
class _DeviceRow extends StatelessWidget {
  const _DeviceRow({required this.label, this.value, this.icon});

  final String label;
  final String? value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: AppSpacing.xs),
          ],
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '',
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
