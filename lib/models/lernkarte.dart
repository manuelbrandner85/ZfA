class Lernkarte {
  final String id;
  final String vorderseite; // Kurzer Begriff oder Frage (max 10 Wörter!)
  final String rueckseite; // Kurze Antwort (max 2 Sätze!)
  final String einfachVersion; // Alltagssprache
  final String emoji;
  final String bereich;
  int leitnerBox; // 1-5 für Spaced Repetition

  Lernkarte({
    required this.id,
    required this.vorderseite,
    required this.rueckseite,
    required this.einfachVersion,
    required this.emoji,
    required this.bereich,
    this.leitnerBox = 1,
  });
}
