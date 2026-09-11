import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ride_dash/app.dart';
import 'package:ride_dash/screens/bluetooth_screen.dart';
import 'package:ride_dash/screens/dashboard_screen.dart';

void main() {
  testWidgets('renders the RideDash dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const RideDashApp());

    expect(find.byKey(const ValueKey('ride-dash-brand')), findsOneWidget);
    expect(find.text('FOR SCHWINN IC8'), findsOneWidget);
    expect(find.text('Disconnected'), findsOneWidget);
    expect(find.text('00:00:00'), findsOneWidget);
    expect(find.text('CADENCE'), findsOneWidget);
    expect(find.text('--'), findsNWidgets(2));
  });

  testWidgets('opens the Bluetooth screen from the sidebar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RideDashApp());

    await tester.tap(find.text('Bluetooth'));
    await tester.pumpAndSettle();

    expect(find.byType(BluetoothScreen), findsOneWidget);
    expect(find.text('BLUETOOTH DEVICES'), findsOneWidget);
    expect(find.text('SCAN FOR DEVICES'), findsOneWidget);
  });

  test('formats live cadence and speed metrics', () {
    expect(formatCadenceMetric(55.0), '55');
    expect(formatSpeedMetric(26.2), '26.2');
    expect(formatCadenceMetric(null), '--');
    expect(formatSpeedMetric(null), '--');
  });
}
