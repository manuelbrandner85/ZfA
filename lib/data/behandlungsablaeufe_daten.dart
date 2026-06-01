import '../models/behandlungsablauf.dart';

// ============================================================
// ALLE BEHANDLUNGSABLÄUFE – Schritt für Schritt.
// Kern für die praktische und mündliche Abschlussprüfung.
// ============================================================

const List<Behandlungsablauf> alleBehandlungsablaeufe = [
  // 1 -----------------------------------------------------
  Behandlungsablauf(
    id: 'ab01',
    emoji: '🏠',
    titel: 'Patientenannahme & Empfang',
    untertitel: 'Der erste Eindruck',
    bereich: 'Anmeldung',
    indikation: 'Bei jedem Patientenkontakt zu Beginn.',
    phasen: [
      AblaufPhase('Empfang', [
        'Patienten freundlich mit Blickkontakt und Namen begrüßen.',
        'Bei gesetzlich Versicherten die eGK einmal pro Quartal einlesen.',
        'Bei Neupatienten eine Karteikarte anlegen.',
      ]),
      AblaufPhase('Anamnese & Aufklärung', [
        'Anamnesebogen ausfüllen lassen oder aktualisieren.',
        'Vorerkrankungen, Allergien und Medikamente erfragen.',
        'Besonderheiten (Diabetes, Gerinnungshemmer) an den Behandler weitergeben.',
        'Aufklärung sicherstellen und unterschreiben lassen.',
      ]),
      AblaufPhase('Abschluss', [
        'Über Ablauf und Wartezeit informieren.',
        'Datenschutz und Schweigepflicht beachten.',
      ]),
    ],
  ),

  // 2 -----------------------------------------------------
  Behandlungsablauf(
    id: 'ab02',
    emoji: '🪑',
    titel: 'Behandlungszimmer vorbereiten',
    untertitel: 'Sauber starten',
    bereich: 'Hygiene',
    indikation: 'Vor jeder Behandlung, nach jedem Patienten.',
    phasen: [
      AblaufPhase('Flächen & Schutz', [
        'Alle Flächen mit Flächendesinfektion wischen, Einwirkzeit beachten.',
        'Schutzbezüge erneuern: Kopfstütze, Griffe, Schläuche.',
        'Wasser führende Systeme kurz durchspülen.',
      ]),
      AblaufPhase('Bereitstellen', [
        'Grundbesteck bereitlegen: Mundspiegel, Sonde, Pinzette.',
        'Benötigte Instrumente und Materialien für die geplante Behandlung richten.',
        'Sauger und Absaugung anschließen und prüfen.',
      ]),
      AblaufPhase('Abschluss', [
        'Erst am Ende der Aufbereitung lüften – nicht zu Beginn.',
      ]),
    ],
  ),

  // 3 -----------------------------------------------------
  Behandlungsablauf(
    id: 'ab03',
    emoji: '🧼',
    titel: 'Händedesinfektion & PSA',
    untertitel: 'Schutz für alle',
    bereich: 'Hygiene',
    indikation: 'Vor und nach jedem Patientenkontakt.',
    phasen: [
      AblaufPhase('Händedesinfektion', [
        'Schmuck, Ringe und Uhr ablegen, Nägel kurz und unlackiert.',
        'Drei bis fünf Milliliter Mittel in die hohle Hand geben.',
        'Mindestens 30 Sekunden einreiben, Hände dauerhaft feucht halten.',
        'Fingerzwischenräume, Daumen, Fingerkuppen und Nägel einbeziehen.',
      ]),
      AblaufPhase('PSA anlegen', [
        'Erst nach der Händedesinfektion Handschuhe anziehen.',
        'Mund-Nasen-Schutz und Schutzbrille tragen.',
        'Schutzkleidung anlegen.',
      ]),
    ],
  ),

  // 4 -----------------------------------------------------
  Behandlungsablauf(
    id: 'ab04',
    emoji: '♨️',
    titel: 'Instrumentenaufbereitung',
    untertitel: 'Von unrein nach rein',
    bereich: 'Hygiene',
    indikation: 'Nach jeder Benutzung von Instrumenten.',
    phasen: [
      AblaufPhase('Vorbereitung & Reinigung', [
        'Direkt nach Gebrauch vorreinigen oder in Desinfektionslösung legen.',
        'Reinigen, am besten im Reinigungs- und Desinfektionsgerät (RDG).',
        'Immer von unrein nach rein arbeiten – niemals zurück.',
      ]),
      AblaufPhase('Kontrolle & Verpackung', [
        'Instrumente auf Sauberkeit und Funktion prüfen, pflegen.',
        'In Klarsichtbeutel verpacken.',
      ]),
      AblaufPhase('Sterilisation & Freigabe', [
        'Im Autoklav mit Dampf bei 134 Grad sterilisieren.',
        'Verpackung mit Datum und Chargennummer beschriften.',
        'Sterilgut dokumentieren und sachgerecht lagern (Freigabe).',
      ]),
    ],
  ),

  // 5 -----------------------------------------------------
  Behandlungsablauf(
    id: 'ab05',
    emoji: '💉',
    titel: 'Lokalanästhesie',
    untertitel: 'Infiltration & Leitung',
    bereich: 'Anästhesie',
    indikation: 'Vor schmerzhaften Eingriffen zur Betäubung.',
    phasen: [
      AblaufPhase('Vorbereitung', [
        'Anamnese auf Herz-Kreislauf und Allergien prüfen.',
        'Karpule, passende Kanüle und Spritze bereitlegen.',
        'Kurze Kanüle für die Infiltration, lange Kanüle für die Leitung.',
        'Oberflächenanästhesie mit Gel oder Spray vorbereiten.',
      ]),
      AblaufPhase('Assistenz', [
        'Einstichstelle trocknen und Oberflächengel auftragen.',
        'Fertige Spritze sicher mit Schutzkappe griffbereit anreichen.',
        'Patienten beruhigen, während injiziert wird.',
      ]),
      AblaufPhase('Nachsorge', [
        'Auf Wirkung warten und Befinden beobachten.',
        'Hinweis: nicht auf die taube Lippe oder Wange beißen.',
        'Kanüle sicher im durchstichsicheren Behälter entsorgen.',
      ]),
    ],
  ),

  // 6 -----------------------------------------------------
  Behandlungsablauf(
    id: 'ab06',
    emoji: '🦷',
    titel: 'Kariesexkavation & Kompositfüllung',
    untertitel: 'Das Loch versorgen',
    bereich: 'Karies',
    indikation: 'Bei Karies zur Wiederherstellung des Zahns.',
    phasen: [
      AblaufPhase('Vorbereitung', [
        'Tray mit Bohrern, Komposit, Ätzgel, Bonding und Matrize richten.',
        'Polymerisationslampe und Schutzbrille bereitstellen.',
        'Nach Betäubung den Zahn trockenlegen, idealerweise mit Kofferdam.',
      ]),
      AblaufPhase('Durchführung', [
        'Karies wird ausgebohrt, Assistenz saugt ab und kühlt mit Wasser.',
        'Zahn wird angeätzt, dann wird das Bonding aufgetragen.',
        'Komposit in Schichten einbringen und mit Licht aushärten.',
      ]),
      AblaufPhase('Abschluss', [
        'Füllung ausarbeiten und polieren.',
        'Biss (Okklusion) prüfen, damit die Füllung nicht zu hoch steht.',
        'Material und Chargennummern dokumentieren.',
      ]),
    ],
  ),

  // 7 -----------------------------------------------------
  Behandlungsablauf(
    id: 'ab07',
    emoji: '🪥',
    titel: 'Wurzelkanalbehandlung',
    untertitel: 'Endodontie',
    bereich: 'Behandlungsassistenz',
    indikation: 'Bei entzündetem oder abgestorbenem Zahnnerv.',
    phasen: [
      AblaufPhase('Vorbereitung', [
        'Zwei Trays richten: ein unsteriles und ein steriles.',
        'Feilen, Spüllösung, Guttapercha und Röntgenhilfen bereitlegen.',
        'Nach Betäubung Kofferdam anlegen.',
      ]),
      AblaufPhase('Durchführung', [
        'Zahn wird von oben eröffnet (Trepanation).',
        'Kanäle werden mit Feilen gereinigt und erweitert.',
        'Zwischendurch wird gespült, die Länge wird elektrisch gemessen.',
        'Kanal wird getrocknet und mit Guttapercha dicht gefüllt.',
      ]),
      AblaufPhase('Abschluss', [
        'Zahn provisorisch oder definitiv verschließen.',
        'Kontrolle planen, Behandlung dokumentieren.',
      ]),
    ],
  ),

  // 8 -----------------------------------------------------
  Behandlungsablauf(
    id: 'ab08',
    emoji: '🦷',
    titel: 'Zahnextraktion',
    untertitel: 'Zahn ziehen',
    bereich: 'Chirurgie',
    indikation: 'Wenn ein Zahn nicht mehr erhalten werden kann.',
    phasen: [
      AblaufPhase('Vorbereitung', [
        'Hebel und passende Extraktionszange steril bereitlegen.',
        'Tupfer, Sauger und ggf. Nahtmaterial richten.',
        'Betäuben und Patienten abdecken.',
      ]),
      AblaufPhase('Durchführung', [
        'Zahn wird mit dem Hebel gelöst.',
        'Mit der Zange wird der Zahn entfernt, Assistenz saugt ab.',
        'Wunde kontrollieren, bei Bedarf naht der Zahnarzt.',
      ]),
      AblaufPhase('Nachbereitung (A-M-I-W-L)', [
        'Aufklären: Verhaltensregeln erklären.',
        'Medikamente und Schmerzmittel mitgeben.',
        'Instrumente aufbereiten.',
        'Wunde kontrollieren, Tupfer aufbeißen lassen, kühlen.',
        'Lüften und Zimmer reinigen.',
      ]),
    ],
  ),

  // 9 -----------------------------------------------------
  Behandlungsablauf(
    id: 'ab09',
    emoji: '🔪',
    titel: 'Operative Zahnentfernung & Naht',
    untertitel: 'Osteotomie',
    bereich: 'Chirurgie',
    indikation: 'Bei verlagerten Zähnen, z. B. Weisheitszähnen.',
    phasen: [
      AblaufPhase('Vorbereitung', [
        'Steriles chirurgisches Tray: Skalpell, Raspatorium, Fräse, Nadelhalter.',
        'Sterile Abdeckung, Kochsalzlösung und Sauger bereitstellen.',
        'Betäuben, steril abdecken, steril anreichen.',
      ]),
      AblaufPhase('Durchführung', [
        'Zahnfleisch wird eröffnet und der Knochen dargestellt.',
        'Zahn wird ggf. getrennt und entfernt, gekühlt und abgesaugt.',
        'Wunde säubern und mit Naht verschließen.',
      ]),
      AblaufPhase('Nachsorge', [
        'Kühlen, Verhaltensregeln und Medikamente mitgeben.',
        'Termin zur Nahtentfernung vereinbaren.',
        'Eingriff und Chargennummern dokumentieren.',
      ]),
    ],
  ),

  // 10 ----------------------------------------------------
  Behandlungsablauf(
    id: 'ab10',
    emoji: '🩸',
    titel: 'Parodontalbehandlung',
    untertitel: 'Scaling & Root Planing',
    bereich: 'Parodontitis',
    indikation: 'Bei Parodontitis mit vertieften Taschen.',
    phasen: [
      AblaufPhase('Vorbereitung & Befund', [
        'Taschentiefen mit der PAR-Sonde messen und dokumentieren.',
        'Scaler, Küretten und Ultraschallgerät bereitlegen.',
        'Mundhygiene-Status erheben.',
      ]),
      AblaufPhase('Durchführung', [
        'Beläge und Zahnstein ober- und unterhalb des Zahnfleischs entfernen.',
        'Wurzeloberflächen glätten (Root Planing), Assistenz saugt ab.',
      ]),
      AblaufPhase('Nachsorge', [
        'Mundhygiene instruieren und motivieren.',
        'Nachsorgetermine (UPT) planen.',
      ]),
    ],
  ),

  // 11 ----------------------------------------------------
  Behandlungsablauf(
    id: 'ab11',
    emoji: '✨',
    titel: 'Professionelle Zahnreinigung',
    untertitel: 'PZR',
    bereich: 'Prophylaxe',
    indikation: 'Zur Vorbeugung von Karies und Parodontitis.',
    phasen: [
      AblaufPhase('Vorbereitung', [
        'Anfärben der Beläge, Mundhygiene-Status erheben.',
        'Ultraschall, Pulverstrahl, Polierpaste und Bürstchen richten.',
      ]),
      AblaufPhase('Durchführung', [
        'Zahnstein und Beläge entfernen.',
        'Verfärbungen mit Pulverstrahl entfernen.',
        'Zähne polieren und Zahnzwischenräume reinigen.',
      ]),
      AblaufPhase('Abschluss', [
        'Fluoridierung auftragen.',
        'Mundhygiene-Tipps geben, Recall planen.',
      ]),
    ],
  ),

  // 12 ----------------------------------------------------
  Behandlungsablauf(
    id: 'ab12',
    emoji: '🛡️',
    titel: 'Fissurenversiegelung & Fluoridierung',
    untertitel: 'Kariesschutz',
    bereich: 'Prophylaxe',
    indikation: 'Zum Schutz tiefer Fissuren, meist bei Jugendlichen.',
    phasen: [
      AblaufPhase('Vorbereitung', [
        'Zahn reinigen und absolut trockenlegen.',
        'Ätzgel, Versiegler und Polymerisationslampe richten.',
      ]),
      AblaufPhase('Durchführung', [
        'Fissuren anätzen, absprühen und trocknen.',
        'Versiegler auftragen und mit Licht aushärten.',
        'Bei der Fluoridierung Lack oder Gel auftragen.',
      ]),
      AblaufPhase('Abschluss', [
        'Biss prüfen, Hinweise zur Nahrungskarenz geben.',
        'Maßnahme dokumentieren.',
      ]),
    ],
  ),

  // 13 ----------------------------------------------------
  Behandlungsablauf(
    id: 'ab13',
    emoji: '🧒',
    titel: 'Individualprophylaxe (IP/FU)',
    untertitel: 'Vorsorge für Kinder',
    bereich: 'Prophylaxe',
    indikation: 'Früherkennung und Vorsorge bei Kindern und Jugendlichen.',
    phasen: [
      AblaufPhase('Früherkennung (FU)', [
        'Mund untersuchen und Befund aufnehmen.',
        'Eltern und Kind altersgerecht beraten.',
      ]),
      AblaufPhase('Individualprophylaxe (IP)', [
        'Mundhygiene anfärben und kontrollieren.',
        'Putztechnik üben und motivieren.',
        'Ernährungsberatung geben und fluoridieren.',
      ]),
    ],
  ),

  // 14 ----------------------------------------------------
  Behandlungsablauf(
    id: 'ab14',
    emoji: '🦷',
    titel: 'Abformung',
    untertitel: 'Alginat & Silikon',
    bereich: 'Behandlungsassistenz',
    indikation: 'Zur Herstellung von Modellen für Zahnersatz oder Schienen.',
    phasen: [
      AblaufPhase('Vorbereitung', [
        'Passenden Abformlöffel auswählen und anprobieren.',
        'Abformmaterial nach Vorschrift anmischen.',
      ]),
      AblaufPhase('Durchführung', [
        'Löffel mit Material füllen und reichen.',
        'Patienten zur Nasenatmung anleiten, beruhigen.',
        'Abbindezeit abwarten, dann Löffel entnehmen.',
      ]),
      AblaufPhase('Abschluss', [
        'Abformung auf Vollständigkeit prüfen, desinfizieren.',
        'Mit Auftrag ins Labor geben.',
      ]),
    ],
  ),

  // 15 ----------------------------------------------------
  Behandlungsablauf(
    id: 'ab15',
    emoji: '👑',
    titel: 'Krone & Brücke',
    untertitel: 'Festsitzender Zahnersatz',
    bereich: 'Behandlungsassistenz',
    indikation: 'Bei stark zerstörten Zähnen oder Lücken.',
    phasen: [
      AblaufPhase('Sitzung 1 – Präparation', [
        'Heil- und Kostenplan vorbereiten, Zahn beschleifen.',
        'Abformung nehmen und Farbe bestimmen.',
        'Provisorium herstellen und eingliedern.',
      ]),
      AblaufPhase('Sitzung 2 – Eingliederung', [
        'Provisorium entfernen, Zahn reinigen und trockenlegen.',
        'Passung und Biss der Krone prüfen.',
        'Krone mit Zement oder adhäsiv befestigen.',
      ]),
      AblaufPhase('Abschluss', [
        'Zementreste entfernen, Pflegehinweise geben.',
        'Dokumentation und Abrechnung.',
      ]),
    ],
  ),

  // 16 ----------------------------------------------------
  Behandlungsablauf(
    id: 'ab16',
    emoji: '🦷',
    titel: 'Prothese / Zahnersatz',
    untertitel: 'Herausnehmbar',
    bereich: 'Behandlungsassistenz',
    indikation: 'Wenn viele oder alle Zähne fehlen.',
    phasen: [
      AblaufPhase('Herstellung', [
        'Erste Abformung, dann Funktionsabformung.',
        'Bisslage bestimmen, Zähne zur Anprobe aufstellen.',
        'Ästhetik und Biss mit dem Patienten kontrollieren.',
      ]),
      AblaufPhase('Eingliederung', [
        'Fertige Prothese einsetzen und Druckstellen prüfen.',
        'Handhabung, Reinigung und Eingewöhnung erklären.',
        'Kontrolltermine vereinbaren.',
      ]),
    ],
  ),

  // 17 ----------------------------------------------------
  Behandlungsablauf(
    id: 'ab17',
    emoji: '🔩',
    titel: 'Implantation – Assistenz',
    untertitel: 'Künstliche Wurzel',
    bereich: 'Chirurgie',
    indikation: 'Zum Ersatz einzelner oder mehrerer Zähne.',
    phasen: [
      AblaufPhase('Vorbereitung', [
        'Strenge Sterilität, OP-Bereich steril abdecken.',
        'Implantatset, Bohrer und gekühlte Kochsalzlösung bereitstellen.',
      ]),
      AblaufPhase('Durchführung', [
        'Zahnfleisch eröffnen, Implantatbett schrittweise aufbohren, dabei kühlen.',
        'Implantat einbringen, Abdeckung setzen, Wunde vernähen.',
      ]),
      AblaufPhase('Nachsorge', [
        'Kühlen, Verhaltensregeln und Medikamente mitgeben.',
        'Einheilzeit erklären, Nahtentfernung planen, dokumentieren.',
      ]),
    ],
  ),

  // 18 ----------------------------------------------------
  Behandlungsablauf(
    id: 'ab18',
    emoji: '🩻',
    titel: 'Röntgen anfertigen',
    untertitel: 'Mit Strahlenschutz',
    bereich: 'Behandlungsassistenz',
    indikation: 'Zur Diagnostik – nur mit rechtfertigender Indikation.',
    phasen: [
      AblaufPhase('Vorbereitung', [
        'Rechtfertigende Indikation durch den Zahnarzt sicherstellen.',
        'Schwangerschaft erfragen, so wenig Strahlung wie möglich.',
        'Sensor oder Film und Halter vorbereiten.',
      ]),
      AblaufPhase('Aufnahme', [
        'Patienten positionieren, Schutzmaßnahmen beachten.',
        'Strahlenfeld einstellen und auslösen.',
      ]),
      AblaufPhase('Abschluss', [
        'Aufnahme prüfen und entwickeln bzw. speichern.',
        'Datum, Begründung und Werte dokumentieren (Aufzeichnungspflicht).',
      ]),
    ],
  ),

  // 19 ----------------------------------------------------
  Behandlungsablauf(
    id: 'ab19',
    emoji: '🚑',
    titel: 'Notfallmanagement',
    untertitel: 'Schnell und sicher',
    bereich: 'Notfall',
    indikation: 'Bei Kollaps, Unterzucker, Allergie oder Atemstillstand.',
    phasen: [
      AblaufPhase('Erkennen', [
        'Bewusstsein und Atmung prüfen, laut um Hilfe rufen.',
        'Behandler informieren, Notfallkoffer holen.',
      ]),
      AblaufPhase('Handeln', [
        'Kreislaufkollaps: flach lagern, Beine hochlegen.',
        'Unterzucker: bei Bewusstsein Zucker geben.',
        'Kein Atem: Notruf 112 und Reanimation 30 zu 2 beginnen.',
      ]),
      AblaufPhase('Nachsorge', [
        'Patienten bis zum Eintreffen des Notarztes betreuen.',
        'Vorfall dokumentieren, Notfallkoffer wieder auffüllen.',
      ]),
    ],
  ),

  // 20 ----------------------------------------------------
  Behandlungsablauf(
    id: 'ab20',
    emoji: '📋',
    titel: 'Verabschiedung, Recall & Doku',
    untertitel: 'Sauberer Abschluss',
    bereich: 'Anmeldung',
    indikation: 'Am Ende jeder Behandlung.',
    phasen: [
      AblaufPhase('Verabschiedung', [
        'Offene Fragen klären, Rezept oder Bescheinigung mitgeben.',
        'Nächsten Termin vereinbaren, Recall-Hinweis geben.',
        'Freundlich verabschieden – der letzte Eindruck zählt.',
      ]),
      AblaufPhase('Dokumentation (4 Ws)', [
        'Was wurde gemacht?',
        'Womit wurde es gemacht?',
        'Welche Charge (Chargennummern)?',
        'Wer hat behandelt?',
      ]),
      AblaufPhase('Abrechnung', [
        'Leistungen nach BEMA (gesetzlich) oder GOZ (privat) erfassen.',
        'Bei Zahnersatz den Heil- und Kostenplan berücksichtigen.',
      ]),
    ],
  ),
];
