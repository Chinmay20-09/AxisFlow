import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/core/constants/app_strings.dart';
import 'package:axisflow/controller/transaction_controller.dart';
import 'package:axisflow/data/models/transaction_model.dart';
import 'package:axisflow/core/error_handler.dart';
import 'package:axisflow/ui/widgets/tiles/transaction_tile.dart';
import 'package:axisflow/ui/screens/add_transaction.dart';
import 'package:axisflow/ui/widgets/navigation/sidemenu.dart';
import 'package:axisflow/ui/widgets/navigation/menu_button.dart';
import 'package:axisflow/ui/screens/dashboard.dart';
import 'package:axisflow/ui/widgets/cards/ai_insight_card.dart';

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

// Using shared AppColors from core/app_colors.dart

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

/* Transaction demo data removed — groups are now built from TransactionController.transactions */

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
  void initState() {
    super.initState();
    // Forward search text to controller so filtering is centralized
    _searchController.addListener(() {
      widget.controller.setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Displays transaction actions (Edit / Delete) in a bottom sheet.
  // Edit respects Transaction.isEditable; Delete is always available.
  void _showTransactionActions(Transaction tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tx.isEditable)
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('Edit'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => AddTransactionSheet(
                          controller: widget.controller,
                          existing: tx,
                        ),
                      );
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Delete'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    final confirm = await showDialog<bool>(
                      context: ctx,
                      builder: (dctx) => AlertDialog(
                        title: const Text('Delete transaction'),
                        content: const Text(
                          'Are you sure you want to delete this transaction?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(dctx).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm != true) return;
                    try {
                      await widget.controller.delete(tx.id);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transaction deleted')),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      showErrorSnackBar(
                        context,
                        e,
                        'Failed to delete transaction',
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
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
                  onChipSelected: (i) => setState(() {
                    _selectedChip = i;
                    widget.controller.setChipSelected(i);
                  }),
                ),
                const SizedBox(height: AppDims.sectionGap),
                AnimatedBuilder(
                  animation: widget.controller,
                  builder: (context, _) {
                    // Use controller's filteredTransactions which centralizes
                    // search and filter logic.
                    final filtered = widget.controller.filteredTransactions;
                    final now = DateTime.now();

                    // Group filtered transactions by label (Today / Yesterday / Date)
                    final groups = <String, List<Transaction>>{};
                    for (final t in filtered) {
                      String label;
                      if (now.year == t.createdAt.year &&
                          now.month == t.createdAt.month &&
                          now.day == t.createdAt.day) {
                        label = AppStrings.groupToday;
                      } else {
                        final yesterday = DateTime(
                          now.year,
                          now.month,
                          now.day,
                        ).subtract(const Duration(days: 1));
                        if (t.createdAt.year == yesterday.year &&
                            t.createdAt.month == yesterday.month &&
                            t.createdAt.day == yesterday.day) {
                          label = AppStrings.groupYesterday;
                        } else {
                          label =
                              '${t.createdAt.day}/${t.createdAt.month}/${t.createdAt.year}';
                        }
                      }
                      groups.putIfAbsent(label, () => []).add(t);
                    }

                    final widgets = groups.entries
                        .map<Widget>(
                          (e) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppDims.sectionGap,
                            ),
                            child: _TransactionGroup(
                              label: e.key,
                              transactions: e.value,
                              controller: widget.controller,
                              onTransactionLongPress: (tx) =>
                                  _showTransactionActions(tx),
                            ),
                          ),
                        )
                        .toList();

                    widgets.add(const SizedBox(height: AppDims.sectionGap));
                    widgets.add(
                      AiInsightCard(
                        message: widget.controller.analytics.summaryInsight,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AxisFlowInsightsScreen(
                                controller: widget.controller,
                              ),
                            ),
                          );
                        },
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
      leading: MenuButton(
        scaffoldKey: _scaffoldKey,
        controller: widget.controller,
      ),
      title: Row(
        children: [
          Text(AppStrings.appBarBrand, style: AppTextStyles.appBarTitle),
        ],
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
                  color: AppColors.label.withValues(alpha: AppOpacity.low),
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
                            : AppColors.label.withValues(
                                alpha: AppOpacity.medium,
                              ),
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
  final String label;
  final List<Transaction> transactions;
  final TransactionController controller;
  final Function(Transaction) onTransactionLongPress;

  const _TransactionGroup({
    required this.label,
    required this.transactions,
    required this.controller,
    required this.onTransactionLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            label.toUpperCase(),
            style: AppTextStyles.groupLabel.copyWith(
              color: AppColors.label.withValues(alpha: AppOpacity.medium),
            ),
          ),
        ),
        Column(
          children: transactions
              .map(
                (tx) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDims.groupSpacing),
                  child: TransactionTile(
                    transaction: tx,
                    onLongPress: () => onTransactionLongPress(tx),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
