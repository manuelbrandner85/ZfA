import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../main.dart';
import '../theme/zfa_theme.dart';
import '../widgets/audio_player_bar.dart';
import '../widgets/lern_buddy.dart';
import 'hoerbuch_uebersicht_screen.dart';
import 'sprach_quiz_screen.dart';
import 'karteikarten_screen.dart';
import 'quiz_screen.dart';
import 'fehler_suchen_screen.dart';
import 'fortschritt_screen.dart';
import 'muendliche_pruefung_screen.dart';
import 'mock_pruefung_screen.dart';
import 'bilder_quiz_screen.dart';
import 'cockpit_screen.dart';
import 'lernpfad_screen.dart';
import 'erfolge_screen.dart';
import 'ablaeufe_screen.dart';
import 'live_fachgespraech_screen.dart';
import 'eigene_karten_screen.dart';
import 'glossar_screen.dart';
import 'pruefungsmodus_screen.dart';
import 'reihenfolge_screen.dart';
import 'ablauf_erklaeren_screen.dart';
import '../data/behandlungsablaeufe_daten.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _tagesgruss() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Guten Morgen';
    if (h < 17) return 'Willkommen zurück';
    return 'Guten Abend';
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final schwach = fortschrittService.schwaechsterBereich();
    final tc = Theme.of(context).colorScheme.onSurface;
    final dunkel = Theme.of(context).brightness == Brightness.dark;
    final zufallsAblauf = alleBehandlungsablaeufe[
        math.Random().nextInt(alleBehandlungsablaeufe.length)];

    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                  children: [
                    // Kopfzeile
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset('assets/images/logo.jpg',
                              width: 48, height: 48, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_tagesgruss(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge),
                              Text('Bereit für deine Prüfung?',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: tc.withOpacity(0.6))),
                            ],
                          ),
                        ),
                        _IconPille(
                          icon: soundService.aktiv
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          onTap: () async {
                            await soundService.umschalten(!soundService.aktiv);
                            if (soundService.aktiv) soundService.tap();
                            _refresh();
                          },
                        ),
                        const SizedBox(width: 8),
                        _IconPille(
                          icon: dunkel
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          onTap: () => themeController.umschalten(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Lern-Buddy mit Tipp
                    _BuddyTipp(),
                    const SizedBox(height: 16),

                    // HERO
                    FadeInDown(
                      child: _HeroHeute(
                        bereich: schwach,
                        onLernen: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const QuizScreen()),
                          ).then((_) => _refresh());
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Cockpit-Teaser (Bestehens-Chance)
                    FadeIn(child: _CockpitTeaser(onReturn: _refresh)),
                    const SizedBox(height: 14),

                    // Prüfungs-Countdown + Statistik nebeneinander
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _PruefungsKachel(onAenderung: _refresh),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _StreakKachel(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ErinnerungsZeile(onAenderung: _refresh),
                    const SizedBox(height: 22),

                    // Behandlungsabläufe – prominent (Kern der Prüfung)
                    GlassCard(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AblaeufeScreen()),
                        ).then((_) => _refresh());
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: ZfaTheme.blauGrad,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: const Text('🦷',
                                style: TextStyle(fontSize: 30)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Behandlungsabläufe',
                                    style: TextStyle(
                                        color: tc,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800)),
                                Text(
                                    '18 echte Abläufe Schritt für Schritt – fürs Fachgespräch',
                                    style: TextStyle(
                                        color: tc.withOpacity(0.6),
                                        fontSize: 12.5)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: tc.withOpacity(0.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Rails (Netflix-Stil)
                    _Rail(
                      titel: 'Dein Weg',
                      poster: [
                        _Poster(
                            '🗺️',
                            'Lernpfad',
                            'Schritt für Schritt',
                            ZfaTheme.violettGrad,
                            const LernpfadScreen(),
                            _refresh),
                        _Poster(
                            '🏅',
                            'Erfolge & Liga',
                            'Abzeichen & XP',
                            ZfaTheme.goldGrad,
                            const ErfolgeScreen(),
                            _refresh),
                        _Poster(
                            '📈',
                            'Cockpit',
                            'Bestehens-Chance',
                            const LinearGradient(colors: [
                              Color(0xFF0D9488),
                              Color(0xFF115E59)
                            ]),
                            const CockpitScreen(),
                            _refresh),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _Rail(
                      titel: 'Üben',
                      poster: [
                        _Poster('🎯', 'Quiz', 'Wissen testen',
                            ZfaTheme.blauGrad, const QuizScreen(), _refresh),
                        _Poster(
                            '🔀',
                            'Reihenfolge',
                            'Schritte ordnen',
                            const LinearGradient(colors: [
                              Color(0xFF8B5CF6),
                              Color(0xFF6D28D9)
                            ]),
                            const ReihenfolgeScreen(),
                            _refresh),
                        _Poster(
                            '🎤',
                            'Sprach-Quiz',
                            'Laut antworten',
                            ZfaTheme.violettGrad,
                            const SprachQuizScreen(),
                            _refresh),
                        _Poster(
                            '🃏',
                            'Karten',
                            'Umblättern',
                            const LinearGradient(colors: [
                              Color(0xFF22C55E),
                              Color(0xFF15803D)
                            ]),
                            const KarteikartenScreen(),
                            _refresh),
                        _Poster(
                            '🖼️',
                            'Instrumente',
                            'Erkennen',
                            const LinearGradient(colors: [
                              Color(0xFF06B6D4),
                              Color(0xFF0E7490)
                            ]),
                            const BilderQuizScreen(),
                            _refresh),
                        _Poster(
                            '🔍',
                            'Fehler finden',
                            'Was ist falsch?',
                            const LinearGradient(colors: [
                              Color(0xFFEF4444),
                              Color(0xFFB91C1C)
                            ]),
                            const FehlerSuchenScreen(),
                            _refresh),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _Rail(
                      titel: 'Prüfung',
                      poster: [
                        _Poster(
                            '🏁',
                            'Prüfungsmodus',
                            'Echt, mit Zeit & Note',
                            const LinearGradient(colors: [
                              Color(0xFF1D4ED8),
                              Color(0xFF0B2A6B)
                            ]),
                            const PruefungsmodusScreen(),
                            _refresh),
                        _Poster(
                            '🗣️',
                            'Ablauf erklären',
                            'Laut wie im Fachgespräch',
                            const LinearGradient(colors: [
                              Color(0xFF0EA5E9),
                              Color(0xFF1E3A8A)
                            ]),
                            AblaufErklaerenScreen(ablauf: zufallsAblauf),
                            _refresh),
                        _Poster(
                            '🎙️',
                            'Live-Fachgespräch',
                            'Sprechen mit Note',
                            const LinearGradient(colors: [
                              Color(0xFF8B5CF6),
                              Color(0xFF5B21B6)
                            ]),
                            const LiveFachgespraechScreen(),
                            _refresh),
                        _Poster(
                            '🎓',
                            'Mündliche Prüfung',
                            'Fachgespräch üben',
                            const LinearGradient(colors: [
                              Color(0xFF7C5CFF),
                              Color(0xFF4527A0)
                            ]),
                            const MuendlichePruefungScreen(),
                            _refresh),
                        _Poster(
                            '📝',
                            'Simulation',
                            'Prüfung mit Note',
                            const LinearGradient(colors: [
                              Color(0xFF3949AB),
                              Color(0xFF1A237E)
                            ]),
                            const MockPruefungScreen(),
                            _refresh),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _Rail(
                      titel: 'Werkzeuge',
                      poster: [
                        _Poster(
                            '📚',
                            'Glossar',
                            'Begriffe suchen',
                            const LinearGradient(colors: [
                              Color(0xFF0EA5E9),
                              Color(0xFF0369A1)
                            ]),
                            const GlossarScreen(),
                            _refresh),
                        _Poster(
                            '⭐',
                            'Meine Karten',
                            'Selbst anlegen',
                            ZfaTheme.goldGrad,
                            const EigeneKartenScreen(),
                            _refresh),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _Rail(
                      titel: 'Anhören & Auswerten',
                      poster: [
                        _Poster(
                            '📖',
                            'Hörbuch',
                            '10 Kapitel',
                            const LinearGradient(colors: [
                              Color(0xFF2563EB),
                              Color(0xFF1E3A8A)
                            ]),
                            const HoerbuchUebersichtScreen(),
                            _refresh),
                        _Poster(
                            '📊',
                            'Fortschritt',
                            'Statistiken',
                            const LinearGradient(colors: [
                              Color(0xFF0D9488),
                              Color(0xFF115E59)
                            ]),
                            const FortschrittScreen(),
                            _refresh),
                      ],
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

// ---------------- HERO ----------------
class _HeroHeute extends StatelessWidget {
  final String bereich;
  final VoidCallback onLernen;
  const _HeroHeute({required this.bereich, required this.onLernen});

  @override
  Widget build(BuildContext context) {
    final fs = fortschrittService;
    final geschafft = fs.aufgabenHeute.clamp(0, fs.tagesziel);
    final fertig = fs.tageszielErreicht;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: ZfaTheme.goldGrad,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: ZfaTheme.gold.withOpacity(0.4),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 78,
                height: 78,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 78,
                      height: 78,
                      child: CircularProgressIndicator(
                        value: fs.tageszielFortschritt,
                        strokeWidth: 9,
                        backgroundColor: const Color(0x33000000),
                        valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF3E2723)),
                      ),
                    ),
                    Text(fertig ? '✓' : '$geschafft/${fs.tagesziel}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Color(0xFF3E2723))),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fertig ? 'Tagesziel geschafft! 🎉' : 'Dein Fokus heute',
                        style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF3E2723))),
                    const SizedBox(height: 4),
                    Text(
                        fertig
                            ? 'Stark dran geblieben – noch eine Runde?'
                            : bereich,
                        style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF5D4037),
                            height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onLernen,
              icon: const Icon(Icons.play_arrow_rounded, size: 26),
              label: const Text('Jetzt 5 Minuten lernen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A1A12),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Kacheln ----------------
class _PruefungsKachel extends StatelessWidget {
  final VoidCallback onAenderung;
  const _PruefungsKachel({required this.onAenderung});

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
    final tc = Theme.of(context).colorScheme.onSurface;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      onTap: () => _datumWaehlen(context),
      child: Row(
        children: [
          const Text('🗓️', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tage == null
                      ? 'Termin setzen'
                      : tage > 0
                          ? 'Noch $tage Tage'
                          : tage == 0
                              ? 'Heute! 🍀'
                              : 'Termin anpassen',
                  style: TextStyle(
                      color: tc, fontWeight: FontWeight.w800, fontSize: 17),
                ),
                Text('bis zur Prüfung',
                    style:
                        TextStyle(color: tc.withOpacity(0.6), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BuddyTipp extends StatelessWidget {
  static const _tipps = [
    'Schon 5 Minuten am Tag bringen dich weiter!',
    'Sag die Antwort laut – so merkst du sie dir besser.',
    'Falsche Karten kommen öfter wieder. Das ist gut so!',
    'Denk an die 3er-Regel: Blick, Name, Lächeln.',
    'Lange Kanüle = lange Leitung (Unterkiefer).',
    'Erst desinfizieren, dann Handschuhe anziehen.',
    'Lüften kommt ans Ende der Hygiene, nicht an den Anfang.',
  ];

  @override
  Widget build(BuildContext context) {
    final fs = fortschrittService;
    final tc = Theme.of(context).colorScheme.onSurface;
    final tipp = _tipps[DateTime.now().day % _tipps.length];
    final stimmung = fs.tageszielErreicht
        ? BuddyStimmung.jubel
        : fs.streak >= 3
            ? BuddyStimmung.freude
            : BuddyStimmung.idle;
    return GlassCard(
      child: Row(
        children: [
          LernBuddy(stimmung: stimmung, groesse: 72),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Zahni sagt:',
                    style: TextStyle(
                        color: tc.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(tipp,
                    style: TextStyle(
                        color: tc, fontSize: 14.5, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CockpitTeaser extends StatelessWidget {
  final VoidCallback onReturn;
  const _CockpitTeaser({required this.onReturn});

  @override
  Widget build(BuildContext context) {
    final fs = fortschrittService;
    final chance = fs.bestehensWahrscheinlichkeit();
    final readiness = fs.readinessScore();
    final farbe = chance >= 70
        ? ZfaTheme.gruen
        : chance >= 45
            ? ZfaTheme.gold
            : ZfaTheme.rot;
    final tc = Theme.of(context).colorScheme.onSurface;
    return GlassCard(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CockpitScreen()))
            .then((_) => onReturn());
      },
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(
                    value: readiness / 100,
                    strokeWidth: 6,
                    backgroundColor: tc.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation(farbe),
                  ),
                ),
                Text('$chance%',
                    style: TextStyle(
                        color: tc, fontSize: 12, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bestehens-Chance',
                    style: TextStyle(
                        color: tc, fontSize: 16, fontWeight: FontWeight.w800)),
                Text('Cockpit öffnen – Trend & Themen',
                    style:
                        TextStyle(color: tc.withOpacity(0.6), fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.insights_rounded, color: farbe),
        ],
      ),
    );
  }
}

class _StreakKachel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text('${fortschrittService.streak}',
              style: TextStyle(
                  color: tc, fontWeight: FontWeight.w800, fontSize: 22)),
          Text('Tage Serie',
              style: TextStyle(color: tc.withOpacity(0.6), fontSize: 11)),
        ],
      ),
    );
  }
}

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
    final tc = Theme.of(context).colorScheme.onSurface;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Text('🔔', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tägliche Erinnerung',
                    style: TextStyle(
                        color: tc,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                Text(
                  s.aktiv
                      ? 'Jeden Tag um ${s.stunde.toString().padLeft(2, '0')}:${s.minute.toString().padLeft(2, '0')} Uhr'
                      : 'Aus – tippe zum Aktivieren',
                  style: TextStyle(color: tc.withOpacity(0.6), fontSize: 12),
                ),
              ],
            ),
          ),
          _busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Switch(value: s.aktiv, onChanged: _umschalten),
        ],
      ),
    );
  }
}

class _IconPille extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconPille({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    return GlassCard(
      padding: const EdgeInsets.all(10),
      radius: 16,
      onTap: onTap,
      child: Icon(icon, color: tc, size: 22),
    );
  }
}

// ---------------- Rails & Poster ----------------
class _Rail extends StatelessWidget {
  final String titel;
  final List<_Poster> poster;
  const _Rail({required this.titel, required this.poster});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titel, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 184,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: poster.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) => poster[i],
          ),
        ),
      ],
    );
  }
}

class _Poster extends StatelessWidget {
  final String emoji;
  final String titel;
  final String untertitel;
  final Gradient gradient;
  final Widget ziel;
  final VoidCallback onReturn;
  const _Poster(this.emoji, this.titel, this.untertitel, this.gradient,
      this.ziel, this.onReturn);

  @override
  Widget build(BuildContext context) {
    final letzte = (gradient as LinearGradient).colors.last;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(context, MaterialPageRoute(builder: (_) => ziel))
            .then((_) => onReturn());
      },
      child: Container(
        width: 152,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
                color: letzte.withOpacity(0.45),
                blurRadius: 20,
                offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 30)),
            ),
            const Spacer(),
            Text(titel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    height: 1.1)),
            const SizedBox(height: 2),
            Text(untertitel,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.85), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
