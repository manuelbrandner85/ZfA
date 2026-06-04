/// Großzügiger Textabgleich für die Sprach-Auswertung.
/// Erkennt Wortstämme/Beugungen ("betäuben" ~ "Betäubung"), ignoriert
/// Stoppwörter und kennt einige fachliche Synonyme.
class TextMatch {
  static const _stopp = {
    'und', 'oder', 'der', 'die', 'das', 'ein', 'eine', 'einen', 'einem',
    'eines', 'dem', 'den', 'des', 'mit', 'für', 'von', 'bei', 'auf', 'aus',
    'zum', 'zur', 'ist', 'sind', 'wird', 'werden', 'nach', 'vor', 'über',
    'unter', 'sowie', 'beim', 'durch', 'wenn', 'dann', 'also', 'noch', 'auch',
    'aber', 'wie', 'man', 'wir', 'sie', 'ich', 'dass', 'sich', 'sein',
    'kann', 'muss', 'soll', 'wegen', 'damit', 'danach',
    'dabei', 'immer', 'etwas', 'gegen', 'falls', 'mögliche',
  };

  // Stämme, die als gleichwertig gelten (Synonyme/Umschreibungen).
  static const List<List<String>> _synonyme = [
    ['betäub', 'anästh', 'lokalan'],
    ['desinf', 'desinfiz'],
    ['steril', 'autokl'],
    ['handsch'],
    ['mundsch', 'maske', 'mund-na'],
    ['schutzb', 'brille'],
    ['absaug', 'sauger', 'saugen'],
    ['präpar', 'bohren', 'ausbohr', 'bohrer'],
    ['füllung', 'kompos'],
    ['röntg'],
    ['dokument', 'eintrag', 'notier'],
    ['verabsch', 'entlass'],
    ['naht', 'nähen', 'vernäh', 'wundvers'],
    ['extrah', 'ziehen', 'entfern'],
    ['spülen', 'spülung'],
    ['trockn', 'trocken'],
    ['kühlen', 'kühlung'],
    ['einverst', 'aufklär', 'einwillig'],
    ['versich', 'karte', 'egk'],
    ['anamnes'],
  ];

  /// Reduziert ein Wort auf einen groben Stamm (entfernt häufige Endungen).
  static String stamm(String w) {
    const endungen = [
      'ungen', 'enden', 'erung', 'lichen', 'ische', 'isch', 'ungs', 'keit',
      'lich', 'ende', 'end', 'ung', 'tion', 'eren', 'iert', 'est', 'ten',
      'te', 'st', 'en', 'er', 'es', 'em', 'et', 'e', 's', 'n', 't'
    ];
    for (final e in endungen) {
      if (w.length - e.length >= 4 && w.endsWith(e)) {
        return w.substring(0, w.length - e.length);
      }
    }
    return w;
  }

  /// Bedeutsame Stämme aus einem Text (Kleinbuchstaben, ohne Stoppwörter).
  static Set<String> staemme(String text) {
    final out = <String>{};
    final woerter = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zäöüß ]'), ' ')
        .split(RegExp(r'\s+'));
    for (final w in woerter) {
      if (w.length < 4 || _stopp.contains(w)) continue;
      final s = stamm(w);
      if (s.length >= 4) out.add(s);
    }
    return out;
  }

  /// Wurde [schritt] im gesprochenen Text genannt? Sehr großzügig:
  /// trifft, wenn irgendein bedeutsamer Stamm des Schritts (oder ein
  /// Synonym davon) im gesprochenen Text/Stämmen vorkommt.
  static bool genannt(String schritt, String gesprochen, Set<String> gespStaemme) {
    final gesprochenKlein = gesprochen.toLowerCase();
    final schrittStaemme = staemme(schritt);
    if (schrittStaemme.isEmpty) return false;

    for (final st in schrittStaemme) {
      // direkter (Teil-)Treffer im gesprochenen Text
      final kurz = st.length > 5 ? st.substring(0, 5) : st;
      if (gesprochenKlein.contains(kurz)) return true;
      // Stamm-Vergleich in beide Richtungen
      for (final gs in gespStaemme) {
        if (gs == st || gs.startsWith(kurz) || st.startsWith(gs)) return true;
      }
      // Synonyme
      for (final gruppe in _synonyme) {
        final schrittIn = gruppe.any((g) => st.startsWith(g) || g.startsWith(kurz));
        if (!schrittIn) continue;
        final gesprochenIn = gruppe.any((g) => gesprochenKlein.contains(g) ||
            gespStaemme.any((x) => x.startsWith(g) || g.startsWith(x)));
        if (gesprochenIn) return true;
      }
    }
    return false;
  }
}
