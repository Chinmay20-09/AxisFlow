// lib/controller/transaction_controller.dart
// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import '../data/services/analytics_service.dart';
import '../data/local/transaction_db.dart';
import '../data/models/transaction_model.dart';
import '../automation/sms/services/sms_sync_service.dart';

class TransactionController extends ChangeNotifier {
  List<Transaction> _transactions = [];

  /// Shared SMS sync service used for auto-sync and pull-to-refresh.
  final SmsSyncService smsSyncService = SmsSyncService();

  // Filter / search state
  String _searchQuery = '';
  TransactionType? _typeFilter;
  TransactionState? _stateFilter;
  DateTime? _fromDate;
  DateTime? _toDate;

  List<Transaction> get transactions => _transactions;

  void load() {
    print('[TRACE] TransactionController.load() — fetching from Hive...');
    _transactions = TransactionDB.getAll();
    print('[TRACE] TransactionController.load() — loaded ${_transactions.length} transactions');
    notifyListeners();
    print('[TRACE] TransactionController.load() — notified listeners');
  }

  Future<void> add(Transaction t) async {
    print('[TRACE] TransactionController.add(${t.id})...');
    await TransactionDB.add(t);
    load();
  }

  Future<bool> update(Transaction t) async {
    if (!t.isEditable) return false;
    await TransactionDB.update(t);
    load();
    return true;
  }

  Future<bool> delete(String id) async {
    if (!_transactions.any((e) => e.id == id)) throw Exception('Not found');
    await TransactionDB.delete(id);
    load();
    return true;
  }

  // --- Filtering API ---
  void setSearchQuery(String q) {
    _searchQuery = q.trim().toLowerCase();
    notifyListeners();
  }

  void setTypeFilter(TransactionType? type) {
    _typeFilter = type;
    notifyListeners();
  }

  void setStateFilter(TransactionState? state) {
    _stateFilter = state;
    notifyListeners();
  }

  void setDateRange(DateTime? from, DateTime? to) {
    _fromDate = from;
    _toDate = to;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _typeFilter = null;
    _stateFilter = null;
    _fromDate = null;
    _toDate = null;
    notifyListeners();
  }

  // Helper: apply quick chip semantics (matches UI chips)
  void setChipSelected(int i) {
    // 0 All, 1 Income, 2 Expenses, 3 Today, 4 Yesterday, 5 This Week
    final now = DateTime.now();
    switch (i) {
      case 1:
        setTypeFilter(TransactionType.income);
        setDateRange(null, null);
        break;
      case 2:
        setTypeFilter(TransactionType.expense);
        setDateRange(null, null);
        break;
      case 3: // Today
        setTypeFilter(null);
        setDateRange(
          DateTime(now.year, now.month, now.day),
          DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
        break;
      case 4: // Yesterday
        final yesterday = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 1));
        setTypeFilter(null);
        setDateRange(
          DateTime(yesterday.year, yesterday.month, yesterday.day),
          DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
        );
        break;
      case 5: // This week (last 7 days)
        setTypeFilter(null);
        setDateRange(now.subtract(const Duration(days: 7)), now);
        break;
      default:
        clearFilters();
        break;
    }
  }

  // Returns transactions after applying active filters and search
  List<Transaction> get filteredTransactions {
    var filtered = List<Transaction>.from(_transactions);

    if (_typeFilter != null) {
      filtered = filtered.where((t) => t.type == _typeFilter).toList();
    }

    if (_stateFilter != null) {
      filtered = filtered.where((t) => t.state == _stateFilter).toList();
    }

    if (_fromDate != null) {
      filtered = filtered
          .where((t) => !t.createdAt.isBefore(_fromDate!))
          .toList();
    }
    if (_toDate != null) {
      filtered = filtered.where((t) => !t.createdAt.isAfter(_toDate!)).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        final note = t.note.toLowerCase();
        final cat = t.category.toLowerCase();
        final amt = t.amount.toString();
        return note.contains(_searchQuery) ||
            cat.contains(_searchQuery) ||
            amt.contains(_searchQuery);
      }).toList();
    }

    // Keep original ordering (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
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
  AnalyticsService get analytics =>
      AnalyticsService(transactions: _transactions);

  List<Map<String, dynamic>> get weeklyData => analytics.weeklyData;
}
