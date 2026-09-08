import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ride_dash/app.dart';

void main() {
  testWidgets('renders the RideDash dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const RideDashApp());

    expect(find.byKey(const ValueKey('ride-dash-brand')), findsOneWidget);
    expect(find.text('FOR SCHWINN IC8'), findsOneWidget);
    expect(find.text('Disconnected'), findsOneWidget);
    expect(find.text('00:00:00'), findsOneWidget);
    expect(find.text('CADENCE'), findsOneWidget);
    expect(find.text('87'), findsOneWidget);
  });
}
