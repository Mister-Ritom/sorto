// lib/features/wallet/wallet_provider.dart
import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/supabase_service.dart';
import '../../shared/models/wallet.dart';
import '../../shared/models/transaction.dart';

const _tag = 'TransactionProvider';

// ─── WALLET STREAM ────────────────────────────────────────────────────────────
final walletStreamProvider = StreamProvider<Wallet?>((ref) {
  final svc = ref.read(supabaseServiceProvider);
  final userId = svc.currentUserId;
  if (userId == null) return Stream.value(null);
  return svc.watchWallet(userId);
});

// ─── TRANSACTIONS ─────────────────────────────────────────────────────────────
class TransactionState {
  final List<SortoTransaction> transactions;
  final bool isLoading;
  final bool hasMore;
  final String? typeFilter;
  final int offset;

  const TransactionState({
    this.transactions = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.typeFilter,
    this.offset = 0,
  });

  TransactionState copyWith({
    List<SortoTransaction>? transactions,
    bool? isLoading,
    bool? hasMore,
    String? typeFilter,
    int? offset,
  }) =>
      TransactionState(
        transactions: transactions ?? this.transactions,
        isLoading: isLoading ?? this.isLoading,
        hasMore: hasMore ?? this.hasMore,
        typeFilter: typeFilter ?? this.typeFilter,
        offset: offset ?? this.offset,
      );
}

class TransactionNotifier extends Notifier<TransactionState> {
  @override
  TransactionState build() {
    // We must use microtask to avoid updating state during the build phase.
    // refresh: true ensures we bypass the loading check for this initial call.
    Future.microtask(() => load(refresh: true));
    return const TransactionState(isLoading: true);
  }

  SupabaseService get _svc => ref.read(supabaseServiceProvider);

  Future<void> load({bool refresh = false}) async {
    if (!refresh && (state.isLoading || !state.hasMore)) return;
    final offset = refresh ? 0 : state.offset;
    state = state.copyWith(isLoading: true, offset: offset,
        transactions: refresh ? [] : state.transactions);

    try {
      final userId = _svc.currentUserId;
      if (userId == null) {
        state = const TransactionState(transactions: []);
        return;
      }
      final txns = await _svc.getTransactions(
        userId,
        limit: 30,
        offset: offset,
        type: state.typeFilter,
      );
      state = state.copyWith(
        transactions: refresh ? txns : [...state.transactions, ...txns],
        isLoading: false,
        hasMore: txns.length == 30,
        offset: offset + txns.length,
      );
    } catch (e, st) {
      dev.log('Failed to load transactions', name: _tag, error: e, stackTrace: st);
      state = state.copyWith(isLoading: false);
    }
  }

  void filterType(String? type) {
    state = TransactionState(typeFilter: type, isLoading: true);
    load(refresh: true);
  }

  void loadMore() => load();
}

final transactionProvider =
    NotifierProvider<TransactionNotifier, TransactionState>(
        TransactionNotifier.new);

// async value wrapper
final transactionAsyncProvider =
    Provider<AsyncValue<List<SortoTransaction>>>((ref) {
  final s = ref.watch(transactionProvider);
  if (s.isLoading && s.transactions.isEmpty) return const AsyncValue.loading();
  return AsyncValue.data(s.transactions);
});

// ─── WITHDRAWAL ───────────────────────────────────────────────────────────────
class WithdrawalNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  SupabaseService get _svc => ref.read(supabaseServiceProvider);

  Future<bool> initiate({required int coinAmount, required String upiId}) async {
    state = const AsyncValue.loading();
    try {
      await _svc.initiateWithdrawal(coinAmount: coinAmount, upiId: upiId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      dev.log('Error initiating withdrawal', error: e, stackTrace: st, name: 'WithdrawalNotifier');
      state = AsyncValue.error('Withdrawal failed. Please check your UPI ID and balance.', st);
      return false;
    }
  }
}

final withdrawalProvider =
    NotifierProvider<WithdrawalNotifier, AsyncValue<void>>(WithdrawalNotifier.new);
