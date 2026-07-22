import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_client.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _pendingConfirmationEmail;
  StreamSubscription? _authSub;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  /// Set right after sign-up when Supabase requires email confirmation
  /// before a session is issued (dashboard "Confirm email" setting).
  String? get pendingConfirmationEmail => _pendingConfirmationEmail;

  AuthProvider() {
    // Seed with current session (app cold-start)
    _user = SupabaseService.currentUser;

    // React to sign-in / sign-out events
    _authSub = SupabaseService.authStateChanges.listen((data) {
      _user = data.session?.user;
      if (_user != null) _pendingConfirmationEmail = null;
      notifyListeners();
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    _setLoading(true);
    try {
      await SupabaseService.signInWithEmail(email: email, password: password);
      _error = null;
    } on AuthException catch (e) {
      _error = _classifyAuthError(e);
    } catch (_) {
      _error = 'errorGeneric';
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
      final res = await SupabaseService.signUpWithEmail(
          email: email, password: password);
      _error = null;
      // No session yet → dashboard requires email confirmation first.
      if (res.session == null) _pendingConfirmationEmail = email;
    } on AuthException catch (e) {
      _error = _classifyAuthError(e);
    } catch (_) {
      _error = 'errorGeneric';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resendConfirmationEmail() async {
    final email = _pendingConfirmationEmail;
    if (email == null) return false;
    try {
      await SupabaseService.resendConfirmationEmail(email);
      return true;
    } catch (_) {
      return false;
    }
  }

  void cancelPendingConfirmation() {
    _pendingConfirmationEmail = null;
    notifyListeners();
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
      _error = _classifyAuthError(e);
    } catch (_) {
      _error = 'errorGeneric';
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
      _error = 'could_not_delete_account';
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
      _error = _classifyAuthError(e);
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'errorGeneric';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePhone({required String phone}) async {
    try {
      await SupabaseService.updatePhone(phone);
      return true;
    } on AuthException catch (e) {
      _error = _classifyAuthError(e);
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'errorGeneric';
      notifyListeners();
      return false;
    }
  }

  static String _classifyAuthError(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login') || msg.contains('invalid credentials') || msg.contains('wrong password')) {
      return 'invalid_credentials';
    }
    if (msg.contains('already registered') || msg.contains('already exists') || msg.contains('duplicate')) {
      return 'email_taken';
    }
    return 'errorGeneric';
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
