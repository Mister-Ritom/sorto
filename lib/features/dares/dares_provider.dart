// lib/features/dares/dares_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/supabase_service.dart';
import '../../shared/models/dare.dart';

// ─── DARE DETAIL ──────────────────────────────────────────────────────────────
final dareDetailProvider =
    FutureProvider.family<Dare?, String>((ref, dareId) async {
  return ref.read(supabaseServiceProvider).getDare(dareId);
});

// ─── DARE SUBMISSIONS ─────────────────────────────────────────────────────────
final dareSubmissionsProvider =
    FutureProvider.family<List<DareSubmission>, String>((ref, dareId) async {
  return ref.read(supabaseServiceProvider).getDareSubmissions(dareId);
});

final mySubmissionProvider =
    FutureProvider.family<DareSubmission?, String>((ref, dareId) async {
  final svc = ref.read(supabaseServiceProvider);
  final userId = svc.currentUserId;
  if (userId == null) return null;
  return svc.getMySubmission(dareId, userId);
});

// ─── CREATE DARE STATE ────────────────────────────────────────────────────────
class CreateDareState {
  final String title;
  final String description;
  final String category;
  final List<String> tags;
  final DareMode mode;
  final int bounty;
  final DateTime? expiresAt;
  final bool isSubmitting;
  final String? error;

  const CreateDareState({
    this.title = '',
    this.description = '',
    this.category = '',
    this.tags = const [],
    this.mode = DareMode.solo,
    this.bounty = 100,
    this.expiresAt,
    this.isSubmitting = false,
    this.error,
  });

  CreateDareState copyWith({
    String? title,
    String? description,
    String? category,
    List<String>? tags,
    DareMode? mode,
    int? bounty,
    DateTime? expiresAt,
    bool? isSubmitting,
    String? error,
  }) =>
      CreateDareState(
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        tags: tags ?? this.tags,
        mode: mode ?? this.mode,
        bounty: bounty ?? this.bounty,
        expiresAt: expiresAt ?? this.expiresAt,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: error,
      );

  bool get isValid =>
      title.length >= 10 &&
      description.length >= 20 &&
      category.isNotEmpty &&
      bounty >= 10 &&
      expiresAt != null;
}

class CreateDareNotifier extends Notifier<CreateDareState> {
  @override
  CreateDareState build() => const CreateDareState();

  SupabaseService get _svc => ref.read(supabaseServiceProvider);

  void setTitle(String v) => state = state.copyWith(title: v);
  void setDescription(String v) => state = state.copyWith(description: v);
  void setCategory(String v) => state = state.copyWith(category: v);
  void toggleTag(String tag) {
    final tags = List<String>.from(state.tags);
    tags.contains(tag) ? tags.remove(tag) : tags.add(tag);
    state = state.copyWith(tags: tags);
  }
  void setMode(DareMode m) => state = state.copyWith(mode: m);
  void setBounty(int v) => state = state.copyWith(bounty: v);
  void setExpiresAt(DateTime dt) => state = state.copyWith(expiresAt: dt);

  Future<Dare?> submit() async {
    if (!state.isValid) return null;
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final result = await _svc.createDare({
        'title': state.title,
        'description': state.description,
        'category': state.category,
        'tags': state.tags,
        'dare_mode': state.mode.dbValue,
        'bounty_amount': state.bounty,
        'expires_at': state.expiresAt!.toIso8601String(),
      });
      state = state.copyWith(isSubmitting: false);
      if (result['dare'] != null) {
        return Dare.fromJson(result['dare'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }

  void reset() => state = const CreateDareState();
}

final createDareProvider =
    NotifierProvider<CreateDareNotifier, CreateDareState>(CreateDareNotifier.new);

// ─── CLAIM DARE ───────────────────────────────────────────────────────────────
class ClaimDareNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  SupabaseService get _svc => ref.read(supabaseServiceProvider);

  Future<bool> claim(String dareId) async {
    state = const AsyncValue.loading();
    try {
      await _svc.claimDare(dareId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final claimDareProvider =
    NotifierProvider<ClaimDareNotifier, AsyncValue<void>>(ClaimDareNotifier.new);

// ─── SUBMIT PROOF ──────────────────────────────────────────────────────────────
class SubmitProofNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  SupabaseService get _svc => ref.read(supabaseServiceProvider);

  Future<bool> submit({
    required String dareId,
    required String videoPath,
    String? proofText,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _svc.submitProof(
          dareId: dareId, videoPath: videoPath, proofText: proofText);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final submitProofProvider =
    NotifierProvider<SubmitProofNotifier, AsyncValue<void>>(SubmitProofNotifier.new);

// ─── SETTLE DARE ──────────────────────────────────────────────────────────────
class SettleDareNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  SupabaseService get _svc => ref.read(supabaseServiceProvider);

  Future<bool> approve({required String dareId, required String submissionId}) async {
    state = const AsyncValue.loading();
    try {
      await _svc.settleDare(
          dareId: dareId, submissionId: submissionId, verdict: 'approved');
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> reject({
    required String dareId,
    required String submissionId,
    required String reason,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _svc.settleDare(
        dareId: dareId, submissionId: submissionId,
        verdict: 'rejected', reason: reason,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

// ─── ADMIN QUEUE ──────────────────────────────────────────────────────────────
final underReviewDaresProvider = FutureProvider<List<Dare>>((ref) async {
  return ref.read(supabaseServiceProvider).getDares(status: 'under_review', limit: 50);
});

final settleDareProvider =
    NotifierProvider<SettleDareNotifier, AsyncValue<void>>(SettleDareNotifier.new);
