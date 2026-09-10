import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HudColors {
  static const background = Color(0xFF020208);
  static const surface = Color(0xFF040A1A);
  static const cyan = Color(0xFF00F0FF);
  static const magenta = Color(0xFFFF007F);
  static const amber = Color(0xFFFFAA00);
  static const green = Color(0xFF00FF66);
  static const textMain = Color(0xFFE2E8F0);
  static const textMuted = Color(0xFF64748B);
  static const borderCyan = Color(0x2900F0FF);
  static const panelBg = Color(0x8C020208);
}

class HudTextStyles {
  static TextStyle header(double size, {Color color = Colors.white, FontWeight weight = FontWeight.w800}) =>
      GoogleFonts.orbitron(fontSize: size, color: color, fontWeight: weight, letterSpacing: 1.0);

  static TextStyle mono(double size, {Color color = HudColors.cyan}) =>
      GoogleFonts.shareTechMono(fontSize: size, color: color);

  static TextStyle body(double size, {Color color = HudColors.textMain}) =>
      GoogleFonts.inter(fontSize: size, color: color, height: 1.55);
}

BoxDecoration hudPanelDecoration({Color borderColor = HudColors.borderCyan, double glowOpacity = 0.15}) =>
    BoxDecoration(
      color: HudColors.panelBg,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: borderColor, width: 1),
      boxShadow: [
        BoxShadow(color: HudColors.cyan.withOpacity(glowOpacity), blurRadius: 12, spreadRadius: 0),
      ],
    );

ThemeData hudTheme() => ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: HudColors.background,
      colorScheme: const ColorScheme.dark(
        primary: HudColors.cyan,
        secondary: HudColors.magenta,
        surface: HudColors.surface,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    );
