import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../main.dart';
import '../theme/zfa_theme.dart';
import '../models/lernkarte.dart';
import '../data/lernkarten_daten.dart';
import '../widgets/lern_buddy.dart';

/// Lückentext: Welcher Fachbegriff wird gesucht? (Begriff aus Definition)
class LueckentextScreen extends StatefulWidget {
  const LueckentextScreen({super.key});

  @override
  State<LueckentextScreen> createState() => _LueckentextScreenState();
}

class _LueckentextScreenState extends State<LueckentextScreen> {
  final _rng = Random();
  late List<Lernkarte> _karten;
  late List<Lernkarte> _alle;
  int _index = 0;
  late List<String> _optionen;
  String? _gewaehlt;
  int _punkte = 0;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 1));
    _alle = alleLernkarten();
    _karten = _alle.toList()..shuffle(_rng);
    _karten = _karten.take(10).toList();
    _optionenBauen();
  }

  void _optionenBauen() {
    final richtig = _karten[_index];
    final falsche = _alle
        .where((k) => k.vorderseite != richtig.vorderseite)
        .map((k) => k.vorderseite)
        .toList()
      ..shuffle(_rng);
    _optionen = [richtig.vorderseite, ...falsche.take(3)]..shuffle(_rng);
    _gewaehlt = null;
  }

  void _waehlen(String wahl) {
    if (_gewaehlt != null) return;
    final richtig = _karten[_index];
    final korrekt = wahl == richtig.vorderseite;
    setState(() => _gewaehlt = wahl);
    if (korrekt) {
      HapticFeedback.lightImpact();
      soundService.richtig();
      _confetti.play();
      _punkte += 10;
      fortschrittService.frageRichtigBeantwortet('lt_${richtig.id}',
          bereich: richtig.bereich);
    } else {
      HapticFeedback.heavyImpact();
      soundService.falsch();
      fortschrittService.frageFalschBeantwortet('lt_${richtig.id}',
          bereich: richtig.bereich);
    }
  }

  void _weiter() {
    if (_index < _karten.length - 1) {
      setState(() {
        _index++;
        _optionenBauen();
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    final k = _karten[_index];
    final hinweis =
        '${k.vorderseite[0]} ${'_ ' * (k.vorderseite.length - 1)}'.trim();
    return Scaffold(
      body: Stack(
        children: [
          PremiumBackground(
            child: SafeArea(
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: (_index + 1) / _karten.length,
                    minHeight: 6,
                    backgroundColor: tc.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation(ZfaTheme.gold),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 16, 4),
                    child: Row(children: [
                      IconButton(
                          icon: Icon(Icons.arrow_back, color: tc),
                          onPressed: () => Navigator.pop(context)),
                      Expanded(
                        child: Text('Lückentext',
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                      Text('⭐ $_punkte',
                          style: TextStyle(
                              color: tc, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                    ]),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(18),
                      children: [
                        Text('Welcher Fachbegriff wird gesucht?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: tc.withOpacity(0.7), fontSize: 14)),
                        const SizedBox(height: 12),
                        GlassCard(
                          child: Column(
                            children: [
                              Text(k.emoji,
                                  style: const TextStyle(fontSize: 36)),
                              const SizedBox(height: 10),
                              Text(k.einfachVersion,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: tc,
                                      fontSize: 17,
                                      height: 1.4,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Text(k.rueckseite,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: tc.withOpacity(0.7),
                                      fontSize: 14,
                                      height: 1.4)),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: ZfaTheme.gold.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                    _gewaehlt == null ? hinweis : k.vorderseite,
                                    style: TextStyle(
                                        color: tc,
                                        fontSize: 18,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._optionen.map((opt) {
                          Color bg = tc.withOpacity(0.05);
                          Color border = tc.withOpacity(0.18);
                          if (_gewaehlt != null) {
                            if (opt == k.vorderseite) {
                              bg = ZfaTheme.gruen.withOpacity(0.18);
                              border = ZfaTheme.gruen;
                            } else if (opt == _gewaehlt) {
                              bg = ZfaTheme.rot.withOpacity(0.15);
                              border = ZfaTheme.rot;
                            }
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              onTap: () => _waehlen(opt),
                              child: Container(
                                constraints:
                                    const BoxConstraints(minHeight: 54),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: border, width: 1.6),
                                ),
                                alignment: Alignment.centerLeft,
                                child: Text(opt,
                                    style: TextStyle(
                                        color: tc,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          );
                        }),
                        if (_gewaehlt != null) ...[
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _weiter,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: ZfaTheme.gold,
                                foregroundColor: Colors.black87),
                            child: Text(_index < _karten.length - 1
                                ? 'Weiter →'
                                : 'Fertig 🎉'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 20,
              colors: const [ZfaTheme.gold, ZfaTheme.blau, ZfaTheme.gruen],
            ),
          ),
        ],
      ),
    );
  }
}
