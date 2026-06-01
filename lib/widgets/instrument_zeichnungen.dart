import 'package:flutter/material.dart';

/// Stilisierte, gut erkennbare Zeichnungen zahnärztlicher Instrumente.
/// Komplett per CustomPaint – keine externen Bilder nötig (offline-fähig).
class InstrumentZeichnung extends StatelessWidget {
  final String id;
  final double groesse;
  const InstrumentZeichnung({super.key, required this.id, this.groesse = 200});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(groesse),
      painter: _InstrumentPainter(id),
    );
  }
}

class _InstrumentPainter extends CustomPainter {
  final String id;
  _InstrumentPainter(this.id);

  static const _metall = Color(0xFFB0BEC5);
  static const _metallDunkel = Color(0xFF607D8B);
  static const _griff = Color(0xFF37474F);
  static const _glanz = Color(0xFFECEFF1);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
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

  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;

  Paint _fill(Color c) => Paint()..color = c;

  void _griffStab(Canvas c, double s, double topY) {
    // Vertikaler Griff unten
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTRB(s * 0.46, topY, s * 0.54, s * 0.93),
      Radius.circular(s * 0.04),
    );
    c.drawRRect(rect, _fill(_griff));
    // Riffelung
    final rip = _stroke(Colors.white24, s * 0.012);
    for (double y = topY + s * 0.06; y < s * 0.88; y += s * 0.05) {
      c.drawLine(Offset(s * 0.47, y), Offset(s * 0.53, y), rip);
    }
  }

  void _mundspiegel(Canvas c, double s) {
    _griffStab(c, s, s * 0.55);
    c.drawLine(Offset(s * 0.5, s * 0.55), Offset(s * 0.5, s * 0.44),
        _stroke(_metallDunkel, s * 0.045));
    // Spiegelkopf
    c.drawCircle(Offset(s * 0.5, s * 0.3), s * 0.17, _fill(_metallDunkel));
    c.drawCircle(Offset(s * 0.5, s * 0.3), s * 0.13, _fill(const Color(0xFFB3E5FC)));
    // Glanz
    final glanz = _stroke(Colors.white, s * 0.03);
    c.drawArc(Rect.fromCircle(center: Offset(s * 0.5, s * 0.3), radius: s * 0.085),
        3.6, 1.3, false, glanz);
  }

  void _sonde(Canvas c, double s) {
    _griffStab(c, s, s * 0.55);
    // Schaft
    c.drawLine(Offset(s * 0.5, s * 0.55), Offset(s * 0.5, s * 0.34),
        _stroke(_metall, s * 0.035));
    // Gebogene Spitze (Haken)
    final p = Path()
      ..moveTo(s * 0.5, s * 0.34)
      ..quadraticBezierTo(s * 0.5, s * 0.18, s * 0.66, s * 0.16);
    c.drawPath(p, _stroke(_metallDunkel, s * 0.03));
    c.drawCircle(Offset(s * 0.66, s * 0.16), s * 0.012, _fill(_metallDunkel));
  }

  void _pinzette(Canvas c, double s) {
    // Zwei Arme, unten verbunden, oben zur Spitze zulaufend
    final links = Path()
      ..moveTo(s * 0.44, s * 0.9)
      ..quadraticBezierTo(s * 0.38, s * 0.45, s * 0.5, s * 0.12);
    final rechts = Path()
      ..moveTo(s * 0.56, s * 0.9)
      ..quadraticBezierTo(s * 0.62, s * 0.45, s * 0.5, s * 0.12);
    final paint = _stroke(_metall, s * 0.035);
    c.drawPath(links, paint);
    c.drawPath(rechts, paint);
    // Verbindung unten
    c.drawLine(Offset(s * 0.44, s * 0.9), Offset(s * 0.56, s * 0.9),
        _stroke(_metallDunkel, s * 0.04));
    // Spitze
    c.drawCircle(Offset(s * 0.5, s * 0.12), s * 0.014, _fill(_metallDunkel));
  }

  void _spritze(Canvas c, double s) {
    // Waagerechte Karpulenspritze
    final body = RRect.fromRectAndRadius(
      Rect.fromLTRB(s * 0.22, s * 0.42, s * 0.68, s * 0.56),
      Radius.circular(s * 0.03),
    );
    c.drawRRect(body, _fill(_metall));
    c.drawRRect(body, _stroke(_metallDunkel, s * 0.012));
    // Sichtfenster (Karpule)
    c.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTRB(s * 0.3, s * 0.45, s * 0.6, s * 0.53),
          Radius.circular(s * 0.015)),
      _fill(const Color(0xFFE1F5FE)),
    );
    // Daumenring
    c.drawCircle(Offset(s * 0.74, s * 0.49), s * 0.055, _stroke(_griff, s * 0.022));
    c.drawLine(Offset(s * 0.68, s * 0.49), Offset(s * 0.69, s * 0.49),
        _stroke(_griff, s * 0.03));
    // Kanüle
    c.drawLine(Offset(s * 0.22, s * 0.49), Offset(s * 0.06, s * 0.49),
        _stroke(_metallDunkel, s * 0.018));
  }

  void _hebel(Canvas c, double s) {
    _griffStab(c, s, s * 0.5);
    c.drawLine(Offset(s * 0.5, s * 0.5), Offset(s * 0.5, s * 0.3),
        _stroke(_metall, s * 0.05));
    // Flache, leicht gebogene Klinge
    final blatt = Path()
      ..moveTo(s * 0.44, s * 0.3)
      ..quadraticBezierTo(s * 0.5, s * 0.14, s * 0.56, s * 0.3)
      ..close();
    c.drawPath(blatt, _fill(_metallDunkel));
    c.drawPath(blatt, _stroke(_glanz, s * 0.012));
  }

  void _zange(Canvas c, double s) {
    final hinge = Offset(s * 0.5, s * 0.55);
    // Griffe unten (leicht gespreizt)
    c.drawLine(Offset(s * 0.36, s * 0.92), hinge, _stroke(_griff, s * 0.05));
    c.drawLine(Offset(s * 0.64, s * 0.92), hinge, _stroke(_griff, s * 0.05));
    // Gelenk
    c.drawCircle(hinge, s * 0.035, _fill(_metallDunkel));
    // Gebogene Maulteile oben
    final links = Path()
      ..moveTo(hinge.dx, hinge.dy)
      ..quadraticBezierTo(s * 0.34, s * 0.34, s * 0.46, s * 0.16);
    final rechts = Path()
      ..moveTo(hinge.dx, hinge.dy)
      ..quadraticBezierTo(s * 0.66, s * 0.34, s * 0.54, s * 0.16);
    final paint = _stroke(_metall, s * 0.045);
    c.drawPath(links, paint);
    c.drawPath(rechts, paint);
  }

  void _scaler(Canvas c, double s) {
    _griffStab(c, s, s * 0.55);
    c.drawLine(Offset(s * 0.5, s * 0.55), Offset(s * 0.5, s * 0.36),
        _stroke(_metall, s * 0.035));
    // Sichelförmige Spitze
    final p = Path()
      ..moveTo(s * 0.5, s * 0.36)
      ..quadraticBezierTo(s * 0.46, s * 0.2, s * 0.6, s * 0.14)
      ..quadraticBezierTo(s * 0.52, s * 0.22, s * 0.5, s * 0.36);
    c.drawPath(p, _fill(_metallDunkel));
  }

  void _sauger(Canvas c, double s) {
    // Gebogenes, dickes Saugrohr
    final p = Path()
      ..moveTo(s * 0.32, s * 0.92)
      ..lineTo(s * 0.32, s * 0.5)
      ..quadraticBezierTo(s * 0.32, s * 0.28, s * 0.6, s * 0.22);
    c.drawPath(p, _stroke(_metall, s * 0.075));
    c.drawPath(p, _stroke(_glanz, s * 0.02));
    // Saugöffnung
    c.drawCircle(Offset(s * 0.62, s * 0.22), s * 0.05, _fill(_metallDunkel));
    c.drawCircle(Offset(s * 0.62, s * 0.22), s * 0.028, _fill(Colors.black26));
  }

  @override
  bool shouldRepaint(covariant _InstrumentPainter old) => old.id != id;
}
