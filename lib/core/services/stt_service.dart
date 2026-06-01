import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SttService {
  final SpeechToText _stt = SpeechToText();
  bool _initialisiert = false;
  bool istAktiv = false;

  String erkannterText = '';
  Function(String)? onTextAendert;
  Function(bool)? onAktivAendert;

  Future<bool> initialisieren() async {
    // Permission anfragen
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) return false;

    _initialisiert = await _stt.initialize(
      onError: (e) {
        istAktiv = false;
        onAktivAendert?.call(false);
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          istAktiv = false;
          onAktivAendert?.call(false);
        }
      },
    );
    return _initialisiert;
  }

  Future<void> starteZuhoeren() async {
    if (!_initialisiert) {
      final ok = await initialisieren();
      if (!ok) return;
    }
    istAktiv = true;
    erkannterText = '';
    onAktivAendert?.call(true);

    await _stt.listen(
      onResult: (result) {
        erkannterText = result.recognizedWords;
        onTextAendert?.call(erkannterText);
      },
      listenOptions: SpeechListenOptions(
        localeId: 'de_DE',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
        listenMode: ListenMode.dictation,
        partialResults: true,
      ),
    );
  }

  Future<String> stoppeUndGibText() async {
    await _stt.stop();
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
