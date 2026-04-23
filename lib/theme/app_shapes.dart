// lib/theme/app_shapes.dart
import 'package:flutter/material.dart';

class AppShapes {
  static const double primaryRadius = 16.0;
  static const double secondaryRadius = 24.0;
  static const double largeRadius = 32.0;

  static const Radius primaryBorderRadius = Radius.circular(primaryRadius);
  static const Radius secondaryBorderRadius = Radius.circular(secondaryRadius);

  static final RoundedRectangleBorder primaryCardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(primaryRadius),
  );

  static final RoundedRectangleBorder largeCardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(largeRadius),
  );

  static final RoundedRectangleBorder secondaryButtonShape =
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(secondaryRadius),
      );

  static final InputBorder customInputFieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(largeRadius),
    borderSide: BorderSide.none, // No border, only fill
  );
}
