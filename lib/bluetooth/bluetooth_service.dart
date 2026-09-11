import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'bluetooth_device_info.dart';
import 'ftms_indoor_bike_data.dart';
import 'gatt_inspector.dart';

class BluetoothService extends ChangeNotifier {
  BluetoothService._() {
    unawaited(_initializePluginStreams());
  }

  static final BluetoothService instance = BluetoothService._();

  final Map<String, BluetoothDeviceInfo> _devices = {};
  final Map<String, StreamSubscription<BluetoothConnectionState>>
  _connectionSubscriptions = {};
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;
  BluetoothDeviceInfo? _connectedDevice;
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  bool _isScanning = false;
  bool _isConnecting = false;
  bool _isInspectingGatt = false;
  bool _isFtmsMonitoring = false;
  bool _isStartingFtmsMonitor = false;
  StreamSubscription<List<int>>? _ftmsSubscription;
  BluetoothCharacteristic? _ftmsCharacteristic;
  int _ftmsPacketCount = 0;
  final Set<int> _ftmsPacketLengths = {};
  final Set<int> _ftmsFlags = {};
  final FtmsIndoorBikeDataParser _ftmsParser = const FtmsIndoorBikeDataParser();
  String? _errorMessage;
  GattInspectionResult? _gattInspection;
  IndoorBikeData? _liveIndoorBikeData;

  List<BluetoothDeviceInfo> get devices {
    final values = _devices.values.toList();
    values.sort((left, right) {
      if (left.isLikelySchwinn != right.isLikelySchwinn) {
        return left.isLikelySchwinn ? -1 : 1;
      }
      if (left.name == 'Unnamed BLE device' &&
          right.name != 'Unnamed BLE device') {
        return 1;
      }
      if (right.name == 'Unnamed BLE device' &&
          left.name != 'Unnamed BLE device') {
        return -1;
      }
      return right.rssi.compareTo(left.rssi);
    });
    return List.unmodifiable(values);
  }

  BluetoothDeviceInfo? get connectedDevice => _connectedDevice;
  BluetoothAdapterState get adapterState => _adapterState;
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  bool get isInspectingGatt => _isInspectingGatt;
  bool get isFtmsMonitoring => _isFtmsMonitoring;
  String? get errorMessage => _errorMessage;
  GattInspectionResult? get gattInspection => _gattInspection;
  IndoorBikeData? get liveIndoorBikeData => _liveIndoorBikeData;

  String get headerDeviceName => _connectedDevice?.name ?? 'Schwinn IC8';

  String get headerConnectionStatus {
    if (_isConnecting) return 'Connecting';
    if (_connectedDevice?.connectionState ==
        RideDashDeviceConnectionState.connected) {
      return 'Connected';
    }
    return 'Disconnected';
  }

  Future<void> _initializePluginStreams() async {
    try {
      _scanSubscription = FlutterBluePlus.onScanResults.listen(
        _handleScanResults,
        onError: (Object error) {
          _setError('Scan failed: ${_shortError(error)}');
          _isScanning = false;
          notifyListeners();
        },
      );
      _adapterSubscription = FlutterBluePlus.adapterState.listen(
        _handleAdapterState,
        onError: (Object error) {
          _setError('Bluetooth adapter unavailable: ${_shortError(error)}');
          _adapterState = BluetoothAdapterState.unavailable;
          notifyListeners();
        },
      );
    } catch (error) {
      debugPrint('[RideDash BLE] Bluetooth platform unavailable: $error');
    }
  }

