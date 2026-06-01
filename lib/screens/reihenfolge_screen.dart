import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../main.dart';
import '../theme/zfa_theme.dart';
import '../data/behandlungsablaeufe_daten.dart';

class _Aufgabe {
  final String ablauf;
  final String phase;
  final List<String> richtig; // korrekte Reihenfolge
  const _Aufgabe(this.ablauf, this.phase, this.richtig);
}

/// Interaktive Übung: Schritte eines echten Behandlungsablaufs in die
/// richtige Reihenfolge ziehen.
class ReihenfolgeScreen extends StatefulWidget {
  const ReihenfolgeScreen({super.key});

  @override
  State<ReihenfolgeScreen> createState() => _ReihenfolgeScreenState();
}

class _ReihenfolgeScreenState extends State<ReihenfolgeScreen> {
  final _rng = Random();
  late List<_Aufgabe> _pool;
  late _Aufgabe _aufgabe;
  late List<String> _aktuell; // aktuelle (verschobene) Reihenfolge
  bool _geprueft = false;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 1));
    _pool = [];
    for (final a in alleBehandlungsablaeufe) {
      for (final p in a.phasen) {
        final n = p.schritte.length;
        final t = p.titel.toLowerCase();
        final geeignet = n >= 4 &&
            n <= 7 &&
            !t.contains('instrument') &&
            !t.contains('material');
        if (geeignet) {
          _pool.add(_Aufgabe(a.titel, p.titel, List.of(p.schritte)));
        }
      }
    }
    _neueAufgabe();
  }

  void _neueAufgabe() {
    _aufgabe = _pool[_rng.nextInt(_pool.length)];
    _aktuell = List.of(_aufgabe.richtig);
    do {
      _aktuell.shuffle(_rng);
    } while (_listeGleich(_aktuell, _aufgabe.richtig) && _aktuell.length > 1);
    _geprueft = false;
  }

  bool _listeGleich(List<String> a, List<String> b) {
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  int _richtigePositionen() {
    int n = 0;
    for (int i = 0; i < _aktuell.length; i++) {
      if (_aktuell[i] == _aufgabe.richtig[i]) n++;
    }
    return n;
  }

  void _pruefen() {
    setState(() => _geprueft = true);
    final richtig = _richtigePositionen();
    if (richtig == _aufgabe.richtig.length) {
      _confetti.play();
      soundService.richtig();
      HapticFeedback.mediumImpact();
      fortschrittService.frageRichtigBeantwortet('reihenfolge',
          bereich: 'Behandlungsassistenz');
    } else {
      soundService.falsch();
      HapticFeedback.heavyImpact();
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
    final alleRichtig =
        _geprueft && _richtigePositionen() == _aufgabe.richtig.length;
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
                        child: Text('Reihenfolge bringen',
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: ZfaTheme.violettGrad,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('👆 Ziehe die Schritte in die richtige Reihenfolge',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15)),
                          const SizedBox(height: 4),
                          Text('${_aufgabe.ablauf} · ${_aufgabe.phase}',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      itemCount: _aktuell.length,
                      onReorder: (oldI, newI) {
                        if (_geprueft) return;
                        setState(() {
                          if (newI > oldI) newI--;
                          final item = _aktuell.removeAt(oldI);
                          _aktuell.insert(newI, item);
                        });
                        HapticFeedback.selectionClick();
                      },
                      itemBuilder: (context, i) {
                        final richtigHier =
                            _geprueft && _aktuell[i] == _aufgabe.richtig[i];
                        final falschHier =
                            _geprueft && _aktuell[i] != _aufgabe.richtig[i];
                        Color bg = tc.withOpacity(0.06);
                        Color border = tc.withOpacity(0.15);
                        if (richtigHier) {
                          bg = ZfaTheme.gruen.withOpacity(0.18);
                          border = ZfaTheme.gruen;
                        } else if (falschHier) {
                          bg = ZfaTheme.rot.withOpacity(0.15);
                          border = ZfaTheme.rot;
                        }
                        return Padding(
                          key: ValueKey(_aktuell[i]),
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: border, width: 1.6),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ZfaTheme.violett.withOpacity(0.8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('${i + 1}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(_aktuell[i],
                                      style: TextStyle(
                                          color: tc,
                                          fontSize: 14.5,
                                          height: 1.3)),
                                ),
                                if (_geprueft)
                                  Icon(
                                      richtigHier
                                          ? Icons.check_circle
                                          : Icons.close,
                                      color: richtigHier
                                          ? ZfaTheme.gruen
                                          : ZfaTheme.rot,
                                      size: 20)
                                else
                                  Icon(Icons.drag_handle,
                                      color: tc.withOpacity(0.4)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: !_geprueft
                        ? ElevatedButton.icon(
                            onPressed: _pruefen,
                            icon: const Icon(Icons.check),
                            label: const Text('Prüfen'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: ZfaTheme.violett,
                                foregroundColor: Colors.white),
                          )
                        : Column(
                            children: [
                              Text(
                                  alleRichtig
                                      ? 'Perfekt! Alles richtig. 🎉'
                                      : '${_richtigePositionen()}/${_aufgabe.richtig.length} an der richtigen Stelle',
                                  style: TextStyle(
                                      color: alleRichtig
                                          ? ZfaTheme.gruen
                                          : tc,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    setState(() => _neueAufgabe()),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Nächste Aufgabe'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: ZfaTheme.violett,
                                    foregroundColor: Colors.white),
                              ),
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
              numberOfParticles: 22,
              colors: const [ZfaTheme.violett, ZfaTheme.gold, ZfaTheme.gruen],
            ),
          ),
        ],
      ),
    );
  }
}
