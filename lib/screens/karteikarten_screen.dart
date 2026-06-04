import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:confetti/confetti.dart';
import '../main.dart';
import '../models/lernkarte.dart';
import '../data/lernkarten_daten.dart';
import '../widgets/tts_button.dart';
import '../widgets/fav_stern.dart';

class KarteikartenScreen extends StatefulWidget {
  const KarteikartenScreen({super.key});

  @override
  State<KarteikartenScreen> createState() => _KarteikartenScreenState();
}

class _KarteikartenScreenState extends State<KarteikartenScreen> {
  final List<Lernkarte> _alle = alleLernkarten();
  late List<Lernkarte> _karten;
  int _index = 0;
  String _filter = 'Alle';
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 1));
    _filterAnwenden('Alle');
  }

  void _filterAnwenden(String filter) {
    setState(() {
      _filter = filter;
      _index = 0;
      // Leitner-Box aus Fortschritt übernehmen
      for (final k in _alle) {
        k.leitnerBox = fortschrittService.leitnerBoxen[k.id] ?? 1;
      }
      switch (filter) {
        case 'Heute fällig':
          final faellig = fortschrittService
              .fragenFuerHeute(_alle.map((k) => k.id).toList())
              .toSet();
          _karten = _alle.where((k) => faellig.contains(k.id)).toList();
          break;
        case 'Schwach':
          _karten = _alle.where((k) => k.leitnerBox <= 2).toList();
          break;
        default:
          _karten = _alle.toList();
      }
      if (_karten.isEmpty) _karten = _alle.toList();
    });
  }

  void _bewerten(bool gewusst) {
    final karte = _karten[_index];
    if (gewusst) {
      fortschrittService.frageRichtigBeantwortet(karte.id,
          bereich: karte.bereich);
    } else {
      fortschrittService.frageFalschBeantwortet(karte.id,
          bereich: karte.bereich);
    }
    if (_index < _karten.length - 1) {
      setState(() => _index++);
    } else {
      _confetti.play();
      _zeigeFertig();
    }
  }

  void _zeigeFertig() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 8),
              const Text('Stapel geschafft!',
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Du hast ${_karten.length} Karten durchgearbeitet. 👏',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _index = 0);
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
    final karte = _karten[_index];
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('🃏 Karteikarten'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Filter-Chips
              SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: ['Alle', 'Heute fällig', 'Schwach'].map((f) {
                    final aktiv = _filter == f;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 8),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: aktiv,
                        onSelected: (_) => _filterAnwenden(f),
                        selectedColor: const Color(0xFF2E7D32),
                        labelStyle: TextStyle(
                          color: aktiv ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Fortschritt
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Karte ${_index + 1} von ${_karten.length}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                    Text('Box ${karte.leitnerBox}/5',
                        style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // Karte mit Swipe
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Dismissible(
                    key: ValueKey('${karte.id}_$_index'),
                    onDismissed: (richtung) {
                      _bewerten(richtung == DismissDirection.startToEnd);
                    },
                    background: const _SwipeHinweis(
                      ausrichtung: Alignment.centerLeft,
                      farbe: Color(0xFF2E7D32),
                      icon: Icons.check_circle,
                      text: 'Ich kann das!',
                    ),
                    secondaryBackground: const _SwipeHinweis(
                      ausrichtung: Alignment.centerRight,
                      farbe: Color(0xFFEF6C00),
                      icon: Icons.refresh,
                      text: 'Nochmal',
                    ),
                    child: FlipCard(
                      direction: FlipDirection.HORIZONTAL,
                      front: _Vorderseite(karte: karte),
                      back: _Rueckseite(karte: karte),
                    ),
                  ),
                ),
              ),
              // Buttons als Alternative zum Swipe
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _bewerten(false),
                        icon: const Icon(Icons.refresh,
                            color: Color(0xFFEF6C00)),
                        label: const Text('Nochmal',
                            style: TextStyle(color: Color(0xFFEF6C00))),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          side: const BorderSide(
                              color: Color(0xFFEF6C00), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _bewerten(true),
                        icon: const Icon(Icons.check),
                        label: const Text('Kann ich!'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 52),
                        ),
                      ),
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
                Color(0xFF2E7D32),
                Color(0xFFD4AF37),
                Color(0xFF1565C0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeHinweis extends StatelessWidget {
  final Alignment ausrichtung;
  final Color farbe;
  final IconData icon;
  final String text;
  const _SwipeHinweis({
    required this.ausrichtung,
    required this.farbe,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: farbe.withOpacity(0.15),
        borderRadius: BorderRadius.circular(28),
      ),
      alignment: ausrichtung,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: farbe, size: 44),
          Text(text,
              style: TextStyle(
                  color: farbe, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

class _Vorderseite extends StatelessWidget {
  final Lernkarte karte;
  const _Vorderseite({required this.karte});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(karte.emoji, style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 24),
              Text(
                karte.vorderseite,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tippen zum Umdrehen 👆',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Rueckseite extends StatelessWidget {
  final Lernkarte karte;
  const _Rueckseite({required this.karte});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(karte.emoji, style: const TextStyle(fontSize: 32)),
                Row(children: [
                  FavStern(id: karte.id, groesse: 22),
                  TtsButton(
                    text: '${karte.einfachVersion}. ${karte.rueckseite}',
                    farbe: const Color(0xFF1565C0),
                  ),
                ]),
              ],
            ),
            const SizedBox(height: 8),
            // Einfache Version
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡 Einfach',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1565C0))),
                  const SizedBox(height: 6),
                  Text(karte.einfachVersion,
                      style:
                          const TextStyle(fontSize: 17, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Prüfungsantwort
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🎓 Prüfungsantwort',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF455A64))),
                  const SizedBox(height: 6),
                  Text(karte.rueckseite,
                      style:
                          const TextStyle(fontSize: 16, height: 1.45)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
