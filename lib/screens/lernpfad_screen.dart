import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../core/services/fortschritt_service.dart';
import '../theme/zfa_theme.dart';
import 'quiz_screen.dart';
import 'mock_pruefung_screen.dart';

class LernpfadScreen extends StatefulWidget {
  const LernpfadScreen({super.key});

  @override
  State<LernpfadScreen> createState() => _LernpfadScreenState();
}

class _LernpfadScreenState extends State<LernpfadScreen> {
  static const _emojis = {
    'Anmeldung': '🏠',
    'Hygiene': '🧤',
    'Behandlungsassistenz': '🪞',
    'Anästhesie': '💉',
    'Chirurgie': '🔪',
    'Karies': '🦷',
    'Parodontitis': '🩸',
  };

  int _kronen(String bereich) {
    final g = fortschrittService.bereichGesamt[bereich] ?? 0;
    if (g == 0) return 0;
    final q = fortschrittService.bereichQuote(bereich);
    if (q >= 0.9 && g >= 6) return 3;
    if (q >= 0.7) return 2;
    if (q >= 0.4) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    final bereiche = FortschrittService.hauptBereiche;
    final plan = fortschrittService.tagesPlan();
    final tage = fortschrittService.tageBisPruefung();

    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 6),
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.arrow_back, color: tc),
                        onPressed: () => Navigator.pop(context)),
                    Text('Dein Lernpfad',
                        style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                  children: [
                    // Countdown-Lernplan
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: ZfaTheme.violettGrad,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: ZfaTheme.violett.withOpacity(0.4),
                              blurRadius: 18,
                              offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tage == null
                                ? 'Dein Plan für heute'
                                : tage > 0
                                    ? 'Noch $tage Tage – heute dran:'
                                    : 'Heute ist Prüfung! 🍀',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),
                          ...plan.map((b) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Text(_emojis[b] ?? '•',
                                        style: const TextStyle(fontSize: 18)),
                                    const SizedBox(width: 10),
                                    Text(b,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pfad-Knoten
                    for (int i = 0; i < bereiche.length; i++)
                      _PfadKnoten(
                        bereich: bereiche[i],
                        emoji: _emojis[bereiche[i]]!,
                        kronen: _kronen(bereiche[i]),
                        ausrichtung: i.isEven ? -1 : 1,
                        istAktuell: bereiche[i] ==
                            fortschrittService.schwaechsterBereich(),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    QuizScreen(nurBereich: bereiche[i])),
                          ).then((_) => setState(() {}));
                        },
                      ),
                    // Finaler Prüfungs-Knoten
                    _PfadKnoten(
                      bereich: 'Abschlussprüfung',
                      emoji: '🎓',
                      kronen: (fortschrittService.readinessScore() / 34)
                          .floor()
                          .clamp(0, 3),
                      ausrichtung: 0,
                      istAktuell: false,
                      gold: true,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MockPruefungScreen()),
                        ).then((_) => setState(() {}));
                      },
                    ),
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

class _PfadKnoten extends StatelessWidget {
  final String bereich;
  final String emoji;
  final int kronen;
  final int ausrichtung; // -1 links, 0 mitte, 1 rechts
  final bool istAktuell;
  final bool gold;
  final VoidCallback onTap;
  const _PfadKnoten({
    required this.bereich,
    required this.emoji,
    required this.kronen,
    required this.ausrichtung,
    required this.istAktuell,
    required this.onTap,
    this.gold = false,
  });

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    final align = ausrichtung == -1
        ? Alignment.centerLeft
        : ausrichtung == 1
            ? Alignment.centerRight
            : Alignment.center;
    final gradient = gold
        ? ZfaTheme.goldGrad
        : kronen > 0
            ? ZfaTheme.blauGrad
            : LinearGradient(
                colors: [tc.withOpacity(0.20), tc.withOpacity(0.12)]);
    return Column(
      children: [
        // Verbinder
        Container(
          width: 4,
          height: 26,
          decoration: BoxDecoration(
            color: tc.withOpacity(0.15),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Align(
          alignment: align,
          child: GestureDetector(
            onTap: onTap,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (istAktuell)
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: ZfaTheme.gold, width: 3),
                        ),
                      ),
                    Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: gradient,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 14,
                              offset: const Offset(0, 6)),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(emoji, style: const TextStyle(fontSize: 36)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Kronen
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                      3,
                      (k) => Icon(
                            k < kronen
                                ? Icons.workspace_premium
                                : Icons.workspace_premium_outlined,
                            size: 16,
                            color: k < kronen
                                ? ZfaTheme.gold
                                : tc.withOpacity(0.3),
                          )),
                ),
                SizedBox(
                  width: 130,
                  child: Text(bereich,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: tc,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
