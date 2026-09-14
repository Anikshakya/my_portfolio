import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HudThemeController extends ChangeNotifier {
  HudThemeController._();
  static final HudThemeController instance = HudThemeController._();

  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor:
          isDark ? const Color(0xFF020208) : HudColors.lightBackground,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ));
    notifyListeners();
  }
}

class HudColors {
  static Color get background => HudThemeController.instance.isDark
      ? const Color(0xFF020208)
      : lightBackground;
  static Color get surface => HudThemeController.instance.isDark
      ? const Color(0xFF040A1A)
      : lightSurface;
  static const primary = Color.fromARGB(255, 210, 187, 111);
  // Kept as an alias so existing screen components inherit the new brand color.
  static const cyan = primary;
  static const magenta = Color(0xFF9A526D);
  static const amber = primary;
  static const green = Color(0xFF7B9B78);
  static Color get textMain => HudThemeController.instance.isDark
      ? const Color(0xFFE2E8F0)
      : lightTextMain;
  static Color get textMuted => HudThemeController.instance.isDark
      ? const Color(0xFF64748B)
      : lightTextMuted;
  static const borderCyan = Color(0x4DD2BB6F);
  static Color get panelBg => HudThemeController.instance.isDark
      ? const Color(0x8C020208)
      : lightPanelBg;
  static Color get elevatedSurface => HudThemeController.instance.isDark
      ? const Color(0xE9161A1F)
      : const Color(0xF9FFFFFF);
  static Color get hoverSurface => HudThemeController.instance.isDark
      ? const Color(0xFF252C33)
      : const Color(0xFFEDF2F4);
  static Color get chipSurface => HudThemeController.instance.isDark
      ? const Color(0x331F1A10)
      : const Color(0xFFF2EBDD);
  static Color get selectionBarSurface => HudThemeController.instance.isDark
      ? const Color(0x66191B1E)
      : const Color(0xFFF5F7F8);
  static Color get selectionBarBorder => HudThemeController.instance.isDark
      ? Colors.white.withOpacity(0.08)
      : Colors.black.withOpacity(0.065);
  static Color get inactiveChipSurface => HudThemeController.instance.isDark
      ? Colors.white.withOpacity(0.035)
      : Colors.white;
  static Color get inactiveChipBorder => HudThemeController.instance.isDark
      ? Colors.white.withOpacity(0.08)
      : Colors.black.withOpacity(0.055);
  static Color get chipBorder => HudThemeController.instance.isDark
      ? const Color(0x667F6C3E)
      : const Color(0x668C733A);
  static Color get cardBorder => HudThemeController.instance.isDark
      ? Colors.white.withOpacity(0.12)
      : Colors.black.withOpacity(0.075);
  static Color get hoverBorder => HudThemeController.instance.isDark
      ? primary.withOpacity(0.75)
      : primary.withOpacity(0.45);
  static Color get shadowColor => Colors.black.withOpacity(
        HudThemeController.instance.isDark ? 0.14 : 0.08,
      );
  static Color get onPrimary => HudThemeController.instance.isDark
      ? const Color(0xFF242017)
      : const Color(0xFFFFFCF6);

  static const lightBackground = Color(0xFFF4F1EA);
  static const lightSurface = Color(0xFFFFFCF6);
  static const lightTextMain = Color(0xFF29261F);
  static const lightTextMuted = Color(0xFF756F63);
  static const lightPanelBg = Color(0xD9FFFCF6);
  static const lightBorderCyan = Color(0x66B59A50);
}

class HudTextStyles {
  static TextStyle header(double size,
          {Color? color, FontWeight weight = FontWeight.w800}) =>
      GoogleFonts.orbitron(
          fontSize: size,
          color: color == null || color == Colors.white
              ? HudColors.textMain
              : color,
          fontWeight: weight,
          letterSpacing: 1.0);

  static TextStyle mono(double size, {Color color = HudColors.cyan}) =>
      GoogleFonts.shareTechMono(fontSize: size, color: color);

  static TextStyle body(double size, {Color? color}) => GoogleFonts.inter(
      fontSize: size, color: color ?? HudColors.textMain, height: 1.55);
}

BoxDecoration hudPanelDecoration({
  Color borderColor = HudColors.borderCyan,
  double glowOpacity = 0.15,
  bool isDark = true,
}) =>
    BoxDecoration(
      color: HudColors.elevatedSurface,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: borderColor, width: 1),
      boxShadow: [
        BoxShadow(
          color: HudColors.primary.withOpacity(isDark ? glowOpacity : 0.08),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ],
    );

ThemeData hudTheme({bool dark = true}) => ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor:
          dark ? HudColors.background : HudColors.lightBackground,
      canvasColor: dark ? HudColors.background : HudColors.lightBackground,
      colorScheme: dark
          ? ColorScheme.dark(
              primary: HudColors.primary,
              secondary: HudColors.magenta,
              surface: HudColors.surface,
              onSurface: const Color(0xFFE2E8F0),
            )
          : const ColorScheme.light(
              primary: HudColors.primary,
              secondary: HudColors.magenta,
              surface: HudColors.lightSurface,
              onSurface: HudColors.lightTextMain,
            ),
      textTheme: GoogleFonts.interTextTheme(
        dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: dark ? HudColors.surface : HudColors.lightSurface,
      ),
    );
