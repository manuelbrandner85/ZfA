import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/zfa_theme.dart';
import '../models/lernkarte.dart';
import '../data/lernkarten_daten.dart';
import '../data/behandlungsablaeufe_daten.dart';
import '../widgets/tts_button.dart';
import '../widgets/fav_stern.dart';
import 'ablaeufe_screen.dart';

class FavoritenScreen extends StatefulWidget {
  const FavoritenScreen({super.key});

  @override
  State<FavoritenScreen> createState() => _FavoritenScreenState();
}

class _FavoritenScreenState extends State<FavoritenScreen> {
  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    final fav = fortschrittService.favoriten;
    final karten = [
      ...alleLernkarten(),
      ...eigeneKartenService.karten,
    ].where((k) => fav.contains(k.id)).toList();
    final ablaeufe =
        alleBehandlungsablaeufe.where((a) => fav.contains(a.id)).toList();
    final leer = karten.isEmpty && ablaeufe.isEmpty;

    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 4),
                child: Row(children: [
                  IconButton(
                      icon: Icon(Icons.arrow_back, color: tc),
                      onPressed: () => Navigator.pop(context)),
                  Text('Favoriten',
                      style: Theme.of(context).textTheme.titleLarge),
                ]),
              ),
              Expanded(
                child: leer
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bookmark_border,
                                  size: 56, color: ZfaTheme.gold),
                              const SizedBox(height: 12),
                              Text(
                                  'Noch keine Favoriten. Tippe das Lesezeichen-Symbol bei Karten oder Abläufen, um sie hier zu sammeln.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: tc.withOpacity(0.7),
                                      fontSize: 15)),
                            ],
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        children: [
                          if (ablaeufe.isNotEmpty) ...[
                            _Titel('Abläufe', tc),
                            ...ablaeufe.map((a) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: GlassCard(
                                    padding: const EdgeInsets.all(12),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              AblaufDetailScreen(ablauf: a)),
                                    ).then((_) => setState(() {})),
                                    child: Row(
                                      children: [
                                        Text(a.emoji,
                                            style:
                                                const TextStyle(fontSize: 26)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(a.titel,
                                              style: TextStyle(
                                                  color: tc,
                                                  fontWeight:
                                                      FontWeight.w700)),
                                        ),
                                        FavStern(id: a.id),
                                      ],
                                    ),
                                  ),
                                )),
                            const SizedBox(height: 12),
                          ],
                          if (karten.isNotEmpty) ...[
                            _Titel('Karten', tc),
                            ...karten.map((k) => _KartenZeile(
                                karte: k,
                                tc: tc,
                                onChange: () => setState(() {}))),
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

class _KartenZeile extends StatelessWidget {
  final Lernkarte karte;
  final Color tc;
  final VoidCallback onChange;
  const _KartenZeile(
      {required this.karte, required this.tc, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
        child: Row(
          children: [
            Text(karte.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(karte.vorderseite,
                      style: TextStyle(
                          color: tc, fontWeight: FontWeight.w800)),
                  Text(karte.rueckseite,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: tc.withOpacity(0.65), fontSize: 13)),
                ],
              ),
            ),
            TtsButton(
                text: '${karte.vorderseite}. ${karte.rueckseite}',
                farbe: ZfaTheme.hellblau),
            FavStern(id: karte.id, groesse: 22),
          ],
        ),
      ),
    );
  }
}

class _Titel extends StatelessWidget {
  final String t;
  final Color tc;
  const _Titel(this.t, this.tc);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4, top: 4),
        child: Text(t,
            style: TextStyle(
                color: tc.withOpacity(0.6),
                fontSize: 13,
                fontWeight: FontWeight.w800)),
      );
}
