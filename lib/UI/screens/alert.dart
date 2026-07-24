// ignore_for_file: avoid_print

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/core/constants/app_strings.dart';
import 'package:axisflow/controller/transaction_controller.dart';
import 'package:axisflow/data/models/transaction_model.dart';
import 'package:axisflow/data/local/transaction_db.dart';
import 'package:axisflow/ui/screens/popup_add_transaction.dart';
import 'package:axisflow/ui/widgets/navigation/sidemenu.dart';
import 'package:axisflow/ui/widgets/navigation/menu_button.dart';
import 'package:axisflow/ui/widgets/common/animated_card.dart';
import 'package:axisflow/ui/widgets/common/empty_placeholder.dart';
import 'package:axisflow/ui/widgets/common/section_header.dart';
import 'package:axisflow/core/formatters.dart';
import 'package:axisflow/ui/screens/budgets/budget_models.dart';

// ── Data model for alert cards ─────────────────────────────────────────────
enum AlertType { priority, achievement, neutral, empty }

class AlertItem {
  final AlertType type;
  final IconData icon;
  final String title;
  final String body;
  final bool isAiInsight;
  final double? progressValue;

  const AlertItem({
    required this.type,
    required this.icon,
    required this.title,
    required this.body,
    this.isAiInsight = false,
    this.progressValue,
  });
}

// ── Screen ─────────────────────────────────────────────────────────────────
class AlertsScreen extends StatefulWidget {
  final TransactionController controller;
  const AlertsScreen({super.key, required this.controller});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  /// Pull-to-refresh: sync SMS then reload.
  Future<void> _onRefresh() async {
    final result = await widget.controller.smsSyncService.sync();
    widget.controller.load();

    // Review workflow: if exactly one new transaction needs review,
    // show the review popup automatically.
    if (result.needsReview == 1 && mounted) {
      final pending = widget.controller.pendingTransactions;
      if (pending.isNotEmpty) {
        await _reviewTransaction(pending.first);
      }
    }
  }

  /// Open the review popup for a pending transaction.
  Future<void> _reviewTransaction(Transaction tx) async {
    final result = await PopupAddTransaction.show(
      context,
      sheet: PopupAddTransaction.fromTransaction(
        tx,
        onDone: (result) async {
          try {
            final savedTx = TransactionDB.get(result.transactionId);
            if (savedTx == null) {
              print('[ALERT] Cannot update ${result.transactionId} — not found');
              return;
            }
            savedTx.category = result.selectedCategory;
            savedTx.note = result.note;
            savedTx.state = TransactionState.completed;
            await TransactionDB.update(savedTx);
            widget.controller.load();
            print('[ALERT] Transaction ${result.transactionId} reviewed: category=${result.selectedCategory}');
          } catch (e) {
            print('[ALERT] Failed to update transaction: $e');
          }
        },
      ),
    );

    if (result != null && mounted) {
      // Transaction was reviewed — controller already reloaded in onDone
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction updated'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(controller: widget.controller, selectedIndex: 6),

      backgroundColor: AppColors.background,
      extendBody: true,
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          // ── Top App Bar ──────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background.withValues(alpha: 0.85),
            elevation: 0,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: MenuButton(
                scaffoldKey: _scaffoldKey,
                controller: widget.controller,
              ),
            ),
            title: Text(
              AppStrings.alertsScreenTitle,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: Icon(
                    Icons.notifications_active,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),

          // ── Body ────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                AnimatedBuilder(
                  animation: widget.controller,
                  builder: (context, _) {
                    final analytics = widget.controller.analytics;

                    // ── Pending transactions (need review) ──────────────
                    final pending = widget.controller.pendingTransactions;

                    // ── Analytics insight items ─────────────────────────
                    final insightItems = <AlertItem>[
                      if (analytics.currentMonthExpense > 0 ||
                          analytics.totalIncome > 0)
                        AlertItem(
                          type: AlertType.priority,
                          icon: Icons.account_balance,
                          title: 'Month Spending',
                          body:
                              'This month: ${formatCompactCurrency(analytics.currentMonthExpense)}',
                          progressValue: analytics.totalIncome > 0
                              ? (analytics.currentMonthExpense /
                                    analytics.totalIncome)
                              : null,
                        ),
                      AlertItem(
                        type: AlertType.neutral,
                        icon: Icons.query_stats,
                        title: 'Spending Insight',
                        body: analytics.summaryInsight,
                      ),
                      AlertItem(
                        type: AlertType.achievement,
                        icon: Icons.stars,
                        title: 'Behaviour Insight',
                        body: analytics.behaviorInsight,
                        isAiInsight: true,
                      ),
                    ];

                    final widgets = <Widget>[];

                    // ── Pending reviews section ─────────────────────────
                    if (pending.isNotEmpty) {
                      widgets.add(
                        SectionHeader(title: 'NEEDS REVIEW'),
                      );
                      widgets.add(const SizedBox(height: 24));

                      for (var i = 0; i < pending.length; i++) {
                        final tx = pending[i];
                        widgets.add(
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AnimatedCard(
                              delay: Duration(milliseconds: 100 * i),
                              child: _PendingTransactionCard(
                                transaction: tx,
                                onReview: () => _reviewTransaction(tx),
                              ),
                            ),
                          ),
                        );
                      }

                      widgets.add(const SizedBox(height: 40));
                    }

                    // ── Insights section ────────────────────────────────
                    widgets.add(
                      SectionHeader(title: AppStrings.prioritySectionLabel),
                    );
                    widgets.add(const SizedBox(height: 24));

                    for (var i = 0; i < insightItems.length; i++) {
                      widgets.add(
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: AnimatedCard(
                            delay: Duration(milliseconds: 100 * i),
                            child: _AlertCard(item: insightItems[i]),
                          ),
                        ),
                      );
                    }

                    // Empty state when nothing to show
                    if (pending.isEmpty && insightItems.isEmpty) {
                      widgets.add(
                        EmptyPlaceholder(
                          message: 'No alerts yet.',
                        ),
                      );
                    }

                    return Column(children: widgets);
                  },
                ),
              ]),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

