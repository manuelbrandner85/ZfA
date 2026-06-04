import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Zentrale Design-Sprache „ZFA Premium" – Netflix × Bloomberg × Duolingo.
/// Tiefe, Glanz, edle Typografie. Dunkel-cinematic und hell-premium.
class ZfaTheme {
  // ---- Markenfarben (aus dem Logo abgeleitet) ----
  static const navy = Color(0xFF070B1A);
  static const tief = Color(0xFF0E1430);
  static const royal = Color(0xFF1E3A8A);
  static const blau = Color(0xFF2563EB);
  static const hellblau = Color(0xFF60A5FA);
  static const gold = Color(0xFFE7C04C);
  static const goldHell = Color(0xFFF6DA8A);
  static const gruen = Color(0xFF22C55E);
  static const rot = Color(0xFFEF4444);
  static const violett = Color(0xFF7C5CFF);

  // ---- Verläufe ----
  static const goldGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF6DA8A), Color(0xFFE7C04C), Color(0xFFCB9B2E)],
  );
  static const blauGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
  );
  static const violettGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
  );

  static TextTheme _textTheme(Color farbe, Color gedimmt) {
    final body = GoogleFonts.nunitoTextTheme();
    return body.copyWith(
      displayLarge: GoogleFonts.sora(
          fontSize: 34, fontWeight: FontWeight.w800, color: farbe, height: 1.1),
      headlineMedium: GoogleFonts.sora(
          fontSize: 24, fontWeight: FontWeight.w800, color: farbe),
      titleLarge: GoogleFonts.sora(
          fontSize: 20, fontWeight: FontWeight.w700, color: farbe),
      titleMedium: GoogleFonts.sora(
          fontSize: 16, fontWeight: FontWeight.w700, color: farbe),
      bodyLarge: GoogleFonts.nunito(
          fontSize: 16, height: 1.55, color: farbe, letterSpacing: 0.2),
      bodyMedium: GoogleFonts.nunito(fontSize: 14, height: 1.5, color: gedimmt),
      labelLarge: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700),
    );
  }

  static ThemeData dark() {
    const surface = Color(0xFF131A36);
    final scheme = const ColorScheme.dark(
      primary: blau,
      secondary: gold,
      surface: surface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: navy,
      textTheme: _textTheme(Colors.white, const Color(0xFFAFBCE6)),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      elevatedButtonTheme: _btn(),
      switchTheme: _switch(),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  static ThemeData light() {
    const surface = Colors.white;
    final scheme = const ColorScheme.light(
      primary: Color(0xFF1D4ED8),
      secondary: Color(0xFFB8860B),
      surface: surface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFEEF3FF),
      textTheme: _textTheme(const Color(0xFF0E1430), const Color(0xFF5B668A)),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.08),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      elevatedButtonTheme: _btn(),
      switchTheme: _switch(),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  static ElevatedButtonThemeData _btn() => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 54),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle:
              GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      );

  static SwitchThemeData _switch() => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? gold : Colors.white),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? gold.withOpacity(0.4)
                : Colors.white24),
      );
}

/// Cinematic-Hintergrund mit weichen Lichtflächen, passend zum Theme.
class PremiumBackground extends StatelessWidget {
  final Widget child;
  const PremiumBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dunkel = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: dunkel
                  ? const RadialGradient(
                      center: Alignment(-0.1, -0.7),
                      radius: 1.4,
                      colors: [Color(0xFF18224A), Color(0xFF0A0F22), Color(0xFF05070F)],
                      stops: [0.0, 0.55, 1.0],
                    )
                  : const RadialGradient(
                      center: Alignment(-0.1, -0.6),
                      radius: 1.4,
                      colors: [Color(0xFFFFFFFF), Color(0xFFEAF0FF), Color(0xFFDDE7FB)],
                      stops: [0.0, 0.5, 1.0],
                    ),
            ),
          ),
        ),
        // Goldener Lichtschein
        Positioned(
          top: -80,
          right: -60,
          child: _Glow(
            color: ZfaTheme.gold.withOpacity(dunkel ? 0.18 : 0.12),
            size: 260,
          ),
        ),
        Positioned(
          bottom: -100,
          left: -80,
          child: _Glow(
            color: ZfaTheme.blau.withOpacity(dunkel ? 0.22 : 0.14),
            size: 300,
          ),
        ),
        child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  const _Glow({required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
        ),
      ),
    );
  }
}

/// Glasmorphes Panel – Kern des Premium-Looks. Bewusst OHNE BackdropFilter,
/// damit es unter allen Constraints stabil rendert und auch auf schwächeren
/// Geräten flüssig bleibt (translucentes Panel mit Rand + Schatten).
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Gradient? randGradient;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 22,
    this.onTap,
    this.randGradient,
  });

  @override
  Widget build(BuildContext context) {
    final dunkel = Theme.of(context).brightness == Brightness.dark;
    final deko = BoxDecoration(
      color: dunkel
          ? Colors.white.withOpacity(0.07)
          : Colors.white.withOpacity(0.82),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: dunkel
            ? Colors.white.withOpacity(0.12)
            : Colors.white.withOpacity(0.9),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(dunkel ? 0.30 : 0.08),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    );
    if (onTap == null) {
      return Container(padding: padding, decoration: deko, child: child);
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Ink(
          padding: padding,
          decoration: deko,
          child: child,
        ),
      ),
    );
  }
}
