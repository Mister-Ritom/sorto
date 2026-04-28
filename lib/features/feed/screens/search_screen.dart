// lib/features/feed/screens/search_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../feed_provider.dart';
import '../widgets/dare_card.dart';
import 'package:sorto/core/extensions/color_extensions.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  String? _selectedCategory;
  String? _selectedMode;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onSearch);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _onSearch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref
          .read(searchProvider.notifier)
          .search(
            _ctrl.text.trim(),
            category: _selectedCategory,
            mode: _selectedMode,
          );
    });
  }

  void _applyFilters() {
    ref
        .read(searchProvider.notifier)
        .search(
          _ctrl.text.trim(),
          category: _selectedCategory,
          mode: _selectedMode,
        );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resultsAsync = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          focusNode: _focus,
          style: AppTypography.bodyL(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Search dares...',
            hintStyle: AppTypography.bodyL(color: AppColors.darkTextMuted),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _ctrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _ctrl.clear();
                      ref.read(searchProvider.notifier).clear();
                    },
                  )
                : null,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Category chips ──────────────────────────────────────────────
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _selectedCategory == null,
                  onTap: () {
                    setState(() => _selectedCategory = null);
                    _applyFilters();
                  },
                ),
                ...AppConstants.dareCategories.map(
                  (cat) => _FilterChip(
                    label: cat,
                    selected: _selectedCategory == cat,
                    onTap: () {
                      setState(() {
                        _selectedCategory = _selectedCategory == cat
                            ? null
                            : cat;
                      });
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Mode filter ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Mode:',
                  style: AppTypography.labelM(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 8),
                ...[null, 'solo', 'open_split', 'open_best'].map(
                  (mode) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _FilterChip(
                      label: mode == null
                          ? 'Any'
                          : mode == 'solo'
                          ? 'Solo'
                          : mode == 'open_split'
                          ? 'Split'
                          : 'Best',
                      selected: _selectedMode == mode,
                      onTap: () {
                        setState(() => _selectedMode = mode);
                        _applyFilters();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Results ─────────────────────────────────────────────────────
          Expanded(
            child: resultsAsync.when(
              loading: () => ListView.builder(
                itemCount: 4,
                itemBuilder: (_, i) => const DareCardSkeleton(),
              ),
              error: (e, _) => Center(
                child: Text('Search failed: $e', style: AppTypography.bodyM()),
              ),
              data: (dares) {
                if (_ctrl.text.isEmpty) {
                  return _SearchHints();
                }
                if (dares.isEmpty) {
                  return _NoResults(query: _ctrl.text);
                }
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: dares.length,
                  itemBuilder: (ctx, i) => DareCard(
                    dare: dares[i],
                    animationDelay: Duration(milliseconds: i * 40),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacityNew(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelM(
            color: selected ? AppColors.primary : null,
          ),
        ),
      ),
    );
  }
}

class _SearchHints extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Popular categories', style: AppTypography.headingS()),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.dareCategories.map((cat) {
              final emoji = AppConstants.categoryEmoji[cat] ?? '🎯';
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacityNew(0.08),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: AppColors.primary.withOpacityNew(0.2),
                  ),
                ),
                child: Text(
                  '$emoji $cat',
                  style: AppTypography.labelM(color: AppColors.primary),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🔍',
            style: TextStyle(fontSize: 48),
          ).animate().scale(curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(
            'No dares for "$query"',
            style: AppTypography.headingS(),
          ).animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 8),
          Text(
            'Try different words or categories.',
            style: AppTypography.bodyM(),
          ).animate(delay: 300.ms).fadeIn(),
        ],
      ),
    );
  }
}