// ── Pending Transaction Card ───────────────────────────────────────────────
class _PendingTransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onReview;

  const _PendingTransactionCard({
    required this.transaction,
    required this.onReview,
  });

  String get _merchant {
    for (final line in transaction.note.split('\n')) {
      if (line.startsWith('Merchant: ')) {
        return line.substring('Merchant: '.length).trim();
      }
    }
    return transaction.note.split('\n').first;
  }

  String get _dateLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDay = DateTime(
      transaction.createdAt.year,
      transaction.createdAt.month,
      transaction.createdAt.day,
    );
    if (txDay == today) return 'Today';
    final yesterday = today.subtract(const Duration(days: 1));
    if (txDay == yesterday) return 'Yesterday';
    return '${transaction.createdAt.day}/${transaction.createdAt.month}';
  }

  Color get _typeColor => transaction.isIncome
      ? AppColors.tertiary
      : AppColors.accentRed;

  String get _typeLabel => transaction.isIncome ? 'Income' : 'Expense';

  @override
  Widget build(BuildContext context) {
    final catInfo = categoryIconInfo(transaction.category);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: icon + amount + badge
                Row(
                  children: [
                    // Category icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: catInfo.fgColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(catInfo.icon, color: catInfo.fgColor, size: 20),
                    ),
                    const SizedBox(width: 14),
                    // Merchant + date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _merchant,
                            style: const TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$_dateLabel • $_typeLabel',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Amount
                    Text(
                      '₹${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: _typeColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Category chip + Pending badge + Review button
                Row(
                  children: [
                    // Category chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: catInfo.fgColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction.category,
                        style: TextStyle(
                          color: catInfo.fgColor.withValues(alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Pending badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.accentRed.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Text(
                        'Pending',
                        style: TextStyle(
                          color: AppColors.accentRed,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Review button
                    SizedBox(
                      height: 34,
                      child: ElevatedButton(
                        onPressed: onReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Review',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Analytics Alert Card ───────────────────────────────────────────────────
class _AlertCard extends StatelessWidget {
  final AlertItem item;

  const _AlertCard({required this.item});

  Color get _iconBg {
    switch (item.type) {
      case AlertType.priority:
        return AppColors.amber.withValues(alpha: 0.1);
      case AlertType.achievement:
        return AppColors.primary.withValues(alpha: 0.1);
      case AlertType.neutral:
        return AppColors.secondaryContainer.withValues(alpha: 0.2);
      default:
        return Colors.transparent;
    }
  }

  Color get _iconColor {
    switch (item.type) {
      case AlertType.priority:
        return AppColors.amber;
      case AlertType.achievement:
        return AppColors.primary;
      case AlertType.neutral:
        return AppColors.secondary;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Stack(
              children: [
                // Mesh glow for achievement cards
                if (item.type == AlertType.achievement)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                          radius: 1.0,
                        ),
                      ),
                    ),
                  ),

                // Dot indicator for priority alerts
                if (item.type == AlertType.priority)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.amber.withValues(alpha: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.amber.withValues(alpha: 0.5),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _iconBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon, color: _iconColor, size: 20),
                      ),
                      const SizedBox(width: 16),

                      // Text + optional progress
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title row
                            Row(
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    color: AppColors.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (item.isAiInsight) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      AppStrings.aiInsightBadge,
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.05 * 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Body text
                            Text(
                              item.body,
                              style: const TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),

                            // Progress bar
                            if (item.progressValue != null) ...[
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: item.progressValue,
                                  minHeight: 4,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.05,
                                  ),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0x99FBB024), // amber/60
                                      ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
