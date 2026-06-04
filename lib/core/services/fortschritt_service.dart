import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

class FortschrittService {
  late SharedPreferences _prefs;

  // --- SM-2 Spaced Repetition (pro Frage) ---
  Map<String, double> sm2Ef = {}; // Easiness-Faktor (>=1.3)
  Map<String, int> sm2Interval = {}; // aktuelles Intervall in Tagen
  Map<String, int> sm2Reps = {}; // Anzahl korrekter Wiederholungen
  Map<String, int> sm2Faellig = {}; // nächste Fälligkeit (Unix-ms)
  // --- Readiness-Verlauf (Datum yyyymmdd -> Score 0..100) ---
  Map<String, int> readinessVerlauf = {};
  // --- Gamification: Wochen-XP (Liga) + freigeschaltete Abzeichen ---
  int wochenXp = 0;
  String _woche = '';
  Set<String> abzeichen = {};
  // Aktuell falsch beantwortete Fragen (Fehler-Sammlung).
  Set<String> fehlerFragen = {};
  // Favoriten/Lesezeichen (Karten, Abläufe …) per ID.
  Set<String> favoriten = {};
  // Lern-Aktivität je Tag (yyyymmdd -> Anzahl Aufgaben) für den Kalender.
  Map<String, int> lernTage = {};

  bool istFavorit(String id) => favoriten.contains(id);

  Future<void> favoritUmschalten(String id) async {
    if (!favoriten.add(id)) favoriten.remove(id);
    await _speichern();
  }

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

    sm2Ef = _ladeDoubleMap('sm2_ef');
    sm2Interval = _ladeIntMap('sm2_int');
    sm2Reps = _ladeIntMap('sm2_reps');
    sm2Faellig = _ladeIntMap('sm2_due');
    readinessVerlauf = _ladeIntMap('readiness', sep: '::');

    wochenXp = _prefs.getInt('wochen_xp') ?? 0;
    _woche = _prefs.getString('woche') ?? '';
    abzeichen = (_prefs.getStringList('abzeichen') ?? []).toSet();
    fehlerFragen = (_prefs.getStringList('fehler') ?? []).toSet();
    favoriten = (_prefs.getStringList('favoriten') ?? []).toSet();
    lernTage = _ladeIntMap('lerntage', sep: '::');
    final aktuelleWoche = _wocheSchluessel(DateTime.now());
    if (_woche != aktuelleWoche) {
      _woche = aktuelleWoche;
      wochenXp = 0; // neue Woche, Liga startet neu
    }

