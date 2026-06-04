import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../theme/zfa_theme.dart';
import '../widgets/lern_buddy.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  final _name = TextEditingController();
  int _tagesziel = 10;
  DateTime? _pruefung;
  int _seite = 0;

  Future<void> _fertig() async {
    await einstellungenService.nameSetzen(_name.text);
    fortschrittService.tagesziel = _tagesziel;
    if (_pruefung != null) {
      await fortschrittService.pruefungsDatumSetzen(_pruefung);
    }
    await fortschrittService.readinessSnapshot(); // speichert auch tagesziel
    await einstellungenService.onboardingAbschliessen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _weiter() {
    if (_seite < 2) {
      _page.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _fertig();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              const LernBuddy(stimmung: BuddyStimmung.freude, groesse: 96),
              Expanded(
                child: PageView(
                  controller: _page,
                  onPageChanged: (i) => setState(() => _seite = i),
                  children: [
                    // 1) Name
                    _Schritt(
                      titel: 'Hi! Wie heißt du?',
                      text: 'Damit dich Zahni persönlich begrüßen kann.',
                      child: TextField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: tc,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                        decoration: const InputDecoration(
                          hintText: 'Dein Name (optional)',
                        ),
                      ),
                    ),
                    // 2) Prüfungstermin
                    _Schritt(
                      titel: 'Wann ist deine Prüfung?',
                      text: 'Die App zeigt dir dann einen Countdown.',
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              final jetzt = DateTime.now();
                              final d = await showDatePicker(
                                context: context,
                                initialDate:
                                    jetzt.add(const Duration(days: 30)),
                                firstDate: jetzt,
                                lastDate:
                                    jetzt.add(const Duration(days: 730)),
                              );
                              if (d != null) setState(() => _pruefung = d);
                            },
                            icon: const Icon(Icons.calendar_month),
                            label: Text(_pruefung == null
                                ? 'Termin wählen'
                                : '${_pruefung!.day}.${_pruefung!.month}.${_pruefung!.year}'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: ZfaTheme.blau,
                                foregroundColor: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text('Kannst du später jederzeit ändern.',
                              style: TextStyle(
                                  color: tc.withOpacity(0.6), fontSize: 12)),
                        ],
                      ),
                    ),
                    // 3) Tagesziel
                    _Schritt(
                      titel: 'Dein Tagesziel',
                      text: 'Wie viele Aufgaben pro Tag? Schon wenige helfen!',
                      child: Wrap(
                        spacing: 10,
                        alignment: WrapAlignment.center,
                        children: [5, 10, 15, 20].map((n) {
                          final aktiv = _tagesziel == n;
                          return ChoiceChip(
                            label: Text('$n'),
                            selected: aktiv,
                            onSelected: (_) =>
                                setState(() => _tagesziel = n),
                            selectedColor: ZfaTheme.gold,
                            labelStyle: TextStyle(
                                color: aktiv ? Colors.black87 : tc,
                                fontWeight: FontWeight.w700),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              // Punkte-Indikator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    3,
                    (i) => Container(
                          width: 9,
                          height: 9,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _seite
                                ? ZfaTheme.gold
                                : tc.withOpacity(0.25),
                          ),
                        )),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _weiter();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ZfaTheme.blau,
                        foregroundColor: Colors.white),
                    child: Text(_seite < 2 ? 'Weiter' : 'Los geht\'s! 🚀'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Schritt extends StatelessWidget {
  final String titel;
  final String text;
  final Widget child;
  const _Schritt(
      {required this.titel, required this.text, required this.child});

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(titel,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10),
          Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(color: tc.withOpacity(0.7), fontSize: 15)),
          const SizedBox(height: 28),
          child,
        ],
      ),
    );
  }
}
