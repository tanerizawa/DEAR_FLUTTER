import 'package:flutter/material.dart';

/// Journal Theme System dengan Color Psychology, Fibonacci & Golden Ratio
/// Updated to Dark Theme untuk kenyamanan jangka panjang
class JournalTheme {
  // Color Psychology untuk Mood States (Enhanced untuk Dark Background)
  static const Map<String, Color> moodColors = {
    'senang': Color(0xFFFFD54F),    // Warm yellow - energetic, optimistic (lebih warm)
    'sedih': Color(0xFF64B5F6),     // Soft blue - calming, supportive
    'marah': Color(0xFFEF5350),     // Softer red - controlled, not aggressive  
    'cemas': Color(0xFFCE93D8),     // Warmer lavender - soothing, stress-relief
    'netral': Color(0xFF81C784),    // Soft green - balanced, peaceful
    'bersyukur': Color(0xFF9CCC65), // Brighter green - growth, appreciation
    'bangga': Color(0xFFBA68C8),    // Purple - achievement, dignity
    'takut': Color(0xFF90CAF9),     // Light blue - supportive, gentle
    'kecewa': Color(0xFFFFB74D),    // Warm orange - understanding, warmth
  };

  // Dark Theme Colors (Konsisten dengan Home Tab)
  static const Color surface = Color(0xFF0A0A0A);           // True black untuk OLED
  static const Color surfaceVariant = Color(0xFF1A1A1A);    // Elevated surfaces
  static const Color surfaceContainer = Color(0xFF2A2A2A);  // Cards & containers
  static const Color outline = Color(0xFF404040);           // Borders & dividers
  
  // Background Colors (Dark Theme)
  static const Color primaryBackground = Color(0xFF0A0A0A);     // True black
  static const Color secondaryBackground = Color(0xFF1A1A1A);  // Elevated
  static const Color cardBackground = Color(0xFF2A2A2A);       // Cards
  static const Color cardBackgroundHover = Color(0xFF363636);  // Hover state
  
  // Accent Colors (Calming & Mindful)
  static const Color accentPrimary = Color(0xFF26A69A);        // Mindful teal (sama dengan home)
  static const Color accentSecondary = Color(0xFFFFD54F);      // Warm yellow
  
  // Text Colors (High Contrast untuk Accessibility)
  static const Color textPrimary = Color(0xFFFFFFFF);         // Pure white - 21:1 contrast
  static const Color textSecondary = Color(0xFFE8E8E8);       // Light gray - 15.3:1 contrast
  static const Color textTertiary = Color(0xFFB8B8B8);        // Medium gray - 7.7:1 contrast
  static const Color textDisabled = Color(0xFF666666);        // Disabled text

  // Dark Theme Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surface, surfaceVariant],
    stops: [0.0, 1.0],
  );

  static LinearGradient moodGradient(String mood) {
    final baseColor = getMoodColor(mood);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor.withValues(alpha: 0.15),    // More visible pada dark background
        baseColor.withValues(alpha: 0.08),
      ],
    );
  }

  // Mood-adaptive ambient background
  static LinearGradient getMoodAmbient(String mood) {
    final baseColor = getMoodColor(mood);
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        surface,                              // Base dark
        baseColor.withValues(alpha: 0.05),    // Very subtle mood tint
      ],
    );
  }

  // Helper Methods
  static Color getMoodColor(String mood) {
    final key = mood.toLowerCase();
    for (final entry in moodColors.entries) {
      if (key.contains(entry.key)) {
        return entry.value;
      }
    }
    return moodColors['netral']!;
  }

  static Color getMoodColorWithOpacity(String mood, double opacity) {
    return getMoodColor(mood).withValues(alpha: opacity);
  }
}

/// Enhanced Fibonacci Spacing System dengan Golden Ratio
class FibonacciSpacing {
  static const double xxs = 3.0;   // F3
  static const double xs = 5.0;    // F4 (adjusted from 8.0)
  static const double sm = 8.0;    // F5 (adjusted from 13.0)
  static const double md = 13.0;   // F6 (adjusted from 21.0)
  static const double lg = 21.0;   // F7 (adjusted from 34.0)
  static const double xl = 34.0;   // F8 (adjusted from 55.0)
  static const double xxl = 55.0;  // F9 (adjusted from 89.0)
  static const double xxxl = 89.0; // F10
  
  // Golden ratio derived spacing
  static double goldenSpacing(double base) => base * GoldenRatio.phi;
  static double inverseGoldenSpacing(double base) => base / GoldenRatio.phi;
}

/// Golden Ratio Implementation
class GoldenRatio {
  static const double phi = 1.618033988749;
  
  static double scale(double base) => base * phi;
  static double scaleDown(double base) => base / phi;
  
  // Common golden ratio sizes
  static const double cardHeight = 144.0;        // 89 * phi
  static const double iconSize = 34.0;           // Base Fibonacci
  static const double iconSizeLarge = 55.0;      // iconSize * phi
  static const double titleFont = 21.0;          // Fibonacci
  static const double subtitleFont = 13.0;       // Fibonacci
  static const double bodyFont = 16.0;           // Close to golden ratio
  
