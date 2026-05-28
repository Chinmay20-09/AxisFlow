// ignore_for_file: unused_element_parameter
import 'package:flutter/material.dart';
import 'package:axisflow/core/constants/app_strings.dart';
import 'package:axisflow/core/config/app_config.dart';
import 'package:axisflow/controller/transaction_controller.dart';
import 'package:axisflow/core/constants/app_radius.dart';
import 'package:axisflow/data/models/transaction_model.dart';
import 'package:axisflow/core/constants/app_sizes.dart';
import 'package:axisflow/core/constants/app_spacing.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/core/theme/app_text_styles.dart';
import 'package:axisflow/ui/screens/add_transaction_sheet.dart';
import 'package:axisflow/ui/widgets/cards/glass_card.dart';
import 'package:axisflow/ui/widgets/common/section_header.dart';
import 'package:axisflow/ui/widgets/navigation/sidemenu.dart';
import 'package:axisflow/ui/widgets/navigation/menu_button.dart';
import 'package:axisflow/ui/widgets/charts/barchart.dart';

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
            backgroundColor: AppColors.primary,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddTransactionSheet(controller: controller),
              );
            },
            child: const Icon(Icons.add, color: AppColors.onSurface),
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
                  _HomeHeader(
                    controller: controller,
                    scaffoldKey: _scaffoldKey,
                  ),
                  const SizedBox(height: AppSpacing.section),
                  const _GreetingSection(),
                  const SizedBox(height: AppSpacing.section),
                  _TodayFlow(amount: analytics.todayNetFlow),
                  const SizedBox(height: AppSpacing.section),
                  _InsightCard(message: analytics.summaryInsight),
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

class _HomeHeader extends StatelessWidget {
  final TransactionController controller;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const _HomeHeader({
    required this.controller,
    required this.scaffoldKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            MenuButton(scaffoldKey: scaffoldKey),
            const SizedBox(width: AppSpacing.sm),
            Text(
              AppStrings.appTitle,
              style: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.primary,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ],
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
              decoration: const BoxDecoration(
                color: AppColors.primary,
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
    final amountString = amount == 0
        ? '\$0.00'
        : '${amount.isNegative ? '-' : ''}\$${amount.abs().toStringAsFixed(2)}';

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
              color: AppColors.primary,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String message;

  const _InsightCard({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: AppSizes.iconSmall,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.aiInsightBadge,
                style: AppTextStyles.cardBadge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            style: AppTextStyles.body.copyWith(
              color: AppColors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.4,
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
              'Avg: \$${dailyAverage.toStringAsFixed(0)}/day',
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
              child: _TransactionTile(
                icon: transaction.type == TransactionType.income
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                title: transaction.note.isNotEmpty
                    ? transaction.note
                    : transaction.category,
                subtitle: _formatTransactionSubtitle(transaction.createdAt),
                amount: _formatTransactionAmount(transaction),
              ),
            );
          }),
      ],
    );
  }

  String _formatTransactionAmount(Transaction transaction) {
    final sign = transaction.type == TransactionType.income ? '+' : '-';
    return '$sign\$${transaction.amount.toStringAsFixed(2)}';
  }

  String _formatTransactionSubtitle(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    if (difference.inDays == 0) {
      return 'Today, ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
    }
    if (difference.inDays == 1) {
      return 'Yesterday, ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
    }
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}

class _TransactionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;

  const _TransactionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(width: AppSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            amount,
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
