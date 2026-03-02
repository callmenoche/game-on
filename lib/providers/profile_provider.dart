import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';
import '../services/supabase_client.dart';

class ProfileProvider extends ChangeNotifier {
  final _service = ProfileService();

  Profile? _profile;
  bool _isLoading = false;
  String? _error;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get availability => _profile?.availabilityJson ?? {};

  /// Returns the list of time slots the user has marked available for [day].
  /// [day] is a lowercase weekday name: "monday", "tuesday", …, "sunday".
  List<String> slotsForDay(String day) =>
      List<String>.from(availability[day] as List? ?? []);

  bool isAvailable(String day, String slot) =>
      slotsForDay(day).contains(slot);

  /// Loads the current user's profile. No-ops if already loaded.
  Future<void> loadProfile() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null || _profile != null) return;
    await _fetch(userId);
  }

  /// Force-refreshes the profile from the DB.
  Future<void> reload() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;
    await _fetch(userId);
  }

  Future<void> _fetch(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _service.fetchProfile(userId);
      _error = null;
    } catch (_) {
      _error = 'Failed to load profile.';
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Toggles a single time slot on/off and persists immediately.
  Future<void> toggleSlot(String day, String slot) async {
    if (_profile == null) return;
    final updated = Map<String, dynamic>.from(availability);
    final slots = List<String>.from(updated[day] as List? ?? []);
    if (slots.contains(slot)) {
      slots.remove(slot);
    } else {
      slots.add(slot);
    }
    updated[day] = slots;
    // Optimistic update
    _profile = _profile!.copyWith(availabilityJson: updated);
    notifyListeners();
    try {
      await _service.updateAvailability(_profile!.id, updated);
    } catch (_) {
      _error = 'Failed to save availability.';
      notifyListeners();
    }
  }

  /// Saves username, bio, and favoriteSports. Optimistic + persists.
  Future<void> saveProfile({
    required String username,
    String? bio,
    required List<String> favoriteSports,
  }) async {
    if (_profile == null) return;
    final updated = _profile!.copyWith(
      username: username,
      bio: bio?.isEmpty == true ? null : bio,
      favoriteSports: favoriteSports,
    );
    _profile = updated;
    notifyListeners();
    try {
      _profile = await _service.updateProfile(updated);
    } catch (_) {
      _error = 'Failed to save profile.';
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
