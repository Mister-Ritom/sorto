// lib/features/dares/screens/proof_review_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/dare.dart';
import '../../../shared/widgets/sorto_button.dart';
import '../dares_provider.dart';

class ProofReviewScreen extends ConsumerStatefulWidget {
  const ProofReviewScreen({
    super.key,
    required this.dareId,
    required this.submissionId,
  });
  final String dareId;
  final String submissionId;

  @override
  ConsumerState<ProofReviewScreen> createState() => _ProofReviewScreenState();
}

class _ProofReviewScreenState extends ConsumerState<ProofReviewScreen> {
  VideoPlayerController? _vpCtrl;
  final _rejectReasonCtrl = TextEditingController();
  bool _showRejectPanel = false;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
    _rejectReasonCtrl.addListener(() => setState(() {}));
  }

  Future<void> _initVideo(String? signedUrl) async {
    if (signedUrl == null || _videoInitialized) return;
    _videoInitialized = true;
    final ctrl = VideoPlayerController.networkUrl(Uri.parse(signedUrl));
    await ctrl.initialize();
    ctrl.setLooping(true);
    ctrl.play();
    setState(() => _vpCtrl = ctrl);
  }

  @override
  void dispose() {
    _vpCtrl?.dispose();
    _rejectReasonCtrl.dispose();
    super.dispose();
  }

  bool get _canReject =>
      _rejectReasonCtrl.text.trim().length >=
      AppConstants.minRejectionReasonLength;

  Future<void> _approve() async {
    HapticFeedback.mediumImpact();
    final ok = await ref.read(settleDareProvider.notifier).approve(
          dareId: widget.dareId,
          submissionId: widget.submissionId,
        );
    if (!mounted) return;
    if (ok) {
      HapticFeedback.heavyImpact();
      _showApprovedDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to approve'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _reject() async {
    if (!_canReject) return;
    HapticFeedback.mediumImpact();
    final ok = await ref.read(settleDareProvider.notifier).reject(
      dareId: widget.dareId,
      submissionId: widget.submissionId,
      reason: _rejectReasonCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to reject'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showApprovedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✅', style: TextStyle(fontSize: 56))
                .animate()
                .scale(curve: Curves.elasticOut, duration: 600.ms),
            const SizedBox(height: 16),
            Text('Dare approved!', style: AppTypography.headingL()),
            const SizedBox(height: 8),
            Text(
              'Coins have been settled. The performer has been paid.',
              style: AppTypography.bodyM(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SortoButton(
              label: 'Done',
              onPressed: () {
                Navigator.pop(context);
                context.go(Routes.home);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final submissionsAsync = ref.watch(dareSubmissionsProvider(widget.dareId));
    final dareAsync = ref.watch(dareDetailProvider(widget.dareId));
    final settleState = ref.watch(settleDareProvider);
    final isLoading = settleState is AsyncLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text('Review Proof', style: AppTypography.headingM()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: submissionsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (submissions) {
          final submission = submissions.where((s) => s.id == widget.submissionId).firstOrNull;
          if (submission == null) {
            return Center(child: Text('Submission not found', style: AppTypography.headingS()));
          }

          // Init video if we have a signed URL
          if (submission.proofVideoUrl != null && !_videoInitialized) {
            WidgetsBinding.instance.addPostFrameCallback(
                (_) => _initVideo(submission.proofVideoUrl));
          }

          final aiConfidence = submission.aiConfidence ?? 0;
          final showWarningBanner = aiConfidence < 0.90 &&
              aiConfidence >= AppConstants.warningBannerThreshold;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Warning banner if AI flagged ─────────────────────────
                if (showWarningBanner)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: AppColors.warning.withOpacity(0.15),
                    child: Row(
                      children: [
                        const Text('⚠️', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Our system flagged potentially concerning content. Review carefully before approving.',
                            style: AppTypography.bodyM(color: AppColors.warning),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                // ── Video player ─────────────────────────────────────────
                if (_vpCtrl != null && _vpCtrl!.value.isInitialized)
                  GestureDetector(
                    onTap: () {
                      if (_vpCtrl!.value.isPlaying) {
                        _vpCtrl!.pause();
                      } else {
                        _vpCtrl!.play();
                      }
                      setState(() {});
                    },
                    child: AspectRatio(
                      aspectRatio: _vpCtrl!.value.aspectRatio,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          VideoPlayer(_vpCtrl!),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: _VideoProgressSlider(ctrl: _vpCtrl!),
                          ),
                          Center(
                            child: AnimatedOpacity(
                              opacity: _vpCtrl!.value.isPlaying ? 0 : 1,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: Colors.black45,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms)
                else
                  Container(
                    height: 250,
                    color: AppColors.darkCard,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── AI verdict ───────────────────────────────────────
                      _AiVerdictCard(
                        verdict: submission.aiVerdict ?? 'pending',
                        confidence: aiConfidence,
                        reason: (submission.proofText),
                      ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 16),

                      // ── Dare reference ───────────────────────────────────
                      dareAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (dare) => dare != null
                            ? _DareReference(dare: dare)
                            : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 24),

                      // ── Performer note ───────────────────────────────────
                      if (submission.proofText != null) ...[
                        Text("Performer's note",
                            style: AppTypography.labelM(
                                color: AppColors.darkTextSecondary)),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.darkCard,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(submission.proofText!,
                              style: AppTypography.bodyM()),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ── Actions ──────────────────────────────────────────
                      if (!_showRejectPanel) ...[
                        SortoButton(
                          label: '✅ Approve',
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _approve,
                        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 12),
                        SortoButton(
                          label: '❌ Reject',
                          variant: SortoButtonVariant.danger,
                          onPressed: isLoading ? null : () => setState(() => _showRejectPanel = true),
                        ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),
                      ] else ...[
                        // ── Rejection panel ──────────────────────────────
                        Text('Why are you rejecting this?',
                            style: AppTypography.headingS())
                            .animate().fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0),
                        const SizedBox(height: 8),
                        Text(
                          'You must provide a reason (min ${AppConstants.minRejectionReasonLength} chars). '
                          'Bad-faith rejections result in a strike.',
                          style: AppTypography.bodyS(color: AppColors.warning),
                        ).animate(delay: 100.ms).fadeIn(),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _rejectReasonCtrl,
                          maxLines: 4,
                          maxLength: 500,
                          decoration: InputDecoration(
                            hintText: 'e.g. The timer was not visible. The face expression was exaggerated...',
                            counterText:
                                '${_rejectReasonCtrl.text.length}/${AppConstants.minRejectionReasonLength} min',
                            counterStyle: AppTypography.bodyS(
                                color: _canReject
                                    ? AppColors.success
                                    : AppColors.error),
                          ),
                        ).animate(delay: 200.ms).fadeIn(),
                        const SizedBox(height: 16),
                        SortoButton(
                          label: 'Confirm Rejection',
                          variant: SortoButtonVariant.danger,
                          isLoading: isLoading,
                          onPressed: (_canReject && !isLoading) ? _reject : null,
                        ),
                        const SizedBox(height: 12),
                        SortoButton(
                          label: 'Cancel',
                          variant: SortoButtonVariant.ghost,
                          onPressed: () => setState(() {
                            _showRejectPanel = false;
                            _rejectReasonCtrl.clear();
                          }),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AiVerdictCard extends StatelessWidget {
  const _AiVerdictCard({
    required this.verdict,
    required this.confidence,
    this.reason,
  });
  final String verdict;
  final double confidence;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (verdict) {
      'approved' => (AppColors.success, '🤖', 'AI: Approved'),
      'rejected' => (AppColors.error, '🤖', 'AI: Rejected'),
      'escalated' => (AppColors.warning, '🤖', 'AI: Needs Review'),
      _ => (AppColors.darkTextSecondary, '🤖', 'AI: Pending'),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon),
              const SizedBox(width: 8),
              Text(label, style: AppTypography.labelL(color: color)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  Formatters.confidence(confidence),
                  style: AppTypography.labelM(color: color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DareReference extends StatelessWidget {
  const _DareReference({required this.dare});
  final Dare dare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('The dare contract',
              style: AppTypography.labelM(color: AppColors.darkTextSecondary)),
          const SizedBox(height: 6),
          Text(dare.title, style: AppTypography.headingS()),
          const SizedBox(height: 4),
          Text(dare.description,
              style: AppTypography.bodyM(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _VideoProgressSlider extends StatefulWidget {
  const _VideoProgressSlider({required this.ctrl});
  final VideoPlayerController ctrl;

  @override
  State<_VideoProgressSlider> createState() => _VideoProgressSliderState();
}

class _VideoProgressSliderState extends State<_VideoProgressSlider> {
  @override
  void initState() {
    super.initState();
    widget.ctrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final position = widget.ctrl.value.position;
    final duration = widget.ctrl.value.duration;
    if (duration.inMilliseconds == 0) return const SizedBox.shrink();

    return SizedBox(
      width: 200,
      child: VideoProgressIndicator(
        widget.ctrl,
        allowScrubbing: true,
        colors: const VideoProgressColors(
          playedColor: AppColors.primary,
          bufferedColor: Colors.white30,
          backgroundColor: Colors.white12,
        ),
      ),
    );
  }
}
