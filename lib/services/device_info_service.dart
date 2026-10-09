import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import '../core/errors/firebase_error_mapper.dart';
import '../core/result/result.dart';
import '../domain/entities/device_info.dart';
import '../domain/usecases/get_device_info.dart';

/// **SINGLETON** wrapper around `device_info_plus`.
///
/// Requirement 3: "The Profile Screen must display ... their device model and
/// OS version fetched using device_info_plus."
///
/// The six very different platform payloads are normalised into a single
/// [DeviceInfo] entity, so the rest of the app never touches `AndroidDeviceInfo`,
/// `IosDeviceInfo`, ... The value is memoised because the profile screen and the
/// sign-up form both need it and the plugin is comparatively slow.
class DeviceInfoService implements DeviceInfoRepository {
  DeviceInfoService();

  static DeviceInfoService? _instance;

  static DeviceInfoService get instance => _instance ??= DeviceInfoService();

  static void registerInstance(DeviceInfoService service) {
    _instance = service;
  }

  final DeviceInfoPlugin _plugin = DeviceInfoPlugin();

  DeviceInfo? _cached;

  @override
  Future<Result<DeviceInfo>> read() async {
    final DeviceInfo? cached = _cached;
    if (cached != null) {
      return Success<DeviceInfo>(cached);
    }
    try {
      final DeviceInfo info = await _read();
      _cached = info;
      return Success<DeviceInfo>(info);
    } on Object catch (error) {
      return ResultFailure<DeviceInfo>(FirebaseErrorMapper.map(error));
    }
  }

  /// Drops the memoised value (used by tests).
  void invalidate() => _cached = null;

  Future<DeviceInfo> _read() async {
    if (kIsWeb) {
      return _fromWeb();
    }
    if (Platform.isAndroid) {
      return _fromAndroid();
    }
    if (Platform.isIOS) {
      return _fromIos();
    }
    if (Platform.isWindows) {
      return _fromWindows();
    }
    if (Platform.isMacOS) {
      return _fromMacOs();
    }
    if (Platform.isLinux) {
      return _fromLinux();
    }
    throw UnsupportedError('Unsupported platform');
  }

  Future<DeviceInfo> _fromAndroid() async {
    final AndroidDeviceInfo info = await _plugin.androidInfo;
    return DeviceInfo(
      model: info.model,
      osVersion: 'Android ${info.version.release} (API ${info.version.sdkInt})',
      platformName: 'Android',
      deviceName: info.device,
      manufacturer: info.manufacturer,
      uniqueId: info.id,
      isPhysicalDevice: info.isPhysicalDevice,
    );
  }

  Future<DeviceInfo> _fromIos() async {
    final IosDeviceInfo info = await _plugin.iosInfo;
    return DeviceInfo(
      model: info.modelName,
      osVersion: '${info.systemName} ${info.systemVersion}',
      platformName: 'iOS',
      deviceName: info.name,
      manufacturer: 'Apple',
      uniqueId: info.identifierForVendor ?? info.utsname.machine,
      isPhysicalDevice: info.isPhysicalDevice,
    );
  }

  Future<DeviceInfo> _fromWindows() async {
    final WindowsDeviceInfo info = await _plugin.windowsInfo;
    return DeviceInfo(
      model: info.computerName,
      osVersion: 'Windows ${info.displayVersion}',
      platformName: 'Windows',
      deviceName: info.computerName,
      // Windows does not expose a manufacturer: derive it from the product
      // name ("Windows 10 Pro" -> the vendor is unknown on desktops).
      manufacturer: _vendorFromWindowsProduct(info.productName),
      uniqueId: info.deviceId.isEmpty ? info.computerName : info.deviceId,
    );
  }

  Future<DeviceInfo> _fromMacOs() async {
    final MacOsDeviceInfo info = await _plugin.macOsInfo;
    return DeviceInfo(
      model: info.model,
      osVersion: 'macOS ${info.osRelease}',
      platformName: 'macOS',
      deviceName: info.hostName,
      manufacturer: 'Apple',
      uniqueId: info.systemGUID ?? info.hostName,
    );
  }

  Future<DeviceInfo> _fromLinux() async {
    final LinuxDeviceInfo info = await _plugin.linuxInfo;
    return DeviceInfo(
      model: info.prettyName,
      osVersion: info.version == null
          ? info.name
          : '${info.name} ${info.version}',
      platformName: 'Linux',
      deviceName: info.name,
      manufacturer: 'Unknown',
      uniqueId: info.machineId ?? info.id,
    );
  }

  Future<DeviceInfo> _fromWeb() async {
    final WebBrowserInfo info = await _plugin.webBrowserInfo;
    return DeviceInfo(
      model: info.vendor?.isNotEmpty ?? false ? info.vendor! : 'Web browser',
      osVersion: info.platform ?? 'Web',
      platformName: info.platform ?? 'Web',
      deviceName: info.browserName.name,
      manufacturer: info.vendor ?? 'Unknown',
      uniqueId: 'web',
      isPhysicalDevice: false,
    );
  }

  String _vendorFromWindowsProduct(String productName) {
    // Product names look like "Windows 10 Pro" / "Windows 11 Home"; the vendor
    // is genuinely unknown from the OS API, so surface it as such rather than
    // inventing a value.
    return productName.startsWith('Windows') ? 'PC vendor' : 'Unknown';
  }
}
