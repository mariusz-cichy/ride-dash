import 'package:flutter/material.dart';

import '../theme/ride_dash_theme.dart';

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      color: rideDashBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 174),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SidebarItem(
              icon: Icons.bar_chart_rounded,
              label: 'Dashboard',
              selected: true,
            ),
            const _SidebarItem(
              icon: Icons.event_note_outlined,
              label: 'Workout History',
            ),
            const _SidebarItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
            ),
            const _SidebarItem(icon: Icons.bluetooth, label: 'Bluetooth'),
            const _SidebarItem(icon: Icons.info_outline, label: 'About'),
            const SizedBox(height: 110),
            Padding(
              padding: const EdgeInsets.fromLTRB(35, 0, 28, 44),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 60, height: 2, color: rideDashBorder),
                  const SizedBox(height: 24),
                  const Text(
                    'RIDE\nSTRONGER\nEVERYDAY',
                    style: TextStyle(
                      color: rideDashSecondaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.75,
                      letterSpacing: 3.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(width: 60, height: 2, color: rideDashRed),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF1A080B) : Colors.transparent,
        border: selected
            ? const Border(left: BorderSide(color: rideDashRed, width: 2))
            : null,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 34),
      child: Row(
        children: [
          Icon(
            icon,
            color: selected ? rideDashRed : rideDashSecondaryText,
            size: 25,
          ),
          const SizedBox(width: 18),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? rideDashRed : rideDashSecondaryText,
                fontSize: 16,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
