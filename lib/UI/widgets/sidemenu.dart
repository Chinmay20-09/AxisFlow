import 'package:flutter/material.dart';
import 'package:transaction/ui/screens/alert.dart';
import 'package:transaction/ui/screens/budgets.dart';
import 'package:transaction/ui/screens/home_screen.dart';
import 'package:transaction/ui/screens/settings.dart';
import '../screens/category_screen.dart';
import '../../controller/transaction_controller.dart';
import '../screens/types.dart';
import '../screens/profile.dart';
import 'package:transaction/ui/screens/dashboard.dart';

class _C {
  static const surface = Color(0xFF181920);
  static const card = Color(0xFF1E2029);
  static const border = Color(0xFF2A2C38);
  static const accent = Color(0xFF3FDC84); // vivid green  (AxisFlow green)
  static const accentRed = Color(0xFFFF6B6B); // salmon-red
  static const muted = Color(0xFF8B8FA8);
  static const label = Color(0xFFE4E6F0);
}

// ─────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  final String? badge;
  final Widget? screen;

  const _NavItem(this.icon, this.label, {this.badge, this.screen});
}

// ─────────────────────────────────────────────
//  THE DRAWER WIDGET
// ─────────────────────────────────────────────
class AppDrawer extends StatefulWidget {
  final TransactionController controller;
  final int selectedIndex;

  const AppDrawer({
    super.key,
    required this.controller,
    this.selectedIndex = 0,
  });
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>
    with SingleTickerProviderStateMixin {
  late int _selected;

  late final AnimationController _ctrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  late final List<_NavItem> _mainItems;
  late final List<_NavItem> _secondaryItems;

  @override
  void initState() {
    _selected = widget.selectedIndex;
    super.initState();
    _mainItems = [
      _NavItem(Icons.home_rounded, 'Home', screen: HomeScreen(controller: widget.controller)),

      _NavItem(
        Icons.bar_chart_rounded,
        'Dashboard',
        screen: AxisFlowInsightsScreen(controller: widget.controller),
      ),

      _NavItem(
        Icons.swap_horiz_rounded,
        'Transactions',
        screen: CategoryScreen(controller: widget.controller),
      ),

      _NavItem(
        Icons.category_rounded,
        'Categories',
        screen: const CategoriesScreen(),
      ),

      _NavItem(
        Icons.account_balance_wallet_rounded,
        'Budgets',
        screen: const BudgetsScreen(),
      ),
    ];
    _secondaryItems = [
      _NavItem(Icons.person_rounded, 'Profile', screen: const ProfileScreen()),

      _NavItem(
        Icons.notifications_rounded,
        'Alerts',
        badge: '3',
        screen: const AlertsScreen(),
      ),

      _NavItem(
        Icons.settings_rounded,
        'Settings',
        screen: const SettingsScreen(),
      ),
    ];
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 540),
    );

