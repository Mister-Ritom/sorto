import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../shared/models/dare.dart';
import '../../shared/models/profile.dart';
import '../../shared/models/wallet.dart';
import '../../shared/models/transaction.dart';
import '../../shared/models/notification_model.dart';
import '../../shared/models/performer_post.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService(ref.read(supabaseClientProvider));
});

class SupabaseService {
  SupabaseService(this._client);
  final SupabaseClient _client;

  SupabaseClient get client => _client;

  // ─── AUTH ────────────────────────────────────────────────────────────────
  User? get currentUser => _client.auth.currentUser;
  String? get currentUserId => _client.auth.currentUser?.id;

  Stream<AuthState> get authStateStream => _client.auth.onAuthStateChange;

  Future<AuthResponse> signInWithEmail(String email, String password) =>
      _client.auth.signInWithPassword(email: email, password: password);

  Future<AuthResponse> signUpWithEmail(
    String email,
    String password,
    String username,
  ) async => _client.auth.signUp(
    email: email,
    password: password,
    data: {'username': username},
  );

  Future<void> signOut() => _client.auth.signOut();

  Future<void> resetPassword(String email) =>
      _client.auth.resetPasswordForEmail(email);

  Future<AuthResponse> signInWithGoogle() async {
    const webClientId = ApiConstants.googleWebClientId;
    const iosClientId = ApiConstants.googleIosClientId;

    // In google_sign_in 7.x+, you use the singleton instance and initialize it first.
    await GoogleSignIn.instance.initialize(
      clientId: kIsWeb ? webClientId : iosClientId,
      serverClientId: webClientId,
    );

    // 1. Authenticate to get identity info
    final googleUser = await GoogleSignIn.instance.authenticate();

    // 2. Authorize scopes to get the accessToken (required for Supabase)
    final authorization = await googleUser.authorizationClient.authorizeScopes([
      'openid',
      'email',
      'profile',
    ]);

    // 3. Get the ID Token (authentication)
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = authorization.accessToken;

    if (idToken == null) {
      throw 'No Google ID Token found.';
    }

    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  // ─── PROFILES ────────────────────────────────────────────────────────────
  Future<Profile?> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return Profile.fromJson(data);
  }

