import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/zfa_theme.dart';
import '../models/lernkarte.dart';
import '../data/lernkarten_daten.dart';
import '../widgets/tts_button.dart';

class GlossarScreen extends StatefulWidget {
  const GlossarScreen({super.key});

  @override
  State<GlossarScreen> createState() => _GlossarScreenState();
}

class _GlossarScreenState extends State<GlossarScreen> {
  String _suche = '';
  late final List<Lernkarte> _alle;

  @override
  void initState() {
    super.initState();
    _alle = [
      ...alleLernkarten(),
      ...eigeneKartenService.karten,
    ]..sort((a, b) =>
        a.vorderseite.toLowerCase().compareTo(b.vorderseite.toLowerCase()));
  }

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    final q = _suche.trim().toLowerCase();
    final treffer = q.isEmpty
        ? _alle
        : _alle
            .where((k) =>
                k.vorderseite.toLowerCase().contains(q) ||
                k.rueckseite.toLowerCase().contains(q) ||
                k.einfachVersion.toLowerCase().contains(q) ||
                k.bereich.toLowerCase().contains(q))
            .toList();

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
                    Text('Glossar',
                        style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  radius: 16,
                  child: TextField(
                    onChanged: (v) => setState(() => _suche = v),
                    style: TextStyle(color: tc),
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: tc.withOpacity(0.6)),
                      hintText: 'Begriff suchen …',
                      hintStyle: TextStyle(color: tc.withOpacity(0.5)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('${treffer.length} Begriffe',
                      style:
                          TextStyle(color: tc.withOpacity(0.6), fontSize: 12)),
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: treffer.length,
                  itemBuilder: (context, i) {
                    final k = treffer[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            leading: Text(k.emoji,
                                style: const TextStyle(fontSize: 24)),
                            title: Text(k.vorderseite,
                                style: TextStyle(
                                    color: tc,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15)),
                            subtitle: Text(k.bereich,
                                style: TextStyle(
                                    color: tc.withOpacity(0.55),
                                    fontSize: 11)),
                            childrenPadding: const EdgeInsets.fromLTRB(
                                12, 0, 12, 12),
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: _Block(
                                    titel: '💡 Einfach',
                                    text: k.einfachVersion,
                                    farbe: ZfaTheme.blau,
                                    tc: tc),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: _Block(
                                    titel: '🎓 Fachlich',
                                    text: k.rueckseite,
                                    farbe: ZfaTheme.violett,
                                    tc: tc),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TtsButton(
                                    text:
                                        '${k.vorderseite}. ${k.einfachVersion}. ${k.rueckseite}',
                                    farbe: ZfaTheme.hellblau),
                              ),
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

class _Block extends StatelessWidget {
  final String titel;
  final String text;
  final Color farbe;
  final Color tc;
  const _Block(
      {required this.titel,
      required this.text,
      required this.farbe,
      required this.tc});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: farbe.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: farbe.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titel,
              style: TextStyle(
                  color: farbe, fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(text,
              style: TextStyle(color: tc, fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }
}
