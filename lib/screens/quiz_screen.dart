import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:animate_do/animate_do.dart';
import '../main.dart';
import '../models/quiz_frage.dart';
import '../data/quiz/alle_quiz_fragen.dart';
import '../widgets/tts_button.dart';
import '../widgets/lern_buddy.dart';
import '../widgets/schwierigkeit.dart';

class QuizScreen extends StatefulWidget {
  final String? nurBereich;
  final bool nurFehler;
  const QuizScreen({super.key, this.nurBereich, this.nurFehler = false});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<QuizFrage> _fragen;
  int _index = 0;
  int? _gewaehlt;
  bool _beantwortet = false;
  int _punkteSession = 0;
  int _richtigInFolge = 0;
  late List<int> _antwortReihenfolge; // gemischte Anzeige-Reihenfolge
  String _schwierigkeit = 'Alle'; // Alle / Leicht / Mittel / Schwer
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 1));
    _fragenLaden();
  }

  void _fragenLaden() {
    var pool = alleQuizFragen.toList();
    if (widget.nurFehler) {
      final ids = fortschrittService.fehlerFragen;
      _fragen = pool.where((f) => ids.contains(f.id)).toList()..shuffle();
      _mischen();
      return;
    }
    if (widget.nurBereich != null) {
      pool = pool.where((f) => f.bereich == widget.nurBereich).toList();
    }
    if (_schwierigkeit != 'Alle') {
      final key = _schwierigkeit.toLowerCase();
      final gefiltert = pool.where((f) => f.schwierigkeit == key).toList();
      if (gefiltert.isNotEmpty) pool = gefiltert;
    }
    // Spaced Repetition: heute fällige Fragen zuerst
    final faelligeIds =
        fortschrittService.fragenFuerHeute(pool.map((f) => f.id).toList());
    pool.sort((a, b) {
      final aF = faelligeIds.contains(a.id) ? 0 : 1;
      final bF = faelligeIds.contains(b.id) ? 0 : 1;
      if (aF != bF) return aF - bF;
      // niedrigere Leitner-Box zuerst (schwächer = öfter)
      final aBox = fortschrittService.leitnerBoxen[a.id] ?? 1;
      final bBox = fortschrittService.leitnerBoxen[b.id] ?? 1;
      return aBox - bBox;
    });
    _fragen = pool.take(10).toList();
    _mischen();
  }

  // Mischt die Antwortreihenfolge der aktuellen Frage, damit die richtige
  // Antwort nicht immer an derselben Stelle steht.
  void _mischen() {
    if (_fragen.isEmpty) return;
    _antwortReihenfolge =
        List.generate(_fragen[_index].antworten.length, (i) => i)..shuffle();
  }

  void _antworten(int i) {
    if (_beantwortet) return;
    final frage = _fragen[_index];
    final richtig = i == frage.richtigeAntwortIndex;
    setState(() {
      _gewaehlt = i;
      _beantwortet = true;
    });
    if (richtig) {
      HapticFeedback.lightImpact();
      soundService.richtig();
      _confetti.play();
      _punkteSession += 10;
      _richtigInFolge++;
      fortschrittService.frageRichtigBeantwortet(frage.id,
          bereich: frage.bereich);
      ttsService.sprechen('Super gemacht!');
    } else {
      HapticFeedback.heavyImpact();
      soundService.falsch();
      _richtigInFolge = 0;
      fortschrittService.frageFalschBeantwortet(frage.id,
          bereich: frage.bereich);
    }
  }

  void _weiter() {
    if (_index < _fragen.length - 1) {
      setState(() {
        _index++;
        _gewaehlt = null;
        _beantwortet = false;
        _mischen();
      });
    } else {
      _zeigeEnde();
    }
  }

  void _zeigeEnde() {
    _confetti.play();
    soundService.levelUp();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LernBuddy(stimmung: BuddyStimmung.jubel, groesse: 104),
              const SizedBox(height: 12),
              const Text('Geschafft!',
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Du hast $_punkteSession Punkte gesammelt! ⭐',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _index = 0;
                    _gewaehlt = null;
                    _beantwortet = false;
                    _punkteSession = 0;
                    _richtigInFolge = 0;
                    _fragenLaden();
                  });
                },
                child: const Text('Nochmal 🔄'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52)),
                child: const Text('Zurück'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_fragen.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.nurFehler ? '🛟 Fehler-Sammlung' : '🎯 Quiz'),
          backgroundColor: const Color(0xFFE65100),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              widget.nurFehler
                  ? 'Stark! Du hast aktuell keine offenen Fehler. 🎉\nFalsch beantwortete Fragen landen hier automatisch zum Wiederholen.'
                  : 'Keine Fragen verfügbar.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ),
      );
    }
    final frage = _fragen[_index];
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯 Quiz'),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('⭐ $_punkteSession',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Fortschrittsbalken
              LinearProgressIndicator(
                value: (_index + 1) / _fragen.length,
                minHeight: 8,
                backgroundColor: const Color(0xFFFFE0B2),
                valueColor:
                    const AlwaysStoppedAnimation(Color(0xFFE65100)),
              ),
              // Schwierigkeits-Filter
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: ['Alle', 'Leicht', 'Mittel', 'Schwer'].map((s) {
                    final aktiv = _schwierigkeit == s;
                    final farbe = s == 'Alle'
                        ? const Color(0xFFE65100)
                        : Schwierigkeit.farbe(s.toLowerCase());
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 7),
                      child: ChoiceChip(
                        label: Text(s),
                        selected: aktiv,
                        onSelected: (_) {
                          setState(() {
                            _schwierigkeit = s;
                            _index = 0;
                            _gewaehlt = null;
                            _beantwortet = false;
                            _fragenLaden();
                          });
                        },
                        selectedColor: farbe,
                        labelStyle: TextStyle(
                            color: aktiv ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (_richtigInFolge >= 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Pulse(
                    infinite: true,
                    child: Text('🔥 $_richtigInFolge in Folge!',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE65100))),
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    // Frage
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                SchwierigkeitBadge(
                                    schwierigkeit: frage.schwierigkeit),
                                TtsButton(
                                    text: frage.frage,
                                    farbe: const Color(0xFFE65100)),
                              ],
                            ),
                            Text(
                              frage.frage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Einfache Erklärung (immer sichtbar)
                    _InfoBox(
                      farbe: const Color(0xFF1565C0),
                      emoji: '💡',
                      titel: 'Einfach erklärt',
                      text: frage.einfacheErklaerung,
                    ),
                    if (frage.merkhilfe != null) ...[
                      const SizedBox(height: 10),
                      _InfoBox(
                        farbe: const Color(0xFF6A1B9A),
                        emoji: '🧠',
                        titel: 'Merkhilfe',
                        text: frage.merkhilfe!,
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Antworten
                    ...List.generate(frage.antworten.length, (pos) {
                      final i = _antwortReihenfolge[pos];
                      return _AntwortButton(
                        text: frage.antworten[i],
                        zustand: _buttonZustand(i, frage),
                        onTap: () => _antworten(i),
                      );
                    }),
                    // Erklärung nach Antwort
                    if (_beantwortet) ...[
                      const SizedBox(height: 14),
                      FadeInUp(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: const Color(0xFF2E7D32), width: 1.5),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('✅',
                                  style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  frage.erklaerung,
                                  style: const TextStyle(
                                      fontSize: 15, height: 1.5),
                                ),
                              ),
                              TtsButton(
                                  text: frage.erklaerung,
                                  farbe: const Color(0xFF2E7D32)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: _weiter,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE65100),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(_index < _fragen.length - 1
                            ? 'Weiter →'
                            : 'Fertig 🎉'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // Konfetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 24,
              maxBlastForce: 18,
              minBlastForce: 6,
              gravity: 0.3,
              colors: const [
                Color(0xFFE65100),
                Color(0xFFD4AF37),
                Color(0xFF1565C0),
                Color(0xFF2E7D32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _AntwortZustand _buttonZustand(int i, QuizFrage frage) {
    if (!_beantwortet) return _AntwortZustand.normal;
    if (i == frage.richtigeAntwortIndex) return _AntwortZustand.richtig;
    if (i == _gewaehlt) return _AntwortZustand.falsch;
    return _AntwortZustand.normal;
  }
}

enum _AntwortZustand { normal, richtig, falsch }

class _AntwortButton extends StatelessWidget {
  final String text;
  final _AntwortZustand zustand;
  final VoidCallback onTap;

  const _AntwortButton({
    required this.text,
    required this.zustand,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.white;
    Color border = const Color(0xFFE0E0E0);
    Color txt = const Color(0xFF263238);
    IconData? icon;
    switch (zustand) {
      case _AntwortZustand.richtig:
        bg = const Color(0xFFC8E6C9);
        border = const Color(0xFF2E7D32);
        icon = Icons.check_circle;
        break;
      case _AntwortZustand.falsch:
        bg = const Color(0xFFFFCDD2);
        border = const Color(0xFFC62828);
        icon = Icons.cancel;
        break;
      case _AntwortZustand.normal:
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 1.8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: txt,
                    ),
                  ),
                ),
                if (icon != null) Icon(icon, color: border),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final Color farbe;
  final String emoji;
  final String titel;
  final String text;

  const _InfoBox({
    required this.farbe,
    required this.emoji,
    required this.titel,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: farbe.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: farbe.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                titel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: farbe,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(fontSize: 15, height: 1.45)),
        ],
      ),
    );
  }
}
