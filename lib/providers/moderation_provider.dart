import 'dart:async';

import 'package:flutter/material.dart';

import '../services/moderation_service.dart';
import '../services/supabase_client.dart';

/// Blocking & reporting state. Blocked users' matches are hidden from the
/// feed (MatchProvider receives the id set via ProxyProvider in main.dart).
class ModerationProvider extends ChangeNotifier {
  final _service = ModerationService();

  Set<String> _blockedIds = {};
  StreamSubscription? _authSub;

  ModerationProvider() {
    _load();
    _authSub = SupabaseService.authStateChanges.listen((data) {
      _blockedIds = {};
      notifyListeners();
      if (data.session?.user.id != null) _load();
    });
  }

  Set<String> get blockedIds => _blockedIds;
  bool isBlocked(String userId) => _blockedIds.contains(userId);

  Future<void> _load() async {
    try {
      _blockedIds = await _service.fetchBlockedIds();
      notifyListeners();
    } catch (_) {
      // Non-fatal: feed just shows everything until next load.
    }
  }

  Future<bool> blockUser(String userId) async {
    try {
      await _service.blockUser(userId);
      _blockedIds = {..._blockedIds, userId};
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unblockUser(String userId) async {
    try {
      await _service.unblockUser(userId);
      _blockedIds = {..._blockedIds}..remove(userId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> reportUser({
    required String reportedUserId,
    String? matchId,
    required String reason,
    String? details,
  }) async {
    try {
      await _service.reportUser(
        reportedUserId: reportedUserId,
        matchId: matchId,
        reason: reason,
        details: details,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
