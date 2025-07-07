// 🌞🌙 Adaptive Brightness System
// Advanced intelligent dark mode with ambient light adaptation
// DEAR Flutter - Modern Theme UI/UX Phase 2

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

/// Intelligent brightness adaptation system that automatically adjusts
/// theme based on ambient light, time of day, and user preferences
class AdaptiveBrightnessSystem {
  static const String _brightnessChannel = 'flutter/brightness';
  static const MethodChannel _methodChannel = MethodChannel(_brightnessChannel);
  
  // Brightness thresholds (0.0 - 1.0)
  static const double _darkModeThreshold = 0.3;
  static const double _lightModeThreshold = 0.7;
  
  // Animation settings
  static const Duration _transitionDuration = Duration(milliseconds: 800);
  static const Curve _transitionCurve = Curves.easeInOutCubic;
  
  StreamController<BrightnessAdaptation>? _brightnessController;
  Timer? _ambientLightTimer;
  Timer? _timeBasedTimer;
  
  double _currentAmbientLight = 0.5;
  BrightnessMode _currentMode = BrightnessMode.auto;
  
  // User preferences
  bool _autoModeEnabled = true;
  bool _timeBasedEnabled = true;
  bool _oledOptimizationEnabled = true;
  TimeOfDay _darkModeStartTime = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _lightModeStartTime = const TimeOfDay(hour: 7, minute: 0);
  
  /// Stream of brightness adaptations
  Stream<BrightnessAdaptation> get brightnessStream => 
      _brightnessController?.stream ?? const Stream.empty();
  
  /// Initialize the adaptive brightness system
  Future<void> initialize() async {
    _brightnessController = StreamController<BrightnessAdaptation>.broadcast();
    
    // Start ambient light monitoring
    if (_autoModeEnabled) {
      _startAmbientLightMonitoring();
    }
    
    // Start time-based monitoring
    if (_timeBasedEnabled) {
      _startTimeBasedMonitoring();
    }
    
    // Listen to system brightness changes
    _listenToSystemBrightness();
    
    // Initial brightness assessment
    await _performInitialBrightnessAssessment();
  }
  
  /// Dispose resources
  void dispose() {
    _brightnessController?.close();
    _ambientLightTimer?.cancel();
    _timeBasedTimer?.cancel();
  }
  
  /// Get current recommended brightness mode
  Future<BrightnessAdaptation> getCurrentBrightnessAdaptation() async {
    final ambientLight = await _getAmbientLight();
    final timeOfDay = TimeOfDay.now();
    final systemBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    
    return BrightnessAdaptation(
      recommendedMode: _calculateRecommendedMode(
        ambientLight: ambientLight,
        timeOfDay: timeOfDay,
        systemBrightness: systemBrightness,
      ),
      ambientLight: ambientLight,
      confidence: _calculateConfidence(ambientLight, timeOfDay),
      adaptationReason: _getAdaptationReason(ambientLight, timeOfDay),
      transitionDuration: _transitionDuration,
      transitionCurve: _transitionCurve,
      oledOptimized: _oledOptimizationEnabled,
    );
  }
  
  /// Update user preferences
  void updatePreferences({
    bool? autoModeEnabled,
    bool? timeBasedEnabled,
    bool? oledOptimizationEnabled,
    TimeOfDay? darkModeStartTime,
    TimeOfDay? lightModeStartTime,
  }) {
    if (autoModeEnabled != null) {
      _autoModeEnabled = autoModeEnabled;
      if (autoModeEnabled) {
        _startAmbientLightMonitoring();
      } else {
        _ambientLightTimer?.cancel();
      }
    }
    
    if (timeBasedEnabled != null) {
      _timeBasedEnabled = timeBasedEnabled;
      if (timeBasedEnabled) {
        _startTimeBasedMonitoring();
      } else {
        _timeBasedTimer?.cancel();
      }
    }
    
    if (oledOptimizationEnabled != null) {
      _oledOptimizationEnabled = oledOptimizationEnabled;
    }
    
    if (darkModeStartTime != null) {
      _darkModeStartTime = darkModeStartTime;
    }
    
    if (lightModeStartTime != null) {
      _lightModeStartTime = lightModeStartTime;
    }
  }
  
