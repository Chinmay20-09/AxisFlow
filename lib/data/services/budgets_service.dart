import 'package:axisflow/data/local/settings_db.dart';
import 'package:axisflow/ui/screens/budgets/budget_models.dart';

class BudgetService {
  static const _incomeKey = 'budget.monthlyIncome';
  static const _allocationsKey = 'budget.allocations';

  static Future<void> save({
    required double monthlyIncome,
    required List<CategoryBudget> categories,
  }) async {
    await SettingsDB.set<double>(_incomeKey, monthlyIncome);

    await SettingsDB.set<Map<String, double>>(_allocationsKey, {
      for (final c in categories) c.id: c.percent,
    });
  }

  static double getMonthlyIncome() {
    return SettingsDB.get<double>(_incomeKey, 0) ?? 0;
  }

  static Map<String, double> getAllocations() {
    final raw = SettingsDB.get<Map>(_allocationsKey, {});

    return Map<String, double>.from(
      raw?.map((k, v) => MapEntry(k.toString(), (v as num).toDouble())) ?? {},
    );
  }

  static Future<void> reset() async {
    await SettingsDB.remove(_incomeKey);
    await SettingsDB.remove(_allocationsKey);
  }
}
