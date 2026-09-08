import 'package:flutter/material.dart';

const rideDashBackground = Color(0xFF090A0C);
const rideDashPanel = Color(0xFF121417);
const rideDashBorder = Color(0xFF2A2D31);
const rideDashRed = Color(0xFFE53935);
const rideDashSecondaryText = Color(0xFF92979F);

final rideDashTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: rideDashBackground,
  colorScheme: const ColorScheme.dark(
    surface: rideDashPanel,
    primary: rideDashRed,
    onPrimary: Colors.white,
    onSurface: Colors.white,
  ),
  fontFamily: 'Segoe UI',
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white),
    labelMedium: TextStyle(
      color: rideDashSecondaryText,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.4,
    ),
  ),
);
