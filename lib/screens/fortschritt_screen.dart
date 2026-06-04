import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import '../main.dart';
import '../data/quiz/alle_quiz_fragen.dart';
import '../data/lernkarten_daten.dart';
import 'quiz_screen.dart';

class FortschrittScreen extends StatelessWidget {
  const FortschrittScreen({super.key});

  List<String> get _alleIds => [
        ...alleQuizFragen.map((f) => f.id),
        ...alleLernkarten().map((k) => k.id),
      ];

  @override
  Widget build(BuildContext context) {
    final fs = fortschrittService;
    final verteilung = fs.leitnerVerteilung(_alleIds);
    final bereiche = [
      'Anmeldung',
      'Hygiene',
      'Behandlungsassistenz',
      'Anästhesie',
      'Chirurgie',
      'Karies',
      'Parodontitis',
    ];
    final schwach = fs.schwaechsterBereich();

    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        title: const Text('📊 Mein Fortschritt'),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Persönliche Stats
          FadeInDown(
            child: Row(
              children: [
                _StatCard(
                  emoji: '🏆',
                  wert: '${fs.gesamtPunkte}',
                  label: 'Punkte',
                  farbe: const Color(0xFFD4AF37),
                ),
                const SizedBox(width: 12),
                _StatCard(
                  emoji: '🔥',
                  wert: '${fs.streak}',
                  label: 'Streak',
                  farbe: const Color(0xFFEF6C00),
                ),
                const SizedBox(width: 12),
                _StatCard(
                  emoji: '⭐',
                  wert: 'Lvl ${fs.level}',
                  label: 'Level',
                  farbe: const Color(0xFF1565C0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Leitner-Boxen
          const _Ueberschrift('🗂️ Leitner-Boxen'),
          const SizedBox(height: 4),
          const Text(
            'Box 1 = neu lernen · Box 5 = sicher gewusst',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (_maxWert(verteilung) * 1.2).clamp(5, 1000).toDouble(),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text('Box ${value.toInt() + 1}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
                barGroups: List.generate(5, (i) {
                  final wert = (verteilung[i + 1] ?? 0).toDouble();
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: wert,
                        width: 28,
                        borderRadius: BorderRadius.circular(8),
                        color: _boxFarbe(i + 1),
                      ),
                    ],
                    showingTooltipIndicators: wert > 0 ? [0] : [],
                  );
                }),
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.transparent,
                    tooltipMargin: 0,
                    getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                      '${rod.toY.toInt()}',
                      const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Bereiche
          const _Ueberschrift('🎯 Deine Bereiche'),
          const SizedBox(height: 14),
          ...bereiche.map((b) {
            final quote = fs.bereichQuote(b);
            final gesamt = fs.bereichGesamt[b] ?? 0;
            return _BereichZeile(
              name: b,
              quote: quote,
              beantwortet: gesamt,
            );
          }),
          const SizedBox(height: 24),

          // Empfehlung
          FadeInUp(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00695C), Color(0xFF00897B)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎯 Heute empfohlen: $schwach',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Übe gezielt deinen schwächsten Bereich – das bringt am meisten!',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(nurBereich: schwach),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF00695C),
                    ),
                    child: const Text('Jetzt lernen →'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _maxWert(Map<int, int> v) =>
      v.values.fold(0, (a, b) => a > b ? a : b);

  Color _boxFarbe(int box) {
    switch (box) {
      case 1:
        return const Color(0xFFC62828);
      case 2:
        return const Color(0xFFEF6C00);
      case 3:
        return const Color(0xFFF9A825);
      case 4:
        return const Color(0xFF7CB342);
      default:
        return const Color(0xFF2E7D32);
    }
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String wert;
  final String label;
  final Color farbe;
  const _StatCard({
    required this.emoji,
    required this.wert,
    required this.label,
    required this.farbe,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: farbe.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(wert,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: farbe)),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _Ueberschrift extends StatelessWidget {
  final String text;
  const _Ueberschrift(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800));
  }
}

class _BereichZeile extends StatelessWidget {
  final String name;
  final double quote;
  final int beantwortet;
  const _BereichZeile({
    required this.name,
    required this.quote,
    required this.beantwortet,
  });

  Color get _farbe {
    if (beantwortet == 0) return const Color(0xFF9E9E9E);
    if (quote > 0.7) return const Color(0xFF2E7D32);
    if (quote >= 0.4) return const Color(0xFFF9A825);
    return const Color(0xFFC62828);
  }

  @override
  Widget build(BuildContext context) {
    final prozent = (quote * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          // Mini-Kreisdiagramm
          SizedBox(
            width: 54,
            height: 54,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    sectionsSpace: 0,
                    centerSpaceRadius: 16,
                    sections: [
                      PieChartSectionData(
                        value: beantwortet == 0 ? 1 : quote,
                        color: _farbe,
                        radius: 11,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: beantwortet == 0 ? 0 : (1 - quote),
                        color: _farbe.withOpacity(0.15),
                        radius: 11,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Text(
                  beantwortet == 0 ? '–' : '$prozent%',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _farbe),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: beantwortet == 0 ? 0 : quote,
                    minHeight: 8,
                    backgroundColor: Colors.black12,
                    valueColor: AlwaysStoppedAnimation(_farbe),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            beantwortet == 0 ? 'neu' : '$beantwortet×',
            style: const TextStyle(fontSize: 12, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}
