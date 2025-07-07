// 📱💻 Responsive Layout System
// Golden ratio-based responsive design with device adaptation
// DEAR Flutter - Modern Theme UI/UX Phase 2

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Responsive layout system based on golden ratio and psychological comfort
/// Provides optimal layouts for different screen sizes and orientations
class ResponsiveLayoutSystem {
  static const double _goldenRatio = 1.618033988749;
  static const double _inverseGoldenRatio = 0.618033988749;
  
  // Standard breakpoints (in logical pixels)
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 1024;
  static const double _desktopBreakpoint = 1440;
  static const double _ultraWideBreakpoint = 2560;
  
  // Comfort zone ratios for different device types
  static const double _mobileComfortRatio = 0.85;
  static const double _tabletComfortRatio = 0.75;
  static const double _desktopComfortRatio = 0.65;
  
  /// Get current device type based on screen size
  static DeviceType getDeviceType(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < _mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (screenWidth < _tabletBreakpoint) {
      return DeviceType.tablet;
    } else if (screenWidth < _desktopBreakpoint) {
      return DeviceType.desktop;
    } else if (screenWidth < _ultraWideBreakpoint) {
      return DeviceType.largeDesktop;
    } else {
      return DeviceType.ultraWide;
    }
  }
  
  /// Get responsive layout configuration for current context
  static ResponsiveConfig getResponsiveConfig(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final deviceType = getDeviceType(context);
    final orientation = mediaQuery.orientation;
    final devicePixelRatio = mediaQuery.devicePixelRatio;
    final textScaleFactor = mediaQuery.textScaleFactor;
    
    return ResponsiveConfig(
      screenSize: screenSize,
      deviceType: deviceType,
      orientation: orientation,
      devicePixelRatio: devicePixelRatio,
      textScaleFactor: textScaleFactor,
      safeAreaInsets: mediaQuery.padding,
      viewInsets: mediaQuery.viewInsets,
    );
  }
  
  /// Calculate golden ratio based margins
  static EdgeInsets getGoldenMargins(BuildContext context) {
    final config = getResponsiveConfig(context);
    final baseMargin = _getBaseMargin(config.deviceType);
    
    // Golden ratio progression for different sides
    return EdgeInsets.only(
      left: baseMargin,
      top: baseMargin * _inverseGoldenRatio,
      right: baseMargin,
      bottom: baseMargin * _goldenRatio,
    );
  }
  
  /// Calculate responsive padding based on content comfort
  static EdgeInsets getContentPadding(BuildContext context, {
    ContentDensity density = ContentDensity.comfortable,
  }) {
    final config = getResponsiveConfig(context);
    final basePadding = _getBasePadding(config.deviceType);
    final densityMultiplier = _getDensityMultiplier(density);
    
    return EdgeInsets.all(basePadding * densityMultiplier);
  }
  
  /// Get optimal content width for readability
  static double getOptimalContentWidth(BuildContext context) {
    final config = getResponsiveConfig(context);
    final screenWidth = config.screenSize.width;
    final comfortRatio = _getComfortRatio(config.deviceType);
    
    // Maximum comfortable reading width (based on typography research)
    const maxReadingWidth = 680.0;
    
    final comfortableWidth = screenWidth * comfortRatio;
    return math.min(comfortableWidth, maxReadingWidth);
  }
  
  /// Calculate responsive grid columns
  static int getOptimalColumns(BuildContext context, {
    double minItemWidth = 280,
    int maxColumns = 6,
  }) {
    final contentWidth = getOptimalContentWidth(context);
    final config = getResponsiveConfig(context);
    
    // Calculate based on golden ratio subdivision
    final idealColumns = (contentWidth / minItemWidth).floor();
    final goldenColumns = _getGoldenColumns(config.deviceType);
    
    return math.min(
      math.max(idealColumns, 1),
      math.min(goldenColumns, maxColumns),
    );
  }
  
