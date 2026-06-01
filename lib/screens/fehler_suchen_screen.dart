import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../main.dart';

class _Punkt {
  final String text;
  final bool istFehler;
  final String erklaerung;
  const _Punkt(this.text, this.istFehler, this.erklaerung);
}

class _Aufgabe {
  final String titel;
  final String emoji;
  final List<_Punkt> punkte;
  const _Aufgabe(this.titel, this.emoji, this.punkte);
}

const List<_Aufgabe> _aufgaben = [
  _Aufgabe('Wo ist der Fehler beim Tray-Aufbau?', '🦷', [
    _Punkt('Spritze mit Betäubungsmittel liegt bereit', false,
        'Richtig – gehört zum Anästhesie-Tray.'),
    _Punkt('Es fehlt die passende Kanüle', true,
        'Fehler! Ohne Kanüle kann nicht injiziert werden.'),
    _Punkt('Tupfer und Watterollen sind vorhanden', false,
        'Richtig – wichtig zum Trocknen und Abtupfen.'),
    _Punkt('Der Pinsel zum Auftragen des Oberflächengels fehlt', true,
        'Fehler! Ohne Applikator keine Oberflächenanästhesie.'),
  ]),
  _Aufgabe('Hygiene-Reihenfolge falsch?', '🧤', [
    _Punkt('Flächen werden desinfiziert', false,
        'Richtig – gehört an den Anfang.'),
    _Punkt('Zuerst wird das Zimmer gelüftet', true,
        'Fehler! Lüften kommt ans ENDE, nicht an den Anfang.'),
    _Punkt('Hände werden 30 Sekunden desinfiziert', false,
        'Richtig – Mindestzeit eingehalten.'),
    _Punkt('Handschuhe nach der Händedesinfektion anziehen', false,
        'Richtig – erst desinfizieren, dann Handschuhe.'),
  ]),
  _Aufgabe('PSA unvollständig?', '🥽', [
    _Punkt('Handschuhe werden getragen', false, 'Richtig.'),
    _Punkt('Mund-Nasen-Schutz sitzt', false, 'Richtig.'),
    _Punkt('Die Schutzbrille fehlt', true,
        'Fehler! Die Schutzbrille schützt vor Spritzern und wird oft vergessen.'),
    _Punkt('Schutzkittel ist angelegt', false, 'Richtig.'),
  ]),
  _Aufgabe('Anästhesie falsch gewählt?', '💉', [
    _Punkt('Für die Leitungsanästhesie wird die kurze Kanüle genommen', true,
        'Fehler! Für die Leitungsanästhesie braucht man die LANGE Kanüle.'),
    _Punkt('Articain wird als Wirkstoff verwendet', false,
        'Richtig – gängiges Lokalanästhetikum.'),
    _Punkt('Im Unterkiefer wird eine Leitungsanästhesie gesetzt', false,
        'Richtig – wegen des dichten Knochens.'),
    _Punkt('Adrenalinzusatz verlängert die Wirkung', false,
        'Richtig – verengt die Gefäße.'),
  ]),
  _Aufgabe('Sauger falsch gehalten?', '💧', [
    _Punkt('Der Sauger hält das Feld trocken', false, 'Richtig.'),
    _Punkt('Der Sauger wird direkt auf die Schleimhaut gepresst', true,
        'Fehler! Zu viel Druck saugt die Schleimhaut an und verletzt sie.'),
    _Punkt('Die Sicht des Behandlers bleibt frei', false, 'Richtig.'),
    _Punkt('Beim Bohren wird zusätzlich mit Wasser gekühlt', false,
        'Richtig – schützt den Nerv vor Hitze.'),
  ]),
  _Aufgabe('Dokumentation unvollständig?', '📋', [
    _Punkt('Die durchgeführte Behandlung ist notiert', false,
        'Richtig – das erste W: Was.'),
    _Punkt('Das verwendete Material ist vermerkt', false,
        'Richtig – das zweite W: Womit.'),
    _Punkt('Die Chargennummern fehlen', true,
        'Fehler! Chargennummern sind Pflicht für die Rückverfolgung.'),
    _Punkt('Der Behandler ist angegeben', false,
        'Richtig – das vierte W: Wer.'),
  ]),
];

