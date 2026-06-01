import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Plant eine freundliche tägliche Lern-Erinnerung.
/// Robust gebaut: schlägt etwas fehl (z. B. fehlende Berechtigung),
/// stürzt nichts ab – die Erinnerung ist optional.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _bereit = false;

  // Persistierte Einstellungen
  bool aktiv = false;
  int stunde = 17;
  int minute = 0;

  static const int _id = 1001;

  Future<void> initialisieren() async {
    try {
      tzdata.initializeTimeZones();
      // Zielgruppe Deutschland – feste Zeitzone genügt.
      tz.setLocalLocation(tz.getLocation('Europe/Berlin'));

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _plugin.initialize(
        const InitializationSettings(android: android),
      );
      _bereit = true;

      final prefs = await SharedPreferences.getInstance();
      aktiv = prefs.getBool('erinnerung_aktiv') ?? false;
      stunde = prefs.getInt('erinnerung_stunde') ?? 17;
      minute = prefs.getInt('erinnerung_minute') ?? 0;

      // Falls vorher aktiviert: Erinnerung wieder einplanen.
      if (aktiv) {
        await _planen();
      }
    } catch (_) {
      _bereit = false;
    }
  }

  Future<bool> _berechtigungAnfragen() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;
    final erlaubt = await android.requestNotificationsPermission();
    return erlaubt ?? true;
  }

  /// Schaltet die Erinnerung ein/aus. Gibt zurück, ob sie jetzt aktiv ist.
  Future<bool> umschalten(bool einschalten, {int? stunde, int? minute}) async {
    if (stunde != null) this.stunde = stunde;
    if (minute != null) this.minute = minute;

    if (einschalten) {
      if (!_bereit) await initialisieren();
      final ok = await _berechtigungAnfragen();
      if (!ok) {
        aktiv = false;
        await _speichern();
        return false;
      }
      await _planen();
      aktiv = true;
    } else {
      await _plugin.cancel(_id);
      aktiv = false;
    }
    await _speichern();
    return aktiv;
  }

  Future<void> _planen() async {
    if (!_bereit) return;
    await _plugin.cancel(_id);
    await _plugin.zonedSchedule(
      _id,
      'Zeit zum Lernen 🦷',
      'Schon 5 Minuten bringen dich näher zur bestandenen Prüfung. Los geht\'s!',
      _naechsteInstanz(stunde, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'taegliche_erinnerung',
          'Tägliche Lern-Erinnerung',
          channelDescription: 'Erinnert dich einmal am Tag ans Lernen.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _naechsteInstanz(int stunde, int minute) {
    final jetzt = tz.TZDateTime.now(tz.local);
    var geplant =
        tz.TZDateTime(tz.local, jetzt.year, jetzt.month, jetzt.day, stunde, minute);
    if (geplant.isBefore(jetzt)) {
      geplant = geplant.add(const Duration(days: 1));
    }
    return geplant;
  }

  Future<void> _speichern() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('erinnerung_aktiv', aktiv);
    await prefs.setInt('erinnerung_stunde', stunde);
    await prefs.setInt('erinnerung_minute', minute);
  }
}
