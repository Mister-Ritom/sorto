// lib/shared/widgets/coin_chip.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../features/auth/auth_provider.dart';

class CoinChip extends ConsumerStatefulWidget {
  const CoinChip({
    super.key,
    this.onTap,
    this.compact = false,
  });

  final VoidCallback? onTap;
  final bool compact;

  @override
  ConsumerState<CoinChip> createState() => _CoinChipState();
}

class _CoinChipState extends ConsumerState<CoinChip> {
  int? _prev;

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(currentWalletProvider);
    final balance = walletAsync.value?.coinBalance ?? 0;

    // Detect increase for animation
    final didIncrease = _prev != null && balance > _prev!;
    _prev = balance;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: widget.compact
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.coinGold.withOpacity(0.12),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: AppColors.coinGold.withOpacity(0.35),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('⚡', style: TextStyle(fontSize: widget.compact ? 12 : 14)),
            const SizedBox(width: 5),
            _AnimatedBalance(
              balance: balance,
              compact: widget.compact,
              animate: didIncrease,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedBalance extends StatefulWidget {
  const _AnimatedBalance({
    required this.balance,
    required this.compact,
    required this.animate,
  });

  final int balance;
  final bool compact;
  final bool animate;

  @override
  State<_AnimatedBalance> createState() => _AnimatedBalanceState();
}

class _AnimatedBalanceState extends State<_AnimatedBalance>
    with SingleTickerProviderStateMixin {
  late int _displayed;
  late AnimationController _ctrl;
  late Animation<double> _anim;
  int _target = 0;
  int _from = 0;

  @override
  void initState() {
    super.initState();
    _displayed = widget.balance;
    _target = widget.balance;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _anim.addListener(() {
      setState(() {
        _displayed =
            (_from + (_target - _from) * _anim.value).round();
      });
    });
  }

  @override
  void didUpdateWidget(_AnimatedBalance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.balance != widget.balance) {
      _from = _displayed;
      _target = widget.balance;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _formatBalance(_displayed, widget.compact);
    Widget child = Text(
      text,
      key: ValueKey(_displayed),
      style: widget.compact
          ? AppTypography.labelM(color: AppColors.coinGold)
          : AppTypography.labelL(color: AppColors.coinGold),
    );

    if (widget.animate && _ctrl.isAnimating) {
      child = child
          .animate()
          .scale(begin: const Offset(1.3, 1.3), duration: 300.ms)
          .then()
          .scale(end: const Offset(1.0, 1.0));
    }

    return child;
  }

  String _formatBalance(int n, bool compact) {
    if (compact && n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}K';
    }
    if (n >= 1000) {
      return n.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    }
    return n.toString();
  }
}

/// Static coin chip for displaying an amount (not tied to wallet)
class CoinAmount extends StatelessWidget {
  const CoinAmount({
    super.key,
    required this.amount,
    this.size = CoinAmountSize.medium,
    this.color,
    this.showIcon = true,
  });

  final int amount;
  final CoinAmountSize size;
  final Color? color;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.coinGold;
    final (fontSize, iconSize) = switch (size) {
      CoinAmountSize.small => (12.0, 12.0),
      CoinAmountSize.medium => (16.0, 16.0),
      CoinAmountSize.large => (22.0, 22.0),
      CoinAmountSize.xlarge => (32.0, 28.0),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showIcon) ...[
          Text('⚡',
              style: TextStyle(fontSize: iconSize * 0.85)),
          const SizedBox(width: 4),
        ],
        Text(
          '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
          style: AppTypography.labelL(color: c).copyWith(fontSize: fontSize),
        ),
      ],
    );
  }
}

enum CoinAmountSize { small, medium, large, xlarge }