  /// Get responsive font sizes using golden ratio
  static ResponsiveFontSizes getFontSizes(BuildContext context) {
    final config = getResponsiveConfig(context);
    final baseSize = _getBaseFontSize(config.deviceType);
    final scaleFactor = math.min(config.textScaleFactor, 1.3); // Limit extreme scaling
    
    return ResponsiveFontSizes(
      displayLarge: (baseSize * math.pow(_goldenRatio, 4) * scaleFactor),
      displayMedium: (baseSize * math.pow(_goldenRatio, 3) * scaleFactor),
      displaySmall: (baseSize * math.pow(_goldenRatio, 2) * scaleFactor),
      headlineLarge: (baseSize * _goldenRatio * _goldenRatio * scaleFactor),
      headlineMedium: (baseSize * _goldenRatio * scaleFactor),
      headlineSmall: (baseSize * scaleFactor),
      titleLarge: (baseSize * _inverseGoldenRatio * _goldenRatio * scaleFactor),
      titleMedium: (baseSize * _inverseGoldenRatio * scaleFactor),
      titleSmall: (baseSize * math.pow(_inverseGoldenRatio, 2) * _goldenRatio * scaleFactor),
      bodyLarge: (baseSize * scaleFactor),
      bodyMedium: (baseSize * _inverseGoldenRatio * scaleFactor),
      bodySmall: (baseSize * math.pow(_inverseGoldenRatio, 2) * scaleFactor),
      labelLarge: (baseSize * _inverseGoldenRatio * scaleFactor),
      labelMedium: (baseSize * math.pow(_inverseGoldenRatio, 2) * scaleFactor),
      labelSmall: (baseSize * math.pow(_inverseGoldenRatio, 3) * scaleFactor),
    );
  }
  
  /// Get responsive spacing scale
  static ResponsiveSpacing getSpacing(BuildContext context) {
    final config = getResponsiveConfig(context);
    final baseSpacing = _getBaseSpacing(config.deviceType);
    
    return ResponsiveSpacing(
      xs: baseSpacing * 0.25,
      sm: baseSpacing * 0.5,
      md: baseSpacing,
      lg: baseSpacing * _goldenRatio,
      xl: baseSpacing * _goldenRatio * _goldenRatio,
      xxl: baseSpacing * math.pow(_goldenRatio, 3),
    );
  }
  
  /// Get adaptive layout constraints
  static BoxConstraints getAdaptiveConstraints(BuildContext context, {
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    final config = getResponsiveConfig(context);
    final optimalWidth = getOptimalContentWidth(context);
    
    return BoxConstraints(
      minWidth: minWidth ?? 0,
      maxWidth: maxWidth ?? optimalWidth,
      minHeight: minHeight ?? 0,
      maxHeight: maxHeight ?? double.infinity,
    );
  }
  
  /// Check if device is in compact mode (need different layout approach)
  static bool isCompactMode(BuildContext context) {
    final config = getResponsiveConfig(context);
    
    // Compact mode criteria
    return config.deviceType == DeviceType.mobile ||
           (config.orientation == Orientation.landscape && 
            config.screenSize.height < 500) ||
           config.textScaleFactor > 1.2;
  }
  
  /// Get safe area aware insets
  static EdgeInsets getSafeAreaAwarePadding(BuildContext context) {
    final config = getResponsiveConfig(context);
    final contentPadding = getContentPadding(context);
    
    return EdgeInsets.only(
      left: math.max(contentPadding.left, config.safeAreaInsets.left),
      top: math.max(contentPadding.top, config.safeAreaInsets.top),
      right: math.max(contentPadding.right, config.safeAreaInsets.right),
      bottom: math.max(contentPadding.bottom, config.safeAreaInsets.bottom),
    );
  }
  
  // Private helper methods
  
  static double _getBaseMargin(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 16.0;
      case DeviceType.tablet:
        return 24.0;
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
        return 32.0;
      case DeviceType.ultraWide:
        return 48.0;
    }
  }
  
