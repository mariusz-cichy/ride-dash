import 'package:flutter/material.dart';

import '../theme/ride_dash_theme.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    required this.currentTime,
    required this.currentDate,
    super.key,
  });

  final String currentTime;
  final String currentDate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return Container(
            height: 320,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Branding(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _Clock(currentTime: currentTime, currentDate: currentDate),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings_outlined),
                      color: rideDashSecondaryText,
                      tooltip: 'Settings',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const _DeviceStatus(),
                const SizedBox(height: 18),
                const _Tagline(),
              ],
            ),
          );
        }
        return Container(
          height: 130,
          padding: const EdgeInsets.fromLTRB(36, 24, 34, 20),
          child: Row(
            children: [
              const _Branding(),
              const SizedBox(width: 48),
              const Expanded(child: _Tagline()),
              const _DeviceStatus(),
              const SizedBox(width: 36),
              _Clock(currentTime: currentTime, currentDate: currentDate),
              const SizedBox(width: 28),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings_outlined),
                color: rideDashSecondaryText,
                iconSize: 29,
                tooltip: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Branding extends StatelessWidget {
  const _Branding();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          key: const ValueKey('ride-dash-brand'),
          text: const TextSpan(
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              height: 0.9,
            ),
            children: [
              TextSpan(
                text: 'Ride',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'Dash',
                style: TextStyle(color: rideDashRed),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'FOR SCHWINN IC8',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.2,
          ),
        ),
      ],
    );
  }
}

class _Tagline extends StatelessWidget {
  const _Tagline();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'YOUR RIDE. FOUR NUMBERS. NO DISTRACTIONS.',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: rideDashSecondaryText,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 3.2,
      ),
    );
  }
}

class _DeviceStatus extends StatelessWidget {
  const _DeviceStatus();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310,
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0x660B0C0E),
        border: Border.all(color: rideDashBorder),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.bluetooth, color: Colors.white, size: 28),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schwinn IC8',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: rideDashRed, size: 8),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Disconnected',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: rideDashSecondaryText,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Clock extends StatelessWidget {
  const _Clock({required this.currentTime, required this.currentDate});

  final String currentTime;
  final String currentDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          currentTime,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w400,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          currentDate,
          style: const TextStyle(color: rideDashSecondaryText, fontSize: 14),
        ),
      ],
    );
  }
}
