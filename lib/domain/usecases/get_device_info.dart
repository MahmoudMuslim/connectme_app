import '../../core/result/result.dart';
import '../entities/device_info.dart';

/// Contract of the `device_info_plus` wrapper.
abstract interface class DeviceInfoRepository {
  /// Reads the model / OS / manufacturer of the current device.
  Future<Result<DeviceInfo>> read();
}

/// Use case feeding the "Device" card of the profile screen and the sign-up
/// payload (requirement 3).
class GetDeviceInfo {
  const GetDeviceInfo(this._repository);

  final DeviceInfoRepository _repository;

  Future<Result<DeviceInfo>> call() => _repository.read();
}