  static double _getBasePadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 12.0;
      case DeviceType.tablet:
        return 16.0;
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
        return 20.0;
      case DeviceType.ultraWide:
        return 24.0;
    }
  }
  
  static double _getBaseFontSize(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 14.0;
      case DeviceType.tablet:
        return 15.0;
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
        return 16.0;
      case DeviceType.ultraWide:
        return 17.0;
    }
  }
  
  static double _getBaseSpacing(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 8.0;
      case DeviceType.tablet:
        return 12.0;
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
        return 16.0;
      case DeviceType.ultraWide:
        return 20.0;
    }
  }
  
  static double _getComfortRatio(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return _mobileComfortRatio;
      case DeviceType.tablet:
        return _tabletComfortRatio;
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
      case DeviceType.ultraWide:
        return _desktopComfortRatio;
    }
  }
  
  static int _getGoldenColumns(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
      case DeviceType.largeDesktop:
        return 4;
      case DeviceType.ultraWide:
        return 5;
    }
  }
  
  static double _getDensityMultiplier(ContentDensity density) {
    switch (density) {
      case ContentDensity.compact:
        return 0.75;
      case ContentDensity.comfortable:
        return 1.0;
      case ContentDensity.spacious:
        return 1.5;
    }
  }
}

/// Device type classification
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
  ultraWide,
}

/// Content density options
enum ContentDensity {
  compact,
  comfortable,
  spacious,
}

/// Comprehensive responsive configuration
class ResponsiveConfig {
  final Size screenSize;
  final DeviceType deviceType;
  final Orientation orientation;
  final double devicePixelRatio;
  final double textScaleFactor;
  final EdgeInsets safeAreaInsets;
  final EdgeInsets viewInsets;
  
  const ResponsiveConfig({
    required this.screenSize,
    required this.deviceType,
    required this.orientation,
    required this.devicePixelRatio,
    required this.textScaleFactor,
    required this.safeAreaInsets,
    required this.viewInsets,
  });
  
  /// Check if device is in landscape mode
  bool get isLandscape => orientation == Orientation.landscape;
  
  /// Check if device is in portrait mode
  bool get isPortrait => orientation == Orientation.portrait;
  
  /// Check if device has high pixel density
  bool get isHighDensity => devicePixelRatio > 2.0;
  
  /// Check if text is scaled up for accessibility
  bool get hasLargeText => textScaleFactor > 1.1;
  
  /// Get aspect ratio
  double get aspectRatio => screenSize.width / screenSize.height;
  
  /// Check if device has notch or similar
  bool get hasNotch => safeAreaInsets.top > 24;
  
  @override
  String toString() {
    return 'ResponsiveConfig('
        'device: $deviceType, '
        'size: ${screenSize.width.toInt()}x${screenSize.height.toInt()}, '
        'orientation: $orientation, '
        'dpr: ${devicePixelRatio.toStringAsFixed(1)}, '
        'textScale: ${textScaleFactor.toStringAsFixed(1)}'
        ')';
  }
}

/// Golden ratio based font size system
class ResponsiveFontSizes {
  final double displayLarge;
  final double displayMedium;
  final double displaySmall;
  final double headlineLarge;
  final double headlineMedium;
  final double headlineSmall;
  final double titleLarge;
  final double titleMedium;
  final double titleSmall;
  final double bodyLarge;
  final double bodyMedium;
  final double bodySmall;
  final double labelLarge;
  final double labelMedium;
  final double labelSmall;
  
  const ResponsiveFontSizes({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
  });
}

/// Responsive spacing scale based on golden ratio
class ResponsiveSpacing {
  final double xs;   // Extra small
  final double sm;   // Small
  final double md;   // Medium (base)
  final double lg;   // Large
  final double xl;   // Extra large
  final double xxl;  // Extra extra large
  
  const ResponsiveSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });
}

/// Responsive layout helper widget
class ResponsiveLayout extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;
  final Widget? ultraWide;
  final Widget? fallback;
  
  const ResponsiveLayout({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
    this.ultraWide,
    this.fallback,
  });
  
  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveLayoutSystem.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? tablet ?? desktop ?? fallback ?? const SizedBox();
      case DeviceType.tablet:
        return tablet ?? mobile ?? desktop ?? fallback ?? const SizedBox();
      case DeviceType.desktop:
        return desktop ?? tablet ?? largeDesktop ?? fallback ?? const SizedBox();
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? ultraWide ?? fallback ?? const SizedBox();
      case DeviceType.ultraWide:
        return ultraWide ?? largeDesktop ?? desktop ?? fallback ?? const SizedBox();
    }
  }
}

/// Responsive builder for custom responsive logic
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveConfig config) builder;
  
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });
  
  @override
  Widget build(BuildContext context) {
    final config = ResponsiveLayoutSystem.getResponsiveConfig(context);
    return builder(context, config);
  }
}
