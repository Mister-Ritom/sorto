// lib/shared/widgets/animated_coin.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Particle burst of coins. Trigger via [AnimatedCoinBurstController].
class AnimatedCoinBurst extends StatefulWidget {
  const AnimatedCoinBurst({
    super.key,
    required this.controller,
    required this.child,
    this.particleCount = 12,
    this.radius = 80,
  });

  final AnimatedCoinBurstController controller;
  final Widget child;
  final int particleCount;
  final double radius;

  @override
  State<AnimatedCoinBurst> createState() => _AnimatedCoinBurstState();
}

class _AnimatedCoinBurstState extends State<AnimatedCoinBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final List<_CoinParticle> _particles = [];
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _ctrl.addListener(() => setState(() {}));
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _ctrl.reset();
        _particles.clear();
        setState(() {});
      }
    });
    widget.controller._state = this;
    _generateParticles();
  }

  void _generateParticles() {
    _particles.clear();
    for (int i = 0; i < widget.particleCount; i++) {
      final angle = (2 * pi * i) / widget.particleCount;
      final distance = widget.radius * (0.5 + _rand.nextDouble() * 0.5);
      _particles.add(_CoinParticle(
        angle: angle,
        distance: distance,
        size: 10 + _rand.nextDouble() * 8,
        delay: _rand.nextDouble() * 0.3,
      ));
    }
  }

  void fire() {
    _generateParticles();
    _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (_ctrl.isAnimating)
          ..._particles.map((p) {
            final t = _ctrl.value;
            final progress = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
            final curve = Curves.easeOut.transform(progress);
            final x = cos(p.angle) * p.distance * curve;
            final y = sin(p.angle) * p.distance * curve;
            return Positioned(
              left: MediaQuery.of(context).size.width / 2 + x - p.size / 2,
              top: 0 + y - p.size / 2,
              child: Opacity(
                opacity: (1 - progress).clamp(0.0, 1.0),
                child: Text(
                  '⚡',
                  style: TextStyle(
                    fontSize: p.size,
                    color: AppColors.coinGold,
                    shadows: [
                      Shadow(
                        color: AppColors.coinGold.withOpacity(0.8),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _CoinParticle {
  final double angle;
  final double distance;
  final double size;
  final double delay;

  const _CoinParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
  });
}

class AnimatedCoinBurstController {
  _AnimatedCoinBurstState? _state;

  void fire() => _state?.fire();

  void dispose() {
    _state = null;
  }
}

/// Mini floating coin animation — single coin that floats up and fades
class FloatingCoinEmoji extends StatefulWidget {
  const FloatingCoinEmoji({
    super.key,
    this.emoji = '⚡',
    this.size = 20,
    this.duration = const Duration(milliseconds: 800),
  });

  final String emoji;
  final double size;
  final Duration duration;

  @override
  State<FloatingCoinEmoji> createState() => _FloatingCoinEmojiState();
}

class _FloatingCoinEmojiState extends State<FloatingCoinEmoji>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _opacity = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 1.0)));
    _offset = Tween<double>(begin: 0.0, end: -40.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, _) => Transform.translate(
        offset: Offset(0, _offset.value),
        child: Opacity(
          opacity: _opacity.value,
          child: Text(widget.emoji, style: TextStyle(fontSize: widget.size)),
        ),
      ),
    );
  }
}
