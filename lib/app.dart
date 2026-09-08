import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'theme/ride_dash_theme.dart';

class RideDashApp extends StatelessWidget {
  const RideDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RideDash for Schwinn IC8',
      debugShowCheckedModeBanner: false,
      theme: rideDashTheme,
      home: const DashboardScreen(),
    );
  }
}
