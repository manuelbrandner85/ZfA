import 'package:flutter/material.dart';
import '../../models/hoerbuch_kapitel.dart';

// ============================================================
// KAPITEL 1 — DIE ANMELDUNG
// ============================================================
const HoerbuchKapitel kapitel1Anmeldung = HoerbuchKapitel(
  id: 'k01_anmeldung',
  emoji: '🏠',
  titel: 'Die Anmeldung',
  untertitel: 'Säule 1 — Dein erster Eindruck zählt',
  farbe: Color(0xFF1565C0),
  bereich: 'Anmeldung',
  saetze: [
    'Willkommen beim ersten Kapitel: Die Anmeldung.',
    'Der Patient betritt die Praxis — und du bist das erste Gesicht das er sieht.',
    'Merke dir: Für den ersten Eindruck gibt es keine zweite Chance!',
    'Schau den Patienten an. Nenn seinen Namen. Lächle.',
    'Das ist die Drei-er-Regel: Blick, Name, Lächeln.',
    'Jetzt zum Wichtigsten an der Anmeldung: Die Versicherungskarte.',
    'Bei gesetzlich Versicherten musst du die eGK einlesen.',
    'eGK bedeutet: Elektronische Gesundheitskarte. Die blaue Krankenkassenkarte.',
    'Dann prüfst du: Ist die Anamnese aktuell?',
    'Anamnese bedeutet: Alle Informationen über Vorerkrankungen und Medikamente.',
    'Warum ist das so wichtig? Weil manche Erkrankungen die Behandlung beeinflussen!',
    'Zum Beispiel: Ein Patient mit Diabetes braucht besondere Aufmerksamkeit.',
    'Bei Diabetes fragen wir: Haben Sie heute gegessen? Haben Sie Ihre Medikamente genommen?',
    'Ein Patient mit Gerinnungshemmern blutet länger. Das muss der Zahnarzt wissen!',
    'Merke: G-E-M bei Diabetes: Gegessen? Eingenommen? Messung heute?',
    'Zum Schluss: Hat der Patient die Aufklärung unterschrieben?',
    'Keine Unterschrift bedeutet: Keine Behandlung! Das ist Gesetz.',
    'Und bei chirurgischen Eingriffen immer fragen: Wie kommen Sie nach Hause?',
    'Nach einer Betäubung darf der Patient nicht selbst Auto fahren.',
    'Das war Kapitel Eins. Drei Dinge merken: Blick-Name-Lächeln, eGK einlesen, Anamnese prüfen.',
  ],
);

// ============================================================
// KAPITEL 2 — ZIMMER VORBEREITEN & HÄNDEDESINFEKTION
// ============================================================
const HoerbuchKapitel kapitel2Vorbereitung = HoerbuchKapitel(
  id: 'k02_vorbereitung',
  emoji: '🧤',
  titel: 'Zimmer vorbereiten',
  untertitel: 'Säule 2 — Sauber starten in den Tag',
  farbe: Color(0xFF00897B),
  bereich: 'Hygiene',
  saetze: [
    'Kapitel Zwei: Das Behandlungszimmer vorbereiten.',
    'Bevor der Patient kommt, muss alles sauber und bereit sein.',
    'Zuerst wischst du alle Flächen mit Flächendesinfektion ab.',
    'Wichtig: Die Einwirkzeit beachten! Steht immer auf der Flasche.',
    'Dann legst du die Schutzbezüge neu auf: Kopfstütze, Griffe, Schläuche.',
    'Jetzt kommt die Händedesinfektion. Das Herzstück der Hygiene!',
    'Nimm genug Mittel in die hohle Hand. Etwa drei bis fünf Milliliter.',
    'Reibe die Hände dreißig Sekunden ein. Die Hände müssen die ganze Zeit feucht sein.',
    'Vergiss die Fingerzwischenräume nicht! Und die Daumen!',
    'Auch die Fingerkuppen und die Nägel sind wichtig.',
    'Merke die Reihenfolge: Handfläche, Handrücken, Finger, Daumen, Kuppen.',
    'Erst desinfizieren, dann Handschuhe anziehen.',
    'Niemals Handschuhe über schmutzige Hände ziehen!',
    'Schmuck und Ringe sind tabu. Darunter sammeln sich Keime.',
    'Auch lange oder lackierte Fingernägel sind nicht erlaubt.',
    'Bereite jetzt das Tray vor: Spiegel, Sonde, Pinzette.',
    'Diese drei nennt man das Grundbesteck. Immer dabei!',
    'Stelle den Sauger und die Absaugung bereit.',
    'Zum Schluss: Lüften kommt am ENDE, nicht am Anfang!',
    'Das war Kapitel Zwei. Drei Dinge merken: Flächen wischen, Hände dreißig Sekunden, dann Handschuhe.',
  ],
);

