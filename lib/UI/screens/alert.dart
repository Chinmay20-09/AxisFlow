import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/core/constants/app_strings.dart';
import 'package:axisflow/controller/transaction_controller.dart';
import 'package:axisflow/ui/widgets/navigation/sidemenu.dart';
import 'package:axisflow/ui/widgets/navigation/menu_button.dart';
import 'package:axisflow/ui/widgets/common/animated_card.dart';
import 'package:axisflow/ui/widgets/common/empty_placeholder.dart';
import 'package:axisflow/ui/widgets/common/section_header.dart';
import 'package:axisflow/core/formatters.dart';

void main() {
  runApp(AxisFlowApp());
}

class AxisFlowApp extends StatelessWidget {
  final TransactionController controller = TransactionController()..load();

  AxisFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
      ),
      home: AlertsScreen(controller: controller),
    );
  }
}

// Using shared AppColors from core/app_colors.dart

// ── Data models ────────────────────────────────────────────────────────────────
enum AlertType { priority, achievement, neutral, empty }

class AlertItem {
  final AlertType type;
  final IconData icon;
  final String title;
  final String body;
  final bool isAiInsight;
  final double? progressValue; // null = no progress bar

  const AlertItem({
    required this.type,
    required this.icon,
    required this.title,
    required this.body,
    this.isAiInsight = false,
    this.progressValue,
  });
}

/* Alerts are generated from analytics at runtime — static demo alerts removed */

// ── Screen ─────────────────────────────────────────────────────────────────────
class AlertsScreen extends StatefulWidget {
  final TransactionController controller;
  const AlertsScreen({super.key, required this.controller});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  // Insights is active
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(controller: widget.controller, selectedIndex: 6),

      backgroundColor: AppColors.background,
      extendBody: true,
      body: CustomScrollView(
        slivers: [
          // ── Top App Bar ──────────────────────────────────────────────────
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

          // ── Body ────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Dynamic alerts generated from analytics
                AnimatedBuilder(
                  animation: widget.controller,
                  builder: (context, _) {
                    final analytics = widget.controller.analytics;

                    final priorityItems = <AlertItem>[
                      AlertItem(
                        type: AlertType.priority,
                        icon: Icons.query_stats,
                        title: 'Spending Insight',
                        body: analytics.summaryInsight,
                      ),
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
                    ];

                    final historyItems = <AlertItem>[
                      AlertItem(
                        type: AlertType.achievement,
                        icon: Icons.stars,
                        title: 'Behaviour Insight',
                        body: analytics.behaviorInsight,
                        isAiInsight: true,
                      ),
                    ];

                    final widgets = <Widget>[];
                    widgets.add(
                      SectionHeader(title: AppStrings.prioritySectionLabel),
                    );
                    widgets.add(const SizedBox(height: 24));
                    for (var i = 0; i < priorityItems.length; i++) {
                      widgets.add(
                        AnimatedCard(
                          delay: Duration(milliseconds: 100 * i),
                          child: _AlertCard(item: priorityItems[i]),
                        ),
                      );
                    }

                    widgets.add(const SizedBox(height: 40));
                    widgets.add(
                      SectionHeader(title: AppStrings.historySectionLabel),
                    );
                    widgets.add(const SizedBox(height: 24));

                    for (var i = 0; i < historyItems.length; i++) {
                      widgets.add(
                        AnimatedCard(
                          delay: Duration(
                            milliseconds: 100 * (priorityItems.length + i),
                          ),
                          child: _AlertCard(item: historyItems[i]),
                        ),
                      );
                    }

                    widgets.add(
                      AnimatedCard(
                        delay: Duration(
                          milliseconds:
                              100 *
                              (priorityItems.length + historyItems.length),
                        ),
                        child: EmptyPlaceholder(
                          message: 'Older notifications cleared',
                        ),
                      ),
                    );

                    return Column(children: widgets);
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Alert Card ─────────────────────────────────────────────────────────────────
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
