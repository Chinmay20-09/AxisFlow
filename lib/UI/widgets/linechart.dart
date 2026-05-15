// lib/ui/widgets/weekly_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';

// ignore: camel_case_types
class linechart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const linechart({super.key, required this.data});
  @override
Widget build(BuildContext context) {
  if (data.isEmpty) {
    return const Center(
      child: Text(
        'No weekly data available yet.',
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 13,
        ),
      ),
    );
  }

  final maxY = _maxY();
  final minY = _minY();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _legend('Income', AppTheme.income),
            const SizedBox(width: 14),

            _legend('Expense', AppTheme.expense),
            const SizedBox(width: 14),

            _legend('Net', AppTheme.pending),
          ],
        ),
      ),

      const SizedBox(height: 20),

      SizedBox(
        height: 160,
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,

            extraLinesData: ExtraLinesData(
              horizontalLines: minY < 0
                  ? [
                      HorizontalLine(
                        y: 0,
                        color: AppTheme.border,
                        strokeWidth: 1,
                        dashArray: [6, 4],
                      ),
                    ]
                  : [],
            ),

            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipBorder: BorderSide(color: AppTheme.border),
                tooltipBorderRadius: BorderRadius.circular(10),
                fitInsideHorizontally: true,
                fitInsideVertically: true,

                getTooltipItems: (spots) {
                  final labels = ['Income', 'Expense', 'Net'];

                  final colors = [
                    AppTheme.income,
                    AppTheme.expense,
                    AppTheme.pending,
                  ];

                  return spots.map((s) {
                    return LineTooltipItem(
                      '${labels[s.barIndex]}\n₹${s.y.toStringAsFixed(0)}',
                      TextStyle(
                        color: colors[s.barIndex],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList();
                },
              ),
            ),

            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),

              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),

              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),

              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,

                  getTitlesWidget: (val, meta) {
                    final idx = val.toInt();

                    if (idx < 0 || idx >= data.length) {
                      return const SizedBox();
                    }

                    final day = data[idx]['day'] as DateTime;

                    return Text(
                      DateFormat('E').format(day),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    );
                  },
                ),
              ),
            ),

            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (maxY - minY) / 4,

              getDrawingHorizontalLine: (_) => FlLine(
                color: AppTheme.border,
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
            ),

            borderData: FlBorderData(show: false),

            lineBarsData: [
              _buildLine(
                spots: _toSpots('income'),
                color: AppTheme.income,
                isCurved: true,
              ),

              _buildLine(
                spots: _toSpots('expense'),
                color: AppTheme.expense,
                isCurved: true,
              ),

              _buildLine(
                spots: _toNetSpots(),
                color: AppTheme.pending,
                isCurved: true,
                isDashed: true,
              ),
            ],
          ),
        ),
      ),
    ],
  );

  }

  LineChartBarData _buildLine({
    required List<FlSpot> spots,
    required Color color,
    bool isCurved = true,
    bool isDashed = false,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: isCurved,
      curveSmoothness: 0.35,
      color: color,
      barWidth: isDashed ? 1.5 : 2.5,
      dashArray: isDashed ? [6, 4] : null,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
          radius: 3,
          color: color,
          strokeWidth: 1.5,
          strokeColor: AppTheme.surface,
        ),
      ),
      belowBarData: BarAreaData(
        show: !isDashed,
        color: color.withValues(alpha: 0.06),
      ),
    );
  }

  List<FlSpot> _toSpots(String key) {
    final today = DateTime.now();
    final spots = <FlSpot>[];

    for (int i = 0; i < data.length; i++) {
      final chartDay = data[i]['day'] as DateTime;

final isFuture =
    chartDay.isAfter(
      DateTime(
        today.year,
        today.month,
        today.day,
      ),
    );


if (!isFuture) {
  spots.add(
    FlSpot(
      i.toDouble(),
      data[i][key] as double,
      
    ),
  );
}
    }
    return spots;
  }

  List<FlSpot> _toNetSpots() {
    return List.generate(data.length, (i) {
      final income = data[i]['income'] as double;
      final expense = data[i]['expense'] as double;
      return FlSpot(i.toDouble(), income - expense);
    });
  }

  double _maxY() {
    double max = 0;
    for (final d in data) {
      if ((d['income'] as double) > max) max = d['income'] as double;
      if ((d['expense'] as double) > max) max = d['expense'] as double;
      final net = (d['income'] as double) - (d['expense'] as double);
      if (net > max) max = net;
    }
    return max == 0 ? 100 : max * 1.25;
  }

  double _minY() {
    double min = 0;
    for (final d in data) {
      final net = (d['income'] as double) - (d['expense'] as double);
      if (net < min) min = net;
    }
    return min == 0 ? 0 : min * 1.25;
  }

  Widget _legend(String label, Color color) => Row(
    children: [
      Container(
        width: 20,
        height: 2.5,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
    ],
  );
}