// ============================================================
// KAPITEL 3 — HYGIENE GRUNDBEGRIFFE
// ============================================================
const HoerbuchKapitel kapitel3Hygiene = HoerbuchKapitel(
  id: 'k03_hygiene',
  emoji: '🦠',
  titel: 'Hygiene verstehen',
  untertitel: 'Säule 3 — Unkritisch, semikritisch, kritisch',
  farbe: Color(0xFF6A1B9A),
  bereich: 'Hygiene',
  saetze: [
    'Kapitel Drei: Die Hygiene-Grundbegriffe einfach erklärt.',
    'In der Praxis teilen wir alle Instrumente in drei Gruppen ein.',
    'Stell dir drei Eimer vor: grün, gelb und rot.',
    'Grün ist unkritisch. Diese Sachen berühren nur die heile Haut.',
    'Zum Beispiel der Blutdruckmessgerät-Arm. Das wird nur gewischt.',
    'Gelb ist semikritisch. Diese berühren Schleimhaut, aber verletzen nicht.',
    'Zum Beispiel der Mundspiegel. Der wird desinfiziert und sterilisiert.',
    'Rot ist kritisch. Diese durchdringen Haut oder Schleimhaut.',
    'Zum Beispiel ein Skalpell oder eine Kanüle. Die müssen immer steril sein!',
    'Merke: Je tiefer es in den Körper geht, desto sauberer muss es sein.',
    'Jetzt der Unterschied zwischen Desinfektion und Sterilisation.',
    'Desinfektion bedeutet: Die meisten Keime werden abgetötet.',
    'Sterilisation bedeutet: Wirklich ALLE Keime werden abgetötet. Auch Sporen!',
    'Sterilisiert wird im Autoklav. Mit heißem Dampf unter Druck.',
    'Der Standard ist: 134 Grad für mindestens fünf Minuten.',
    'Nach dem Sterilisieren werden Instrumente verpackt und beschriftet.',
    'Auf die Verpackung kommt das Datum und die Chargennummer.',
    'So weißt du immer: Ist das noch steril? Bis wann haltbar?',
    'Die Aufbereitung läuft immer von unrein nach rein. Niemals zurück!',
    'Das war Kapitel Drei. Drei Eimer merken: grün berührt Haut, gelb Schleimhaut, rot geht rein.',
  ],
);

// ============================================================
// KAPITEL 4 — DIE ANÄSTHESIEARTEN
// ============================================================
const HoerbuchKapitel kapitel4Anaesthesie = HoerbuchKapitel(
  id: 'k04_anaesthesie',
  emoji: '💉',
  titel: 'Die Betäubung',
  untertitel: 'Säule 4 — Kurze und lange Kanüle',
  farbe: Color(0xFFD84315),
  bereich: 'Anästhesie',
  saetze: [
    'Kapitel Vier: Die örtliche Betäubung, auch Anästhesie genannt.',
    'Die Betäubung sorgt dafür, dass der Patient keinen Schmerz spürt.',
    'Es gibt verschiedene Arten. Wir merken uns die wichtigsten.',
    'Die Oberflächenanästhesie ist ein Gel oder Spray auf der Schleimhaut.',
    'Damit spürt der Patient den Einstich der Nadel nicht so stark.',
    'Die Infiltrationsanästhesie betäubt einen einzelnen Zahn.',
    'Dafür nimmt man die KURZE Kanüle.',
    'Sie wird meist im Oberkiefer benutzt, weil der Knochen dort dünner ist.',
    'Die Leitungsanästhesie betäubt einen ganzen Nervenast.',
    'Dafür braucht man die LANGE Kanüle.',
    'Sie wird meist im Unterkiefer benutzt, hinten am Kieferwinkel.',
    'Merke die Eselsbrücke: Lange Kanüle für die lange Leitung.',
    'Und: kurze Kanüle für den kurzen Weg zum einzelnen Zahn.',
    'Das Betäubungsmittel heißt oft Articain oder Lidocain.',
    'Viele Mittel enthalten Adrenalin. Das verengt die Gefäße.',
    'Dadurch wirkt die Betäubung länger und es blutet weniger.',
    'Aber Vorsicht: Bei manchen Herzpatienten ist Adrenalin heikel.',
    'Du legst dem Zahnarzt die fertige Spritze gut sichtbar an.',
    'Nach der Betäubung darf der Patient nicht auf die taube Lippe beißen!',
    'Das war Kapitel Vier. Merke: kurze Kanüle einzelner Zahn, lange Kanüle ganzer Nerv.',
  ],
);

