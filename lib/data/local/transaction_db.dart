// lib/data/transaction_db.dart
// ignore_for_file: avoid_print

import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';

class TransactionDB {
  static const String _boxName = 'transactions';
  static Box<Transaction>? _box;

  static Future<void> init() async {
    print('[TRACE] TransactionDB.init() — starting');
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(TransactionStateAdapter());
    print('[TRACE] TransactionDB.init() — adapters registered');
    _box = await Hive.openBox<Transaction>(_boxName);
    print('[TRACE] TransactionDB.init() — box opened: ${_box?.length ?? 0} existing items');
  }

  static Box<Transaction> get box {
    if (_box == null) throw Exception('TransactionDB not initialized');
    return _box!;
  }

  static Future<void> add(Transaction t) async {
    print('[TRACE] TransactionDB.add(${t.id}) — amount=${t.amount}, type=${t.type}');
    print('[TRACE]   box._box is null? ${_box == null}');
    final b = _box;
    if (b == null) {
      print('[TRACE] TransactionDB.add(${t.id}) — _box is NULL, THROWING!');
      throw Exception('TransactionDB not initialized');
    }
    await b.put(t.id, t);
    print('[TRACE] TransactionDB.add(${t.id}) — box.put() succeeded');
    // Verify immediately
    final readBack = b.get(t.id);
    print('[TRACE] TransactionDB.add(${t.id}) — readBack null? ${readBack == null}');
  }

  static Transaction? get(String id) => _box?.get(id);

  static Future<void> update(Transaction t) async {
    await box.put(t.id, t);
  }

  static Future<void> delete(String id) async {
    await box.delete(id);
  }

  static List<Transaction> getAll() {
    print('[TRACE] TransactionDB.getAll() — _box is null? ${_box == null}');
    // Preserve original throw behavior (just add trace before it)
    final b = _box;
    if (b == null) {
      print('[TRACE] TransactionDB.getAll() — _box is NULL, will throw');
      throw Exception('TransactionDB not initialized');
    }
    final items = b.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    print('[TRACE] TransactionDB.getAll() — returning ${items.length} items');
    return items;
  }
}
