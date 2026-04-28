// lib/features/performer_posts/screens/create_performer_post_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/sorto_button.dart';
import '../performer_posts_provider.dart';
import 'package:sorto/core/extensions/color_extensions.dart';

class CreatePerformerPostScreen extends ConsumerStatefulWidget {
  const CreatePerformerPostScreen({super.key});

  @override
  ConsumerState<CreatePerformerPostScreen> createState() =>
      _CreatePerformerPostScreenState();
}

class _CreatePerformerPostScreenState
    extends ConsumerState<CreatePerformerPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _selectedCategory;
  double _askingPrice = 100.0;
  final _askingPriceCtrl = TextEditingController(text: '100');
  DateTime? _deadline;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _askingPriceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category and deadline.')),
      );
      return;
    }
    HapticFeedback.mediumImpact();

    final postId = await ref
        .read(createPostProvider.notifier)
        .create(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          category: _selectedCategory!,
          askingPrice: _askingPrice.round(),
          deadline: _deadline!,
        );

    if (!mounted) return;
    if (postId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎬 Creator post published!')),
      );
      context.go(Routes.performerPostDetailPath(postId));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create post'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final createState = ref.watch(createPostProvider);
    final isLoading = createState is AsyncLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text('Creator Post', style: AppTypography.headingM()),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell posters what you\'ll do',
                style: AppTypography.displayS(),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 6),
              Text(
                'Posters fund your post. You complete the dare and earn coins.',
                style: AppTypography.bodyM(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 28),

              // Title
              TextFormField(
                controller: _titleCtrl,
                maxLength: AppConstants.dareTitleMaxLength,
                textCapitalization: TextCapitalization.sentences,
                validator: Validators.dareTitle,
                decoration: const InputDecoration(
                  labelText: 'What will you do?',
                  hintText: 'e.g. I will eat whatever hot sauce you pick',
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                maxLength: AppConstants.dareDescriptionMaxLength,
                textCapitalization: TextCapitalization.sentences,
                validator: Validators.dareDescription,
                decoration: const InputDecoration(
                  labelText: 'Full details',
                  hintText:
                      'Describe exactly what you\'ll do and any conditions...',
                  alignLabelWithHint: true,
                ),
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 24),

              // Category
              Text(
                'Category',
                style: AppTypography.labelL(),
              ).animate(delay: 400.ms).fadeIn(),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.dareCategories.map((cat) {
                  final emoji = AppConstants.categoryEmoji[cat] ?? '🎯';
                  final sel = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedCategory = cat);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.primary.withOpacityNew(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: sel
                              ? AppColors.primary
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Text(
                        '$emoji $cat',
                        style: AppTypography.labelM(
                          color: sel ? AppColors.primary : null,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ).animate(delay: 450.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              // Asking price
              Text(
                'Asking price (SC)',
                style: AppTypography.labelL(),
              ).animate(delay: 500.ms).fadeIn(),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 8),
                    IntrinsicWidth(
                      child: TextField(
                        controller: _askingPriceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: false,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        onChanged: (v) {
                          final val = double.tryParse(v);
                          if (val != null) setState(() => _askingPrice = val);
                        },
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
              ).animate(delay: 550.ms).fadeIn(),

              const SizedBox(height: 24),

              // Deadline
              Text(
                'Deadline',
                style: AppTypography.labelL(),
              ).animate(delay: 600.ms).fadeIn(),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                      ('1 day', const Duration(days: 1)),
                      ('3 days', const Duration(days: 3)),
                      ('1 week', const Duration(days: 7)),
                      ('2 weeks', const Duration(days: 14)),
                    ].map((opt) {
                      final (label, dur) = opt;
                      final dt = DateTime.now().add(dur);
                      final sel =
                          _deadline != null &&
                          (_deadline!.difference(dt).inHours.abs() < 2);
                      return GestureDetector(
                        onTap: () => setState(() => _deadline = dt),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.primary.withOpacityNew(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: sel
                                  ? AppColors.primary
                                  : Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Text(
                            label,
                            style: AppTypography.labelM(
                              color: sel ? AppColors.primary : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ).animate(delay: 650.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 32),

              SortoButton(
                    label: 'Publish Post',
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _submit,
                  )
                  .animate(delay: 700.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
