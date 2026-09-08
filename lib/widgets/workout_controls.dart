import 'package:flutter/material.dart';

import '../theme/ride_dash_theme.dart';

class WorkoutControls extends StatelessWidget {
  const WorkoutControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: _ControlButton(icon: Icons.pause, label: 'PAUSE'),
        ),
        const SizedBox(width: 28),
        const Expanded(
          child: _ControlButton(
            icon: Icons.stop,
            label: 'END RIDE',
            emphasized: true,
          ),
        ),
        const SizedBox(width: 28),
        const Expanded(
          child: _ControlButton(icon: Icons.refresh, label: 'RESET'),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 30),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: emphasized ? rideDashRed : const Color(0xFF17191C),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: emphasized ? rideDashRed : rideDashBorder),
          ),
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }
}

class WorkoutStatusCard extends StatelessWidget {
  const WorkoutStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0x330E1012),
        border: Border.all(color: const Color(0xFF181A1D)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'WORKOUT STATUS',
            style: TextStyle(
              color: rideDashSecondaryText,
              fontSize: 13,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: rideDashSecondaryText,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'IDLE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Auto-pause when stopped',
            style: TextStyle(color: rideDashSecondaryText, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
