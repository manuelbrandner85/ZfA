import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../main.dart';
import '../widgets/cinematic_background.dart';
import '../widgets/audio_player_bar.dart';
import '../data/quiz/hoerbuch_texte.dart';
import '../models/hoerbuch_kapitel.dart';
import 'hoerbuch_screen.dart';

class HoerbuchUebersichtScreen extends StatefulWidget {
  const HoerbuchUebersichtScreen({super.key});

  @override
  State<HoerbuchUebersichtScreen> createState() =>
      _HoerbuchUebersichtScreenState();
}

class _HoerbuchUebersichtScreenState extends State<HoerbuchUebersichtScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: CinematicBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      '📖 Hörbuch',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Lehn dich zurück und hör einfach zu. 5 Minuten reichen!',
                    style: TextStyle(color: Color(0xFFB0C4FF), fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: alleHoerbuchKapitel.length,
                  itemBuilder: (context, i) {
                    final k = alleHoerbuchKapitel[i];
                    final fortschritt =
                        fortschrittService.hoerbuchFortschritt[k.id] ?? 0;
                    final prozent = fortschritt / k.anzahlSaetze;
                    return FadeInUp(
                      delay: Duration(milliseconds: 40 * i),
                      child: _KapitelKachel(
                        kapitel: k,
                        nummer: i + 1,
                        fortschritt: prozent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HoerbuchScreen(kapitel: k),
                            ),
                          ).then((_) => setState(() {}));
                        },
                      ),
                    );
                  },
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

class _KapitelKachel extends StatelessWidget {
  final HoerbuchKapitel kapitel;
  final int nummer;
  final double fortschritt;
  final VoidCallback onTap;

  const _KapitelKachel({
    required this.kapitel,
    required this.nummer,
    required this.fortschritt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kapitel.farbe, kapitel.farbe.withOpacity(0.6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Text(kapitel.emoji,
                      style: const TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$nummer. ${kapitel.titel}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${kapitel.minutenGeschaetzt} Min · ${kapitel.anzahlSaetze} Abschnitte',
                        style: const TextStyle(
                          color: Color(0xFFB0C4FF),
                          fontSize: 13,
                        ),
                      ),
                      if (fortschritt > 0) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: fortschritt,
                            minHeight: 5,
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation(kapitel.farbe),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.play_circle_fill,
                    color: Colors.white70, size: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
