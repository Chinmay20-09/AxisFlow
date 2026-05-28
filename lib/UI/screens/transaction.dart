import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:axisflow/core/constants/app_strings.dart';
import 'package:axisflow/core/config/app_config.dart';
import 'package:axisflow/controller/transaction_controller.dart';
import 'package:axisflow/ui/widgets/navigation/sidemenu.dart';
import 'package:axisflow/ui/widgets/navigation/menu_button.dart';

void main() {
  runApp(AxisFlowApp());
}

// ── App ────────────────────────────────────────────────────────────────────────
class AxisFlowApp extends StatelessWidget {
  final TransactionController controller = TransactionController()..load();

  AxisFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appActivityTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
      ),
      home: ActivityScreen(controller: controller),
    );
  }
}

// ── Colour tokens ──────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const background = Color(0xFF05070A);
  static const surface = Color(0xFF111417);
  static const surfaceContainer = Color(0xFF1D2023);
  static const surfaceContainerHighest = Color(0xFF323539);
  static const onSurface = Color(0xFFE1E2E7);
  static const onSurfaceVariant = Color(0xFFBCCABB);
  static const primary = Color(0xFF4ADE80);
  static const onPrimary = Color(0xFF003919);
  static const secondary = Color(0xFFC4C6CE);
  static const error = Color(0xFFFFB4AB);
  static const outline = Color(0xFF869486);
}

// ── Opacity constants (replaces magic numbers) ─────────────────────────────────
class AppOpacity {
  AppOpacity._();

  static const high = 1.0;
  static const medium = 0.6;
  static const low = 0.4;
  static const faint = 0.3;
  static const ghost = 0.1;
  static const glassCard = 0.04;
  static const glassBorder = 0.08;
  static const glassBlur = 0.05;
  static const searchBg = 1.0; // #0F1115 – opaque
}

// ── Dimensions ─────────────────────────────────────────────────────────────────
class AppDims {
  AppDims._();

  static const double pagePaddingH = 20;
  static const double pagePaddingTop = 20;
  static const double sectionGap = 32;
  static const double cardRadius = 24;
  static const double chipRadius = 999;
  static const double avatarSize = 32;
  static const double iconWrapSize = 48;
  static const double iconWrapRadius = 999; // circle
  static const double glowSize = 256;
  static const double glowBlur = 80;
  static const double backdropBlur = 20;
  static const double navBlur = 30;
  static const double chipPadH = 20;
  static const double chipPadV = 8;
  static const double cardPadding = 16;
  static const double insightPadding = 28;
  static const double groupSpacing = 12;
}

// ── Typography ─────────────────────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static const appBarTitle = TextStyle(
    color: AppColors.primary,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.48,
  );

  static const groupLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.1,
  );

  static const transactionTitle = TextStyle(
    color: AppColors.onSurface,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const transactionMeta = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.55,
  );

  static const amountBase = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const chipLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.55,
  );

  static const aiLabel = TextStyle(
    color: AppColors.primary,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.88,
  );

  static const aiBody = TextStyle(
    color: AppColors.onSurface,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const aiCta = TextStyle(
    color: AppColors.primary,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.55,
  );
}

// ── Data models ───────────────────────────────────────────────────────────
class TransactionItem {
  final IconData icon;
  final String title;
  final String meta; // time + category string
  final String amount;
  final bool isIncome;

  const TransactionItem({
    required this.icon,
    required this.title,
    required this.meta,
    required this.amount,
    this.isIncome = false,
  });
}

class TransactionGroup {
  final String label;
  final List<TransactionItem> items;

  const TransactionGroup({required this.label, required this.items});
}

