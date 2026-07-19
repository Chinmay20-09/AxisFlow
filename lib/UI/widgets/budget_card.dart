import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/ui/screens/budgets/budget_models.dart';

// ── Budget card ───────────────────────────────────────────────────────────────
class BudgetCard extends StatefulWidget {
  final BudgetItem item;

  const BudgetCard({super.key, required this.item});

  @override
  State<BudgetCard> createState() => BudgetCardState();
}

class BudgetCardState extends State<BudgetCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _progress;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _progress = Tween<double>(
      begin: 0,
      end: widget.item.progress,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _statusRow() {
    switch (widget.item.status) {
      case BudgetStatus.caution:
        return Row(
          children: [
            const Icon(Icons.warning, color: AppColors.error, size: 14),
            const SizedBox(width: 6),
            const Text(
              'Caution: Over 50% limit reached',
              style: TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ],
        );
      case BudgetStatus.onTrack:
        return Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              'On track',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
              ),
            ),
          ],
        );
      case BudgetStatus.critical:
        return Row(
          children: [
            const Icon(Icons.error, color: AppColors.amber, size: 14),
            const SizedBox(width: 6),
            const Text(
              'CRITICAL: ALMOST EXCEEDED',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.08 * 11,
              ),
            ),
          ],
        );
      case BudgetStatus.pending:
        return Text(
          'Pending bills detected',
          style: TextStyle(
            color: AppColors.secondary.withValues(alpha: (0.6)),
            fontSize: 12,
          ),
        );
    }
  }

  Color get _barColor {
    switch (widget.item.status) {
      case BudgetStatus.caution:
        return Theme.of(context).colorScheme.primaryContainer;
      case BudgetStatus.onTrack:
        return Theme.of(context).colorScheme.primary.withValues(alpha: (0.4));
      case BudgetStatus.critical:
        return AppColors.error;
      case BudgetStatus.pending:
        return AppColors.onSurfaceVariant.withValues(alpha: (0.3));
    }
  }

  Color get _amountColor => widget.item.status == BudgetStatus.critical
      ? AppColors.error
      : AppColors.onSurface;

  Color get _remainingColor => widget.item.status == BudgetStatus.critical
      ? AppColors.error.withValues(alpha: (0.6))
      : AppColors.secondary.withValues(alpha: (0.6));

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white.withValues(alpha: (0.06))
                : Colors.white.withValues(alpha: (0.04)),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: (0.08))),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Top row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: widget.item.iconBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            widget.item.icon,
                            color: widget.item.iconColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Title + status
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.item.title,
                                style: const TextStyle(
                                  color: AppColors.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _statusRow(),
                            ],
                          ),
                        ),

                        // Amounts
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${widget.item.spent} / ${widget.item.total}',
                              style: TextStyle(
                                color: _amountColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.item.remaining,
                              style: TextStyle(
                                color: _remainingColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${widget.item.allocationPercent.round()}% allocated',
                              style: TextStyle(
                                color: AppColors.primary.withValues(alpha: 0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Progress bar
                    AnimatedBuilder(
                      animation: _progress,
                      builder: (context, _) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: _progress.value,
                            minHeight: 6,
                            backgroundColor: Colors.white.withValues(
                              alpha: (0.05),
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _barColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
