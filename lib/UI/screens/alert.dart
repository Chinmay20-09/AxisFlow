import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:transaction/app_strings.dart';

void main() {
  runApp(const AxisFlowApp());
}

class AxisFlowApp extends StatelessWidget {
  const AxisFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
      ),
      home: const AlertsScreen(),
    );
  }
}

// ── Colour tokens ──────────────────────────────────────────────────────────────
class AppColors {
  static const background = Color(0xFF05070A);
  static const surface = Color(0xFF111417);
  static const surfaceContainer = Color(0xFF1D2023);
  static const surfaceContainerHigh = Color(0xFF282A2E);
  static const secondaryContainer = Color(0xFF464950);
  static const onSurface = Color(0xFFE1E2E7);
  static const onSurfaceVariant = Color(0xFFBCCABB);
  static const primary = Color(0xFF4ADE80);
  static const primaryContainer = Color(0xFF4ADE80);
  static const onPrimary = Color(0xFF003919);
  static const secondary = Color(0xFFC4C6CE);
  static const amber = Color(0xFFFBBF24);
}

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

const _priorityAlerts = <AlertItem>[
  AlertItem(
    type: AlertType.priority,
    icon: Icons.query_stats,
    title: 'Spending Insight',
    body: 'Food spending increased 30% compared to last week.',
  ),
  AlertItem(
    type: AlertType.priority,
    icon: Icons.account_balance,
    title: 'Budget Alert',
    body: 'Budget for Entertainment almost exceeded (92%).',
    progressValue: 0.92,
  ),
];

const _historyAlerts = <AlertItem>[
  AlertItem(
    type: AlertType.achievement,
    icon: Icons.stars,
    title: 'Achievement',
    body: "Savings improved this month. You're \$450 ahead of your goal.",
    isAiInsight: true,
  ),
  AlertItem(
    type: AlertType.neutral,
    icon: Icons.edit_calendar,
    title: 'Action Needed',
    body: 'No transactions added today. Stay on track.',
  ),
];

// ── Screen ─────────────────────────────────────────────────────────────────────
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int _selectedNavIndex = 2; // Insights is active

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: Stack(
        children: [
          CustomScrollView(
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
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.onSurface,
                      size: 20,
                    ),
                    onPressed: () => Navigator.maybePop(context),
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
                      icon: const Icon(
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
                    // Priority section
                    _SectionHeader(label: AppStrings.prioritySectionLabel),
                    const SizedBox(height: 24),
                    ..._priorityAlerts.asMap().entries.map(
                      (e) => _AnimatedCard(
                        delay: Duration(milliseconds: 100 * e.key),
                        child: _AlertCard(item: e.value),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // History section
                    _SectionHeader(label: AppStrings.historySectionLabel),
                    const SizedBox(height: 24),
                    ..._historyAlerts.asMap().entries.map(
                      (e) => _AnimatedCard(
                        delay: Duration(
                          milliseconds: 100 * (_priorityAlerts.length + e.key),
                        ),
                        child: _AlertCard(item: e.value),
                      ),
                    ),

                    // Empty placeholder
                    _AnimatedCard(
                      delay: Duration(
                        milliseconds:
                            100 *
                            (_priorityAlerts.length + _historyAlerts.length),
                      ),
                      child: _EmptyPlaceholder(),
                    ),
                  ]),
                ),
              ),
            ],
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

// ── Section header with divider line ──────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1 * 11,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }
}

// ── Animated entrance wrapper ──────────────────────────────────────────────────
class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _AnimatedCard({required this.child, required this.delay});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(position: _slide, child: widget.child),
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
                                    child: const Text(
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

// ── Empty placeholder ──────────────────────────────────────────────────────────
class _EmptyPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.4,
          child: Text(
            'Older notifications cleared',
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.05 * 11,
            ),
          ),
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
    _NavItem(icon: Icons.insights, label: 'Insights'),
    _NavItem(icon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.9),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final active = i == selectedIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: active
                      ? const EdgeInsets.symmetric(horizontal: 20, vertical: 8)
                      : const EdgeInsets.symmetric(vertical: 8),
                  decoration: active
                      ? BoxDecoration(
                          color: AppColors.primaryContainer.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        )
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: active
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: active
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.05 * 11,
                        ),
                      ),
                    ],
                  ),
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
