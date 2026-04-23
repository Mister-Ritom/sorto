// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  static const String appName = 'Sorto';
  static const String packageName = 'me.ritom.sorto';
  static const String tagline = 'Dare to earn.';

  // SharedPreferences keys
  static const String prefOnboardingDone = 'onboarding_done';

  // Domain — used for deep links
  static const String appDomain = 'sorto.ritom.in';
  static const String appScheme = 'sorto';

  // SortCoin economics
  static const double coinToInr = 1.0; // 1 SortCoin = ₹1
  static const double platformFeePct = 0.20; // 20% cut
  static const double performerSharePct = 0.80; // 80% to performer
  static const double buySpreadPct = 0.20; // Pay ₹100 → get 80 coins

  // Limits
  static const int minWithdrawalCoins = 100;
  static const int minRejectionReasonLength = 20;
  static const int usernameMinLength = 3;
  static const int usernameMaxLength = 20;
  static const int dareTitleMaxLength = 100;
  static const int dareDescriptionMaxLength = 1000;

  // Timing
  static const Duration posterReviewWindow = Duration(hours: 24);
  static const Duration openBestJudgingWindow = Duration(hours: 24);
  static const Duration signedUrlExpiry = Duration(minutes: 15);
  static const Duration videoAutoDeleteAfter = Duration(days: 30);
  static const Duration usernameDebounce = Duration(milliseconds: 500);

  // AI moderation thresholds
  static const double autoRejectHarmThreshold = 0.90;
  static const double warningBannerThreshold = 0.80;

  // Engagement timing (days after signup to show each prompt)
  static const int engagementDay1 = 1;
  static const int engagementDay2 = 2;
  static const int engagementDay3 = 3;
  static const int engagementDay7 = 7;

  // Strikes
  static const int maxPosterStrikes = 3;
  static const double badFaithPenaltyPct = 0.10;

  // Paging
  static const int defaultPageSize = 20;

  // Animation durations
  static const Duration splashDuration = Duration(milliseconds: 2500);
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration cardPress = Duration(milliseconds: 150);
  static const Duration chipSelect = Duration(milliseconds: 200);
  static const Duration verdictReveal = Duration(milliseconds: 600);
  static const Duration balanceUpdate = Duration(milliseconds: 400);
  static const Duration testimonialStagger = Duration(milliseconds: 200);
  static const Duration statCardStagger = Duration(milliseconds: 150);
  static const Duration typewriterDelay = Duration(milliseconds: 60);

  // Coin pack names
  static const List<Map<String, dynamic>> coinPacks = [
    {
      'id': 'tiny',
      'name': 'Tiny',
      'coins': 39,
      'webPriceInr': 49,
      'nativePriceInr': 59,
      'revenuecatId': 'sorto_coins_39',
      'razorpayPlanId': 'plan_sorto_tiny',
      'isBestValue': false,
    },
    {
      'id': 'starter',
      'name': 'Starter',
      'coins': 79,
      'webPriceInr': 99,
      'nativePriceInr': 119,
      'revenuecatId': 'sorto_coins_79',
      'razorpayPlanId': 'plan_sorto_starter',
      'isBestValue': false,
    },
    {
      'id': 'popular',
      'name': 'Popular',
      'coins': 199,
      'webPriceInr': 249,
      'nativePriceInr': 299,
      'revenuecatId': 'sorto_coins_199',
      'razorpayPlanId': 'plan_sorto_popular',
      'isBestValue': true,
    },
    {
      'id': 'pro',
      'name': 'Pro',
      'coins': 399,
      'webPriceInr': 499,
      'nativePriceInr': 599,
      'revenuecatId': 'sorto_coins_399',
      'razorpayPlanId': 'plan_sorto_pro',
      'isBestValue': false,
    },
    {
      'id': 'elite',
      'name': 'Elite',
      'coins': 799,
      'webPriceInr': 999,
      'nativePriceInr': 1199,
      'revenuecatId': 'sorto_coins_799',
      'razorpayPlanId': 'plan_sorto_elite',
      'isBestValue': false,
    },
  ];

  // Dare categories
  static const List<String> dareCategories = [
    'Fitness',
    'Comedy',
    'Food',
    'Skill',
    'Outdoor',
    'Gaming',
    'Social',
    'Art',
  ];

  static const Map<String, String> categoryEmoji = {
    'Fitness': '🏋️',
    'Comedy': '😂',
    'Food': '🍋',
    'Skill': '🎨',
    'Outdoor': '🌍',
    'Gaming': '🎮',
    'Social': '🤝',
    'Art': '🎭',
  };

  // Attribution sources (post-login Day 1)
  static const List<String> attributionSources = [
    'TikTok',
    'Instagram',
    'Friend told me',
    'YouTube',
    'Reddit',
    'Just found it',
  ];
}
