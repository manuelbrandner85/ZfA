import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../main.dart';
import '../core/services/tts_service.dart';
import '../theme/zfa_theme.dart';
import '../models/behandlungsablauf.dart';
import '../data/behandlungsablaeufe_daten.dart';
import 'ablauf_erklaeren_screen.dart';
import '../widgets/fav_stern.dart';

class AblaeufeScreen extends StatelessWidget {
  const AblaeufeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 4),
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.arrow_back, color: tc),
                        onPressed: () => Navigator.pop(context)),
                    Expanded(
                      child: Text('Behandlungsabläufe',
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${alleBehandlungsablaeufe.length} Abläufe Schritt für Schritt – ideal fürs Fachgespräch.',
                    style: TextStyle(color: tc.withOpacity(0.65), fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: alleBehandlungsablaeufe.length,
                  itemBuilder: (context, i) {
                    final a = alleBehandlungsablaeufe[i];
                    return FadeInUp(
                      delay: Duration(milliseconds: 25 * i),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          padding: const EdgeInsets.all(14),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AblaufDetailScreen(ablauf: a)),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: ZfaTheme.blauGrad,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: Text(a.emoji,
                                    style: const TextStyle(fontSize: 28)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${i + 1}. ${a.titel}',
                                        style: TextStyle(
                                            color: tc,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16)),
                                    Text(
                                        '${a.untertitel} · ${a.anzahlSchritte} Schritte',
                                        style: TextStyle(
                                            color: tc.withOpacity(0.6),
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  color: tc.withOpacity(0.5)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AblaufDetailScreen extends StatefulWidget {
  final Behandlungsablauf ablauf;
  const AblaufDetailScreen({super.key, required this.ablauf});

  @override
  State<AblaufDetailScreen> createState() => _AblaufDetailScreenState();
}

class _AblaufDetailScreenState extends State<AblaufDetailScreen> {
  final Set<String> _erledigt = {};
  bool _liest = false;

  @override
  void initState() {
    super.initState();
    ttsService.onZustandAendert = (z) {
      if (mounted) setState(() => _liest = z == TtsZustand.spricht);
    };
  }

  @override
  void dispose() {
    ttsService.onZustandAendert = null;
    ttsService.stoppen();
    super.dispose();
  }

  Future<void> _vorlesen() async {
    if (_liest) {
      await ttsService.stoppen();
    } else {
      await ttsService.kapitelVorlesen(widget.ablauf.alleSaetze());
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.ablauf;
    final tc = Theme.of(context).colorScheme.onSurface;
    final gesamt = a.anzahlSchritte;
    final fortschritt = gesamt == 0 ? 0.0 : _erledigt.length / gesamt;

    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 12, 4),
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.arrow_back, color: tc),
                        onPressed: () => Navigator.pop(context)),
                    Expanded(
                      child: Text(a.titel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                    FavStern(id: a.id),
                    IconButton(
                      icon: Icon(
                          _liest
                              ? Icons.stop_circle_rounded
                              : Icons.volume_up_rounded,
                          color: ZfaTheme.hellblau),
                      onPressed: _vorlesen,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: [
                    // Kopf
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: ZfaTheme.blauGrad,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(a.emoji, style: const TextStyle(fontSize: 40)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.titel,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800)),
                                Text(
                                    a.indikation.isEmpty
                                        ? '${a.untertitel} · ${a.anzahlSchritte} Schritte'
                                        : a.indikation,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        height: 1.3)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Aktiv üben: erklären
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    AblaufErklaerenScreen(ablauf: a)),
                          );
                        },
                        icon: const Icon(Icons.mic_rounded),
                        label: const Text('Erklären üben (wie im Fachgespräch)'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ZfaTheme.violett,
                            foregroundColor: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Fortschritt
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: fortschritt,
                              minHeight: 8,
                              backgroundColor: tc.withOpacity(0.12),
                              valueColor:
                                  const AlwaysStoppedAnimation(ZfaTheme.gruen),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('${_erledigt.length}/$gesamt',
                            style: TextStyle(
                                color: tc, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Phasen
                    for (final phase in a.phasen) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 8),
                        child: Text(phase.titel,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        child: Column(
                          children: [
                            for (int j = 0; j < phase.schritte.length; j++)
                              _SchrittZeile(
                                text: phase.schritte[j],
                                erledigt: _erledigt
                                    .contains('${phase.titel}_$j'),
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  final key = '${phase.titel}_$j';
                                  setState(() {
                                    if (!_erledigt.add(key)) {
                                      _erledigt.remove(key);
                                    }
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SchrittZeile extends StatelessWidget {
  final String text;
  final bool erledigt;
  final VoidCallback onTap;
  const _SchrittZeile(
      {required this.text, required this.erledigt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              erledigt
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: erledigt ? ZfaTheme.gruen : tc.withOpacity(0.35),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                    color: erledigt ? tc.withOpacity(0.55) : tc,
                    fontSize: 14.5,
                    height: 1.4,
                    decoration:
                        erledigt ? TextDecoration.lineThrough : null,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
