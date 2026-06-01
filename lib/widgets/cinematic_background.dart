import 'package:flutter/material.dart';

/// Cinematic, tiefblauer Hintergrund passend zum App-Logo.
/// Radialer Verlauf von hellem Blau in der Mitte zu dunklem Navy am Rand.
class CinematicBackground extends StatelessWidget {
  final Widget child;
  final bool dunkel;

  const CinematicBackground({
    super.key,
    required this.child,
    this.dunkel = true,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: dunkel
            ? const RadialGradient(
                center: Alignment(0, -0.35),
                radius: 1.2,
                colors: [
                  Color(0xFF1E3A8A),
                  Color(0xFF121B54),
                  Color(0xFF0A1230),
                ],
                stops: [0.0, 0.55, 1.0],
              )
            : const RadialGradient(
                center: Alignment(0, -0.4),
                radius: 1.3,
                colors: [
                  Color(0xFFE8F0FF),
                  Color(0xFFF0F4FF),
                ],
              ),
      ),
      child: child,
    );
  }
}

/// Cinematic-Farbpalette als zentrale Konstanten.
class ZfaFarben {
  static const Color navy = Color(0xFF0A1230);
  static const Color tiefblau = Color(0xFF121B54);
  static const Color blau = Color(0xFF1565C0);
  static const Color hellblau = Color(0xFF42A5F5);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldHell = Color(0xFFF4D03F);
  static const Color gruen = Color(0xFF2E7D32);
  static const Color rot = Color(0xFFC62828);
}
