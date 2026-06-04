import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Zentrale App-Einstellungen (persistiert).
class EinstellungenService {
  // Textgröße als Skalierungsfaktor (Barrierefreiheit). 1.0 = normal.
  final ValueNotifier<double> textSkala = ValueNotifier(1.0);
  // Bestehensgrenze in Prozent (Notenschlüssel).
  int bestehensGrenze = 50;
  // Name des Lernenden.
  String name = '';
  // Wurde das Onboarding abgeschlossen?
  bool onboardingFertig = false;

  Future<void> laden() async {
    final p = await SharedPreferences.getInstance();
    textSkala.value = p.getDouble('text_skala') ?? 1.0;
    bestehensGrenze = p.getInt('bestehensgrenze') ?? 50;
    name = p.getString('nutzer_name') ?? '';
    onboardingFertig = p.getBool('onboarding_fertig') ?? false;
  }

  Future<void> textSkalaSetzen(double wert) async {
    textSkala.value = wert;
    final p = await SharedPreferences.getInstance();
    await p.setDouble('text_skala', wert);
  }

  Future<void> bestehensGrenzeSetzen(int wert) async {
    bestehensGrenze = wert;
    final p = await SharedPreferences.getInstance();
    await p.setInt('bestehensgrenze', wert);
  }

  Future<void> nameSetzen(String wert) async {
    name = wert.trim();
    final p = await SharedPreferences.getInstance();
    await p.setString('nutzer_name', name);
  }

  Future<void> onboardingAbschliessen() async {
    onboardingFertig = true;
    final p = await SharedPreferences.getInstance();
    await p.setBool('onboarding_fertig', true);
  }

  /// Schulnote (1–6) aus Prozent unter Berücksichtigung der Bestehensgrenze.
  int note(int prozent) {
    if (prozent >= 92) return 1;
    if (prozent >= 81) return 2;
    if (prozent >= 67) return 3;
    if (prozent >= bestehensGrenze) return 4;
    if (prozent >= (bestehensGrenze * 0.6).round()) return 5;
    return 6;
  }

  bool bestanden(int prozent) => prozent >= bestehensGrenze;
}
