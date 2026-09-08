import 'package:flutter/material.dart';

import '../theme/ride_dash_theme.dart';

class RideTimer extends StatelessWidget {
  const RideTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'RIDE TIME',
          style: TextStyle(
            color: rideDashSecondaryText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 4.5,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '00:00:00',
          style: TextStyle(
            color: Colors.white,
            fontSize: 98,
            fontWeight: FontWeight.w800,
            height: 0.9,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }
}
