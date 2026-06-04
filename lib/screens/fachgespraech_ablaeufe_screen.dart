import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../main.dart';
import '../core/services/stt_service.dart';
import '../core/text_match.dart';
import '../theme/zfa_theme.dart';
import '../models/behandlungsablauf.dart';
import '../data/behandlungsablaeufe_daten.dart';
import '../widgets/sprach_eingabe_button.dart';
import '../widgets/lern_buddy.dart';

/// Benotetes Fachgespräch über die echten Behandlungsabläufe:
/// Pro Frage einen Ablauf laut erklären, Bewertung über genannte Schritte,
/// am Ende Schulnote.
class FachgespraechAblaeufeScreen extends StatefulWidget {
  const FachgespraechAblaeufeScreen({super.key});

  @override
  State<FachgespraechAblaeufeScreen> createState() =>
      _FachgespraechAblaeufeScreenState();
}

class _FachgespraechAblaeufeScreenState
    extends State<FachgespraechAblaeufeScreen> {
  final SttService _stt = SttService();
  late List<Behandlungsablauf> _ablaeufe;
  final List<double> _scores = [];
  int _index = 0;
  String _erkannt = '';
  bool _hoert = false;
  bool _mikVerfuegbar = true;
  bool _ausgewertet = false;
  bool _fertig = false;
  Map<String, bool> _treffer = {};
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _ablaeufe = alleBehandlungsablaeufe.toList()..shuffle();
    _ablaeufe = _ablaeufe.take(4).toList();
    _stt.onTextAendert = (t) {
      if (mounted) setState(() => _erkannt = t);
    };
    _stt.onAktivAendert = (a) {
      if (mounted) setState(() => _hoert = a);
    };
    _stt.initialisieren().then((ok) {
      if (mounted) setState(() => _mikVerfuegbar = ok);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _frageVorlesen());
  }

  void _frageVorlesen() {
    ttsService.sprechen('Erkläre den Ablauf: ${_ablaeufe[_index].titel}');
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

  void _auswerten() {
    final a = _ablaeufe[_index];
    final gespStaemme = TextMatch.staemme(_erkannt);
    int gesamt = 0, hit = 0;
    final tr = <String, bool>{};
    for (final p in a.phasen) {
      for (final s in p.schritte) {
        gesamt++;
        final t = TextMatch.genannt(s, _erkannt, gespStaemme);
        tr[s] = t;
        if (t) hit++;
      }
    }
    final score = gesamt == 0 ? 0.0 : hit / gesamt;
    setState(() {
      _ausgewertet = true;
      _treffer = tr;
    });
    if (score >= 0.6) soundService.richtig();
    _letzterScore = score;
  }

  double _letzterScore = 0;

  void _weiter() {
    _scores.add(_letzterScore);
    ttsService.stoppen();
    if (_index < _ablaeufe.length - 1) {
      setState(() {
        _index++;
        _erkannt = '';
        _ausgewertet = false;
        _treffer = {};
      });
      _frageVorlesen();
    } else {
      final schnitt = _scores.reduce((a, b) => a + b) / _scores.length;
      if (einstellungenService.bestanden((schnitt * 100).round())) {
        _confetti.play();
        soundService.levelUp();
      }
      fortschrittService.frageRichtigBeantwortet('fg_ablaeufe',
          bereich: 'Behandlungsassistenz');
      setState(() => _fertig = true);
    }
  }

  @override
  void dispose() {
    _stt.stoppeUndGibText();
    ttsService.stoppen();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_fertig) return _ergebnis();
    final a = _ablaeufe[_index];
    final tc = Theme.of(context).colorScheme.onSurface;
    final gesamt = a.anzahlSchritte;
    final hit = _treffer.values.where((v) => v).length;
    final prozent = (gesamt == 0 ? 0 : hit / gesamt * 100).round();

    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_index + (_ausgewertet ? 1 : 0)) / _ablaeufe.length,
                minHeight: 6,
                backgroundColor: tc.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation(ZfaTheme.violett),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 4),
                child: Row(children: [
                  IconButton(
                      icon: Icon(Icons.close, color: tc),
                      onPressed: () => Navigator.pop(context)),
                  Expanded(
                    child: Text('Fachgespräch ${_index + 1}/${_ablaeufe.length}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const SizedBox(width: 40),
                ]),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: ZfaTheme.violettGrad,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(children: [
                        Text(a.emoji, style: const TextStyle(fontSize: 34)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('👨‍⚕️ Prüfer:',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                              Text('Erkläre den Ablauf „${a.titel}"',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    if (!_ausgewertet) ...[
                      if (_mikVerfuegbar)
                        Center(
                            child: SprachEingabeButton(
                                aktiv: _hoert, onTippen: _mik))
                      else
                        Center(
                            child: Text(
                                'Kein Mikrofon – erkläre laut und tippe „Lösung".',
                                style:
                                    TextStyle(color: tc.withOpacity(0.7)))),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                            _hoert
                                ? 'Erkläre ALLE Schritte – tippe das Mikro erst, wenn du fertig bist.'
                                : 'Tippe das Mikro und erkläre den ganzen Ablauf.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: tc.withOpacity(0.6), fontSize: 12.5)),
                      ),
                      if (_erkannt.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: tc.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text('„$_erkannt"',
                              style: TextStyle(
                                  color: tc, fontStyle: FontStyle.italic)),
                        ),
                      ],
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: _auswerten,
                        icon: const Icon(Icons.checklist_rtl),
                        label: const Text('Lösung & bewerten'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ZfaTheme.violett,
                            foregroundColor: Colors.white),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: ZfaTheme.blauGrad,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text('$prozent % der Schritte genannt ($hit/$gesamt)',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15)),
                      ),
                      const SizedBox(height: 12),
                      for (final p in a.phasen) ...[
                        Text(p.titel,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        ...p.schritte.map((s) {
                          final t = _treffer[s] ?? false;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                    t
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    size: 17,
                                    color: t
                                        ? ZfaTheme.gruen
                                        : tc.withOpacity(0.35)),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(s,
                                        style: TextStyle(
                                            color: t ? tc : tc.withOpacity(0.7),
                                            fontSize: 13.5,
                                            height: 1.3))),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 10),
                      ],
                      ElevatedButton(
                        onPressed: _weiter,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ZfaTheme.violett,
                            foregroundColor: Colors.white),
                        child: Text(_index < _ablaeufe.length - 1
                            ? 'Nächster Ablauf →'
                            : 'Zur Note 🎓'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ergebnis() {
    final tc = Theme.of(context).colorScheme.onSurface;
    final schnitt =
        _scores.isEmpty ? 0.0 : _scores.reduce((a, b) => a + b) / _scores.length;
    final prozent = (schnitt * 100).round();
    final note = einstellungenService.note(prozent);
    final bestanden = einstellungenService.bestanden(prozent);
    return Scaffold(
      body: Stack(children: [
        PremiumBackground(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 8),
                Center(
                  child: LernBuddy(
                      stimmung: bestanden
                          ? BuddyStimmung.jubel
                          : BuddyStimmung.nachdenklich,
                      groesse: 110),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(bestanden ? 'Bestanden! 🎉' : 'Fast geschafft!',
                      style: TextStyle(
                          color: tc,
                          fontSize: 24,
                          fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Container(
                    width: 130,
                    height: 130,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: bestanden
                          ? ZfaTheme.goldGrad
                          : const LinearGradient(
                              colors: [Color(0xFF9AA6B2), Color(0xFF6B7682)]),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Note',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        Text('$note',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 54,
                                fontWeight: FontWeight.w800,
                                height: 1.0)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Text('Ø $prozent % der Schritte genannt',
                      style: TextStyle(color: tc.withOpacity(0.7))),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _ablaeufe = alleBehandlungsablaeufe.toList()..shuffle();
                      _ablaeufe = _ablaeufe.take(4).toList();
                      _scores.clear();
                      _index = 0;
                      _ausgewertet = false;
                      _treffer = {};
                      _erkannt = '';
                      _fertig = false;
                    });
                    _frageVorlesen();
                  },
                  child: const Text('Nochmal'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Zurück'),
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
            numberOfParticles: 26,
            colors: const [
              ZfaTheme.gold,
              ZfaTheme.violett,
              ZfaTheme.blau,
              ZfaTheme.gruen
            ],
          ),
        ),
      ]),
    );
  }
}
