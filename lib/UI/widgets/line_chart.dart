// lib/ui/widgets/weekly_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';

class Line_Chart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const Line_Chart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.show_chart, color: AppTheme.textSecondary),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No weekly data available yet.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    final maxY = _maxY();
    final minY = _minY(); // net can go negative

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.surface, AppTheme.surfaceAlt],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.income.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.show_chart, size: 16, color: AppTheme.income),
              ),
              const SizedBox(width: 10),
              const Text(
                'LAST 7 DAYS',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _legend('Income', AppTheme.income),
              const SizedBox(width: 10),
              _legend('Expense', AppTheme.expense),
              const SizedBox(width: 10),
              _legend('Net', AppTheme.pending),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,

                // Zero line if net goes negative
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
                      final colors = [AppTheme.income, AppTheme.expense, AppTheme.pending];
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
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= data.length) return const SizedBox();
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
                  // Income line
                  _buildLine(
                    spots: _toSpots('income'),
                    color: AppTheme.income,
                    isCurved: true,
                  ),
                  // Expense line
                  _buildLine(
                    spots: _toSpots('expense'),
                    color: AppTheme.expense,
                    isCurved: true,
                  ),
                  // Net line (income - expense), dashed
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
      ),
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
    return List.generate(data.length, (i) {
      return FlSpot(i.toDouble(), (data[i][key] as double));
    });
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