import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:axisflow/core/formatters.dart';
import 'package:intl/intl.dart';
import 'package:axisflow/core/theme/app_theme.dart';

// ignore: camel_case_types
class barchart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const barchart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No weekly data available yet.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      );
    }

    final maxY = _maxY();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _legend('Income', AppTheme.income, Icons.arrow_upward),

            const SizedBox(width: 14),

            _legend('Expense', AppTheme.expense, Icons.arrow_downward),
          ],
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 150,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              minY: 0,

              barTouchData: BarTouchData(
                enabled: true,

                touchTooltipData: BarTouchTooltipData(
                  tooltipBorder: BorderSide(color: AppTheme.border),

                  tooltipBorderRadius: BorderRadius.circular(10),

                  tooltipMargin: 8,
                  fitInsideHorizontally: true,

                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final label = rodIndex == 0 ? 'Income' : 'Expense';

                    return BarTooltipItem(
                      '$label\n${formatCompactCurrency(rod.toY)}',

                      const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 12,
                      ),
                    );
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
                horizontalInterval: maxY / 4,

                getDrawingHorizontalLine: (val) => FlLine(
                  color: AppTheme.border,
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),

                drawVerticalLine: false,
              ),

              borderData: FlBorderData(show: false),

              barGroups: List.generate(data.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barsSpace: 10,

                  barRods: [
                    BarChartRodData(
                      toY: (data[i]['income'] as double),

                      color: AppTheme.income,

                      width: 10,

                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),

                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxY,

                        color: AppTheme.border.withValues(alpha: 0.1),
                      ),
                    ),

                    BarChartRodData(
                      toY: (data[i]['expense'] as double),

                      color: AppTheme.expense,

                      width: 10,

                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),

                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxY,

                        color: AppTheme.border.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  double _maxY() {
    double max = 0;
    for (final d in data) {
      if ((d['income'] as double) > max) max = d['income'] as double;
      if ((d['expense'] as double) > max) max = d['expense'] as double;
    }
    return max == 0 ? 100 : max * 1.2;
  }

  Widget _legend(String label, Color color, IconData icon) => Row(
    children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
      ),
    ],
  );
}
