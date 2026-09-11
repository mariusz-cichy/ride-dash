import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

class GattUuidCatalog {
  static const fitnessMachineService = '00001826-0000-1000-8000-00805f9b34fb';
  static const fitnessMachineFeature = '00002acc-0000-1000-8000-00805f9b34fb';
  static const indoorBikeData = '00002ad2-0000-1000-8000-00805f9b34fb';
  static const fitnessMachineControlPoint =
      '00002ad9-0000-1000-8000-00805f9b34fb';
  static const fitnessMachineStatus = '00002ada-0000-1000-8000-00805f9b34fb';
  static const deviceInformationService =
      '0000180a-0000-1000-8000-00805f9b34fb';
  static const heartRateService = '0000180d-0000-1000-8000-00805f9b34fb';
  static const batteryService = '0000180f-0000-1000-8000-00805f9b34fb';

  static const _names = <String, String>{
    fitnessMachineService: 'Fitness Machine Service',
    fitnessMachineFeature: 'Fitness Machine Feature',
    indoorBikeData: 'Indoor Bike Data',
    fitnessMachineControlPoint: 'Fitness Machine Control Point',
    fitnessMachineStatus: 'Fitness Machine Status',
    deviceInformationService: 'Device Information Service',
    heartRateService: 'Heart Rate Service',
    batteryService: 'Battery Service',
  };

  static String normalize(String uuid) {
    var value = uuid.toLowerCase().trim();
    value = value.replaceAll('{', '').replaceAll('}', '');
    value = value.replaceFirst('urn:uuid:', '');
    if (value.length == 4) {
      value = '0000$value-0000-1000-8000-00805f9b34fb';
    } else if (value.length == 8) {
      value = '$value-0000-1000-8000-00805f9b34fb';
    }
    return value;
  }

  static String? nameFor(String uuid) => _names[normalize(uuid)];
}

class GattCharacteristicInfo {
  const GattCharacteristicInfo({
    required this.name,
    required this.uuid,
    required this.properties,
    required this.canRead,
    required this.characteristic,
  });

  final String? name;
  final String uuid;
  final List<String> properties;
  final bool canRead;
  final fbp.BluetoothCharacteristic characteristic;
}

class GattServiceInfo {
  const GattServiceInfo({
    required this.name,
    required this.uuid,
    required this.characteristics,
  });

  final String? name;
  final String uuid;
  final List<GattCharacteristicInfo> characteristics;
}

class GattInspectionResult {
  const GattInspectionResult({
    required this.services,
    required this.ftmsDetected,
    required this.indoorBikeDataDetected,
  });

  final List<GattServiceInfo> services;
  final bool ftmsDetected;
  final bool indoorBikeDataDetected;
}

class GattInspector {
  static Future<GattInspectionResult> inspect(
    fbp.BluetoothDevice device,
  ) async {
    final services = await device.discoverServices();
    final serviceReports = <GattServiceInfo>[];
    var ftmsDetected = false;
    var indoorBikeDataDetected = false;

    for (final service in services) {
      final serviceUuid = GattUuidCatalog.normalize(service.uuid.str);
      ftmsDetected |= serviceUuid == GattUuidCatalog.fitnessMachineService;
      final characteristics = <GattCharacteristicInfo>[];
      for (final characteristic in service.characteristics) {
        final properties = <String>[];
        if (characteristic.properties.read) properties.add('READ');
        if (characteristic.properties.write) properties.add('WRITE');
        if (characteristic.properties.writeWithoutResponse) {
          properties.add('WRITE WITHOUT RESPONSE');
        }
        if (characteristic.properties.notify) properties.add('NOTIFY');
        if (characteristic.properties.indicate) properties.add('INDICATE');
        final characteristicUuid = GattUuidCatalog.normalize(
          characteristic.uuid.str,
        );
        indoorBikeDataDetected |=
            characteristicUuid == GattUuidCatalog.indoorBikeData;
        characteristics.add(
          GattCharacteristicInfo(
            name: GattUuidCatalog.nameFor(characteristicUuid),
            uuid: characteristicUuid,
            properties: List.unmodifiable(properties),
            canRead: characteristic.properties.read,
            characteristic: characteristic,
          ),
        );
      }
      serviceReports.add(
        GattServiceInfo(
          name: GattUuidCatalog.nameFor(serviceUuid),
          uuid: serviceUuid,
          characteristics: List.unmodifiable(characteristics),
        ),
      );
    }

    final result = GattInspectionResult(
      services: List.unmodifiable(serviceReports),
      ftmsDetected: ftmsDetected,
      indoorBikeDataDetected: indoorBikeDataDetected,
    );
    _printReport(device, result);
    return result;
  }

  static void _printReport(
    fbp.BluetoothDevice device,
    GattInspectionResult result,
  ) {
    final report = StringBuffer()
      ..writeln('=== RideDash GATT Inspector ===')
      ..writeln('Device: ${device.platformName}')
      ..writeln('Device ID: ${device.remoteId.str}');
    for (final service in result.services) {
      report
        ..writeln()
        ..writeln('Service: ${service.name ?? 'Unknown Service'}')
        ..writeln('UUID: ${service.uuid}');
      for (final characteristic in service.characteristics) {
        report
          ..writeln()
          ..writeln(
            '  Characteristic: ${characteristic.name ?? 'Unknown Characteristic'}',
          )
          ..writeln('  UUID: ${characteristic.uuid}')
          ..writeln('  Properties: ${characteristic.properties.join(', ')}');
      }
    }
    report
      ..writeln()
      ..writeln('FTMS detected: ${result.ftmsDetected}')
      ..writeln('Indoor Bike Data detected: ${result.indoorBikeDataDetected}')
      ..writeln('=== End GATT Report ===');
    debugPrint(report.toString());
  }
}
