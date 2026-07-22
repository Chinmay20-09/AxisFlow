import 'package:flutter/material.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/core/theme/app_text_styles.dart';
import 'package:axisflow/core/constants/app_dims.dart';
import 'package:axisflow/data/models/transaction_model.dart';
import 'package:axisflow/data/local/settings_db.dart';
import 'package:axisflow/ui/screens/categories.dart';
import 'package:axisflow/ui/screens/budgets/budget_models.dart';

/// A shared category selection widget used by both [PopupAddTransaction]
/// and [AddTransactionSheet].
///
/// Provides:
/// - Favorite category chips filtered by [transactionType]
/// - A category field with icon, color, and "Suggested •" label
/// - A bottom sheet picker with full category list and icons
///
/// Loads categories and favorites internally from the same source
/// (categories.dart + SettingsDB) so there is only one category
/// experience throughout AxisFlow.
class CategorySelector extends StatefulWidget {
  final TransactionType transactionType;
  final String selectedCategory;
  final String? suggestedCategory;
  final ValueChanged<String> onChanged;

  const CategorySelector({
    super.key,
    required this.transactionType,
    required this.selectedCategory,
    this.suggestedCategory,
    required this.onChanged,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  List<String> _favoriteCats = [];
  List<String> _typeCategories = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void didUpdateWidget(CategorySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactionType != widget.transactionType) {
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    try {
      await SettingsDB.init();
      final fav =
          SettingsDB.get<List>('categories.favorites', <String>[]);
      final favList = (fav ?? <String>[]).cast<String>();

      final incNames = await loadIncomeCategoryNames();
      final expNames = await loadExpenseCategoryNames();

      if (mounted) {
        setState(() {
          _typeCategories = widget.transactionType == TransactionType.income
              ? incNames
              : expNames;
          _favoriteCats =
              favList.where((f) => _typeCategories.contains(f)).toList();
          _loaded = true;
        });
      }
    } catch (_) {
      // Use defaults on failure
    }
  }

  bool get _isSuggested =>
      widget.suggestedCategory != null &&
      widget.selectedCategory == widget.suggestedCategory;

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_favoriteCats.isNotEmpty) ...[
          _buildFavoriteChips(),
          const SizedBox(height: AppDims.sm),
        ],
        _buildCategoryField(),
      ],
    );
  }

  /// Favorite category chips with icons, colors, and highlight.
  Widget _buildFavoriteChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FAVOURITES',
          style: TextStyle(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            fontSize: 11,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppDims.xs),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _favoriteCats.map((name) {
            final info = categoryIconInfo(name);
            final isSelected = widget.selectedCategory == name;
            return GestureDetector(
              onTap: () => widget.onChanged(name),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? info.fgColor.withValues(alpha: 0.12)
                      : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppDims.radiusXl),
                  border: Border.all(
                    color: isSelected
                        ? info.fgColor.withValues(alpha: 0.5)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(info.icon, size: 16, color: info.fgColor),
                    const SizedBox(width: 6),
                    Text(
                      name,
                      style: TextStyle(
                        color: isSelected
                            ? info.fgColor
                            : AppColors.onSurface,
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Category field showing current category with icon and "Suggested •" label.
  Widget _buildCategoryField() {
    final info = categoryIconInfo(widget.selectedCategory);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppDims.radiusXl),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDims.radiusXl),
          onTap: _showCategoryPicker,
          child: Padding(
            padding: EdgeInsets.all(AppDims.md),
            child: Row(
              children: [
                // Category icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: info.fgColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(info.icon, color: info.fgColor, size: 20),
                ),
                const SizedBox(width: AppDims.md),
                // Labels
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CATEGORY',
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant
                              .withValues(alpha: 0.6),
                          fontSize: 11,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isSuggested
                            ? 'Suggested • ${widget.selectedCategory}'
                            : widget.selectedCategory,
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chevron
                Icon(
                  Icons.chevron_right,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Bottom sheet picker with full category list and icons.
  void _showCategoryPicker() {
    final isIncome = widget.transactionType == TransactionType.income;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Grab handle
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Text(
                      isIncome ? 'Choose Income Category' : 'Choose Category',
                      style: AppTextStyles.headlineLgMobile,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              // Category list
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: _typeCategories.map((name) {
                    final i = categoryIconInfo(name);
                    final isSelected = widget.selectedCategory == name;
                    return ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: i.fgColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(i.icon, color: i.fgColor, size: 18),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          color: isSelected
                              ? i.fgColor
                              : AppColors.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: i.fgColor, size: 20)
                          : null,
                      onTap: () {
                        widget.onChanged(name);
                        Navigator.of(ctx).pop();
                      },
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
            ],
          ),
        );
      },
    );
  }
}
