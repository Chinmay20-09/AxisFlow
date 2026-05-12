// lib/ui/widgets/summary_card.dart
import 'package:flutter/material.dart';
import '../app_theme.dart';

class SummaryCard extends StatelessWidget {
  final double income;
  final double expense;
  final double pending;
  final double net;

  const SummaryCard({
    super.key,
    required this.income,
    required this.expense,
    required this.pending,
    required this.net,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.surface, AppTheme.surfaceAlt],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'NET BALANCE',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (net >= 0 ? AppTheme.income : AppTheme.expense)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  net >= 0 ? 'Positive' : 'Negative',
                  style: TextStyle(
                    color: net >= 0 ? AppTheme.income : AppTheme.expense,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${net >= 0 ? '+' : ''}₹${_fmt(net)}',
            style: TextStyle(
              color: net >= 0 ? AppTheme.income : AppTheme.expense,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _stat('income', income, AppTheme.income, Icons.arrow_upward),
                const SizedBox(width: 12),
                _stat('expense', expense, AppTheme.expense, Icons.arrow_downward),
                const SizedBox(width: 12),
                _stat('pending', pending, AppTheme.pending, Icons.schedule),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, double value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      constraints: const BoxConstraints(minWidth: 120),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '₹${_fmt(value)}',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _fmt(double val) {
    // ignore: curly_braces_in_flow_control_structures
    if (val.abs() >= 10000000) return '${(val / 1000000).toStringAsFixed(1)}cr';
    // ignore: curly_braces_in_flow_control_structures
    else if (val.abs() >= 100000) return '${(val / 100000).toStringAsFixed(1)}l';
    // ignore: curly_braces_in_flow_control_structures
    else if (val.abs() >= 1000) return '${(val / 1000).toStringAsFixed(1)}k';
    return val.toStringAsFixed(0);
    





  }
}