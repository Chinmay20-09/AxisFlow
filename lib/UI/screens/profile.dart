import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/core/config/app_config.dart';
import 'package:axisflow/controller/transaction_controller.dart';
import 'package:axisflow/ui/widgets/navigation/sidemenu.dart';
import 'package:axisflow/ui/widgets/navigation/menu_button.dart';
import 'package:axisflow/ui/widgets/tiles/settings_tile.dart';
import 'package:axisflow/ui/widgets/cards/glass_card.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:axisflow/data/local/settings_db.dart';

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

// Using shared AppColors from core/app_colors.dart

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
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: MenuButton(
                    scaffoldKey: _scaffoldKey,
                    controller: widget.controller,
                  ),
                ),
                title: Row(
                  children: [
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
                actions: [Padding(padding: const EdgeInsets.only(right: 12))],
              ),

              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                  filter: ImageFilter.blur(
                                    sigmaX: 20,
                                    sigmaY: 20,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.04,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.08,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: const [
                                            Icon(
                                              Icons.auto_awesome,
                                              color: AppColors.primary,
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'AI GENERATED',
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          analytics.summaryInsight,
                                          style: TextStyle(
                                            color: AppColors.onSurface,
                                            fontSize: 16,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
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
class _ProfileHeader extends StatefulWidget {

  @override
  State<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<_ProfileHeader> {
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    // Read stored avatar (if any)
    _avatarPath = SettingsDB.get<String>('avatar');
  }

  Future<void> _pickAndSaveAvatar() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
      );
      if (result == null || result.files.isEmpty) return;
      final path = result.files.first.path;
      if (path == null) return;

      await SettingsDB.set<String>('avatar', path);
      debugPrint('Avatar path: $path');
debugPrint('Exists: ${File(path).existsSync()}');

      setState(() {
        _avatarPath = path;
      });

    } catch (e) {
      // Handle errors (e.g. permission denied, unsupported format) gracefully
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update avatar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider avatarImage;
    if (_avatarPath != null && _avatarPath!.isNotEmpty) {
      if (_avatarPath!.startsWith('http')) {
        avatarImage = NetworkImage(_avatarPath!);
      } else {
        avatarImage = FileImage(File(_avatarPath!));
      }
    } else {
      avatarImage = NetworkImage(AppCredentials.avatarUrl);
    }

    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: _pickAndSaveAvatar,
              child: Container(
                height: 96,
                width: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: ClipOval(
                  child: Image(
                    image: avatarImage,
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
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickAndSaveAvatar,
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SettingsSection(
              label: 'Account',
              items: [
                SettingsTile(
                  icon: Icons.account_balance,
                  title: 'Manage linked banks',
                ),
                SettingsTile(icon: Icons.shield, title: 'Security'),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
        const SizedBox(height: 16),
        // Row 2
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SettingsSection(
              label: 'Intelligence',
              items: [
                SettingsTile(
                  icon: Icons.monitor_heart,
                  title: 'AI Insight Frequency',
                ),
                SettingsTile(
                  icon: Icons.category,
                  title: 'Auto-categorization',
                ),
              ],
            ),

            const SizedBox(height: 16),

            _SettingsSection(
              label: 'Support',
              items: [
                SettingsTile(icon: Icons.help, title: 'Help Center'),
                SettingsTile(icon: Icons.info, title: 'About AxisFlow'),
              ],
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
        GlassCard(
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
                      : const Color.fromARGB(255, 255, 0, 0),
                  size: 22,
                ),
                const SizedBox(height: 12),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: _hovered
                        ? AppColors.error
                        : const Color.fromARGB(255, 255, 0, 0),
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
