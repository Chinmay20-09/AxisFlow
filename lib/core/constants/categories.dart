// lib/core/constants/categories.dart

class CategoryItem {
  final String name;
  final String icon;

  const CategoryItem({required this.name, required this.icon});

  @override
  String toString() => name;
}

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

final List<CategoryItem> _allCategories = List<CategoryItem>.from(
  incomeCategories,
)..addAll(expenseCategories);

String getCategoryIcon(String categoryName) {
  final item = _allCategories.firstWhere(
    (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
    orElse: () => CategoryItem(name: categoryName, icon: ''),
  );
  return item.icon;
}

String getCategoryDisplay(String categoryName) {
  final icon = getCategoryIcon(categoryName);
  return icon.isEmpty ? categoryName : '$categoryName $icon';
}
