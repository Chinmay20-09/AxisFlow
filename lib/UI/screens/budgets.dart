import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/controller/transaction_controller.dart';
import 'package:axisflow/ui/widgets/navigation/sidemenu.dart';
import 'package:axisflow/ui/widgets/navigation/menu_button.dart';
import 'package:axisflow/ui/widgets/cards/ai_insight_card.dart';
import 'package:axisflow/ui/widgets/cards/glass_card.dart';
import 'package:axisflow/core/formatters.dart';
import 'package:axisflow/ui/screens/budgets/details.dart';
import 'package:axisflow/ui/widgets/pulsing_glow.dart';
import 'package:axisflow/ui/screens/budgets/budget_planner.dart';

// ── Screen ─────────────────────────────────────────────────────────────────────
class BudgetsScreen extends StatefulWidget {
  final TransactionController controller;
  const BudgetsScreen({super.key, required this.controller});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
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
                  'Budgets',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Did I stay in control?',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant.withValues(alpha: (0.8)),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Bento row: Remaining + AI ──────────────────────────────
                _BentoRow(controller: widget.controller),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bento row ──────────────────────────────────────────────────────────────────
class _BentoRow extends StatelessWidget {
  final TransactionController controller;

  const _BentoRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Remaining balance card (driven from analytics)
        AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final analytics = controller.analytics;
            final remainingValue =
                analytics.totalIncome -
                analytics.currentMonthExpense -
                analytics.totalPending;
            final remainingText = formatCompactCurrency(remainingValue);

            return GlassCard(
              child: Stack(
                children: [
                  // Ambient glow blob
                  Positioned(top: -32, right: -32, child: const PulsingGlow()),
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REMAINING BALANCE',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1 * 11,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              remainingText,
                              style: const TextStyle(
                                color: AppColors.onSurface,
                                fontSize: 36,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.72,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'left this month',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _PillButton(
                              label: 'Adjust Limits',
                              filled: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BudgetPlannerScreen(
                                      controller: controller,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            _PillButton(
                              label: 'View Details',
                              filled: false,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BudgetDetailsScreen(
                                      controller: controller,
                                    ),
                                  ),
                                );
                              },
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
        const SizedBox(height: 12),

        // AI Insight card (driven from analytics)
        AnimatedBuilder(
          animation: controller,
          builder: (ctx, _) {
            final analytics = controller.analytics;
            final top = analytics.topExpenseCategories.isNotEmpty
                ? analytics.topExpenseCategories.first
                : null;
            final insightText = top != null
                ? 'Your top category is "${top.category}" (${formatCompactCurrency(top.total)}). ${analytics.summaryInsight}'
                : analytics.summaryInsight;
            return AiInsightCard(message: insightText);
          },
        ),
      ],
    );
  }
}


// ── Pill buttons ───────────────────────────────────────────────────────────────
class _PillButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: filled
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: filled
              ? null
              : Border.all(color: AppColors.outline.withValues(alpha: (0.2))),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? AppColors.onPrimary : AppColors.onSurface,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.05 * 11,
          ),
        ),
      ),
    );
  }
}


