import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../services/profile_service.dart';
import '../services/supabase_client.dart';

class ProfileProvider extends ChangeNotifier {
  final _service = ProfileService();

  Profile? _profile;
  bool _isLoading = false;
  bool _isUploadingAvatar = false;
  String? _error;
  StreamSubscription? _authSub;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isUploadingAvatar => _isUploadingAvatar;
  String? get error => _error;
  bool get isOnboarded => _profile?.onboarded ?? true;
  Map<String, dynamic> get availability => _profile?.availabilityJson ?? {};

  ProfileProvider() {
    // When the signed-in user changes, clear the cached profile and reload.
    _authSub = SupabaseService.authStateChanges.listen((data) {
      final newUserId = data.session?.user.id;
      if (newUserId != _profile?.id) {
        _profile = null;
        _error = null;
        if (newUserId != null) {
          _fetch(newUserId);
        } else {
          notifyListeners();
        }
      }
    });
  }

  /// Returns the list of time slots the user has marked available for [day].
  /// [day] is a lowercase weekday name: "monday", "tuesday", …, "sunday".
  List<String> slotsForDay(String day) =>
      List<String>.from(availability[day] as List? ?? []);

  bool isAvailable(String day, String slot) =>
      slotsForDay(day).contains(slot);

  /// Loads the current user's profile. No-ops if already loaded for this user.
  Future<void> loadProfile() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null || _profile?.id == userId) return;
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
      _error = 'could_not_load_profile';
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
      _error = 'could_not_save_availability';
      notifyListeners();
    }
  }

  /// Saves profile fields. Username is immutable and never changed here.
  /// [birthDate] and [gender] can be null to clear the value.
  Future<void> saveProfile({
    String? bio,
    required List<String> favoriteSports,
    DateTime? birthDate,
    String? gender,
    required bool showAge,
    required bool showGender,
  }) async {
    if (_profile == null) return;
    final current = _profile!;
    // Build directly to allow clearing nullable fields (birthDate, gender)
    final updated = Profile(
      id: current.id,
      username: current.username,
      bio: bio == null || bio.isEmpty ? null : bio,
      favoriteSports: favoriteSports,
      availabilityJson: current.availabilityJson,
      avatarUrl: current.avatarUrl,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
      onboarded: current.onboarded,
      birthDate: birthDate,
      gender: gender,
      showAge: showAge,
      showGender: showGender,
    );
    _profile = updated;
    notifyListeners();
    try {
      _profile = await _service.updateProfile(updated);
    } catch (_) {
      _profile = current; // revert optimistic update
      _error = 'could_not_save_profile';
    }
    notifyListeners();
  }

  /// Uploads a new avatar image and updates the profile's avatar_url.
  Future<void> saveAvatar(Uint8List bytes, String ext) async {
    if (_profile == null) return;
    _isUploadingAvatar = true;
    notifyListeners();
    try {
      final url = await _service.uploadAvatar(_profile!.id, bytes, ext);
      final updated = _profile!.copyWith(avatarUrl: url);
      _profile = await _service.updateProfile(updated);
      _error = null;
    } catch (_) {
      _error = 'could_not_upload_photo';
    }
    _isUploadingAvatar = false;
    notifyListeners();
  }

  Future<void> completeOnboarding({
    required String username,
    required List<String> favoriteSports,
    String? bio,
    DateTime? birthDate,
    String? gender,
    required DateTime acceptedTermsAt,
  }) async {
    if (_profile == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _service.completeOnboarding(
        userId: _profile!.id,
        username: username,
        favoriteSports: favoriteSports,
        bio: bio,
        birthDate: birthDate,
        gender: gender,
        acceptedTermsAt: acceptedTermsAt,
      );
    } catch (_) {
      _error = 'could_not_complete_setup';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveDefaultLocation({
    required String name,
    required double lat,
    required double lng,
  }) async {
    if (_profile == null) return;
    final current = _profile!;
    _profile = current.copyWith(
      defaultLocationName: name,
      defaultGeoLat: lat,
      defaultGeoLng: lng,
    );
    notifyListeners();
    try {
      _profile = await _service.updateProfile(_profile!);
    } catch (_) {
      _profile = current;
      _error = 'could_not_save_location';
    }
    notifyListeners();
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
