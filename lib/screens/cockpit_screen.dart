import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import '../main.dart';
import '../core/services/fortschritt_service.dart';
import '../theme/zfa_theme.dart';
import 'quiz_screen.dart';

/// Prüfungs-Cockpit (Bloomberg-Stil): Readiness-Score, Bestehensprognose,
/// 7-Tage-Trend und Themen-Beherrschung auf einen Blick.
class CockpitScreen extends StatefulWidget {
  const CockpitScreen({super.key});

  @override
  State<CockpitScreen> createState() => _CockpitScreenState();
}

class _CockpitScreenState extends State<CockpitScreen> {
  @override
  void initState() {
    super.initState();
    fortschrittService.readinessSnapshot();
  }

  Color _ampel(double q) {
    if (q >= 0.7) return ZfaTheme.gruen;
    if (q >= 0.4) return ZfaTheme.gold;
    return ZfaTheme.rot;
  }

  @override
  Widget build(BuildContext context) {
    final fs = fortschrittService;
    final readiness = fs.readinessScore();
    final chance = fs.bestehensWahrscheinlichkeit();
    final trend = fs.readinessTrend();
    final tc = Theme.of(context).colorScheme.onSurface;
    final schwach = fs.schwaechsterBereich();

    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 6),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: tc),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text('Prüfungs-Cockpit',
                        style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: [
                    // Readiness-Gauge + Bestehenschance
                    FadeInDown(
                      child: GlassCard(
                        padding: const EdgeInsets.all(22),
                        child: Row(
                          children: [
                            _Gauge(
                              wert: readiness,
                              farbe: _ampel(readiness / 100),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Bestehens-Chance',
                                      style: TextStyle(
                                          color: tc.withOpacity(0.7),
                                          fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text('$chance %',
                                      style: TextStyle(
                                          color: _ampel(chance / 100),
                                          fontSize: 40,
                                          fontWeight: FontWeight.w800,
                                          height: 1.0)),
                                  const SizedBox(height: 8),
                                  Text(
                                    chance >= 70
                                        ? 'Sehr gut – bleib dran!'
                                        : chance >= 45
                                            ? 'Auf gutem Weg.'
                                            : 'Noch etwas Übung nötig.',
                                    style: TextStyle(
                                        color: tc.withOpacity(0.7),
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 7-Tage-Trend
                    Text('Verlauf (7 Tage)',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    GlassCard(
                      padding: const EdgeInsets.fromLTRB(10, 20, 18, 10),
                      child: SizedBox(
                        height: 140,
                        child: _TrendChart(trend: trend, farbe: ZfaTheme.hellblau),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Themen-Beherrschung
                    Text('Themen-Beherrschung',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    GlassCard(
                      child: Column(
                        children: FortschrittService.hauptBereiche.map((b) {
                          final g = fs.bereichGesamt[b] ?? 0;
                          final q = g == 0 ? 0.0 : fs.bereichQuote(b);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 132,
                                  child: Text(b,
                                      style: TextStyle(
                                          color: tc,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                ),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: g == 0 ? 0 : q,
                                      minHeight: 9,
                                      backgroundColor: tc.withOpacity(0.12),
                                      valueColor:
                                          AlwaysStoppedAnimation(_ampel(q)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(g == 0 ? 'neu' : '${(q * 100).round()}%',
                                    style: TextStyle(
                                        color: tc.withOpacity(0.7),
                                        fontSize: 12)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Empfehlung
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: ZfaTheme.blauGrad,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: ZfaTheme.blau.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🎯 Größter Hebel: $schwach',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          const Text(
                              'Übe gezielt dein schwächstes Thema – das hebt die Chance am stärksten.',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      QuizScreen(nurBereich: schwach)),
                            ).then((_) => setState(() {})),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: ZfaTheme.royal,
                            ),
                            child: const Text('Jetzt trainieren →'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Gauge extends StatelessWidget {
  final int wert;
  final Color farbe;
  const _Gauge({required this.wert, required this.farbe});

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      width: 116,
      height: 116,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 116,
            height: 116,
            child: CustomPaint(
              painter: _GaugePainter(wert / 100, farbe, tc.withOpacity(0.12)),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$wert',
                  style: TextStyle(
                      color: tc,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      height: 1.0)),
              Text('Readiness',
                  style:
                      TextStyle(color: tc.withOpacity(0.6), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double fortschritt;
  final Color farbe;
  final Color spur;
  _GaugePainter(this.fortschritt, this.farbe, this.spur);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 7;
    const start = math.pi * 0.75;
    const sweep = math.pi * 1.5;
    final spurP = Paint()
      ..color = spur
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final wertP = Paint()
      ..shader = SweepGradient(
        startAngle: start,
        endAngle: start + sweep,
        colors: [farbe.withOpacity(0.6), farbe],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start,
        sweep, false, spurP);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start,
        sweep * fortschritt.clamp(0.0, 1.0), false, wertP);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.fortschritt != fortschritt || old.farbe != farbe;
}

class _TrendChart extends StatelessWidget {
  final List<MapEntry<String, int>> trend;
  final Color farbe;
  const _TrendChart({required this.trend, required this.farbe});

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).colorScheme.onSurface;
    final spots = <FlSpot>[
      for (int i = 0; i < trend.length; i++)
        FlSpot(i.toDouble(), trend[i].value.toDouble()),
    ];
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (v) =>
              FlLine(color: tc.withOpacity(0.08), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 50,
              reservedSize: 28,
              getTitlesWidget: (v, _) => Text('${v.toInt()}',
                  style:
                      TextStyle(color: tc.withOpacity(0.5), fontSize: 10)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= trend.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(trend[i].key,
                      style: TextStyle(
                          color: tc.withOpacity(0.6), fontSize: 11)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: farbe,
            barWidth: 3,
            dotData: FlDotData(
              getDotPainter: (s, _, __, ___) => FlDotCirclePainter(
                  radius: 3.5, color: farbe, strokeWidth: 0),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [farbe.withOpacity(0.3), farbe.withOpacity(0.0)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
