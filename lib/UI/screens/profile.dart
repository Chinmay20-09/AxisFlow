import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const AxisFlowApp());
}

class AxisFlowApp extends StatelessWidget {
  const AxisFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AxisFlow | Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
      ),
      home: const ProfileScreen(),
    );
  }
}

// ── Colour tokens ──────────────────────────────────────────────────────────────
class AppColors {
  static const background = Color(0xFF111417);
  static const surface = Color(0xFF111417);
  static const surfaceContainer = Color(0xFF1D2023);
  static const surfaceContainerHigh = Color(0xFF282A2E);
  static const onSurface = Color(0xFFE1E2E7);
  static const onSurfaceVariant = Color(0xFFBCCABB);
  static const primary = Color(0xFF4ADE80);
  static const primaryContainer = Color(0xFF4ADE80);
  static const onPrimary = Color(0xFF003919);
  static const secondary = Color(0xFFC4C6CE);
  static const outlineVariant = Color(0xFF3D4A3E);
  static const error = Color(0xFFFFB4AB);
}

// ── Screen ─────────────────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _darkMode = true;
  int _selectedNavIndex = 3; // Profile is active

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: Stack(
        children: [
          // ── Scrollable content ───────────────────────────────────────────────
          CustomScrollView(
            slivers: [
              // Header app bar
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
                title: Row(
                  children: [
                    const Icon(
                      Icons.bubble_chart,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.settings,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Profile header ─────────────────────────────────────────
                    _ProfileHeader(),
                    const SizedBox(height: 32),

                    // ── AI Insight card ────────────────────────────────────────
                    _AiInsightCard(),
                    const SizedBox(height: 32),

                    // ── Settings grid ──────────────────────────────────────────
                    _SettingsGrid(
                      darkMode: _darkMode,
                      onDarkModeToggle: () =>
                          setState(() => _darkMode = !_darkMode),
                    ),
                    const SizedBox(height: 32),

                    // ── Logout ─────────────────────────────────────────────────
                    _LogoutButton(),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),

      // ── Bottom nav ────────────────────────────────────────────────────────────
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedNavIndex,
        onTap: (i) => setState(() => _selectedNavIndex = i),
      ),
    );
  }
}

// ── Profile Header ─────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: ClipOval(
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCHQ3Md9bwL4z5Q8JZ5QBRaX_rvSZo2rKWKnTaxzMhxX-rNvLG6kKwSNxfXXTbsqvwPR5mJDvzBpRr4B8EwjXtieAGUns4Q_om_ETxPJa1Kn7sC1bYbD9Nsz5qVWSnStav5EPTpDSHqx0Fu8gbKyr1n7aV3Tyo_bqE5PvdZSYdqbSFL348OZOm9dQ9v7hajHZ0ohwG_xBWe-7jbBV59ALKP-bcnq_C1qiFEuyY8QnS5Bs0j9tv1xmHJbrpqnt8X5aKEjXLr-rU6ruiS',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.surfaceContainer,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.onSurfaceVariant,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 3),
                ),
                child: const Icon(
                  Icons.edit,
                  color: AppColors.onPrimary,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Alex Rivers',
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.02 * 32,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: const Text(
            'AXIS PREMIUM',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1 * 11,
            ),
          ),
        ),
      ],
    );
  }
}

// ── AI Insight Card ────────────────────────────────────────────────────────────
class _AiInsightCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 60,
            spreadRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Stack(
              children: [
                // Background decorative icon
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 40,
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI GENERATED',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1 * 11,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your Financial Flow',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 16,
                          height: 1.6,
                        ),
                        children: [
                          const TextSpan(text: 'Your spending has been '),
                          TextSpan(
                            text: '12% more mindful',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(
                            text: ' this month. Great work, Alex.',
                          ),
                        ],
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

// ── Settings Grid ──────────────────────────────────────────────────────────────
class _SettingsGrid extends StatelessWidget {
  final bool darkMode;
  final VoidCallback onDarkModeToggle;

  const _SettingsGrid({required this.darkMode, required this.onDarkModeToggle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _SettingsSection(
                label: 'Account',
                items: [
                  _SettingsTile(
                    icon: Icons.account_balance,
                    label: 'Manage linked banks',
                  ),
                  _SettingsTile(icon: Icons.shield, label: 'Security'),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SettingsSection(
                label: 'Preferences',
                items: [
                  _DarkModeTile(value: darkMode, onToggle: onDarkModeToggle),
                  _SettingsTile(
                    icon: Icons.notifications,
                    label: 'Notifications',
                  ),
                  _SettingsTile(
                    icon: Icons.payments,
                    label: 'Currency',
                    trailing: const Text(
                      'USD',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.05 * 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Row 2
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _SettingsSection(
                label: 'Intelligence',
                items: [
                  _SettingsTile(
                    icon: Icons.monitor_heart,
                    label: 'AI Insight Frequency',
                  ),
                  _SettingsTile(
                    icon: Icons.category,
                    label: 'Auto-categorization',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SettingsSection(
                label: 'Support',
                items: [
                  _SettingsTile(icon: Icons.help, label: 'Help Center'),
                  _SettingsTile(icon: Icons.info, label: 'About AxisFlow'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Settings Section wrapper ───────────────────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  final String label;
  final List<Widget> items;

  const _SettingsSection({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1 * 11,
            ),
          ),
        ),
        _GlassCard(
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Glass card container ───────────────────────────────────────────────────────
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
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Settings Tile ──────────────────────────────────────────────────────────────
class _SettingsTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;

  const _SettingsTile({required this.icon, required this.label, this.trailing});

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: _hovered
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 22,
                color: _hovered
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 16,
                  ),
                ),
              ),
              if (widget.trailing != null) ...[
                widget.trailing!,
                const SizedBox(width: 4),
              ],
              const Icon(
                Icons.chevron_right,
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dark Mode Toggle Tile ──────────────────────────────────────────────────────
class _DarkModeTile extends StatelessWidget {
  final bool value;
  final VoidCallback onToggle;

  const _DarkModeTile({required this.value, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Icon(
            Icons.dark_mode,
            size: 22,
            color: value ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Dark Mode',
              style: TextStyle(color: AppColors.onSurface, fontSize: 16),
            ),
          ),
          // Toggle switch
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: 48,
              height: 24,
              decoration: BoxDecoration(
                color: value
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: value
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    left: value ? 28 : 4,
                    top: 4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: value
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logout Button ──────────────────────────────────────────────────────────────
class _LogoutButton extends StatefulWidget {
  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.logout,
                  color: _hovered
                      ? AppColors.error
                      : AppColors.onSurfaceVariant,
                  size: 22,
                ),
                const SizedBox(width: 12),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: _hovered
                        ? AppColors.error
                        : AppColors.onSurfaceVariant,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  child: const Text('Log Out'),
                ),
              ],
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: active
                      ? const EdgeInsets.symmetric(horizontal: 12, vertical: 4)
                      : EdgeInsets.zero,
                  decoration: active
                      ? BoxDecoration(
                          color: AppColors.primaryContainer.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
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
                        size: 24,
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