// ============================================================
// KAPITEL 5 — CHIRURGIE SCHRITT FÜR SCHRITT
// ============================================================
const HoerbuchKapitel kapitel5Chirurgie = HoerbuchKapitel(
  id: 'k05_chirurgie',
  emoji: '🔪',
  titel: 'Die Chirurgie',
  untertitel: 'Säule 5 — Schritt für Schritt assistieren',
  farbe: Color(0xFFC62828),
  bereich: 'Chirurgie',
  saetze: [
    'Kapitel Fünf: Die zahnärztliche Chirurgie.',
    'Ein typischer Eingriff ist das Ziehen eines Zahnes. Die Extraktion.',
    'Hier ist alles steril. Du arbeitest besonders sauber.',
    'Zuerst wird betäubt und der Patient wird abgedeckt.',
    'Das Instrument zum Lösen des Zahnes heißt Hebel oder Elevator.',
    'Das Instrument zum Ziehen heißt Zange. Es gibt viele Formen.',
    'Für jeden Zahn gibt es eine passende Zange.',
    'Während der Zahnarzt arbeitet, hältst du den Sauger bereit.',
    'Du saugst Blut und Speichel ab, damit er gut sieht.',
    'Nach dem Ziehen kommt oft eine Naht. Du reichst Nadelhalter und Faden.',
    'Jetzt zur Nachbereitung. Dafür gibt es eine Merkhilfe: A-M-I-W-L.',
    'A steht für Aufklären: Was darf der Patient jetzt nicht tun?',
    'M steht für Medikamente: Schmerzmittel und Verhaltensregeln mitgeben.',
    'I steht für Instrumente: Alles zur Aufbereitung bringen.',
    'W steht für Wunde: Auf Nachblutung achten, Tupfer aufbeißen lassen.',
    'L steht für Lüften und Reinigen des Zimmers.',
    'Wichtige Patientenregel: In den ersten Stunden nicht spülen!',
    'Auch kein Kaffee, kein Sport und keine Zigaretten am ersten Tag.',
    'Sonst löst sich das Blutgerinnsel und die Wunde heilt schlecht.',
    'Das war Kapitel Fünf. Merke A-M-I-W-L für die saubere Nachbereitung.',
  ],
);

// ============================================================
// KAPITEL 6 — PARODONTITIS
// ============================================================
const HoerbuchKapitel kapitel6Parodontitis = HoerbuchKapitel(
  id: 'k06_parodontitis',
  emoji: '🩸',
  titel: 'Parodontitis',
  untertitel: 'Säule 6 — Von Plaque bis zum Zahnverlust',
  farbe: Color(0xFFAD1457),
  bereich: 'Parodontitis',
  saetze: [
    'Kapitel Sechs: Die Parodontitis. Die Erkrankung des Zahnhalteapparates.',
    'Stell dir eine Treppe mit drei Stufen vor.',
    'Die erste Stufe ist Plaque. Das ist der weiche Zahnbelag.',
    'Plaque besteht aus Bakterien. Man kann sie wegputzen.',
    'Wenn Plaque bleibt, wird sie hart. Dann heißt sie Zahnstein.',
    'Zahnstein kann man nicht mehr wegputzen. Nur die Praxis entfernt ihn.',
    'Die zweite Stufe ist die Gingivitis. Die Zahnfleischentzündung.',
    'Das Zahnfleisch ist rot, geschwollen und blutet beim Putzen.',
    'Gute Nachricht: Gingivitis ist noch heilbar und umkehrbar!',
    'Die dritte Stufe ist die Parodontitis. Jetzt wird es ernst.',
    'Die Entzündung geht tief. Der Knochen baut sich ab.',
    'Es entstehen Zahnfleischtaschen. Dort sitzen die Bakterien.',
    'Wird nichts getan, werden die Zähne locker und fallen aus.',
    'Wie tief eine Tasche ist, misst man mit der PAR-Sonde.',
    'Man misst in Millimetern an sechs Stellen pro Zahn.',
    'Ab vier Millimetern spricht man von einer Tasche.',
    'Die Behandlung heißt: Die Taschen werden gründlich gereinigt.',
    'Danach ist gute Mundhygiene zu Hause besonders wichtig.',
    'Merke die Treppe: Plaque, dann Gingivitis, dann Parodontitis.',
    'Das war Kapitel Sechs. Drei Stufen merken: Belag, Entzündung, Knochenabbau.',
  ],
);

