// ignore_for_file: unused_element_parameter

import 'package:flutter/material.dart';
import 'package:axisflow/controller/transaction_controller.dart';
import 'package:axisflow/core/constants/app_radius.dart';
import 'package:axisflow/core/constants/app_sizes.dart';
import 'package:axisflow/core/constants/app_spacing.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/core/theme/app_text_styles.dart';
import 'package:axisflow/ui/widgets/charts/linechart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:axisflow/core/formatters.dart';
import 'package:axisflow/ui/widgets/cards/analytics_card.dart';
import 'package:axisflow/ui/widgets/cards/glass_card.dart';
import 'package:axisflow/ui/widgets/navigation/sidemenu.dart';
import 'package:axisflow/ui/widgets/navigation/menu_button.dart';
import 'package:axisflow/ui/widgets/tiles/allocation_tile.dart';
import 'package:axisflow/ui/widgets/common/section_header.dart';

class AxisFlowInsightsScreen extends StatelessWidget {
  final TransactionController controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AxisFlowInsightsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final analytics = controller.analytics;
        final topCategories = analytics.topExpenseCategories;
        final monthIcon = analytics.totalIncome > analytics.totalExpense
            ? Icons.trending_up
            : Icons.trending_down;
        final monthIconColor = analytics.totalIncome > analytics.totalExpense
            ? Theme.of(context).colorScheme.primary
            : AppColors.secondary;

        return Scaffold(
          key: _scaffoldKey,
          drawer: AppDrawer(controller: controller, selectedIndex: 1),
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DashboardTopBar(
                    controller: controller,
                    scaffoldKey: _scaffoldKey,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  const Text(
                    'Extraordinary For You',
                    style: AppTextStyles.pageTitle,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Zoomed out view of life',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  GlassCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xxs,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                ),
                                child: Text(
                                  'AI ANALYSIS',
                                  style: AppTextStyles.cardBadge,
                                ),
                              ),

                              const SizedBox(height: AppSpacing.lg),
                              const Text(
                                'Behavioral Intelligence',
                                style: AppTextStyles.sectionTitle,
                              ),
                              const SizedBox(height: AppSpacing.md),

                              Text(
                                analytics.behaviorInsight,
                                style: AppTextStyles.body.copyWith(
                                  height: 1.5,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xxl),
                        Icon(
                          Icons.psychology,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.2),
                          size: AppSizes.chartDiameter / 1.66,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: SectionHeader(
                                title: 'Spending Trends',
                                subtitle: 'Where your money went this month',
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    (formatCompactCurrency(
                                      analytics.currentMonthExpense,
                                    )),
                                    style: AppTextStyles.statValue,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    children: [
                                      Icon(
                                        monthIcon,
                                        size: AppSizes.iconSmall,
                                        color: monthIconColor,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.xxxl),
                        linechart(data: analytics.weeklyData),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Allocation',
                          style: AppTextStyles.sectionTitle,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: AppSizes.chartDiameter,
                                width: AppSizes.chartDiameter,
                                child: PieChart(
                                  PieChartData(
                                    centerSpaceRadius:
                                        AppSizes.chartCenterRadius,
                                    sectionsSpace: 2,
                                    sections: (() {
                                      final chartData = topCategories
                                          .take(3)
                                          .toList();
                                      final total = chartData.fold<double>(
                                        0,
                                        (sum, item) => sum + item.total,
                                      );

                                      return chartData.asMap().entries.map((
                                        entry,
                                      ) {
                                        final index = entry.key;
                                        final item = entry.value;

                                        return PieChartSectionData(
                                          value: item.total.toDouble(),
                                          color: getRankColor(index),
                                          radius: 50,
                                          title: total == 0
                                              ? '0%'
                                              : '${((item.total / total) * 100).round()}%',
                                          titleStyle: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        );
                                      }).toList();
                                    })(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),
                        if (topCategories.isEmpty)
                          Text(
                            'No expense categories available yet.',
                            style: AppTextStyles.bodyMuted,
                          )
                        else
                          ...topCategories.take(3).map((allocation) {
                            final color = getRankColor(
                              topCategories.indexOf(allocation),
                            );
                            return AllocationTile(
                              title: allocation.category,
                              value: formatCompactCurrency(allocation.total),
                              dotColor: color,
                            );
                          }),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Savings Velocity',
                          style: AppTextStyles.sectionTitle,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Growth trajectory for 2024',
                          style: AppTextStyles.bodyMuted,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Row(
                          children: [
                            Expanded(
                              child: AnalyticsCard(
                                title: 'Saved This Year',
                                value: (formatCompactCurrency(
                                  analytics.yearToDateSavings,
                                )),
                                subtitle: 'Year-to-date savings',
                                icon: Icons.savings,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.04,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: AnalyticsCard(
                                title: 'Avg. Rate',
                                value:
                                    '${analytics.savingsRate.clamp(0.0, 99.9).toStringAsFixed(1)}%',
                                subtitle: 'Net margin on income',
                                icon: monthIcon,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.04,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DashboardTopBar extends StatelessWidget {
  final TransactionController controller;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const _DashboardTopBar({
    super.key,
    required this.controller,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            MenuButton(scaffoldKey: scaffoldKey, controller: controller),
            const SizedBox(width: AppSpacing.sm),
            Text('AxisFlow', style: AppTextStyles.appTitle),
          ],
        ),
      ],
    );
  }
}

Color getRankColor(int index) {
  switch (index) {
    case 0:
      return Colors.red;
    case 1:
      return Colors.orange;
    case 2:
      return Colors.green;
    default:
      return Colors.grey;
  }
}
