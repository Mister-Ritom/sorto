// lib/features/notifications/notifications_provider.dart
import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/supabase_service.dart';
import '../../shared/models/notification_model.dart';

// ─── NOTIFICATIONS STREAM ─────────────────────────────────────────────────────
final notificationsStreamProvider =
    StreamProvider<List<SortoNotification>>((ref) {
  final svc = ref.read(supabaseServiceProvider);
  final userId = svc.currentUserId;
  if (userId == null) return Stream.value([]);
  return svc.watchNotifications(userId);
});

// ─── UNREAD COUNT ─────────────────────────────────────────────────────────────
final unreadCountProvider = Provider<int>((ref) {
  final notifs = ref.watch(notificationsStreamProvider).value ?? [];
  return notifs.where((n) => !n.isRead).length;
});

// ─── MARK READ ────────────────────────────────────────────────────────────────
class NotificationsNotifier extends Notifier<void> {
  @override
  void build() {}

  SupabaseService get _svc => ref.read(supabaseServiceProvider);

  Future<void> markRead(String notificationId) async {
    try {
      await _svc.markNotificationRead(notificationId);
    } catch (e, st) {
      dev.log('Error marking notification as read',
          error: e, stackTrace: st, name: 'NotificationsNotifier');
    }
  }

  Future<void> markAllRead() async {
    final userId = _svc.currentUserId;
    if (userId == null) return;
    try {
      await _svc.markAllNotificationsRead(userId);
    } catch (e, st) {
      dev.log('Error marking all notifications as read',
          error: e, stackTrace: st, name: 'NotificationsNotifier');
    }
  }
}

final notificationsNotifierProvider =
    NotifierProvider<NotificationsNotifier, void>(NotificationsNotifier.new);
