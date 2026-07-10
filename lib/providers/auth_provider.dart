import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_client.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _authSub;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Seed with current session (app cold-start)
    _user = SupabaseService.currentUser;

    // React to sign-in / sign-out events
    _authSub = SupabaseService.authStateChanges.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    _setLoading(true);
    try {
      await SupabaseService.signInWithEmail(email: email, password: password);
      _error = null;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await SupabaseService.signUpWithEmail(email: email, password: password);
      _error = null;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    await SupabaseService.signOut();
    _setLoading(false);
  }

  Future<void> resetPassword({required String email}) async {
    _setLoading(true);
    try {
      await SupabaseService.resetPasswordForEmail(email);
      _error = null;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount() async {
    _setLoading(true);
    try {
      await SupabaseService.deleteAccount();
      // Session may already be invalidated after account deletion
      try {
        await SupabaseService.signOut();
      } catch (_) {}
      _user = null;
      _error = null;
      _setLoading(false);
      return true;
    } catch (_) {
      _error = 'Failed to delete account. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  String? get phone => SupabaseService.currentUserPhone;

  Future<bool> changePassword({required String newPassword}) async {
    try {
      await SupabaseService.updatePassword(newPassword);
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePhone({required String phone}) async {
    try {
      await SupabaseService.updatePhone(phone);
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
