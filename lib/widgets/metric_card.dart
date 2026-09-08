import 'package:flutter/material.dart';

import '../theme/ride_dash_theme.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    super.key,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 318,
      padding: const EdgeInsets.fromLTRB(40, 30, 40, 28),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: rideDashBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Icon(icon, color: rideDashRed, size: 46),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 88,
                fontWeight: FontWeight.w800,
                height: 0.95,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            unit,
            style: const TextStyle(
              color: rideDashSecondaryText,
              fontSize: 19,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.2,
            ),
          ),
          const Spacer(),
          Container(height: 2, color: rideDashRed),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.5,
            ),
          ),
        ],
      ),
    );
  }
}
