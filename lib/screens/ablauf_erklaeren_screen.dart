import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../main.dart';
import '../core/services/stt_service.dart';
import '../core/text_match.dart';
import '../theme/zfa_theme.dart';
import '../models/behandlungsablauf.dart';
import '../widgets/sprach_eingabe_button.dart';
import '../widgets/lern_buddy.dart';

/// "Ablauf erklären": Der Prüfling erklärt einen Behandlungsablauf laut.
/// Die App erkennt die Sprache, prüft, welche Schritte genannt wurden,
/// und deckt die vollständige Lösung Phase für Phase auf.
class AblaufErklaerenScreen extends StatefulWidget {
  final Behandlungsablauf ablauf;
  const AblaufErklaerenScreen({super.key, required this.ablauf});

  @override
  State<AblaufErklaerenScreen> createState() => _AblaufErklaerenScreenState();
}

class _AblaufErklaerenScreenState extends State<AblaufErklaerenScreen> {
  final SttService _stt = SttService();
  String _erkannt = '';
  bool _hoert = false;
  bool _mikVerfuegbar = true;
  bool _ausgewertet = false;
  late ConfettiController _confetti;

  // pro Schritt: genannt?
  final Map<String, bool> _treffer = {};

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 1));
    _stt.onTextAendert = (t) {
      if (mounted) setState(() => _erkannt = t);
    };
    _stt.onAktivAendert = (a) {
      if (mounted) setState(() => _hoert = a);
    };
    _stt.initialisieren().then((ok) {
      if (mounted) setState(() => _mikVerfuegbar = ok);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        ttsService.sprechen('Erkläre den Ablauf: ${widget.ablauf.titel}'));
  }

  @override
  void dispose() {
    _stt.stoppeUndGibText();
    ttsService.stoppen();
    _confetti.dispose();
    super.dispose();
  }

  void _auswerten() {
    final gesagt = _erkannt;
    final gespStaemme = TextMatch.staemme(gesagt);
    int gesamt = 0;
    int getroffen = 0;
    for (final p in widget.ablauf.phasen) {
      for (final s in p.schritte) {
        gesamt++;
        final hit = TextMatch.genannt(s, gesagt, gespStaemme);
        _treffer[s] = hit;
        if (hit) getroffen++;
      }
    }
    setState(() => _ausgewertet = true);
    final quote = gesamt == 0 ? 0.0 : getroffen / gesamt;
    if (quote >= 0.6) {
      _confetti.play();
      soundService.richtig();
    }
  }

  Future<void> _mik() async {
    if (_hoert) {
      await _stt.stoppeUndGibText();
      _auswerten();
    } else {
      setState(() => _erkannt = '');
      await _stt.starteZuhoeren(kontinuierlich: true);
    }
  }

  void _selbstWertung(double score) {
    fortschrittService.frageRichtigBeantwortet('erkl_${widget.ablauf.id}',
        bereich: widget.ablauf.bereich);
    Navigator.pop(context);
  }

  int _getroffenAnzahl() => _treffer.values.where((v) => v).length;

  @override
  Widget build(BuildContext context) {
    final a = widget.ablauf;
    final tc = Theme.of(context).colorScheme.onSurface;
    final gesamt = a.anzahlSchritte;
    final quote = (_ausgewertet && gesamt > 0)
        ? _getroffenAnzahl() / gesamt
        : 0.0;
    final prozent = (quote * 100).round();

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
                        child: Text('Ablauf erklären',
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                    ]),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      children: [
                        // Aufgabe
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: ZfaTheme.violettGrad,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(a.emoji,
                                  style: const TextStyle(fontSize: 36)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text('Erkläre laut:',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12)),
                                    Text(a.titel,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 19,
                                            fontWeight: FontWeight.w800)),
                                    Text(
                                        'Nenne möglichst alle $gesamt Schritte in der richtigen Reihenfolge.',
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12.5,
                                            height: 1.3)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        if (!_ausgewertet) ...[
                          if (_mikVerfuegbar) ...[
                            Center(
                                child: SprachEingabeButton(
                                    aktiv: _hoert, onTippen: _mik)),
                            const SizedBox(height: 6),
                            Center(
                              child: Text(
                                  _hoert
                                      ? 'Erkläre in Ruhe ALLE Schritte – tippe das Mikro erst, wenn du fertig bist.'
                                      : 'Tippe das Mikro und erkläre den ganzen Ablauf am Stück.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: tc.withOpacity(0.6),
                                      fontSize: 12.5)),
                            ),
                          ]
                          else
                            Center(
                              child: Text(
                                  'Kein Mikrofon – erkläre laut für dich und tippe dann „Lösung zeigen".',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: tc.withOpacity(0.7))),
                            ),
                          const SizedBox(height: 12),
                          if (_erkannt.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: tc.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text('„$_erkannt"',
                                  style: TextStyle(
                                      color: tc,
                                      fontStyle: FontStyle.italic)),
                            ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: _auswerten,
                            icon: const Icon(Icons.checklist_rtl),
                            label: const Text('Lösung zeigen & prüfen'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: ZfaTheme.violett,
                                foregroundColor: Colors.white),
                          ),
                        ] else ...[
                          // Trefferquote
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: ZfaTheme.blauGrad,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                LernBuddy(
                                    stimmung: quote >= 0.6
                                        ? BuddyStimmung.jubel
                                        : BuddyStimmung.nachdenklich,
                                    groesse: 56),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                      'Du hast $prozent % der Schritte genannt (${_getroffenAnzahl()}/$gesamt).',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Lösung Phase für Phase
                          for (final p in a.phasen) ...[
                            Text(p.titel,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium),
                            const SizedBox(height: 6),
                            ...p.schritte.map((s) {
                              final hit = _treffer[s] ?? false;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                        hit
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        size: 18,
                                        color: hit
                                            ? ZfaTheme.gruen
                                            : tc.withOpacity(0.35)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(s,
                                          style: TextStyle(
                                              color: hit
                                                  ? tc
                                                  : tc.withOpacity(0.7),
                                              fontSize: 14,
                                              height: 1.35)),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 12),
                          ],
                          const SizedBox(height: 4),
                          Text('Wie gut konntest du es erklären?',
                              style: TextStyle(
                                  color: tc, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _selbstWertung(1.0),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: ZfaTheme.gruen,
                                      foregroundColor: Colors.white),
                                  child: const Text('Sicher'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _selbstWertung(0.5),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: ZfaTheme.gold,
                                      foregroundColor: Colors.black87),
                                  child: const Text('Teilweise'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Nochmal'),
                                ),
                              ),
                            ],
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
              numberOfParticles: 22,
              colors: const [ZfaTheme.violett, ZfaTheme.gold, ZfaTheme.gruen],
            ),
          ),
        ],
      ),
    );
  }
}
