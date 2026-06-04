import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../main.dart';
import '../theme/zfa_theme.dart';
import '../models/lernkarte.dart';
import '../data/lernkarten_daten.dart';

/// Zuordnen: Begriff (links) mit der passenden Erklärung (rechts) verbinden.
class ZuordnenScreen extends StatefulWidget {
  const ZuordnenScreen({super.key});

  @override
  State<ZuordnenScreen> createState() => _ZuordnenScreenState();
}

class _ZuordnenScreenState extends State<ZuordnenScreen> {
  static const _proRunde = 5;
  final _rng = Random();
  late List<Lernkarte> _runde;
  late List<int> _rechtsReihenfolge; // Index in _runde, gemischt
  int? _gewaehltLinks;
  int? _gewaehltRechts;
  final Set<int> _geloest = {}; // gelöste Karten-Indizes
  bool _fehlerFlash = false;
  int _runden = 0;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 1));
    _neueRunde();
  }

  void _neueRunde() {
    final pool = alleLernkarten()..shuffle(_rng);
    _runde = pool.take(_proRunde).toList();
    _rechtsReihenfolge = List.generate(_runde.length, (i) => i)..shuffle(_rng);
    _geloest.clear();
    _gewaehltLinks = null;
    _gewaehltRechts = null;
  }

  void _pruefe() {
    if (_gewaehltLinks == null || _gewaehltRechts == null) return;
    final kartenIndexRechts = _rechtsReihenfolge[_gewaehltRechts!];
    if (kartenIndexRechts == _gewaehltLinks) {
      // Treffer
      HapticFeedback.lightImpact();
      soundService.richtig();
      setState(() {
        _geloest.add(_gewaehltLinks!);
        _gewaehltLinks = null;
        _gewaehltRechts = null;
      });
      if (_geloest.length == _runde.length) {
        _confetti.play();
        soundService.levelUp();
        fortschrittService.frageRichtigBeantwortet('zuordnen',
            bereich: 'Behandlungsassistenz');
      }
    } else {
      HapticFeedback.heavyImpact();
      soundService.falsch();
      setState(() => _fehlerFlash = true);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() {
            _fehlerFlash = false;
            _gewaehltLinks = null;
            _gewaehltRechts = null;
          });
        }
      });
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
    final fertig = _geloest.length == _runde.length;
    return Scaffold(
      body: Stack(
        children: [
          PremiumBackground(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 16, 4),
                    child: Row(children: [
                      IconButton(
                          icon: Icon(Icons.arrow_back, color: tc),
                          onPressed: () => Navigator.pop(context)),
                      Expanded(
                        child: Text('Zuordnen',
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                      Text('${_geloest.length}/${_runde.length}',
                          style: TextStyle(
                              color: tc, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                        'Tippe einen Begriff und dann die passende Erklärung.',
                        style: TextStyle(
                            color: tc.withOpacity(0.65), fontSize: 13)),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Begriffe
                          Expanded(
                            child: Column(
                              children: [
                                for (int i = 0; i < _runde.length; i++)
                                  _Kachel(
                                    text: _runde[i].vorderseite,
                                    emoji: _runde[i].emoji,
                                    gewaehlt: _gewaehltLinks == i,
                                    geloest: _geloest.contains(i),
                                    fehler: _fehlerFlash &&
                                        _gewaehltLinks == i,
                                    onTap: _geloest.contains(i)
                                        ? null
                                        : () {
                                            setState(
                                                () => _gewaehltLinks = i);
                                            _pruefe();
                                          },
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Erklärungen
                          Expanded(
                            child: Column(
                              children: [
                                for (int j = 0;
                                    j < _rechtsReihenfolge.length;
                                    j++)
                                  _Kachel(
                                    text: _runde[_rechtsReihenfolge[j]]
                                        .einfachVersion,
                                    klein: true,
                                    gewaehlt: _gewaehltRechts == j,
                                    geloest: _geloest
                                        .contains(_rechtsReihenfolge[j]),
                                    fehler: _fehlerFlash &&
                                        _gewaehltRechts == j,
                                    onTap: _geloest.contains(
                                            _rechtsReihenfolge[j])
                                        ? null
                                        : () {
                                            setState(
                                                () => _gewaehltRechts = j);
                                            _pruefe();
                                          },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (fertig)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _runden++;
                            _neueRunde();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Neue Runde'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ZfaTheme.violett,
                            foregroundColor: Colors.white),
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
              numberOfParticles: 22,
              colors: const [ZfaTheme.violett, ZfaTheme.gold, ZfaTheme.gruen],
            ),
          ),
        ],
      ),
    );
  }
}

class _Kachel extends StatelessWidget {
  final String text;
  final String? emoji;
  final bool gewaehlt;
  final bool geloest;
  final bool fehler;
  final bool klein;
  final VoidCallback? onTap;
  const _Kachel({
    required this.text,
    this.emoji,
    required this.gewaehlt,
    required this.geloest,
    required this.fehler,
    this.klein = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    Color bg = tc.withOpacity(0.06);
    Color border = tc.withOpacity(0.15);
    if (geloest) {
      bg = ZfaTheme.gruen.withOpacity(0.20);
      border = ZfaTheme.gruen;
    } else if (fehler) {
      bg = ZfaTheme.rot.withOpacity(0.18);
      border = ZfaTheme.rot;
    } else if (gewaehlt) {
      bg = ZfaTheme.blau.withOpacity(0.20);
      border = ZfaTheme.blau;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1.6),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (emoji != null && !klein)
                Text(emoji!, style: const TextStyle(fontSize: 20)),
              Text(text,
                  textAlign: TextAlign.center,
                  maxLines: klein ? 4 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: geloest ? tc.withOpacity(0.6) : tc,
                      fontSize: klein ? 12.5 : 14,
                      height: 1.2,
                      fontWeight:
                          klein ? FontWeight.w500 : FontWeight.w700,
                      decoration:
                          geloest ? TextDecoration.lineThrough : null)),
            ],
          ),
        ),
      ),
    );
  }
}
