/// Eine Phase eines Behandlungsablaufs mit ihren einzelnen Schritten.
class AblaufPhase {
  final String titel; // z. B. "Vorbereitung", "Durchführung", "Nachbereitung"
  final List<String> schritte;
  const AblaufPhase(this.titel, this.schritte);
}

/// Ein vollständiger Behandlungsablauf Schritt für Schritt – die Grundlage
/// für die praktische und mündliche Abschlussprüfung.
class Behandlungsablauf {
  final String id;
  final String emoji;
  final String titel;
  final String untertitel;
  final String bereich;
  final String indikation; // Wann / warum?
  final List<AblaufPhase> phasen;

  const Behandlungsablauf({
    required this.id,
    required this.emoji,
    required this.titel,
    required this.untertitel,
    required this.bereich,
    required this.indikation,
    required this.phasen,
  });

  int get anzahlSchritte =>
      phasen.fold(0, (sum, p) => sum + p.schritte.length);

  /// Alle Schritte als ein vorlesbarer Text (für die Sprachausgabe).
  List<String> alleSaetze() => [
        'Ablauf: $titel.',
        if (indikation.isNotEmpty) 'Wann: $indikation',
        for (final p in phasen) ...[
          '${p.titel}:',
          ...p.schritte,
        ],
      ];
}
