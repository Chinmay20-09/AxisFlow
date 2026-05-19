// lib/controller/transaction_controller.dart
import 'package:flutter/foundation.dart';
import '../data/services/analytics_service.dart';
import '../data/transaction_db.dart';
import '../data/transaction_model.dart';

class TransactionController extends ChangeNotifier {
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  void load() {
    _transactions = TransactionDB.getAll();
    notifyListeners();
  }

  Future<void> add(Transaction t) async {
    await TransactionDB.add(t);
    load();
  }

  Future<bool> update(Transaction t) async {
    if (!t.isEditable) return false;
    t.amount = t.amount;
    await TransactionDB.update(t);
    load();
    return true;
  }

  Future<bool> delete(String id) async {
    final t = _transactions.firstWhere(
      (e) => e.id == id,
      orElse: () => throw Exception('Not found'),
    );
    if (!t.isEditable) return false;
    await TransactionDB.delete(id);
    load();
    return true;
  }

  // Group by category
  Map<String, List<Transaction>> get byCategory {
    final map = <String, List<Transaction>>{};
    for (final t in _transactions) {
      map.putIfAbsent(t.category, () => []).add(t);
    }
    return map;
  }

  // Summary
  double get totalincome => _transactions
      .where(
        (t) =>
            t.type == TransactionType.income &&
            t.state == TransactionState.completed,
      )
      .fold(0.0, (s, t) => s + t.amount);
  double get totalexpense => _transactions
      .where(
        (t) =>
            t.type == TransactionType.expense &&
            t.state == TransactionState.completed,
      )
      .fold(0.0, (s, t) => s + t.amount);
  double get totalPending {
    return _transactions
        .where((t) => t.state == TransactionState.pending)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  List<Transaction> get completedTransactions => _transactions
      .where((t) => t.state == TransactionState.completed)
      .toList();
  List<Transaction> get pendingTransactions =>
      _transactions.where((t) => t.state == TransactionState.pending).toList();

  double get net => totalincome - totalexpense;

  // Daily data for chart (last 7 days)
  AnalyticsService get analytics => AnalyticsService(transactions: _transactions);

  List<Map<String, dynamic>> get weeklyData => analytics.weeklyData;
}