  /// Manual brightness override
  void overrideBrightness(BrightnessMode mode) {
    _currentMode = mode;
    final adaptation = BrightnessAdaptation(
      recommendedMode: mode,
      ambientLight: _currentAmbientLight,
      confidence: 1.0, // Maximum confidence for manual override
      adaptationReason: AdaptationReason.userOverride,
      transitionDuration: const Duration(milliseconds: 300),
      transitionCurve: Curves.easeOutQuart,
      oledOptimized: _oledOptimizationEnabled,
    );
    
    _brightnessController?.add(adaptation);
  }
  
  // Private methods
  
  Future<void> _performInitialBrightnessAssessment() async {
    final adaptation = await getCurrentBrightnessAdaptation();
    _brightnessController?.add(adaptation);
  }
  
  void _startAmbientLightMonitoring() {
    _ambientLightTimer?.cancel();
    _ambientLightTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkAmbientLight(),
    );
  }
  
  void _startTimeBasedMonitoring() {
    _timeBasedTimer?.cancel();
    _timeBasedTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkTimeBasedBrightness(),
    );
  }
  
  void _listenToSystemBrightness() {
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      _checkSystemBrightnessChange();
    };
  }
  
  Future<void> _checkAmbientLight() async {
    if (!_autoModeEnabled) return;
    
    final ambientLight = await _getAmbientLight();
    final previousLight = _currentAmbientLight;
    _currentAmbientLight = ambientLight;
    
    // Check if significant change occurred
    if ((ambientLight - previousLight).abs() > 0.15) {
      final adaptation = await getCurrentBrightnessAdaptation();
      _brightnessController?.add(adaptation);
    }
  }
  
  Future<void> _checkTimeBasedBrightness() async {
    if (!_timeBasedEnabled) return;
    
    final adaptation = await getCurrentBrightnessAdaptation();
    _brightnessController?.add(adaptation);
  }
  
  void _checkSystemBrightnessChange() {
    // Respond to system-level brightness changes
    Timer(const Duration(milliseconds: 500), () async {
      final adaptation = await getCurrentBrightnessAdaptation();
      _brightnessController?.add(adaptation);
    });
  }
  
  Future<double> _getAmbientLight() async {
    try {
      // Try to get actual ambient light sensor data
      final result = await _methodChannel.invokeMethod<double>('getAmbientLight');
      return result ?? _estimateAmbientLight();
    } catch (e) {
      // Fallback to estimation
      return _estimateAmbientLight();
    }
  }
  
  double _estimateAmbientLight() {
    final now = DateTime.now();
    final hour = now.hour + (now.minute / 60.0);
    final random = math.Random();
    
    // Simulate natural light curve (0.0 = dark, 1.0 = bright)
    if (hour >= 6 && hour <= 18) {
      // Daytime: sine wave simulation
      final dayProgress = (hour - 6) / 12;
      return 0.3 + (0.7 * math.sin(math.pi * dayProgress));
    } else {
      // Nighttime: low ambient light
      return 0.1 + (0.1 * random.nextDouble());
    }
  }
  
  BrightnessMode _calculateRecommendedMode({
    required double ambientLight,
    required TimeOfDay timeOfDay,
    required Brightness systemBrightness,
  }) {
    // Priority 1: User override
    if (_currentMode != BrightnessMode.auto) {
      return _currentMode;
    }
    
    // Priority 2: Time-based with ambient light consideration
    if (_timeBasedEnabled) {
      final currentMinutes = timeOfDay.hour * 60 + timeOfDay.minute;
      final darkStartMinutes = _darkModeStartTime.hour * 60 + _darkModeStartTime.minute;
      final lightStartMinutes = _lightModeStartTime.hour * 60 + _lightModeStartTime.minute;
      
      bool isNightTime;
      if (darkStartMinutes < lightStartMinutes) {
        // Normal case: dark mode starts evening, light mode starts morning
        isNightTime = currentMinutes >= darkStartMinutes || currentMinutes < lightStartMinutes;
      } else {
        // Edge case: spans midnight
        isNightTime = currentMinutes >= darkStartMinutes && currentMinutes < lightStartMinutes;
      }
      
      if (isNightTime && ambientLight < _lightModeThreshold) {
        return BrightnessMode.dark;
      } else if (!isNightTime && ambientLight > _darkModeThreshold) {
        return BrightnessMode.light;
      }
    }
    
    // Priority 3: Ambient light based
    if (_autoModeEnabled) {
      if (ambientLight < _darkModeThreshold) {
        return BrightnessMode.dark;
      } else if (ambientLight > _lightModeThreshold) {
        return BrightnessMode.light;
      }
    }
    
    // Priority 4: System preference
    return systemBrightness == Brightness.dark 
        ? BrightnessMode.dark 
        : BrightnessMode.light;
  }
  
  double _calculateConfidence(double ambientLight, TimeOfDay timeOfDay) {
    // Higher confidence for extreme light conditions
    if (ambientLight < 0.2 || ambientLight > 0.8) {
      return 0.9;
    }
    
    // Medium confidence for time-based decisions
    final hour = timeOfDay.hour;
    if (hour < 6 || hour > 21) {
      return 0.7;
    } else if (hour > 10 && hour < 17) {
      return 0.8;
    }
    
    // Lower confidence for ambiguous conditions
    return 0.5;
  }
  
  AdaptationReason _getAdaptationReason(double ambientLight, TimeOfDay timeOfDay) {
    if (_currentMode != BrightnessMode.auto) {
      return AdaptationReason.userOverride;
    }
    
    if (ambientLight < _darkModeThreshold) {
      return AdaptationReason.ambientLight;
    }
    
    if (ambientLight > _lightModeThreshold) {
      return AdaptationReason.ambientLight;
    }
    
    final hour = timeOfDay.hour;
    if (hour < 6 || hour > 21) {
      return AdaptationReason.timeOfDay;
    }
    
    return AdaptationReason.systemPreference;
  }
}

