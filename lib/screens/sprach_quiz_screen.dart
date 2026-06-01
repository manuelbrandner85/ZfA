import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../main.dart';
import '../core/services/stt_service.dart';
import '../models/quiz_frage.dart';
import '../data/quiz/alle_quiz_fragen.dart';
import '../widgets/sprach_eingabe_button.dart';
import '../widgets/tts_button.dart';

class SprachQuizScreen extends StatefulWidget {
  const SprachQuizScreen({super.key});

  @override
  State<SprachQuizScreen> createState() => _SprachQuizScreenState();
}

class _SprachQuizScreenState extends State<SprachQuizScreen> {
  final SttService _stt = SttService();
  late List<QuizFrage> _fragen;
  int _index = 0;
  String _erkannt = '';
  bool _hoert = false;
  bool _ausgewertet = false;
  bool? _richtig;
  bool _multipleChoice = false;
  bool _mikrofonVerfuegbar = true;
  Color _flash = Colors.transparent;
  int? _gewaehlt;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 1));
    // Fragen mit Schlüsselwörtern bevorzugen
    _fragen = alleQuizFragen
        .where((f) => f.schluesselwoerter.isNotEmpty)
        .toList()
      ..shuffle();
    _fragen = _fragen.take(10).toList();

    _stt.onTextAendert = (t) {
      if (mounted) setState(() => _erkannt = t);
    };
    _stt.onAktivAendert = (a) {
      if (mounted) setState(() => _hoert = a);
      if (!a && _erkannt.isNotEmpty && !_ausgewertet) {
        _auswerten();
      }
    };
    _initMikrofon();
    WidgetsBinding.instance.addPostFrameCallback((_) => _frageVorlesen());
  }

  Future<void> _initMikrofon() async {
    final ok = await _stt.initialisieren();
    if (!ok && mounted) {
      setState(() {
        _mikrofonVerfuegbar = false;
        _multipleChoice = true;
      });
    }
  }

  void _frageVorlesen() {
    ttsService.sprechen(_fragen[_index].frage);
  }

  Future<void> _mikTippen() async {
    if (_ausgewertet) return;
    if (_hoert) {
      await _stt.stoppeUndGibText();
      _auswerten();
    } else {
      setState(() => _erkannt = '');
      await _stt.starteZuhoeren();
    }
  }

  void _auswerten() {
    if (_ausgewertet) return;
    final frage = _fragen[_index];
    final richtig = _stt.pruefeAntwort(_erkannt, frage.schluesselwoerter);
    _verarbeite(richtig);
  }

  void _verarbeite(bool richtig) {
    setState(() {
      _ausgewertet = true;
      _richtig = richtig;
      _flash = richtig
          ? const Color(0xFF2E7D32).withOpacity(0.25)
          : const Color(0xFFC62828).withOpacity(0.25);
    });
    final frage = _fragen[_index];
    if (richtig) {
      _confetti.play();
      fortschrittService.frageRichtigBeantwortet(frage.id,
          bereich: frage.bereich);
      ttsService.sprechen('Super gemacht!');
    } else {
      fortschrittService.frageFalschBeantwortet(frage.id,
          bereich: frage.bereich);
      final richtigeAntwort = frage.antworten[frage.richtigeAntwortIndex];
      ttsService.sprechen('Fast! Die Antwort ist: $richtigeAntwort');
    }
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _flash = Colors.transparent);
    });
  }

  void _mcWaehlen(int i) {
    if (_ausgewertet) return;
    setState(() => _gewaehlt = i);
    _verarbeite(i == _fragen[_index].richtigeAntwortIndex);
  }

  void _weiter() {
    if (_index < _fragen.length - 1) {
      setState(() {
        _index++;
        _erkannt = '';
        _ausgewertet = false;
        _richtig = null;
        _gewaehlt = null;
        _multipleChoice = !_mikrofonVerfuegbar;
      });
      _frageVorlesen();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _stt.stoppeUndGibText();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frage = _fragen[_index];
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: const Text('🎤 Sprach-Quiz'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: _flash,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_index + 1) / _fragen.length,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE1BEE7),
                  valueColor:
                      const AlwaysStoppedAnimation(Color(0xFF6A1B9A)),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Frage-Karte
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TtsButton(
                                    text: frage.frage,
                                    farbe: const Color(0xFF6A1B9A),
                                  ),
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
                        const SizedBox(height: 20),

                        if (!_multipleChoice) ...[
                          // Sprach-Modus
                          SprachEingabeButton(
                            aktiv: _hoert,
                            onTippen: _mikTippen,
                          ),
                          const SizedBox(height: 16),
                          // Live-Untertitel
                          Container(
                            width: double.infinity,
                            constraints:
                                const BoxConstraints(minHeight: 60),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              _erkannt.isEmpty
                                  ? 'Deine Antwort erscheint hier …'
                                  : _erkannt,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                color: _erkannt.isEmpty
                                    ? Colors.black38
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_hoert)
                            ElevatedButton.icon(
                              onPressed: _mikTippen,
                              icon: const Icon(Icons.check),
                              label: const Text('Fertig'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A1B9A),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          if (!_ausgewertet && !_hoert)
                            TextButton.icon(
                              onPressed: () =>
                                  setState(() => _multipleChoice = true),
                              icon: const Icon(Icons.touch_app),
                              label: const Text('Zu schwer? Antippen statt sprechen'),
                            ),
                        ] else ...[
                          // Multiple-Choice-Fallback
                          if (!_mikrofonVerfuegbar)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Tippe die richtige Antwort an 👇',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ...List.generate(frage.antworten.length, (i) {
                            Color bg = Colors.white;
                            Color border = const Color(0xFFCE93D8);
                            if (_ausgewertet) {
                              if (i == frage.richtigeAntwortIndex) {
                                bg = const Color(0xFFC8E6C9);
                                border = const Color(0xFF2E7D32);
                              } else if (i == _gewaehlt) {
                                bg = const Color(0xFFFFCDD2);
                                border = const Color(0xFFC62828);
                              }
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Material(
                                color: bg,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => _mcWaehlen(i),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                        minHeight: 56),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(16),
                                      border: Border.all(
                                          color: border, width: 1.8),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      frage.antworten[i],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],

                        // Feedback
                        if (_ausgewertet) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _richtig!
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _richtig!
                                      ? 'Super gemacht! 🎉'
                                      : 'Fast! Die richtige Antwort:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: _richtig!
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFC62828),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  frage.antworten[frage.richtigeAntwortIndex],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                Text(frage.erklaerung,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 14, height: 1.4)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: _weiter,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),
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
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 24,
              colors: const [
                Color(0xFF6A1B9A),
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
}
