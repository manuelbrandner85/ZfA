import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SttService {
  final SpeechToText _stt = SpeechToText();
  bool _initialisiert = false;
  bool istAktiv = false;

  String erkannterText = '';
  Function(String)? onTextAendert;
  Function(bool)? onAktivAendert;

  // Kontinuierliches Diktat: lauscht durchgehend und sammelt den Text,
  // bis der Nutzer selbst stoppt (für lange Erklärungen).
  bool _kontinuierlich = false;
  bool _gewollt = false; // Nutzer möchte weiter aufnehmen
  String _basis = ''; // bereits abgeschlossene Sessions
  String _aktuelleSession = '';

  Future<bool> initialisieren() async {
    // Permission anfragen
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) return false;

    _initialisiert = await _stt.initialize(
      onError: (e) {
        if (_kontinuierlich && _gewollt) {
          _neustart();
        } else {
          istAktiv = false;
          onAktivAendert?.call(false);
        }
      },
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          if (_kontinuierlich && _gewollt) {
            _neustart(); // weiter zuhören
          } else {
            istAktiv = false;
            onAktivAendert?.call(false);
          }
        }
      },
    );
    return _initialisiert;
  }

  Future<void> starteZuhoeren({bool kontinuierlich = false}) async {
    if (!_initialisiert) {
      final ok = await initialisieren();
      if (!ok) return;
    }
    _kontinuierlich = kontinuierlich;
    _gewollt = true;
    _basis = '';
    _aktuelleSession = '';
    erkannterText = '';
    istAktiv = true;
    onAktivAendert?.call(true);
    await _starteSession();
  }

  Future<void> _starteSession() async {
    _aktuelleSession = '';
    try {
      await _stt.listen(
        onResult: (result) {
          _aktuelleSession = result.recognizedWords;
          final ganz = (_basis.isEmpty
                  ? _aktuelleSession
                  : '$_basis $_aktuelleSession')
              .trim();
          erkannterText = ganz;
          onTextAendert?.call(erkannterText);
        },
        listenOptions: SpeechListenOptions(
          localeId: 'de_DE',
          // Lange Sessions; bei Pausen wird automatisch neu gestartet.
          listenFor: Duration(minutes: _kontinuierlich ? 5 : 1),
          pauseFor: Duration(seconds: _kontinuierlich ? 12 : 4),
          listenMode: ListenMode.dictation,
          partialResults: true,
          cancelOnError: false,
        ),
      );
    } catch (_) {
      // Falls listen fehlschlägt (z. B. noch aktiv): kurz warten, neu versuchen.
      if (_kontinuierlich && _gewollt) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (_gewollt) await _starteSession();
      }
    }
  }

  Future<void> _neustart() async {
    // Abgeschlossene Session an die Basis anhängen, damit nichts verloren geht.
    if (_aktuelleSession.trim().isNotEmpty) {
      _basis =
          (_basis.isEmpty ? _aktuelleSession : '$_basis $_aktuelleSession')
              .trim();
      _aktuelleSession = '';
    }
    await Future.delayed(const Duration(milliseconds: 150));
    if (_gewollt) {
      await _starteSession();
    } else {
      istAktiv = false;
      onAktivAendert?.call(false);
    }
  }

  Future<String> stoppeUndGibText() async {
    _gewollt = false;
    _kontinuierlich = false;
    try {
      await _stt.stop();
    } catch (_) {}
    istAktiv = false;
    onAktivAendert?.call(false);
    return erkannterText;
  }

  // Prüft ob genug Schlüsselwörter in der Antwort sind
  bool pruefeAntwort(String gesprochenerText, List<String> schluessel) {
    final kleingeschrieben = gesprochenerText.toLowerCase();
    int treffer = 0;
    for (final wort in schluessel) {
      if (kleingeschrieben.contains(wort.toLowerCase())) {
        treffer++;
      }
    }
    // Mind. 1 Schlüsselwort muss passen
    return treffer >= 1;
  }

  bool get verfuegbar => _initialisiert;
}
