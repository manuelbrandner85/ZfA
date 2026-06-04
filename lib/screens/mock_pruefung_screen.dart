import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../main.dart';
import '../models/quiz_frage.dart';
import '../data/quiz/alle_quiz_fragen.dart';

/// Simulierte Abschlussprüfung: 20 gemischte Fragen, am Ende eine
/// klare Bestanden/Nicht-bestanden-Auswertung in Prozent.
class MockPruefungScreen extends StatefulWidget {
  const MockPruefungScreen({super.key});

  @override
  State<MockPruefungScreen> createState() => _MockPruefungScreenState();
}

class _MockPruefungScreenState extends State<MockPruefungScreen> {
  static const int _anzahl = 20;
  int get _bestehensGrenze => einstellungenService.bestehensGrenze;

  late List<QuizFrage> _fragen;
  int _index = 0;
  int _richtig = 0;
  int? _gewaehlt;
  bool _fertig = false;
  final List<QuizFrage> _falscheFragen = [];
  late List<int> _antwortReihenfolge; // gemischte Anzeige-Reihenfolge
  late ConfettiController _confetti;

  void _mischen() {
    _antwortReihenfolge =
        List.generate(_fragen[_index].antworten.length, (i) => i)..shuffle();
  }

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    final pool = alleQuizFragen.toList()..shuffle();
    _fragen = pool.take(_anzahl).toList();
    _mischen();
  }

  void _antworten(int i) {
    if (_gewaehlt != null) return;
    final frage = _fragen[_index];
    final korrekt = i == frage.richtigeAntwortIndex;
    HapticFeedback.selectionClick();
    setState(() => _gewaehlt = i);
    if (korrekt) {
      _richtig++;
      soundService.richtig();
      fortschrittService.frageRichtigBeantwortet(frage.id,
          bereich: frage.bereich);
    } else {
      soundService.falsch();
      _falscheFragen.add(frage);
      fortschrittService.frageFalschBeantwortet(frage.id,
          bereich: frage.bereich);
    }
    // Kurz das Feedback zeigen, dann automatisch weiter
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      if (_index < _fragen.length - 1) {
        setState(() {
          _index++;
          _gewaehlt = null;
          _mischen();
        });
      } else {
        setState(() => _fertig = true);
        final prozent = (_richtig / _fragen.length * 100).round();
        if (prozent >= _bestehensGrenze) _confetti.play();
      }
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_fertig) return _ergebnis();
    final frage = _fragen[_index];
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('📝 Prüfungssimulation'),
        backgroundColor: const Color(0xFF283593),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_index + 1) / _fragen.length,
            minHeight: 8,
            backgroundColor: const Color(0xFFC5CAE9),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF283593)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Frage ${_index + 1} von ${_fragen.length}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text('✅ $_richtig',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32))),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Text(
                      frage.frage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(frage.antworten.length, (pos) {
                  final i = _antwortReihenfolge[pos];
                  Color bg = Colors.white;
                  Color border = const Color(0xFFE0E0E0);
                  if (_gewaehlt != null) {
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
                        onTap: () => _antworten(i),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 56),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: border, width: 1.8),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            frage.antworten[i],
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ergebnis() {
    final prozent = (_richtig / _fragen.length * 100).round();
    final bestanden = prozent >= _bestehensGrenze;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('📝 Ergebnis'),
        backgroundColor: const Color(0xFF283593),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 12),
              Center(
                child: Text(bestanden ? '🎉' : '💪',
                    style: const TextStyle(fontSize: 80)),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  bestanden ? 'Bestanden!' : 'Fast geschafft!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: bestanden
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFEF6C00),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  '$_richtig von ${_fragen.length} richtig  ·  $prozent %',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bestanden
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  bestanden
                      ? 'Stark! Du liegst über der Bestehensgrenze von $_bestehensGrenze %. Weiter so – wiederhole die wenigen Fehler, dann sitzt es.'
                      : 'Du brauchst $_bestehensGrenze % zum Bestehen. Übe gezielt die Themen unten – du schaffst das beim nächsten Mal!',
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),
              if (_falscheFragen.isNotEmpty) ...[
                const SizedBox(height: 22),
                const Text('Das solltest du nochmal anschauen:',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                ..._falscheFragen.map((f) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFFCDD2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.frage,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                          const SizedBox(height: 6),
                          Text(
                            '✅ ${f.antworten[f.richtigeAntwortIndex]}',
                            style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    final pool = alleQuizFragen.toList()..shuffle();
                    _fragen = pool.take(_anzahl).toList();
                    _index = 0;
                    _richtig = 0;
                    _gewaehlt = null;
                    _fertig = false;
                    _falscheFragen.clear();
                    _mischen();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF283593),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Neue Prüfung 🔄'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52)),
                child: const Text('Zurück zum Start'),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              colors: const [
                Color(0xFF283593),
                Color(0xFFD4AF37),
                Color(0xFF2E7D32),
                Color(0xFF1565C0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
