import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../core/errors/firebase_error_mapper.dart';
import '../../../core/result/result.dart';
import '../../../domain/entities/device_info.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/get_device_info.dart';
import '../../../domain/usecases/update_display_name.dart';
import '../../../domain/usecases/update_profile_photo.dart';
import '../../../domain/usecases/verify_biometrics.dart';
import '../../../services/image_picker_service.dart';
import 'profile_state.dart';

/// **CUBIT** backing the biometric-gated profile screen.
///
/// Requirement 3 covers three things, all handled here:
/// * biometric verification before navigation ([VerifyBiometrics]),
/// * the device model / OS version ([GetDeviceInfo] + `device_info_plus`),
/// * the gallery picker + Firestore upload of the profile photo
///   ([UpdateProfilePhoto] + `image_picker`).
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this.getDeviceInfo,
    required this.updateProfilePhoto,
    required this.updateDisplayName,
    required this.verifyBiometrics,
    required this.imagePickerService,
  }) : super(const ProfileState());

  /// Reads the device model / OS version.
  final GetDeviceInfo getDeviceInfo;

  /// Uploads a new profile picture.
  final UpdateProfilePhoto updateProfilePhoto;

  /// Renames the member.
  final UpdateDisplayName updateDisplayName;

  /// Runs the native biometric challenge.
  final VerifyBiometrics verifyBiometrics;

  /// Opens the gallery and encodes the selection.
  final ImagePickerService imagePickerService;

  /// Loads the device information and probes the biometric sensor.
  Future<void> load(User user) async {
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        status: ProfileStatus.loading,
        user: user,
        clearError: true,
      ),
    );

    final Result<DeviceInfo> deviceInfo = await getDeviceInfo();
    final Result<bool> biometrics = await _probeBiometrics();
    if (isClosed) {
      return;
    }

    final bool available = biometrics.valueOrNull ?? false;
    final String label = available
        ? await verifyBiometrics.label()
        : 'Biometrics';
    if (isClosed) {
      return;
    }

    deviceInfo.fold(
      onSuccess: (DeviceInfo info) => emit(
        state.copyWith(
          status: ProfileStatus.ready,
          deviceInfo: info,
          isBiometricAvailable: available,
          biometricLabel: label,
          clearError: true,
        ),
      ),
      onFailure: (Object failure) => emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: _messageOf(failure),
          isBiometricAvailable: available,
          biometricLabel: label,
        ),
      ),
    );
  }

  /// Runs the biometric challenge that guards the profile screen.
  ///
  /// Returns `true` when the profile may be opened. Devices without an enrolled
  /// sensor are let through with an explanatory message so the screen is still
  /// reachable on an emulator — the gate is enforced strictly as soon as a
  /// sensor exists.
  Future<bool> authenticate({required String reason}) async {
    if (!await verifyBiometrics.isAvailable()) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isBiometricAvailable: false,
            errorMessage:
                'Biometrics are not set up on this device, so the profile was '
                'opened without verification.',
          ),
        );
      }
      return true;
    }

    final Result<bool> result = await verifyBiometrics(reason: reason);
    if (isClosed) {
      return false;
    }
    return result.fold(
      onSuccess: (bool authenticated) {
        emit(state.copyWith(isBiometricAvailable: true, clearError: true));
        return authenticated;
      },
      onFailure: (Object failure) {
        emit(state.copyWith(errorMessage: _messageOf(failure)));
        return false;
      },
    );
  }

  /// Opens the gallery and uploads the selection to Firestore.
  ///
  /// Returns `true` when a photo was stored.
  Future<bool> pickAndUploadPhoto() async {
    final Result<String?> picked = await imagePickerService.pickProfilePhoto();
    if (isClosed) {
      return false;
    }
    final String? dataUrl = picked.failureOrNull != null
        ? null
        : picked.valueOrNull;
    if (picked.failureOrNull != null) {
      emit(state.copyWith(errorMessage: _messageOf(picked.failureOrNull!)));
      return false;
    }
    if (dataUrl == null) {
      return false;
    }
    return uploadPhoto(dataUrl);
  }

  /// Uploads an already encoded `data:` URL.
  Future<bool> uploadPhoto(String dataUrl) async {
    final User? user = state.user;
    if (user == null) {
      return false;
    }
    emit(state.copyWith(isUpdatingPhoto: true, clearError: true));
    final Result<User> result = await updateProfilePhoto(
      userId: user.id,
      photoUrl: dataUrl,
    );
    if (isClosed) {
      return false;
    }
    return result.fold(
      onSuccess: (User updated) {
        // The new photo is pushed into the state, so the UI reflects it
        // immediately without waiting for a Firestore round-trip.
        emit(state.copyWith(isUpdatingPhoto: false, user: updated));
        return true;
      },
      onFailure: (Object failure) {
        emit(
          state.copyWith(
            isUpdatingPhoto: false,
            errorMessage: _messageOf(failure),
          ),
        );
        return false;
      },
    );
  }

  /// Renames the member.
  Future<bool> rename(String fullName) async {
    final User? user = state.user;
    if (user == null) {
      return false;
    }
    final Result<User> result = await updateDisplayName(
      userId: user.id,
      fullName: fullName,
    );
    if (isClosed) {
      return false;
    }
    return result.fold(
      onSuccess: (User updated) {
        emit(state.copyWith(user: updated));
        return true;
      },
      onFailure: (Object failure) {
        emit(state.copyWith(errorMessage: _messageOf(failure)));
        return false;
      },
    );
  }

  /// Clears the last error (used before reopening a dialog).
  void clearError() {
    if (state.errorMessage == null || isClosed) {
      return;
    }
    emit(state.copyWith(clearError: true));
  }

  Future<Result<bool>> _probeBiometrics() async {
    try {
      return Success<bool>(await verifyBiometrics.isAvailable());
    } on Object catch (error) {
      return ResultFailure<bool>(FirebaseErrorMapper.map(error));
    }
  }

  String _messageOf(Object failure) {
    if (failure is Failure) {
      return failure.message;
    }
    return FirebaseErrorMapper.messageOf(failure);
  }
}
