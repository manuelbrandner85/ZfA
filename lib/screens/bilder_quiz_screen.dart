import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../main.dart';
import '../widgets/instrument_zeichnungen.dart';
import '../widgets/tts_button.dart';

class _Instrument {
  final String id;
  final String name;
  final String hinweis;
  const _Instrument(this.id, this.name, this.hinweis);
}

const List<_Instrument> _instrumente = [
  _Instrument('mundspiegel', 'Mundspiegel',
      'Verschafft Sicht, hält die Wange ab und lenkt Licht.'),
  _Instrument('sonde', 'Sonde',
      'Zum Ertasten von Karies, Rändern und Belägen.'),
  _Instrument('pinzette', 'Pinzette',
      'Zum Greifen und Transportieren kleiner Teile.'),
  _Instrument('spritze', 'Karpulenspritze',
      'Für die örtliche Betäubung mit Karpule und Kanüle.'),
  _Instrument('hebel', 'Hebel (Elevator)',
      'Löst den Zahn vor der Extraktion aus dem Knochen.'),
  _Instrument('zange', 'Extraktionszange',
      'Zum Ziehen des Zahns – für jeden Zahn eine Form.'),
  _Instrument('scaler', 'Scaler',
      'Zum Entfernen von Zahnstein und harten Belägen.'),
  _Instrument('sauger', 'Sauger',
      'Saugt Speichel, Blut und Kühlwasser ab.'),
];

class BilderQuizScreen extends StatefulWidget {
  const BilderQuizScreen({super.key});

  @override
  State<BilderQuizScreen> createState() => _BilderQuizScreenState();
}

class _BilderQuizScreenState extends State<BilderQuizScreen> {
  final _rng = Random();
  late List<_Instrument> _reihenfolge;
  int _index = 0;
  late List<String> _optionen;
  String? _gewaehlt;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 1));
    _reihenfolge = _instrumente.toList()..shuffle(_rng);
    _optionenBauen();
  }

  void _optionenBauen() {
    final richtig = _reihenfolge[_index];
    final falsche = _instrumente.where((i) => i.id != richtig.id).toList()
      ..shuffle(_rng);
    _optionen = [richtig.name, ...falsche.take(3).map((e) => e.name)]
      ..shuffle(_rng);
    _gewaehlt = null;
  }

  void _waehlen(String name) {
    if (_gewaehlt != null) return;
    final richtig = _reihenfolge[_index];
    final korrekt = name == richtig.name;
    setState(() => _gewaehlt = name);
    if (korrekt) {
      HapticFeedback.lightImpact();
      soundService.richtig();
      _confetti.play();
      fortschrittService.frageRichtigBeantwortet('bild_${richtig.id}',
          bereich: 'Behandlungsassistenz');
      ttsService.sprechen('Richtig! Das ist ${richtig.name}.');
    } else {
      HapticFeedback.heavyImpact();
      soundService.falsch();
      fortschrittService.frageFalschBeantwortet('bild_${richtig.id}',
          bereich: 'Behandlungsassistenz');
      ttsService.sprechen('Das ist ${richtig.name}.');
    }
  }

  void _weiter() {
    if (_index < _reihenfolge.length - 1) {
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
    final aktuell = _reihenfolge[_index];
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
      appBar: AppBar(
        title: const Text('🖼️ Instrumente erkennen'),
        backgroundColor: const Color(0xFF00838F),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              LinearProgressIndicator(
                value: (_index + 1) / _reihenfolge.length,
                minHeight: 8,
                backgroundColor: const Color(0xFFB2EBF2),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF00838F)),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    const Center(
                      child: Text('Welches Instrument ist das?',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(height: 14),
                    // Instrument auf „Studio"-Hintergrund
                    Center(
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          gradient: const RadialGradient(
                            center: Alignment(-0.2, -0.3),
                            radius: 0.95,
                            colors: [
                              Color(0xFFFFFFFF),
                              Color(0xFFEDF2F5),
                              Color(0xFFD7E0E6),
                            ],
                            stops: [0.0, 0.6, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 22,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                              color: Colors.white.withOpacity(0.8), width: 1),
                        ),
                        child: InstrumentZeichnung(id: aktuell.id, groesse: 240),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Antwortoptionen
                    ..._optionen.map((name) {
                      Color bg = Colors.white;
                      Color border = const Color(0xFFB0BEC5);
                      if (_gewaehlt != null) {
                        if (name == aktuell.name) {
                          bg = const Color(0xFFC8E6C9);
                          border = const Color(0xFF2E7D32);
                        } else if (name == _gewaehlt) {
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
                            onTap: () => _waehlen(name),
                            child: Container(
                              constraints:
                                  const BoxConstraints(minHeight: 56),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: border, width: 1.8),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(name,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      );
                    }),
                    if (_gewaehlt != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('${aktuell.name}: ${aktuell.hinweis}',
                                  style: const TextStyle(
                                      fontSize: 15, height: 1.4)),
                            ),
                            TtsButton(
                                text: '${aktuell.name}. ${aktuell.hinweis}',
                                farbe: const Color(0xFF00838F)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _weiter,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00838F),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(_index < _reihenfolge.length - 1
                            ? 'Weiter →'
                            : 'Fertig 🎉'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 22,
              colors: const [
                Color(0xFF00838F),
                Color(0xFFD4AF37),
                Color(0xFF2E7D32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
