// lib/core/theme/contrast_text_widget.dart

import 'package:flutter/material.dart';
import 'package:dear_flutter/core/theme/mood_color_system.dart';

/// Widget that ensures text has proper contrast in dark mode
/// Automatically applies high contrast colors based on WCAG guidelines
class ContrastText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;
  final TextPriority priority;

  const ContrastText(
    this.text, {
    Key? key,
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
    this.priority = TextPriority.primary,
  }) : super(key: key);

  /// Primary text (highest contrast) - for headings and important content
  const ContrastText.primary(
    this.text, {
    Key? key,
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  })  : priority = TextPriority.primary,
        super(key: key);

  /// Secondary text (medium contrast) - for supporting content
  const ContrastText.secondary(
    this.text, {
    Key? key,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  })  : priority = TextPriority.secondary,
        super(key: key);

  /// Tertiary text (lower contrast but still accessible) - for captions
  const ContrastText.tertiary(
    this.text, {
    Key? key,
    this.fontSize = 12,
    this.fontWeight = FontWeight.normal,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  })  : priority = TextPriority.tertiary,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    Color textColor;
    switch (priority) {
      case TextPriority.primary:
        textColor = brightness == Brightness.dark 
            ? MoodColorSystem.onSurface 
            : Colors.black87;
        break;
      case TextPriority.secondary:
        textColor = brightness == Brightness.dark 
            ? MoodColorSystem.onSurfaceVariant 
            : Colors.black54;
        break;
      case TextPriority.tertiary:
        textColor = brightness == Brightness.dark 
            ? MoodColorSystem.onSurfaceSecondary 
            : Colors.black38;
        break;
    }

    final effectiveStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: textColor,
      fontFamily: 'Montserrat',
    ).merge(style);

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
    );
  }
}

enum TextPriority {
  primary,   // Main content, headings - highest contrast
  secondary, // Supporting content - medium contrast  
  tertiary,  // Captions, labels - accessible but subtle
}

/// Extension to easily convert existing Text widgets to ContrastText
extension TextContrast on Text {
  ContrastText toHighContrast({TextPriority priority = TextPriority.primary}) {
    return ContrastText(
      data ?? '',
      fontSize: style?.fontSize ?? 16,
      fontWeight: style?.fontWeight ?? FontWeight.normal,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      priority: priority,
    );
  }
}
