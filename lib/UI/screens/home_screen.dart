// ignore_for_file: unused_element_parameter
import 'package:flutter/material.dart';
import 'package:axisflow/core/constants/app_strings.dart';
import 'package:axisflow/core/config/app_config.dart';
import 'package:axisflow/controller/transaction_controller.dart';
import 'package:axisflow/data/models/transaction_model.dart';
import 'package:axisflow/core/constants/app_sizes.dart';
import 'package:axisflow/core/constants/app_spacing.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/core/theme/app_text_styles.dart';
import 'package:axisflow/ui/screens/add_transaction.dart';
import 'package:axisflow/ui/widgets/common/section_header.dart';
import 'package:axisflow/ui/widgets/navigation/sidemenu.dart';
import 'package:axisflow/ui/widgets/navigation/home_header.dart';
import 'package:axisflow/ui/widgets/cards/insight_card.dart';
import 'package:axisflow/ui/widgets/tiles/transaction_tile.dart';
import 'package:axisflow/ui/widgets/charts/barchart.dart';
import 'package:axisflow/core/formatters.dart';

class HomeScreen extends StatelessWidget {
  final TransactionController controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomeScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final analytics = controller.analytics;
        final weeklyData = analytics.weeklyData;
        final recentTransactions = controller.transactions.take(3).toList();

        return Scaffold(
          key: _scaffoldKey,
          drawer: AppDrawer(controller: controller, selectedIndex: 0),
          backgroundColor: AppColors.surfaceBackground,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddTransactionSheet(controller: controller),
              );
            },
            child: const Icon(Icons.add, color: AppColors.black),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeHeader(controller: controller, scaffoldKey: _scaffoldKey),
                  const SizedBox(height: AppSpacing.section),
                  const _GreetingSection(),
                  const SizedBox(height: AppSpacing.section),
                  _TodayFlow(amount: analytics.todayNetFlow),
                  const SizedBox(height: AppSpacing.section),
                  InsightCard(message: analytics.summaryInsight),
                  const SizedBox(height: AppSpacing.section),
                  _WeeklyRhythm(
                    weeklyData: weeklyData,
                    dailyAverage: analytics.averageDailyExpense,
                  ),
                  const SizedBox(height: AppSpacing.section),
                  _RecentActivity(transactions: recentTransactions),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GreetingSection extends StatelessWidget {
  const _GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppStrings.goodMorning}, ${AppCredentials.userName}',
          style: AppTextStyles.sectionTitle.copyWith(
            color: AppColors.onSurface,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Container(
              width: AppSpacing.xs,
              height: AppSpacing.xs,
              decoration:  BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              AppStrings.trackMessage,
              style: AppTextStyles.body.copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TodayFlow extends StatelessWidget {
  final double amount;

  const _TodayFlow({required this.amount, super.key});

  @override
  Widget build(BuildContext context) {
    final amountString = formatCompactCurrency(amount);

    return Center(
      child: Column(
        children: [
          Text(
            AppStrings.todayFlowLabel,
            style: AppTextStyles.body.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: AppSizes.badge,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            amountString,
            style: AppTextStyles.sectionTitle.copyWith(
              color: amount >= 0 ? Theme.of(context).colorScheme.primary : AppColors.secondary,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyRhythm extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyData;
  final double dailyAverage;

  const _WeeklyRhythm({
    required this.weeklyData,
    required this.dailyAverage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.weeklyRhythmTitle,
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
            ),
            Text(
              'Avg: ${formatCompactCurrency(dailyAverage)}/day',
              style: AppTextStyles.body.copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        barchart(data: weeklyData),
      ],
    );
  }
}

class _RecentActivity extends StatelessWidget {
  final List<Transaction> transactions;

  const _RecentActivity({required this.transactions, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: AppStrings.recentActivityTitle,
          actionText: AppStrings.viewAll,
          onAction: () {},
        ),
        const SizedBox(height: AppSpacing.lg),
        if (transactions.isEmpty)
          Text('No recent activity yet.', style: AppTextStyles.bodyMuted)
        else
          ...transactions.map((transaction) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: TransactionTile(transaction: transaction),
            );
          }),
      ],
    );
  }
}