  // Enhanced golden ratio layout values
  static const double fabSize = 89.0;            // Fibonacci F10
  static const double appBarHeight = 91.0;       // ~56 * phi
  static const double cardRadius = 21.0;         // Fibonacci F7
  static const double buttonRadius = 13.0;       // Fibonacci F6
  static const double inputHeight = 144.0;       // Golden ratio based
  static const double listItemHeight = 89.0;     // Fibonacci F10
  
  // Golden ratio proportions
  static double getGoldenHeight(double width) => width / phi;
  static double getGoldenWidth(double height) => height * phi;
  
  // Golden section spacing
  static double spacing(int fibonacciIndex) {
    const fibSequence = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144];
    if (fibonacciIndex >= 0 && fibonacciIndex < fibSequence.length) {
      return fibSequence[fibonacciIndex].toDouble();
    }
    return 8.0; // Default fallback
  }
}

/// Typography System
class JournalTypography {
  static const TextStyle heading1 = TextStyle(
    fontSize: GoldenRatio.titleFont,
    fontWeight: FontWeight.w700,
    color: JournalTheme.textPrimary,
    height: 1.3,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 18.0, // titleFont * 0.85
    fontWeight: FontWeight.w600,
    color: JournalTheme.textPrimary,
    height: 1.4,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: GoldenRatio.bodyFont,
    fontWeight: FontWeight.w400,
    color: JournalTheme.textPrimary,
    height: 1.5,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: GoldenRatio.subtitleFont,
    fontWeight: FontWeight.w400,
    color: JournalTheme.textSecondary,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: JournalTheme.textTertiary,
    height: 1.3,
  );

  static TextStyle moodLabel(String mood) => TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    color: JournalTheme.getMoodColor(mood),
    height: 1.2,
  );
}

/// Shadow System (Enhanced untuk Dark Theme)
class JournalShadows {
  // Enhanced shadows untuk dark background
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x40000000),     // Darker shadow untuk visibility
    offset: Offset(0, 4),
    blurRadius: 16,
    spreadRadius: 0,
  );

  static const BoxShadow cardShadowHover = BoxShadow(
    color: Color(0x60000000),     // More prominent pada hover
    offset: Offset(0, 8),
    blurRadius: 24,
    spreadRadius: 0,
  );

  static const BoxShadow fabShadow = BoxShadow(
    color: Color(0x80000000),     // Strong shadow untuk FAB
    offset: Offset(0, 6),
    blurRadius: 20,
    spreadRadius: 0,
  );

  // Accent glow effects untuk mood colors
  static BoxShadow moodGlow(Color moodColor) => BoxShadow(
    color: moodColor.withValues(alpha: 0.3),
    offset: const Offset(0, 0),
    blurRadius: 12,
    spreadRadius: 0,
  );

  // Subtle inner glow untuk cards
  static const BoxShadow innerGlow = BoxShadow(
    color: Color(0x1A26A69A),     // Subtle accent glow
    offset: Offset(0, 1),
    blurRadius: 8,
    spreadRadius: -2,
  );
}

/// Border Radius System (Golden Ratio Based)
class JournalBorderRadius {
  static const double xs = 5.0;         // Small elements
  static const double sm = 8.0;         // Buttons, chips
  static const double md = 13.0;        // Cards, containers (Fibonacci)
  static const double lg = 21.0;        // Large cards (Fibonacci)
  static const double xl = 34.0;        // Hero elements (Fibonacci)

  static BorderRadius circular(double radius) => BorderRadius.circular(radius);
  static BorderRadius all(double radius) => BorderRadius.circular(radius);
  static BorderRadius only({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) => BorderRadius.only(
    topLeft: Radius.circular(topLeft),
    topRight: Radius.circular(topRight),
    bottomLeft: Radius.circular(bottomLeft),
    bottomRight: Radius.circular(bottomRight),
  );
}

/// Animation Durations (Enhanced)
class JournalAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  // Enhanced curves for better feel
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve bounce = Curves.elasticOut;
}

/// Enhanced Constants untuk Dark Theme
class JournalConstants {
  // Border colors untuk dark theme
  static const Color borderPrimary = Color(0xFF404040);     // Main borders
  static const Color borderSecondary = Color(0xFF2A2A2A);   // Subtle borders
  static const Color borderAccent = Color(0xFF26A69A);      // Accent borders
  
  // Interactive states
  static const Color hoverOverlay = Color(0x0DFFFFFF);      // 5% white overlay
  static const Color pressedOverlay = Color(0x1AFFFFFF);    // 10% white overlay
  static const Color focusOverlay = Color(0x1A26A69A);      // Accent focus
  
  // Status colors untuk dark theme
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Elevation colors
  static const Color elevation1 = Color(0xFF1A1A1A);    // Level 1 elevation
  static const Color elevation2 = Color(0xFF2A2A2A);    // Level 2 elevation  
  static const Color elevation3 = Color(0xFF363636);    // Level 3 elevation
}
