import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/services/tts_service.dart';
import 'core/services/fortschritt_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/sound_service.dart';
import 'core/services/eigene_karten_service.dart';
import 'theme/theme_controller.dart';
import 'theme/zfa_theme.dart';
import 'screens/splash_screen.dart';

// Globaler TTS Service - überall erreichbar
final TtsService ttsService = TtsService();
// Globaler Fortschritt - überall erreichbar
final FortschrittService fortschrittService = FortschrittService();
// Globale Erinnerungen (tägliche Lern-Benachrichtigung)
final NotificationService notificationService = NotificationService();
// Globaler Theme-Umschalter (dunkel/hell)
final ThemeController themeController = ThemeController();
// Globale, abschaltbare UI-Klänge
final SoundService soundService = SoundService();
// Eigene, vom Nutzer angelegte Karteikarten
final EigeneKartenService eigeneKartenService = EigeneKartenService();
// Globaler Audio-Zustand für Mini-Player
final ValueNotifier<AudioZustand?> aktuellerAudio = ValueNotifier(null);

class AudioZustand {
  final String kapitelEmoji;
  final String kapitelTitel;
  final bool laeuft;
  final double fortschritt;
  AudioZustand({
    required this.kapitelEmoji,
    required this.kapitelTitel,
    required this.laeuft,
    required this.fortschritt,
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Nur Hochformat erlauben
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await ttsService.initialisieren();
  await fortschrittService.laden();
  await notificationService.initialisieren();
  await themeController.laden();
  await soundService.initialisieren();
  await eigeneKartenService.laden();
  runApp(const ZFALernApp());
}

class ZFALernApp extends StatelessWidget {
  const ZFALernApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController.mode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'ZFA Lernapp',
          debugShowCheckedModeBanner: false,
          theme: ZfaTheme.light(),
          darkTheme: ZfaTheme.dark(),
          themeMode: mode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
