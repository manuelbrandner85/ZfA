import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../main.dart';
import '../core/services/stt_service.dart';
import '../models/fachgespraech_frage.dart';
import '../data/muendliche_pruefung_daten.dart';
import '../widgets/sprach_eingabe_button.dart';
import '../widgets/tts_button.dart';

class MuendlichePruefungScreen extends StatefulWidget {
  const MuendlichePruefungScreen({super.key});

  @override
  State<MuendlichePruefungScreen> createState() =>
      _MuendlichePruefungScreenState();
}

class _MuendlichePruefungScreenState extends State<MuendlichePruefungScreen> {
  final SttService _stt = SttService();
  late List<FachgespraechFrage> _fragen;
  String _filter = 'Alle';
  int _index = 0;
  bool _stichpunkteOffen = false;
  bool _musterOffen = false;
  String _erkannt = '';
  bool _hoert = false;
  bool _mikVerfuegbar = true;

  @override
  void initState() {
    super.initState();
    _stt.onTextAendert = (t) {
      if (mounted) setState(() => _erkannt = t);
    };
    _stt.onAktivAendert = (a) {
      if (mounted) setState(() => _hoert = a);
    };
    _stt.initialisieren().then((ok) {
      if (mounted) setState(() => _mikVerfuegbar = ok);
    });
    _fragenLaden('Alle');
    WidgetsBinding.instance.addPostFrameCallback((_) => _frageVorlesen());
  }

  void _fragenLaden(String filter) {
    _filter = filter;
    _index = 0;
    if (filter == 'Alle') {
      _fragen = alleFachgespraeche.toList()..shuffle();
    } else {
      _fragen = alleFachgespraeche.where((f) => f.bereich == filter).toList();
    }
    _zuruecksetzen();
  }

  void _zuruecksetzen() {
    _stichpunkteOffen = false;
    _musterOffen = false;
    _erkannt = '';
  }

  void _frageVorlesen() {
    if (_fragen.isEmpty) return;
    ttsService.sprechen(_fragen[_index].frage);
  }

  Future<void> _mikTippen() async {
    if (_hoert) {
      await _stt.stoppeUndGibText();
    } else {
      setState(() => _erkannt = '');
      await _stt.starteZuhoeren();
    }
  }

  void _musterVorlesen() {
    setState(() {
      _musterOffen = true;
      _stichpunkteOffen = true;
    });
    ttsService.sprechen(_fragen[_index].musterantwort);
  }

  void _bewerten(bool konnte) {
    HapticFeedback.selectionClick();
    final f = _fragen[_index];
    if (konnte) {
      fortschrittService.frageRichtigBeantwortet('fg_${f.id}',
          bereich: f.bereich);
    } else {
      fortschrittService.frageFalschBeantwortet('fg_${f.id}',
          bereich: f.bereich);
    }
    _weiter();
  }

  void _weiter() {
    ttsService.stoppen();
    if (_index < _fragen.length - 1) {
      setState(() {
        _index++;
        _zuruecksetzen();
      });
      _frageVorlesen();
    } else {
      _zeigeEnde();
    }
  }

  void _zeigeEnde() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎓', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 8),
              const Text('Prüfung durchgespielt!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text(
                'Stark! Wiederhole die Themen, bei denen du unsicher warst.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _fragenLaden(_filter));
                  _frageVorlesen();
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
    _stt.stoppeUndGibText();
    ttsService.stoppen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_fragen.isEmpty) {
      return const Scaffold(body: Center(child: Text('Keine Fragen.')));
    }
    final f = _fragen[_index];
    final bereiche = ['Alle', ...fachgespraechBereiche()];
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('🎓 Mündliche Prüfung'),
        backgroundColor: const Color(0xFF4527A0),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_index + 1) / _fragen.length,
            minHeight: 8,
            backgroundColor: const Color(0xFFD1C4E9),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF4527A0)),
          ),
          // Themen-Filter
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: bereiche.map((b) {
                final aktiv = _filter == b;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: ChoiceChip(
                    label: Text(b),
                    selected: aktiv,
                    onSelected: (_) {
                      setState(() => _fragenLaden(b));
                      _frageVorlesen();
                    },
                    selectedColor: const Color(0xFF4527A0),
                    labelStyle: TextStyle(
                      color: aktiv ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                // Prüfer-Frage
                FadeIn(
                  key: ValueKey('frage_${f.id}'),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4527A0), Color(0xFF673AB7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4527A0).withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('${f.emoji}  ${f.bereich}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            ),
                            const Spacer(),
                            const Text('👨‍⚕️ Prüfer',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          f.frage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TtsButton(
                              text: f.frage, farbe: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sprech-Übung
                Center(
                  child: Column(
                    children: [
                      const Text('Antworte laut – wie in der Prüfung',
                          style: TextStyle(
                              fontSize: 14, color: Colors.black54)),
                      const SizedBox(height: 10),
                      if (_mikVerfuegbar)
                        SprachEingabeButton(
                            aktiv: _hoert, onTippen: _mikTippen)
                      else
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('🎤 Kein Mikrofon – sprich für dich,\ndann prüfe mit der Musterantwort.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black45)),
                        ),
                    ],
                  ),
                ),
                if (_erkannt.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text('„$_erkannt"',
                        style: const TextStyle(
                            fontSize: 16, fontStyle: FontStyle.italic)),
                  ),
                ],
                const SizedBox(height: 18),

                // Stichpunkte (Selbstkontrolle)
                _AufklappBox(
                  titel: 'Das solltest du nennen',
                  emoji: '✅',
                  farbe: const Color(0xFF2E7D32),
                  offen: _stichpunkteOffen,
                  onTap: () => setState(
                      () => _stichpunkteOffen = !_stichpunkteOffen),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: f.stichpunkte
                        .map((s) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text('•  ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32))),
                                  Expanded(
                                      child: Text(s,
                                          style: const TextStyle(
                                              fontSize: 15, height: 1.4))),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // Musterantwort
                _AufklappBox(
                  titel: 'Musterantwort',
                  emoji: '💬',
                  farbe: const Color(0xFF1565C0),
                  offen: _musterOffen,
                  onTap: () => setState(() => _musterOffen = !_musterOffen),
                  trailing: TtsButton(
                      text: f.musterantwort,
                      farbe: const Color(0xFF1565C0)),
                  child: Text(f.musterantwort,
                      style: const TextStyle(fontSize: 16, height: 1.55)),
                ),
                const SizedBox(height: 8),
                if (!_musterOffen)
                  Center(
                    child: TextButton.icon(
                      onPressed: _musterVorlesen,
                      icon: const Icon(Icons.play_circle_outline),
                      label: const Text('Musterantwort anhören'),
                    ),
                  ),
                const SizedBox(height: 16),

                // Selbsteinschätzung
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _bewerten(false),
                        icon: const Icon(Icons.refresh,
                            color: Color(0xFFEF6C00)),
                        label: const Text('Nochmal üben',
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
                        label: const Text('Konnte ich'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4527A0),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 52),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AufklappBox extends StatelessWidget {
  final String titel;
  final String emoji;
  final Color farbe;
  final bool offen;
  final VoidCallback onTap;
  final Widget child;
  final Widget? trailing;

  const _AufklappBox({
    required this.titel,
    required this.emoji,
    required this.farbe,
    required this.offen,
    required this.onTap,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: farbe.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: farbe.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(titel,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: farbe)),
                  ),
                  if (trailing != null && offen) trailing!,
                  Icon(offen ? Icons.expand_less : Icons.expand_more,
                      color: farbe),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(alignment: Alignment.centerLeft, child: child),
            ),
            crossFadeState: offen
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
