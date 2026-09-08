import 'dart:async';

import 'package:flutter/material.dart';

import '../bluetooth/bluetooth_device_info.dart';
import '../bluetooth/bluetooth_service.dart';
import '../theme/ride_dash_theme.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_sidebar.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final BluetoothService _bluetoothService = BluetoothService.instance;
  late DateTime _currentTime;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  String get _time {
    final hour = _currentTime.hour.toString().padLeft(2, '0');
    final minute = _currentTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get _date {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[_currentTime.weekday - 1]}, ${_currentTime.day} ${months[_currentTime.month - 1]} ${_currentTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DashboardSidebar(
              dashboardSelected: false,
              bluetoothSelected: true,
              onDashboard: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _bluetoothService,
                    builder: (context, _) => DashboardHeader(
                      currentTime: _time,
                      currentDate: _date,
                      deviceName: _bluetoothService.headerDeviceName,
                      connectionStatus:
                          _bluetoothService.headerConnectionStatus,
                    ),
                  ),
                  Expanded(
                    child: _BluetoothContent(service: _bluetoothService),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BluetoothContent extends StatelessWidget {
  const _BluetoothContent({required this.service});

  final BluetoothService service;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            border: Border(
              left: BorderSide(color: rideDashBorder),
              top: BorderSide(color: rideDashBorder),
            ),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(18)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(40, 42, 40, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'BLUETOOTH DEVICES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Find and connect to a nearby BLE cycling device.',
                      style: TextStyle(
                        color: rideDashSecondaryText,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: service.isScanning
                              ? service.stopScan
                              : service.startScan,
                          icon: Icon(
                            service.isScanning
                                ? Icons.stop
                                : Icons.bluetooth_searching,
                          ),
                          label: Text(
                            service.isScanning
                                ? 'STOP SCAN'
                                : 'SCAN FOR DEVICES',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: rideDashRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 18,
                            ),
                          ),
                        ),
                        if (service.isScanning) ...[
                          const SizedBox(width: 18),
                          const Text(
                            'SCANNING...',
                            style: TextStyle(
                              color: rideDashRed,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (service.errorMessage != null) ...[
                      const SizedBox(height: 20),
                      _MessagePanel(
                        message: service.errorMessage!,
                        isError: true,
                      ),
                    ],
                    const SizedBox(height: 28),
                    if (service.devices.isEmpty && !service.isScanning)
                      const _MessagePanel(
                        message: 'No BLE devices found yet. Start a scan to search nearby devices.',
                      ),
                    for (final device in service.devices) ...[
                      _DeviceTile(device: device, service: service),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.device, required this.service});

  final BluetoothDeviceInfo device;
  final BluetoothService service;

  @override
  Widget build(BuildContext context) {
    final connected =
        device.connectionState == RideDashDeviceConnectionState.connected;
    final connecting =
        device.connectionState == RideDashDeviceConnectionState.connecting;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
      decoration: BoxDecoration(
        color: rideDashPanel,
        border: Border.all(
          color: device.isLikelySchwinn ? rideDashRed : rideDashBorder,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            device.isLikelySchwinn ? Icons.directions_bike : Icons.bluetooth,
            color: device.isLikelySchwinn ? rideDashRed : rideDashSecondaryText,
            size: 30,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        device.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (device.isLikelySchwinn) ...[
                      const SizedBox(width: 12),
                      const Text(
                        'LIKELY IC8',
                        style: TextStyle(
                          color: rideDashRed,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  device.identifier,
                  style: const TextStyle(
                    color: rideDashSecondaryText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'RSSI ${device.rssi} dBm  |  ${_stateLabel(device.connectionState)}',
                  style: TextStyle(
                    color: connected
                        ? const Color(0xFF55F05B)
                        : rideDashSecondaryText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (connected)
            OutlinedButton.icon(
              onPressed: service.disconnect,
              icon: const Icon(Icons.link_off),
              label: const Text('DISCONNECT'),
              style: OutlinedButton.styleFrom(
                foregroundColor: rideDashRed,
                side: const BorderSide(color: rideDashRed),
              ),
            )
          else
            ElevatedButton(
              onPressed: connecting ? null : () => service.connect(device),
              style: ElevatedButton.styleFrom(
                backgroundColor: rideDashRed,
                foregroundColor: Colors.white,
              ),
              child: Text(connecting ? 'CONNECTING...' : 'CONNECT'),
            ),
        ],
      ),
    );
  }

  String _stateLabel(RideDashDeviceConnectionState state) {
    switch (state) {
      case RideDashDeviceConnectionState.connected:
        return 'CONNECTED';
      case RideDashDeviceConnectionState.connecting:
        return 'CONNECTING';
      case RideDashDeviceConnectionState.disconnected:
        return 'DISCONNECTED';
    }
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({required this.message, this.isError = false});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: rideDashPanel,
        border: Border.all(color: isError ? rideDashRed : rideDashBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isError ? Colors.white : rideDashSecondaryText,
          fontSize: 15,
        ),
      ),
    );
  }
}