class FehlerSuchenScreen extends StatefulWidget {
  const FehlerSuchenScreen({super.key});

  @override
  State<FehlerSuchenScreen> createState() => _FehlerSuchenScreenState();
}

class _FehlerSuchenScreenState extends State<FehlerSuchenScreen> {
  int _aufgabeIndex = 0;
  final Set<int> _markiert = {};
  bool _ausgewertet = false;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 1));
  }

  void _auswerten() {
    setState(() => _ausgewertet = true);
    final aufgabe = _aufgaben[_aufgabeIndex];
    bool allesRichtig = true;
    for (int i = 0; i < aufgabe.punkte.length; i++) {
      final sollMarkiert = aufgabe.punkte[i].istFehler;
      final istMarkiert = _markiert.contains(i);
      if (sollMarkiert != istMarkiert) allesRichtig = false;
    }
    if (allesRichtig) {
      _confetti.play();
      fortschrittService.frageRichtigBeantwortet(
          'fehler_$_aufgabeIndex',
          bereich: 'Hygiene');
      ttsService.sprechen('Super gemacht! Alles richtig erkannt!');
    } else {
      ttsService.sprechen('Schau dir die Erklärungen an.');
    }
  }

  void _weiter() {
    if (_aufgabeIndex < _aufgaben.length - 1) {
      setState(() {
        _aufgabeIndex++;
        _markiert.clear();
        _ausgewertet = false;
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
    final aufgabe = _aufgaben[_aufgabeIndex];
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text('🔍 Fehler finden'),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              LinearProgressIndicator(
                value: (_aufgabeIndex + 1) / _aufgaben.length,
                minHeight: 8,
                backgroundColor: const Color(0xFFFFCCBC),
                valueColor:
                    const AlwaysStoppedAnimation(Color(0xFFC62828)),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    // Aufgaben-Karte
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF6C00), Color(0xFFF57C00)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(aufgabe.emoji,
                              style: const TextStyle(fontSize: 36)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  aufgabe.titel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '👆 Tippe auf alle FALSCHEN Punkte!',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Punkte
                    ...List.generate(aufgabe.punkte.length, (i) {
                      final punkt = aufgabe.punkte[i];
                      final markiert = _markiert.contains(i);
                      Color bg = Colors.white;
                      Color border = const Color(0xFFE0E0E0);
                      if (!_ausgewertet && markiert) {
                        bg = const Color(0xFFFFE0B2);
                        border = const Color(0xFFEF6C00);
                      }
                      if (_ausgewertet) {
                        if (punkt.istFehler) {
                          bg = const Color(0xFFFFCDD2);
                          border = const Color(0xFFC62828);
                        } else if (markiert) {
                          bg = const Color(0xFFFFF9C4);
                          border = const Color(0xFFF9A825);
                        } else {
                          bg = const Color(0xFFC8E6C9);
                          border = const Color(0xFF2E7D32);
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: bg,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _ausgewertet
                                ? null
                                : () {
                                    setState(() {
                                      if (markiert) {
                                        _markiert.remove(i);
                                      } else {
                                        _markiert.add(i);
                                      }
                                    });
                                  },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: border, width: 1.8),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _ausgewertet
                                            ? (punkt.istFehler
                                                ? Icons.error
                                                : Icons.check_circle)
                                            : (markiert
                                                ? Icons.radio_button_checked
                                                : Icons
                                                    .radio_button_unchecked),
                                        color: border,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          punkt.text,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_ausgewertet) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      punkt.erklaerung,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black.withOpacity(0.7),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    if (!_ausgewertet)
                      ElevatedButton(
                        onPressed:
                            _markiert.isEmpty ? null : _auswerten,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC62828),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Auswerten 🔍'),
                      )
                    else
                      ElevatedButton(
                        onPressed: _weiter,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC62828),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                            _aufgabeIndex < _aufgaben.length - 1
                                ? 'Nächste Aufgabe →'
                                : 'Fertig 🎉'),
                      ),
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
              numberOfParticles: 24,
              colors: const [
                Color(0xFFC62828),
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
