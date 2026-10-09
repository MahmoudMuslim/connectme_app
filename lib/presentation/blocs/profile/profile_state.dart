import 'package:equatable/equatable.dart';

import '../../../domain/entities/device_info.dart';
import '../../../domain/entities/user.dart';

/// Status axis of [ProfileCubit].
enum ProfileStatus {
  /// Reading the device information for the first time.
  loading,

  /// The profile is ready to be rendered.
  ready,

  /// Something went wrong while reading the device information.
  error,
}

/// Immutable state of [ProfileCubit].
class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.loading,
    this.user,
    this.deviceInfo,
    this.errorMessage,
    this.isUpdatingPhoto = false,
    this.isBiometricAvailable = false,
    this.biometricLabel = 'Biometrics',
  });

  final ProfileStatus status;

  /// The signed-in member.
  final User? user;

  /// Device model / OS version rendered by the "Device" card.
  final DeviceInfo? deviceInfo;

  final String? errorMessage;

  /// `true` while the picked photo is being resized and uploaded.
  final bool isUpdatingPhoto;

  /// `true` when the device exposes a usable biometric sensor.
  final bool isBiometricAvailable;

  /// "Fingerprint" / "Face ID", shown in the profile gate dialog.
  final String biometricLabel;

  ProfileState copyWith({
    ProfileStatus? status,
    User? user,
    DeviceInfo? deviceInfo,
    String? errorMessage,
    bool? isUpdatingPhoto,
    bool? isBiometricAvailable,
    String? biometricLabel,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isUpdatingPhoto: isUpdatingPhoto ?? this.isUpdatingPhoto,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      biometricLabel: biometricLabel ?? this.biometricLabel,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    user,
    deviceInfo,
    errorMessage,
    isUpdatingPhoto,
    isBiometricAvailable,
    biometricLabel,
  ];
}
