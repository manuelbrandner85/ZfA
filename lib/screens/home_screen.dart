import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'muendliche_pruefung_screen.dart';
import 'mock_pruefung_screen.dart';
import 'bilder_quiz_screen.dart';

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

                    // HERO: Heute lernen + Tagesziel-Ring
                    FadeInDown(
                      child: _HeuteLernenKarte(
                        bereich: schwach,
                        onLernen: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const QuizScreen(),
                            ),
                          ).then((_) => setState(() {}));
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Prüfungs-Countdown
                    _PruefungsKarte(onAenderung: () => setState(() {})),
                    const SizedBox(height: 12),

                    // Tägliche Erinnerung
                    _ErinnerungsZeile(onAenderung: () => setState(() {})),
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

                    // Große Menü-Karten
                    _MenuKarte(
                      emoji: '🎓',
                      titel: 'Mündliche Prüfung',
                      untertitel: 'Fachgespräch laut üben',
                      farben: const [Color(0xFF4527A0), Color(0xFF7E57C2)],
                      ziel: const MuendlichePruefungScreen(),
                      onReturn: () => setState(() {}),
                    ),
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
                      emoji: '📝',
                      titel: 'Prüfung simulieren',
                      untertitel: 'Echte Prüfung mit Note',
                      farben: const [Color(0xFF283593), Color(0xFF3949AB)],
                      ziel: const MockPruefungScreen(),
                      onReturn: () => setState(() {}),
                    ),
                    _MenuKarte(
                      emoji: '🖼️',
                      titel: 'Instrumente erkennen',
                      untertitel: 'Welches Instrument ist das?',
                      farben: const [Color(0xFF00838F), Color(0xFF00ACC1)],
                      ziel: const BilderQuizScreen(),
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

// Hero-Karte: ein großer Knopf + Tagesziel-Ring. Nimmt dem Nutzer jede
// Entscheidung ab – einfach starten.
class _HeuteLernenKarte extends StatelessWidget {
  final String bereich;
  final VoidCallback onLernen;
  const _HeuteLernenKarte(
      {required this.bereich, required this.onLernen});

  @override
  Widget build(BuildContext context) {
    final fs = fortschrittService;
    final geschafft = fs.aufgabenHeute.clamp(0, fs.tagesziel);
    final fertig = fs.tageszielErreicht;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFF4D03F)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Tagesziel-Ring
              SizedBox(
                width: 74,
                height: 74,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 74,
                      height: 74,
                      child: CircularProgressIndicator(
                        value: fs.tageszielFortschritt,
                        strokeWidth: 8,
                        backgroundColor: const Color(0x33000000),
                        valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF3E2723)),
                      ),
                    ),
                    Text(
                      fertig ? '✓' : '$geschafft/${fs.tagesziel}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fertig
                          ? 'Tagesziel geschafft! 🎉'
                          : 'Heute lernen',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fertig
                          ? 'Stark dran geblieben – noch eine Runde?'
                          : 'Schwerpunkt heute: $bereich',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5D4037),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onLernen,
              icon: const Icon(Icons.play_arrow_rounded, size: 26),
              label: const Text('Jetzt 5 Minuten lernen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E2723),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Prüfungs-Countdown. Tippen setzt/ändert den Termin.
class _PruefungsKarte extends StatelessWidget {
  final VoidCallback onAenderung;
  const _PruefungsKarte({required this.onAenderung});

  Future<void> _datumWaehlen(BuildContext context) async {
    final jetzt = DateTime.now();
    final aktuell = fortschrittService.pruefungsDatum != null
        ? DateTime.tryParse(fortschrittService.pruefungsDatum!)
        : null;
    final gewaehlt = await showDatePicker(
      context: context,
      initialDate: aktuell ?? jetzt.add(const Duration(days: 30)),
      firstDate: jetzt,
      lastDate: jetzt.add(const Duration(days: 730)),
      helpText: 'Wann ist deine Prüfung?',
    );
    if (gewaehlt != null) {
      await fortschrittService.pruefungsDatumSetzen(gewaehlt);
      onAenderung();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tage = fortschrittService.tageBisPruefung();
    final gesetzt = tage != null;
    return Material(
      color: Colors.white.withOpacity(0.10),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _datumWaehlen(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              const Text('🗓️', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 14),
              Expanded(
                child: gesetzt
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tage > 0
                                ? 'Noch $tage Tage bis zur Prüfung'
                                : tage == 0
                                    ? 'Heute ist deine Prüfung – viel Erfolg! 🍀'
                                    : 'Prüfung geschafft? Termin anpassen',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const Text('Tippen zum Ändern',
                              style: TextStyle(
                                  color: Color(0xFFB0C4FF), fontSize: 12)),
                        ],
                      )
                    : const Text(
                        'Prüfungstermin festlegen',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}

// Schalter für die tägliche Lern-Erinnerung.
class _ErinnerungsZeile extends StatefulWidget {
  final VoidCallback onAenderung;
  const _ErinnerungsZeile({required this.onAenderung});

  @override
  State<_ErinnerungsZeile> createState() => _ErinnerungsZeileState();
}

class _ErinnerungsZeileState extends State<_ErinnerungsZeile> {
  bool _busy = false;

  Future<void> _umschalten(bool wert) async {
    setState(() => _busy = true);
    final jetztAktiv = await notificationService.umschalten(wert);
    if (!mounted) return;
    setState(() => _busy = false);
    if (wert && !jetztAktiv) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Benachrichtigungen sind blockiert. Bitte in den Einstellungen erlauben.'),
      ));
    }
    widget.onAenderung();
  }

  @override
  Widget build(BuildContext context) {
    final s = notificationService;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Text('🔔', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tägliche Erinnerung',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  s.aktiv
                      ? 'Jeden Tag um ${s.stunde.toString().padLeft(2, '0')}:${s.minute.toString().padLeft(2, '0')} Uhr'
                      : 'Aus – tippe zum Aktivieren',
                  style: const TextStyle(
                      color: Color(0xFFB0C4FF), fontSize: 12),
                ),
              ],
            ),
          ),
          _busy
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Switch(
                  value: s.aktiv,
                  activeColor: const Color(0xFFF4D03F),
                  onChanged: _umschalten,
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
            HapticFeedback.lightImpact();
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
