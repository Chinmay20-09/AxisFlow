import 'package:flutter/material.dart';
import 'package:axisflow/data/local/settings_db.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/controller/transaction_controller.dart';
import 'package:axisflow/ui/widgets/navigation/sidemenu.dart';
// Category model
class CategoryItem {
  final String name;
  final String icon;

  const CategoryItem({required this.name, required this.icon});

  @override
  String toString() => name;
}
class CategoriesScreen extends StatefulWidget {
  final TransactionController? controller;

  const CategoriesScreen({super.key, this.controller});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

// Default lists (used when no saved data exists)
const List<CategoryItem> incomeCategories = [
  CategoryItem(name: 'Salary', icon: '💰'),
  CategoryItem(name: 'Freelance', icon: '💻'),
  CategoryItem(name: 'Business', icon: '📈'),
  CategoryItem(name: 'Investment', icon: '📊'),
  CategoryItem(name: 'Gift', icon: '🎁'),
  CategoryItem(name: 'Refund', icon: '💵'),
  CategoryItem(name: 'Bonus', icon: '💸'),
  CategoryItem(name: 'Rental', icon: '🏠'),
  CategoryItem(name: 'Scholarship', icon: '🎓'),
  CategoryItem(name: 'Other', icon: '🪙'),
];

const List<CategoryItem> expenseCategories = [
  CategoryItem(name: 'Food', icon: '🍔'),
  CategoryItem(name: 'Transport', icon: '🚗'),
  CategoryItem(name: 'Bills', icon: '🧾'),
  CategoryItem(name: 'Shopping', icon: '🛍️'),
  CategoryItem(name: 'Health', icon: '🏥'),
  CategoryItem(name: 'Education', icon: '🎓'),
  CategoryItem(name: 'Entertainment', icon: '🎬'),
  CategoryItem(name: 'Travel', icon: '✈️'),
  CategoryItem(name: 'Subscription', icon: '📱'),
  CategoryItem(name: 'Rent', icon: '🔑'),
  CategoryItem(name: 'EMI', icon: '💳'),
  CategoryItem(name: 'Family', icon: '👨‍👩‍👧‍👦'),
  CategoryItem(name: 'Personal', icon: '👤'),
  CategoryItem(name: 'Other', icon: '🪙'),
];

final List<CategoryItem> _allDefaultCategories = List<CategoryItem>.from(
  incomeCategories,
)..addAll(expenseCategories);

String getCategoryIcon(String categoryName) {
  final item = _allDefaultCategories.firstWhere(
    (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
    orElse: () => CategoryItem(name: categoryName, icon: ''),
  );
  return item.icon;
}

String getCategoryDisplay(String categoryName) {
  final icon = getCategoryIcon(categoryName);
  return icon.isEmpty ? categoryName : '$categoryName $icon';
}

// Persistence helpers
Future<List<String>> loadIncomeCategoryNames() async {
  try {
    await SettingsDB.init();
    final saved = SettingsDB.get<List>('categories.income');
    if (saved == null) return incomeCategories.map((c) => c.name).toList();
    return saved.cast<String>();
  } catch (_) {
    return incomeCategories.map((c) => c.name).toList();
  }
}

Future<List<String>> loadExpenseCategoryNames() async {
  try {
    await SettingsDB.init();
    final saved = SettingsDB.get<List>('categories.expense');
    if (saved == null) return expenseCategories.map((c) => c.name).toList();
    return saved.cast<String>();
  } catch (_) {
    return expenseCategories.map((c) => c.name).toList();
  }
}

Future<Set<String>> loadFavoriteCategoryNames() async {
  try {
    await SettingsDB.init();
    final saved = SettingsDB.get<List>('categories.favorites');
    if (saved == null) return <String>{};
    return saved.cast<String>().toSet();
  } catch (_) {
    return <String>{};
  }
}

Future<void> saveCategories({List<String>? income, List<String>? expense, Set<String>? favorites}) async {
  await SettingsDB.init();
  if (income != null) await SettingsDB.set('categories.income', income);
  if (expense != null) await SettingsDB.set('categories.expense', expense);
  if (favorites != null) await SettingsDB.set('categories.favorites', favorites.toList());
}

// Screen widget to manage categories


class _CategoriesScreenState extends State<CategoriesScreen> {
  List<String> _income = [];
  List<String> _expense = [];
  Set<String> _favorites = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final inc = await loadIncomeCategoryNames();
    final exp = await loadExpenseCategoryNames();
    final fav = await loadFavoriteCategoryNames();
    setState(() {
      _income = inc;
      _expense = exp;
      _favorites = fav;
      _loading = false;
    });
  }

  Future<void> _addCategory(bool income, String name) async {
    if (name.trim().isEmpty) return;
    setState(() {
      if (income) {
        _income.add(name.trim());
      } else {
        _expense.add(name.trim());
      }
    });
    await saveCategories(income: _income, expense: _expense, favorites: _favorites);
  }

  Future<void> _removeCategory(bool income, String name) async {
    setState(() {
      if (income) {
        _income.remove(name);
      } else {
        _expense.remove(name);
      }
      _favorites.remove(name);
    });
    await saveCategories(income: _income, expense: _expense, favorites: _favorites);
  }

  Future<void> _toggleFavorite(String name) async {
    setState(() {
      if (_favorites.contains(name)) {
        _favorites.remove(name);
      } else {
        _favorites.add(name);
      }
    });
    await saveCategories(favorites: _favorites);
  }

  Future<void> _showAddDialog(bool income) async {
    final ctrl = TextEditingController();
    final res = await showDialog<String?>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(income ? 'Add income category' : 'Add expense category'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Category name')),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(null), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(c).pop(ctrl.text.trim()), child: const Text('Add')),
        ],
      ),
    );
    if (res != null && res.isNotEmpty) await _addCategory(income, res);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
        drawer: AppDrawer(
          controller: widget.controller!,
    selectedIndex: 3, // Categories
  ),
  appBar: AppBar(
    title: const Text('Categories'),
  ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Income', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _income.map((name) => _categoryChip(name, true)).toList(),
              ),
              const SizedBox(height: 8),
              Row(children: [
                ElevatedButton.icon(onPressed: () => _showAddDialog(true), icon: const Icon(Icons.add), label: const Text('Add')),
              ]),
              const SizedBox(height: 24),

              const Text('Expense', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _expense.map((name) => _categoryChip(name, false)).toList(),
              ),
              const SizedBox(height: 8),
              Row(children: [
                ElevatedButton.icon(onPressed: () => _showAddDialog(false), icon: const Icon(Icons.add), label: const Text('Add')),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(String name, bool income) {
    final fav = _favorites.contains(name);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: fav ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: fav ? Border.all(color: AppColors.primary) : null,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(
  getCategoryDisplay(name),
  style: TextStyle(
    color: fav
        ? AppColors.primary
        : AppColors.onSurface,
  ),
),
        const SizedBox(width: 8),
        GestureDetector(onTap: () => _toggleFavorite(name), child: Icon(fav ? Icons.star : Icons.star_border, size: 18, color: fav ? AppColors.primary : AppColors.onSurfaceVariant)),
        const SizedBox(width: 6),
        GestureDetector(onTap: () => _removeCategory(income, name), child: const Icon(Icons.delete_outline, size: 18)),
      ]),
    );
  }
}
