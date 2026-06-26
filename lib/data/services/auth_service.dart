import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// AuthService wraps Supabase auth calls and exposes a simple API for the app.
class AuthService extends ChangeNotifier {
  AuthService._private();
  static final AuthService instance = AuthService._private();

  final _client = Supabase.instance.client;

  User? _user;

  User? get currentUser => _user ?? _client.auth.currentUser;

  bool get isAuthenticated => currentUser != null;

  Stream<User?> get authStateChanges {
    // Map Supabase auth state changes to a stream of User?
    return _client.auth.onAuthStateChange.map((event) {
      final session = event.session;
      _user = session?.user ?? _client.auth.currentUser;
      notifyListeners();
      return _user;
    });
  }

  StreamSubscription<AuthState>? _authSub;

  Future<void> init() async {
    _user = _client.auth.currentUser;

    _authSub ??= _client.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  /// Returns null on success, otherwise an error message.
  Future<String?> signUp(String email, String password, String name) async {
    try {
      // Newer Supabase API uses signUpWithPassword or signUp depending on SDK.
      // Try signUp first, fall back gracefully.
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      // If a session is returned, set user
      _user = res.user ?? _client.auth.currentUser;
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
  debugPrint('SIGNUP ERROR: $e');
  return e.toString();
}
  }

  Future<String?> signIn(String email, String password) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      _user = res.user ?? _client.auth.currentUser;
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Unable to sign in. Please check your credentials and try again.';
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      // The API may simply send the email; treat as success
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Failed to send reset link. Please check your network and try again.';
    }
  }

  Future<String?> signOut() async {
    try {
      await _client.auth.signOut();
      _user = null;
      notifyListeners();
      return null;
    } catch (e) {
      return 'Failed to sign out. Please try again.';
    }
  }
}
