/// Eine Frage für das mündliche Fachgespräch der ZFA-Abschlussprüfung.
/// Der Prüfer stellt die [frage]; die Antwort sollte die [stichpunkte]
/// enthalten. Die [musterantwort] ist ein vollständiges, laut vorlesbares
/// Beispiel in natürlicher Sprache.
class FachgespraechFrage {
  final String id;
  final String bereich;
  final String emoji;
  final String frage;
  final List<String> stichpunkte; // Was MUSS in der Antwort vorkommen?
  final String musterantwort; // Vollständige Beispielantwort

  const FachgespraechFrage({
    required this.id,
    required this.bereich,
    required this.emoji,
    required this.frage,
    required this.stichpunkte,
    required this.musterantwort,
  });
}
