import 'package:flutter/material.dart';
import '../main.dart';
import '../data/quiz/hoerbuch_texte.dart';
import '../screens/hoerbuch_screen.dart';

/// Persistente Mini-AudioBar am unteren Rand.
/// Erscheint nur, wenn gerade ein Hörbuch läuft (aktuellerAudio != null).
class AudioPlayerBar extends StatelessWidget {
  const AudioPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AudioZustand?>(
      valueListenable: aktuellerAudio,
      builder: (context, audio, _) {
        final sichtbar = audio != null;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          height: sichtbar ? 72 : 0,
          child: !sichtbar
              ? const SizedBox.shrink()
              : Material(
                  color: const Color(0xFF0D1B2A),
                  child: InkWell(
                    onTap: () {
                      // Passendes Kapitel finden und öffnen
                      final kapitel = alleHoerbuchKapitel.firstWhere(
                        (k) => k.titel == audio.kapitelTitel,
                        orElse: () => alleHoerbuchKapitel.first,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HoerbuchScreen(kapitel: kapitel),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Text(audio.kapitelEmoji,
                                    style: const TextStyle(fontSize: 28)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        audio.kapitelTitel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const Text(
                                        'Hörbuch läuft',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    audio.laeuft
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_fill,
                                    color: const Color(0xFF42A5F5),
                                    size: 40,
                                  ),
                                  onPressed: () async {
                                    if (audio.laeuft) {
                                      await ttsService.stoppen();
                                      aktuellerAudio.value = null;
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Dünner Fortschrittsbalken
                        LinearProgressIndicator(
                          value: audio.fortschritt,
                          minHeight: 3,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF42A5F5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