// ── Static data ────────────────────────────────────────────────────────────────
const _transactionGroups = <TransactionGroup>[
  TransactionGroup(
    label: AppStrings.groupToday,
    items: [
      TransactionItem(
        icon: Icons.coffee,
        title: 'Starbucks',
        meta: '08:45 AM • Food & Drink',
        amount: '- \$6.50',
      ),
      TransactionItem(
        icon: Icons.payments,
        title: 'Salary Deposit',
        meta: '12:00 PM • Income',
        amount: '+ \$5,400.00',
        isIncome: true,
      ),
    ],
  ),
  TransactionGroup(
    label: AppStrings.groupYesterday,
    items: [
      TransactionItem(
        icon: Icons.devices,
        title: 'Apple Subscription',
        meta: '09:15 PM • Entertainment',
        amount: '- \$14.99',
      ),
      TransactionItem(
        icon: Icons.local_gas_station,
        title: 'Gas Station',
        meta: '04:30 PM • Transport',
        amount: '- \$52.20',
      ),
    ],
  ),
  TransactionGroup(
    label: AppStrings.groupMarch14,
    items: [
      TransactionItem(
        icon: Icons.home,
        title: 'Rent Payment',
        meta: '10:00 AM • Housing',
        amount: '- \$2,100.00',
      ),
    ],
  ),
];

// ── Screen ─────────────────────────────────────────────────────────────────────
class ActivityScreen extends StatefulWidget {
  final TransactionController controller;
  const ActivityScreen({super.key, required this.controller});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedChip = 0;
  final _searchController = TextEditingController();
  bool _searchFocused = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(controller: widget.controller, selectedIndex: 2),
      backgroundColor: AppColors.background,
      extendBody: true,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppDims.pagePaddingH,
              AppDims.pagePaddingTop,
              AppDims.pagePaddingH,
              120,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SearchAndFilters(
                  controller: _searchController,
                  focused: _searchFocused,
                  onFocusChange: (v) => setState(() => _searchFocused = v),
                  selectedChip: _selectedChip,
                  onChipSelected: (i) => setState(() => _selectedChip = i),
                ),
                const SizedBox(height: AppDims.sectionGap),
                ..._transactionGroups.map(
                  (g) => Padding(
                    padding: const EdgeInsets.only(bottom: AppDims.sectionGap),
                    child: _TransactionGroup(group: g),
                  ),
                ),
                _AiInsightCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.surface.withValues(
        alpha: AppOpacity.medium + 0.2,
      ),
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppDims.backdropBlur,
            sigmaY: AppDims.backdropBlur,
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          MenuButton(scaffoldKey: _scaffoldKey),
          const SizedBox(width: 8),
          Text(AppStrings.appBarBrand, style: AppTextStyles.appBarTitle),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            color: AppColors.secondary.withValues(alpha: AppOpacity.high),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            Icons.tune,
            color: AppColors.secondary.withValues(alpha: AppOpacity.high),
          ),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _Avatar(
            url: AppCredentials.avatarUrl,
            size: AppDims.avatarSize,
          ),
        ),
      ],
    );
  }
}

// ── Avatar ─────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String url;
  final double size;

  const _Avatar({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: AppOpacity.ghost),
          ),
        ),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const Icon(
            Icons.person,
            color: AppColors.onSurfaceVariant,
            size: 18,
          ),
        ),
      ),
    );
  }
}

// ── Search + Filter chips ──────────────────────────────────────────────────────
class _SearchAndFilters extends StatelessWidget {
  final TextEditingController controller;
  final bool focused;
  final ValueChanged<bool> onFocusChange;
  final int selectedChip;
  final ValueChanged<int> onChipSelected;

