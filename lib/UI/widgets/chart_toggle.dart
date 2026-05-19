import 'package:flutter/material.dart';
import '../app_theme.dart';

enum ChartType { line, bar }

class ChartToggle extends StatelessWidget {
  final ChartType selected;
  final ValueChanged<ChartType> onChanged;

  const ChartToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isLine = selected == ChartType.line;

    return GestureDetector(
      onTap: () {
        onChanged(isLine ? ChartType.bar : ChartType.line);
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),

        width: 82,
        height: 38,

        padding: const EdgeInsets.symmetric(horizontal: 4),

        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppTheme.border),
        ),

        child: Stack(
          children: [
            // Active Indicator
            AnimatedAlign(
              duration: const Duration(milliseconds: 220),

              alignment: isLine ? Alignment.centerLeft : Alignment.centerRight,

              child: Container(
                width: 30,
                height: 30,

                decoration: BoxDecoration(
                  color: AppTheme.income,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            // Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                SizedBox(
                  width: 30,
                  child: Icon(
                    Icons.auto_graph,
                    size: 17,
                    color: isLine ? Colors.black : AppTheme.textSecondary,
                  ),
                ),

                SizedBox(
                  width: 30,
                  child: Icon(
                    Icons.bar_chart_rounded,
                    size: 17,
                    color: !isLine ? Colors.black : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
