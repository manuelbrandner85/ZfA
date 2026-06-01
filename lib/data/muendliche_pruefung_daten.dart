import '../models/fachgespraech_frage.dart';

// ============================================================
// MÜNDLICHE ABSCHLUSSPRÜFUNG — FACHGESPRÄCH
// Typische Prüfer-Fragen mit Stichpunkten und Musterantwort.
// Deckt den kompletten Behandlungsablauf + Querschnittsthemen ab.
// ============================================================

const List<FachgespraechFrage> alleFachgespraeche = [
  // ---------- EMPFANG & PATIENTENANNAHME ----------
  FachgespraechFrage(
    id: 'fg01',
    bereich: 'Empfang',
    emoji: '🏠',
    frage: 'Ein neuer Patient kommt in die Praxis. Beschreiben Sie, wie Sie ihn empfangen und annehmen.',
    stichpunkte: [
      'freundlicher erster Eindruck, Blickkontakt, Begrüßung mit Namen',
      'Versichertenkarte (eGK) einlesen',
      'Anamnesebogen ausfüllen lassen',
      'Daten erfassen und Datenschutz beachten',
    ],
    musterantwort:
        'Ich begrüße den Patienten freundlich mit Blickkontakt und nach Möglichkeit mit Namen. '
        'Bei einem Neupatienten lese ich die elektronische Gesundheitskarte ein und lege eine Karteikarte an. '
        'Ich lasse den Anamnesebogen ausfüllen und frage Vorerkrankungen, Allergien und Medikamente ab. '
        'Dabei achte ich auf den Datenschutz und behandle alle Angaben vertraulich. '
        'Zum Schluss informiere ich über den Ablauf und die ungefähre Wartezeit.',
  ),
  FachgespraechFrage(
    id: 'fg02',
    bereich: 'Empfang',
    emoji: '📅',
    frage: 'Wie organisieren Sie die Terminvergabe, damit der Praxisablauf reibungslos funktioniert?',
    stichpunkte: [
      'Behandlungsdauer realistisch einplanen',
      'Pufferzeiten für Notfälle',
      'Recall-System nutzen',
      'Patientenwünsche und Dringlichkeit berücksichtigen',
    ],
    musterantwort:
        'Ich plane jeden Termin nach der voraussichtlichen Behandlungsdauer und lasse Pufferzeiten für Notfälle. '
        'Schmerzpatienten bekommen kurzfristig einen Termin, planbare Behandlungen werden vorausschauend vergeben. '
        'Über das Recall-System erinnere ich an Kontroll- und Prophylaxetermine. '
        'So vermeide ich Leerlauf und lange Wartezeiten.',
  ),

  // ---------- RECHT & AUFKLÄRUNG ----------
  FachgespraechFrage(
    id: 'fg03',
    bereich: 'Recht',
    emoji: '⚖️',
    frage: 'Was müssen Sie zur Schweigepflicht und zum Datenschutz wissen?',
    stichpunkte: [
      'Schweigepflicht gilt für alle Patientendaten',
      'auch außerhalb der Arbeitszeit und gegenüber Angehörigen',
      'Datenschutz nach DSGVO',
      'Unterlagen vor unbefugtem Zugriff schützen',
    ],
    musterantwort:
        'Die Schweigepflicht verpflichtet mich, keine Patientendaten an Unbefugte weiterzugeben – auch nicht an Angehörige oder außerhalb der Arbeitszeit. '
        'Nach der DSGVO dürfen Daten nur für die Behandlung verwendet und müssen sicher aufbewahrt werden. '
        'Bildschirme und Unterlagen schütze ich vor fremden Blicken, und ich gebe Auskünfte nur nach Einwilligung des Patienten.',
  ),
  FachgespraechFrage(
    id: 'fg04',
    bereich: 'Recht',
    emoji: '✍️',
    frage: 'Warum ist die Aufklärung und Einwilligung des Patienten vor einem Eingriff so wichtig?',
    stichpunkte: [
      'Patient muss über Risiken und Alternativen informiert sein',
      'ohne Einwilligung ist die Behandlung Körperverletzung',
      'schriftliche Einwilligung bei Eingriffen',
      'Selbstbestimmungsrecht des Patienten',
    ],
    musterantwort:
        'Der Patient hat ein Selbstbestimmungsrecht und muss vor einem Eingriff verständlich über Ablauf, Risiken und Alternativen aufgeklärt werden. '
        'Erst danach kann er rechtswirksam einwilligen. Ohne wirksame Einwilligung gilt jeder Eingriff rechtlich als Körperverletzung. '
        'Bei chirurgischen Eingriffen lassen wir die Einwilligung schriftlich unterschreiben und dokumentieren das Aufklärungsgespräch.',
  ),

  // ---------- HYGIENE ----------
  FachgespraechFrage(
    id: 'fg05',
    bereich: 'Hygiene',
    emoji: '🧤',
    frage: 'Erklären Sie die Aufbereitung von Instrumenten von der Behandlung bis zur sterilen Lagerung.',
    stichpunkte: [
      'Vorreinigung / Desinfektion direkt nach Gebrauch',
      'Reinigung (manuell oder Thermodesinfektor) – von unrein nach rein',
      'Kontrolle, Pflege, Verpackung',
      'Sterilisation im Autoklav bei 134 °C, beschriften mit Datum und Charge',
    ],
    musterantwort:
        'Nach der Behandlung werden die Instrumente zuerst vorgereinigt oder in eine Desinfektionslösung gelegt. '
        'Dann reinige ich sie, am besten im Thermodesinfektor, und arbeite immer von unrein nach rein. '
        'Nach der Reinigung kontrolliere und pflege ich die Instrumente, verpacke sie und sterilisiere sie im Autoklav bei 134 Grad. '
        'Die Verpackung beschrifte ich mit Datum und Chargennummer, damit alles rückverfolgbar bleibt.',
  ),
  FachgespraechFrage(
    id: 'fg06',
    bereich: 'Hygiene',
    emoji: '🦠',
    frage: 'Wie teilen Sie Medizinprodukte nach ihrem Risiko ein und was bedeutet das für die Aufbereitung?',
    stichpunkte: [
      'unkritisch – berührt intakte Haut – reinigen/desinfizieren',
      'semikritisch – berührt Schleimhaut – desinfizieren, ggf. sterilisieren',
      'kritisch – durchdringt Haut/Schleimhaut – muss steril sein',
      'je tiefer im Körper, desto höher die Anforderung',
    ],
    musterantwort:
        'Wir teilen Medizinprodukte in unkritisch, semikritisch und kritisch ein. '
        'Unkritische berühren nur intakte Haut und werden gereinigt und desinfiziert. '
        'Semikritische berühren Schleimhaut, zum Beispiel der Mundspiegel, und werden desinfiziert und meist sterilisiert. '
        'Kritische durchdringen Haut oder Schleimhaut, zum Beispiel eine Kanüle, und müssen immer steril sein. '
        'Je tiefer ein Produkt in den Körper eindringt, desto höher sind die Hygieneanforderungen.',
  ),

  // ---------- BEHANDLUNGSASSISTENZ ----------
  FachgespraechFrage(
    id: 'fg07',
    bereich: 'Behandlungsassistenz',
    emoji: '🪞',
    frage: 'Was verstehen Sie unter der Arbeit zu vier Händen und welche Vorteile hat sie?',
    stichpunkte: [
      'Zahnarzt und Assistenz arbeiten gleichzeitig',
      'Instrumente griffbereit anreichen',
      'absaugen, Sicht freihalten, Wange abhalten',
      'spart Zeit, schont den Patienten, ruhiger Ablauf',
    ],
    musterantwort:
        'Bei der Arbeit zu vier Händen arbeiten Zahnarzt und Assistenz gleichzeitig am Patienten. '
        'Ich reiche die Instrumente griffbereit so an, dass der Behandler sie ohne Blickwechsel greifen kann, sauge ab und halte die Wange ab. '
        'Das hält das Arbeitsfeld trocken und übersichtlich, spart Zeit und macht die Behandlung für den Patienten angenehmer und sicherer.',
  ),
  FachgespraechFrage(
    id: 'fg08',
    bereich: 'Behandlungsassistenz',
    emoji: '🦷',
    frage: 'Ein Patient bekommt eine Kompositfüllung. Beschreiben Sie Ablauf und Ihre Assistenz.',
    stichpunkte: [
      'Trockenlegung, idealerweise Kofferdam',
      'Karies entfernen, Zahn säubern',
      'Ätzen, Bonding auftragen',
      'Komposit in Schichten, mit Polymerisationslampe aushärten, Biss prüfen',
    ],
    musterantwort:
        'Zuerst wird der Zahn trockengelegt, am besten mit Kofferdam, damit kein Speichel stört. '
        'Der Zahnarzt entfernt die Karies, dann wird der Zahn geätzt und das Bonding aufgetragen. '
        'Ich reiche das Komposit an, das in Schichten eingebracht und mit der Polymerisationslampe ausgehärtet wird. '
        'Während der Behandlung sauge ich ab und halte das Feld trocken. Zum Schluss wird die Füllung poliert und der Biss kontrolliert.',
  ),

  // ---------- ANÄSTHESIE ----------
  FachgespraechFrage(
    id: 'fg09',
    bereich: 'Anästhesie',
    emoji: '💉',
    frage: 'Welche Anästhesiearten kennen Sie und wann wird welche Kanüle verwendet?',
    stichpunkte: [
      'Oberflächenanästhesie (Gel/Spray)',
      'Infiltrationsanästhesie – kurze Kanüle – einzelner Zahn',
      'Leitungsanästhesie – lange Kanüle – ganzer Nervenast, meist Unterkiefer',
      'Adrenalinzusatz verlängert die Wirkung',
    ],
    musterantwort:
        'Es gibt die Oberflächenanästhesie mit Gel oder Spray, die Infiltrationsanästhesie und die Leitungsanästhesie. '
        'Für die Infiltration eines einzelnen Zahns, meist im Oberkiefer, nehme ich die kurze Kanüle. '
        'Für die Leitungsanästhesie eines ganzen Nervenastes, meist im Unterkiefer, nehme ich die lange Kanüle. '
        'Viele Betäubungsmittel enthalten Adrenalin – das verengt die Gefäße, verlängert die Wirkung und verringert die Blutung.',
  ),

  // ---------- CHIRURGIE ----------
  FachgespraechFrage(
    id: 'fg10',
    bereich: 'Chirurgie',
    emoji: '🔪',
    frage: 'Ein Zahn wird extrahiert. Wie bereiten Sie nach und welche Verhaltensregeln geben Sie dem Patienten mit?',
    stichpunkte: [
      'Tupfer aufbeißen lassen, Blutung stillen',
      'kühlen gegen Schwellung',
      'erste Stunden nicht spülen, kein Kaffee/Alkohol/Nikotin, kein Sport',
      'Instrumente aufbereiten, dokumentieren',
    ],
    musterantwort:
        'Nach der Extraktion lasse ich den Patienten auf einen Tupfer beißen, um die Blutung zu stillen, und empfehle, von außen zu kühlen. '
        'Ich erkläre, dass er in den ersten Stunden nicht kräftig spülen, nicht rauchen, keinen Kaffee oder Alkohol trinken und keinen Sport machen soll, '
        'damit sich das Blutgerinnsel nicht löst. Danach bereite ich die Instrumente auf und dokumentiere die Behandlung mit den verwendeten Materialien.',
  ),

  // ---------- PARODONTOLOGIE / PROPHYLAXE ----------
  FachgespraechFrage(
    id: 'fg11',
    bereich: 'Parodontitis',
    emoji: '🩸',
    frage: 'Erklären Sie die Entstehung einer Parodontitis und was man dagegen tun kann.',
    stichpunkte: [
      'Plaque → Zahnstein → Gingivitis → Parodontitis',
      'Gingivitis ist umkehrbar, Parodontitis mit Knochenabbau',
      'Taschen mit PAR-Sonde messen',
      'professionelle Reinigung und gute häusliche Mundhygiene',
    ],
    musterantwort:
        'Am Anfang steht weiche Plaque, die zu Zahnstein wird. Bleibt sie liegen, entsteht eine Zahnfleischentzündung, die Gingivitis. '
        'Die ist noch heilbar. Wird nichts getan, geht die Entzündung in die Tiefe und der Knochen baut sich ab – das ist die Parodontitis. '
        'Die Taschentiefe messen wir mit der PAR-Sonde. Behandelt wird durch gründliche Reinigung der Taschen, und ganz wichtig ist die gute Mundhygiene zu Hause und die Nachsorge.',
  ),
  FachgespraechFrage(
    id: 'fg12',
    bereich: 'Prophylaxe',
    emoji: '🪥',
    frage: 'Wie erklären Sie einem Patienten die richtige Mundhygiene und Prophylaxe?',
    stichpunkte: [
      'zweimal täglich putzen, systematisch',
      'Zahnzwischenräume mit Zahnseide oder Bürstchen',
      'fluoridhaltige Zahnpasta',
      'zuckerarme Ernährung, regelmäßige Kontrolle und PZR',
    ],
    musterantwort:
        'Ich empfehle, mindestens zweimal täglich systematisch mit fluoridhaltiger Zahnpasta zu putzen und immer in der gleichen Reihenfolge vorzugehen. '
        'Die Zahnzwischenräume reinigt man mit Zahnseide oder Interdentalbürstchen, weil die Zahnbürste dort nicht hinkommt. '
        'Dazu rate ich zu zuckerarmer Ernährung, regelmäßigen Kontrollterminen und einer professionellen Zahnreinigung.',
  ),

  // ---------- RÖNTGEN & STRAHLENSCHUTZ ----------
  FachgespraechFrage(
    id: 'fg13',
    bereich: 'Röntgen',
    emoji: '🩻',
    frage: 'Was müssen Sie beim Röntgen und beim Strahlenschutz beachten?',
    stichpunkte: [
      'rechtfertigende Indikation durch den Zahnarzt',
      'so wenig Strahlung wie möglich (ALARA-Prinzip)',
      'Schwangerschaft erfragen, Schutzmaßnahmen',
      'Aufnahmen dokumentieren, Röntgenpass / Aufzeichnungspflicht',
    ],
    musterantwort:
        'Geröntgt wird nur, wenn der Zahnarzt eine rechtfertigende Indikation stellt – es muss also einen medizinischen Grund geben. '
        'Es gilt das Prinzip, so wenig Strahlung wie möglich einzusetzen. Ich frage bei Frauen nach einer möglichen Schwangerschaft und sorge für Schutzmaßnahmen. '
        'Jede Aufnahme wird mit Datum und Begründung dokumentiert, denn es besteht Aufzeichnungspflicht.',
  ),

  // ---------- NOTFALL ----------
  FachgespraechFrage(
    id: 'fg14',
    bereich: 'Notfall',
    emoji: '🚑',
    frage: 'Ein Patient wird im Wartezimmer ohnmächtig. Wie reagieren Sie?',
    stichpunkte: [
      'Bewusstsein und Atmung prüfen, laut um Hilfe rufen',
      'bei Atmung: stabile Seitenlage / Beine hochlagern (Kreislaufkollaps)',
      'bei fehlender Atmung: Notruf 112 und Reanimation 30:2',
      'Behandler informieren, Notfallkoffer holen, betreuen',
    ],
    musterantwort:
        'Ich spreche den Patienten an und prüfe Bewusstsein und Atmung, und ich rufe sofort laut um Hilfe und informiere den Zahnarzt. '
        'Bei einem einfachen Kreislaufkollaps mit vorhandener Atmung lagere ich die Beine hoch. '
        'Atmet der Patient nicht, setze ich den Notruf 112 ab und beginne mit der Herz-Lungen-Wiederbelebung im Verhältnis dreißig zu zwei. '
        'Ich hole den Notfallkoffer und bleibe beim Patienten, bis der Notarzt da ist.',
  ),
  FachgespraechFrage(
    id: 'fg15',
    bereich: 'Notfall',
    emoji: '🩸',
    frage: 'Was gehört in einen Notfallkoffer und warum ist die Erreichbarkeit wichtig?',
    stichpunkte: [
      'Beatmungsbeutel, Sauerstoff, Guedeltubus',
      'Notfallmedikamente, Blutdruckmessgerät, Verbandmaterial',
      'regelmäßig auf Vollständigkeit und Verfallsdaten prüfen',
      'für alle griffbereit und der Standort bekannt',
    ],
    musterantwort:
        'Im Notfallkoffer sind unter anderem ein Beatmungsbeutel, Sauerstoff, ein Guedeltubus, Notfallmedikamente, ein Blutdruckmessgerät und Verbandmaterial. '
        'Der Koffer muss für alle griffbereit sein und jeder im Team muss seinen Standort kennen. '
        'Ich prüfe ihn regelmäßig auf Vollständigkeit und Verfallsdaten, damit im Ernstfall alles funktioniert.',
  ),

  // ---------- DOKUMENTATION ----------
  FachgespraechFrage(
    id: 'fg16',
    bereich: 'Dokumentation',
    emoji: '📋',
    frage: 'Was und warum müssen Sie eine Behandlung dokumentieren?',
    stichpunkte: [
      'Was, Womit, Welche Charge, Wer (die 4 Ws)',
      'Chargennummern für Rückverfolgbarkeit',
      'Allergien und Besonderheiten',
      'rechtlicher Nachweis – was nicht dokumentiert ist, gilt als nicht gemacht',
    ],
    musterantwort:
        'Ich dokumentiere, was gemacht wurde, womit, mit welcher Chargennummer und wer behandelt hat – das sind die vier Ws. '
        'Die Chargennummern sind wichtig, damit Materialien rückverfolgbar sind, und ich vermerke Allergien und Besonderheiten. '
        'Die Dokumentation ist auch ein rechtlicher Nachweis: Was nicht dokumentiert ist, gilt im Streitfall als nicht durchgeführt.',
  ),

  // ---------- ABRECHNUNG ----------
  FachgespraechFrage(
    id: 'fg17',
    bereich: 'Abrechnung',
    emoji: '🧾',
    frage: 'Erklären Sie den Unterschied zwischen BEMA und GOZ und was ein Heil- und Kostenplan ist.',
    stichpunkte: [
      'BEMA für gesetzlich Versicherte',
      'GOZ für privatzahnärztliche Leistungen',
      'HKP plant Zahnersatz und Kosten',
      'Festzuschuss der Kasse, Bonusheft erhöht ihn',
    ],
    musterantwort:
        'Der BEMA ist der Leistungskatalog für gesetzlich Versicherte, die GOZ ist die Gebührenordnung für private Leistungen. '
        'Beim Zahnersatz wird ein Heil- und Kostenplan erstellt, der zeigt, was geplant ist und was es kostet; die Kasse muss ihn genehmigen. '
        'Die Kasse zahlt einen Festzuschuss, und mit einem gepflegten Bonusheft erhöht sich dieser Zuschuss.',
  ),

  // ---------- ARBEITSSCHUTZ ----------
  FachgespraechFrage(
    id: 'fg18',
    bereich: 'Arbeitsschutz',
    emoji: '🦺',
    frage: 'Welche persönliche Schutzausrüstung tragen Sie und wie verhalten Sie sich bei einer Nadelstichverletzung?',
    stichpunkte: [
      'PSA: Handschuhe, Mund-Nasen-Schutz, Schutzbrille, Schutzkleidung',
      'Nadelstich: Wunde bluten lassen, desinfizieren',
      'Durchgangsarzt / Betriebsarzt aufsuchen, dokumentieren',
      'Infektionsrisiko abklären',
    ],
    musterantwort:
        'Zur persönlichen Schutzausrüstung gehören Handschuhe, Mund-Nasen-Schutz, Schutzbrille und Schutzkleidung. '
        'Bei einer Nadelstichverletzung lasse ich die Wunde zunächst bluten, desinfiziere sie gründlich und suche den Durchgangs- oder Betriebsarzt auf. '
        'Der Vorfall wird dokumentiert und das Infektionsrisiko wird abgeklärt.',
  ),
  FachgespraechFrage(
    id: 'fg19',
    bereich: 'Empfang',
    emoji: '😟',
    frage: 'Ein Patient hat große Angst vor der Behandlung. Wie gehen Sie mit ihm um?',
    stichpunkte: [
      'ruhig, freundlich und verständnisvoll bleiben',
      'zuhören und Ängste ernst nehmen',
      'Ablauf erklären, Sicherheit geben',
      'Signale vereinbaren, Behandler informieren',
    ],
    musterantwort:
        'Ich bleibe ruhig, freundlich und nehme die Angst des Patienten ernst. Ich höre ihm zu und erkläre ihm den Ablauf in einfachen Worten, '
        'damit er weiß, was auf ihn zukommt. Oft hilft es, ein Handzeichen zu vereinbaren, mit dem er jederzeit eine Pause signalisieren kann. '
        'Ich informiere den Behandler über die Angst, damit besonders einfühlsam vorgegangen wird.',
  ),
  FachgespraechFrage(
    id: 'fg20',
    bereich: 'Behandlungsassistenz',
    emoji: '🪥',
    frage: 'Warum werden bei einer Wurzelkanalbehandlung oft zwei Trays verwendet?',
    stichpunkte: [
      'Trennung von sterilem und unsterilem Material',
      'Kanal soll keimfrei bleiben',
      'steriles Tray: Feilen, Füllmaterial',
      'unsteriles Tray: Vorbereitung, Röntgenhilfen',
    ],
    musterantwort:
        'Bei der Wurzelkanalbehandlung arbeitet man oft mit zwei Trays, um steriles und unsteriles Material klar zu trennen. '
        'Auf dem sterilen Tray liegen zum Beispiel die Feilen und das Füllmaterial, auf dem unsterilen die Sachen für die Vorbereitung. '
        'So verhindere ich, dass Keime in den Wurzelkanal gelangen, und der Kanal bleibt sauber.',
  ),
];

// Alle Themenbereiche des Fachgesprächs (für Filter/Auswahl).
List<String> fachgespraechBereiche() {
  final set = <String>{};
  for (final f in alleFachgespraeche) {
    set.add(f.bereich);
  }
  return set.toList();
}
