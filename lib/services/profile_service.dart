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
}
