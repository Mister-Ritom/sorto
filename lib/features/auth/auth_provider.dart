import 'dart:developer' as dev;
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

  Future<void> _performAuth(Future<dynamic> Function() action, String name) async {
    state = const AsyncValue.loading();
    try {
      await action();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      dev.log('Auth error: $name', error: e, stackTrace: st, name: 'AuthNotifier');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signIn(String email, String password) async {
    await _performAuth(() => _svc.signInWithEmail(email, password), 'signIn');
  }

  Future<void> signUp(String email, String password, String username) async {
    await _performAuth(
      () => _svc.signUpWithEmail(email, password, username),
      'signUp',
    );
  }

  Future<void> signOut() async {
    await _performAuth(() => _svc.signOut(), 'signOut');
  }

  Future<void> resetPassword(String email) async {
    await _performAuth(() => _svc.resetPassword(email), 'resetPassword');
  }

  Future<void> signInWithGoogle() async {
    await _performAuth(() => _svc.signInWithGoogle(), 'signInWithGoogle');
  }

  Future<void> disableAccount() async {
    final userId = _svc.currentUserId;
    if (userId == null) return;
    await _performAuth(() => _svc.disableAccount(userId), 'disableAccount');
    if (!state.hasError) {
      await signOut();
    }
  }

  Future<void> enableAccount() async {
    final userId = _svc.currentUserId;
    if (userId == null) return;
    await _performAuth(() => _svc.enableAccount(userId), 'enableAccount');
    ref.invalidate(currentProfileProvider);
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AsyncValue<void>>(AuthNotifier.new);
