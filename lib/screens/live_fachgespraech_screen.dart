import 'dart:async';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../main.dart';
import '../core/services/stt_service.dart';
import '../theme/zfa_theme.dart';
import '../models/fachgespraech_frage.dart';
import '../data/muendliche_pruefung_daten.dart';
import '../widgets/sprach_eingabe_button.dart';
import '../widgets/lern_buddy.dart';

class LiveFachgespraechScreen extends StatefulWidget {
  const LiveFachgespraechScreen({super.key});

  @override
  State<LiveFachgespraechScreen> createState() =>
      _LiveFachgespraechScreenState();
}

class _LiveFachgespraechScreenState extends State<LiveFachgespraechScreen> {
  final SttService _stt = SttService();
  late List<FachgespraechFrage> _fragen;
  final List<double> _scores = [];
  int _index = 0;
  String _erkannt = '';
  bool _hoert = false;
  bool _ausgewertet = false;
  bool _mikVerfuegbar = true;
  bool _fertig = false;
  double _letzterScore = 0;
  List<bool> _letzteTreffer = [];
  int _restSekunden = 75;
  Timer? _timer;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _fragen = alleFachgespraeche.toList()..shuffle();
    _fragen = _fragen.take(5).toList();
    _stt.onTextAendert = (t) {
      if (mounted) setState(() => _erkannt = t);
    };
    _stt.onAktivAendert = (a) {
      if (mounted) setState(() => _hoert = a);
    };
    _stt.initialisieren().then((ok) {
      if (mounted) setState(() => _mikVerfuegbar = ok);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _starteFrage());
  }

  void _starteFrage() {
    setState(() {
      _erkannt = '';
      _ausgewertet = false;
      _restSekunden = 75;
    });
    ttsService.sprechen(_fragen[_index].frage);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _restSekunden--);
      if (_restSekunden <= 0) {
        t.cancel();
        if (!_ausgewertet) _auswerten();
      }
    });
  }

  // Zerlegt einen Stichpunkt in bedeutsame Wörter (>=5 Buchstaben).
  List<String> _woerter(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-zäöüß ]'), ' ')
      .split(' ')
      .where((w) => w.length >= 5)
      .toList();

  void _auswerten() {
    _timer?.cancel();
    final frage = _fragen[_index];
    final gesagt = _erkannt.toLowerCase();
    final treffer = <bool>[];
    for (final sp in frage.stichpunkte) {
      final ws = _woerter(sp);
      final hit = ws.isEmpty ? false : ws.any((w) => gesagt.contains(w));
      treffer.add(hit);
    }
    final score = frage.stichpunkte.isEmpty
        ? 0.0
        : treffer.where((t) => t).length / frage.stichpunkte.length;
    setState(() {
      _ausgewertet = true;
      _letzterScore = score;
      _letzteTreffer = treffer;
    });
    if (score >= 0.6) soundService.richtig();
  }

  void _selbstWertung(double score) {
    _timer?.cancel();
    final frage = _fragen[_index];
    setState(() {
      _ausgewertet = true;
      _letzterScore = score;
      _letzteTreffer =
          List.generate(frage.stichpunkte.length, (i) => i < score * frage.stichpunkte.length);
    });
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

  void _weiter() {
    _scores.add(_letzterScore);
    ttsService.stoppen();
    if (_index < _fragen.length - 1) {
      setState(() => _index++);
      _starteFrage();
    } else {
      _abschluss();
    }
  }

  void _abschluss() {
    _timer?.cancel();
    final schnitt = _scores.isEmpty
        ? 0.0
        : _scores.reduce((a, b) => a + b) / _scores.length;
    final prozent = (schnitt * 100).round();
    if (prozent >= 50) {
      _confetti.play();
      soundService.levelUp();
    }
    setState(() => _fertig = true);
    fortschrittService.frageRichtigBeantwortet('live_fg', bereich: 'Anmeldung');
  }

  int _note(int prozent) {
    if (prozent >= 92) return 1;
    if (prozent >= 81) return 2;
    if (prozent >= 67) return 3;
    if (prozent >= 50) return 4;
    if (prozent >= 30) return 5;
    return 6;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stt.stoppeUndGibText();
    ttsService.stoppen();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_fertig) return _ergebnis();
    final frage = _fragen[_index];
    final tc = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_index + (_ausgewertet ? 1 : 0)) / _fragen.length,
                minHeight: 6,
                backgroundColor: tc.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation(ZfaTheme.violett),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.close, color: tc),
                        onPressed: () => Navigator.pop(context)),
                    Expanded(
                      child: Text('Frage ${_index + 1} / ${_fragen.length}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    // Timer
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (_restSekunden <= 15
                                ? ZfaTheme.rot
                                : ZfaTheme.violett)
                            .withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${_restSekunden}s',
                          style: TextStyle(
                              color: _restSekunden <= 15
                                  ? ZfaTheme.rot
                                  : tc,
                              fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Prüferfrage
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: ZfaTheme.violettGrad,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('👨‍⚕️ Prüfer fragt:',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 8),
                          Text(frage.frage,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  height: 1.35,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    if (!_ausgewertet) ...[
                      if (_mikVerfuegbar)
                        Center(
                            child: SprachEingabeButton(
                                aktiv: _hoert, onTippen: _mik))
                      else
                        _SelbstWertung(onWertung: _selbstWertung),
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
                                  color: tc, fontStyle: FontStyle.italic)),
                        ),
                      if (_mikVerfuegbar && _hoert)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: ElevatedButton.icon(
                            onPressed: _mik,
                            icon: const Icon(Icons.check),
                            label: const Text('Fertig & auswerten'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: ZfaTheme.violett,
                                foregroundColor: Colors.white),
                          ),
                        ),
                    ] else ...[
                      // Auswertung dieser Frage
                      _Bewertung(
                        score: _letzterScore,
                        stichpunkte: frage.stichpunkte,
                        treffer: _letzteTreffer,
                        muster: frage.musterantwort,
                        tc: tc,
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: _weiter,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ZfaTheme.violett,
                            foregroundColor: Colors.white),
                        child: Text(_index < _fragen.length - 1
                            ? 'Nächste Frage →'
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
    final schnitt = _scores.isEmpty
        ? 0.0
        : _scores.reduce((a, b) => a + b) / _scores.length;
    final prozent = (schnitt * 100).round();
    final note = _note(prozent);
    final bestanden = prozent >= 50;
    return Scaffold(
      body: Stack(
        children: [
          PremiumBackground(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LernBuddy(
                          stimmung: bestanden
                              ? BuddyStimmung.jubel
                              : BuddyStimmung.nachdenklich,
                          groesse: 120),
                      const SizedBox(height: 12),
                      Text(bestanden ? 'Bestanden!' : 'Fast geschafft!',
                          style: TextStyle(
                              color: tc,
                              fontSize: 26,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 18),
                      Container(
                        width: 130,
                        height: 130,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: bestanden
                              ? ZfaTheme.goldGrad
                              : const LinearGradient(colors: [
                                  Color(0xFF9AA6B2),
                                  Color(0xFF6B7682)
                                ]),
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
                                    fontSize: 56,
                                    fontWeight: FontWeight.w800,
                                    height: 1.0)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('$prozent % der Stichpunkte genannt',
                          style: TextStyle(color: tc.withOpacity(0.7))),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _fragen = alleFachgespraeche.toList()..shuffle();
                              _fragen = _fragen.take(5).toList();
                              _scores.clear();
                              _index = 0;
                              _fertig = false;
                            });
                            _starteFrage();
                          },
                          child: const Text('Nochmal prüfen'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Zurück'),
                        ),
                      ),
                    ],
                  ),
                ),
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
        ],
      ),
    );
  }
}

