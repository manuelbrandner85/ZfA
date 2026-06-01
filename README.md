# 🦷 ZFA Lernapp — Dein Prüfungsbegleiter

[![Build APK](https://github.com/manuelbrandner85/zfa/actions/workflows/build_apk.yml/badge.svg)](https://github.com/manuelbrandner85/zfa/actions/workflows/build_apk.yml)

Eine Flutter-Android-App für ZFA-Azubis (Zahnmedizinische Fachangestellte), die sich Dinge
schwer merken können und trotzdem die praktische Abschlussprüfung bestehen wollen.

## 📥 APK Download
**[⬇️ Neueste APK hier herunterladen](../../releases/latest)**

Oder die APK direkt aus dem letzten Build laden:
**Actions → „🦷 ZFA Lernapp — Build APK" → letzter Lauf → Artifact „ZFA-Lernapp-APK"**

## 🎯 Was kann die App?
- 📖 **Hörbuch-Modus** — 10 Kapitel zum Anhören mit Karaoke-Highlight & Geschwindigkeitsregler
- 🎤 **Sprach-Quiz** — Antworten einsprechen statt tippen (mit Multiple-Choice-Fallback)
- 🃏 **Karteikarten** — Flip-Karten mit Spaced Repetition (Leitner-System) & Swipe-Gesten
- 🎯 **Quiz** — 80 Fragen mit Gamification, Konfetti & Streak
- 🔍 **Fehler finden** — Aufgaben im TikTok-Stil: „Was ist hier falsch?"
- 📊 **Fortschritt** — Leitner-Boxen, Bereichs-Statistiken & persönliche Empfehlung

## 🧠 Lernprinzipien
1. **Micro-Learning** — kurze Einheiten, schon 5 Minuten reichen
2. **Spaced Repetition** — falsch beantwortete Karten kommen öfter wieder (Leitner-Boxen 1–5)
3. **Multi-sensorisch** — alles gleichzeitig hören (TTS) + lesen + sprechen (STT)
4. **Emotionales Feedback** — Konfetti, Lob und Punkte bei jeder richtigen Antwort
5. **Chunking** — nie mehr als 3–4 Infos auf einmal

## 📚 Inhalte
- **10 Hörbuch-Kapitel**: Anmeldung, Vorbereitung/Hygiene, Hygiene-Grundbegriffe,
  Anästhesie, Chirurgie, Parodontitis, Karies/Füllung, Wurzelkanal, Zahnersatz/eHKP, Dokumentation
- **80 Quizfragen** mit einfacher Erklärung, Merkhilfe und Schlüsselwörtern
- **60 Lernkarten** (die 20 wichtigsten Prüfungsbegriffe zuerst)

## 🚀 Entwicklung
```bash
git clone https://github.com/manuelbrandner85/zfa
cd zfa
flutter pub get
flutter run
```

### APK selbst bauen
```bash
flutter build apk --release            # Universal-APK
flutter build apk --release --split-per-abi   # je Architektur
```

### Build über GitHub Actions auslösen
Der Workflow baut automatisch bei Push auf `main` und bei Tags (`v*`).
Er lässt sich auch manuell starten: **Actions → Build APK → „Run workflow"**.
Ein Tag `vX.Y.Z` erzeugt zusätzlich ein GitHub-Release mit den APKs.

## 🛠️ Tech-Stack
Flutter 3.24 · google_fonts · flutter_tts · speech_to_text · shared_preferences ·
confetti · fl_chart · flip_card · animate_do · permission_handler

## 📋 Berechtigungen
- **Mikrofon** (`RECORD_AUDIO`) — für das Sprach-Quiz
- **Internet** — TTS auf manchen Geräten
- **Vibration** — haptisches Feedback
