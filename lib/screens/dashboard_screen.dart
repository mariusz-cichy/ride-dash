import 'dart:async';

import 'package:flutter/material.dart';

import '../bluetooth/bluetooth_service.dart';
import '../theme/ride_dash_theme.dart';
import 'bluetooth_screen.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/metric_card.dart';
import '../widgets/ride_timer.dart';
import '../widgets/workout_controls.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final BluetoothService _bluetoothService = BluetoothService.instance;
  late DateTime _currentTime;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _currentTime = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final hour = _currentTime.hour.toString().padLeft(2, '0');
    final minute = _currentTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get _formattedDate {
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
              onBluetooth: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const BluetoothScreen(),
                  ),
                );
              },
            ),
            Expanded(
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _bluetoothService,
                    builder: (context, _) => DashboardHeader(
                      currentTime: _formattedTime,
                      currentDate: _formattedDate,
                      deviceName: _bluetoothService.headerDeviceName,
                      connectionStatus:
                          _bluetoothService.headerConnectionStatus,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        border: Border(
                          left: BorderSide(color: rideDashBorder),
                          top: BorderSide(color: rideDashBorder),
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 44, 24, 38),
                        child: Column(
                          children: [
                            const RideTimer(),
                            const SizedBox(height: 66),
                            const _MetricsGrid(),
                            const SizedBox(height: 40),
                            const _BottomRow(),
                          ],
                        ),
                      ),
                    ),
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

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid();

  @override
  Widget build(BuildContext context) {
    const metrics = [
      MetricCard(
        label: 'CADENCE',
        value: '87',
        unit: 'RPM',
        icon: Icons.rotate_right,
      ),
      MetricCard(
        label: 'SPEED',
        value: '31.4',
        unit: 'KM/H',
        icon: Icons.speed,
      ),
      MetricCard(
        label: 'DISTANCE',
        value: '12.8',
        unit: 'KM',
        icon: Icons.alt_route,
      ),
      MetricCard(
        label: 'HEART RATE',
        value: '142',
        unit: 'BPM',
        icon: Icons.favorite,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1050
            ? 4
            : constraints.maxWidth >= 600
            ? 2
            : 1;
        final gap = 20.0;
        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final metric in metrics)
              SizedBox(width: cardWidth, child: metric),
          ],
        );
      },
    );
  }
}

class _BottomRow extends StatelessWidget {
  const _BottomRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return const Column(
            children: [
              WorkoutControls(),
              SizedBox(height: 20),
              WorkoutStatusCard(),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(flex: 3, child: WorkoutControls()),
            const SizedBox(width: 28),
            const Expanded(child: WorkoutStatusCard()),
          ],
        );
      },
    );
  }
}
