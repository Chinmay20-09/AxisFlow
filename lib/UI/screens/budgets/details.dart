import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/controller/transaction_controller.dart';
import 'package:axisflow/ui/widgets/navigation/sidemenu.dart';
import 'package:axisflow/ui/widgets/navigation/menu_button.dart';
import 'package:axisflow/ui/widgets/cards/ai_insight_card.dart';
import 'package:axisflow/ui/widgets/cards/glass_card.dart';
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
      title: 'AxisFlow BudgetsDetail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          primary: Theme.of(context).colorScheme.primary,
          surface: AppColors.surface,
        ),
      ),
      home: BudgetsDetailScreen(controller: controller),
    );
  }
}

// Using shared AppColors from core/app_colors.dart

// ── Data model ─────────────────────────────────────────────────────────────────
enum BudgetsDetailtatus { caution, onTrack, critical, pending }

class BudgetItem {
  final IconData icon;
  final String title;
  final String spent;
  final String total;
  final String remaining;
  final double progress;
  final BudgetsDetailtatus status;
  final Color iconBg;
  final Color iconColor;

  const BudgetItem({
    required this.icon,
    required this.title,
    required this.spent,
    required this.total,
    required this.remaining,
    required this.progress,
    required this.status,
    required this.iconBg,
    required this.iconColor,
  });
}

// BudgetsDetail are computed at runtime from analytics (top expense categories). The previous static demo list was removed.

// ── Screen ─────────────────────────────────────────────────────────────────────
class BudgetsDetailScreen extends StatefulWidget {
  final TransactionController controller;
  const BudgetsDetailScreen({super.key, required this.controller});

  @override
  State<BudgetsDetailScreen> createState() => _BudgetsDetailScreenState();
}

class _BudgetsDetailScreenState extends State<BudgetsDetailScreen> {
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
                  'BudgetsDetail',
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
                const SizedBox(height: 32),

                // ── Category list ──────────────────────────────────────────
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
                  Positioned(top: -32, right: -32, child: _PulsingGlow()),
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
                                color: AppColors.secondary.withValues(
                                  alpha: (0.6),
                                ),
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Adjust Limits not implemented',
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            _PillButton(
                              label: 'Details',
                              filled: false,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Details not implemented'),
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

// ── Pulsing glow blob ──────────────────────────────────────────────────────────
class _PulsingGlow extends StatefulWidget {
  @override
  State<_PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<_PulsingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.5,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 128,
        height: 128,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: (0.05)),
              blurRadius: 60,
              spreadRadius: 30,
            ),
          ],
        ),
      ),
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

// ── Budget card ────────────────────────────────────────────────────────────────
class _BudgetCard extends StatefulWidget {
  final BudgetItem item;

  const _BudgetCard({required this.item});

  @override
  State<_BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends State<_BudgetCard>
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
      case BudgetsDetailtatus.caution:
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
      case BudgetsDetailtatus.onTrack:
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
      case BudgetsDetailtatus.critical:
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
      case BudgetsDetailtatus.pending:
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
      case BudgetsDetailtatus.caution:
        return Theme.of(context).colorScheme.primaryContainer;
      case BudgetsDetailtatus.onTrack:
        return Theme.of(context).colorScheme.primary.withValues(alpha: (0.4));
      case BudgetsDetailtatus.critical:
        return AppColors.error;
      case BudgetsDetailtatus.pending:
        return AppColors.onSurfaceVariant.withValues(alpha: (0.3));
    }
  }

  Color get _amountColor => widget.item.status == BudgetsDetailtatus.critical
      ? AppColors.error
      : AppColors.onSurface;

  Color get _remainingColor => widget.item.status == BudgetsDetailtatus.critical
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