  const _SearchAndFilters({
    required this.controller,
    required this.focused,
    required this.onFocusChange,
    required this.selectedChip,
    required this.onChipSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        AnimatedScale(
          scale: focused ? 1.01 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Focus(
            onFocusChange: onFocusChange,
            child: TextField(
              controller: controller,
              style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
              decoration: InputDecoration(
                hintText: AppStrings.searchHint,
                hintStyle: TextStyle(
                  color: AppColors.secondary.withValues(alpha: AppOpacity.low),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: const Color(0xFF0F1115),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: AppOpacity.low),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(AppStrings.chips.length, (i) {
              final active = i == selectedChip;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onChipSelected(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDims.chipPadH,
                      vertical: AppDims.chipPadV,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primary
                          : Colors.white.withValues(
                              alpha: AppOpacity.glassCard,
                            ),
                      borderRadius: BorderRadius.circular(AppDims.chipRadius),
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: active ? 0 : AppOpacity.glassBorder,
                        ),
                      ),
                    ),
                    child: Text(
                      AppStrings.chips[i],
                      style: AppTextStyles.chipLabel.copyWith(
                        color: active
                            ? AppColors.onPrimary
                            : AppColors.secondary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── Transaction group ──────────────────────────────────────────────────────────
class _TransactionGroup extends StatelessWidget {
  final TransactionGroup group;

  const _TransactionGroup({required this.group});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            group.label.toUpperCase(),
            style: AppTextStyles.groupLabel.copyWith(
              color: AppColors.secondary.withValues(alpha: AppOpacity.medium),
            ),
          ),
        ),
        Column(
          children: group.items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDims.groupSpacing),
                  child: _TransactionTile(item: item),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ── Transaction tile ───────────────────────────────────────────────────────────
class _TransactionTile extends StatefulWidget {
  final TransactionItem item;

  const _TransactionTile({required this.item});

  @override
  State<_TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<_TransactionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {},
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDims.cardRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppDims.backdropBlur,
              sigmaY: AppDims.backdropBlur,
            ),
            child: Container(
              padding: const EdgeInsets.all(AppDims.cardPadding),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: AppOpacity.glassCard),
                borderRadius: BorderRadius.circular(AppDims.cardRadius),
                border: Border.all(
                  color: Colors.white.withValues(alpha: AppOpacity.glassBorder),
                ),
              ),
              child: Row(
                children: [
                  // Icon wrapper
                  Container(
                    width: AppDims.iconWrapSize,
                    height: AppDims.iconWrapSize,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.item.icon,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Labels
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.title,
                          style: AppTextStyles.transactionTitle,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.item.meta,
                          style: AppTextStyles.transactionMeta.copyWith(
                            color: AppColors.secondary.withValues(
                              alpha: AppOpacity.medium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amount + chevron
                  Row(
                    children: [
                      Text(
                        widget.item.amount,
                        style: AppTextStyles.amountBase.copyWith(
                          color: widget.item.isIncome
                              ? AppColors.primary
                              : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.secondary.withValues(
                          alpha: AppOpacity.faint,
                        ),
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── AI Insight Card ────────────────────────────────────────────────────────────
class _AiInsightCard extends StatefulWidget {
  @override
  State<_AiInsightCard> createState() => _AiInsightCardState();
}

class _AiInsightCardState extends State<_AiInsightCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDims.cardRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppDims.backdropBlur,
            sigmaY: AppDims.backdropBlur,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: AppOpacity.glassCard),
              borderRadius: BorderRadius.circular(AppDims.cardRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: AppOpacity.glassBorder),
              ),
            ),
            child: Stack(
              children: [
                // Ambient glow blob
                Positioned(
                  top: -96,
                  right: -96,
                  child: Container(
                    width: AppDims.glowSize,
                    height: AppDims.glowSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: AppOpacity.glassBlur,
                          ),
                          blurRadius: AppDims.glowBlur,
                          spreadRadius: AppDims.glowBlur,
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(AppDims.insightPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            AppStrings.aiInsightLabel,
                            style: AppTextStyles.aiLabel,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        AppStrings.aiInsightBody,
                        style: AppTextStyles.aiBody,
                      ),
                      const SizedBox(height: 16),
                      AnimatedSlide(
                        offset: Offset(_hovered ? 0.04 : 0, 0),
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        child: Row(
                          children: const [
                            Text(
                              AppStrings.aiInsightCta,
                              style: AppTextStyles.aiCta,
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward,
                              color: AppColors.primary,
                              size: 16,
                            ),
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