  Future<void> startScan() async {
    _errorMessage = null;
    _devices.clear();
    _isScanning = true;
    notifyListeners();
    debugPrint('[RideDash BLE] scan started');

    try {
      if (!await FlutterBluePlus.isSupported) {
        throw StateError('Bluetooth is not available on this Windows device.');
      }
      _adapterState = FlutterBluePlus.adapterStateNow;
      if (_adapterState != BluetoothAdapterState.on) {
        throw StateError(
          'Bluetooth is disabled. Turn it on in Windows settings.',
        );
      }
      debugPrint('Tutaj');
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 12));
    } catch (error) {
      _setError('Unable to scan: ${_shortError(error)}');
    } finally {
      _isScanning = false;
      notifyListeners();
      debugPrint('[RideDash BLE] scan stopped');
    }
  }

  Future<void> stopScan() async {
    if (!_isScanning && !FlutterBluePlus.isScanningNow) return;
    try {
      await FlutterBluePlus.stopScan();
    } catch (error) {
      _setError('Unable to stop scan: ${_shortError(error)}');
    } finally {
      _isScanning = false;
      notifyListeners();
      debugPrint('[RideDash BLE] scan stopped');
    }
  }

  Future<void> connect(BluetoothDeviceInfo info) async {
    await stopScan();
    _errorMessage = null;
    _isConnecting = true;
    info.connectionState = RideDashDeviceConnectionState.connecting;
    _listenForConnectionChanges(info);
    notifyListeners();
    debugPrint('[RideDash BLE] selected device ${info.identifier}');
    debugPrint('[RideDash BLE] connection attempt ${info.identifier}');

    try {
      await info.device.connect(
        license: License.commercial,
        timeout: const Duration(seconds: 20),
      );
      info.connectionState = RideDashDeviceConnectionState.connected;
      _connectedDevice = info;
      unawaited(_ensureLiveFtmsMonitor());
      debugPrint(
        '[RideDash BLE] connection success ${info.identifier}; ready for GATT discovery in RD-004',
      );
    } catch (error) {
      info.connectionState = RideDashDeviceConnectionState.disconnected;
      _setError('Connection failed: ${_shortError(error)}');
      debugPrint(
        '[RideDash BLE] connection failure ${info.identifier}: $error',
      );
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    final info = _connectedDevice;
    if (info == null) return;
    await stopFtmsMonitor();
    try {
      await info.device.disconnect();
    } catch (error) {
      _setError('Disconnect failed: ${_shortError(error)}');
    } finally {
      _gattInspection = null;
      _liveIndoorBikeData = null;
      info.connectionState = RideDashDeviceConnectionState.disconnected;
      _connectedDevice = null;
      _isConnecting = false;
      notifyListeners();
      debugPrint('[RideDash BLE] disconnect event ${info.identifier}');
    }
  }

  Future<void> startFtmsMonitor() async {
    if (_isFtmsMonitoring || _isStartingFtmsMonitor) {
      _setError('FTMS monitor is already running.');
      notifyListeners();
      return;
    }
    final info = _connectedDevice;
    final inspection = _gattInspection;
    if (info == null ||
        info.connectionState != RideDashDeviceConnectionState.connected ||
        inspection == null ||
        !inspection.ftmsDetected ||
        !inspection.indoorBikeDataDetected) {
      _setError('FTMS Indoor Bike Data is not available. Inspect GATT first.');
      notifyListeners();
      return;
    }

    GattCharacteristicInfo? feature;
    GattCharacteristicInfo? indoorBikeData;
    for (final service in inspection.services) {
      for (final characteristic in service.characteristics) {
        if (characteristic.uuid == GattUuidCatalog.fitnessMachineFeature) {
          feature = characteristic;
        }
        if (characteristic.uuid == GattUuidCatalog.indoorBikeData) {
          indoorBikeData = characteristic;
        }
      }
    }
    if (feature == null || indoorBikeData == null) {
      _setError('Required FTMS characteristics were not found.');
      notifyListeners();
      return;
    }

    _errorMessage = null;
    _isStartingFtmsMonitor = true;
    _ftmsPacketCount = 0;
    _ftmsPacketLengths.clear();
    _ftmsFlags.clear();
    try {
      await _readFtmsFeature(feature.characteristic);
      await indoorBikeData.characteristic.setNotifyValue(true);
      _ftmsCharacteristic = indoorBikeData.characteristic;
      _ftmsSubscription = _ftmsCharacteristic!.onValueReceived.listen(
        _handleFtmsPacket,
        onError: (Object error) {
          _setError('FTMS notification failed: ${_shortError(error)}');
          notifyListeners();
        },
      );
      _isFtmsMonitoring = true;
      debugPrint('=== RideDash FTMS Monitor Started ===');
      debugPrint('Device: ${info.name}');
      debugPrint('Service: 0x1826');
      debugPrint('Characteristic: 0x2AD2');
      debugPrint('===');
      notifyListeners();
    } catch (error) {
      _ftmsCharacteristic = null;
      await _ftmsSubscription?.cancel();
      _ftmsSubscription = null;
      _setError('Unable to start FTMS monitor: ${_shortError(error)}');
      notifyListeners();
    } finally {
      _isStartingFtmsMonitor = false;
    }
  }

  Future<void> _ensureLiveFtmsMonitor() async {
    if (_isFtmsMonitoring || _isStartingFtmsMonitor) return;
    if (_gattInspection == null) {
      await inspectGatt();
    }
    await startFtmsMonitor();
  }

  Future<void> stopFtmsMonitor() async {
    final wasMonitoring = _isFtmsMonitoring;
    _isFtmsMonitoring = false;
    final characteristic = _ftmsCharacteristic;
    _ftmsCharacteristic = null;
    await _ftmsSubscription?.cancel();
    _ftmsSubscription = null;
    if (characteristic != null) {
      try {
        await characteristic.setNotifyValue(false);
      } catch (error) {
        debugPrint(
          '[RideDash FTMS] Notification disable failed: ${_shortError(error)}',
        );
      }
    }
    if (wasMonitoring) {
      debugPrint('=== RideDash FTMS Monitor Stopped ===');
      debugPrint('Packets received: $_ftmsPacketCount');
      debugPrint('=== RideDash FTMS Session Summary ===');
      debugPrint('Packets: $_ftmsPacketCount');
      debugPrint(
        'Packet lengths: ${(_ftmsPacketLengths.toList()..sort()).toString()}',
      );
      final flags = _ftmsFlags.toList()..sort();
      debugPrint('Flags observed:');
      for (final value in flags) {
        debugPrint('0x${value.toRadixString(16).padLeft(4, '0')}');
      }
      debugPrint('=== End FTMS Session Summary ===');
      notifyListeners();
    }
  }

  Future<void> _readFtmsFeature(BluetoothCharacteristic characteristic) async {
    try {
      final value = await characteristic.read();
      debugPrint('=== RideDash FTMS Feature ===');
      debugPrint('RAW HEX: ${_hex(value)}');
      debugPrint('RAW DEC: $value');
      debugPrint('Length: ${value.length} bytes');
      debugPrint('=== End FTMS Feature ===');
    } catch (error) {
      debugPrint('[RideDash FTMS] Feature read failed: ${_shortError(error)}');
    }
  }

  void _handleFtmsPacket(List<int> value) {
    _ftmsPacketCount++;
    _ftmsPacketLengths.add(value.length);
    final time = DateTime.now().toIso8601String().substring(11, 23);
    debugPrint('[RideDash FTMS] Packet #$_ftmsPacketCount');
    debugPrint('Time: $time');
    debugPrint('Length: ${value.length}');
    debugPrint('HEX: ${_hex(value)}');
    debugPrint('DEC: $value');
    if (value.length < 2) {
      debugPrint('FLAGS RAW: unavailable (packet shorter than 2 bytes)');
      _setError('Received an empty or truncated FTMS notification.');
    } else {
      final flags = value[0] | (value[1] << 8);
      _ftmsFlags.add(flags);
      debugPrint('FLAGS RAW: 0x${flags.toRadixString(16).padLeft(4, '0')}');
    }
    try {
      _liveIndoorBikeData = _ftmsParser.parse(value);
      notifyListeners();
    } on FtmsPacketFormatException catch (error) {
      debugPrint('[RideDash FTMS] Parser rejected packet: ${error.message}');
    }
  }

  String _hex(List<int> value) => value
      .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
      .join(' ');

  Future<void> inspectGatt() async {
    final info = _connectedDevice;
    if (info == null ||
        info.connectionState != RideDashDeviceConnectionState.connected) {
      return;
    }
    _errorMessage = null;
    _isInspectingGatt = true;
    notifyListeners();
    try {
      _gattInspection = await GattInspector.inspect(info.device);
      if (_gattInspection!.services.isEmpty) {
        _setError('GATT discovery returned no services.');
      }
    } catch (error) {
      _gattInspection = null;
      _setError('GATT discovery failed: ${_shortError(error)}');
    } finally {
      _isInspectingGatt = false;
      notifyListeners();
    }
  }

  void _handleAdapterState(BluetoothAdapterState state) {
    _adapterState = state;
    if (state != BluetoothAdapterState.on && _isScanning) {
      _isScanning = false;
      _setError('Bluetooth is unavailable or disabled.');
    }
    notifyListeners();
  }

  void _handleScanResults(List<ScanResult> results) {
    for (final result in results) {
      final id = result.device.remoteId.str;
      final current = _devices[id];
      if (current == null) {
        final info = BluetoothDeviceInfo.fromScanResult(result);
        _devices[id] = info;
        if (info.name != 'Unnamed BLE device') {
          debugPrint(
            '[RideDash BLE] discovered named device ${info.name} ($id)',
          );
        }
      } else {
        current.updateFrom(result);
      }
    }
    notifyListeners();
  }

  void _listenForConnectionChanges(BluetoothDeviceInfo info) {
    if (_connectionSubscriptions.containsKey(info.identifier)) return;
    _connectionSubscriptions[info.identifier] = info.device.connectionState
        .listen((state) {
          if (state == BluetoothConnectionState.connected) {
            info.connectionState = RideDashDeviceConnectionState.connected;
            _connectedDevice = info;
            debugPrint('[RideDash BLE] connection success ${info.identifier}');
          } else {
            unawaited(stopFtmsMonitor());
            _gattInspection = null;
            _liveIndoorBikeData = null;
            info.connectionState = RideDashDeviceConnectionState.disconnected;
            if (_connectedDevice?.identifier == info.identifier) {
              _connectedDevice = null;
              debugPrint('[RideDash BLE] disconnect event ${info.identifier}');
            }
          }
          notifyListeners();
        });
  }

  void _setError(String message) {
    _errorMessage = message;
    debugPrint('[RideDash BLE] $message');
  }

  String _shortError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    return message.length > 140 ? '${message.substring(0, 140)}...' : message;
  }

  @override
  void dispose() {
    unawaited(stopFtmsMonitor());
    _scanSubscription?.cancel();
    _adapterSubscription?.cancel();
    for (final subscription in _connectionSubscriptions.values) {
      subscription.cancel();
    }
    super.dispose();
  }
}
