import 'package:flutter_tts/flutter_tts.dart';

enum TtsZustand { gestoppt, laedt, spricht, pausiert }

class TtsService {
  final FlutterTts _tts = FlutterTts();
  TtsZustand zustand = TtsZustand.gestoppt;
  Function(TtsZustand)? onZustandAendert;

  // AKTUELL GESPROCHENER SATZ für Karaoke-Highlight
  Function(int satzIndex)? onSatzAendert;
  List<String> _aktuelleSaetze = [];
  int _aktuellerSatzIndex = 0;

  Future<void> initialisieren() async {
    await _tts.setLanguage('de-DE');
    await _tts.setSpeechRate(0.45); // Langsam für besseres Verstehen!
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      zustand = TtsZustand.spricht;
      onZustandAendert?.call(zustand);
    });

    _tts.setCompletionHandler(() {
      zustand = TtsZustand.gestoppt;
      onZustandAendert?.call(zustand);
      _aktuellerSatzIndex = 0;
    });

    _tts.setErrorHandler((msg) {
      zustand = TtsZustand.gestoppt;
      onZustandAendert?.call(zustand);
    });
  }

  // Einfaches Vorlesen eines kurzen Textes
  Future<void> sprechen(String text) async {
    await stoppen();
    zustand = TtsZustand.laedt;
    onZustandAendert?.call(zustand);
    await _tts.speak(text);
  }

  // Hörbuch-Modus: Satz für Satz mit Karaoke-Highlight
  Future<void> kapitelVorlesen(List<String> saetze, {int startIndex = 0}) async {
    await stoppen();
    _aktuelleSaetze = saetze;
    _aktuellerSatzIndex = startIndex.clamp(0, saetze.length);
    await _naechstenSatzSprechen();
  }

  Future<void> _naechstenSatzSprechen() async {
    if (_aktuellerSatzIndex >= _aktuelleSaetze.length) {
      zustand = TtsZustand.gestoppt;
      onZustandAendert?.call(zustand);
      // Standard-Handler wiederherstellen
      _tts.setCompletionHandler(() {
        zustand = TtsZustand.gestoppt;
        onZustandAendert?.call(zustand);
        _aktuellerSatzIndex = 0;
      });
      return;
    }
    onSatzAendert?.call(_aktuellerSatzIndex);
    zustand = TtsZustand.spricht;
    onZustandAendert?.call(zustand);
    _tts.setCompletionHandler(() async {
      _aktuellerSatzIndex++;
      await Future.delayed(const Duration(milliseconds: 300));
      await _naechstenSatzSprechen();
    });
    await _tts.speak(_aktuelleSaetze[_aktuellerSatzIndex]);
  }

  // Direkt zu einem bestimmten Satz springen (für Vor/Zurück)
  Future<void> zuSatzSpringen(int index) async {
    if (_aktuelleSaetze.isEmpty) return;
    _aktuellerSatzIndex = index.clamp(0, _aktuelleSaetze.length - 1);
    await _tts.stop();
    await _naechstenSatzSprechen();
  }

  int get aktuellerSatzIndex => _aktuellerSatzIndex;

  Future<void> stoppen() async {
    await _tts.stop();
    zustand = TtsZustand.gestoppt;
    _aktuellerSatzIndex = 0;
    onZustandAendert?.call(zustand);
  }

  Future<void> geschwindigkeitSetzen(double rate) async {
    await _tts.setSpeechRate(rate);
  }

  bool get istAktiv =>
      zustand == TtsZustand.spricht || zustand == TtsZustand.laedt;
}
