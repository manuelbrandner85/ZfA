import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/services/tts_service.dart';
import 'core/services/fortschritt_service.dart';
import 'screens/splash_screen.dart';

// Globaler TTS Service - überall erreichbar
final TtsService ttsService = TtsService();
// Globaler Fortschritt - überall erreichbar
final FortschrittService fortschrittService = FortschrittService();
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
  runApp(const ZFALernApp());
}

class ZFALernApp extends StatelessWidget {
  const ZFALernApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZFA Lernapp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.nunitoTextTheme().copyWith(
          bodyLarge: GoogleFonts.nunito(
            fontSize: 17,
            height: 1.7,
            letterSpacing: 0.3,
          ),
          bodyMedium: GoogleFonts.nunito(
            fontSize: 15,
            height: 1.6,
          ),
          titleLarge: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F4FF),
        cardTheme: CardTheme(
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: GoogleFonts.nunito(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
