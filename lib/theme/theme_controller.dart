import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Verwaltet das App-Theme (dunkel/hell) und merkt sich die Wahl.
class ThemeController {
  final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.dark);

  Future<void> laden() async {
    final prefs = await SharedPreferences.getInstance();
    final wert = prefs.getString('theme_mode') ?? 'dark';
    mode.value = wert == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  bool get istDunkel => mode.value == ThemeMode.dark;

  Future<void> umschalten() async {
    mode.value = istDunkel ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', istDunkel ? 'dark' : 'light');
  }
}
