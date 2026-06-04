import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Großer, animierter Mikrofon-Button.
/// Inaktiv: blau. Aktiv: rot mit drei pulsierenden Ringen.
class SprachEingabeButton extends StatefulWidget {
  final bool aktiv;
  final VoidCallback onTippen;

  const SprachEingabeButton({
    super.key,
    required this.aktiv,
    required this.onTippen,
  });

  @override
  State<SprachEingabeButton> createState() => _SprachEingabeButtonState();
}

class _SprachEingabeButtonState extends State<SprachEingabeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final farbe = widget.aktiv ? const Color(0xFFD32F2F) : const Color(0xFF1565C0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onTippen();
          },
          child: SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulsierende Ringe nur wenn aktiv
                if (widget.aktiv)
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: List.generate(3, (i) {
                          final t = (_controller.value + i / 3) % 1.0;
                          return Opacity(
                            opacity: (1.0 - t) * 0.5,
                            child: Container(
                              width: 100 + t * 80,
                              height: 100 + t * 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: farbe.withOpacity(0.6),
                                  width: 3,
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                // Haupt-Button
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [farbe, farbe.withOpacity(0.75)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: farbe.withOpacity(0.5),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.aktiv ? Icons.mic : Icons.mic_none_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.aktiv ? 'Höre zu …' : 'Tippe und sprich',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: farbe,
          ),
        ),
      ],
    );
  }
}
