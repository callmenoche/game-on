import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';
import 'supabase_client.dart';

class ProfileService {
  static final _profiles = SupabaseService.table('profiles');

  Future<Profile> fetchProfile(String userId) async {
    final data = await _profiles.select().eq('id', userId).single();
    return Profile.fromJson(data);
  }

  Future<Profile> updateProfile(Profile profile) async {
    final data = await _profiles
        .update(profile.toJson())
        .eq('id', profile.id)
        .select()
        .single();
    return Profile.fromJson(data);
  }

  Future<void> updateAvailability(
    String userId,
    Map<String, dynamic> availability,
  ) async {
    await _profiles
        .update({'availability_json': availability})
        .eq('id', userId);
  }

  /// Uploads [bytes] to the "avatars" bucket at path {userId}/avatar.{ext}
  /// and returns the public URL.
  Future<String> uploadAvatar(
      String userId, Uint8List bytes, String ext) async {
    final path = '$userId/avatar.$ext';
    await SupabaseService.client.storage.from('avatars').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return SupabaseService.client.storage.from('avatars').getPublicUrl(path);
  }

  /// Returns up to 20 profiles whose username matches [query] (case-insensitive),
  /// excluding the currently signed-in user.
  Future<List<Profile>> searchPlayers(String query) async {
    final currentId = SupabaseService.currentUser?.id;
    final builder = _profiles
        .select()
        .ilike('username', '%$query%');
    // Apply filter before limit so we operate on PostgrestFilterBuilder
    final data = currentId != null
        ? await builder.neq('id', currentId).limit(20)
        : await builder.limit(20);
    return (data as List).map((e) => Profile.fromJson(e)).toList();
  }
}
