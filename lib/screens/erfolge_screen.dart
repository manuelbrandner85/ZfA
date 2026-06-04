import 'dart:math';
import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/zfa_theme.dart';

class _Abzeichen {
  final String id;
  final String emoji;
  final String titel;
  final String beschreibung;
  final bool Function() erfuellt;
  const _Abzeichen(
      this.id, this.emoji, this.titel, this.beschreibung, this.erfuellt);
}

class ErfolgeScreen extends StatefulWidget {
  const ErfolgeScreen({super.key});

  @override
  State<ErfolgeScreen> createState() => _ErfolgeScreenState();
}

class _ErfolgeScreenState extends State<ErfolgeScreen> {
  late final List<_Abzeichen> _alle;

  @override
  void initState() {
    super.initState();
    final fs = fortschrittService;
    _alle = [
      _Abzeichen('start', '🚀', 'Erste Schritte', 'Beantworte deine erste Frage',
          () => fs.geloesteFragen.isNotEmpty),
      _Abzeichen('p100', '⭐', 'Sammler', 'Erreiche 100 Punkte',
          () => fs.gesamtPunkte >= 100),
      _Abzeichen('p500', '🏆', 'Meister', 'Erreiche 500 Punkte',
          () => fs.gesamtPunkte >= 500),
      _Abzeichen('streak3', '🔥', 'Dranbleiber', '3 Tage in Folge',
          () => fs.streak >= 3),
      _Abzeichen('streak7', '🌟', 'Wochenheld', '7 Tage in Folge',
          () => fs.streak >= 7),
      _Abzeichen('hygiene', '🧤', 'Hygiene-Profi',
          'Hygiene über 80 % beherrschen',
          () => (fs.bereichGesamt['Hygiene'] ?? 0) >= 5 &&
              fs.bereichQuote('Hygiene') >= 0.8),
      _Abzeichen('hoerer', '📖', 'Zuhörer', '3 Hörbuch-Kapitel gehört',
          () => fs.kapitelGehoert >= 3),
      _Abzeichen(
          'allround',
          '🧠',
          'Allrounder',
          'In jedem Thema geübt',
          () => const [
                'Anmeldung',
                'Hygiene',
                'Behandlungsassistenz',
                'Anästhesie',
                'Chirurgie',
                'Karies',
                'Parodontitis'
              ].every((b) => (fs.bereichGesamt[b] ?? 0) > 0)),
      _Abzeichen('reif', '🎓', 'Prüfungsreif', 'Readiness über 70',
          () => fs.readinessScore() >= 70),
    ];
    // Erfüllte dauerhaft freischalten
    for (final a in _alle) {
      if (a.erfuellt()) fortschrittService.abzeichenFreischalten(a.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    final freigeschaltet = fortschrittService.abzeichen;

    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 6),
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.arrow_back, color: tc),
                        onPressed: () => Navigator.pop(context)),
                    Text('Erfolge & Liga',
                        style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: [
                    Text('Wochen-Liga',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    const _Liga(),
                    const SizedBox(height: 22),
                    Text('Deine Abzeichen',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.82,
                      children: _alle.map((a) {
                        final hat = freigeschaltet.contains(a.id);
                        return _AbzeichenKachel(a: a, frei: hat);
                      }).toList(),
                    ),
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

class _AbzeichenKachel extends StatelessWidget {
  final _Abzeichen a;
  final bool frei;
  const _AbzeichenKachel({required this.a, required this.frei});

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(children: [
            Text(a.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 8),
            Expanded(child: Text(a.titel)),
          ]),
          content: Text(frei
              ? '${a.beschreibung}\n\nFreigeschaltet ✅'
              : '${a.beschreibung}\n\nNoch nicht freigeschaltet.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK')),
          ],
        ),
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(10),
        radius: 18,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: frei ? 1 : 0.32,
              child: Text(a.emoji, style: const TextStyle(fontSize: 38)),
            ),
            const SizedBox(height: 6),
            Text(a.titel,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: frei ? tc : tc.withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
            if (!frei)
              Icon(Icons.lock, size: 12, color: tc.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}

class _Liga extends StatelessWidget {
  const _Liga();

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    final meine = fortschrittService.wochenXp;
    // Deterministische Mitstreiter rund um den eigenen XP-Wert
    final rng = Random(7);
    const namen = [
      'Lena', 'Mehmet', 'Sophie', 'Jonas', 'Aylin', 'Tim', 'Marie', 'Paul'
    ];
    final eintraege = <MapEntry<String, int>>[
      MapEntry('Du', meine),
      for (final n in namen)
        MapEntry(n, max(0, meine + rng.nextInt(120) - 55)),
    ]..sort((a, b) => b.value.compareTo(a.value));

    return GlassCard(
      child: Column(
        children: [
          for (int i = 0; i < eintraege.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text('${i + 1}',
                        style: TextStyle(
                            color: i < 3 ? ZfaTheme.gold : tc.withOpacity(0.6),
                            fontWeight: FontWeight.w800)),
                  ),
                  Icon(
                    i < 3
                        ? Icons.emoji_events
                        : Icons.person_outline_rounded,
                    size: 18,
                    color: i < 3 ? ZfaTheme.gold : tc.withOpacity(0.5),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(eintraege[i].key,
                        style: TextStyle(
                            color: tc,
                            fontWeight: eintraege[i].key == 'Du'
                                ? FontWeight.w800
                                : FontWeight.w500)),
                  ),
                  Text('${eintraege[i].value} XP',
                      style: TextStyle(
                          color: tc.withOpacity(0.8),
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Text('Top 3 steigen auf – sammle XP durch richtige Antworten!',
              style: TextStyle(color: tc.withOpacity(0.6), fontSize: 12)),
        ],
      ),
    );
  }
}
