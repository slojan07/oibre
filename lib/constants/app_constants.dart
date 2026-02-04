import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'cortracker360';
  static const String appSubtitle = 'HRM System';

  // URLs
  static const String hrmUrl = 'https://oibre-crm.web.app/#/dashboard';

  // Colors
  static const Color primaryColor = Color(0xFF1a237e);
  static const Color secondaryColor = Color(0xFF3949ab);
  static const Color accentColor = Color(0xFF5e35b1);

  // Animation Durations
  static const Duration splashAnimationDuration = Duration(milliseconds: 800);
  static const Duration textFadeDuration = Duration(milliseconds: 600);
  static const Duration fadeOutDuration = Duration(milliseconds: 500);
  static const Duration splashDelay = Duration(seconds: 3);

  // Sizes
  static const double appBarHeight = 70.0;
  static const double logoSize = 80.0;
  static const double iconSize = 24.0;
  static const double smallIconSize = 20.0;

  // Spacing
  static const double defaultPadding = 16.0;
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 12.0;
  static const double largeSpacing = 32.0;
  static const double extraLargeSpacing = 40.0;
  static const double hugeSpacing = 60.0;

  // Border Radius
  static const double defaultBorderRadius = 8.0;
  static const double mediumBorderRadius = 12.0;

  // Shadows
  static const BoxShadow defaultShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow strongShadow = BoxShadow(
    color: Colors.black26,
    blurRadius: 16,
    offset: Offset(0, 4),
  );
}