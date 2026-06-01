import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Spielt kurze, dezente UI-Klänge. Lässt sich abschalten.
class SoundService {
  final AudioPlayer _player = AudioPlayer(playerId: 'zfa_ui');
  bool aktiv = true;

  Future<void> initialisieren() async {
    final prefs = await SharedPreferences.getInstance();
    aktiv = prefs.getBool('sound_aktiv') ?? true;
    await _player.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> umschalten(bool wert) async {
    aktiv = wert;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_aktiv', wert);
  }

  Future<void> _spiele(String datei) async {
    if (!aktiv) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/$datei.wav'), volume: 0.7);
    } catch (_) {
      // Tonausgabe ist optional – Fehler ignorieren.
    }
  }

  Future<void> richtig() => _spiele('richtig');
  Future<void> falsch() => _spiele('falsch');
  Future<void> tap() => _spiele('tap');
  Future<void> levelUp() => _spiele('level');
}
