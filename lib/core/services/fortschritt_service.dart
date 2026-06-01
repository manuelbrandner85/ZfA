import 'package:shared_preferences/shared_preferences.dart';

class FortschrittService {
  late SharedPreferences _prefs;

  // Gelöste Quiz-IDs
  Set<String> geloesteFragen = {};
  // Spaced Repetition: frage_id -> wann nächste Wiederholung (Unix-Timestamp)
  Map<String, int> wiederholungsZeiten = {};
  // Leitner-Box Level: frage_id -> Box 1-5
  Map<String, int> leitnerBoxen = {};
  // Tagesstreak
  int streak = 0;
  int gesamtPunkte = 0;
  // Hörbuch-Fortschritt: kapitel_id -> letzter Satz-Index
  Map<String, int> hoerbuchFortschritt = {};
  // Pro Bereich: wie viele richtig / wie viele insgesamt beantwortet
  Map<String, int> bereichRichtig = {};
  Map<String, int> bereichGesamt = {};

  // --- Tagesziel & Gewohnheit ---
  int tagesziel = 10; // Aufgaben pro Tag
  int aufgabenHeute = 0;
  String _lernTag = ''; // yyyymmdd des laufenden Zähltags
  String _zielErreichtTag = ''; // yyyymmdd, an dem das Ziel zuletzt erreicht wurde
  // Prüfungstermin (ISO yyyy-MM-dd) – optional
  String? pruefungsDatum;

  String _tagSchluessel(DateTime d) =>
      '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

  void _tagPruefen() {
    final heute = _tagSchluessel(DateTime.now());
    if (_lernTag != heute) {
      _lernTag = heute;
      aufgabenHeute = 0;
    }
  }

  double get tageszielFortschritt {
    if (tagesziel <= 0) return 1;
    return (aufgabenHeute / tagesziel).clamp(0.0, 1.0);
  }

  bool get tageszielErreicht => aufgabenHeute >= tagesziel;

  Future<void> laden() async {
    _prefs = await SharedPreferences.getInstance();
    geloesteFragen = (_prefs.getStringList('geloest') ?? []).toSet();
    gesamtPunkte = _prefs.getInt('punkte') ?? 0;
    streak = _prefs.getInt('streak') ?? 0;

    final boxDaten = _prefs.getStringList('leitner') ?? [];
    for (final eintrag in boxDaten) {
      final teile = eintrag.split(':');
      if (teile.length == 2) {
        leitnerBoxen[teile[0]] = int.tryParse(teile[1]) ?? 1;
      }
    }

    final zeitDaten = _prefs.getStringList('wiederholung') ?? [];
    for (final eintrag in zeitDaten) {
      final teile = eintrag.split(':');
      if (teile.length == 2) {
        wiederholungsZeiten[teile[0]] = int.tryParse(teile[1]) ?? 0;
      }
    }

    final hoerDaten = _prefs.getStringList('hoerbuch') ?? [];
    for (final eintrag in hoerDaten) {
      final teile = eintrag.split(':');
      if (teile.length == 2) {
        hoerbuchFortschritt[teile[0]] = int.tryParse(teile[1]) ?? 0;
      }
    }

    final richtigDaten = _prefs.getStringList('bereich_richtig') ?? [];
    for (final eintrag in richtigDaten) {
      final teile = eintrag.split('::');
      if (teile.length == 2) {
        bereichRichtig[teile[0]] = int.tryParse(teile[1]) ?? 0;
      }
    }
    final gesamtDaten = _prefs.getStringList('bereich_gesamt') ?? [];
    for (final eintrag in gesamtDaten) {
      final teile = eintrag.split('::');
      if (teile.length == 2) {
        bereichGesamt[teile[0]] = int.tryParse(teile[1]) ?? 0;
      }
    }

    // Tagesziel & Prüfungstermin
    tagesziel = _prefs.getInt('tagesziel') ?? 10;
    aufgabenHeute = _prefs.getInt('aufgaben_heute') ?? 0;
    _lernTag = _prefs.getString('lern_tag') ?? '';
    _zielErreichtTag = _prefs.getString('ziel_tag') ?? '';
    pruefungsDatum = _prefs.getString('pruefungsdatum');
    _tagPruefen(); // ggf. Tageszähler zurücksetzen
  }

  // Zählt eine erledigte Aufgabe für das Tagesziel und pflegt den Streak.
  void _aufgabeGezaehlt() {
    _tagPruefen();
    aufgabenHeute++;
    if (aufgabenHeute == tagesziel) {
      final heute = _tagSchluessel(DateTime.now());
      final gestern = _tagSchluessel(
          DateTime.now().subtract(const Duration(days: 1)));
      if (_zielErreichtTag == gestern) {
        streak++; // Tag an Tag fortgesetzt
      } else if (_zielErreichtTag != heute) {
        streak = 1; // neuer Streak beginnt
      }
      _zielErreichtTag = heute;
    }
  }

  Future<void> frageRichtigBeantwortet(String frageId, {String? bereich}) async {
    geloesteFragen.add(frageId);
    gesamtPunkte += 10;
    // Leitner: Eine Box höher (max. Box 5)
    final aktuelleBox = leitnerBoxen[frageId] ?? 1;
    leitnerBoxen[frageId] = (aktuelleBox + 1).clamp(1, 5);
    wiederholungsZeiten[frageId] = DateTime.now().millisecondsSinceEpoch;
    if (bereich != null) {
      bereichRichtig[bereich] = (bereichRichtig[bereich] ?? 0) + 1;
      bereichGesamt[bereich] = (bereichGesamt[bereich] ?? 0) + 1;
    }
    _aufgabeGezaehlt();
    await _speichern();
  }

