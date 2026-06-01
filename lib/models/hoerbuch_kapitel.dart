import 'package:flutter/material.dart';

class HoerbuchKapitel {
  final String id;
  final String emoji;
  final String titel;
  final String untertitel;
  final Color farbe;
  final String bereich;
  final List<String> saetze; // Jeder Satz einzeln für Karaoke!

  const HoerbuchKapitel({
    required this.id,
    required this.emoji,
    required this.titel,
    required this.untertitel,
    required this.farbe,
    required this.bereich,
    required this.saetze,
  });

  int get anzahlSaetze => saetze.length;

  // Geschätzte Minuten (bei 0.45x Geschwindigkeit ~= 3 Wörter/Sekunde)
  int get minutenGeschaetzt {
    final woerter = saetze.join(' ').split(' ').length;
    return (woerter / 180).ceil(); // 180 Wörter/Minute bei langsamer Geschwindigkeit
  }
}
