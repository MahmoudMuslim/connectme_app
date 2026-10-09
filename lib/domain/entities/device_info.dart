import 'package:equatable/equatable.dart';

/// Snapshot of the hardware/OS the app is currently running on, produced by
/// `device_info_plus` inside `DeviceInfoService`.
///
/// It is rendered by the "Device" card of the profile screen and persisted on
/// the user document at sign-up time.
class DeviceInfo extends Equatable {
  const DeviceInfo({
    required this.model,
    required this.osVersion,
    required this.platformName,
    required this.deviceName,
    required this.manufacturer,
    required this.uniqueId,
    this.isPhysicalDevice = true,
  });

  /// Marketing model, e.g. `Pixel 8 Pro`.
  final String model;

  /// Operating system version, e.g. `Android 14 (API 34)`.
  final String osVersion;

  /// `Android`, `iOS`, `Windows`, `Web`...
  final String platformName;

  /// Device name as reported by the OS, e.g. `sdk_gphone64`.
  final String deviceName;

  /// Hardware manufacturer, e.g. `Google`.
  final String manufacturer;

  /// Stable per-installation identifier.
  final String uniqueId;

  final bool isPhysicalDevice;

  /// `Google · Pixel 8 Pro` — the headline of the device card.
  String get summary => manufacturer.isEmpty ? model : '$manufacturer · $model';

  @override
  List<Object?> get props => <Object?>[
    model,
    osVersion,
    platformName,
    deviceName,
    manufacturer,
    uniqueId,
    isPhysicalDevice,
  ];
}
