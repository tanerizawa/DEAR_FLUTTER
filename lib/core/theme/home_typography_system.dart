// lib/core/theme/home_typography_system.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Enhanced Typography System for Home Screen
/// Optimized for readability, accessibility, and visual hierarchy
class HomeTypographySystem {
  // Font family constants
  static const String primaryFont = 'Montserrat';
  static const String secondaryFont = 'Merriweather'; // For quotes/reading content
  static const String monoFont = 'JetBrains Mono'; // For technical content
  
  // Font size scale based on modular scale (1.25 ratio)
  static const double baseSize = 16.0;
  static const double scale = 1.25;
  
  // Calculated font sizes
  static const double h1Size = 32.0; // baseSize * scale^3
  static const double h2Size = 25.6; // baseSize * scale^2.5
  static const double h3Size = 20.0; // baseSize * scale^1.5
  static const double bodySize = 16.0; // baseSize
  static const double captionSize = 12.8; // baseSize / scale
  static const double smallSize = 10.24; // baseSize / scale^1.5
  
  // Line height constants (optimal for readability)
  static const double headingLineHeight = 1.2;
  static const double bodyLineHeight = 1.5;
  static const double captionLineHeight = 1.4;
  
  // Letter spacing for optimal readability
  static const double headingLetterSpacing = -0.5;
  static const double bodyLetterSpacing = 0.15;
  static const double captionLetterSpacing = 0.4;
  
  /// Primary heading style (Greeting)
  static TextStyle primaryHeading({Color? color}) {
    return GoogleFonts.montserrat(
      fontSize: h1Size,
      fontWeight: FontWeight.w700,
      height: headingLineHeight,
      letterSpacing: headingLetterSpacing,
      color: color,
    );
  }
  
  /// Secondary heading style (Section headers)
  static TextStyle sectionHeader({Color? color}) {
    return GoogleFonts.montserrat(
      fontSize: h3Size,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: -0.2,
      color: color,
    );
  }
  
  /// Quote text style (Optimized for reading)
  static TextStyle quoteText({Color? color}) {
    return GoogleFonts.merriweather(
      fontSize: 18.0, // Slightly larger for quotes
      fontWeight: FontWeight.w400,
      height: bodyLineHeight,
      letterSpacing: bodyLetterSpacing,
      color: color,
      fontStyle: FontStyle.italic,
    );
  }
  
  /// Quote author style
  static TextStyle quoteAuthor({Color? color}) {
    return GoogleFonts.montserrat(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.2,
      color: color,
    );
  }
  
  /// Body text style
  static TextStyle bodyText({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.montserrat(
      fontSize: bodySize,
      fontWeight: fontWeight ?? FontWeight.w400,
      height: bodyLineHeight,
      letterSpacing: bodyLetterSpacing,
      color: color,
    );
  }
  
  /// Sub-greeting style
  static TextStyle subGreeting({Color? color}) {
    return GoogleFonts.montserrat(
      fontSize: bodySize,
      fontWeight: FontWeight.w400,
      height: 1.4,
      letterSpacing: 0.1,
      color: color,
    );
  }
  
  /// Button text style (Enhanced for accessibility)
  static TextStyle buttonText({Color? color, bool isLarge = false}) {
    return GoogleFonts.montserrat(
      fontSize: isLarge ? 16.0 : 14.0,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.1,
      color: color,
    );
  }
  
  /// Caption style (For small labels and metadata)
  static TextStyle caption({Color? color}) {
    return GoogleFonts.montserrat(
      fontSize: captionSize,
      fontWeight: FontWeight.w500,
      height: captionLineHeight,
      letterSpacing: captionLetterSpacing,
      color: color,
    );
  }
  
  /// Small text style (For very small labels)
  static TextStyle smallText({Color? color}) {
    return GoogleFonts.montserrat(
      fontSize: smallSize,
      fontWeight: FontWeight.w400,
      height: 1.3,
      letterSpacing: 0.3,
      color: color,
    );
  }
  
  /// Music/Media title style
  static TextStyle mediaTitle({Color? color}) {
    return GoogleFonts.montserrat(
      fontSize: 18.0,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.3,
      color: color,
    );
  }
  
  /// Music/Media artist style
  static TextStyle mediaArtist({Color? color}) {
    return GoogleFonts.montserrat(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      height: 1.3,
      letterSpacing: 0.1,
      color: color,
    );
  }
  
  /// Get responsive text style based on screen size
  static TextStyle responsive({
    required BuildContext context,
    required TextStyle baseStyle,
    double scaleFactor = 1.0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    // Adjust for very small screens
    if (screenWidth < 360) {
      scaleFactor *= 0.9;
    }
    // Adjust for large screens
    else if (screenWidth > 600) {
      scaleFactor *= 1.1;
    }
    
    // Respect user's text scale preference but limit extreme values
    final finalScale = (textScaleFactor * scaleFactor).clamp(0.8, 1.5);
    
    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? bodySize) * finalScale,
    );
  }
  
  /// Get contrast-compliant color based on background
  static Color getContrastColor({
    required Color backgroundColor,
    Color lightColor = Colors.white,
    Color darkColor = Colors.black87,
  }) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? darkColor : lightColor;
  }
  
  /// Apply text style with automatic contrast adjustment
  static TextStyle withAutoContrast({
    required TextStyle style,
    required Color backgroundColor,
  }) {
    final contrastColor = getContrastColor(backgroundColor: backgroundColor);
    return style.copyWith(color: style.color ?? contrastColor);
  }
}

/// Text style presets for common use cases
class HomeTextPresets {
  /// Large greeting text
  static TextStyle greeting(Color color) => HomeTypographySystem.primaryHeading(color: color);
  
  /// Sub greeting text  
  static TextStyle subGreeting(Color color) => HomeTypographySystem.subGreeting(color: color);
  
  /// Section title
  static TextStyle sectionTitle(Color color) => HomeTypographySystem.sectionHeader(color: color);
  
  /// Quote content
  static TextStyle quote(Color color) => HomeTypographySystem.quoteText(color: color);
  
  /// Quote attribution
  static TextStyle quoteBy(Color color) => HomeTypographySystem.quoteAuthor(color: color);
  
  /// Media track title
  static TextStyle trackTitle(Color color) => HomeTypographySystem.mediaTitle(color: color);
  
  /// Media artist name
  static TextStyle artistName(Color color) => HomeTypographySystem.mediaArtist(color: color);
  
  /// Button label
  static TextStyle button(Color color, {bool isLarge = false}) => 
      HomeTypographySystem.buttonText(color: color, isLarge: isLarge);
  
  /// Small metadata
  static TextStyle metadata(Color color) => HomeTypographySystem.caption(color: color);
  
  /// Tiny labels
  static TextStyle tiny(Color color) => HomeTypographySystem.smallText(color: color);
}
