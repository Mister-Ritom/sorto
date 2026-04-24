// lib/features/dares/screens/submit_proof_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/widgets/sorto_button.dart';
import '../dares_provider.dart';

class SubmitProofScreen extends ConsumerStatefulWidget {
  const SubmitProofScreen({super.key, required this.dareId});
  final String dareId;

  @override
  ConsumerState<SubmitProofScreen> createState() => _SubmitProofScreenState();
}

class _SubmitProofScreenState extends ConsumerState<SubmitProofScreen> {
  XFile? _pickedVideo;
  VideoPlayerController? _vpCtrl;
  final _descCtrl = TextEditingController();
  bool _uploading = false;
  double _uploadProgress = 0;

  @override
  void dispose() {
    _vpCtrl?.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickVideo(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(
      source: source,
      maxDuration: const Duration(minutes: 3),
    );
    if (picked == null) return;

    final VideoPlayerController vpCtrl;
    if (kIsWeb) {
      vpCtrl = VideoPlayerController.networkUrl(Uri.parse(picked.path));
    } else {
      vpCtrl = VideoPlayerController.file(io.File(picked.path));
    }

    await vpCtrl.initialize();
    vpCtrl.setLooping(true);
    vpCtrl.play();

    setState(() {
      _pickedVideo = picked;
      _vpCtrl?.dispose();
      _vpCtrl = vpCtrl;
    });
  }

  Future<void> _submit() async {
    if (_pickedVideo == null) return;
    HapticFeedback.mediumImpact();
    setState(() { _uploading = true; _uploadProgress = 0; });

    try {
      final svc = ref.read(supabaseServiceProvider);
      final userId = svc.currentUserId!;
      final path = '$userId/${widget.dareId}/${DateTime.now().millisecondsSinceEpoch}.mp4';
      final bytes = await _pickedVideo!.readAsBytes();

      // Simulate upload progress
      setState(() => _uploadProgress = 0.3);
      await svc.uploadVideo(
        filePath: path,
        bytes: bytes,
        mimeType: 'video/mp4',
      );
      setState(() => _uploadProgress = 0.8);

      final ok = await ref.read(submitProofProvider.notifier).submit(
            dareId: widget.dareId,
            videoPath: path,
            proofText: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
          );

      setState(() { _uploading = false; _uploadProgress = 1; });

      if (!mounted) return;
      if (ok) {
        HapticFeedback.heavyImpact();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.darkCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎬', style: TextStyle(fontSize: 56))
                    .animate()
                    .scale(curve: Curves.elasticOut, duration: 600.ms),
                const SizedBox(height: 16),
                Text('Proof submitted!', style: AppTypography.headingL()),
                const SizedBox(height: 8),
                Text(
                  'Our AI is reviewing it now. The poster will see it soon.',
                  style: AppTypography.bodyM(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SortoButton(
                  label: 'View Dare',
                  onPressed: () {
                    Navigator.pop(context);
                    context.go(Routes.dareDetailPath(widget.dareId));
                  },
                ),
              ],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.read(submitProofProvider).error?.toString() ?? 'Upload failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() { _uploading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Proof', style: AppTypography.headingM()),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Video picker ────────────────────────────────────────────
            if (_pickedVideo == null) ...[
              Text('Upload your proof video', style: AppTypography.headingM())
                  .animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                'Max 3 minutes. Must show you completing the dare.',
                style: AppTypography.bodyM(color: AppColors.darkTextSecondary),
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _VideoSourceButton(
                      icon: Icons.videocam_rounded,
                      label: 'Record Now',
                      onTap: () => _pickVideo(ImageSource.camera),
                    ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _VideoSourceButton(
                      icon: Icons.video_library_rounded,
                      label: 'From Gallery',
                      onTap: () => _pickVideo(ImageSource.gallery),
                    ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
                  ),
                ],
              ),
            ] else ...[
              // ── Preview ─────────────────────────────────────────────
              GestureDetector(
                onTap: () {
                  if (_vpCtrl!.value.isPlaying) {
                    _vpCtrl!.pause();
                  } else {
                    _vpCtrl!.play();
                  }
                  setState(() {});
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: _vpCtrl!.value.aspectRatio,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        VideoPlayer(_vpCtrl!),
                        Center(
                          child: AnimatedOpacity(
                            opacity: _vpCtrl!.value.isPlaying ? 0 : 1,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  _vpCtrl?.dispose();
                  setState(() {
                    _pickedVideo = null;
                    _vpCtrl = null;
                  });
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Choose different video'),
              ),
            ],

            const SizedBox(height: 24),

            // ── Optional description ─────────────────────────────────────
            Text('Add a note (optional)',
                style: AppTypography.labelL()).animate(delay: 400.ms).fadeIn(),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Anything you want the poster to know...',
              ),
            ).animate(delay: 500.ms).fadeIn(),

            const SizedBox(height: 32),

            // ── Upload progress ──────────────────────────────────────────
            if (_uploading)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Uploading... ${(_uploadProgress * 100).round()}%',
                      style: AppTypography.bodyM(color: AppColors.primary)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _uploadProgress,
                    color: AppColors.primary,
                    backgroundColor: AppColors.darkCardBorder,
                  ),
                  const SizedBox(height: 24),
                ],
              ).animate().fadeIn(duration: 300.ms),

            // ── Submit ───────────────────────────────────────────────────
            SortoButton(
              label: 'Submit Proof',
              isLoading: _uploading,
              onPressed:
                  (_pickedVideo != null && !_uploading) ? _submit : null,
            ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }
}

class _VideoSourceButton extends StatelessWidget {
  const _VideoSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.darkCardBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.brandGradientDiagonal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(label, style: AppTypography.labelL()),
          ],
        ),
      ),
    );
  }
}
