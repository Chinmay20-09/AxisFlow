// lib/data/transaction_model.dart
import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
  @HiveField(2)
  pending,
}

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  TransactionType type;

  @HiveField(3)
  String note;

  @HiveField(4)
  String category;

  @HiveField(5)
  DateTime createdAt;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.note,
    required this.category,
    required this.createdAt,
  });

  bool get isEditable {
    return DateTime.now().difference(createdAt).inMinutes < 60;
  }

  String get typeLabel {
    switch (type) {
      case TransactionType.income:
        return 'income';
      case TransactionType.expense:
        return 'expense';
      case TransactionType.pending:
        return 'Pending';
    }
  }

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  bool get isPending => type == TransactionType.pending;
}
