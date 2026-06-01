import 'package:shared_preferences/shared_preferences.dart';
import '../../models/lernkarte.dart';

/// Speichert selbst angelegte Karteikarten dauerhaft.
class EigeneKartenService {
  static const _sep = '';
  List<Lernkarte> karten = [];

  Future<void> laden() async {
    final prefs = await SharedPreferences.getInstance();
    karten = (prefs.getStringList('eigene_karten') ?? []).map((e) {
      final t = e.split(_sep);
      return Lernkarte(
        id: t[0],
        vorderseite: t.length > 1 ? t[1] : '',
        rueckseite: t.length > 2 ? t[2] : '',
        einfachVersion: t.length > 3 ? t[3] : '',
        emoji: '⭐',
        bereich: 'Eigene',
      );
    }).toList();
  }

  Future<void> hinzufuegen(
      String vorder, String rueck, String einfach) async {
    karten.add(Lernkarte(
      id: 'eigen_${DateTime.now().millisecondsSinceEpoch}',
      vorderseite: vorder.trim(),
      rueckseite: rueck.trim(),
      einfachVersion: einfach.trim().isEmpty ? rueck.trim() : einfach.trim(),
      emoji: '⭐',
      bereich: 'Eigene',
    ));
    await _speichern();
  }

  Future<void> loeschen(String id) async {
    karten.removeWhere((k) => k.id == id);
    await _speichern();
  }

  Future<void> _speichern() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'eigene_karten',
      karten
          .map((k) =>
              [k.id, k.vorderseite, k.rueckseite, k.einfachVersion].join(_sep))
          .toList(),
    );
  }
}
