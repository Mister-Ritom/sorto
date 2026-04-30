// lib/features/profile/widgets/edit_profile_sheet.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/profile.dart';
import '../../../shared/widgets/sorto_button.dart';
import '../profile_provider.dart';
import 'package:sorto/core/extensions/color_extensions.dart';
import 'package:sorto/core/extensions/error_extensions.dart';

class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({super.key, required this.profile});
  final Profile profile;

  static Future<void> show(BuildContext context, Profile profile) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileSheet(profile: profile),
    );
  }

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  XFile? _imageFile;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.displayName);
    _bioController = TextEditingController(text: widget.profile.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (image != null) {
      setState(() => _imageFile = image);
    }
  }

  Future<void> _save() async {
    final notifier = ref.read(editProfileProvider.notifier);

    List<int>? avatarBytes;
    if (_imageFile != null) {
      avatarBytes = await _imageFile!.readAsBytes();
    }

    final success = await notifier.save(
      userId: widget.profile.id,
      displayName: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      avatarBytes: avatarBytes,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      final state = ref.read(editProfileProvider);
      if (state is AsyncError) {
        setState(() => _localError = state.error.toUserFriendlyMessage());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottomInset),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withOpacityNew(
                  0.1,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Edit Profile',
            style: AppTypography.headingL(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Avatar Picker
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacityNew(0.3),
                        width: 2,
                      ),
                      gradient:
                          _imageFile == null && widget.profile.avatarUrl == null
                          ? AppColors.brandGradientDiagonal
                          : null,
                    ),
                    child: ClipOval(
                      child: _imageFile != null
                          ? Image.file(
                              File(_imageFile!.path),
                              fit: BoxFit.cover,
                            )
                          : (widget.profile.avatarUrl != null
                                ? Image.network(
                                    widget.profile.avatarUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child: Text(
                                      widget.profile.username[0].toUpperCase(),
                                      style: AppTypography.displayM(
                                        color: Colors.white,
                                      ),
                                    ),
                                  )),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Name Field
          _buildField(
            label: 'Display Name',
            controller: _nameController,
            hint: 'How you appear to others',
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // Bio Field
          _buildField(
            label: 'Bio',
            controller: _bioController,
            hint: 'Tell us about yourself...',
            maxLines: 3,
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          if (_localError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacityNew(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.error.withOpacityNew(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _localError!,
                        style: AppTypography.bodyS(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ).animate().shake(duration: 400.ms),
            ),

          SortoButton(
            label: 'Save Changes',
            onPressed: _save,
            isLoading: ref.watch(editProfileProvider).isLoading,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.labelS(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ).copyWith(letterSpacing: 1.1),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTypography.bodyL(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyL(
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.darkCardBorder
                    : AppColors.lightCardBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
