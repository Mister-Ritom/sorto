// lib/shared/models/notification_model.dart

class SortoNotification {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final String? dareId;
  final bool isRead;
  final DateTime createdAt;

  const SortoNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.dareId,
    required this.isRead,
    required this.createdAt,
  });

  factory SortoNotification.fromJson(Map<String, dynamic> json) =>
      SortoNotification(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        dareId: json['dare_id'] as String?,
        isRead: json['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  SortoNotification markRead() => SortoNotification(
        id: id,
        userId: userId,
        type: type,
        title: title,
        body: body,
        dareId: dareId,
        isRead: true,
        createdAt: createdAt,
      );

  String get icon {
    switch (type) {
      case 'dare_claimed':
        return '🎯';
      case 'proof_submitted':
        return '📹';
      case 'dare_approved':
        return '✅';
      case 'dare_rejected':
        return '❌';
      case 'dare_settled':
        return '💰';
      case 'withdrawal_complete':
        return '🏦';
      case 'post_funded':
        return '🚀';
      case 'new_dare_match':
        return '⚡';
      default:
        return '🔔';
    }
  }

  /// Alias for [icon] — use in UI components
  String get typeIcon => icon;
}
