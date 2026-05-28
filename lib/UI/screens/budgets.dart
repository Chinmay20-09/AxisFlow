import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:axisflow/controller/transaction_controller.dart';
import 'package:axisflow/ui/widgets/navigation/sidemenu.dart';
import 'package:axisflow/ui/widgets/navigation/menu_button.dart';

void main() {
  runApp(AxisFlowApp());
}

class AxisFlowApp extends StatelessWidget {
  final TransactionController controller = TransactionController()..load();

  AxisFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AxisFlow Budgets',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
      ),
      home: BudgetsScreen(controller: controller),
    );
  }
}

// ── Colour tokens ──────────────────────────────────────────────────────────────
class AppColors {
  static const background = Color(0xFF05070A);
  static const surface = Color(0xFF111417);
  static const surfaceContainer = Color(0xFF1D2023);
  static const surfaceContainerHigh = Color(0xFF282A2E);
  static const surfaceContainerHighest = Color(0xFF323539);
  static const secondaryContainer = Color(0xFF464950);
  static const errorContainer = Color(0xFF93000A);
  static const onSurface = Color(0xFFE1E2E7);
  static const onSurfaceVariant = Color(0xFFBCCABB);
  static const primary = Color(0xFF4ADE80);
  static const primaryContainer = Color(0xFF4ADE80);
  static const onPrimary = Color(0xFF003919);
  static const secondary = Color(0xFFC4C6CE);
  static const error = Color(0xFFFFB4AB);
  static const outline = Color(0xFF869486);
}

// ── Data model ─────────────────────────────────────────────────────────────────
enum BudgetStatus { caution, onTrack, critical, pending }

class BudgetItem {
  final IconData icon;
  final String title;
  final String spent;
  final String total;
  final String remaining;
  final double progress;
  final BudgetStatus status;
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

final _budgets = <BudgetItem>[
  BudgetItem(
    iconColor: AppColors.primary,
    icon: Icons.restaurant,
    title: 'Food Budget',
    spent: '₹4,000',
    total: '₹6,000',
    remaining: '₹2,000 remaining',
    progress: 0.66,
    status: BudgetStatus.caution,
    iconBg: AppColors.primary.withValues(alpha: (0.1)),
  ),
  BudgetItem(
    iconColor: AppColors.secondary,
    icon: Icons.commute,
    title: 'Travel Budget',
    spent: '₹1,200',
    total: '₹3,000',
    remaining: '₹1,800 remaining',
    progress: 0.40,
    status: BudgetStatus.onTrack,
    iconBg: AppColors.secondaryContainer.withValues(alpha: (0.1)),
  ),
  BudgetItem(
    icon: Icons.movie,
    title: 'Entertainment',
    spent: '₹4,800',
    total: '₹5,000',
    remaining: '₹200 remaining',
    progress: 0.96,
    status: BudgetStatus.critical,
    iconBg: AppColors.errorContainer.withValues(alpha: (0.2)),
    iconColor: AppColors.error,
  ),
  BudgetItem(
    icon: Icons.lightbulb,
    title: 'Utilities',
    spent: '₹2,000',
    total: '₹2,500',
    remaining: '₹500 remaining',
    progress: 0.80,
    status: BudgetStatus.pending,
    iconBg: AppColors.surfaceContainerHighest,
    iconColor: AppColors.onSurfaceVariant,
  ),
];

// ── Screen ─────────────────────────────────────────────────────────────────────
class BudgetsScreen extends StatefulWidget {
  final TransactionController controller;
  const BudgetsScreen({super.key, required this.controller});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedNavIndex = 2;

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
            title: Row(
              children: [
                MenuButton(scaffoldKey: _scaffoldKey),
                const SizedBox(width: 8),
                const Text(
                  'AxisFlow',
                  style: TextStyle(
                    color: AppColors.primary,
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
                    child: const Icon(
                      Icons.person,
                      size: 18,
                      color: AppColors.onSurface,
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
                _BentoRow(),
                const SizedBox(height: 32),

                // ── Category list ──────────────────────────────────────────
                const Text(
                  'Categories',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                ..._budgets.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _BudgetCard(item: b),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedNavIndex,
        onTap: (i) => setState(() => _selectedNavIndex = i),
      ),
    );
  }
}

// ── Bento row ──────────────────────────────────────────────────────────────────
class _BentoRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Remaining balance card
        _GlassCard(
          child: Stack(
            children: [
              // Ambient glow blob
              Positioned(top: -32, right: -32, child: _PulsingGlow()),
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'REMAINING BALANCE',
                      style: TextStyle(
                        color: AppColors.primary,
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
                        const Text(
                          '₹12,400',
                          style: TextStyle(
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
                            color: AppColors.secondary.withValues(alpha: (0.6)),
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
                          onTap: () {},
                        ),
                        const SizedBox(width: 12),
                        _PillButton(
                          label: 'Details',
                          filled: false,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // AI Insight card
        _AiInsightCard(),
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
              color: AppColors.primary.withValues(alpha: (0.05)),
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
          color: filled ? AppColors.primary : Colors.transparent,
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

// ── AI Insight card ────────────────────────────────────────────────────────────
class _AiInsightCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.2,
              colors: [
                AppColors.primary.withValues(alpha: (0.03)),
                Colors.white.withValues(alpha: (0.02)),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: (0.1)),
            ),
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'AI INSIGHT',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.08 * 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text:
                          'Based on your current "Food" spending velocity, you might exceed your limit by ',
                    ),
                    TextSpan(
                      text: '₹800',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: '. Consider reducing dining out next week.'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.verified,
                    size: 16,
                    color: AppColors.onSurfaceVariant.withValues(alpha: (0.6)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Calculated 2 minutes ago',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant.withValues(
                        alpha: (0.6),
                      ),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
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
      case BudgetStatus.caution:
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
      case BudgetStatus.onTrack:
        return Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.primary, size: 14),
            const SizedBox(width: 6),
            const Text(
              'On track',
              style: TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ],
        );
      case BudgetStatus.critical:
        return Row(
          children: [
            const Icon(Icons.error, color: AppColors.error, size: 14),
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
      case BudgetStatus.pending:
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
      case BudgetStatus.caution:
        return AppColors.primaryContainer;
      case BudgetStatus.onTrack:
        return AppColors.primary.withValues(alpha: (0.4));
      case BudgetStatus.critical:
        return AppColors.error;
      case BudgetStatus.pending:
        return AppColors.onSurfaceVariant.withValues(alpha: (0.3));
    }
  }

  Color get _amountColor => widget.item.status == BudgetStatus.critical
      ? AppColors.error
      : AppColors.onSurface;

  Color get _remainingColor => widget.item.status == BudgetStatus.critical
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

// ── Reusable glass card ────────────────────────────────────────────────────────
class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: (0.04)),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: (0.08))),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Bottom Navigation Bar ──────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.selectedIndex, required this.onTap});

  static const _items = [
    _NavItem(icon: Icons.account_balance_wallet, label: 'Wealth'),
    _NavItem(icon: Icons.swap_calls, label: 'Flow'),
    _NavItem(icon: Icons.query_stats, label: 'Insights'),
    _NavItem(icon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: (0.9)),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: (0.05))),
            ),
          ),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final active = i == selectedIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      color: active
                          ? AppColors.primary
                          : AppColors.secondary.withValues(alpha: (0.6)),
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: active
                            ? AppColors.primary
                            : AppColors.secondary.withValues(alpha: (0.6)),
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        letterSpacing: 0.05 * 11,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
