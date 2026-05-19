import '../transaction_model.dart';

class AnalyticsService {
  final List<Transaction> transactions;

  AnalyticsService({required this.transactions});

  List<Transaction> get completedTransactions => transactions
      .where((t) => t.state == TransactionState.completed)
      .toList();

  List<Transaction> get completedIncome => completedTransactions
      .where((t) => t.type == TransactionType.income)
      .toList();

  List<Transaction> get completedExpenses => completedTransactions
      .where((t) => t.type == TransactionType.expense)
      .toList();

  double get totalIncome =>
      completedIncome.fold(0.0, (sum, transaction) => sum + transaction.amount);

  double get totalExpense => completedExpenses.fold(
      0.0, (sum, transaction) => sum + transaction.amount);

  double get netCashFlow => totalIncome - totalExpense;

  double get totalPending => transactions
      .where((t) => t.state == TransactionState.pending)
      .fold(0.0, (sum, transaction) => sum + transaction.amount);

  double get yearToDateIncome {
    final now = DateTime.now();
    return completedIncome
        .where((transaction) => transaction.createdAt.year == now.year)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get yearToDateExpense {
    final now = DateTime.now();
    return completedExpenses
        .where((transaction) => transaction.createdAt.year == now.year)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get yearToDateSavings => yearToDateIncome - yearToDateExpense;

  double get savingsRate {
    if (yearToDateIncome <= 0) return 0;
    return (yearToDateSavings / yearToDateIncome) * 100;
  }

  double get currentMonthExpense {
    final now = DateTime.now();
    return completedExpenses
        .where((transaction) =>
            transaction.createdAt.year == now.year &&
            transaction.createdAt.month == now.month)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get previousMonthExpense {
    final now = DateTime.now();
    final previousMonth = DateTime(now.year, now.month - 1);
    return completedExpenses
        .where((transaction) =>
            transaction.createdAt.year == previousMonth.year &&
            transaction.createdAt.month == previousMonth.month)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get monthOverMonthChange {
    if (previousMonthExpense == 0) return 0;
    return ((currentMonthExpense - previousMonthExpense) / previousMonthExpense) * 100;
  }

  double get averageDailyExpense {
    final dailyExpense = weeklyData
        .map((data) => data['expense'] as double)
        .fold(0.0, (sum, value) => sum + value);
    return weeklyData.isEmpty ? 0 : dailyExpense / weeklyData.length;
  }

  double get todayNetFlow {
    final now = DateTime.now();
    return completedTransactions.fold(0.0, (sum, transaction) {
      if (!_isSameDay(transaction.createdAt, now)) return sum;
      return transaction.type == TransactionType.income
          ? sum + transaction.amount
          : sum - transaction.amount;
    });
  }

  String get todayNetLabel {
    if (todayNetFlow > 0) return 'Inflow today';
    if (todayNetFlow < 0) return 'Outflow today';
    return 'No activity today';
  }

  String get summaryInsight {
    if (yearToDateSavings > 0) {
      return 'Nice work — you have saved ₹${yearToDateSavings.toStringAsFixed(0)} so far this year.';
    }

    if (currentMonthExpense > totalIncome) {
      return 'This month has more expenses than income. Review your top categories to balance spending.';
    }

    return 'Expenses are steady. Keep tracking your transactions for a clearer view of your cash flow.';
  }

  String get behaviorInsight {
    final weekendExpenses = completedExpenses.where((transaction) {
      final weekday = transaction.createdAt.weekday;
      return weekday == DateTime.saturday || weekday == DateTime.sunday;
    }).fold(0.0, (sum, transaction) => sum + transaction.amount);

    final weekdayExpenses = completedExpenses.where((transaction) {
      final weekday = transaction.createdAt.weekday;
      return weekday >= DateTime.monday && weekday <= DateTime.friday;
    }).fold(0.0, (sum, transaction) => sum + transaction.amount);

    if (weekdayExpenses == 0 || weekendExpenses == 0) {
      return 'Your spending pattern is stable across the week.';
    }

    final ratio = weekendExpenses / weekdayExpenses;
    if (ratio > 1.1) {
      return 'Weekend spending is ${(ratio * 100).toStringAsFixed(0)}% higher than weekdays.';
    }

    return 'Weekday spending is lower than weekend spending, which is a healthy balance.';
  }

  List<Map<String, dynamic>> get weeklyData {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (index) {
      final day = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day + index,
      );

      final dayTransactions = completedTransactions.where((transaction) {
        return transaction.createdAt.year == day.year &&
            transaction.createdAt.month == day.month &&
            transaction.createdAt.day == day.day;
      });

      final income = dayTransactions
          .where((transaction) => transaction.type == TransactionType.income)
          .fold(0.0, (sum, transaction) => sum + transaction.amount);

      final expense = dayTransactions
          .where((transaction) => transaction.type == TransactionType.expense)
          .fold(0.0, (sum, transaction) => sum + transaction.amount);

      return {
        'day': day,
        'income': income,
        'expense': expense,
      };
    });
  }

  List<CategoryAllocation> get topExpenseCategories {
    final totals = <String, double>{};

    for (final transaction in completedExpenses) {
      totals[transaction.category] =
          (totals[transaction.category] ?? 0) + transaction.amount;
    }

    final sorted = totals.entries
        .map((entry) => CategoryAllocation(
              category: entry.key,
              total: entry.value,
              share: 0,
            ))
        .toList();

    final expenseTotal = totalExpense;
    for (final allocation in sorted) {
      allocation.share = expenseTotal > 0 ? allocation.total / expenseTotal : 0;
    }

    sorted.sort((a, b) => b.total.compareTo(a.total));
    return sorted;
  }

  List<Transaction> get recentTransactions {
    return transactions.take(3).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class CategoryAllocation {
  final String category;
  final double total;
  double share;

  CategoryAllocation({
    required this.category,
    required this.total,
    required this.share,
  });
}