    final totalItems = _mainItems.length + _secondaryItems.length;
    _fadeAnims = List.generate(totalItems, (i) {
      final start = (i * 0.07).clamp(0.0, 0.8);
      return CurvedAnimation(
        parent: _ctrl,
        curve: Interval(
          start,
          (start + 0.35).clamp(0.0, 1.0),
          curve: Curves.easeOut,
        ),
      );
    });
    _slideAnims = List.generate(totalItems, (i) {
      final start = (i * 0.07).clamp(0.0, 0.8);
      return Tween<Offset>(
        begin: const Offset(-0.25, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(
            start,
            (start + 0.35).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 272,
      backgroundColor: _C.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── PROFILE HEADER ──────────────────────
            _ProfileHeader(),

            const SizedBox(height: 8),
            _SectionDivider(),

            // ── MAIN NAV ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Text(
                'MENU',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: _C.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            ...List.generate(_mainItems.length, (i) {
              return _AnimatedNavTile(
                item: _mainItems[i],
                index: i,
                selected: _selected == i,
                fade: _fadeAnims[i],
                slide: _slideAnims[i],
                onTap: () {
                  setState(() => _selected = i);

                  Navigator.pop(context);

                  final screen = _mainItems[i].screen;

                  if (screen != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => screen),
                    );
                  }
                },
              );
            }),

            const SizedBox(height: 8),
            _SectionDivider(),

            // ── SECONDARY NAV ───────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Text(
                'ACCOUNT',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: _C.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            ...List.generate(_secondaryItems.length, (i) {
              final globalIdx = _mainItems.length + i;
              return _AnimatedNavTile(
                item: _secondaryItems[i],
                index: globalIdx,
                selected: _selected == globalIdx,
                fade: _fadeAnims[globalIdx],
                slide: _slideAnims[globalIdx],
                onTap: () {
                  setState(() => _selected = globalIdx);

                  Navigator.pop(context);

                  final screen = _secondaryItems[i].screen;

                  if (screen != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => screen),
                    );
                  }
                },
              );
            }),

            const Spacer(),

            // ── LOGOUT ──────────────────────────────
            _LogoutButton(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PROFILE HEADER
// ─────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _C.accent, width: 1.8),
              color: _C.card,
            ),
            child: const Icon(Icons.person_rounded, color: _C.accent, size: 24),
          ),
          const SizedBox(width: 12),
          // Name + role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sophia Rose',
                  style: const TextStyle(
                    color: _C.label,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'UX / UI Designer',
                  style: TextStyle(
                    color: _C.muted,
                    fontSize: 11,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          // Status dot
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _C.accent,
              boxShadow: [
                BoxShadow(color: _C.accent, blurRadius: 6, spreadRadius: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ANIMATED NAV TILE
// ─────────────────────────────────────────────
class _AnimatedNavTile extends StatefulWidget {
  final _NavItem item;
  final int index;
  final bool selected;
  final Animation<double> fade;
  final Animation<Offset> slide;
  final VoidCallback onTap;

  const _AnimatedNavTile({
    required this.item,
    required this.index,
    required this.selected,
    required this.fade,
    required this.slide,
    required this.onTap,
  });

  @override
  State<_AnimatedNavTile> createState() => _AnimatedNavTileState();
}

class _AnimatedNavTileState extends State<_AnimatedNavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool active = widget.selected;

    return FadeTransition(
      opacity: widget.fade,
      child: SlideTransition(
        position: widget.slide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: active
                      ? _C.accent.withValues(alpha: 0.12)
                      : _hovered
                      ? _C.card
                      : Colors.transparent,
                  border: Border.all(
                    color: active
                        ? _C.accent.withValues(alpha: 0.35)
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Icon
                    Icon(
                      widget.item.icon,
                      size: 20,
                      color: active ? _C.accent : _C.muted,
                    ),
                    const SizedBox(width: 14),
                    // Label
                    Expanded(
                      child: Text(
                        widget.item.label,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: active ? _C.label : _C.muted,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    // Badge (optional)
                    if (widget.item.badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _C.accentRed.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _C.accentRed.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.item.badge!,
                          style: const TextStyle(
                            color: _C.accentRed,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    // Active indicator dot
                    if (active) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _C.accent,
                        ),
                      ),
                    ],
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

// ─────────────────────────────────────────────
//  SECTION DIVIDER
// ─────────────────────────────────────────────
class _SectionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(color: _C.border, height: 1, thickness: 1),
    );
  }
}

// ─────────────────────────────────────────────
//  LOGOUT BUTTON
// ─────────────────────────────────────────────
class _LogoutButton extends StatefulWidget {
  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () {},
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _hovered
                  ? _C.accentRed.withValues(alpha: 0.1)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: _C.accentRed.withValues(alpha: 0.75),
                ),
                const SizedBox(width: 14),
                Text(
                  'Log out',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: _C.accentRed.withValues(alpha: 0.75),
                    letterSpacing: 0.2,
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
