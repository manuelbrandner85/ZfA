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
    // Etwas natürlicher als ganz langsam – wirkt weniger roboterhaft.
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    // Wichtig für sauberes Satz-für-Satz-Vorlesen (Karaoke).
    await _tts.awaitSpeakCompletion(true);

    // Beste verfügbare deutsche Stimme wählen (klingt realistischer).
    await _besteStimmeWaehlen();

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

  // Sucht aus den installierten Stimmen die natürlichste deutsche Stimme.
  // Bevorzugt hochwertige (network/neural) Stimmen, fällt sonst auf eine
  // beliebige de-DE-Stimme zurück. Schlägt das fehl, bleibt die Standardstimme.
  Future<void> _besteStimmeWaehlen() async {
    try {
      final dynamic voices = await _tts.getVoices;
      if (voices is! List) return;
      final deutsche = voices
          .whereType<Map>()
          .map((v) => v.map((k, val) => MapEntry(k.toString(), val.toString())))
          .where((v) => (v['locale'] ?? '').toLowerCase().startsWith('de'))
          .toList();
      if (deutsche.isEmpty) return;

      int bewerten(Map<String, String> v) {
        final name = (v['name'] ?? '').toLowerCase();
        int score = 0;
        if (name.contains('neural')) score += 5;
        if (name.contains('network')) score += 4;
        if (name.contains('enhanced') || name.contains('premium')) score += 3;
        if (name.contains('wavenet')) score += 5;
        // de-DE exakt bevorzugen
        if ((v['locale'] ?? '').toLowerCase() == 'de-de') score += 2;
        return score;
      }

      deutsche.sort((a, b) => bewerten(b).compareTo(bewerten(a)));
      final beste = deutsche.first;
      await _tts.setVoice({
        'name': beste['name'] ?? '',
        'locale': beste['locale'] ?? 'de-DE',
      });
    } catch (_) {
      // Stimme bleibt Standard – kein Abbruch.
    }
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
