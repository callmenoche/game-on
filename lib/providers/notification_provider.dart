import 'dart:async';
import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../services/notification_service.dart';
import '../services/supabase_client.dart';

class NotificationProvider extends ChangeNotifier {
  final _service = NotificationService();

  List<NotificationItem> _items = [];
  StreamSubscription<List<NotificationItem>>? _sub;

  List<NotificationItem> get items => _items;
  int get unreadCount => _items.where((n) => !n.isRead).length;

  /// Start listening. Safe to call multiple times (cancels previous sub).
  void start() {
    if (SupabaseService.currentUser == null) return;
    _sub?.cancel();
    _sub = _service.watch().listen((items) {
      _items = items;
      notifyListeners();
    });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    _items = [];
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx != -1 && !_items[idx].isRead) {
      _items[idx] = _items[idx].copyWith(readAt: DateTime.now());
      notifyListeners();
      await _service.markRead(id);
    }
  }

  Future<void> markAllRead() async {
    _items = _items.map((n) => n.copyWith(readAt: DateTime.now())).toList();
    notifyListeners();
    final userId = SupabaseService.currentUser?.id;
    if (userId != null) await _service.markAllRead(userId);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
