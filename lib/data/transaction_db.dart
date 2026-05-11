// lib/data/transaction_db.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'transaction_model.dart';

class TransactionDB {
  static const String _boxName = 'transactions';
  static Box<Transaction>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(TransactionAdapter());
    _box = await Hive.openBox<Transaction>(_boxName);
  }

  static Box<Transaction> get box {
    if (_box == null) throw Exception('TransactionDB not initialized');
    return _box!;
  }

  static Future<void> add(Transaction t) async {
    await box.put(t.id, t);
  }

  static Future<void> update(Transaction t) async {
    await box.put(t.id, t);
  }

  static Future<void> delete(String id) async {
    await box.delete(id);
  }

  static List<Transaction> getAll() {
    return box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
