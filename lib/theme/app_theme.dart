import 'package:flutter/material.dart';

/// Available color palettes the user can choose from.
enum AppPalette {
  softNursery('Soft Nursery'),
  oceanBreeze('Ocean Breeze'),
  sunsetGlow('Sunset Glow'),
  forestGarden('Forest Garden'),
  lavenderDreams('Lavender Dreams');

  final String label;
  const AppPalette(this.label);
}

/// All colours that vary per palette.
class ColorPaletteData {
  final Color primary;
  final Color primaryDark;
  final Color lightBg;
  final Color lightSurface;
  final Color darkBg;
  final Color darkSurface;
  final Color lightTrack;
  final Color darkTrack;
  final Color breastFeedLight;
  final Color breastFeedDark;
  final Color formulaLight;
  final Color formulaDark;
  final Color diaperLight;
  final Color diaperDark;
  final Color sleepLight;
  final Color sleepDark;
  final Color leftSide;
  final Color rightSide;
  final Color lightOnSurface;
  final Color darkOnSurface;

  const ColorPaletteData({
    required this.primary,
    required this.primaryDark,
    required this.lightBg,
    required this.lightSurface,
    required this.darkBg,
    required this.darkSurface,
    required this.lightTrack,
    required this.darkTrack,
    required this.breastFeedLight,
    required this.breastFeedDark,
    required this.formulaLight,
    required this.formulaDark,
    required this.diaperLight,
    required this.diaperDark,
    required this.sleepLight,
    required this.sleepDark,
    required this.leftSide,
    required this.rightSide,
    required this.lightOnSurface,
    required this.darkOnSurface,
  });
}

class AppTheme {
  AppTheme._();

  /// Set by ThemeProvider before building themes.
  static AppPalette activePalette = AppPalette.softNursery;

  static ColorPaletteData get _p => palettes[activePalette]!;

  // ── Palette definitions ───────────────────────────────────────────────────
  static const Map<AppPalette, ColorPaletteData> palettes = {
    AppPalette.softNursery: ColorPaletteData(
      primary: Color(0xFFCB8589),
      primaryDark: Color(0xFFD4979A),
      lightBg: Color(0xFFFDF8F4),
      lightSurface: Color(0xFFFFFBF7),
      darkBg: Color(0xFF1B1D2A),
      darkSurface: Color(0xFF232536),
      lightTrack: Color(0xFFF0EBE5),
      darkTrack: Color(0xFF2E3044),
      breastFeedLight: Color(0xFFD98E96),
      breastFeedDark: Color(0xFFC07A82),
      formulaLight: Color(0xFF8CB4D5),
      formulaDark: Color(0xFF6F9DBF),
      diaperLight: Color(0xFF8EBB9F),
      diaperDark: Color(0xFF6FA389),
      sleepLight: Color(0xFFAEA0D2),
      sleepDark: Color(0xFF9585BF),
      leftSide: Color(0xFFD98E96),
      rightSide: Color(0xFF8CB4D5),
      lightOnSurface: Color(0xFF3E3B42),
      darkOnSurface: Color(0xFFE1DDE5),
    ),
    AppPalette.oceanBreeze: ColorPaletteData(
      primary: Color(0xFF5B8FB9),
      primaryDark: Color(0xFF6D9FC5),
      lightBg: Color(0xFFF3F8FC),
      lightSurface: Color(0xFFF8FBFF),
      darkBg: Color(0xFF19232F),
      darkSurface: Color(0xFF212D3B),
      lightTrack: Color(0xFFE2EAF2),
      darkTrack: Color(0xFF2B384A),
      breastFeedLight: Color(0xFFD4908E),
      breastFeedDark: Color(0xFFBF7B79),
      formulaLight: Color(0xFF5BB5B0),
      formulaDark: Color(0xFF49A09B),
      diaperLight: Color(0xFFC5A66E),
      diaperDark: Color(0xFFB09158),
      sleepLight: Color(0xFF8E9AD4),
      sleepDark: Color(0xFF7985BF),
      leftSide: Color(0xFF5BB5B0),
      rightSide: Color(0xFFD4908E),
      lightOnSurface: Color(0xFF3B4250),
      darkOnSurface: Color(0xFFDEE2E8),
    ),
    AppPalette.sunsetGlow: ColorPaletteData(
      primary: Color(0xFFD4854A),
      primaryDark: Color(0xFFDFA06E),
      lightBg: Color(0xFFFDF6F0),
      lightSurface: Color(0xFFFFF9F4),
      darkBg: Color(0xFF2A1F1A),
      darkSurface: Color(0xFF362923),
      lightTrack: Color(0xFFF0E5D8),
      darkTrack: Color(0xFF3E3028),
      breastFeedLight: Color(0xFFD47858),
      breastFeedDark: Color(0xFFBF6345),
      formulaLight: Color(0xFFC5A44E),
      formulaDark: Color(0xFFB09040),
      diaperLight: Color(0xFFD48EA0),
      diaperDark: Color(0xFFBF7990),
      sleepLight: Color(0xFF9E85C5),
      sleepDark: Color(0xFF8A70B0),
      leftSide: Color(0xFFD47858),
      rightSide: Color(0xFFC5A44E),
      lightOnSurface: Color(0xFF42392E),
      darkOnSurface: Color(0xFFE8E0D8),
    ),
    AppPalette.forestGarden: ColorPaletteData(
      primary: Color(0xFF6B9F7E),
      primaryDark: Color(0xFF7DAF8E),
      lightBg: Color(0xFFF4F8F5),
      lightSurface: Color(0xFFF8FBF9),
      darkBg: Color(0xFF1A261E),
      darkSurface: Color(0xFF223228),
      lightTrack: Color(0xFFE0EBE3),
      darkTrack: Color(0xFF2D3E32),
      breastFeedLight: Color(0xFFB08E6B),
      breastFeedDark: Color(0xFF9C7A58),
      formulaLight: Color(0xFF6BB09F),
      formulaDark: Color(0xFF589C8B),
      diaperLight: Color(0xFFC5A44E),
      diaperDark: Color(0xFFB09040),
      sleepLight: Color(0xFF8E9F6B),
      sleepDark: Color(0xFF7A8B58),
      leftSide: Color(0xFF6BB09F),
      rightSide: Color(0xFFB08E6B),
      lightOnSurface: Color(0xFF3B4238),
      darkOnSurface: Color(0xFFDEE5DB),
    ),
    AppPalette.lavenderDreams: ColorPaletteData(
      primary: Color(0xFF9B7EC5),
      primaryDark: Color(0xFFAB90D0),
      lightBg: Color(0xFFF8F4FC),
      lightSurface: Color(0xFFFBF8FF),
      darkBg: Color(0xFF1E1A28),
      darkSurface: Color(0xFF282434),
      lightTrack: Color(0xFFEAE2F0),
      darkTrack: Color(0xFF352E44),
      breastFeedLight: Color(0xFFC57EA0),
      breastFeedDark: Color(0xFFB06990),
      formulaLight: Color(0xFF7EABC5),
      formulaDark: Color(0xFF6996B0),
      diaperLight: Color(0xFFC5AB7E),
      diaperDark: Color(0xFFB09669),
      sleepLight: Color(0xFF8E7EC5),
      sleepDark: Color(0xFF7969B0),
      leftSide: Color(0xFFC57EA0),
      rightSide: Color(0xFF7EABC5),
      lightOnSurface: Color(0xFF3E3842),
      darkOnSurface: Color(0xFFE2DEE8),
    ),
  };

