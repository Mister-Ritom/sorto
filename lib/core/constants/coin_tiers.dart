// lib/core/constants/coin_tiers.dart
//
// Defines the product identifiers for each coin tier.
// 1 coin = ₹1. The actual price shown to the user comes from:
//   - RevenueCat SDK (App Store / Play Store pricing) on Android/iOS
//   - Inline rupee calculation (coins == rupees) for Razorpay on Web/Desktop
//
// The `priceInRupees` field is ONLY used for the Razorpay fallback UI.
// Never pass paise from Flutter — the Edge Function handles that conversion.

class CoinTier {
  final int coins;
  final String revenueCatId; // must match Google Play / App Store product IDs

  const CoinTier({
    required this.coins,
    required this.revenueCatId,
  });

  /// Since 1 coin = ₹1, the rupee price equals the coin count.
  /// Used for Razorpay fallback display only.
  int get priceInRupees => coins;

  String get label => '$coins SC';

  /// Fallback price label shown when RevenueCat offerings are unavailable.
  String get razorpayPriceLabel => '₹$coins';
}

const List<CoinTier> kCoinTiers = [
  CoinTier(coins: 100,  revenueCatId: 'coins_100'),
  CoinTier(coins: 300,  revenueCatId: 'coins_300'),
  CoinTier(coins: 500,  revenueCatId: 'coins_500'),
  CoinTier(coins: 1000, revenueCatId: 'coins_1000'),
  CoinTier(coins: 2000, revenueCatId: 'coins_2000'),
  CoinTier(coins: 5000, revenueCatId: 'coins_5000'),
];