  Future<void> frageFalschBeantwortet(String frageId, {String? bereich}) async {
    // Leitner: Zurück zu Box 1!
    leitnerBoxen[frageId] = 1;
    wiederholungsZeiten[frageId] = DateTime.now().millisecondsSinceEpoch;
    if (bereich != null) {
      bereichGesamt[bereich] = (bereichGesamt[bereich] ?? 0) + 1;
    }
    _aufgabeGezaehlt();
    await _speichern();
  }

  // --- Prüfungstermin ---
  Future<void> pruefungsDatumSetzen(DateTime? datum) async {
    pruefungsDatum = datum == null
        ? null
        : '${datum.year}-${datum.month.toString().padLeft(2, '0')}-${datum.day.toString().padLeft(2, '0')}';
    await _speichern();
  }

  int? tageBisPruefung() {
    if (pruefungsDatum == null) return null;
    final ziel = DateTime.tryParse(pruefungsDatum!);
    if (ziel == null) return null;
    final heute = DateTime.now();
    final differenz = DateTime(ziel.year, ziel.month, ziel.day)
        .difference(DateTime(heute.year, heute.month, heute.day))
        .inDays;
    return differenz;
  }

  // Welche Fragen JETZT wiederholen? (Spaced Repetition)
  List<String> fragenFuerHeute(List<String> alleFrageIds) {
    final faellig = alleFrageIds.where((id) {
      final box = leitnerBoxen[id] ?? 1;
      // Box 1: täglich, Box 2: alle 2 Tage, Box 3: alle 4 Tage, etc.
      final intervall = [1, 2, 4, 8, 16][box - 1];
      final letzteWiederholung = wiederholungsZeiten[id] ?? 0;
      final tageSeit =
          (DateTime.now().millisecondsSinceEpoch - letzteWiederholung) ~/
              (1000 * 60 * 60 * 24);
      return tageSeit >= intervall;
    }).toList();
    // Wenn nichts fällig ist, gib trotzdem alle zurück (immer lernen können!)
    return faellig.isEmpty ? alleFrageIds : faellig;
  }

  // Wie viele Karten/Fragen in jeder Leitner-Box?
  Map<int, int> leitnerVerteilung(List<String> alleIds) {
    final verteilung = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final id in alleIds) {
      final box = leitnerBoxen[id] ?? 1;
      verteilung[box] = (verteilung[box] ?? 0) + 1;
    }
    return verteilung;
  }

  // Erfolgsquote pro Bereich (0.0 - 1.0)
  double bereichQuote(String bereich) {
    final gesamt = bereichGesamt[bereich] ?? 0;
    if (gesamt == 0) return 0.0;
    return (bereichRichtig[bereich] ?? 0) / gesamt;
  }

  // Schwächster Bereich für "Heute lernen" Empfehlung
  String schwaechsterBereich() {
    const bereiche = [
      'Anmeldung',
      'Hygiene',
      'Behandlungsassistenz',
      'Anästhesie',
      'Chirurgie',
      'Karies',
      'Parodontitis',
    ];
    String schwaechster = bereiche.first;
    double niedrigsteQuote = 2.0;
    for (final b in bereiche) {
      final gesamt = bereichGesamt[b] ?? 0;
      // Noch nie gelernte Bereiche haben höchste Priorität
      final quote = gesamt == 0 ? -1.0 : bereichQuote(b);
      if (quote < niedrigsteQuote) {
        niedrigsteQuote = quote;
        schwaechster = b;
      }
    }
    return schwaechster;
  }

  int get level => (gesamtPunkte / 100).floor() + 1;

  Future<void> hoerbuchSpeichern(String kapitelId, int satzIndex) async {
    hoerbuchFortschritt[kapitelId] = satzIndex;
    await _speichern();
  }

  int get kapitelGehoert => hoerbuchFortschritt.values.where((v) => v > 0).length;

  Future<void> _speichern() async {
    await _prefs.setStringList('geloest', geloesteFragen.toList());
    await _prefs.setInt('punkte', gesamtPunkte);
    await _prefs.setInt('streak', streak);
    await _prefs.setStringList(
      'leitner',
      leitnerBoxen.entries.map((e) => '${e.key}:${e.value}').toList(),
    );
    await _prefs.setStringList(
      'wiederholung',
      wiederholungsZeiten.entries.map((e) => '${e.key}:${e.value}').toList(),
    );
    await _prefs.setStringList(
      'hoerbuch',
      hoerbuchFortschritt.entries.map((e) => '${e.key}:${e.value}').toList(),
    );
    await _prefs.setStringList(
      'bereich_richtig',
      bereichRichtig.entries.map((e) => '${e.key}::${e.value}').toList(),
    );
    await _prefs.setStringList(
      'bereich_gesamt',
      bereichGesamt.entries.map((e) => '${e.key}::${e.value}').toList(),
    );
    await _prefs.setInt('tagesziel', tagesziel);
    await _prefs.setInt('aufgaben_heute', aufgabenHeute);
    await _prefs.setString('lern_tag', _lernTag);
    await _prefs.setString('ziel_tag', _zielErreichtTag);
    if (pruefungsDatum == null) {
      await _prefs.remove('pruefungsdatum');
    } else {
      await _prefs.setString('pruefungsdatum', pruefungsDatum!);
    }
  }
}
