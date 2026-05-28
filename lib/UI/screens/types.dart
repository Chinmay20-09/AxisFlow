import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:axisflow/controller/transaction_controller.dart';

void main() {
  runApp(const AxisFlowApp());
}

class AxisFlowApp extends StatelessWidget {
  const AxisFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AxisFlow - Categories',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF05070A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4ADE80),
          surface: Color(0xFF111417),
        ),
      ),
      home: const CategoriesScreen(),
    );
  }
}

// ── Colour tokens ──────────────────────────────────────────────────────────────
class AppColors {
  static const background = Color(0xFF05070A);
  static const surface = Color(0xFF111417);
  static const surfaceContainer = Color(0xFF1D2023);
  static const surfaceContainerLow = Color(0xFF191C1F);
  static const surfaceContainerHigh = Color(0xFF282A2E);
  static const surfaceVariant = Color(0xFF323539);
  static const onSurface = Color(0xFFE1E2E7);
  static const onSurfaceVariant = Color(0xFFBCCABB);
  static const primary = Color(0xFF4ADE80);
  static const onPrimary = Color(0xFF003919);
  static const secondary = Color(0xFFC4C6CE);
  static const outlineVariant = Color(0xFF3D4A3E);
}

// ── Data model ─────────────────────────────────────────────────────────────────
class CategoryItem {
  final String id;
  final String label;
  final IconData icon;
  final bool frequent;

  const CategoryItem({
    required this.id,
    required this.label,
    required this.icon,
    this.frequent = false,
  });
}

const _categories = <CategoryItem>[
  CategoryItem(
    id: 'food',
    label: 'Food',
    icon: Icons.restaurant,
    frequent: true,
  ),
  CategoryItem(id: 'travel', label: 'Travel', icon: Icons.flight),
  CategoryItem(
    id: 'shopping',
    label: 'Shopping',
    icon: Icons.shopping_bag,
    frequent: true,
  ),
  CategoryItem(id: 'bills', label: 'Bills', icon: Icons.receipt_long),
  CategoryItem(id: 'salary', label: 'Salary', icon: Icons.payments),
  CategoryItem(id: 'health', label: 'Health', icon: Icons.medical_services),
  CategoryItem(id: 'entertainment', label: 'Movies', icon: Icons.movie),
  CategoryItem(id: 'investments', label: 'Invest', icon: Icons.trending_up),
  CategoryItem(id: 'education', label: 'Education', icon: Icons.school),
  CategoryItem(id: 'gifts', label: 'Gifts', icon: Icons.card_giftcard),
];

// ── Screen ─────────────────────────────────────────────────────────────────────
class CategoriesScreen extends StatefulWidget {
  final TransactionController? controller;

  const CategoriesScreen({super.key, this.controller});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // Start with "Food" selected to match the HTML default.
  final Set<String> _selected = {'food'};

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  void _reset() => setState(() => _selected.clear());

  List<CategoryItem> get _selectedItems =>
      _categories.where((c) => _selected.contains(c.id)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Header ──────────────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.surface.withValues(alpha: 0.85),
                elevation: 0,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: const SizedBox.expand(),
                  ),
                ),
                leading: const Icon(
                  Icons.arrow_back,
                  color: AppColors.onSurface,
                ),
                title: const Text(
                  'Categories',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.02 * 24,
                  ),
                ),
                actions: const [
                  Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.reorder, color: AppColors.onSurface),
                  ),
                ],
              ),

              // ── Subtitle ────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Text(
                    'Choose shortcuts for faster transaction tracking',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              // ── AI Insight card ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _AiInsightCard(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ── Category grid ───────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final cat = _categories[i];
                    final sel = _selected.contains(cat.id);
                    return _CategoryCard(
                      item: cat,
                      selected: sel,
                      onTap: () => _toggle(cat.id),
                    );
                  }, childCount: _categories.length),
                ),
              ),

              // Bottom padding so content isn't hidden behind the FAB strip.
              const SliverToBoxAdapter(child: SizedBox(height: 160)),
            ],
          ),

          // ── Floating bottom panel ────────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomPanel(
              selectedItems: _selectedItems,
              onReset: _reset,
              onSave: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Saved ${_selectedItems.length} shortcut(s)!',
                    ),
                    backgroundColor: AppColors.surfaceContainerHigh,
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI INSIGHT',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.05 * 11,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Most used categories are already prioritized based on your monthly spending flow.',
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 14,
                          height: 1.43,
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

// ── Category Card ──────────────────────────────────────────────────────────────
class _CategoryCard extends StatefulWidget {
  final CategoryItem item;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _lift;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.selected ? 1.0 : 0.0,
    );
    _lift = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void didUpdateWidget(_CategoryCard old) {
    super.didUpdateWidget(old);
    if (widget.selected != old.selected) {
      widget.selected ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _lift,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -4 * _lift.value),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.selected
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: 0.08),
              width: widget.selected ? 1.5 : 1,
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon container
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.selected
                            ? AppColors.surfaceContainerHigh
                            : AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        widget.item.icon,
                        size: 30,
                        color: widget.selected
                            ? AppColors.primary
                            : AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Label
                    Text(
                      widget.item.label,
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Frequency badge / spacer
                    if (widget.item.frequent)
                      Text(
                        'Frequently used',
                        style: TextStyle(
                          color: AppColors.primary.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.05 * 11,
                        ),
                      )
                    else
                      const SizedBox(height: 16),
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

// ── Bottom Panel ───────────────────────────────────────────────────────────────
class _BottomPanel extends StatelessWidget {
  final List<CategoryItem> selectedItems;
  final VoidCallback onReset;
  final VoidCallback onSave;

  const _BottomPanel({
    required this.selectedItems,
    required this.onReset,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          color: AppColors.surfaceContainerLow.withValues(alpha: 0.92),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Preview strip
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Text(
                      'PREVIEW:',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.05 * 11,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: selectedItems.isNotEmpty
                              ? selectedItems
                                    .map(
                                      (c) => Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: _PreviewIcon(icon: c.icon),
                                      ),
                                    )
                                    .toList()
                              : [
                                  Text(
                                    'No shortcuts selected',
                                    style: TextStyle(
                                      color: AppColors.onSurfaceVariant
                                          .withValues(alpha: 0.4),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  MediaQuery.of(context).padding.bottom + 16,
                ),
                child: Row(
                  children: [
                    // Reset
                    Expanded(
                      child: GestureDetector(
                        onTap: onReset,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.outlineVariant.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Save
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: onSave,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Save Shortcuts',
                            style: TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Preview icon bubble ────────────────────────────────────────────────────────
class _PreviewIcon extends StatelessWidget {
  final IconData icon;

  const _PreviewIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, color: AppColors.primary, size: 18),
    );
  }
}
