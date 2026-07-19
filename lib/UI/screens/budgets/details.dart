import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/controller/transaction_controller.dart';
import 'package:axisflow/ui/widgets/navigation/sidemenu.dart';
import 'package:axisflow/ui/widgets/navigation/menu_button.dart';
import 'package:axisflow/ui/widgets/cards/glass_card.dart';
import 'package:axisflow/ui/widgets/budget_card.dart';
import 'package:axisflow/ui/screens/budgets/budget_models.dart';
import 'package:axisflow/core/formatters.dart';
import 'package:axisflow/ui/widgets/pulsing_glow.dart';
import 'package:axisflow/ui/screens/budgets/budget_planner.dart';

// ── Screen ─────────────────────────────────────────────────────────────────────
class BudgetDetailsScreen extends StatefulWidget {
  final TransactionController controller;
  const BudgetDetailsScreen({super.key, required this.controller});

  @override
  State<BudgetDetailsScreen> createState() => _BudgetDetailsScreenState();
}

class _BudgetDetailsScreenState extends State<BudgetDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Build budget items from analytics data + BudgetService allocations
  List<BudgetItem> _buildBudgetItems() {
    final analytics = widget.controller.analytics;
    final categories = analytics.topExpenseCategories;

    if (categories.isEmpty) return [];

    final budgetData = getBudgetData();
    final monthlyIncome = budgetData.monthlyIncome;
    final allocations = budgetData.allocations;

    return categories.map((cat) {
      final spent = cat.total;
      final allocationPercent = allocations[cat.category] ?? 0.0;
      final budgetAmount = monthlyIncome * allocationPercent / 100;

      final remaining = budgetAmount - spent;
      final progress = budgetAmount > 0 ? spent / budgetAmount : 0.0;

      // Determine status
      BudgetStatus status;
      if (budgetAmount <= 0) {
        status = BudgetStatus.pending;
      } else if (progress < 0.5) {
        status = BudgetStatus.onTrack;
      } else if (progress < 0.75) {
        status = BudgetStatus.caution;
      } else if (progress < 1.0) {
        status = BudgetStatus.critical;
      } else {
        status = BudgetStatus.critical;
      }

      final iconInfo = categoryIconInfo(cat.category);

      return BudgetItem(
        icon: iconInfo.icon,
        title: cat.category,
        spent: formatCompactCurrency(spent),
        total: formatCompactCurrency(budgetAmount),
        remaining: formatCompactCurrency(remaining),
        progress: progress.clamp(0.0, 1.0),
        status: status,
        iconBg: iconInfo.bgColor,
        iconColor: iconInfo.fgColor,
        allocationPercent: allocationPercent,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildBudgetItems();

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(controller: widget.controller, selectedIndex: 4),

      backgroundColor: AppColors.background,
      extendBody: true,
      body: CustomScrollView(
        slivers: [
          // ── Top App Bar ────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface.withValues(alpha: (0.85)),
            elevation: 0,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: const SizedBox.expand(),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: MenuButton(
                scaffoldKey: _scaffoldKey,
                controller: widget.controller,
              ),
            ),
            title: Row(
              children: [
                Text(
                  'AxisFlow',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.48,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ClipOval(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.outline.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Body ────────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Page heading
                const Text(
                  'Budget Breakdown',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Track every category against its monthly budget.',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant.withValues(alpha: (0.8)),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Monthly Overview glass card ─────────────────────────────
                AnimatedBuilder(
                  animation: widget.controller,
                  builder: (context, _) {
                    final budgetData = getBudgetData();
                    final monthlyIncome = budgetData.monthlyIncome;
                    final allocations = budgetData.allocations;
                    final analytics = widget.controller.analytics;

                    // Calculate total budget from allocation
                    final allocatedPercent = allocations.values.fold(
                      0.0,
                      (sum, value) => sum + value,
                    );

                    final totalBudget = monthlyIncome * allocatedPercent / 100;

                    final totalSpent = analytics.currentMonthExpense;
                    final remaining = totalBudget - totalSpent;
                    final progress = totalBudget > 0
                        ? totalSpent / totalBudget
                        : 0.0;

                    return GlassCard(
                      child: Stack(
                        children: [
                          // Ambient glow blob
                          Positioned(
                            top: -32,
                            right: -32,
                            child: const PulsingGlow(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MONTHLY OVERVIEW',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.1 * 11,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Stat rows
                                Row(
                                  children: [
                                    _OverviewStat(
                                      label: 'Budget',
                                      value: formatCompactCurrency(totalBudget),
                                      color: AppColors.onSurface,
                                    ),
                                    const SizedBox(width: 24),
                                    _OverviewStat(
                                      label: 'Spent',
                                      value: formatCompactCurrency(
                                        totalSpent,
                                      ),
                                      color: totalSpent >
                                              totalBudget
                                          ? AppColors.error
                                          : AppColors.onSurface,
                                    ),
                                    const SizedBox(width: 24),
                                    _OverviewStat(
                                      label: 'Remaining',
                                      value: formatCompactCurrency(remaining),
                                      color: remaining < 0
                                          ? AppColors.error
                                          : AppColors.onSurface,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Progress bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: progress.clamp(0.0, 1.0),
                                    minHeight: 6,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: (0.05),
                                    ),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      progress > 0.8
                                          ? AppColors.error
                                          : progress > 0.5
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: (0.4)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Budget period label + allocation info
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                    Text(
                                      'Monthly budget period',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // ── Category Budget cards ─────────────────────────────────
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text(
                        'No expense data yet.\nAdd transactions to see budget breakdowns.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: (0.6),
                          ),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                  )
                else
                  ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: BudgetCard(item: item),
                      )),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Overview stat widget ───────────────────────────────────────────────────────
class _OverviewStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _OverviewStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.secondary.withValues(alpha: (0.6)),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.36,
          ),
        ),
      ],
    );
  }
}