class _Bewertung extends StatelessWidget {
  final double score;
  final List<String> stichpunkte;
  final List<bool> treffer;
  final String muster;
  final Color tc;
  const _Bewertung({
    required this.score,
    required this.stichpunkte,
    required this.treffer,
    required this.muster,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    final prozent = (score * 100).round();
    final farbe = score >= 0.6
        ? ZfaTheme.gruen
        : score >= 0.3
            ? ZfaTheme.gold
            : ZfaTheme.rot;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: farbe.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: farbe.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$prozent % der Stichpunkte genannt',
              style: TextStyle(
                  color: farbe, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          for (int i = 0; i < stichpunkte.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                      (i < treffer.length && treffer[i])
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 18,
                      color: (i < treffer.length && treffer[i])
                          ? ZfaTheme.gruen
                          : tc.withOpacity(0.35)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(stichpunkte[i],
                          style: TextStyle(color: tc, fontSize: 13.5))),
                ],
              ),
            ),
          const Divider(height: 20),
          Text('Musterantwort',
              style: TextStyle(
                  color: tc.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(muster,
              style: TextStyle(color: tc, fontSize: 13.5, height: 1.45)),
        ],
      ),
    );
  }
}

class _SelbstWertung extends StatelessWidget {
  final void Function(double) onWertung;
  const _SelbstWertung({required this.onWertung});

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    return Column(
      children: [
        Text('Kein Mikrofon – antworte laut für dich und bewerte ehrlich:',
            textAlign: TextAlign.center,
            style: TextStyle(color: tc.withOpacity(0.7))),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => onWertung(1.0),
                style: ElevatedButton.styleFrom(
                    backgroundColor: ZfaTheme.gruen,
                    foregroundColor: Colors.white),
                child: const Text('Konnte ich gut'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => onWertung(0.5),
                style: ElevatedButton.styleFrom(
                    backgroundColor: ZfaTheme.gold,
                    foregroundColor: Colors.black87),
                child: const Text('Teilweise'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => onWertung(0.0),
                style: ElevatedButton.styleFrom(
                    backgroundColor: ZfaTheme.rot,
                    foregroundColor: Colors.white),
                child: const Text('Gar nicht'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
