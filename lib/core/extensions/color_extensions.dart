import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  // ignore: deprecated_member_use
  /// A replacement for the deprecated [withOpacity] method.
  /// Uses [withValues] internally with the provided [opacity] as alpha.
  Color withOpacityNew(double opacity) {
    return withValues(alpha: opacity.clamp(0.0, 1.0));
  }
}
