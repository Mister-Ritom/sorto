// lib/core/utils/formatters.dart
import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _inrFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final _compactFormatter = NumberFormat.compact(locale: 'en_IN');

  /// Format an integer coin amount: 1200 → "1,200 SC"
  static String coins(int amount) {
    return '${NumberFormat('#,##0', 'en_IN').format(amount)} SC';
  }

  /// Format coins compactly: 1200 → "1.2K SC"
  static String coinsCompact(int amount) {
    return '${_compactFormatter.format(amount)} SC';
  }

  /// Format INR from coin amount (1:1): 250 → "₹250"
  static String inrFromCoins(int coins) {
    return _inrFormatter.format(coins);
  }

  /// Format raw INR amount: 249.0 → "₹249"
  static String inr(double amount) {
    return _inrFormatter.format(amount.round());
  }

  /// Alias for [inrFromCoins] — convenient shorthand used in wallet/withdrawal screens
  static String rupees(int coins) => inrFromCoins(coins);

  /// Format time remaining from a DateTime
  static String timeRemaining(DateTime expiresAt) {
    final now = DateTime.now();
    final diff = expiresAt.difference(now);
    if (diff.isNegative) return 'Expired';
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m left';
    return 'Ending soon';
  }

  /// Format bounty breakdown for display
  static String bountyBreakdown(int total) {
    final platformCut = (total * 0.20).round();
    final performerShare = total - platformCut;
    return '₹$performerShare to you · ₹$platformCut platform fee';
  }

  /// Open-best share estimate for display
  static String splitEstimate(int bounty, int submissionCount) {
    if (submissionCount == 0) return coins(bounty);
    final share = ((bounty * 0.80) / submissionCount).round();
    return '~${coins(share)} per person';
  }

  /// Format a DateTime as "Apr 23" or "Today" / "Yesterday"
  static String shortDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('MMM d').format(dt);
  }

  /// Full date + time: "Apr 23, 2026 · 11:30 PM"
  static String fullDateTime(DateTime dt) {
    return DateFormat("MMM d, y '·' hh:mm a").format(dt);
  }

  /// Username display (adds @ prefix if not present)
  static String username(String name) {
    return name.startsWith('@') ? name : '@$name';
  }

  /// Confidence percent: 0.97 → "97%"
  static String confidence(double value) {
    return '${(value * 100).round()}%';
  }

  /// Transaction type display label
  static String txnTypeLabel(String type) {
    const map = {
      'topup_native': 'Coins Purchased',
      'topup_web': 'Coins Purchased',
      'dare_lock': 'Dare Funded',
      'dare_unlock': 'Dare Refund',
      'dare_earn': 'Dare Earned',
      'platform_fee': 'Platform Fee',
      'withdrawal_request': 'Withdrawal',
      'withdrawal_complete': 'Paid Out',
      'refund': 'Refund',
    };
    return map[type] ?? type;
  }
}