// ============================================================
// KAPITEL 7 — KARIES UND KOMPOSITFÜLLUNG
// ============================================================
const HoerbuchKapitel kapitel7Karies = HoerbuchKapitel(
  id: 'k07_karies',
  emoji: '🦷',
  titel: 'Karies und Füllung',
  untertitel: 'Säule 7 — Das Loch und der Kofferdam',
  farbe: Color(0xFF00838F),
  bereich: 'Karies',
  saetze: [
    'Kapitel Sieben: Karies und die Kompositfüllung.',
    'Karies ist das, was man im Volksmund Loch im Zahn nennt.',
    'Bakterien im Mund machen aus Zucker eine Säure.',
    'Diese Säure löst den harten Zahnschmelz auf.',
    'Wird nichts getan, geht die Karies immer tiefer.',
    'Zuerst der Schmelz, dann das Dentin, dann der Nerv.',
    'Der Zahnarzt bohrt die kranke Stelle sauber aus.',
    'Das Loch muss dann gefüllt werden. Heute oft mit Komposit.',
    'Komposit ist ein zahnfarbener Kunststoff. Sieht aus wie ein echter Zahn.',
    'Für eine gute Füllung muss es absolut trocken sein.',
    'Speichel ist der Feind! Er verhindert, dass die Füllung hält.',
    'Deshalb spannt man oft einen Kofferdam.',
    'Der Kofferdam ist ein dünnes Gummituch über dem Zahn.',
    'Es hält Speichel weg und schützt den Patienten vor Schluckunfällen.',
    'Der Zahn wird mit einem Gel angeätzt. Das macht ihn rau.',
    'Auf die raue Fläche kommt der Kleber, der Bonding heißt.',
    'Dann wird das Komposit in Schichten eingebracht.',
    'Jede Schicht wird mit blauem Licht ausgehärtet. Die Polymerisationslampe.',
    'Zum Schluss wird die Füllung poliert und der Biss geprüft.',
    'Das war Kapitel Sieben. Merke: Trockenlegen mit Kofferdam, dann ätzen, kleben, härten.',
  ],
);

// ============================================================
// KAPITEL 8 — WURZELKANALBEHANDLUNG
// ============================================================
const HoerbuchKapitel kapitel8Wurzelkanal = HoerbuchKapitel(
  id: 'k08_wurzelkanal',
  emoji: '🪥',
  titel: 'Wurzelbehandlung',
  untertitel: 'Säule 8 — Warum zwei Trays sinnvoll sind',
  farbe: Color(0xFF5E35B1),
  bereich: 'Behandlungsassistenz',
  saetze: [
    'Kapitel Acht: Die Wurzelkanalbehandlung.',
    'Sie wird nötig, wenn der Nerv im Zahn entzündet oder tot ist.',
    'Der Fachbegriff dafür ist Endodontie.',
    'Das Ziel: Den Zahn retten statt ihn zu ziehen.',
    'Der Zahnarzt öffnet den Zahn von oben. Das nennt man Trepanation.',
    'Dann werden die feinen Kanäle in der Wurzel gesucht.',
    'Mit dünnen Feilen wird der Kanal gereinigt und erweitert.',
    'Zwischendurch wird immer wieder gespült. Meist mit einer Desinfektionslösung.',
    'Wie lang der Kanal ist, misst die Endometrie. Eine elektrische Messung.',
    'Bei dieser Behandlung arbeitet man oft mit zwei Trays.',
    'Warum zwei Trays? Das ist ein wichtiger Lerninhalt!',
    'Tray Eins ist unsteril. Darauf liegt alles für die Vorbereitung.',
    'Zum Beispiel Watte, Spüllösung und die Röntgenhilfen.',
    'Tray Zwei ist steril. Darauf liegen die Feilen und das Füllmaterial.',
    'So vermischt man saubere und unsaubere Sachen nicht.',
    'Das schützt den Kanal vor neuen Bakterien.',
    'Am Ende wird der Kanal dicht gefüllt. Oft mit Guttapercha.',
    'Guttapercha ist ein gummiartiges Material aus einem Baum.',
    'Danach bekommt der Zahn eine Füllung oder eine Krone.',
    'Das war Kapitel Acht. Merke: zwei Trays trennen steril und unsteril.',
  ],
);

