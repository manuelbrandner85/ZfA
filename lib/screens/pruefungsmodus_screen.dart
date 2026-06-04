import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../main.dart';
import '../theme/zfa_theme.dart';
import '../models/quiz_frage.dart';
import '../data/quiz/alle_quiz_fragen.dart';
import '../widgets/lern_buddy.dart';
import '../widgets/schwierigkeit.dart';

enum _Phase { konfig, pruefung, ergebnis }

/// Echter Prüfungsmodus wie in der IHK-Abschlussprüfung:
/// Zeitlimit, Fragen-Navigator, Markieren, KEIN Soforт-Feedback,
/// am Ende Note, Bestehen und Auswertung.
class PruefungsmodusScreen extends StatefulWidget {
  const PruefungsmodusScreen({super.key});

  @override
  State<PruefungsmodusScreen> createState() => _PruefungsmodusScreenState();
}

class _PruefungsmodusScreenState extends State<PruefungsmodusScreen> {
  _Phase _phase = _Phase.konfig;

  // Konfiguration
  int _anzahl = 20;
  String _schwierigkeit = 'Alle';

  // Prüfung
  late List<QuizFrage> _fragen;
  late List<List<int>> _reihenfolge; // gemischte Antwortreihenfolge je Frage
  late List<int?> _gewaehlt; // Original-Index der gewählten Antwort
  final Set<int> _markiert = {};
  int _index = 0;
  int _restSekunden = 0;
  Timer? _timer;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  void _start() {
    var pool = alleQuizFragen.toList();
    if (_schwierigkeit != 'Alle') {
      final key = _schwierigkeit.toLowerCase();
      final f = pool.where((q) => q.schwierigkeit == key).toList();
      if (f.length >= 5) pool = f;
    }
    pool.shuffle();
    _fragen = pool.take(_anzahl).toList();
    _reihenfolge = _fragen
        .map((q) => (List.generate(q.antworten.length, (i) => i)..shuffle()))
        .toList();
    _gewaehlt = List.filled(_fragen.length, null);
    _markiert.clear();
    _index = 0;
    _restSekunden = _fragen.length * 75; // 75 Sekunden pro Frage
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _restSekunden--);
      if (_restSekunden <= 0) {
        t.cancel();
        _abgeben(zeitAbgelaufen: true);
      }
    });
    setState(() => _phase = _Phase.pruefung);
  }

  void _abgeben({bool zeitAbgelaufen = false}) {
    _timer?.cancel();
    // Ergebnis in den Fortschritt einspeisen
    for (int i = 0; i < _fragen.length; i++) {
      final q = _fragen[i];
      if (_gewaehlt[i] == q.richtigeAntwortIndex) {
        fortschrittService.frageRichtigBeantwortet(q.id, bereich: q.bereich);
      } else {
        fortschrittService.frageFalschBeantwortet(q.id, bereich: q.bereich);
      }
    }
    final prozent = _prozent();
    if (einstellungenService.bestanden(prozent)) {
      _confetti.play();
      soundService.levelUp();
    }
    setState(() => _phase = _Phase.ergebnis);
  }

  int get _beantwortet => _gewaehlt.where((g) => g != null).length;

  int _richtigAnzahl() {
    int n = 0;
    for (int i = 0; i < _fragen.length; i++) {
      if (_gewaehlt[i] == _fragen[i].richtigeAntwortIndex) n++;
    }
    return n;
  }

  int _prozent() =>
      _fragen.isEmpty ? 0 : (_richtigAnzahl() / _fragen.length * 100).round();

  int _note(int p) => einstellungenService.note(p);

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.konfig:
        return _konfig();
      case _Phase.pruefung:
        return _pruefung();
      case _Phase.ergebnis:
        return _ergebnis();
    }
  }

  // ---------------- Konfiguration ----------------
  Widget _konfig() {
    final tc = Theme.of(context).colorScheme.onSurface;
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
                  Text('Prüfungsmodus',
                      style: Theme.of(context).textTheme.titleLarge),
                ]),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: ZfaTheme.blauGrad,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Row(
                        children: [
                          Text('🎯', style: TextStyle(fontSize: 40)),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                                'Wie in der echten Prüfung: mit Zeit, ohne Hilfe, Note am Ende.',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    height: 1.35,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text('Anzahl Fragen',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: [10, 20, 40].map((n) {
                        final aktiv = _anzahl == n;
                        return ChoiceChip(
                          label: Text('$n'),
                          selected: aktiv,
                          onSelected: (_) => setState(() => _anzahl = n),
                          selectedColor: ZfaTheme.blau,
                          labelStyle: TextStyle(
                              color: aktiv ? Colors.white : tc,
                              fontWeight: FontWeight.w700),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text('Schwierigkeit',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children:
                          ['Alle', 'Leicht', 'Mittel', 'Schwer'].map((s) {
                        final aktiv = _schwierigkeit == s;
                        final farbe = s == 'Alle'
                            ? ZfaTheme.blau
                            : Schwierigkeit.farbe(s.toLowerCase());
                        return ChoiceChip(
                          label: Text(s),
                          selected: aktiv,
                          onSelected: (_) =>
                              setState(() => _schwierigkeit = s),
                          selectedColor: farbe,
                          labelStyle: TextStyle(
                              color: aktiv ? Colors.white : tc,
                              fontWeight: FontWeight.w700),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    GlassCard(
                      child: Row(
                        children: [
                          Icon(Icons.timer_outlined, color: tc),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                                'Zeitlimit: ${(_anzahl * 75 / 60).round()} Minuten (75 s pro Frage)',
                                style: TextStyle(color: tc, fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _start,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Prüfung starten'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: ZfaTheme.blau,
                          foregroundColor: Colors.white),
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

  // ---------------- Prüfung ----------------
  Widget _pruefung() {
    final tc = Theme.of(context).colorScheme.onSurface;
    final q = _fragen[_index];
    final min = _restSekunden ~/ 60;
    final sek = _restSekunden % 60;
    final knapp = _restSekunden <= 60;
    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Kopf mit Timer
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                child: Row(
                  children: [
                    Text('Frage ${_index + 1}/${_fragen.length}',
                        style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: (knapp ? ZfaTheme.rot : ZfaTheme.blau)
                            .withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(children: [
                        Icon(Icons.timer,
                            size: 16,
                            color: knapp ? ZfaTheme.rot : tc),
                        const SizedBox(width: 6),
                        Text(
                            '${min.toString().padLeft(2, '0')}:${sek.toString().padLeft(2, '0')}',
                            style: TextStyle(
                                color: knapp ? ZfaTheme.rot : tc,
                                fontWeight: FontWeight.w800)),
                      ]),
                    ),
                  ],
                ),
              ),
              // Navigator-Strip
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _fragen.length,
                  itemBuilder: (_, i) {
                    final beantwortet = _gewaehlt[i] != null;
                    final markiert = _markiert.contains(i);
                    final aktuell = i == _index;
                    Color bg = tc.withOpacity(0.10);
                    if (markiert) bg = ZfaTheme.gold.withOpacity(0.6);
                    if (beantwortet) bg = ZfaTheme.blau.withOpacity(0.7);
                    return GestureDetector(
                      onTap: () => setState(() => _index = i),
                      child: Container(
                        width: 32,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 6),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(8),
                          border: aktuell
                              ? Border.all(color: tc, width: 2)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text('${i + 1}',
                            style: TextStyle(
                                color: (beantwortet || markiert)
                                    ? Colors.white
                                    : tc,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SchwierigkeitBadge(
                                  schwierigkeit: q.schwierigkeit),
                              Text(q.bereich,
                                  style: TextStyle(
                                      color: tc.withOpacity(0.6),
                                      fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(q.frage,
                              style: TextStyle(
                                  color: tc,
                                  fontSize: 19,
                                  height: 1.4,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...List.generate(q.antworten.length, (pos) {
                      final orig = _reihenfolge[_index][pos];
                      final gewaehlt = _gewaehlt[_index] == orig;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            soundService.tap();
                            setState(() => _gewaehlt[_index] = orig);
                          },
                          child: Container(
                            constraints:
                                const BoxConstraints(minHeight: 56),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: gewaehlt
                                  ? ZfaTheme.blau.withOpacity(0.18)
                                  : tc.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: gewaehlt
                                      ? ZfaTheme.blau
                                      : tc.withOpacity(0.18),
                                  width: gewaehlt ? 2 : 1.4),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                    gewaehlt
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: gewaehlt
                                        ? ZfaTheme.blau
                                        : tc.withOpacity(0.4),
                                    size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(q.antworten[orig],
                                      style: TextStyle(
                                          color: tc,
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              // Steuerleiste
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: _index > 0
                          ? () => setState(() => _index--)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() {
                          if (!_markiert.add(_index)) _markiert.remove(_index);
                        }),
                        icon: Icon(
                            _markiert.contains(_index)
                                ? Icons.flag
                                : Icons.flag_outlined,
                            color: ZfaTheme.gold),
                        label: Text(
                            _markiert.contains(_index)
                                ? 'Markiert'
                                : 'Markieren',
                            style: const TextStyle(color: ZfaTheme.gold)),
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: ZfaTheme.gold)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (_index < _fragen.length - 1)
                      IconButton.filledTonal(
                        onPressed: () => setState(() => _index++),
                        icon: const Icon(Icons.chevron_right),
                      )
                    else
                      ElevatedButton(
                        onPressed: _abgebenDialog,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ZfaTheme.gruen,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 48)),
                        child: const Text('Abgeben'),
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

  void _abgebenDialog() {
    final offen = _fragen.length - _beantwortet;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Prüfung abgeben?'),
        content: Text(offen == 0
            ? 'Alle Fragen beantwortet. Jetzt abgeben?'
            : 'Noch $offen Frage(n) offen. Trotzdem abgeben?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Zurück')),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _abgeben();
              },
              style:
                  ElevatedButton.styleFrom(minimumSize: const Size(110, 44)),
              child: const Text('Abgeben')),
        ],
      ),
    );
  }

  // ---------------- Ergebnis ----------------
  Widget _ergebnis() {
    final tc = Theme.of(context).colorScheme.onSurface;
    final prozent = _prozent();
    final note = _note(prozent);
    final bestanden = einstellungenService.bestanden(prozent);
    final falsche = [
      for (int i = 0; i < _fragen.length; i++)
        if (_gewaehlt[i] != _fragen[i].richtigeAntwortIndex) i
    ];
    return Scaffold(
      body: Stack(
        children: [
          PremiumBackground(
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
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
                    child: Text(bestanden ? 'Bestanden! 🎉' : 'Noch nicht bestanden',
                        style: TextStyle(
                            color: tc,
                            fontSize: 24,
                            fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                          child: _ErgebnisKachel(
                              titel: 'Note', wert: '$note', tc: tc)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _ErgebnisKachel(
                              titel: 'Ergebnis',
                              wert: '$prozent %',
                              tc: tc)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _ErgebnisKachel(
                              titel: 'Richtig',
                              wert: '${_richtigAnzahl()}/${_fragen.length}',
                              tc: tc)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (falsche.isNotEmpty) ...[
                    Text('Zum Nacharbeiten (${falsche.length})',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    ...falsche.map((i) {
                      final q = _fragen[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(q.frage,
                                  style: TextStyle(
                                      color: tc,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.5)),
                              const SizedBox(height: 6),
                              Text(
                                  '✅ ${q.antworten[q.richtigeAntwortIndex]}',
                                  style: const TextStyle(
                                      color: ZfaTheme.gruen,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              if (_gewaehlt[i] != null)
                                Text('✗ Deine: ${q.antworten[_gewaehlt[i]!]}',
                                    style: TextStyle(
                                        color: ZfaTheme.rot
                                            .withOpacity(0.9),
                                        fontSize: 13)),
                              const SizedBox(height: 6),
                              Text(q.erklaerung,
                                  style: TextStyle(
                                      color: tc.withOpacity(0.75),
                                      fontSize: 13,
                                      height: 1.4)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(() => _phase = _Phase.konfig),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ZfaTheme.blau,
                        foregroundColor: Colors.white),
                    child: const Text('Neue Prüfung'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Zurück zur Startseite'),
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
              numberOfParticles: 28,
              colors: const [
                ZfaTheme.gold,
                ZfaTheme.blau,
                ZfaTheme.gruen,
                ZfaTheme.violett
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErgebnisKachel extends StatelessWidget {
  final String titel;
  final String wert;
  final Color tc;
  const _ErgebnisKachel(
      {required this.titel, required this.wert, required this.tc});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(wert,
              style: TextStyle(
                  color: tc, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(titel,
              style: TextStyle(color: tc.withOpacity(0.6), fontSize: 12)),
        ],
      ),
    );
  }
}
