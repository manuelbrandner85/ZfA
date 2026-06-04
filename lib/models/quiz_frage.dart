class QuizFrage {
  final String id;
  final String frage;
  final String einfacheErklaerung; // Alltagssprache mit Emoji
  final String? merkhilfe; // Kurze Eselsbrücke (max 1 Satz!)
  final List<String> antworten;
  final int richtigeAntwortIndex;
  final String erklaerung; // Warum ist das richtig?
  final String bereich;
  final String schwierigkeit; // 'leicht', 'mittel', 'schwer'
  final List<String> schluesselwoerter; // Für Sprach-Quiz

  const QuizFrage({
    required this.id,
    required this.frage,
    required this.einfacheErklaerung,
    this.merkhilfe,
    required this.antworten,
    required this.richtigeAntwortIndex,
    required this.erklaerung,
    required this.bereich,
    this.schwierigkeit = 'mittel',
    this.schluesselwoerter = const [],
  });
}
