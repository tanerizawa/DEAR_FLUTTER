// lib/core/theme/home_layout_system.dart

import 'package:flutter/material.dart';

/// Golden Ratio Layout System for Home Screen
/// Implements mathematical proportions based on φ (phi) = 1.618
class HomeLayoutSystem {
  // Golden ratio constants
  static const double primaryRatio = 1.618; // φ (phi)
  static const double secondaryRatio = 0.618; // 1/φ
  static const double tertiaryRatio = 0.382; // 1/φ²
  
  // Base unit for calculations (in dp)
  static const double baseUnit = 89.0; // Fibonacci number F(11)
  
  // Content area heights based on golden ratio
  static const double greetingHeight = 120.0; // Current height maintained
  static const double quoteHeight = 233.0; // φ × 144 (enhanced from current 144)
  static const double mediaHeight = 144.0; // Primary golden unit
  static const double footerHeight = 89.0; // φ × 55
  
  // Section spacing based on golden ratio
  static const double sectionSpacing = 34.0; // Fibonacci F(9)
  static const double componentSpacing = 21.0; // Fibonacci F(8)
  static const double elementSpacing = 13.0; // Fibonacci F(7)
  
  /// Calculate golden ratio proportions for containers
  static Size getGoldenProportions({
    required double width,
    bool useSecondaryRatio = false,
  }) {
    final ratio = useSecondaryRatio ? secondaryRatio : primaryRatio;
    return Size(width, width / ratio);
  }
  
  /// Get responsive spacing based on screen size
  static EdgeInsets getResponsiveSpacing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;
    final isLarge = screenWidth > 900;
    
    if (isLarge) {
      return EdgeInsets.symmetric(
        horizontal: FibonacciSpacing.xl,
        vertical: FibonacciSpacing.lg,
      );
    } else if (isCompact) {
      return EdgeInsets.symmetric(
        horizontal: FibonacciSpacing.md,
        vertical: FibonacciSpacing.sm,
      );
    } else {
      return EdgeInsets.symmetric(
        horizontal: FibonacciSpacing.lg,
        vertical: FibonacciSpacing.md,
      );
    }
  }
  
  /// Calculate optimal card proportions
  static BoxConstraints getCardConstraints(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth - (FibonacciSpacing.md * 2);
    
    return BoxConstraints(
      maxWidth: maxWidth,
      minHeight: quoteHeight,
      maxHeight: quoteHeight * 1.2, // Allow slight flexibility
    );
  }
  
  /// Get section header proportions
  static double getSectionHeaderHeight() => 55.0; // Fibonacci F(10)
  
  /// Get button minimum touch target size (WCAG 2.1 AA compliance)
  static double getMinTouchTarget() => 48.0;
  
  /// Calculate media section split ratios (golden ratio based)
  static List<int> getMediaSectionFlex() => [62, 38]; // 62% music, 38% radio
}

/// Fibonacci-based spacing system
class FibonacciSpacing {
  // Fibonacci sequence numbers used for spacing
  static const double xs = 8.0;   // F(6)
  static const double sm = 13.0;  // F(7)  
  static const double md = 21.0;  // F(8)
  static const double lg = 34.0;  // F(9)
  static const double xl = 55.0;  // F(10)
  static const double xxl = 89.0; // F(11)
  
  /// Get spacing based on component type
  static double getComponentSpacing(ComponentType type) {
    switch (type) {
      case ComponentType.card:
        return md;
      case ComponentType.section:
        return lg;
      case ComponentType.element:
        return sm;
      case ComponentType.text:
        return xs;
    }
  }
  
  /// Get responsive spacing multiplier
  static double getResponsiveMultiplier(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return 0.8; // Very small screens
    if (screenWidth > 900) return 1.2; // Large screens/tablets
    return 1.0; // Standard screens
  }
}

enum ComponentType {
  card,
  section, 
  element,
  text,
}

/// Layout constraints for different screen sizes
class ResponsiveConstraints {
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
  
  /// Check if current screen is mobile size
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  /// Check if current screen is tablet size
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }
  
  /// Check if current screen is desktop size
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }
  
  /// Get optimal content width for current screen
  static double getContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isDesktop(context)) {
      return (screenWidth * 0.6).clamp(600.0, 800.0); // Max content width on desktop
    } else if (isTablet(context)) {
      return screenWidth * 0.8; // 80% on tablet
    } else {
      return screenWidth - (FibonacciSpacing.md * 2); // Full width minus padding on mobile
    }
  }
}
