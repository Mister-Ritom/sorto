// lib/shared/models/transaction.dart

enum TransactionType {
  topupNative,
  topupWeb,
  dareLock,
  dareUnlock,
  dareEarn,
  platformFee,
  withdrawalRequest,
  withdrawalComplete,
  refund,
}

extension TransactionTypeX on TransactionType {
  String get dbValue {
    switch (this) {
      case TransactionType.topupNative:
        return 'topup_native';
      case TransactionType.topupWeb:
        return 'topup_web';
      case TransactionType.dareLock:
        return 'dare_lock';
      case TransactionType.dareUnlock:
        return 'dare_unlock';
      case TransactionType.dareEarn:
        return 'dare_earn';
      case TransactionType.platformFee:
        return 'platform_fee';
      case TransactionType.withdrawalRequest:
        return 'withdrawal_request';
      case TransactionType.withdrawalComplete:
        return 'withdrawal_complete';
      case TransactionType.refund:
        return 'refund';
    }
  }

  String get label {
    switch (this) {
      case TransactionType.topupNative:
      case TransactionType.topupWeb:
        return 'Coins Purchased';
      case TransactionType.dareLock:
        return 'Dare Funded';
      case TransactionType.dareUnlock:
        return 'Dare Refund';
      case TransactionType.dareEarn:
        return 'Dare Earned';
      case TransactionType.platformFee:
        return 'Platform Fee';
      case TransactionType.withdrawalRequest:
        return 'Withdrawal';
      case TransactionType.withdrawalComplete:
        return 'Paid Out';
      case TransactionType.refund:
        return 'Refund';
    }
  }

  bool get isCredit {
    switch (this) {
      case TransactionType.topupNative:
      case TransactionType.topupWeb:
      case TransactionType.dareEarn:
      case TransactionType.dareUnlock:
      case TransactionType.refund:
        return true;
      default:
        return false;
    }
  }

  String get emoji {
    switch (this) {
      case TransactionType.topupNative:
      case TransactionType.topupWeb:
        return '💳';
      case TransactionType.dareLock:
        return '🔒';
      case TransactionType.dareUnlock:
      case TransactionType.dareEarn:
        return '⚡';
      case TransactionType.platformFee:
        return '💸';
      case TransactionType.withdrawalRequest:
        return '🏦';
      case TransactionType.withdrawalComplete:
        return '✅';
      case TransactionType.refund:
        return '↩️';
    }
  }

  static TransactionType fromString(String value) {
    switch (value) {
      case 'topup_native':
        return TransactionType.topupNative;
      case 'topup_web':
        return TransactionType.topupWeb;
      case 'dare_lock':
        return TransactionType.dareLock;
      case 'dare_unlock':
        return TransactionType.dareUnlock;
      case 'dare_earn':
        return TransactionType.dareEarn;
      case 'platform_fee':
        return TransactionType.platformFee;
      case 'withdrawal_request':
        return TransactionType.withdrawalRequest;
      case 'withdrawal_complete':
        return TransactionType.withdrawalComplete;
      case 'refund':
      default:
        return TransactionType.refund;
    }
  }
}

class SortoTransaction {
  final String id;
  final String userId;
  final String? dareId;
  final int amount;
  final TransactionType type;
  final String? providerTxnId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const SortoTransaction({
    required this.id,
    required this.userId,
    this.dareId,
    required this.amount,
    required this.type,
    this.providerTxnId,
    this.metadata,
    required this.createdAt,
  });

  /// Alias for [amount] — used in wallet screen
  int get coinAmount => amount;

  /// Human-readable description from metadata or type label
  String? get description {
    final note = metadata?['note'] as String?;
    if (note != null) return note;
    final dareTitle = metadata?['dare_title'] as String?;
    return dareTitle;
  }

  factory SortoTransaction.fromJson(Map<String, dynamic> json) =>
      SortoTransaction(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        dareId: json['dare_id'] as String?,
        amount: json['amount'] as int,
        type: TransactionTypeX.fromString(json['type'] as String),
        providerTxnId: json['provider_txn_id'] as String?,
        metadata: json['metadata'] as Map<String, dynamic>?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
