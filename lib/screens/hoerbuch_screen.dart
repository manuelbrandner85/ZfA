import 'package:flutter/material.dart';
import '../main.dart';
import '../core/services/tts_service.dart';
import '../models/hoerbuch_kapitel.dart';

class HoerbuchScreen extends StatefulWidget {
  final HoerbuchKapitel kapitel;
  const HoerbuchScreen({super.key, required this.kapitel});

  @override
  State<HoerbuchScreen> createState() => _HoerbuchScreenState();
}

class _HoerbuchScreenState extends State<HoerbuchScreen> {
  int _aktuellerSatz = 0;
  bool _laeuft = false;
  double _tempo = 1.0; // Anzeige-Faktor (1.0 = normal 0.45)
  final ScrollController _scroll = ScrollController();

  // Mapping Anzeige-Faktor -> TTS-Rate (Basis 0.45)
  double _ttsRate(double faktor) => (0.45 * faktor).clamp(0.1, 1.0);

  @override
  void initState() {
    super.initState();
    final gespeichert =
        fortschrittService.hoerbuchFortschritt[widget.kapitel.id] ?? 0;
    _aktuellerSatz = gespeichert.clamp(0, widget.kapitel.anzahlSaetze - 1);

    ttsService.onSatzAendert = (index) {
      if (!mounted) return;
      setState(() => _aktuellerSatz = index);
      fortschrittService.hoerbuchSpeichern(widget.kapitel.id, index);
      _aktualisiereMiniPlayer();
      _scrolleZuSatz(index);
    };
    ttsService.onZustandAendert = (zustand) {
      if (!mounted) return;
      setState(() => _laeuft = zustand == TtsZustand.spricht);
      _aktualisiereMiniPlayer();
    };

    // Bei gespeichertem Fortschritt nachfragen
    if (gespeichert > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _frageWeiter(gespeichert));
    }
  }

  void _aktualisiereMiniPlayer() {
    aktuellerAudio.value = AudioZustand(
      kapitelEmoji: widget.kapitel.emoji,
      kapitelTitel: widget.kapitel.titel,
      laeuft: _laeuft,
      fortschritt: widget.kapitel.anzahlSaetze == 0
          ? 0
          : _aktuellerSatz / widget.kapitel.anzahlSaetze,
    );
  }

  Future<void> _frageWeiter(int satz) async {
    final weiter = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Weiterhören?'),
        content: Text('Du warst bei Abschnitt ${satz + 1}. Dort weitermachen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Von vorne'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(minimumSize: const Size(120, 44)),
            child: const Text('Weiter'),
          ),
        ],
      ),
    );
    if (weiter == false) {
      setState(() => _aktuellerSatz = 0);
    }
  }

  void _scrolleZuSatz(int index) {
    if (!_scroll.hasClients) return;
    // Geschätzte Höhe pro Satz ~ 64px, zentriert scrollen
    final ziel = (index * 64.0) - 120;
    _scroll.animateTo(
      ziel.clamp(0, _scroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _playPause() async {
    if (_laeuft) {
      await ttsService.stoppen();
      setState(() => _laeuft = false);
    } else {
      await ttsService.geschwindigkeitSetzen(_ttsRate(_tempo));
      await ttsService.kapitelVorlesen(widget.kapitel.saetze,
          startIndex: _aktuellerSatz);
    }
  }

  Future<void> _satzWechsel(int delta) async {
    final neu =
        (_aktuellerSatz + delta).clamp(0, widget.kapitel.anzahlSaetze - 1);
    setState(() => _aktuellerSatz = neu);
    fortschrittService.hoerbuchSpeichern(widget.kapitel.id, neu);
    if (_laeuft) {
      await ttsService.zuSatzSpringen(neu);
    }
  }

  Future<void> _tempoSetzen(double faktor) async {
    setState(() => _tempo = faktor);
    await ttsService.geschwindigkeitSetzen(_ttsRate(faktor));
    if (_laeuft) {
      // Neu starten ab aktuellem Satz, damit Tempo greift
      await ttsService.zuSatzSpringen(_aktuellerSatz);
    }
  }

  @override
  void dispose() {
    ttsService.onSatzAendert = null;
    ttsService.onZustandAendert = null;
    ttsService.stoppen();
    fortschrittService.hoerbuchSpeichern(widget.kapitel.id, _aktuellerSatz);
    aktuellerAudio.value = null;
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.kapitel;
    final gesamt = k.anzahlSaetze;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Column(
          children: [
            // Kopf
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'Abschnitt ${_aktuellerSatz + 1} / $gesamt',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Cover + Titel
            Container(
              width: 130,
              height: 130,
              margin: const EdgeInsets.only(top: 4, bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [k.farbe, k.farbe.withOpacity(0.55)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: k.farbe.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(k.emoji, style: const TextStyle(fontSize: 64)),
            ),
            Text(
              k.titel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Text(
                k.untertitel,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFB0C4FF), fontSize: 14),
              ),
            ),

            // Karaoke-Textbereich
            Expanded(
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
                  stops: [0.0, 0.12, 0.88, 1.0],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 24),
                  itemCount: gesamt,
                  itemBuilder: (context, i) {
                    final istAktuell = i == _aktuellerSatz;
                    final istVergangen = i < _aktuellerSatz;
                    return GestureDetector(
                      onTap: () => _satzWechsel(i - _aktuellerSatz),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          k.saetze[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: istAktuell ? 22 : 16,
                            height: 1.4,
                            fontWeight:
                                istAktuell ? FontWeight.w800 : FontWeight.w500,
                            color: istAktuell
                                ? Colors.white
                                : istVergangen
                                    ? Colors.white30
                                    : Colors.white60,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Geschwindigkeits-Chips
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [0.5, 0.75, 1.0, 1.25].map((f) {
                  final aktiv = _tempo == f;
                  final chip = Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: GestureDetector(
                      onTap: () => _tempoSetzen(f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: aktiv
                              ? const Color(0xFF42A5F5)
                              : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${f}x',
                          style: TextStyle(
                            color: aktiv ? Colors.white : Colors.white60,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                  if (f == 0.5) {
                    return Tooltip(
                      message: 'Sehr langsam – perfekt zum Lernen',
                      child: chip,
                    );
                  }
                  return chip;
                }).toList(),
              ),
            ),

            // Fortschrittsbalken
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: gesamt == 0 ? 0 : (_aktuellerSatz + 1) / gesamt,
                  minHeight: 6,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation(k.farbe),
                ),
              ),
            ),

            // Steuerung
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 44,
                    icon: const Icon(Icons.skip_previous_rounded,
                        color: Colors.white),
                    onPressed: () => _satzWechsel(-1),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _playPause,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF42A5F5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF42A5F5).withOpacity(0.5),
                            blurRadius: 22,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        _laeuft
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    iconSize: 44,
                    icon: const Icon(Icons.skip_next_rounded,
                        color: Colors.white),
                    onPressed: () => _satzWechsel(1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
