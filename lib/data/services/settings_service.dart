import 'package:flutter/material.dart';
import 'package:axisflow/data/local/settings_db.dart';
import 'package:axisflow/core/theme/app_colors.dart';

/// Centralised settings service. Reads/writes to SettingsDB and exposes
/// values via ChangeNotifier so UI can react immediately.
class SettingsService extends ChangeNotifier {
  SettingsService._private();
  static final SettingsService instance = SettingsService._private();

  // Keys
  static const _kDarkMode = 'appearance.darkMode';
  static const _kAccentIndex = 'appearance.accentIndex';
  static const _kCurrency = 'finance.currency';
  static const _kFirstDay = 'finance.firstDay';
  static const _kOnboarding = 'app.onboardingComplete';

  // Defaults
  bool _darkMode = true;
  int _accentIndex = 0;
  String _currency = 'INR (₹)';
  String _firstDay = '1st';
  bool _onboardingComplete = false;

  /// Initialize service and load persisted values. Safe to call multiple times.
  Future<void> init() async {
    await SettingsDB.init();

    try {
      _darkMode = SettingsDB.get<bool>(_kDarkMode, _darkMode) ?? _darkMode;
      _accentIndex =
          SettingsDB.get<int>(_kAccentIndex, _accentIndex) ?? _accentIndex;
      _currency = SettingsDB.get<String>(_kCurrency, _currency) ?? _currency;
      _firstDay = SettingsDB.get<String>(_kFirstDay, _firstDay) ?? _firstDay;
      _onboardingComplete =
          SettingsDB.get<bool>(_kOnboarding, _onboardingComplete) ??
          _onboardingComplete;
    } catch (_) {
      // Fall back to defaults on any error
    }

    notifyListeners();
  }

  // Getters
  bool get darkMode => _darkMode;
  int get accentIndex => _accentIndex;
  String get currency => _currency;
  String get firstDay => _firstDay;
  bool get onboardingComplete => _onboardingComplete;

  Color get accentColor {
    const accents = [
      AppColors.accentGreen,
      AppColors.accentBlue,
      AppColors.accentPurple,
      AppColors.accentAmber,
    ];
    final idx = _accentIndex.clamp(0, accents.length - 1);
    return accents[idx];
  }

  // Setters - persist immediately and notify listeners
  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    try {
      await SettingsDB.set<bool>(_kDarkMode, value);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setAccentIndex(int index) async {
    _accentIndex = index;
    try {
      await SettingsDB.set<int>(_kAccentIndex, index);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setCurrency(String value) async {
    _currency = value;
    try {
      await SettingsDB.set<String>(_kCurrency, value);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setFirstDay(String value) async {
    _firstDay = value;
    try {
      await SettingsDB.set<String>(_kFirstDay, value);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setOnboardingComplete(bool value) async {
    _onboardingComplete = value;
    try {
      await SettingsDB.set<bool>(_kOnboarding, value);
    } catch (_) {}
    notifyListeners();
  }
}