// ============================================================
// KAPITEL 9 — ZAHNERSATZ UND HKP
// ============================================================
const HoerbuchKapitel kapitel9Zahnersatz = HoerbuchKapitel(
  id: 'k09_zahnersatz',
  emoji: '👑',
  titel: 'Zahnersatz',
  untertitel: 'Säule 9 — eHKP, GOZ und BEMA',
  farbe: Color(0xFF455A64),
  bereich: 'Behandlungsassistenz',
  saetze: [
    'Kapitel Neun: Der Zahnersatz und der Heil- und Kostenplan.',
    'Wenn ein Zahn fehlt oder kaputt ist, gibt es Ersatz.',
    'Eine Krone setzt man auf einen einzelnen beschädigten Zahn.',
    'Eine Brücke überspannt eine Lücke. Sie hängt an den Nachbarzähnen.',
    'Eine Prothese ersetzt viele Zähne und ist herausnehmbar.',
    'Ein Implantat ist eine künstliche Wurzel aus Titan.',
    'Bevor es losgeht, braucht es einen Plan: den Heil- und Kostenplan.',
    'Heute meist digital. Dann heißt er eHKP.',
    'Der HKP zeigt: Was ist geplant und was kostet es?',
    'Die Krankenkasse muss den Plan erst genehmigen.',
    'Jetzt zwei wichtige Abkürzungen: BEMA und GOZ.',
    'BEMA ist der Katalog für gesetzlich Versicherte.',
    'Merke: BEMA wie Beim gesetzlichen Patienten.',
    'GOZ ist die Gebührenordnung für Privatleistungen.',
    'Merke: GOZ wie Gesondert ohne Zuzahlung der Kasse.',
    'Die Kasse zahlt einen festen Zuschuss. Den Festzuschuss.',
    'Wer regelmäßig zur Kontrolle geht, hat ein gepflegtes Bonusheft.',
    'Mit vollem Bonusheft gibt die Kasse mehr Geld dazu.',
    'Den Zahnersatz selbst baut der Zahntechniker im Labor.',
    'Das war Kapitel Neun. Merke: BEMA für gesetzlich, GOZ für privat.',
  ],
);

// ============================================================
// KAPITEL 10 — VERABSCHIEDUNG & DOKUMENTATION
// ============================================================
const HoerbuchKapitel kapitel10Doku = HoerbuchKapitel(
  id: 'k10_doku',
  emoji: '📋',
  titel: 'Doku & Abschied',
  untertitel: 'Säule 10 — Die 4 Ws der Dokumentation',
  farbe: Color(0xFF2E7D32),
  bereich: 'Anmeldung',
  saetze: [
    'Kapitel Zehn: Die Verabschiedung und die Dokumentation.',
    'Die Behandlung ist vorbei. Jetzt kommt der saubere Abschluss.',
    'Zuerst die Verabschiedung des Patienten.',
    'Frage: Sind noch Fragen offen? Brauchen Sie ein Rezept?',
    'Vereinbare gleich den nächsten Termin. Das spart später Arbeit.',
    'Gib bei Bedarf einen Recall-Hinweis. Also eine Erinnerung zur Kontrolle.',
    'Verabschiede freundlich. Der letzte Eindruck bleibt auch hängen!',
    'Jetzt das Wichtigste: Die Dokumentation. Alles muss aufgeschrieben werden.',
    'Was nicht dokumentiert ist, gilt vor Gericht als nicht gemacht!',
    'Dafür merken wir uns die vier Ws.',
    'Das erste W: Was wurde gemacht? Welche Behandlung?',
    'Das zweite W: Womit wurde es gemacht? Welches Material?',
    'Das dritte W: Welche Charge? Also die Chargennummer der Materialien.',
    'Das vierte W: Wer hat es gemacht? Welcher Behandler?',
    'Besonders Chargennummern sind oft eine Prüfungsfalle.',
    'Bei Betäubung, Füllung und sterilen Sachen immer die Charge notieren.',
    'So kann man später alles zurückverfolgen.',
    'Auch Allergien und Besonderheiten werden vermerkt.',
    'Erst wenn alles steht, ist deine Arbeit wirklich fertig.',
    'Das war Kapitel Zehn. Merke die vier Ws: Was, Womit, Welche Charge, Wer.',
  ],
);

// ============================================================
// ALLE KAPITEL IN EINER LISTE
// ============================================================
const List<HoerbuchKapitel> alleHoerbuchKapitel = [
  kapitel1Anmeldung,
  kapitel2Vorbereitung,
  kapitel3Hygiene,
  kapitel4Anaesthesie,
  kapitel5Chirurgie,
  kapitel6Parodontitis,
  kapitel7Karies,
  kapitel8Wurzelkanal,
  kapitel9Zahnersatz,
  kapitel10Doku,
];