    _tagPruefen(); // ggf. Tageszähler zurücksetzen
  }

  String _wocheSchluessel(DateTime d) {
    final tagImJahr = int.parse(
        '${d.difference(DateTime(d.year, 1, 1)).inDays}');
    return '${d.year}-W${(tagImJahr / 7).floor()}';
  }

  // ---- Tages-Lernplan bis zur Prüfung ----
  /// Empfohlene Themen für heute (schwächste zuerst) + Wiederholung.
  List<String> tagesPlan() {
    final sortiert = [...hauptBereiche];
    sortiert.sort((a, b) {
      final ga = bereichGesamt[a] ?? 0, gb = bereichGesamt[b] ?? 0;
      final qa = ga == 0 ? -1.0 : bereichQuote(a);
      final qb = gb == 0 ? -1.0 : bereichQuote(b);
      return qa.compareTo(qb);
    });
    return sortiert.take(3).toList();
  }

  Future<void> abzeichenFreischalten(String id) async {
    if (abzeichen.add(id)) await _speichern();
  }

  Map<String, int> _ladeIntMap(String key, {String sep = ':'}) {
    final out = <String, int>{};
    for (final e in _prefs.getStringList(key) ?? []) {
      final t = e.split(sep);
      if (t.length == 2) out[t[0]] = int.tryParse(t[1]) ?? 0;
    }
    return out;
  }

  Map<String, double> _ladeDoubleMap(String key) {
    final out = <String, double>{};
    for (final e in _prefs.getStringList(key) ?? []) {
      final t = e.split(':');
      if (t.length == 2) out[t[0]] = double.tryParse(t[1]) ?? 2.5;
    }
    return out;
  }

  // SM-2-Aktualisierung. quality 0..5 (5 = mühelos richtig, <3 = falsch).
  void _sm2(String id, int quality) {
    double ef = sm2Ef[id] ?? 2.5;
    int reps = sm2Reps[id] ?? 0;
    int interval = sm2Interval[id] ?? 0;
    if (quality < 3) {
      reps = 0;
      interval = 1;
    } else {
      ef = ef + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
      if (ef < 1.3) ef = 1.3;
      if (reps == 0) {
        interval = 1;
      } else if (reps == 1) {
        interval = 6;
      } else {
        interval = (interval * ef).round();
      }
      reps += 1;
    }
    sm2Ef[id] = ef;
    sm2Reps[id] = reps;
    sm2Interval[id] = interval;
    sm2Faellig[id] = DateTime.now()
        .add(Duration(days: interval))
        .millisecondsSinceEpoch;
  }

  // Zählt eine erledigte Aufgabe für das Tagesziel und pflegt den Streak.
  void _aufgabeGezaehlt() {
    _tagPruefen();
    aufgabenHeute++;
    final t = _tagSchluessel(DateTime.now());
    lernTage[t] = (lernTage[t] ?? 0) + 1;
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
    fehlerFragen.remove(frageId);
    gesamtPunkte += 10;
    wochenXp += 10;
    // Leitner: Eine Box höher (max. Box 5)
    final aktuelleBox = leitnerBoxen[frageId] ?? 1;
    leitnerBoxen[frageId] = (aktuelleBox + 1).clamp(1, 5);
    wiederholungsZeiten[frageId] = DateTime.now().millisecondsSinceEpoch;
    if (bereich != null) {
      bereichRichtig[bereich] = (bereichRichtig[bereich] ?? 0) + 1;
      bereichGesamt[bereich] = (bereichGesamt[bereich] ?? 0) + 1;
    }
    _sm2(frageId, 5);
    _aufgabeGezaehlt();
    _readinessHeuteMerken();
    await _speichern();
  }

  Future<void> frageFalschBeantwortet(String frageId, {String? bereich}) async {
    // Leitner: Zurück zu Box 1!
    leitnerBoxen[frageId] = 1;
    fehlerFragen.add(frageId);
    wiederholungsZeiten[frageId] = DateTime.now().millisecondsSinceEpoch;
    if (bereich != null) {
      bereichGesamt[bereich] = (bereichGesamt[bereich] ?? 0) + 1;
    }
    _sm2(frageId, 2);
    _aufgabeGezaehlt();
    _readinessHeuteMerken();
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

  // Welche Fragen JETZT wiederholen? (SM-2 Spaced Repetition)
  List<String> fragenFuerHeute(List<String> alleFrageIds) {
    final jetzt = DateTime.now().millisecondsSinceEpoch;
    final faellig = alleFrageIds.where((id) {
      final due = sm2Faellig[id];
      return due == null || due <= jetzt; // noch nie gelernt ODER fällig
    }).toList();
    // Schwächste zuerst (kleinstes Intervall)
    faellig.sort(
        (a, b) => (sm2Interval[a] ?? 0).compareTo(sm2Interval[b] ?? 0));
    return faellig.isEmpty ? alleFrageIds : faellig;
  }

  // ---- Prüfungs-Readiness ----
  static const List<String> hauptBereiche = [
    'Anmeldung',
    'Hygiene',
    'Behandlungsassistenz',
    'Anästhesie',
    'Chirurgie',
    'Karies',
    'Parodontitis',
  ];

  /// Bereitschafts-Score 0..100 aus Themen-Beherrschung und Abdeckung.
  int readinessScore() {
    double summe = 0;
    for (final b in hauptBereiche) {
      final g = bereichGesamt[b] ?? 0;
      final abdeckung = (g / 8).clamp(0.0, 1.0); // ab 8 Antworten voll gewertet
      final quote = g == 0 ? 0.0 : bereichQuote(b);
      summe += quote * abdeckung;
    }
    return (summe / hauptBereiche.length * 100).round();
  }

  /// Geschätzte Bestehenswahrscheinlichkeit (logistische Kurve um 50).
  int bestehensWahrscheinlichkeit() {
    final r = readinessScore();
    final p = 100 / (1 + math.exp(-(r - 48) / 11));
    return p.clamp(1, 99).round();
  }

  void _readinessHeuteMerken() {
    readinessVerlauf[_tagSchluessel(DateTime.now())] = readinessScore();
  }

  /// Speichert den heutigen Readiness-Wert (z. B. beim Öffnen des Cockpits).
  Future<void> readinessSnapshot() async {
    _readinessHeuteMerken();
    await _speichern();
  }

  /// Liste der letzten [tage] Tage als (Kürzel, Score) für den Trend.
  List<MapEntry<String, int>> readinessTrend({int tage = 7}) {
    const wt = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    final out = <MapEntry<String, int>>[];
    int letzter = 0;
    for (int i = tage - 1; i >= 0; i--) {
      final tag = DateTime.now().subtract(Duration(days: i));
      final key = _tagSchluessel(tag);
      final wert = readinessVerlauf[key] ?? letzter;
      letzter = wert;
      out.add(MapEntry(wt[tag.weekday - 1], wert));
    }
    return out;
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
    await _prefs.setStringList('sm2_ef',
        sm2Ef.entries.map((e) => '${e.key}:${e.value}').toList());
    await _prefs.setStringList('sm2_int',
        sm2Interval.entries.map((e) => '${e.key}:${e.value}').toList());
    await _prefs.setStringList('sm2_reps',
        sm2Reps.entries.map((e) => '${e.key}:${e.value}').toList());
    await _prefs.setStringList('sm2_due',
        sm2Faellig.entries.map((e) => '${e.key}:${e.value}').toList());
    await _prefs.setStringList('readiness',
        readinessVerlauf.entries.map((e) => '${e.key}::${e.value}').toList());
    await _prefs.setInt('wochen_xp', wochenXp);
    await _prefs.setString('woche', _woche);
    await _prefs.setStringList('abzeichen', abzeichen.toList());
    await _prefs.setStringList('fehler', fehlerFragen.toList());
    await _prefs.setStringList('favoriten', favoriten.toList());
    await _prefs.setStringList('lerntage',
        lernTage.entries.map((e) => '${e.key}::${e.value}').toList());
  }
}
