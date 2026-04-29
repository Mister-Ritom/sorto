// lib/features/auth/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../../shared/models/profile.dart';
import '../../shared/models/wallet.dart';

// ─── CURRENT USER ────────────────────────────────────────────────────────────
final currentUserProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange
      .map((event) => event.session?.user);
});

// ─── CURRENT PROFILE ─────────────────────────────────────────────────────────
final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;
  if (user == null) return null;
  final svc = ref.read(supabaseServiceProvider);
  return svc.getProfile(user.id);
});

// ─── CURRENT WALLET ──────────────────────────────────────────────────────────
final currentWalletProvider = StreamProvider<Wallet?>((ref) {
  final svc = ref.read(supabaseServiceProvider);
  final userId = svc.currentUserId;
  if (userId == null) return Stream.value(null);
  return svc.watchWallet(userId);
});

// ─── AUTH STATE ──────────────────────────────────────────────────────────────
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// ─── AUTH NOTIFIER (Riverpod 3 style) ────────────────────────────────────────
class AuthNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  SupabaseService get _svc => ref.read(supabaseServiceProvider);

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _svc.signInWithEmail(email, password).then((_) {}));
  }

  Future<void> signUp(String email, String password, String username) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _svc.signUpWithEmail(email, password, username));
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _svc.signOut());
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _svc.resetPassword(email));
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _svc.signInWithGoogle().then((_) {}));
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AsyncValue<void>>(AuthNotifier.new);