  Future<Profile?> getProfileByUsername(String username) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('username', username)
        .maybeSingle();
    if (data == null) return null;
    return Profile.fromJson(data);
  }

  Future<bool> isUsernameAvailable(String username) async {
    final data = await _client
        .from('profiles')
        .select('id')
        .eq('username', username)
        .maybeSingle();
    return data == null;
  }

  Future<void> upsertProfile(Map<String, dynamic> data) async {
    await _client.from('profiles').upsert(data);
  }

  Future<List<Profile>> searchProfiles(String query, {int limit = 20}) async {
    final data = await _client
        .from('profiles')
        .select()
        .or('username.ilike.%$query%,display_name.ilike.%$query%')
        .limit(limit);
    return data.map<Profile>((e) => Profile.fromJson(e)).toList();
  }

  // ─── WALLET ──────────────────────────────────────────────────────────────
  Future<Wallet?> getWallet(String userId) async {
    final data = await _client
        .from('wallets')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (data == null) return null;
    return Wallet.fromJson(data);
  }

  Stream<Wallet?> watchWallet(String userId) {
    return _client
        .from('wallets')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', userId)
        .map<Wallet?>((rows) {
          if (rows.isEmpty) return null;
          return Wallet.fromJson(rows.first);
        });
  }

  // ─── TRANSACTIONS ─────────────────────────────────────────────────────────
  Future<List<SortoTransaction>> getTransactions(
    String userId, {
    int limit = AppConstants.defaultPageSize,
    int offset = 0,
    String? type,
  }) async {
    var query = _client.from('transactions').select().eq('user_id', userId);
    if (type != null) {
      query = query.eq('type', type);
    }
    final data = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return data
        .map<SortoTransaction>((e) => SortoTransaction.fromJson(e))
        .toList();
  }

  // ─── DARES ───────────────────────────────────────────────────────────────
  Future<List<Dare>> getDares({
    int limit = AppConstants.defaultPageSize,
    int offset = 0,
    String? category,
    String? mode,
    String? status,
    String? posterId,
    String? performerId,
  }) async {
    var query = _client
        .from('dares')
        .select('*, profiles!poster_id(username, avatar_url, display_name)');

    if (category != null) query = query.eq('category', category);
    if (mode != null) query = query.eq('dare_mode', mode);
    if (status != null) query = query.eq('status', status);
    if (posterId != null) query = query.eq('poster_id', posterId);
    if (performerId != null) query = query.eq('performer_id', performerId);

    final data = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return data.map<Dare>((e) => Dare.fromJson(e)).toList();
  }

  Future<Dare?> getDare(String dareId) async {
    final data = await _client
        .from('dares')
        .select(
          '*, profiles!poster_id(username, avatar_url, display_name), dare_submissions(count)',
        )
        .eq('id', dareId)
        .maybeSingle();
    if (data == null) return null;
    return Dare.fromJson(data);
  }

  Stream<List<Dare>> watchOpenDares({
    String? category,
    String? mode,
    int limit = AppConstants.defaultPageSize,
  }) {
    var query = _client
        .from('dares')
        .stream(primaryKey: ['id'])
        .eq('status', 'open');
    return query.map<List<Dare>>(
      (rows) => rows.map<Dare>((e) => Dare.fromJson(e)).toList(),
    );
  }

  Future<List<DareSubmission>> getDareSubmissions(String dareId) async {
    final data = await _client
        .from('dare_submissions')
        .select()
        .eq('dare_id', dareId)
        .order('created_at', ascending: false);
    return data.map<DareSubmission>((e) => DareSubmission.fromJson(e)).toList();
  }

  Future<DareSubmission?> getMySubmission(String dareId, String userId) async {
    final data = await _client
        .from('dare_submissions')
        .select()
        .eq('dare_id', dareId)
        .eq('performer_id', userId)
        .maybeSingle();
    if (data == null) return null;
    return DareSubmission.fromJson(data);
  }

  // ─── PERFORMER POSTS ─────────────────────────────────────────────────────
  Future<List<PerformerPost>> getPerformerPosts({
    int limit = AppConstants.defaultPageSize,
    int offset = 0,
    String? category,
    String? performerId,
    String? status,
  }) async {
    var query = _client
        .from('performer_posts')
        .select('*, profiles!performer_id(username, avatar_url, display_name)');
    if (category != null) query = query.eq('category', category);
    if (performerId != null) query = query.eq('performer_id', performerId);
    if (status != null) query = query.eq('status', status);
    final data = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return data.map<PerformerPost>((e) => PerformerPost.fromJson(e)).toList();
  }

  Future<PerformerPost?> getPerformerPost(String postId) async {
    final data = await _client
        .from('performer_posts')
        .select('*, profiles!performer_id(username, avatar_url, display_name)')
        .eq('id', postId)
        .maybeSingle();
    if (data == null) return null;
    return PerformerPost.fromJson(data);
  }

  // ─── NOTIFICATIONS ────────────────────────────────────────────────────────
  Future<List<SortoNotification>> getNotifications(
    String userId, {
    int limit = 50,
  }) async {
    final data = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);
    return data
        .map<SortoNotification>((e) => SortoNotification.fromJson(e))
        .toList();
  }

  Future<int> getUnreadNotificationCount(String userId) async {
    final data = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .eq('is_read', false)
        .count(CountOption.exact);
    return data.count;
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  Future<void> markAllNotificationsRead(String userId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  Stream<List<SortoNotification>> watchNotifications(String userId) {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50)
        .map<List<SortoNotification>>(
          (rows) => rows
              .map<SortoNotification>((e) => SortoNotification.fromJson(e))
              .toList(),
        );
  }

  // ─── EDGE FUNCTIONS ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> invokeFunction(
    String name, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _client.functions.invoke(name, body: body);
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {'data': response.data};
  }

  Future<Map<String, dynamic>> createDare(Map<String, dynamic> data) =>
      invokeFunction(ApiConstants.fnDareCreate, body: data);

  Future<Map<String, dynamic>> claimDare(String dareId) =>
      invokeFunction(ApiConstants.fnDareClaim, body: {'dare_id': dareId});

  Future<Map<String, dynamic>> submitProof({
    required String dareId,
    required String videoPath,
    String? proofText,
  }) => invokeFunction(
    ApiConstants.fnDareSubmitProof,
    body: {'dare_id': dareId, 'video_path': videoPath, 'proof_text': proofText},
  );

  Future<Map<String, dynamic>> settleDare({
    required String dareId,
    required String submissionId,
    required String verdict, // 'approved' | 'rejected' | 'winner'
    String? reason,
  }) => invokeFunction(
    ApiConstants.fnDareSettle,
    body: {
      'dare_id': dareId,
      'submission_id': submissionId,
      'verdict': verdict,
      'reason': reason,
    },
  );

  Future<Map<String, dynamic>> initiateWithdrawal({
    required int coinAmount,
    required String upiId,
  }) => invokeFunction(
    ApiConstants.fnWithdrawalInitiate,
    body: {'coin_amount': coinAmount, 'upi_id': upiId},
  );

  Future<Map<String, dynamic>> createPerformerPost(Map<String, dynamic> data) =>
      invokeFunction(ApiConstants.fnPerformerPostCreate, body: data);

  // ─── STORAGE ──────────────────────────────────────────────────────────────
  Future<String> uploadVideo({
    required String filePath,
    required List<int> bytes,
    required String mimeType,
  }) async {
    await _client.storage
        .from(ApiConstants.videoBucket)
        .uploadBinary(
          filePath,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(contentType: mimeType),
        );
    return filePath;
  }

  Future<String> getSignedVideoUrl(
    String path, {
    Duration expiry = const Duration(minutes: 15),
  }) async {
    return await _client.storage
        .from(ApiConstants.videoBucket)
        .createSignedUrl(path, expiry.inSeconds);
  }

  Future<String?> uploadAvatar(String userId, List<int> bytes) async {
    final path = '$userId/avatar.jpg';
    await _client.storage
        .from(ApiConstants.avatarBucket)
        .uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );
    return _client.storage.from(ApiConstants.avatarBucket).getPublicUrl(path);
  }
}