/// Brightness mode options
enum BrightnessMode {
  light,
  dark,
  auto,
}

/// Reason for brightness adaptation
enum AdaptationReason {
  ambientLight,
  timeOfDay,
  systemPreference,
  userOverride,
  batteryOptimization,
}

/// Comprehensive brightness adaptation data
class BrightnessAdaptation {
  final BrightnessMode recommendedMode;
  final double ambientLight; // 0.0 (dark) to 1.0 (bright)
  final double confidence; // 0.0 (low) to 1.0 (high)
  final AdaptationReason adaptationReason;
  final Duration transitionDuration;
  final Curve transitionCurve;
  final bool oledOptimized;
  
  const BrightnessAdaptation({
    required this.recommendedMode,
    required this.ambientLight,
    required this.confidence,
    required this.adaptationReason,
    required this.transitionDuration,
    required this.transitionCurve,
    required this.oledOptimized,
  });
  
  /// Get display brightness (for OLED optimization)
  Brightness get brightness => recommendedMode == BrightnessMode.dark 
      ? Brightness.dark 
      : Brightness.light;
  
  /// Check if this is a high-confidence adaptation
  bool get isHighConfidence => confidence > 0.7;
  
  /// Get human-readable reason description
  String get reasonDescription {
    switch (adaptationReason) {
      case AdaptationReason.ambientLight:
        return 'Based on ambient light conditions';
      case AdaptationReason.timeOfDay:
        return 'Based on time of day';
      case AdaptationReason.systemPreference:
        return 'Following system preference';
      case AdaptationReason.userOverride:
        return 'User manual selection';
      case AdaptationReason.batteryOptimization:
        return 'Optimizing for battery life';
    }
  }
  
  @override
  String toString() {
    return 'BrightnessAdaptation('
        'mode: $recommendedMode, '
        'ambient: ${(ambientLight * 100).toInt()}%, '
        'confidence: ${(confidence * 100).toInt()}%, '
        'reason: $adaptationReason'
        ')';
  }
}

/// OLED-specific optimization utilities
class OLEDOptimization {
  /// Generate true black colors for OLED displays
  static Color getTrueBlack() => const Color(0xFF000000);
  
  /// Get OLED-optimized surface colors
  static Color getOLEDSurface({required bool isDark, double elevation = 0}) {
    if (!isDark) return Colors.white;
    
    // True black for base surface
    if (elevation == 0) return getTrueBlack();
    
    // Slightly elevated surfaces for depth
    final opacity = math.min(elevation * 0.008, 0.15);
    return Color.lerp(getTrueBlack(), Colors.white, opacity)!;
  }
  
  /// Calculate power consumption reduction (estimated)
  static double estimatePowerSaving({
    required Color backgroundColor,
    required double screenCoverage,
  }) {
    if (backgroundColor.computeLuminance() > 0.1) return 0.0;
    
    // Approximate power saving for true black pixels on OLED
    return screenCoverage * 0.4; // Up to 40% power saving
  }
}