  // ── Theme builders ────────────────────────────────────────────────────────
  static ThemeData light() {
    final p = _p;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: p.primary,
      brightness: Brightness.light,
      primary: p.primary,
      surface: p.lightSurface,
      onSurface: p.lightOnSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.lightBg,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: p.lightBg,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: p.primary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: p.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: p.lightTrack),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: p.lightTrack),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.lightTrack),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.lightTrack),
        ),
        filled: true,
        fillColor: p.lightSurface,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.lightBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      dividerColor: p.lightTrack,
      textTheme: const TextTheme().apply(
        bodyColor: p.lightOnSurface,
        displayColor: p.lightOnSurface,
      ),
    );
  }

  static ThemeData dark() {
    final p = _p;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: p.primaryDark,
      brightness: Brightness.dark,
      primary: p.primaryDark,
      surface: p.darkSurface,
      onSurface: p.darkOnSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.darkBg,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: p.darkBg,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: p.primaryDark),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: p.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: p.darkTrack),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primaryDark,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primaryDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: p.darkTrack),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.darkTrack),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.darkTrack),
        ),
        filled: true,
        fillColor: p.darkSurface,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.darkBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      dividerColor: p.darkTrack,
      textTheme: const TextTheme().apply(
        bodyColor: p.darkOnSurface,
        displayColor: p.darkOnSurface,
      ),
    );
  }

  // ── Track background for timeline widgets ─────────────────────────────────
  static Color trackColor(Brightness brightness) =>
      brightness == Brightness.light ? _p.lightTrack : _p.darkTrack;

  // ── Breast-feeding side colours ───────────────────────────────────────────
  static Color get leftSideColor => _p.leftSide;
  static Color get rightSideColor => _p.rightSide;

  // ── Activity helpers ──────────────────────────────────────────────────────
  static IconData iconForActivity(String type) {
    switch (type) {
      case 'breastFeeding':
        return Icons.child_care;
      case 'formulaFeeding':
        return Icons.baby_changing_station;
      case 'diaper':
        return Icons.water_drop;
      case 'sleep':
        return Icons.bedtime;
      default:
        return Icons.help_outline;
    }
  }

  static Color colorForActivity(String type, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final p = _p;
    switch (type) {
      case 'breastFeeding':
        return isLight ? p.breastFeedLight : p.breastFeedDark;
      case 'formulaFeeding':
        return isLight ? p.formulaLight : p.formulaDark;
      case 'diaper':
        return isLight ? p.diaperLight : p.diaperDark;
      case 'sleep':
        return isLight ? p.sleepLight : p.sleepDark;
      default:
        return isLight ? const Color(0xFFBDB8B0) : const Color(0xFF6E6A64);
    }
  }

  static String labelForActivity(String type) {
    switch (type) {
      case 'breastFeeding':
        return 'Breast Feed';
      case 'formulaFeeding':
        return 'Formula';
      case 'diaper':
        return 'Diaper';
      case 'sleep':
        return 'Sleep';
      default:
        return type;
    }
  }
}
