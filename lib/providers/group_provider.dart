import 'dart:async';

import 'package:flutter/material.dart';
import '../models/group.dart';
import '../services/group_service.dart';
import '../services/supabase_client.dart';

class GroupProvider extends ChangeNotifier {
  final _service = GroupService();

  List<Group> _groups = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _authSub;

  GroupProvider() {
    _authSub = SupabaseService.authStateChanges.listen((data) {
      final newUserId = data.session?.user.id;
      _groups = [];
      _error = null;
      notifyListeners();
      if (newUserId != null) fetchGroups();
    });
  }

  final Set<String> _pendingRequestGroupIds = {};

  List<Group> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get groupIds => _groups.map((g) => g.id).toList();
  bool isMember(String groupId) => _groups.any((g) => g.id == groupId);
  bool hasPendingRequest(String groupId) =>
      _pendingRequestGroupIds.contains(groupId);

  Future<void> fetchGroups() async {
    _isLoading = true;
    notifyListeners();
    try {
      _groups = await _service.fetchMyGroups();
      _pendingRequestGroupIds
        ..clear()
        ..addAll(await _service.fetchMyPendingRequestGroupIds());
      _error = null;
    } catch (_) {
      _error = 'could_not_load_groups';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Group?> createGroup(String name, String? description,
      {GroupVisibility visibility = GroupVisibility.private}) async {
    try {
      final group = await _service.createGroup(
          name: name, description: description, visibility: visibility);
      _groups.insert(0, group);
      notifyListeners();
      return group;
    } catch (_) {
      _error = 'could_not_create_group';
      notifyListeners();
      return null;
    }
  }

  /// Instant join of a public group (from search results).
  Future<bool> joinPublicGroup(Group group) async {
    try {
      await _service.joinPublicGroup(group.id);
      if (!_groups.any((g) => g.id == group.id)) {
        _groups.insert(0, group);
      }
      notifyListeners();
      return true;
    } catch (_) {
      _error = 'could_not_join_group';
      notifyListeners();
      return false;
    }
  }

  /// Membership request for an invite-only group.
  Future<bool> requestToJoin(Group group) async {
    try {
      await _service.requestToJoin(group.id);
      _pendingRequestGroupIds.add(group.id);
      notifyListeners();
      return true;
    } catch (_) {
      _error = 'could_not_join_group';
      notifyListeners();
      return false;
    }
  }

  Future<Group?> joinByCode(String code) async {
    try {
      final group = await _service.joinByCode(code);
      if (group == null) {
        _error = 'invalid_invite_code';
        notifyListeners();
        return null;
      }
      if (!_groups.any((g) => g.id == group.id)) {
        _groups.add(group);
        notifyListeners();
      }
      return group;
    } catch (_) {
      _error = 'could_not_join_group';
      notifyListeners();
      return null;
    }
  }

  Future<void> leaveGroup(String groupId) async {
    try {
      await _service.leaveGroup(groupId);
      _groups.removeWhere((g) => g.id == groupId);
      notifyListeners();
    } catch (_) {
      _error = 'could_not_leave_group';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
