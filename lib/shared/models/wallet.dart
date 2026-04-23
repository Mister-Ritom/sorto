// lib/shared/models/wallet.dart

class Wallet {
  final String userId;
  final int coinBalance; // Spendable
  final int escrowBalance; // Locked in dares
  final int earnedBalance; // Creator earnings — withdrawable
  final double realCurrencyWithdrawable; // INR
  final int lifetimeCoinsPurchased;
  final int lifetimeCoinsEarned;

  const Wallet({
    required this.userId,
    required this.coinBalance,
    required this.escrowBalance,
    required this.earnedBalance,
    required this.realCurrencyWithdrawable,
    required this.lifetimeCoinsPurchased,
    required this.lifetimeCoinsEarned,
  });

  int get totalBalance => coinBalance + escrowBalance + earnedBalance;

  /// Alias for UI consistency
  int get escrowedBalance => escrowBalance;
  int get pendingWithdrawal => 0; // Placeholder until DB field is added or logic verified

  factory Wallet.empty(String userId) => Wallet(
        userId: userId,
        coinBalance: 0,
        escrowBalance: 0,
        earnedBalance: 0,
        realCurrencyWithdrawable: 0,
        lifetimeCoinsPurchased: 0,
        lifetimeCoinsEarned: 0,
      );

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        userId: json['user_id'] as String,
        coinBalance: json['coin_balance'] as int? ?? 0,
        escrowBalance: json['escrow_balance'] as int? ?? 0,
        earnedBalance: json['earned_balance'] as int? ?? 0,
        realCurrencyWithdrawable:
            (json['real_currency_withdrawable'] as num?)?.toDouble() ?? 0.0,
        lifetimeCoinsPurchased:
            json['lifetime_coins_purchased'] as int? ?? 0,
        lifetimeCoinsEarned: json['lifetime_coins_earned'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'coin_balance': coinBalance,
        'escrow_balance': escrowBalance,
        'earned_balance': earnedBalance,
        'real_currency_withdrawable': realCurrencyWithdrawable,
        'lifetime_coins_purchased': lifetimeCoinsPurchased,
        'lifetime_coins_earned': lifetimeCoinsEarned,
      };

  Wallet copyWith({
    int? coinBalance,
    int? escrowBalance,
    int? earnedBalance,
    double? realCurrencyWithdrawable,
    int? lifetimeCoinsPurchased,
    int? lifetimeCoinsEarned,
  }) =>
      Wallet(
        userId: userId,
        coinBalance: coinBalance ?? this.coinBalance,
        escrowBalance: escrowBalance ?? this.escrowBalance,
        earnedBalance: earnedBalance ?? this.earnedBalance,
        realCurrencyWithdrawable:
            realCurrencyWithdrawable ?? this.realCurrencyWithdrawable,
        lifetimeCoinsPurchased:
            lifetimeCoinsPurchased ?? this.lifetimeCoinsPurchased,
        lifetimeCoinsEarned: lifetimeCoinsEarned ?? this.lifetimeCoinsEarned,
      );

  @override
  String toString() =>
      'Wallet(spendable=$coinBalance, escrow=$escrowBalance, earned=$earnedBalance)';
}
