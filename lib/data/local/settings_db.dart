import 'package:hive_flutter/hive_flutter.dart';

class SettingsDB {
  static const _boxName = 'settings';
  static Box<dynamic>? _box;

  static Future<void> init() async {
    // Ensure Hive is initialized (harmless if already initialized)
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  static Box<dynamic> get box {
    if (_box == null) throw Exception('SettingsDB not initialized');
    return _box!;
  }

  static T? get<T>(String key, [T? defaultValue]) {
    if (_box == null) throw Exception('SettingsDB not initialized');
    final v = box.get(key);
    if (v == null) return defaultValue;
    return v as T;
  }

  static Future<void> set<T>(String key, T value) async {
    await box.put(key, value);
  }

  static Future<void> remove(String key) async {
    await box.delete(key);
  }

  static Map<String, dynamic> getAll() {
    return Map<String, dynamic>.from(box.toMap());
  }
}
