import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../local/transaction_db.dart';
import '../models/transaction_model.dart';

class ImportResult {
  final int totalRows;
  final int validRows;
  final int invalidRows;
  final int duplicateRows;
  final int importedCount;
  final List<Map<String, dynamic>> invalidRecords;
  final List<Transaction> toImport;
  final Map<String, dynamic> analysis;

  ImportResult({
    required this.totalRows,
    required this.validRows,
    required this.invalidRows,
    required this.duplicateRows,
    required this.importedCount,
    required this.invalidRecords,
    required this.toImport,
    required this.analysis,
  });
}

class ImportService {
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Parse CSV content and return preview (does not write to DB).
  static Future<ImportResult> previewCsv(String content) async {
    final rows = const CsvToListConverter().convert(content);
    if (rows.isEmpty) {
      return ImportResult(
        totalRows: 0,
        validRows: 0,
        invalidRows: 0,
        duplicateRows: 0,
        importedCount: 0,
        invalidRecords: [],
        toImport: [],
        analysis: {},
      );
    }

    // If first row looks like header, drop it
    int start = 0;
    final first = rows.first.map((e) => e.toString().toLowerCase()).toList();
    if (first.contains('date') &&
        first.contains('time') &&
        first.contains('amount')) {
      start = 1;
    }

    final total = rows.length - start;

    final invalidRecords = <Map<String, dynamic>>[];
    final toImport = <Transaction>[];
    final existing = TransactionDB.getAll();

    for (int i = start; i < rows.length; i++) {
      final row = rows[i];
      try {
        if (row.length < 7) {
          invalidRecords.add({
            'row': i + 1,
            'reason': 'Insufficient columns',
            'data': row,
          });
          continue;
        }

        final dateStr = row[0].toString();
        final timeStr = row[1].toString();
        final note = row[2].toString();
        final amountStr = row[3].toString();
        final category = row[4].toString();
        final typeStr = row[5].toString().toLowerCase();
        final stateStr = row[6].toString().toLowerCase();

        if (category.trim().isEmpty) {
          invalidRecords.add({
            'row': i + 1,
            'reason': 'Empty category',
            'data': row,
          });
          continue;
        }

        final amount = double.tryParse(amountStr.replaceAll(',', ''));
        if (amount == null) {
          invalidRecords.add({
            'row': i + 1,
            'reason': 'Invalid amount',
            'data': row,
          });
          continue;
        }

        DateTime createdAt;
        try {
          createdAt = _dateTimeFormat.parseStrict('$dateStr $timeStr');
        } catch (e) {
          invalidRecords.add({
            'row': i + 1,
            'reason': 'Invalid date/time',
            'data': row,
          });
          continue;
        }

        TransactionType type;
        if (typeStr == 'income') {
          type = TransactionType.income;
        } else if (typeStr == 'expense') {
          type = TransactionType.expense;
        } else {
          invalidRecords.add({
            'row': i + 1,
            'reason': 'Invalid type',
            'data': row,
          });
          continue;
        }

        TransactionState state;
        if (stateStr == 'completed') {
          state = TransactionState.completed;
        } else if (stateStr == 'pending') {
          state = TransactionState.pending;
        } else if (stateStr == 'forfeited') {
          state = TransactionState.forfeited;
        } else {
          invalidRecords.add({
            'row': i + 1,
            'reason': 'Invalid state',
            'data': row,
          });
          continue;
        }

        // Duplicate detection
        final isDuplicate = existing.any((e) {
          return e.createdAt.millisecondsSinceEpoch ==
                  createdAt.millisecondsSinceEpoch &&
              e.amount == amount &&
              e.category == category &&
              e.note == note;
        });
        if (isDuplicate) {
          // skip duplicates in preview (counted later)
          continue;
        }

        // id generation: stable-ish
        final id =
            '${createdAt.millisecondsSinceEpoch}_${(Random().nextInt(99999))}';

        final tx = Transaction(
          id: id,
          amount: amount,
          type: type,
          note: note,
          category: category,
          createdAt: createdAt,
          state: state,
        );

        toImport.add(tx);
      } catch (e) {
        debugPrint('CSV parse row failed: $e');
        invalidRecords.add({
          'row': i + 1,
          'reason': 'Parse error',
          'data': row,
          'error': e.toString(),
        });
      }
    }

    // compute dup count by comparing all valid rows vs existing
    final duplicateRows = total - toImport.length - invalidRecords.length;
    final validRows = toImport.length;
    final invalidRows = invalidRecords.length;

    // analysis preview
    final analysis = _analyzeTransactions(toImport);

    return ImportResult(
      totalRows: total,
      validRows: validRows,
      invalidRows: invalidRows,
      duplicateRows: duplicateRows < 0 ? 0 : duplicateRows,
      importedCount: 0,
      invalidRecords: invalidRecords,
      toImport: toImport,
      analysis: analysis,
    );
  }

  /// Perform import: writes valid, non-duplicate transactions into Hive and optionally refreshes controller by calling [onImported]
  static Future<ImportResult> importTransactions(
    List<Transaction> transactions, {
    Function? onImported,
  }) async {
    final existing = TransactionDB.getAll();
    int imported = 0;
    for (final tx in transactions) {
      final isDuplicate = existing.any((e) {
        return e.createdAt.millisecondsSinceEpoch ==
                tx.createdAt.millisecondsSinceEpoch &&
            e.amount == tx.amount &&
            e.category == tx.category &&
            e.note == tx.note;
      });
      if (isDuplicate) continue;
      await TransactionDB.add(tx);
      imported++;
    }

    // Optionally notify controller to reload
    if (onImported != null) {
      try {
        onImported();
      } catch (_) {}
    }

    final analysis = _analyzeTransactions(transactions);

    return ImportResult(
      totalRows: transactions.length,
      validRows: transactions.length,
      invalidRows: 0,
      duplicateRows: transactions.length - imported,
      importedCount: imported,
      invalidRecords: [],
      toImport: transactions,
      analysis: analysis,
    );
  }

  static Map<String, dynamic> _analyzeTransactions(
    List<Transaction> transactions,
  ) {
    if (transactions.isEmpty) return {};

    double totalIncome = 0;
    double totalExpense = 0;
    final Map<String, double> expenseByCategory = {};
    Transaction? largest;
    DateTime? minDate;
    DateTime? maxDate;

    for (final t in transactions) {
      if (t.type == TransactionType.income) totalIncome += t.amount;
      if (t.type == TransactionType.expense) totalExpense += t.amount;

      if (t.type == TransactionType.expense) {
        expenseByCategory[t.category] =
            (expenseByCategory[t.category] ?? 0) + t.amount;
      }

      if (largest == null || t.amount > largest.amount) largest = t;

      if (minDate == null || t.createdAt.isBefore(minDate)){
        minDate = t.createdAt;
      }
      if (maxDate == null || t.createdAt.isAfter(maxDate)){
        maxDate = t.createdAt;
      }
    }

    String? topExpenseCategory;
    if (expenseByCategory.isNotEmpty) {
      topExpenseCategory = expenseByCategory.entries
          .toList()
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'topExpenseCategory': topExpenseCategory,
      'largestTransaction': largest,
      'dateRangeStart': minDate,
      'dateRangeEnd': maxDate,
    };
  }
}

class CsvToListConverter {
  final String eol;

  const CsvToListConverter({this.eol = '\n'});

  List<List<dynamic>> convert(String csv) {
    final rows = csv.split(eol);
    return rows.map((row) {
      // Simple split by comma, can be enhanced to handle quoted commas
      return row.split(',');
    }).toList();
  }
}
