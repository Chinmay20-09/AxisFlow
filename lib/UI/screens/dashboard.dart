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
            ? AppColors.primary
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
                  const Text('Insights', style: AppTextStyles.pageTitle),
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
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                ),
                                child: const Text(
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
                          color: AppColors.primary.withValues(alpha: 0.2),
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
                              child: _DashboardSectionHeader(
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
                                    centerSpaceRadius: 50,
                                    sectionsSpace: 2,
                                    sections: topCategories
                                        .take(3)
                                        .toList()
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                          final index = entry.key;

                                          return PieChartSectionData(
                                            color: getRankColor(index),
                                            titleStyle: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          );
                                        })
                                        .toList(),
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
            const Text('AxisFlow', style: AppTextStyles.appTitle),
          ],
        ),
      ],
    );
  }
}

class _DashboardSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _DashboardSectionHeader({
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: AppTextStyles.bodyMuted),
      ],
    );
  }
}

class AllocationTile extends StatelessWidget {
  final String title;
  final String value;
  final Color dotColor;

  const AllocationTile({
    required this.title,
    required this.value,
    required this.dotColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: TextStyle(color: AppColors.textPrimary)),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
