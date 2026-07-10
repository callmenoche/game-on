import '../models/sponsored_post.dart';
import 'supabase_client.dart';

class SponsoredPostService {
  static final _posts = SupabaseService.table('sponsored_posts');

  /// Currently running posts (RLS already filters on active + dates).
  Future<List<SponsoredPost>> fetchActive() async {
    final data =
        await _posts.select().order('created_at', ascending: false).limit(10);
    return (data as List).map((e) => SponsoredPost.fromJson(e)).toList();
  }
}
