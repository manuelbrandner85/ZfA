import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../main.dart';
import '../widgets/cinematic_background.dart';
import '../widgets/audio_player_bar.dart';
import 'hoerbuch_uebersicht_screen.dart';
import 'sprach_quiz_screen.dart';
import 'karteikarten_screen.dart';
import 'quiz_screen.dart';
import 'fehler_suchen_screen.dart';
import 'fortschritt_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _tagesgruss() {
    final stunde = DateTime.now().hour;
    if (stunde < 11) return 'Guten Morgen!';
    if (stunde < 17) return 'Schön, dass du da bist!';
    return 'Guten Abend!';
  }

  @override
  Widget build(BuildContext context) {
    final schwach = fortschrittService.schwaechsterBereich();
    return Scaffold(
      body: CinematicBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    // Kopfzeile mit kleinem Logo
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset('assets/images/logo.jpg',
                              width: 52, height: 52, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _tagesgruss(),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'Heute lernst du:',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFFB0C4FF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Heutiger Fokus
                    FadeInDown(
                      child: _FokusKarte(
                        bereich: schwach,
                        onLernen: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const QuizScreen(),
                            ),
                          ).then((_) => setState(() {}));
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mini-Statistik (3 Werte = Chunking)
                    FadeIn(
                      child: Row(
                        children: [
                          _StatChip(
                            emoji: '⭐',
                            wert: '${fortschrittService.gesamtPunkte}',
                            label: 'Punkte',
                          ),
                          const SizedBox(width: 10),
                          _StatChip(
                            emoji: '🔥',
                            wert: '${fortschrittService.streak}',
                            label: 'Tage',
                          ),
                          const SizedBox(width: 10),
                          _StatChip(
                            emoji: '📖',
                            wert: '${fortschrittService.kapitelGehoert}',
                            label: 'Kapitel',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    const Text(
                      'Wähle deinen Weg',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 6 große Menü-Karten
                    _MenuKarte(
                      emoji: '📖',
                      titel: 'Hörbuch',
                      untertitel: 'Einfach anhören & lernen',
                      farben: const [Color(0xFF1565C0), Color(0xFF1E88E5)],
                      ziel: const HoerbuchUebersichtScreen(),
                      onReturn: () => setState(() {}),
                    ),
                    _MenuKarte(
                      emoji: '🎤',
                      titel: 'Sprach-Quiz',
                      untertitel: 'Sag die Antwort laut!',
                      farben: const [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                      ziel: const SprachQuizScreen(),
                      onReturn: () => setState(() {}),
                    ),
                    _MenuKarte(
                      emoji: '🃏',
                      titel: 'Karten',
                      untertitel: 'Umblättern & merken',
                      farben: const [Color(0xFF2E7D32), Color(0xFF43A047)],
                      ziel: const KarteikartenScreen(),
                      onReturn: () => setState(() {}),
                    ),
                    _MenuKarte(
                      emoji: '🎯',
                      titel: 'Quiz',
                      untertitel: 'Teste dein Wissen',
                      farben: const [Color(0xFFE65100), Color(0xFFF57C00)],
                      ziel: const QuizScreen(),
                      onReturn: () => setState(() {}),
                    ),
                    _MenuKarte(
                      emoji: '🔍',
                      titel: 'Fehler finden',
                      untertitel: 'Was ist hier falsch?',
                      farben: const [Color(0xFFC62828), Color(0xFFE53935)],
                      ziel: const FehlerSuchenScreen(),
                      onReturn: () => setState(() {}),
                    ),
                    _MenuKarte(
                      emoji: '📊',
                      titel: 'Mein Fortschritt',
                      untertitel: 'Deine Statistiken',
                      farben: const [Color(0xFF00695C), Color(0xFF00897B)],
                      ziel: const FortschrittScreen(),
                      onReturn: () => setState(() {}),
                    ),
                  ],
                ),
              ),
              const AudioPlayerBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FokusKarte extends StatelessWidget {
  final String bereich;
  final VoidCallback onLernen;
  const _FokusKarte({required this.bereich, required this.onLernen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFF4D03F)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🎯', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Text(
                'Heutiger Fokus',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3E2723),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Übe heute den Bereich „$bereich". Schon 5 Minuten bringen dich weiter!',
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF3E2723),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onLernen,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E2723),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Jetzt lernen →'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String emoji;
  final String wert;
  final String label;
  const _StatChip(
      {required this.emoji, required this.wert, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              wert,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFFB0C4FF)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuKarte extends StatelessWidget {
  final String emoji;
  final String titel;
  final String untertitel;
  final List<Color> farben;
  final Widget ziel;
  final VoidCallback onReturn;

  const _MenuKarte({
    required this.emoji,
    required this.titel,
    required this.untertitel,
    required this.farben,
    required this.ziel,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ziel),
            ).then((_) => onReturn());
          },
          child: Container(
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: farben,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: farben.last.withOpacity(0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 36)),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titel,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        untertitel,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white70, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
