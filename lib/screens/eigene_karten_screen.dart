import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flip_card/flip_card.dart';
import '../main.dart';
import '../theme/zfa_theme.dart';
import '../models/lernkarte.dart';

class EigeneKartenScreen extends StatefulWidget {
  const EigeneKartenScreen({super.key});

  @override
  State<EigeneKartenScreen> createState() => _EigeneKartenScreenState();
}

class _EigeneKartenScreenState extends State<EigeneKartenScreen> {
  Future<void> _neueKarte() async {
    final vorder = TextEditingController();
    final rueck = TextEditingController();
    final einfach = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Neue Karte'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: vorder,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'Begriff / Frage (Vorderseite)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: rueck,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'Antwort (Rückseite)'),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: einfach,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'Einfach erklärt (optional)'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(minimumSize: const Size(110, 44)),
              child: const Text('Speichern')),
        ],
      ),
    );
    if (ok == true &&
        vorder.text.trim().isNotEmpty &&
        rueck.text.trim().isNotEmpty) {
      await eigeneKartenService.hinzufuegen(
          vorder.text, rueck.text, einfach.text);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    final karten = eigeneKartenService.karten;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _neueKarte,
        backgroundColor: ZfaTheme.blau,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Neue Karte',
            style: TextStyle(color: Colors.white)),
      ),
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
                      child: Text('Meine Karten',
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                    if (karten.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  _LernModus(karten: List.of(karten))),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Lernen'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: karten.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⭐', style: TextStyle(fontSize: 56)),
                              const SizedBox(height: 12),
                              Text(
                                'Lege eigene Karten an – für deine kniffligen Begriffe.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: tc.withOpacity(0.7), fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                        itemCount: karten.length,
                        itemBuilder: (context, i) {
                          final k = karten[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GlassCard(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(k.vorderseite,
                                            style: TextStyle(
                                                color: tc,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16)),
                                        const SizedBox(height: 2),
                                        Text(k.rueckseite,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: tc.withOpacity(0.65),
                                                fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline,
                                        color: ZfaTheme.rot.withOpacity(0.8)),
                                    onPressed: () async {
                                      HapticFeedback.lightImpact();
                                      await eigeneKartenService
                                          .loeschen(k.id);
                                      setState(() {});
                                    },
                                  ),
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

class _LernModus extends StatefulWidget {
  final List<Lernkarte> karten;
  const _LernModus({required this.karten});

  @override
  State<_LernModus> createState() => _LernModusState();
}

class _LernModusState extends State<_LernModus> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    final k = widget.karten[_index];
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
                    Text('Karte ${_index + 1}/${widget.karten.length}',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: FlipCard(
                    key: ValueKey(k.id),
                    direction: FlipDirection.HORIZONTAL,
                    front: _Seite(
                      gradient: ZfaTheme.blauGrad,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(k.vorderseite,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 16),
                          const Text('Tippen zum Umdrehen 👆',
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                    back: _Seite(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFF7FAFF), Color(0xFFE6EEFB)]),
                      child: Center(
                        child: Text(k.rueckseite,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Color(0xFF0E1430),
                                fontSize: 20,
                                height: 1.4,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _index > 0
                            ? () => setState(() => _index--)
                            : null,
                        child: const Text('Zurück'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _index < widget.karten.length - 1
                            ? () => setState(() => _index++)
                            : () => Navigator.pop(context),
                        child: Text(_index < widget.karten.length - 1
                            ? 'Weiter →'
                            : 'Fertig'),
                      ),
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

class _Seite extends StatelessWidget {
  final Gradient gradient;
  final Widget child;
  const _Seite({required this.gradient, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 22,
              offset: const Offset(0, 10)),
        ],
      ),
      child: child,
    );
  }
}
