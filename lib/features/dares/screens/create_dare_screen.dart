// lib/features/dares/screens/create_dare_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/models/dare.dart';
import '../../../shared/widgets/dare_mode_badge.dart';
import '../../../shared/widgets/sorto_button.dart';
import '../../../shared/widgets/coin_chip.dart';
import '../../../features/auth/auth_provider.dart';
import '../dares_provider.dart';
import 'package:sorto/core/extensions/color_extensions.dart';

class CreateDareScreen extends ConsumerStatefulWidget {
  const CreateDareScreen({super.key});

  @override
  ConsumerState<CreateDareScreen> createState() => _CreateDareScreenState();
}

class _CreateDareScreenState extends ConsumerState<CreateDareScreen> {
  final PageController _pageCtrl = PageController();
  int _currentStep = 0;
  final int _totalSteps = 6;

  // Step 1
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // Step 2
  String? _selectedCategory;

  // Step 3
  DareMode _selectedMode = DareMode.solo;

  // Step 4 — face-value double (10.0 = 10 coins, 5.99 = 5.99 coins)
  double _bounty = 10.0;
  final _bountyCtrl = TextEditingController(text: '10');

  // Step 5
  DateTime? _expiresAt;

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(() => setState(() {}));
    _descCtrl.addListener(() => setState(() {}));
    _bountyCtrl.addListener(() {
      final val = double.tryParse(_bountyCtrl.text);
      if (val != null) setState(() => _bounty = val);
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _bountyCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < _totalSteps - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentStep++);
    }
  }

  void _back() {
    if (_currentStep > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  bool get _step1Valid =>
      Validators.dareTitle(_titleCtrl.text) == null &&
      Validators.dareDescription(_descCtrl.text) == null;

  Future<void> _submit() async {
    HapticFeedback.mediumImpact();
    final notifier = ref.read(createDareProvider.notifier);
    notifier.setTitle(_titleCtrl.text.trim());
    notifier.setDescription(_descCtrl.text.trim());
    notifier.setCategory(_selectedCategory ?? '');
    notifier.setMode(_selectedMode);
    notifier.setBounty(_bounty.round());
    if (_expiresAt != null) notifier.setExpiresAt(_expiresAt!);

    final dare = await notifier.submit();
    if (!mounted) return;
    if (dare != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('🎯 Dare posted!')));
      context.go(Routes.dareDetailPath(dare.id));
    } else {
      final error = ref.read(createDareProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to post dare'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final createState = ref.watch(createDareProvider);
    final wallet = ref.watch(currentWalletProvider).value;
    final balance = wallet?.coinBalance ?? 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _back,
        ),
        title: Text('Create Dare', style: AppTypography.headingM()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _StepProgressBar(current: _currentStep, total: _totalSteps),
        ),
      ),
      body: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // ── Step 1: Title + Description ───────────────────────────────
          _StepWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepHeader(
                  step: 1,
                  title: 'What\'s the dare?',
                  subtitle: 'Be specific. Vague dares get fewer performers.',
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _titleCtrl,
                  maxLength: AppConstants.dareTitleMaxLength,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTypography.headingS(),
                  decoration: InputDecoration(
                    labelText: 'Dare title',
                    hintText: 'e.g. Eat a lemon without making a face',
                    counterStyle: AppTypography.bodyS(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 4,
                  maxLength: AppConstants.dareDescriptionMaxLength,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Full description',
                    hintText: 'Describe exactly what the performer must do...',
                    alignLabelWithHint: true,
                    counterStyle: AppTypography.bodyS(),
                  ),
                ),
                const Spacer(),
                SortoButton(
                  label: 'Next →',
                  onPressed: _step1Valid ? _next : null,
                ),
              ],
            ),
          ),

          // ── Step 2: Category ──────────────────────────────────────────
          _StepWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepHeader(
                  step: 2,
                  title: 'Pick a category',
                  subtitle: 'Helps performers find dares they\'d enjoy.',
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: AppConstants.dareCategories.map((cat) {
                      final emoji = AppConstants.categoryEmoji[cat] ?? '🎯';
                      final selected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedCategory = cat);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary.withOpacityNew(0.2)
                                : (isDark
                                      ? AppColors.darkCard
                                      : AppColors.lightCard),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : (isDark
                                        ? AppColors.darkCardBorder
                                        : AppColors.lightCardBorder),
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(emoji, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(
                                cat,
                                style: AppTypography.labelL(
                                  color: selected ? AppColors.primary : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SortoButton(
                  label: 'Next →',
                  onPressed: _selectedCategory != null ? _next : null,
                ),
              ],
            ),
          ),

          // ── Step 3: Mode ──────────────────────────────────────────────
          _StepWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepHeader(
                  step: 3,
                  title: 'How should it work?',
                  subtitle: 'Choose the dare mode.',
                ),
                const SizedBox(height: 28),
                ...DareMode.values.map(
                  (mode) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedMode = mode);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedMode == mode
                              ? AppColors.primary.withOpacityNew(0.1)
                              : (isDark
                                    ? AppColors.darkCard
                                    : AppColors.lightCard),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedMode == mode
                                ? AppColors.primary
                                : (isDark
                                      ? AppColors.darkCardBorder
                                      : AppColors.lightCardBorder),
                            width: _selectedMode == mode ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            DareModeBadge(mode: mode),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                mode.description,
                                style: AppTypography.bodyM(),
                              ),
                            ),
                            if (_selectedMode == mode)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                SortoButton(label: 'Next →', onPressed: _next),
              ],
            ),
          ),

          // ── Step 4: Bounty ────────────────────────────────────────────
          _StepWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepHeader(
                  step: 4,
                  title: 'Set the bounty',
                  subtitle: 'This comes from your spendable balance.',
                ),
                const Spacer(),
                // ── Big bold amount input ─────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '⚡',
                            style: const TextStyle(fontSize: 36),
                          ),
                          const SizedBox(width: 8),
                          IntrinsicWidth(
                            child: TextField(
                              controller: _bountyCtrl,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: false,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}'),
                                ),
                              ],
                              textAlign: TextAlign.center,
                              style: AppTypography.displayM().copyWith(
                                color: AppColors.coinGold,
                                fontSize: 52,
                                fontWeight: FontWeight.w800,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '0',
                                hintStyle: TextStyle(
                                  color: AppColors.darkTextMuted,
                                  fontSize: 52,
                                  fontWeight: FontWeight.w800,
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SC',
                            style: AppTypography.headingM(
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Performer earns ${Formatters.coins((_bounty * 0.8).round())} · $balance SC available',
                        style: AppTypography.bodyS(),
                      ),
                      if (_bounty > 0 && _bounty < 10)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Minimum bounty is 10 SC',
                            style: AppTypography.bodyS(color: AppColors.error),
                          ),
                        ),
                      if (_bounty > balance)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Exceeds your balance of $balance SC',
                            style: AppTypography.bodyS(color: AppColors.error),
                          ),
                        ),
                    ],
                  ),
                ),
                const Spacer(),
                if (balance < 10)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacityNew(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('⚠️'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You need at least 10 coins. Add coins first.',
                            style: AppTypography.bodyS(
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SortoButton(
                  label: 'Next →',
                  onPressed: (balance >= 10 && _bounty >= 10 && _bounty <= balance)
                      ? _next
                      : null,
                ),
              ],
            ),
          ),

          // ── Step 5: Deadline ──────────────────────────────────────────
          _StepWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepHeader(
                  step: 5,
                  title: 'Set a deadline',
                  subtitle: 'Performers must submit before this time.',
                ),
                const SizedBox(height: 28),
                // Quick options
                ...[
                  ('24 hours', const Duration(hours: 24)),
                  ('48 hours', const Duration(hours: 48)),
                  ('3 days', const Duration(days: 3)),
                  ('1 week', const Duration(days: 7)),
                ].map((opt) {
                  final (label, dur) = opt;
                  final dt = DateTime.now().add(dur);
                  final selected =
                      _expiresAt != null &&
                      (_expiresAt!.difference(dt).inMinutes.abs() < 5);
                  return GestureDetector(
                    onTap: () => setState(() => _expiresAt = dt),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withOpacityNew(0.1)
                            : (isDark
                                  ? AppColors.darkCard
                                  : AppColors.lightCard),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.darkCardBorder
                                    : AppColors.lightCardBorder),
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(label, style: AppTypography.labelL()),
                          const Spacer(),
                          Text(
                            Formatters.fullDateTime(dt),
                            style: AppTypography.bodyS(),
                          ),
                          if (selected) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
                const Spacer(),
                SortoButton(
                  label: 'Next →',
                  onPressed: _expiresAt != null ? _next : null,
                ),
              ],
            ),
          ),

          // ── Step 6: Review + Confirm ──────────────────────────────────
          _StepWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepHeader(
                  step: 6,
                  title: 'Review your dare',
                  subtitle: 'Once posted, coins are locked in escrow.',
                ),
                const SizedBox(height: 28),
                _ReviewCard(
                  title: _titleCtrl.text,
                  description: _descCtrl.text,
                  category: _selectedCategory ?? '',
                  mode: _selectedMode,
                  bounty: _bounty.round(),
                  expiresAt: _expiresAt,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacityNew(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.warning.withOpacityNew(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('⚡'),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${_bounty.round()} coins will be locked immediately.',
                          style: AppTypography.bodyM(color: AppColors.warning),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SortoButton(
                  label: 'Post Dare ⚡',
                  isLoading: createState.isSubmitting,
                  onPressed: createState.isSubmitting ? null : _submit,
                ),
                const SizedBox(height: 12),
                SortoButton(
                  label: 'Edit',
                  variant: SortoButtonVariant.ghost,
                  onPressed: () {
                    _pageCtrl.jumpToPage(0);
                    setState(() => _currentStep = 0);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepWrapper extends StatelessWidget {
  const _StepWrapper({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: child,
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.step,
    required this.title,
    required this.subtitle,
  });
  final int step;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step $step of 6',
          style: AppTypography.labelM(color: AppColors.primary),
        ),
        const SizedBox(height: 6),
        Text(title, style: AppTypography.displayS()),
        const SizedBox(height: 6),
        Text(subtitle, style: AppTypography.bodyM()),
      ],
    );
  }
}

class _StepProgressBar extends StatelessWidget {
  const _StepProgressBar({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: (current + 1) / total,
      backgroundColor: Theme.of(context).dividerColor,
      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
      minHeight: 3,
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.title,
    required this.description,
    required this.category,
    required this.mode,
    required this.bounty,
    required this.expiresAt,
  });

  final String title;
  final String description;
  final String category;
  final DareMode mode;
  final int bounty;
  final DateTime? expiresAt;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DareModeBadge(mode: mode),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacityNew(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  category,
                  style: AppTypography.labelS(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTypography.headingS()),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTypography.bodyM(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CoinAmount(amount: bounty, size: CoinAmountSize.medium),
              const Spacer(),
              if (expiresAt != null)
                Text(
                  'Expires ${Formatters.fullDateTime(expiresAt!)}',
                  style: AppTypography.bodyS(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
