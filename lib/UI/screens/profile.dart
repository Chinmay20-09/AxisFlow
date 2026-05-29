import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:axisflow/core/config/app_config.dart';
import 'package:axisflow/controller/transaction_controller.dart';
import 'package:axisflow/ui/widgets/tiles/transaction_tile.dart';
import 'package:axisflow/ui/screens/add_transaction_sheet.dart';
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
      title: 'AxisFlow | Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
      ),
      home: ProfileScreen(controller: controller),
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
  final TransactionController controller;
  const ProfileScreen({super.key, required this.controller});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _darkMode = true; // Profile is active

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(controller: widget.controller, selectedIndex: 5),
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
                    MenuButton(scaffoldKey: _scaffoldKey),
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

              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                  child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ── Profile header ─────────────────────────────────────────
                                    _ProfileHeader(),
                                    const SizedBox(height: 24),

                                    // ── AI Insight (driven by analytics) ───────────────────────
                                    AnimatedBuilder(
                                      animation: widget.controller,
                                      builder: (context, _) {
                                        final analytics = widget.controller.analytics;
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(24),
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withValues(alpha: 0.04),
                                                    borderRadius: BorderRadius.circular(24),
                                                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                                  ),
                                                  padding: const EdgeInsets.all(24),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: const [
                                                          Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                                                          SizedBox(width: 8),
                                                          Text('AI GENERATED', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 12),
                                                      Text(analytics.summaryInsight, style: TextStyle(color: AppColors.onSurface, fontSize: 16, height: 1.5)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 24),

                                            // ── Recent transactions
                                            Text('Recent activity', style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.w600)),
                                            const SizedBox(height: 12),
                                            Column(
                                              children: widget.controller.transactions.take(5).map((tx) => TransactionTile(
                                                    transaction: tx,
                                                    onEdit: () {
                                                      showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled: true,
                                                        backgroundColor: Colors.transparent,
                                                        builder: (_) => AddTransactionSheet(controller: widget.controller, existing: tx),
                                                      );
                                                    },
                                                    onDelete: () async {
                                                      final confirm = await showDialog<bool>(
                                                        context: context,
                                                        builder: (ctx) => AlertDialog(
                                                          title: const Text('Delete transaction'),
                                                          content: const Text('Are you sure you want to delete this transaction?'),
                                                          actions: [
                                                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                                            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                                                          ],
                                                        ),
                                                      );
                                                      if (confirm == true) {
                                                        await widget.controller.delete(tx.id);
                                                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction deleted')));
                                                      }
                                                    },
                                                  )).toList(),
                                            ),
                                          ],
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 24),

                                    // ── Settings grid ──────────────────────────────────────────
                                    _SettingsGrid(
                                      darkMode: _darkMode,
                                      onDarkModeToggle: () =>
                                          setState(() => _darkMode = !_darkMode),
                                    ),
                                    const SizedBox(height: 32),

                                    // ── Logout ─────────────────────────────────────────────────
                                    _LogoutButton(),
                                  ],
                                ),
                              ),
                            ),
            ],
          ),
        ],
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
                  AppCredentials.avatarUrl,
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
        Text(
          AppCredentials.userName,
          style: const TextStyle(
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
          child: Text(
            AppCredentials.userPlan,
            style: const TextStyle(
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
