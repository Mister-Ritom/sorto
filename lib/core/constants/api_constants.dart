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
  static const String fnCreateRazorpayOrder = 'create-razorpay-order';
  static const String fnVerifyRazorpayPayment = 'verify-razorpay-payment';

  // Realtime channel templates
  static String dareChannel(String dareId) => 'dare:$dareId';
  static String walletChannel(String userId) => 'wallet:$userId';
  static String notificationsChannel(String userId) => 'notifications:$userId';

  // Razorpay (Web)
  static const String razorpayKeyId = 'rzp_test_ShQ0F2kKESEWDW';

  // RevenueCat (Native)
  static const String revenuecatAppleKey = 'test_nniGqWFpDtkWSNGYbHayiDVTSoi';
  static const String revenuecatGoogleKey = 'test_nniGqWFpDtkWSNGYbHayiDVTSoi';
  static const String revenuecatWebKey = 'test_nniGqWFpDtkWSNGYbHayiDVTSoi';

  // Gemini (used server-side only — never exposed to client)
  // The client never calls Gemini directly.

  // Rate limits (client-side optimistic)
  static const int maxDareCreatePerDay = 10;
  static const int maxClaimPerDay = 20;

  // Google Auth
  static const String googleWebClientId =
      '884254093205-ooq7v12dm10hsp3qcrg4r939575tcra3.apps.googleusercontent.com';
  static const String googleIosClientId =
      '884254093205-tvnlarva4etqjoahthnmrj1fo3psv04i.apps.googleusercontent.com';
}
