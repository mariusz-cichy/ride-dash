import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum RideDashDeviceConnectionState { disconnected, connecting, connected }

class BluetoothDeviceInfo {
  BluetoothDeviceInfo({
    required this.device,
    required this.name,
    required this.identifier,
    required this.rssi,
    required this.isLikelySchwinn,
    this.connectionState = RideDashDeviceConnectionState.disconnected,
  });

  final BluetoothDevice device;
  String name;
  final String identifier;
  int rssi;
  bool isLikelySchwinn;
  RideDashDeviceConnectionState connectionState;

  void updateFrom(ScanResult result) {
    final advertisedName = result.advertisementData.advName.trim();
    final platformName = result.device.platformName.trim();
    final nextName = advertisedName.isNotEmpty
        ? advertisedName
        : platformName.isNotEmpty
        ? platformName
        : 'Unnamed BLE device';

    if (nextName != 'Unnamed BLE device') {
      name = nextName;
    }
    rssi = result.rssi;
    isLikelySchwinn = _isLikelySchwinn(name);
  }

  static BluetoothDeviceInfo fromScanResult(ScanResult result) {
    final advertisedName = result.advertisementData.advName.trim();
    final platformName = result.device.platformName.trim();
    final name = advertisedName.isNotEmpty
        ? advertisedName
        : platformName.isNotEmpty
        ? platformName
        : 'Unnamed BLE device';

    return BluetoothDeviceInfo(
      device: result.device,
      name: name,
      identifier: result.device.remoteId.str,
      rssi: result.rssi,
      isLikelySchwinn: _isLikelySchwinn(name),
    );
  }

  static bool _isLikelySchwinn(String name) {
    final normalized = name.toLowerCase();
    return normalized.contains('schwinn') ||
        normalized.contains('ic8') ||
        normalized.contains('800ic') ||
        normalized.contains('ic bike');
  }
}
