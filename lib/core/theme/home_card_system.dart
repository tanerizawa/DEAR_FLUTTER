// lib/core/theme/home_card_system.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dear_flutter/core/theme/mood_color_system.dart';

/// Enhanced Card Design System for Home Screen
/// Implements depth, consistency, and accessibility
class HomeCardSystem {
  // Border radius constants based on design system
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 20.0;
  static const double radiusLarge = 28.0;
  static const double radiusXLarge = 34.0; // Golden ratio derived
  
  // Shadow system for depth perception
  static const List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 8.0,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Color(0x26000000), // 15% black
      blurRadius: 16.0,
      offset: Offset(0, 4),
      spreadRadius: 1,
    ),
    BoxShadow(
      color: Color(0x0D000000), // 5% black
      blurRadius: 4.0,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> strongShadow = [
    BoxShadow(
      color: Color(0x33000000), // 20% black
      blurRadius: 24.0,
      offset: Offset(0, 8),
      spreadRadius: 2,
    ),
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 6.0,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  /// Primary card decoration for quotes and main content
  static BoxDecoration primaryCard({
    required BuildContext context,
    Gradient? gradient,
    Color? backgroundColor,
    bool elevated = true,
    BorderRadius? customRadius,
  }) {
    final defaultGradient = gradient ?? _getDefaultGradient(context);
    
    return BoxDecoration(
      borderRadius: customRadius ?? BorderRadius.circular(radiusLarge),
      gradient: backgroundColor == null ? defaultGradient : null,
      color: backgroundColor,
      boxShadow: elevated ? mediumShadow : lightShadow,
      border: Border.all(
        color: Colors.white.withOpacity(0.15),
        width: 1.0,
      ),
    );
  }
  
  /// Secondary card decoration for media players and less prominent content
  static BoxDecoration secondaryCard({
    required BuildContext context,
    Color? backgroundColor,
    bool elevated = false,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radiusMedium),
      color: backgroundColor ?? _getSecondaryColor(context),
      boxShadow: elevated ? lightShadow : [],
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
        width: 0.5,
      ),
    );
  }
  
  /// Floating action button style decoration
  static BoxDecoration floatingButton({
    required Color primaryColor,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radiusXLarge),
      gradient: LinearGradient(
        colors: [
          primaryColor,
          primaryColor.withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: isPressed ? lightShadow : strongShadow,
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1.0,
      ),
    );
  }
  
  /// Glass morphism effect for modern cards
  static BoxDecoration glassMorphism({
    Color? backgroundColor,
    double blur = 10.0,
    double opacity = 0.1,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radiusLarge),
      color: (backgroundColor ?? Colors.white).withOpacity(opacity),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: blur,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
  
  /// Button decoration with proper touch feedback
  static BoxDecoration buttonDecoration({
    required Color primaryColor,
    bool isPressed = false,
    bool isOutlined = false,
    bool isSmall = false,
  }) {
    final radius = isSmall ? radiusSmall : radiusMedium;
    
    if (isOutlined) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: Colors.transparent,
        border: Border.all(
          color: primaryColor,
          width: 2.0,
        ),
        boxShadow: isPressed ? [] : lightShadow,
      );
    }
    
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        colors: [
          primaryColor,
          primaryColor.withOpacity(0.9),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      boxShadow: isPressed ? [] : mediumShadow,
    );
  }
  
  /// Icon container decoration
  static BoxDecoration iconContainer({
    required Color primaryColor,
    bool isLarge = false,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(isLarge ? radiusMedium : radiusSmall),
      color: primaryColor.withOpacity(0.15),
      border: Border.all(
        color: primaryColor.withOpacity(0.3),
        width: 1.0,
      ),
    );
  }
  
  /// Get decoration with mood-adaptive colors
  static BoxDecoration moodAdaptiveCard({
    required BuildContext context,
    String? mood,
    bool elevated = true,
  }) {
    final moodTheme = MoodColorSystem.getMoodTheme(mood);
    final gradient = moodTheme['primaryGradient'] as List<Color>?;
    
    return primaryCard(
      context: context,
      gradient: gradient != null ? LinearGradient(
        colors: gradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ) : null,
      elevated: elevated,
    );
  }
  
  /// Create backdrop filter widget for glassmorphism
  static Widget createBackdropFilter({
    required Widget child,
    double sigmaX = 10.0,
    double sigmaY = 10.0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: child,
      ),
    );
  }
  
  /// Helper method to get default gradient
  static LinearGradient _getDefaultGradient(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    if (brightness == Brightness.dark) {
      return const LinearGradient(
        colors: [
          Color(0xFF2D3748),
          Color(0xFF1A202C),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return const LinearGradient(
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFF7FAFC),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }
  
  /// Helper method to get secondary background color
  static Color _getSecondaryColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    if (brightness == Brightness.dark) {
      return Colors.white.withOpacity(0.05);
    } else {
      return Colors.black.withOpacity(0.03);
    }
  }
}

/// Predefined card styles for common use cases
class HomeCardPresets {
  /// Quote card with enhanced styling
  static BoxDecoration quoteCard(BuildContext context, {String? mood}) {
    return HomeCardSystem.moodAdaptiveCard(
      context: context,
      mood: mood,
      elevated: true,
    );
  }
  
  /// Media player card
  static BoxDecoration mediaCard(BuildContext context) {
    return HomeCardSystem.secondaryCard(
      context: context,
      elevated: false,
    );
  }
  
  /// Section header icon container
  static BoxDecoration sectionIcon(Color primaryColor) {
    return HomeCardSystem.iconContainer(
      primaryColor: primaryColor,
      isLarge: false,
    );
  }
  
  /// Primary action button
  static BoxDecoration primaryButton(Color primaryColor, {bool isPressed = false}) {
    return HomeCardSystem.buttonDecoration(
      primaryColor: primaryColor,
      isPressed: isPressed,
    );
  }
  
  /// Secondary outline button
  static BoxDecoration outlineButton(Color primaryColor, {bool isPressed = false}) {
    return HomeCardSystem.buttonDecoration(
      primaryColor: primaryColor,
      isPressed: isPressed,
      isOutlined: true,
    );
  }
  
  /// Glass morphism overlay
  static BoxDecoration glassOverlay({Color? color}) {
    return HomeCardSystem.glassMorphism(
      backgroundColor: color,
      blur: 15.0,
      opacity: 0.15,
    );
  }
}
