import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:axisflow/controller/transaction_controller.dart';
import 'package:axisflow/ui/widgets/navigation/sidemenu.dart';
import 'package:axisflow/ui/widgets/navigation/menu_button.dart';
import 'package:axisflow/data/local/settings_db.dart';
import 'package:axisflow/data/services/export_service.dart';

void main() {
  runApp(AxisFlowApp());
}

class AxisFlowApp extends StatelessWidget {
  final TransactionController controller = TransactionController()..load();

  AxisFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AxisFlow | Settings',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        sliderTheme: SliderThemeData(
          trackHeight: 4,
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: AppColors.surfaceContainer,
          thumbColor: AppColors.primary,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          overlayColor: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      home: SettingsScreen(controller: controller),
    );
  }
}

// ── Colour tokens ──────────────────────────────────────────────────────────────
class AppColors {
  static const background = Color(0xFF111417);
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
  static const error = Color(0xFFFFB4AB);
  static const outlineVariant = Color(0xFF3D4A3E);

  // Accent colour palette
  static const accentGreen = Color(0xFF4ADE80);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentPurple = Color(0xFFA855F7);
  static const accentAmber = Color(0xFFF59E0B);
}

// ── Screen ─────────────────────────────────────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  final TransactionController controller;
  const SettingsScreen({super.key, required this.controller});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Appearance
  bool _darkMode = true;
  int _accentIndex = 0;

  // Finance
  String _currency = 'USD (\$)';
  String _firstDay = '1st';

  // AI
  double _insightFreq = 3; // 1=Daily 2=Weekly 3=Adaptive

  // internal

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      await SettingsDB.init();
      final dark = SettingsDB.get<bool>('appearance.darkMode', _darkMode);
      final accent = SettingsDB.get<int>(
        'appearance.accentIndex',
        _accentIndex,
      );
      final currency = SettingsDB.get<String>('finance.currency', _currency);
      final firstDay = SettingsDB.get<String>('finance.firstDay', _firstDay);
      final freq = SettingsDB.get<double>('ai.insightFreq', _insightFreq);

      setState(() {
        _darkMode = dark ?? _darkMode;
        _accentIndex = accent ?? _accentIndex;
        _currency = currency ?? _currency;
        _firstDay = firstDay ?? _firstDay;
        _insightFreq = freq ?? _insightFreq;
      });
    } catch (e) {
      // If persistence not available, fall back to defaults
    }
  }

  static const _accentColors = [
    AppColors.accentGreen,
    AppColors.accentBlue,
    AppColors.accentPurple,
    AppColors.accentAmber,
  ];

  static const _freqLabels = ['Daily', 'Weekly', 'Adaptive'];

  String get _freqLabel {
    final index = (_insightFreq - 1).round().clamp(0, 2);
    return _freqLabels[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(controller: widget.controller, selectedIndex: 7),

      backgroundColor: AppColors.background,
      extendBody: true,
      body: CustomScrollView(
        slivers: [
          // ── Top App Bar ────────────────────────────────────────────────────
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
            title: const Text(
              'AxisFlow',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ClipOval(
                  child: Container(
                    width: 32,
                    height: 32,
                    color: AppColors.secondaryContainer,
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBgurkxRhbJliK429a4vs0EBoh9MfWppl8ZvzyutCazfnT_AopopO8grIDDhYfbK7mnGXz4hlOGg1T7ESfjDmaIicfwN6Hbwd_gDHw2kSpM1f8TLrKW0qanp8XeEGQIsHYHCHRfz5aim45E4u9vN1O_NZ8v9RTzBoWEEaVdnuyj_XnWfWoRdBqjJM96LZm-Nh03meK-OnjMgJ-0fIlNTsDtqzyf0pc5W5b60U-1Hm0mTMh6RKnEbr7LhE3SvvFSl1JdM4Y1huMuufoq',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.person,
                        color: AppColors.onSurfaceVariant,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Body ────────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Page heading
                const Text(
                  'Settings',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'How should the app behave?',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Appearance ───────────────────────────────────────────────
                _AppearanceCard(
                  darkMode: _darkMode,
                  accentIndex: _accentIndex,
                  accentColors: _accentColors,
                  onDarkModeToggle: () =>
                      setState(() => _darkMode = !_darkMode),
                  onAccentSelected: (i) => setState(() => _accentIndex = i),
                ),
                const SizedBox(height: 16),

                // ── Finance ──────────────────────────────────────────────────
                _FinanceCard(
                  currency: _currency,
                  firstDay: _firstDay,
                  onCurrencyChanged: (v) =>
                      setState(() => _currency = v ?? _currency),
                  onFirstDayChanged: (v) =>
                      setState(() => _firstDay = v ?? _firstDay),
                ),
                const SizedBox(height: 16),

                // ── AI Intelligence ──────────────────────────────────────────
                _AiCard(
                  freq: _insightFreq,
                  freqLabel: _freqLabel,
                  onFreqChanged: (v) => setState(() => _insightFreq = v),
                ),
                const SizedBox(height: 16),

                // ── Privacy ──────────────────────────────────────────────────
                _PrivacyCard(controller: widget.controller),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable glass card ────────────────────────────────────────────────────────
class _GlassCard extends StatelessWidget {
  final Widget child;
  final bool aiGlow;

  const _GlassCard({required this.child, this.aiGlow = false});

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
            boxShadow: aiGlow
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.all(24),
          child: child,
        ),
      ),
    );
  }
}

// ── Card header row ────────────────────────────────────────────────────────────
class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const _CardHeader({required this.icon, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Toggle switch ──────────────────────────────────────────────────────────────
class _Toggle extends StatelessWidget {
  final bool value;
  final VoidCallback onToggle;

  const _Toggle({required this.value, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 48,
        height: 24,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(999),
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
                decoration: const BoxDecoration(
                  color: AppColors.onPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Row label + sublabel ───────────────────────────────────────────────────────
class _RowLabel extends StatelessWidget {
  final String label;
  final String sub;

  const _RowLabel({required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          sub,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ── Appearance Card ────────────────────────────────────────────────────────────
class _AppearanceCard extends StatelessWidget {
  final bool darkMode;
  final int accentIndex;
  final List<Color> accentColors;
  final VoidCallback onDarkModeToggle;
  final ValueChanged<int> onAccentSelected;

  const _AppearanceCard({
    required this.darkMode,
    required this.accentIndex,
    required this.accentColors,
    required this.onDarkModeToggle,
    required this.onAccentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(icon: Icons.palette, title: 'Appearance'),
          const SizedBox(height: 32),

          // Dark mode row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _RowLabel(
                label: 'Dark Mode',
                sub: 'Reduce eye strain at night',
              ),
              _Toggle(value: darkMode, onToggle: onDarkModeToggle),
            ],
          ),
          const SizedBox(height: 32),

          // Accent colours
          const Text(
            'Accent Color',
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(accentColors.length, (i) {
              final active = i == accentIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => onAccentSelected(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: accentColors[i],
                      shape: BoxShape.circle,
                      border: active
                          ? Border.all(color: accentColors[i], width: 2)
                          : null,
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: accentColors[i].withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Finance Card ───────────────────────────────────────────────────────────────
class _FinanceCard extends StatelessWidget {
  final String currency;
  final String firstDay;
  final ValueChanged<String?> onCurrencyChanged;
  final ValueChanged<String?> onFirstDayChanged;

  const _FinanceCard({
    required this.currency,
    required this.firstDay,
    required this.onCurrencyChanged,
    required this.onFirstDayChanged,
  });

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          dropdownColor: AppColors.surfaceContainer,
          style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
          icon: const SizedBox.shrink(),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(icon: Icons.account_balance, title: 'Finance'),
          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _RowLabel(
                label: 'Currency',
                sub: 'Default reporting currency',
              ),
              _dropdown(
                value: currency,
                items: ['INR (₹)', 'USD (\$)', 'EUR (€)', 'GBP (£)'],
                onChanged: onCurrencyChanged,
              ),
            ],
          ),
          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _RowLabel(
                label: 'First Day of Month',
                sub: 'Budget calculation cycle',
              ),
              _dropdown(
                value: firstDay,
                items: ['1st', '15th', 'Last'],
                onChanged: onFirstDayChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── AI Intelligence Card ───────────────────────────────────────────────────────
class _AiCard extends StatelessWidget {
  final double freq;
  final String freqLabel;
  final ValueChanged<double> onFreqChanged;

  const _AiCard({
    required this.freq,
    required this.freqLabel,
    required this.onFreqChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      aiGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.auto_awesome,
            title: 'AI Intelligence',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'GEIST AI ENGINE',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.08 * 10,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Freq row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Insight Frequency',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                freqLabel,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.surfaceContainer,
              thumbColor: AppColors.primary,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: freq,
              min: 1,
              max: 3,
              divisions: 2,
              onChanged: onFreqChanged,
            ),
          ),

          // Tick labels
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              Text(
                'Weekly',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              Text(
                'Adaptive',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Privacy Card ───────────────────────────────────────────────────────────────
class _PrivacyCard extends StatelessWidget {
  final TransactionController controller;

  const _PrivacyCard({required this.controller});
  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(icon: Icons.security, title: 'Privacy'),
          const SizedBox(height: 32),

          // Data Export
          _PrivacyTile(
            icon: Icons.download,
            label: 'Data Export',
            labelColor: AppColors.error,
            iconColor: AppColors.error,
            chevronColor: AppColors.error.withValues(alpha: 0.5),
            hoverColor: AppColors.error.withValues(alpha: 0.05),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);

              messenger.showSnackBar(
                const SnackBar(content: Text('Exporting transactions...')),
              );
              final success = await ExportService.exportTransactions(
                controller.transactions,
              );
              messenger.hideCurrentSnackBar();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Transactions exported successfully!'
                        : 'Failed to export transactions. Please try again.',
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 4),

          // Delete Account
          _PrivacyTile(
            icon: Icons.delete_forever,
            label: 'Delete Account',
            labelColor: AppColors.error,
            iconColor: AppColors.error,
            chevronColor: AppColors.error.withValues(alpha: 0.5),
            hoverColor: AppColors.error.withValues(alpha: 0.05),
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Coming soon')));
            },
          ),
        ],
      ),
    );
  }
}

class _PrivacyTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color labelColor;
  final Color iconColor;
  final Color chevronColor;
  final Color hoverColor;
  final VoidCallback? onTap;

  const _PrivacyTile({
    required this.icon,
    required this.label,
    required this.labelColor,
    required this.iconColor,
    required this.chevronColor,
    required this.hoverColor,
    required this.onTap,
  });

  @override
  State<_PrivacyTile> createState() => _PrivacyTileState();
}

class _PrivacyTileState extends State<_PrivacyTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hovered ? widget.hoverColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: widget.iconColor, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(color: widget.labelColor, fontSize: 14),
                ),
              ),
              Icon(Icons.chevron_right, color: widget.chevronColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
