import 'package:flutter/material.dart';
import '../theme/zfa_theme.dart';
import '../data/lernkarten_daten.dart';
import '../data/behandlungsablaeufe_daten.dart';
import '../data/quiz/alle_quiz_fragen.dart';
import '../data/muendliche_pruefung_daten.dart';
import '../widgets/tts_button.dart';
import 'ablaeufe_screen.dart';

class _Treffer {
  final String emoji;
  final String titel;
  final String text;
  final String typ;
  final VoidCallback? oeffnen;
  const _Treffer(this.emoji, this.titel, this.text, this.typ, this.oeffnen);
}

/// Durchsucht die gesamte App: Karten, Abläufe, Quizfragen, Fachgespräche.
class SucheScreen extends StatefulWidget {
  const SucheScreen({super.key});

  @override
  State<SucheScreen> createState() => _SucheScreenState();
}

class _SucheScreenState extends State<SucheScreen> {
  String _q = '';

  List<_Treffer> _suche(BuildContext context) {
    final q = _q.trim().toLowerCase();
    if (q.length < 2) return [];
    final out = <_Treffer>[];

    bool m(String s) => s.toLowerCase().contains(q);

    for (final a in alleBehandlungsablaeufe) {
      final inSteps = a.phasen.any((p) => p.schritte.any(m));
      if (m(a.titel) || m(a.untertitel) || inSteps) {
        out.add(_Treffer(a.emoji, a.titel, 'Behandlungsablauf', 'Ablauf', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => AblaufDetailScreen(ablauf: a)));
        }));
      }
    }
    for (final k in alleLernkarten()) {
      if (m(k.vorderseite) || m(k.rueckseite) || m(k.einfachVersion)) {
        out.add(_Treffer(k.emoji, k.vorderseite,
            '${k.einfachVersion}\n${k.rueckseite}', 'Karte', null));
      }
    }
    for (final f in alleQuizFragen) {
      if (m(f.frage) || m(f.erklaerung)) {
        out.add(_Treffer('🎯', f.frage,
            '✅ ${f.antworten[f.richtigeAntwortIndex]}\n${f.erklaerung}',
            'Quizfrage', null));
      }
    }
    for (final f in alleFachgespraeche) {
      if (m(f.frage) || m(f.musterantwort)) {
        out.add(_Treffer(f.emoji, f.frage, f.musterantwort, 'Fachgespräch',
            null));
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    final treffer = _suche(context);
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
                  Text('Suche', style: Theme.of(context).textTheme.titleLarge),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  radius: 16,
                  child: TextField(
                    autofocus: true,
                    style: TextStyle(color: tc),
                    onChanged: (v) => setState(() => _q = v),
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: tc.withOpacity(0.6)),
                      hintText: 'Alles durchsuchen …',
                      hintStyle: TextStyle(color: tc.withOpacity(0.5)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              if (_q.trim().length >= 2)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('${treffer.length} Treffer',
                        style: TextStyle(
                            color: tc.withOpacity(0.6), fontSize: 12)),
                  ),
                ),
              Expanded(
                child: treffer.isEmpty
                    ? Center(
                        child: Text(
                            _q.trim().length < 2
                                ? 'Gib mindestens 2 Buchstaben ein.'
                                : 'Nichts gefunden.',
                            style: TextStyle(color: tc.withOpacity(0.6))),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                        itemCount: treffer.length,
                        itemBuilder: (context, i) {
                          final t = treffer[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GlassCard(
                              padding: const EdgeInsets.all(12),
                              onTap: t.oeffnen,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.emoji,
                                      style: const TextStyle(fontSize: 22)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(t.titel,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: tc,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 14.5)),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: ZfaTheme.blau
                                                    .withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(t.typ,
                                                  style: const TextStyle(
                                                      color: ZfaTheme.hellblau,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(t.text,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: tc.withOpacity(0.7),
                                                fontSize: 13,
                                                height: 1.35)),
                                      ],
                                    ),
                                  ),
                                  if (t.typ != 'Ablauf')
                                    TtsButton(
                                        text: '${t.titel}. ${t.text}',
                                        farbe: ZfaTheme.hellblau)
                                  else
                                    Icon(Icons.chevron_right,
                                        color: tc.withOpacity(0.5)),
                                ],
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
