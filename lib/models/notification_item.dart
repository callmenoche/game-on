import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String userId;
  final String type;
  final String? matchId;
  final String? actorId;
  final String body;
  final DateTime? readAt;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.userId,
    required this.type,
    this.matchId,
    this.actorId,
    required this.body,
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  IconData get icon => switch (type) {
        'match_joined'    => Icons.person_add_rounded,
        'match_confirmed' => Icons.check_circle_rounded,
        'match_cancelled' => Icons.cancel_rounded,
        _                 => Icons.notifications_rounded,
      };

  Color get color => switch (type) {
        'match_joined'    => const Color(0xFF42A5F5),
        'match_confirmed' => const Color(0xFF4CAF50),
        'match_cancelled' => Colors.redAccent,
        _                 => const Color(0xFFFFB300),
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id:        json['id'] as String,
        userId:    json['user_id'] as String,
        type:      json['type'] as String,
        matchId:   json['match_id'] as String?,
        actorId:   json['actor_id'] as String?,
        body:      json['body'] as String,
        readAt:    json['read_at'] == null
            ? null
            : DateTime.parse(json['read_at'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  NotificationItem copyWith({DateTime? readAt}) => NotificationItem(
        id:        id,
        userId:    userId,
        type:      type,
        matchId:   matchId,
        actorId:   actorId,
        body:      body,
        readAt:    readAt ?? this.readAt,
        createdAt: createdAt,
      );
}
