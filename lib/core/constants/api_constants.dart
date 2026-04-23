// lib/core/constants/api_constants.dart

class ApiConstants {
  ApiConstants._();

  // Supabase
  static const String supabaseUrl = 'https://gsohcpkjchaunpepiqxy.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_BiZasabLBYOaYwTn7yToJA_e_u3hgVt';

  static const String supabaeDevUrl = "http://127.0.0.1:54321";
  static const String supabaeDevAnonKey =
      "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH";

  // Supabase Storage
  static const String videoBucket = 'proof-videos';
  static const String avatarBucket = 'avatars';

  // Edge Function names
  static const String fnDareCreate = 'dare-create';
  static const String fnDareClaim = 'dare-claim';
  static const String fnDareSubmitProof = 'dare-submit-proof';
  static const String fnDareModerate = 'dare-moderate';
  static const String fnDareSettle = 'dare-settle';
  static const String fnWithdrawalInitiate = 'withdrawal-initiate';
  static const String fnPerformerPostCreate = 'performer-post-create';

  // Realtime channel templates
  static String dareChannel(String dareId) => 'dare:$dareId';
  static String walletChannel(String userId) => 'wallet:$userId';
  static String notificationsChannel(String userId) => 'notifications:$userId';

  // Razorpay (Web)
  static const String razorpayKeyId = 'rzp_test_PLACEHOLDER';

  // RevenueCat (Native)
  static const String revenuecatAppleKey = 'appl_PLACEHOLDER';
  static const String revenuecatGoogleKey = 'goog_PLACEHOLDER';

  // Gemini (used server-side only — never exposed to client)
  // The client never calls Gemini directly.

  // Rate limits (client-side optimistic)
  static const int maxDareCreatePerDay = 10;
  static const int maxClaimPerDay = 20;
}
