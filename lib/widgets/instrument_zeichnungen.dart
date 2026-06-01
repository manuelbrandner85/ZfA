import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Realistische, metallisch schattierte Darstellungen zahnärztlicher
/// Instrumente – komplett per CustomPaint gezeichnet (offline, lizenzfrei).
///
/// Für einen echten Edelstahl-Look werden zylindrische Verläufe (dunkel→hell→
/// dunkel quer zur Längsachse), Glanzlichter und weiche Schatten verwendet.
class InstrumentZeichnung extends StatelessWidget {
  final String id;
  final double groesse;
  const InstrumentZeichnung({super.key, required this.id, this.groesse = 200});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: groesse,
      height: groesse,
      child: CustomPaint(
        size: Size.square(groesse),
        painter: _InstrumentPainter(id),
      ),
    );
  }
}

class _InstrumentPainter extends CustomPainter {
  final String id;
  _InstrumentPainter(this.id);

  // Edelstahl-Palette
  static const _edge = Color(0xFF55636C);
  static const _dark = Color(0xFF7C8B95);
  static const _mid = Color(0xFFAEBCC4);
  static const _hi = Color(0xFFF4F8FA);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    // Weicher Boden-Schatten für Tiefe
    final boden = Paint()
      ..color = Colors.black.withOpacity(0.10)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.03);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(s * 0.5, s * 0.95),
          width: s * 0.5,
          height: s * 0.06),
      boden,
    );

    switch (id) {
      case 'mundspiegel':
        _mundspiegel(canvas, s);
        break;
      case 'sonde':
        _sonde(canvas, s);
        break;
      case 'pinzette':
        _pinzette(canvas, s);
        break;
      case 'spritze':
        _spritze(canvas, s);
        break;
      case 'hebel':
        _hebel(canvas, s);
        break;
      case 'zange':
        _zange(canvas, s);
        break;
      case 'scaler':
        _scaler(canvas, s);
        break;
      case 'sauger':
        _sauger(canvas, s);
        break;
      default:
        _sonde(canvas, s);
    }
  }

  // ---------- Hilfsfunktionen für metallischen Look ----------

  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;

  Paint _fill(Color c) => Paint()..color = c;

  /// Zylindrischer Edelstahl-Verlauf quer zur Achse (für runde Stäbe).
  Paint _stahl(Rect r, {bool vertikal = true, List<Color>? farben}) {
    final cols = farben ?? const [_edge, _dark, _hi, _mid, _edge];
    return Paint()
      ..shader = LinearGradient(
        begin: vertikal ? Alignment.centerLeft : Alignment.topCenter,
        end: vertikal ? Alignment.centerRight : Alignment.bottomCenter,
        colors: cols,
        stops: const [0.0, 0.22, 0.46, 0.74, 1.0],
      ).createShader(r);
  }

  Paint _schatten(double s) => Paint()
    ..color = Colors.black.withOpacity(0.16)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.012);

  /// Glanzlicht-Linie (schmaler heller Streifen).
  void _glanz(Canvas c, Offset a, Offset b, double w) {
    c.drawLine(a, b, _stroke(Colors.white.withOpacity(0.6), w));
  }

  /// Zeichnet einen vertikalen, gerillten Edelstahl-Griff.
  void _griff(Canvas c, double s, double cx, double topY, double botY,
      double w) {
    final left = cx - w / 2, right = cx + w / 2;
    final rect = Rect.fromLTRB(left, topY, right, botY);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(w * 0.5));
    // Schatten
    c.drawRRect(rr.shift(Offset(s * 0.012, s * 0.016)), _schatten(s));
    // Korpus
    c.drawRRect(rr, _stahl(rect));
    // Konturkante
    c.drawRRect(rr, _stroke(_edge.withOpacity(0.6), w * 0.06));
    // feine Riffelung
    final rip = _stroke(Colors.black.withOpacity(0.18), w * 0.07);
    for (double y = topY + w * 0.5; y < botY - w * 0.4; y += w * 0.32) {
      c.drawLine(Offset(left + w * 0.16, y), Offset(right - w * 0.16, y), rip);
    }
    // Glanzlicht
    _glanz(c, Offset(left + w * 0.34, topY + w * 0.5),
        Offset(left + w * 0.34, botY - w * 0.4), w * 0.12);
  }

  /// Zeichnet einen schlanken, konischen Schaft (Arbeitsteil-Hals).
  void _schaft(Canvas c, double s, Offset von, Offset bis, double wVon,
      double wBis) {
    // Als gefülltes Polygon mit Stahlverlauf
    final dir = (bis - von);
    final len = dir.distance;
    if (len == 0) return;
    final n = Offset(-dir.dy / len, dir.dx / len);
    final p = Path()
      ..moveTo(von.dx + n.dx * wVon, von.dy + n.dy * wVon)
      ..lineTo(bis.dx + n.dx * wBis, bis.dy + n.dy * wBis)
      ..lineTo(bis.dx - n.dx * wBis, bis.dy - n.dy * wBis)
      ..lineTo(von.dx - n.dx * wVon, von.dy - n.dy * wVon)
      ..close();
    final r = p.getBounds();
    c.drawPath(p, _schatten(s));
    c.drawPath(p, _stahl(r, vertikal: r.width >= r.height));
  }

  // ---------- Instrumente ----------

  void _mundspiegel(Canvas c, double s) {
    _griff(c, s, s * 0.5, s * 0.5, s * 0.9, s * 0.075);
    // Hals zum Spiegel (leicht abgewinkelt)
    _schaft(c, s, Offset(s * 0.5, s * 0.5), Offset(s * 0.5, s * 0.44),
        s * 0.03, s * 0.022);
    _schaft(c, s, Offset(s * 0.5, s * 0.44), Offset(s * 0.46, s * 0.36),
        s * 0.02, s * 0.018);
    final mitte = Offset(s * 0.5, s * 0.27);
    final r = s * 0.165;
    // Rahmen (Schatten + Stahlring)
    c.drawCircle(mitte.translate(s * 0.012, s * 0.016), r, _schatten(s));
    c.drawCircle(mitte, r, _fill(_dark));
    c.drawCircle(mitte, r,
        _stroke(_edge, s * 0.012)..style = PaintingStyle.stroke);
    // Spiegelfläche mit Reflexion
    final face = Rect.fromCircle(center: mitte, radius: r * 0.86);
    final spiegel = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [
          Color(0xFFE8F6FF),
          Color(0xFFBFE2F2),
          Color(0xFF8FB8CC),
          Color(0xFFCDE6F0),
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(face);
    c.drawOval(face, spiegel);
    // Schräge Glanzstreifen
    final glanz = _stroke(Colors.white.withOpacity(0.75), s * 0.02);
    c.save();
    c.clipPath(Path()..addOval(face));
    c.drawLine(Offset(mitte.dx - r * 0.6, mitte.dy + r * 0.2),
        Offset(mitte.dx + r * 0.1, mitte.dy - r * 0.6), glanz);
    c.drawLine(Offset(mitte.dx - r * 0.2, mitte.dy + r * 0.55),
        Offset(mitte.dx + r * 0.45, mitte.dy - r * 0.1),
        _stroke(Colors.white.withOpacity(0.4), s * 0.012));
    c.restore();
  }

  void _sonde(Canvas c, double s) {
    _griff(c, s, s * 0.5, s * 0.52, s * 0.9, s * 0.07);
    // konischer Schaft nach oben
    _schaft(c, s, Offset(s * 0.5, s * 0.52), Offset(s * 0.5, s * 0.34),
        s * 0.028, s * 0.014);
    // scharfe Hirtenstab-Spitze
    final p = Path()
      ..moveTo(s * 0.5, s * 0.34)
      ..quadraticBezierTo(s * 0.5, s * 0.17, s * 0.66, s * 0.15);
    c.drawPath(p, _stroke(_dark, s * 0.022)..strokeCap = StrokeCap.round);
    c.drawPath(p, _stroke(Colors.white.withOpacity(0.5), s * 0.007));
    // feine Nadelspitze
    c.drawCircle(Offset(s * 0.66, s * 0.15), s * 0.009, _fill(_edge));
  }

  void _pinzette(Canvas c, double s) {
    // Zwei elegante, gebogene Arme (College-Pinzette / Wattepinzette)
    final basis = Offset(s * 0.5, s * 0.9);
    final links = Path()
      ..moveTo(basis.dx, basis.dy)
      ..cubicTo(s * 0.36, s * 0.62, s * 0.4, s * 0.32, s * 0.52, s * 0.14);
    final rechts = Path()
      ..moveTo(basis.dx, basis.dy)
      ..cubicTo(s * 0.64, s * 0.62, s * 0.6, s * 0.32, s * 0.52, s * 0.14);
    // Schatten
    c.drawPath(links, _stroke(Colors.black.withOpacity(0.14), s * 0.06));
    c.drawPath(rechts, _stroke(Colors.black.withOpacity(0.14), s * 0.06));
    // Körper mit Verlauf (zwei Töne für Rundung)
    c.drawPath(links, _stroke(_dark, s * 0.05));
    c.drawPath(rechts, _stroke(_dark, s * 0.05));
    c.drawPath(links, _stroke(_mid, s * 0.03));
    c.drawPath(rechts, _stroke(_mid, s * 0.03));
    c.drawPath(links, _stroke(Colors.white.withOpacity(0.5), s * 0.01));
    c.drawPath(rechts, _stroke(Colors.white.withOpacity(0.45), s * 0.01));
    // Abgewinkelte feine Spitze
    c.drawCircle(Offset(s * 0.52, s * 0.14), s * 0.012, _fill(_edge));
    // gerillte Griffzone
    final rip = _stroke(Colors.black.withOpacity(0.18), s * 0.012);
    for (int i = 0; i < 5; i++) {
      final y = s * (0.66 + i * 0.04);
      c.drawLine(Offset(s * 0.43, y), Offset(s * 0.47, y), rip);
      c.drawLine(Offset(s * 0.53, y), Offset(s * 0.57, y), rip);
    }
  }

  void _spritze(Canvas c, double s) {
    // Aspirationsspritze (Karpulenspritze), waagerecht
    final achseY = s * 0.5;
    // Korpus (offener Rahmen mit Fenster)
    final body = Rect.fromLTRB(s * 0.26, achseY - s * 0.085, s * 0.66,
        achseY + s * 0.085);
    final rr = RRect.fromRectAndRadius(body, Radius.circular(s * 0.02));
    c.drawRRect(rr.shift(Offset(s * 0.012, s * 0.016)), _schatten(s));
    c.drawRRect(rr, _stahl(body, vertikal: false));
    c.drawRRect(rr, _stroke(_edge, s * 0.01));
    // Sichtfenster mit Glaskarpule + Flüssigkeit
    final fenster = Rect.fromLTRB(
        s * 0.31, achseY - s * 0.05, s * 0.6, achseY + s * 0.05);
    c.drawRRect(
        RRect.fromRectAndRadius(fenster, Radius.circular(s * 0.012)),
        _fill(const Color(0xFF1B2A33)));
    final glas = Rect.fromLTRB(
        s * 0.325, achseY - s * 0.038, s * 0.585, achseY + s * 0.038);
    c.drawRRect(
      RRect.fromRectAndRadius(glas, Radius.circular(s * 0.01)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEAF6FF), Color(0xFFBFE0F0), Color(0xFF9FCADC)],
        ).createShader(glas),
    );
    // Luftblase
    c.drawCircle(Offset(s * 0.4, achseY - s * 0.005), s * 0.012,
        _fill(Colors.white.withOpacity(0.8)));
    // Glanz auf Glas
    _glanz(c, Offset(s * 0.34, achseY - s * 0.028),
        Offset(s * 0.57, achseY - s * 0.028), s * 0.008);
    // Daumenring
    final ring = Offset(s * 0.78, achseY);
    c.drawCircle(ring, s * 0.06, _stroke(_dark, s * 0.028));
    c.drawCircle(ring, s * 0.06, _stroke(Colors.white.withOpacity(0.4), s * 0.008));
    // Fingerstützen (zwei Flügel)
    c.drawLine(Offset(s * 0.7, achseY - s * 0.02),
        Offset(s * 0.7, achseY - s * 0.11), _stroke(_dark, s * 0.02));
    c.drawLine(Offset(s * 0.7, achseY + s * 0.02),
        Offset(s * 0.7, achseY + s * 0.11), _stroke(_dark, s * 0.02));
    // Kolbenstange Ring→Body
    c.drawLine(Offset(s * 0.72, achseY), Offset(s * 0.66, achseY),
        _stroke(_mid, s * 0.03));
    // Gewindehals + Kanüle nach links
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTRB(s * 0.2, achseY - s * 0.03, s * 0.26,
                achseY + s * 0.03),
            Radius.circular(s * 0.006)),
        _fill(_dark));
    _schaft(c, s, Offset(s * 0.2, achseY), Offset(s * 0.05, achseY),
        s * 0.012, s * 0.004);
  }

  void _hebel(Canvas c, double s) {
    // Bein-/Wurzelhebel: kräftiger Griff + konkave Klinge
    _griff(c, s, s * 0.5, s * 0.46, s * 0.9, s * 0.09);
    _schaft(c, s, Offset(s * 0.5, s * 0.46), Offset(s * 0.5, s * 0.3),
        s * 0.04, s * 0.03);
    // Konkave, löffelartige Klinge
    final blatt = Path()
      ..moveTo(s * 0.46, s * 0.3)
      ..quadraticBezierTo(s * 0.42, s * 0.16, s * 0.5, s * 0.1)
      ..quadraticBezierTo(s * 0.58, s * 0.16, s * 0.54, s * 0.3)
      ..close();
    final r = blatt.getBounds();
    c.drawPath(blatt.shift(Offset(s * 0.01, s * 0.014)), _schatten(s));
    c.drawPath(blatt, _stahl(r));
    c.drawPath(blatt, _stroke(_edge, s * 0.008));
    // Hohlkehle (Glanz innen)
    _glanz(c, Offset(s * 0.49, s * 0.27), Offset(s * 0.5, s * 0.14), s * 0.014);
  }

  void _zange(Canvas c, double s) {
    final hinge = Offset(s * 0.5, s * 0.56);
    // Griffe (leicht gebogen, gespreizt) – mit Stahlverlauf via dicker Linien
    for (final off in [-1.0, 1.0]) {
      final ende = Offset(s * (0.5 + off * 0.16), s * 0.93);
      final p = Path()
        ..moveTo(hinge.dx, hinge.dy)
        ..quadraticBezierTo(s * (0.5 + off * 0.05), s * 0.78, ende.dx, ende.dy);
      c.drawPath(p, _stroke(Colors.black.withOpacity(0.14), s * 0.075));
      c.drawPath(p, _stroke(_dark, s * 0.06));
      c.drawPath(p, _stroke(_mid, s * 0.032));
      c.drawPath(p, _stroke(Colors.white.withOpacity(0.4), s * 0.01));
    }
    // Maulteile (Beaks) nach oben, gebogen zusammenlaufend
    for (final off in [-1.0, 1.0]) {
      final p = Path()
        ..moveTo(hinge.dx, hinge.dy)
        ..quadraticBezierTo(s * (0.5 + off * 0.16), s * 0.34,
            s * (0.5 + off * 0.05), s * 0.16);
      c.drawPath(p, _stroke(Colors.black.withOpacity(0.14), s * 0.062));
      c.drawPath(p, _stroke(_dark, s * 0.05));
      c.drawPath(p, _stroke(_mid, s * 0.026));
    }
    // Gelenkbolzen
    c.drawCircle(hinge, s * 0.045, _fill(_dark));
    c.drawCircle(hinge, s * 0.045, _stroke(_edge, s * 0.01));
    c.drawCircle(hinge, s * 0.018, _fill(_edge));
    c.drawCircle(Offset(hinge.dx - s * 0.012, hinge.dy - s * 0.012),
        s * 0.008, _fill(Colors.white.withOpacity(0.6)));
  }

  void _scaler(Canvas c, double s) {
    _griff(c, s, s * 0.5, s * 0.52, s * 0.9, s * 0.075);
    _schaft(c, s, Offset(s * 0.5, s * 0.52), Offset(s * 0.52, s * 0.36),
        s * 0.026, s * 0.014);
    // Sichelförmige Spitze (gebogen, spitz zulaufend)
    final p = Path()
      ..moveTo(s * 0.52, s * 0.36)
      ..quadraticBezierTo(s * 0.44, s * 0.24, s * 0.58, s * 0.13)
      ..quadraticBezierTo(s * 0.5, s * 0.24, s * 0.52, s * 0.36)
      ..close();
    final r = p.getBounds();
    c.drawPath(p.shift(Offset(s * 0.008, s * 0.012)), _schatten(s));
    c.drawPath(p, _stahl(r));
    _glanz(c, Offset(s * 0.5, s * 0.32), Offset(s * 0.55, s * 0.17), s * 0.01);
  }

  void _sauger(Canvas c, double s) {
    // Speichelsauger mit geriffeltem, biegbarem Abschnitt
    final p = Path()
      ..moveTo(s * 0.34, s * 0.92)
      ..lineTo(s * 0.34, s * 0.52)
      ..quadraticBezierTo(s * 0.34, s * 0.3, s * 0.58, s * 0.22);
    c.drawPath(p, _stroke(Colors.black.withOpacity(0.14), s * 0.095));
    // Rohr mit Längsverlauf
    c.drawPath(p, _stroke(_dark, s * 0.08));
    c.drawPath(p, _stroke(_mid, s * 0.05));
    _glanz(c, Offset(s * 0.345, s * 0.9), Offset(s * 0.345, s * 0.55), s * 0.018);
    // Geriffelter, biegbarer Bereich
    final rip = _stroke(_edge.withOpacity(0.6), s * 0.012);
    for (int i = 0; i < 7; i++) {
      final t = i / 7.0;
      final pos = _aufPfad(s, t);
      c.drawCircle(pos, s * 0.045, rip);
    }
    // Saugkopf
    c.drawCircle(Offset(s * 0.6, s * 0.21), s * 0.055, _fill(_dark));
    c.drawCircle(Offset(s * 0.6, s * 0.21), s * 0.055, _stroke(_edge, s * 0.01));
    c.drawCircle(Offset(s * 0.6, s * 0.21), s * 0.03, _fill(const Color(0xFF1B2A33)));
  }

  // Punkt entlang des oberen, gebogenen Saugbereichs (für Riffelung).
  Offset _aufPfad(double s, double t) {
    // Linearer Bereich von y0.5→0.36 entlang x0.34, dann leichte Kurve
    final y = s * (0.5 - t * 0.16);
    final x = s * (0.34 + math.pow(t, 2) * 0.06);
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant _InstrumentPainter old) => old.id != id;
}
