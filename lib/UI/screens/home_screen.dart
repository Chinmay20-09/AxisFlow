// ignore_for_file: unused_element_parameter

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:transaction/app_strings.dart';
import 'package:transaction/credentials.dart';
import 'package:transaction/controller/transaction_controller.dart';
import 'package:transaction/core/constants/app_radius.dart';
import 'package:transaction/data/transaction_model.dart';
import 'package:transaction/core/constants/app_sizes.dart';
import 'package:transaction/core/constants/app_spacing.dart';
import 'package:transaction/core/theme/app_colors.dart';
import 'package:transaction/core/theme/app_text_styles.dart';
import 'package:transaction/ui/widgets/cards/glass_card.dart';
import 'package:transaction/ui/widgets/common/section_header.dart';
import 'package:transaction/ui/widgets/sidemenu.dart';

class HomeScreen extends StatelessWidget {
  final TransactionController controller;

  const HomeScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final analytics = controller.analytics;
        final weeklyData = analytics.weeklyData;
        final maxExpense = weeklyData
            .map((data) => data['expense'] as double)
            .fold(0.0, (current, value) => max(current, value));
        final weeklyHeights = weeklyData
            .map<double>((data) {
              final expense = data['expense'] as double;
              if (maxExpense == 0) return 40.0;
              return 30 + (expense / maxExpense) * 65;
            })
            .toList();
        final recentTransactions = controller.transactions.take(3).toList();

        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () {},
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
                  _HomeHeader(controller: controller),
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
                    barHeights: weeklyHeights,
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

  const _HomeHeader({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.reorder, color: AppColors.onSurface),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppDrawer(
                      controller: controller,
                    ),
                  ),
                );
              },
            ),
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
                style: AppTextStyles.cardBadge.copyWith(color: AppColors.primary),
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
  final List<double> barHeights;

  const _WeeklyRhythm({
    required this.weeklyData,
    required this.dailyAverage,
    required this.barHeights,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final labels = weeklyData
        .map((data) => (data['day'] as DateTime).weekday)
        .map((weekday) {
          switch (weekday) {
            case DateTime.monday:
              return 'M';
            case DateTime.tuesday:
              return 'T';
            case DateTime.wednesday:
              return 'W';
            case DateTime.thursday:
              return 'T';
            case DateTime.friday:
              return 'F';
            case DateTime.saturday:
              return 'S';
            case DateTime.sunday:
              return 'S';
            default:
              return '';
          }
        })
        .toList();

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
        SizedBox(
          height: 90,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(barHeights.length, (index) {
              final bool isActive = index == barHeights.length - 1;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: _WeeklyBar(
                    height: barHeights[index],
                    isActive: isActive,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(labels.length, (index) {
            final isActive = index == labels.length - 1;
            return Text(
              labels[index],
              style: AppTextStyles.body.copyWith(
                color: isActive
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _WeeklyBar extends StatelessWidget {
  final double height;
  final bool isActive;

  const _WeeklyBar({required this.height, required this.isActive, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
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
          Text(
            'No recent activity yet.',
            style: AppTextStyles.bodyMuted,
          )
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
        borderRadius: BorderRadius.circular(AppRadius.md),
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
