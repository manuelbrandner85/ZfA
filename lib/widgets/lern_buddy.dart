import 'dart:math' as math;
import 'package:flutter/material.dart';

enum BuddyStimmung { idle, freude, jubel, nachdenklich, traurig }

/// Freundlicher Zahn-Charakter (komplett gezeichnet), der mitfiebert.
class LernBuddy extends StatefulWidget {
  final BuddyStimmung stimmung;
  final double groesse;
  const LernBuddy({
    super.key,
    this.stimmung = BuddyStimmung.idle,
    this.groesse = 96,
  });

  @override
  State<LernBuddy> createState() => _LernBuddyState();
}

class _LernBuddyState extends State<LernBuddy>
    with TickerProviderStateMixin {
  late final AnimationController _idle;
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _blink = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 160));
    _blinkSchleife();
  }

  Future<void> _blinkSchleife() async {
    while (mounted) {
      await Future.delayed(
          Duration(milliseconds: 2200 + (1000 * _r()).toInt()));
      if (!mounted) return;
      await _blink.forward();
      await _blink.reverse();
    }
  }

  double _r() => (DateTime.now().millisecondsSinceEpoch % 1000) / 1000;

  @override
  void dispose() {
    _idle.dispose();
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_idle, _blink]),
      builder: (context, _) {
        final jubel = widget.stimmung == BuddyStimmung.jubel;
        final dy = math.sin(_idle.value * math.pi) * (jubel ? 8 : 4);
        return Transform.translate(
          offset: Offset(0, -dy),
          child: CustomPaint(
            size: Size.square(widget.groesse),
            painter: _BuddyPainter(
              stimmung: widget.stimmung,
              blink: _blink.value,
              schwung: _idle.value,
            ),
          ),
        );
      },
    );
  }
}

class _BuddyPainter extends CustomPainter {
  final BuddyStimmung stimmung;
  final double blink;
  final double schwung;
  _BuddyPainter(
      {required this.stimmung, required this.blink, required this.schwung});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final cx = s / 2;

    // Schatten
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, s * 0.95), width: s * 0.5, height: s * 0.08),
      Paint()..color = Colors.black.withOpacity(0.12),
    );

    // Zahnkörper (zwei Höcker oben, zwei Wurzeln unten)
    final body = Path()
      ..moveTo(s * 0.18, s * 0.42)
      ..cubicTo(s * 0.16, s * 0.12, s * 0.42, s * 0.10, s * 0.5, s * 0.26)
      ..cubicTo(s * 0.58, s * 0.10, s * 0.84, s * 0.12, s * 0.82, s * 0.42)
      ..cubicTo(s * 0.86, s * 0.66, s * 0.74, s * 0.72, s * 0.68, s * 0.92)
      ..quadraticBezierTo(s * 0.62, s * 0.78, s * 0.56, s * 0.74)
      ..quadraticBezierTo(s * 0.5, s * 0.72, s * 0.44, s * 0.74)
      ..quadraticBezierTo(s * 0.38, s * 0.78, s * 0.32, s * 0.92)
      ..cubicTo(s * 0.26, s * 0.72, s * 0.14, s * 0.66, s * 0.18, s * 0.42)
      ..close();

    final bounds = body.getBounds();
    final koerper = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [Color(0xFFFFFFFF), Color(0xFFF1F5FB), Color(0xFFD9E2EF)],
      ).createShader(bounds);
    canvas.drawPath(body, Paint()..color = Colors.black.withOpacity(0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawPath(body, koerper);
    canvas.drawPath(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.012
          ..color = const Color(0xFFBFD0E2));

    // Glanzlicht
    canvas.drawCircle(Offset(s * 0.36, s * 0.30), s * 0.06,
        Paint()..color = Colors.white.withOpacity(0.7));

    // Wangen
    final wange = Paint()..color = const Color(0xFFFFC1CC).withOpacity(0.8);
    canvas.drawCircle(Offset(s * 0.30, s * 0.52), s * 0.055, wange);
    canvas.drawCircle(Offset(s * 0.70, s * 0.52), s * 0.055, wange);

    // Augen
    final augY = s * 0.42;
    final augColor = Paint()..color = const Color(0xFF26334D);
    final offen = (1 - blink);
    void auge(double ax) {
      final h = s * 0.07 * offen + s * 0.006;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(ax, augY), width: s * 0.055, height: h),
        augColor,
      );
      if (offen > 0.4) {
        canvas.drawCircle(Offset(ax - s * 0.012, augY - s * 0.018),
            s * 0.012, Paint()..color = Colors.white);
      }
    }

    if (stimmung == BuddyStimmung.jubel) {
      // fröhliche ^^ Augen
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.016
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF26334D);
      canvas.drawArc(
          Rect.fromCircle(center: Offset(s * 0.40, augY), radius: s * 0.035),
          math.pi,
          math.pi,
          false,
          p);
      canvas.drawArc(
          Rect.fromCircle(center: Offset(s * 0.60, augY), radius: s * 0.035),
          math.pi,
          math.pi,
          false,
          p);
    } else {
      auge(s * 0.40);
      auge(s * 0.60);
    }

    // Mund je Stimmung
    final mund = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.018
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF26334D);
    final my = s * 0.56;
    switch (stimmung) {
      case BuddyStimmung.freude:
      case BuddyStimmung.jubel:
        canvas.drawArc(
            Rect.fromCircle(center: Offset(cx, my), radius: s * 0.09),
            0.15 * math.pi,
            0.7 * math.pi,
            false,
            mund);
        break;
      case BuddyStimmung.traurig:
        canvas.drawArc(
            Rect.fromCircle(
                center: Offset(cx, my + s * 0.06), radius: s * 0.08),
            1.15 * math.pi,
            0.7 * math.pi,
            false,
            mund);
        break;
      case BuddyStimmung.nachdenklich:
        canvas.drawLine(Offset(cx - s * 0.05, my), Offset(cx + s * 0.05, my),
            mund);
        break;
      case BuddyStimmung.idle:
        canvas.drawArc(
            Rect.fromCircle(center: Offset(cx, my), radius: s * 0.06),
            0.1 * math.pi,
            0.8 * math.pi,
            false,
            mund);
        break;
    }

    // Jubel: kleine Funkeln
    if (stimmung == BuddyStimmung.jubel) {
      final fk = Paint()..color = const Color(0xFFE7C04C);
      for (final o in [
        Offset(s * 0.12, s * 0.18),
        Offset(s * 0.88, s * 0.22),
        Offset(s * 0.84, s * 0.6),
      ]) {
        _funken(canvas, o, s * 0.03, fk);
      }
    }
  }

  void _funken(Canvas c, Offset o, double r, Paint p) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      path.moveTo(o.dx, o.dy);
      path.lineTo(o.dx + math.cos(a) * r, o.dy + math.sin(a) * r);
    }
    c.drawPath(
        path,
        p
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.5
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant _BuddyPainter old) =>
      old.stimmung != stimmung ||
      old.blink != blink ||
      old.schwung != schwung;
}
