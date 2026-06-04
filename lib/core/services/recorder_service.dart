import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

/// Nimmt eine kurze Sprachaufnahme auf (zum eigenen Anhören) und spielt sie ab.
/// Unabhängig von der Spracherkennung (nicht gleichzeitig nutzen – ein Mikro).
class RecorderService {
  final AudioRecorder _rec = AudioRecorder();
  final AudioPlayer _player = AudioPlayer(playerId: 'zfa_vortrag');
  String? _pfad;
  bool laeuft = false;

  bool get hatAufnahme => _pfad != null;

  Future<bool> start() async {
    if (!await _rec.hasPermission()) return false;
    final dir = await getTemporaryDirectory();
    final pfad = '${dir.path}/vortrag.m4a';
    await _rec.start(const RecordConfig(), path: pfad);
    _pfad = pfad;
    laeuft = true;
    return true;
  }

  Future<void> stop() async {
    final p = await _rec.stop();
    if (p != null) _pfad = p;
    laeuft = false;
  }

  Future<void> abspielen() async {
    if (_pfad == null) return;
    await _player.stop();
    await _player.play(DeviceFileSource(_pfad!));
  }

  Future<void> stopAbspielen() async => _player.stop();

  Future<void> freigeben() async {
    try {
      if (laeuft) await _rec.stop();
    } catch (_) {}
    await _rec.dispose();
    await _player.dispose();
  }
}
