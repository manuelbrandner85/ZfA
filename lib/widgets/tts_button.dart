import 'package:flutter/material.dart';
import '../main.dart';
import '../core/services/tts_service.dart';

class TtsButton extends StatefulWidget {
  final String text;
  final Color? farbe;

  const TtsButton({
    super.key,
    required this.text,
    this.farbe,
  });

  @override
  State<TtsButton> createState() => _TtsButtonState();
}

class _TtsButtonState extends State<TtsButton>
    with SingleTickerProviderStateMixin {
  bool _laeuft = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  Future<void> _toggle() async {
    if (_laeuft) {
      await ttsService.stoppen();
      if (mounted) {
        setState(() => _laeuft = false);
        _animController.stop();
        _animController.reset();
      }
    } else {
      setState(() => _laeuft = true);
      _animController.repeat(reverse: true);
      // Eigener Completion-Callback nur für diesen Button
      ttsService.onZustandAendert = (zustand) {
        if (!mounted) return;
        if (zustand == TtsZustand.gestoppt) {
          setState(() => _laeuft = false);
          _animController.stop();
          _animController.reset();
        }
      };
      await ttsService.sprechen(widget.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _laeuft ? _scaleAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (widget.farbe ?? Colors.blue).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _laeuft ? Icons.stop_rounded : Icons.volume_up_rounded,
              color: widget.farbe ?? Colors.blue,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
}
