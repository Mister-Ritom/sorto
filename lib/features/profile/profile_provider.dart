// lib/features/profile/profile_provider.dart
import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/supabase_service.dart';
import '../../shared/models/profile.dart';
import '../../shared/models/dare.dart';
import '../../shared/models/performer_post.dart';

// ─── OWN PROFILE ──────────────────────────────────────────────────────────────
final ownProfileProvider = FutureProvider<Profile?>((ref) async {
  final svc = ref.read(supabaseServiceProvider);
  final userId = svc.currentUserId;
  if (userId == null) return null;
  return svc.getProfile(userId);
});

// ─── PUBLIC PROFILE (by username) ────────────────────────────────────────────
final publicProfileProvider =
    FutureProvider.family<Profile?, String>((ref, username) async {
  return ref.read(supabaseServiceProvider).getProfileByUsername(username);
});

// ─── MY DARES (posted) ────────────────────────────────────────────────────────
final myPostedDaresProvider = FutureProvider<List<Dare>>((ref) async {
  final svc = ref.read(supabaseServiceProvider);
  final userId = svc.currentUserId;
  if (userId == null) return [];
  return svc.getDares(posterId: userId, limit: 50);
});

// ─── MY DARES (completed as performer) ───────────────────────────────────────
final myCompletedDaresProvider = FutureProvider<List<Dare>>((ref) async {
  final svc = ref.read(supabaseServiceProvider);
  final userId = svc.currentUserId;
  if (userId == null) return [];
  return svc.getDares(performerId: userId, status: 'completed', limit: 50);
});

// ─── MY PERFORMER POSTS ───────────────────────────────────────────────────────
final myPerformerPostsProvider = FutureProvider<List<PerformerPost>>((ref) async {
  final svc = ref.read(supabaseServiceProvider);
  final userId = svc.currentUserId;
  if (userId == null) return [];
  return svc.getPerformerPosts(performerId: userId, limit: 50);
});

// ─── PUBLIC DARES (posted by user) ───────────────────────────────────────────
final userDaresProvider =
    FutureProvider.family<List<Dare>, String>((ref, userId) async {
  return ref.read(supabaseServiceProvider).getDares(posterId: userId, limit: 30);
});

// ─── PUBLIC PERFORMER POSTS ───────────────────────────────────────────────────
final userPerformerPostsProvider =
    FutureProvider.family<List<PerformerPost>, String>((ref, userId) async {
  return ref.read(supabaseServiceProvider).getPerformerPosts(
      performerId: userId, status: 'open', limit: 20);
});

// ─── EDIT PROFILE ─────────────────────────────────────────────────────────────
class EditProfileNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  SupabaseService get _svc => ref.read(supabaseServiceProvider);

  Future<bool> save({
    required String userId,
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      final data = <String, dynamic>{
        'id': userId,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (displayName != null) data['display_name'] = displayName;
      if (bio != null) data['bio'] = bio;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;
      await _svc.upsertProfile(data);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      dev.log('Error updating profile', error: e, stackTrace: st, name: 'EditProfileNotifier');
      state = AsyncValue.error('Failed to update profile. Please try again.', st);
      return false;
    }
  }
}

final editProfileProvider =
    NotifierProvider<EditProfileNotifier, AsyncValue<void>>(EditProfileNotifier.new);
