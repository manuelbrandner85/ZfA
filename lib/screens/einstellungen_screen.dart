import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../theme/zfa_theme.dart';
import 'splash_screen.dart';

class EinstellungenScreen extends StatefulWidget {
  const EinstellungenScreen({super.key});

  @override
  State<EinstellungenScreen> createState() => _EinstellungenScreenState();
}

class _EinstellungenScreenState extends State<EinstellungenScreen> {
  late final TextEditingController _name =
      TextEditingController(text: einstellungenService.name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _zuruecksetzen() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Fortschritt zurücksetzen?'),
        content: const Text(
            'Alle Punkte, Streaks, Statistiken und eigenen Karten werden gelöscht. Das kann nicht rückgängig gemacht werden.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: ZfaTheme.rot,
                foregroundColor: Colors.white,
                minimumSize: const Size(120, 44)),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final p = await SharedPreferences.getInstance();
    await p.clear();
    await fortschrittService.laden();
    await eigeneKartenService.laden();
    await einstellungenService.laden();
    await soundService.initialisieren();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    final dunkel = Theme.of(context).brightness == Brightness.dark;
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
                  Text('Einstellungen',
                      style: Theme.of(context).textTheme.titleLarge),
                ]),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: [
                    _Abschnitt('Profil', tc),
                    GlassCard(
                      child: TextField(
                        controller: _name,
                        style: TextStyle(color: tc),
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: tc.withOpacity(0.6)),
                          border: InputBorder.none,
                        ),
                        onChanged: (v) => einstellungenService.nameSetzen(v),
                      ),
                    ),
                    const SizedBox(height: 18),

                    _Abschnitt('Darstellung', tc),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Zeile(
                            tc: tc,
                            icon: dunkel
                                ? Icons.dark_mode
                                : Icons.light_mode,
                            titel: 'Dunkles Design',
                            trailing: Switch(
                              value: dunkel,
                              onChanged: (_) => themeController.umschalten(),
                            ),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Textgröße',
                                    style: TextStyle(
                                        color: tc,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 8),
                                ValueListenableBuilder<double>(
                                  valueListenable:
                                      einstellungenService.textSkala,
                                  builder: (context, skala, _) => Wrap(
                                    spacing: 8,
                                    children: [
                                      _skalaChip('Normal', 1.0, skala, tc),
                                      _skalaChip('Groß', 1.2, skala, tc),
                                      _skalaChip('Sehr groß', 1.4, skala, tc),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    _Abschnitt('Lernen & Prüfung', tc),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Zeile(
                            tc: tc,
                            icon: Icons.volume_up,
                            titel: 'Sounds',
                            trailing: Switch(
                              value: soundService.aktiv,
                              onChanged: (v) async {
                                await soundService.umschalten(v);
                                setState(() {});
                              },
                            ),
                          ),
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          Text('Tagesziel: ${fortschrittService.tagesziel} Aufgaben',
                              style: TextStyle(
                                  color: tc, fontWeight: FontWeight.w700)),
                          Slider(
                            value: fortschrittService.tagesziel.toDouble(),
                            min: 3,
                            max: 30,
                            divisions: 27,
                            label: '${fortschrittService.tagesziel}',
                            activeColor: ZfaTheme.gold,
                            onChanged: (v) => setState(
                                () => fortschrittService.tagesziel = v.round()),
                            onChangeEnd: (v) => fortschrittService
                                .readinessSnapshot(), // speichert
                          ),
                          const SizedBox(height: 4),
                          Text(
                              'Bestehensgrenze: ${einstellungenService.bestehensGrenze} %',
                              style: TextStyle(
                                  color: tc, fontWeight: FontWeight.w700)),
                          Text(
                              'Ab wie viel Prozent gilt eine Prüfung als bestanden.',
                              style: TextStyle(
                                  color: tc.withOpacity(0.6), fontSize: 12)),
                          Slider(
                            value:
                                einstellungenService.bestehensGrenze.toDouble(),
                            min: 40,
                            max: 80,
                            divisions: 40,
                            label: '${einstellungenService.bestehensGrenze} %',
                            activeColor: ZfaTheme.blau,
                            onChanged: (v) => setState(() =>
                                einstellungenService.bestehensGrenze =
                                    v.round()),
                            onChangeEnd: (v) => einstellungenService
                                .bestehensGrenzeSetzen(v.round()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    _Abschnitt('Daten', tc),
                    GlassCard(
                      onTap: _zuruecksetzen,
                      child: Row(
                        children: [
                          const Icon(Icons.delete_forever,
                              color: ZfaTheme.rot),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Fortschritt zurücksetzen',
                                style: TextStyle(
                                    color: tc,
                                    fontWeight: FontWeight.w700)),
                          ),
                          Icon(Icons.chevron_right, color: tc.withOpacity(0.5)),
                        ],
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

  Widget _skalaChip(String label, double wert, double aktuell, Color tc) {
    final aktiv = (aktuell - wert).abs() < 0.01;
    return ChoiceChip(
      label: Text(label),
      selected: aktiv,
      onSelected: (_) => einstellungenService.textSkalaSetzen(wert),
      selectedColor: ZfaTheme.blau,
      labelStyle: TextStyle(
          color: aktiv ? Colors.white : tc, fontWeight: FontWeight.w600),
    );
  }
}

class _Abschnitt extends StatelessWidget {
  final String titel;
  final Color tc;
  const _Abschnitt(this.titel, this.tc);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(titel,
            style: TextStyle(
                color: tc.withOpacity(0.6),
                fontSize: 13,
                fontWeight: FontWeight.w800)),
      );
}

class _Zeile extends StatelessWidget {
  final Color tc;
  final IconData icon;
  final String titel;
  final Widget trailing;
  const _Zeile(
      {required this.tc,
      required this.icon,
      required this.titel,
      required this.trailing});
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: tc),
          const SizedBox(width: 12),
          Expanded(
              child: Text(titel,
                  style:
                      TextStyle(color: tc, fontWeight: FontWeight.w700))),
          trailing,
        ],
      );
}
