import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:axisflow/controller/transaction_controller.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/ui/screens/budgets/budget_models.dart';
import 'package:axisflow/ui/widgets/cards/planner_summary_card.dart';
import 'package:axisflow/ui/widgets/cards/glass_card.dart';
import 'package:axisflow/ui/widgets/common/planner_footer.dart';
import 'package:axisflow/ui/widgets/tiles/category_slider_card.dart';
import 'package:axisflow/data/services/budgets_service.dart';
import 'package:axisflow/ui/screens/categories.dart';

// ── Budget Data model ─────────────────────────────────────────────────────────
/// The budget data read through the Planner, serving as the single access point
/// for Details and other screens that need the planner's budget values.
class BudgetData {
  final double monthlyIncome;
  final Map<String, double> allocations;

  const BudgetData({
    required this.monthlyIncome,
    required this.allocations,
  });
}

/// Read the current budget data through the Planner layer.
/// Details and other consumers should call this instead of reading
/// BudgetService directly, so all budget value access flows through the Planner.
BudgetData getBudgetData() {
  return BudgetData(
    monthlyIncome: BudgetService.getMonthlyIncome(),
    allocations: BudgetService.getAllocations(),
  );
}

// ── Budget Planner Screen ──────────────────────────────────────────────────────
class BudgetPlannerScreen extends StatefulWidget {
  final TransactionController? controller;

  const BudgetPlannerScreen({super.key, this.controller});

  @override
  State<BudgetPlannerScreen> createState() => _BudgetPlannerScreenState();
}

class _BudgetPlannerScreenState extends State<BudgetPlannerScreen> {
  late final TextEditingController _incomeController;
  List<CategoryBudget> _categories = [];
  double _monthlyIncome = 50000;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _monthlyIncome = BudgetService.getMonthlyIncome();
    if (_monthlyIncome <= 0) {
      _monthlyIncome = 50000;
    }

    _incomeController =
        TextEditingController(text: _monthlyIncome.round().toString());

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    // Load favorite category names from the single source of truth
    final favoriteNames = await loadFavoriteCategoryNames();

    final savedAllocations = BudgetService.getAllocations();

    final categories = <CategoryBudget>[];
    for (final name in favoriteNames) {
      final info = categoryIconInfo(name);
      categories.add(CategoryBudget(
        id: name,
        name: name,
        icon: info.icon,
        color: info.fgColor,
        percent: savedAllocations[name] ?? 0,
      ));
    }

    if (mounted) {
      setState(() {
        _categories = categories;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  double get _totalAllocated =>
      _categories.fold(0.0, (sum, c) => sum + c.percent).clamp(0, 100);

  void _onIncomeChanged(String value) {
    setState(() => _monthlyIncome = double.tryParse(value) ?? 0);
  }

  void _onCategoryChanged(CategoryBudget category, double newValue) {
    final othersSum = _categories
        .where((c) => c.id != category.id)
        .fold(0.0, (sum, c) => sum + c.percent);
    final capped = (othersSum + newValue > 100) ? 100 - othersSum : newValue;

    setState(() => category.percent = capped.clamp(0, 100));
  }

  void _onReset() {
    setState(() {
      for (final category in _categories) {
        category.percent = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allocated = _totalAllocated;
    final remaining = 100 - allocated;
    final isFullyAllocated = allocated >= 100;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildTopBar(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            const SizedBox(height: 8),
            const Text(
              'Budget Planner',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Allocate your monthly income across categories',
              style: TextStyle(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            PlannerSummaryCard(
              incomeController: _incomeController,
              allocated: allocated,
              remaining: remaining,
              onIncomeChanged: _onIncomeChanged,
            ),
            const SizedBox(height: 16),
            Divider(color: AppColors.outlineVariant, height: 1),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_categories.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.star_border,
                        size: 48,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No favorite categories yet.\nMark categories as favorites in the Categories\nscreen to start planning your budget.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._categories.map((category) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: CategorySliderCard(
                      category: category,
                      monthlyIncome: _monthlyIncome,
                      onChanged: (v) => _onCategoryChanged(category, v),
                    ),
                  )),
            if (_categories.isNotEmpty) _buildValidationBox(isFullyAllocated),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: PlannerFooter(
        onReset: _onReset,
        onSave: () async {
          final navigator = Navigator.of(context);
          await BudgetService.save(
            monthlyIncome: _monthlyIncome,
            categories: _categories,
          );

          if (mounted) {
            navigator.pop();
          }
        },
      ),
    );
  }

  PreferredSizeWidget _buildTopBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface.withValues(alpha: 0.85),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: const SizedBox.expand(),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: const Text(
        'Budget Planner',
        style: TextStyle(
          color: AppColors.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: Colors.white.withValues(alpha: 0.2),
          height: 1,
        ),
      ),
    );
  }

  Widget _buildValidationBox(bool isFullyAllocated) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: BorderRadius.circular(18),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isFullyAllocated
                  ? '100% allocated!'
                  : 'Allocate your income across categories',
              style: TextStyle(
                color: isFullyAllocated
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
