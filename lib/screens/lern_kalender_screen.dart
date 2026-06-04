import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/zfa_theme.dart';

/// Lern-Kalender im GitHub-Heatmap-Stil: zeigt, an welchen Tagen gelernt wurde.
class LernKalenderScreen extends StatelessWidget {
  const LernKalenderScreen({super.key});

  String _key(DateTime d) =>
      '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

  Color _farbe(int n, Color basis) {
    if (n <= 0) return basis.withOpacity(0.08);
    if (n < 3) return ZfaTheme.gold.withOpacity(0.35);
    if (n < 6) return ZfaTheme.gold.withOpacity(0.65);
    return ZfaTheme.gruen;
  }

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    final fs = fortschrittService;
    const wochen = 13;
    final heute = DateTime.now();
    // Startmontag: zurück bis Wochenbeginn vor (wochen-1) Wochen.
    final startMontag = heute
        .subtract(Duration(days: heute.weekday - 1))
        .subtract(const Duration(days: (wochen - 1) * 7));

    int aktiveTage = 0;
    int gesamtAufgaben = 0;
    for (final v in fs.lernTage.values) {
      if (v > 0) aktiveTage++;
      gesamtAufgaben += v;
    }

    final wochenSpalten = <Widget>[];
    for (int w = 0; w < wochen; w++) {
      final tage = <Widget>[];
      for (int d = 0; d < 7; d++) {
        final tag = startMontag.add(Duration(days: w * 7 + d));
        final zukunft = tag.isAfter(heute);
        final n = fs.lernTage[_key(tag)] ?? 0;
        final heuteRand = _key(tag) == _key(heute);
        tage.add(Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: zukunft ? Colors.transparent : _farbe(n, tc),
            borderRadius: BorderRadius.circular(4),
            border: heuteRand
                ? Border.all(color: ZfaTheme.blau, width: 1.5)
                : null,
          ),
        ));
      }
      wochenSpalten.add(Column(children: tage));
    }

    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 4),
                child: Row(children: [
                  IconButton(
                      icon: Icon(Icons.arrow_back, color: tc),
                      onPressed: () => Navigator.pop(context)),
                  Text('Lern-Kalender',
                      style: Theme.of(context).textTheme.titleLarge),
                ]),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _Stat(
                                emoji: '🔥',
                                wert: '${fs.streak}',
                                label: 'Streak',
                                tc: tc)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _Stat(
                                emoji: '📅',
                                wert: '$aktiveTage',
                                label: 'Lerntage',
                                tc: tc)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _Stat(
                                emoji: '✅',
                                wert: '$gesamtAufgaben',
                                label: 'Aufgaben',
                                tc: tc)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Letzte 13 Wochen',
                              style: TextStyle(
                                  color: tc, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(children: wochenSpalten),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text('weniger',
                                  style: TextStyle(
                                      color: tc.withOpacity(0.6),
                                      fontSize: 11)),
                              const SizedBox(width: 6),
                              for (final n in [0, 2, 5, 8])
                                Container(
                                  width: 14,
                                  height: 14,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: _farbe(n, tc),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              const SizedBox(width: 6),
                              Text('mehr',
                                  style: TextStyle(
                                      color: tc.withOpacity(0.6),
                                      fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                        'Jeder gelernte Tag färbt ein Kästchen. Bleib dran – die Kette nicht abreißen lassen! 💪',
                        style: TextStyle(
                            color: tc.withOpacity(0.7), fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String emoji;
  final String wert;
  final String label;
  final Color tc;
  const _Stat(
      {required this.emoji,
      required this.wert,
      required this.label,
      required this.tc});
  @override
  Widget build(BuildContext context) => GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(wert,
                style: TextStyle(
                    color: tc, fontSize: 20, fontWeight: FontWeight.w800)),
            Text(label,
                style: TextStyle(color: tc.withOpacity(0.6), fontSize: 11)),
          ],
        ),
      );
}
