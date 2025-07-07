// lib/core/theme/accessibility_enhanced.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';

/// Enhanced Accessibility System for Home Screen
/// Ensures WCAG 2.1 AA compliance and optimal user experience
class AccessibilityEnhanced {
  // WCAG 2.1 AA minimum touch target size
  static const double minTouchTarget = 48.0;
  
  // Recommended touch target size for better UX
  static const double recommendedTouchTarget = 56.0;
  
  // Minimum color contrast ratios (WCAG 2.1 AA)
  static const double normalTextContrast = 4.5;
  static const double largeTextContrast = 3.0;
  static const double uiComponentContrast = 3.0;
  
  /// Enhanced button with proper accessibility
  static Widget enhancedButton({
    required Widget child,
    required VoidCallback? onTap,
    required String semanticLabel,
    String? tooltip,
    bool isLarge = false,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    Color? foregroundColor,
    bool hapticFeedback = true,
  }) {
    final size = isLarge ? recommendedTouchTarget : minTouchTarget;
    
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onTap != null,
      child: Tooltip(
        message: tooltip ?? semanticLabel,
        child: Material(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap != null ? () {
              if (hapticFeedback) {
                HapticFeedback.lightImpact();
              }
              onTap();
            } : null,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            child: Container(
              constraints: BoxConstraints(
                minHeight: size,
                minWidth: size,
              ),
              padding: padding ?? EdgeInsets.all(12),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Enhanced text with proper contrast and scaling
  static Widget enhancedText({
    required String text,
    required TextStyle style,
    required Color backgroundColor,
    String? semanticLabel,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool respectUserTextScale = true,
  }) {
    return Semantics(
      label: semanticLabel ?? text,
      child: Builder(
        builder: (context) {
          final contrastColor = _getContrastColor(
            backgroundColor: backgroundColor,
            currentColor: style.color ?? Colors.black,
          );
          
          var finalStyle = style.copyWith(color: contrastColor);
          
          // Respect user's text scale preference with reasonable limits
          if (respectUserTextScale) {
            final textScaleFactor = MediaQuery.of(context).textScaleFactor;
            final clampedScale = textScaleFactor.clamp(0.8, 1.5);
            
            finalStyle = finalStyle.copyWith(
              fontSize: (finalStyle.fontSize ?? 16.0) * clampedScale,
            );
          }
          
          return Text(
            text,
            style: finalStyle,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
          );
        },
      ),
    );
  }
  
  /// Enhanced card container with proper focus handling
  static Widget enhancedCard({
    required Widget child,
    required String semanticLabel,
    VoidCallback? onTap,
    EdgeInsets? padding,
    BoxDecoration? decoration,
    bool focusable = true,
    String? tooltip,
  }) {
    return Semantics(
      label: semanticLabel,
      container: true,
      button: onTap != null,
      focusable: focusable,
      child: Focus(
        child: Builder(
          builder: (context) {
            final isFocused = Focus.of(context).hasFocus;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: decoration?.copyWith(
                border: isFocused ? Border.all(
                  color: Theme.of(context).focusColor,
                  width: 2.0,
                ) : decoration.border,
              ) ?? BoxDecoration(
                border: isFocused ? Border.all(
                  color: Theme.of(context).focusColor,
                  width: 2.0,
                ) : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap != null ? () {
                    HapticFeedback.lightImpact();
                    onTap();
                  } : null,
                  borderRadius: decoration?.borderRadius?.resolve(TextDirection.ltr),
                  child: Padding(
                    padding: padding ?? EdgeInsets.zero,
                    child: child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  /// Enhanced icon with proper sizing and semantics
  static Widget enhancedIcon({
    required IconData icon,
    required String semanticLabel,
    Color? color,
    double? size,
    bool decorative = false,
  }) {
    final iconSize = size ?? 24.0;
    
    return Semantics(
      label: decorative ? null : semanticLabel,
      excludeSemantics: decorative,
      child: Icon(
        icon,
        color: color,
        size: iconSize.clamp(16.0, 48.0), // Ensure reasonable icon sizes
        semanticLabel: decorative ? null : semanticLabel,
      ),
    );
  }
  
  /// Enhanced slider with proper accessibility labels
  static Widget enhancedSlider({
    required double value,
    required ValueChanged<double>? onChanged,
    required String semanticLabel,
    double min = 0.0,
    double max = 1.0,
    int? divisions,
    String Function(double)? semanticFormatterCallback,
  }) {
    return Semantics(
      slider: true,
      label: semanticLabel,
      value: semanticFormatterCallback?.call(value) ?? '${(value * 100).round()}%',
      increasedValue: semanticFormatterCallback?.call((value + 0.1).clamp(min, max)) ?? 
                     '${((value + 0.1).clamp(min, max) * 100).round()}%',
      decreasedValue: semanticFormatterCallback?.call((value - 0.1).clamp(min, max)) ?? 
                     '${((value - 0.1).clamp(min, max) * 100).round()}%',
      child: Slider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
        semanticFormatterCallback: semanticFormatterCallback,
      ),
    );
  }
  
  /// Check if color contrast meets WCAG standards
  static bool meetsContrastRequirement({
    required Color foreground,
    required Color background,
    bool isLargeText = false,
  }) {
    final contrast = _calculateContrast(foreground, background);
    final requiredContrast = isLargeText ? largeTextContrast : normalTextContrast;
    
    return contrast >= requiredContrast;
  }
  
  /// Get accessible color that meets contrast requirements
  static Color getAccessibleColor({
    required Color backgroundColor,
    Color preferredColor = Colors.black,
    bool isLargeText = false,
  }) {
    if (meetsContrastRequirement(
      foreground: preferredColor,
      background: backgroundColor,
      isLargeText: isLargeText,
    )) {
      return preferredColor;
    }
    
    // Return high contrast alternative
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
  
  /// Create reduced motion alternative for animations
  static Widget createReducedMotionAlternative({
    required Widget animatedChild,
    required Widget staticChild,
    required BuildContext context,
  }) {
    return Builder(
      builder: (context) {
        final reduceAnimations = MediaQuery.of(context).disableAnimations;
        return reduceAnimations ? staticChild : animatedChild;
      },
    );
  }
  
  /// Enhanced focus management for navigation
  static void manageFocus(BuildContext context, FocusNode focusNode) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        FocusScope.of(context).requestFocus(focusNode);
      }
    });
  }
  
  /// Announce content changes to screen readers
  static void announceChange(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }
  
  /// Helper method to calculate color contrast ratio
  static double _calculateContrast(Color color1, Color color2) {
    final lum1 = color1.computeLuminance();
    final lum2 = color2.computeLuminance();
    
    final lightest = lum1 > lum2 ? lum1 : lum2;
    final darkest = lum1 > lum2 ? lum2 : lum1;
    
    return (lightest + 0.05) / (darkest + 0.05);
  }
  
  /// Helper method to get contrast-compliant color
  static Color _getContrastColor({
    required Color backgroundColor,
    required Color currentColor,
  }) {
    if (meetsContrastRequirement(
      foreground: currentColor,
      background: backgroundColor,
    )) {
      return currentColor;
    }
    
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

/// Accessibility preferences and settings
class AccessibilityPreferences {
  /// Check if user prefers reduced motion
  static bool prefersReducedMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }
  
  /// Check if user has high contrast enabled
  static bool prefersHighContrast(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }
  
  /// Get user's preferred text scale factor
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }
  
  /// Check if user is using a screen reader
  static bool isUsingScreenReader(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }
  
  /// Get safe area insets for proper content positioning
  static EdgeInsets getSafeAreaInsets(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
}
