import '../models/notification_item.dart';
import 'supabase_client.dart';

class NotificationService {
  static final _table = SupabaseService.table('notifications');

  Stream<List<NotificationItem>> watch() {
    final userId = SupabaseService.currentUser!.id;
    return SupabaseService.client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(NotificationItem.fromJson).toList());
  }

  Future<void> markRead(String id) async {
    await _table
        .update({'read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id);
  }

  Future<void> markAllRead(String userId) async {
    await _table
        .update({'read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('user_id', userId)
        .isFilter('read_at', null);
  }
}
