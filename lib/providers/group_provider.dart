import 'package:flutter/material.dart';
import '../models/group.dart';
import '../services/group_service.dart';
import '../services/supabase_client.dart';

class GroupProvider extends ChangeNotifier {
  final _service = GroupService();

  List<Group> _groups = [];
  bool _isLoading = false;
  String? _error;

  GroupProvider() {
    SupabaseService.authStateChanges.listen((data) {
      final newUserId = data.session?.user.id;
      _groups = [];
      _error = null;
      notifyListeners();
      if (newUserId != null) fetchGroups();
    });
  }

  List<Group> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get groupIds => _groups.map((g) => g.id).toList();

  Future<void> fetchGroups() async {
    _isLoading = true;
    notifyListeners();
    try {
      _groups = await _service.fetchMyGroups();
      _error = null;
    } catch (_) {
      _error = 'Failed to load groups.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Group?> createGroup(String name, String? description) async {
    try {
      final group = await _service.createGroup(name: name, description: description);
      _groups.insert(0, group);
      notifyListeners();
      return group;
    } catch (_) {
      _error = 'Could not create group.';
      notifyListeners();
      return null;
    }
  }

  Future<Group?> joinByCode(String code) async {
    try {
      final group = await _service.joinByCode(code);
      if (group == null) {
        _error = 'Invalid invite code.';
        notifyListeners();
        return null;
      }
      if (!_groups.any((g) => g.id == group.id)) {
        _groups.add(group);
        notifyListeners();
      }
      return group;
    } catch (_) {
      _error = 'Could not join group.';
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
      _error = 'Could not leave group.';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
