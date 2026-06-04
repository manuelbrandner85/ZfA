import 'package:flutter/material.dart';

/// Farben und Beschriftung für Schwierigkeitsgrade ('leicht'/'mittel'/'schwer').
class Schwierigkeit {
  static Color farbe(String s) {
    switch (s) {
      case 'leicht':
        return const Color(0xFF22C55E);
      case 'schwer':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B); // mittel
    }
  }

  static String label(String s) {
    switch (s) {
      case 'leicht':
        return 'Leicht';
      case 'schwer':
        return 'Schwer';
      default:
        return 'Mittel';
    }
  }

  static int sterne(String s) {
    switch (s) {
      case 'leicht':
        return 1;
      case 'schwer':
        return 3;
      default:
        return 2;
    }
  }
}

/// Kleines farbiges Badge mit Punkten je Schwierigkeit.
class SchwierigkeitBadge extends StatelessWidget {
  final String schwierigkeit;
  const SchwierigkeitBadge({super.key, required this.schwierigkeit});

  @override
  Widget build(BuildContext context) {
    final f = Schwierigkeit.farbe(schwierigkeit);
    final n = Schwierigkeit.sterne(schwierigkeit);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: f.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: f.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < 3; i++)
            Icon(Icons.circle,
                size: 7,
                color: i < n ? f : f.withOpacity(0.25)),
          const SizedBox(width: 6),
          Text(Schwierigkeit.label(schwierigkeit),
              style: TextStyle(
                  color: f, fontSize: 11.5, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
