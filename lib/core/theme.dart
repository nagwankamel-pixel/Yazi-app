import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// YAZI brand tokens — violet primary, warm supporting accents.
abstract final class Yozi {
  static const violet = Color(0xFF6C3FD6);
  static const violetDeep = Color(0xFF5227B0);
  static const violetSoft = Color(0xFFEFE8FD);
  static const violetGhost = Color(0xFFF7F4FE);

  static const ink = Color(0xFF221A38);
  static const ink2 = Color(0xFF4C4368);
  static const muted = Color(0xFF7F76A0);
  static const faint = Color(0xFFA9A1C4);

  static const ground = Color(0xFFF6F4FB);
  static const surface = Colors.white;
  static const surface2 = Color(0xFFF1EDFA);
  static const line = Color(0xFFE7E2F5);
  static const lineSoft = Color(0xFFF0ECFA);

  static const amber = Color(0xFFB45309);
  static const amberBright = Color(0xFFF59E0B);
  static const amberWash = Color(0xFFFDF3E0);
  static const mint = Color(0xFF0E9F6E);
  static const mintDeep = Color(0xFF047857);
  static const mintWash = Color(0xFFDEF7EC);
  static const coral = Color(0xFFE11D48);
  static const coralWash = Color(0xFFFDE8ED);
  static const sky = Color(0xFF0E7DC2);
  static const skyWash = Color(0xFFE1F1FB);
  static const gold = Color(0xFF8A6D1B);
  static const goldWash = Color(0xFFFBF0CE);

  static const rLg = 20.0;
  static const rMd = 16.0;
  static const rSm = 12.0;

  /// Photo-placeholder gradients keyed by name.
  static const gradients = <String, List<Color>>{
    'violet': [Color(0xFF7C4DE8), Color(0xFFA78BFA)],
    'sky': [Color(0xFF2E9BDB), Color(0xFF7FC8F0)],
    'mint': [Color(0xFF12B981), Color(0xFF5EEAD4)],
    'coral': [Color(0xFFF43F5E), Color(0xFFFB7185)],
    'amber': [Color(0xFFF59E0B), Color(0xFFFCD34D)],
    'pink': [Color(0xFFEC4899), Color(0xFFF9A8D4)],
    'deep': [Color(0xFF5227B0), Color(0xFF8B5CF6)],
    'teal': [Color(0xFF0D9488), Color(0xFF2DD4BF)],
  };

  static LinearGradient grad(String name) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradients[name] ?? gradients['violet']!,
      );

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
            color: ink.withValues(alpha: .05),
            blurRadius: 2,
            offset: const Offset(0, 1)),
        BoxShadow(
            color: violetDeep.withValues(alpha: .16),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: -18),
      ];

  static List<BoxShadow> get floatShadow => [
        BoxShadow(
            color: ink.withValues(alpha: .08),
            blurRadius: 10,
            offset: const Offset(0, 4)),
        BoxShadow(
            color: violetDeep.withValues(alpha: .28),
            blurRadius: 50,
            offset: const Offset(0, 18),
            spreadRadius: -20),
      ];

  static ThemeData theme(bool arabic) {
    final base = arabic
        ? GoogleFonts.cairoTextTheme()
        : GoogleFonts.nunitoTextTheme();
    final text = base.apply(bodyColor: ink, displayColor: ink);
    final scheme = ColorScheme.fromSeed(
      seedColor: violet,
      primary: violet,
      surface: ground,
      onSurface: ink,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: ground,
      textTheme: text,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: ground,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(
            fontWeight: FontWeight.w800, fontSize: 18, color: ink),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface.withValues(alpha: .95),
        indicatorColor: violetSoft,
        height: 68,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final on = states.contains(WidgetState.selected);
          return text.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 11,
              color: on ? violetDeep : faint);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final on = states.contains(WidgetState.selected);
          return IconThemeData(color: on ? violetDeep : faint, size: 24);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: violet,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: text.titleSmall
              ?.copyWith(fontWeight: FontWeight.w800, fontSize: 15.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentTextStyle: text.bodyMedium?.copyWith(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      ),
      dividerTheme: const DividerThemeData(color: lineSoft, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        side: const BorderSide(color: line),
        labelStyle: text.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        shape: const StadiumBorder(),
      ),
    );
  }
}
