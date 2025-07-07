// lib/presentation/home/screens/home_screen.dart

import 'package:dear_flutter/core/theme/mood_color_system.dart';
import 'package:dear_flutter/core/theme/home_layout_system.dart';
import 'package:dear_flutter/core/theme/home_typography_system.dart';
import 'package:dear_flutter/core/theme/home_card_system.dart';
import 'package:dear_flutter/core/theme/accessibility_enhanced.dart';
import 'package:dear_flutter/presentation/home/cubit/improved_home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_state.dart';
import 'package:dear_flutter/presentation/home/widgets/enhanced_quote_section.dart';
import 'package:dear_flutter/presentation/home/widgets/unified_media_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> 
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  bool _hasNetworkError = false;
  Timer? _refreshTimeout;
  Timer? _retryTimer;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  // Sprint 3: Advanced Analytics & Personalization
  late SharedPreferences _prefs;
  Map<String, dynamic> _userPreferences = {};
  Map<String, int> _interactionCounts = {};
  DateTime? _lastVisitTime;
  int _sessionDuration = 0;
  Timer? _sessionTimer;
  String _preferredLanguage = 'id';
  bool _isDarkModePreferred = false;
  
  // Performance Monitoring
  late Stopwatch _performanceStopwatch;
  final List<Map<String, dynamic>> _performanceMetrics = [];

  // Animation controllers for enhanced UX
  late AnimationController _greetingAnimationController;
  late AnimationController _sectionAnimationController;
  late AnimationController _refreshAnimationController;
  late AnimationController _errorAnimationController;
  late AnimationController _successAnimationController;
  
  late Animation<double> _greetingFadeAnimation;
  late Animation<Offset> _greetingSlideAnimation;
  late Animation<double> _sectionScaleAnimation;
  late Animation<double> _refreshRotationAnimation;
  late Animation<double> _errorShakeAnimation;
  late Animation<double> _successPulseAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _performanceStopwatch = Stopwatch()..start();
    _initializeAdvancedFeatures();
    _initializeAnimations();
    _startIntroAnimations();
    _startSessionTracking();
    _setupScrollAnalytics();
  }

  // Sprint 3: Scroll Analytics Setup
  void _setupScrollAnalytics() {
    _scrollController.addListener(() {
      _incrementInteractionCount('scroll');
      
      // Track scroll depth for analytics
      final scrollPercentage = (_scrollController.offset / 
          (_scrollController.position.maxScrollExtent + 1)).clamp(0.0, 1.0);
      
      if (scrollPercentage > 0.5 && !_userPreferences.containsKey('deep_scroll_tracked')) {
        _recordAnalyticsEvent('deep_scroll', {'scroll_percentage': scrollPercentage});
        _userPreferences['deep_scroll_tracked'] = true;
      }
    });
  }

  // Sprint 3: Advanced Features Initialization
  Future<void> _initializeAdvancedFeatures() async {
    await _loadUserPreferences();
    await _trackUserSession();
    _recordPerformanceMetric('home_screen_init', _performanceStopwatch.elapsedMilliseconds);
  }

  Future<void> _loadUserPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Load user preferences
    _userPreferences = {
      'greeting_style': _prefs.getString('greeting_style') ?? 'time_based',
      'animation_speed': _prefs.getDouble('animation_speed') ?? 1.0,
      'haptic_enabled': _prefs.getBool('haptic_enabled') ?? true,
      'auto_refresh': _prefs.getBool('auto_refresh') ?? false,
    };
    
    // Load interaction counts for personalization
    final countsJson = _prefs.getString('interaction_counts') ?? '{}';
    _interactionCounts = Map<String, int>.from(jsonDecode(countsJson));
    
    // Load session data
    _lastVisitTime = DateTime.tryParse(_prefs.getString('last_visit_time') ?? '');
    _preferredLanguage = _prefs.getString('preferred_language') ?? 'id';
    _isDarkModePreferred = _prefs.getBool('dark_mode_preferred') ?? false;
    
    if (mounted) setState(() {});
  }

  Future<void> _trackUserSession() async {
    final now = DateTime.now();
    
    // Calculate time since last visit
    if (_lastVisitTime != null) {
      final timeSinceLastVisit = now.difference(_lastVisitTime!);
      _recordAnalyticsEvent('session_return', {
        'hours_since_last_visit': timeSinceLastVisit.inHours,
        'is_returning_user': true,
      });
    }
    
    // Update last visit time
    _lastVisitTime = now;
    await _prefs.setString('last_visit_time', now.toIso8601String());
  }

  void _startSessionTracking() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _sessionDuration += 30;
      
      // Record engagement metrics every 30 seconds
      if (_sessionDuration % 60 == 0) {
        _recordAnalyticsEvent('session_engagement', {
          'duration_seconds': _sessionDuration,
          'scroll_events': _interactionCounts['scroll'] ?? 0,
          'refresh_events': _interactionCounts['refresh'] ?? 0,
        });
      }
    });
  }

  void _recordAnalyticsEvent(String eventName, Map<String, dynamic> parameters) {
    final event = {
      'event': eventName,
      'timestamp': DateTime.now().toIso8601String(),
      'parameters': parameters,
      'user_id': _prefs.getString('user_id') ?? 'anonymous',
      'session_id': _sessionTimer?.hashCode.toString() ?? 'unknown',
    };
    
    // In production, send to analytics service (Firebase, Mixpanel, etc.)
    debugPrint('📊 Analytics: $eventName - ${jsonEncode(parameters)}');
    
    // Store locally for batch upload later
    _storeEventLocally(event);
  }

  Future<void> _storeEventLocally(Map<String, dynamic> event) async {
    try {
      final eventsJson = _prefs.getString('stored_events') ?? '[]';
      final events = List<Map<String, dynamic>>.from(jsonDecode(eventsJson));
      events.add(event);
      
      // Keep only last 50 events to prevent storage bloat
      if (events.length > 50) {
        events.removeRange(0, events.length - 50);
      }
      
      await _prefs.setString('stored_events', jsonEncode(events));
    } catch (e) {
      debugPrint('Error storing analytics event: $e');
    }
  }

  void _recordPerformanceMetric(String metricName, int valueMs) {
    _performanceMetrics.add({
      'metric': metricName,
      'value_ms': valueMs,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Keep only last 10 metrics to avoid memory bloat
    if (_performanceMetrics.length > 10) {
      _performanceMetrics.removeAt(0);
    }
  }

  void _incrementInteractionCount(String action) {
    _interactionCounts[action] = (_interactionCounts[action] ?? 0) + 1;
    
    // Save to preferences periodically
    if (_interactionCounts[action]! % 5 == 0) {
      _saveInteractionCounts();
    }
  }

  Future<void> _saveInteractionCounts() async {
    await _prefs.setString('interaction_counts', jsonEncode(_interactionCounts));
  }

  void _initializeAnimations() {
    // Greeting animation controller (2 seconds)
    _greetingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Section animation controller (staggered animations)
    _sectionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Refresh animation controller
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Error animation controller (shake effect)
    _errorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Success animation controller (pulse effect)
    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Setup animations
    _greetingFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _greetingAnimationController,
      curve: Curves.easeOutQuart,
    ));

    _greetingSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _greetingAnimationController,
      curve: Curves.easeOutBack,
    ));

    _sectionScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sectionAnimationController,
      curve: Curves.elasticOut,
    ));

    _refreshRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _refreshAnimationController,
      curve: Curves.easeInOut,
    ));

    _errorShakeAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _errorAnimationController,
      curve: Curves.elasticIn,
    ));

    _successPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.bounceOut,
    ));
  }

  void _startIntroAnimations() {
    // Start greeting animation immediately
    _greetingAnimationController.forward();
    
    // Delay section animations for staggered effect
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _sectionAnimationController.forward();
    });
  }

  void _triggerErrorAnimation() {
    _errorAnimationController.reset();
    _errorAnimationController.repeat(reverse: true, period: const Duration(milliseconds: 100));
    
    // Stop shake after a few cycles
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _errorAnimationController.stop();
    });
  }

  void _triggerSuccessAnimation() {
    _successAnimationController.reset();
    _successAnimationController.forward().then((_) {
      if (mounted) _successAnimationController.reverse();
    });
  }

  @override
  void dispose() {
    // Sprint 3: Advanced cleanup
    _sessionTimer?.cancel();
    _performanceStopwatch.stop();
    _saveInteractionCounts();
    _recordAnalyticsEvent('session_end', {
      'total_duration_seconds': _sessionDuration,
      'total_interactions': _interactionCounts.values.fold(0, (a, b) => a + b),
      'performance_metrics': _performanceMetrics.length,
    });
    
    // Core cleanup
    _scrollController.dispose();
    _refreshTimeout?.cancel();
    _retryTimer?.cancel();
    
    // Dispose animation controllers
    _greetingAnimationController.dispose();
    _sectionAnimationController.dispose();
    _refreshAnimationController.dispose();
    _errorAnimationController.dispose();
    _successAnimationController.dispose();
    
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false, VoidCallback? actionCallback, String? actionLabel}) {
    if (!mounted) return;
    
    // Add haptic feedback for better UX
    if (isError) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 6 : 3),
        action: actionCallback != null ? SnackBarAction(
          label: actionLabel ?? 'Retry',
          textColor: Colors.white,
          onPressed: actionCallback,
        ) : null,
      ),
    );
  }

  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _retryWithExponentialBackoff() async {
    if (_retryCount >= _maxRetries) {
      _triggerErrorAnimation(); // Add error animation
      _showSnackBar(
        'Tidak dapat terhubung setelah $_maxRetries percobaan. Periksa koneksi internet Anda.',
        isError: true,
        actionCallback: () => _resetAndRetry(),
        actionLabel: 'Coba Lagi',
      );
      return;
    }

    _retryCount++;
    final delaySeconds = (2 * _retryCount).clamp(2, 10); // Exponential backoff: 2, 4, 6 seconds
    
    _showSnackBar(
      'Mencoba lagi dalam $delaySeconds detik... ($_retryCount/$_maxRetries)'
    );
    
    _retryTimer = Timer(Duration(seconds: delaySeconds), () {
      if (mounted && context.mounted) _onRefresh();
    });
  }

  void _resetAndRetry() {
    _retryCount = 0;
    _hasNetworkError = false;
    _retryTimer?.cancel();
    _onRefresh();
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;

    // Sprint 3: Enhanced analytics for refresh action
    final refreshStartTime = Stopwatch()..start();
    _incrementInteractionCount('refresh');
    _recordAnalyticsEvent('refresh_initiated', {
      'user_type': (_interactionCounts['visit'] ?? 0) > 10 ? 'frequent' : 'new',
      'time_of_day': DateTime.now().hour,
      'session_duration': _sessionDuration,
    });

    // Start refresh animation
    _refreshAnimationController.repeat();

    // Check network connectivity first
    if (!await _checkConnectivity()) {
      _refreshAnimationController.stop();
      setState(() => _hasNetworkError = true);
      _recordAnalyticsEvent('refresh_failed_network', {
        'error_type': 'no_connectivity',
      });
      _showSnackBar(
        'Tidak ada koneksi internet. Periksa koneksi Anda.',
        isError: true,
        actionCallback: () => _resetAndRetry(),
        actionLabel: 'Coba Lagi',
      );
      return;
    }

    setState(() {
      _isRefreshing = true;
      _hasNetworkError = false;
    });

    _refreshTimeout = Timer(const Duration(seconds: 15), () {
      if (mounted && _isRefreshing) {
        _refreshAnimationController.stop();
        setState(() => _isRefreshing = false);
        _recordAnalyticsEvent('refresh_timeout', {
          'timeout_duration': 15,
        });
        _showSnackBar(
          'Timeout - Server tidak merespons',
          isError: true,
          actionCallback: () => _retryWithExponentialBackoff(),
          actionLabel: 'Retry',
        );
      }
    });

    try {
      if (!mounted) return;
      await context.read<ImprovedHomeFeedCubit>().fetchHomeFeed();
      _retryCount = 0; // Reset retry count on success
      
      // Record successful refresh analytics
      refreshStartTime.stop();
      _recordAnalyticsEvent('refresh_success', {
        'refresh_duration_ms': refreshStartTime.elapsedMilliseconds,
        'retry_count': _retryCount,
      });
      _recordPerformanceMetric('refresh_duration', refreshStartTime.elapsedMilliseconds);
      
      // Success animation sequence
      _refreshAnimationController.stop();
      _refreshAnimationController.reset();
      
      // Trigger success micro-animation
      _triggerSuccessAnimation();
      
      _showSnackBar('Konten berhasil diperbarui! 🎉');
    } catch (e) {
      _refreshAnimationController.stop();
      _recordAnalyticsEvent('refresh_failed', {
        'error_message': e.toString(),
        'error_type': _categorizeError(e.toString()),
        'retry_count': _retryCount,
      });
      
      if (mounted) {
        final isNetworkError = e.toString().contains('SocketException') || 
                              e.toString().contains('TimeoutException') ||
                              e.toString().contains('Connection failed');
        
        if (isNetworkError) {
          setState(() => _hasNetworkError = true);
          _retryWithExponentialBackoff();
        } else {
          _showSnackBar(
            'Gagal memperbarui konten: ${_getReadableErrorMessage(e.toString())}',
            isError: true,
            actionCallback: () => _onRefresh(),
            actionLabel: 'Coba Lagi',
          );
        }
      }
    } finally {
      _refreshTimeout?.cancel();
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  String _categorizeError(String error) {
    if (error.contains('SocketException')) return 'network';
    if (error.contains('TimeoutException')) return 'timeout';
    if (error.contains('FormatException')) return 'data_format';
    if (error.contains('401')) return 'authentication';
    if (error.contains('404')) return 'not_found';
    if (error.contains('500')) return 'server_error';
    return 'unknown';
  }

  String _getReadableErrorMessage(String error) {
    if (error.contains('SocketException')) return 'Tidak dapat terhubung ke server';
    if (error.contains('TimeoutException')) return 'Koneksi timeout';
    if (error.contains('FormatException')) return 'Data tidak valid dari server';
    if (error.contains('401')) return 'Sesi expired, silakan login ulang';
    if (error.contains('404')) return 'Konten tidak ditemukan';
    if (error.contains('500')) return 'Server sedang bermasalah';
    return 'Terjadi kesalahan tak terduga';
  }

  String _getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    final day = now.weekday;
    
    // Sprint 3: Intelligent personalized greetings
    final visitCount = _interactionCounts['visit'] ?? 0;
    final isFrequentUser = visitCount > 10;
    final greetingStyle = _userPreferences['greeting_style'] ?? 'time_based';
    
    // Check if user has been away for more than a day
    bool isReturningAfterBreak = false;
    if (_lastVisitTime != null) {
      final hoursSinceLastVisit = now.difference(_lastVisitTime!).inHours;
      isReturningAfterBreak = hoursSinceLastVisit > 24;
    }
    
    // Special return greetings
    if (isReturningAfterBreak && greetingStyle == 'personalized') {
      final daysSince = now.difference(_lastVisitTime!).inDays;
      if (daysSince == 1) return 'Selamat datang kembali! 🌟';
      if (daysSince <= 7) return 'Senang melihat Anda lagi! 💫';
      return 'Lama tidak bertemu! Selamat datang kembali 🎉';
    }
    
    // Frequent user personalized greetings
    if (isFrequentUser && greetingStyle == 'personalized') {
      if (day == DateTime.saturday || day == DateTime.sunday) {
        if (hour < 12) return 'Morning ritual favorit Anda! ☕️🌅';
        if (hour < 17) return 'Siang yang produktif untuk Anda 💪';
        return 'Waktunya refleksi weekend 🌇✨';
      } else {
        if (hour < 9) return 'Siap untuk hari yang luar biasa! 🚀';
        if (hour < 12) return 'Semangat pagi, productivity champion! ⚡';
        if (hour < 17) return 'Bagaimana progres hari ini? 📈';
        return 'Perfect time untuk wind down 🧘‍♀️';
      }
    }
    
    // Multi-language support (Sprint 3)
    if (_preferredLanguage == 'en') {
      if (day == DateTime.saturday || day == DateTime.sunday) {
        if (hour < 12) return 'Good morning! Happy weekend 🌅';
        if (hour < 17) return 'Good afternoon! Enjoy your weekend 🌞';
        return 'Good evening! Relax and unwind 🌇';
      } else {
        if (hour < 6) return 'Early bird! Peaceful dawn 🌙';
        if (hour < 12) return 'Good morning! Make it count 🌅';
        if (hour < 17) return 'Good afternoon! Stay focused 🌞';
        return 'Good evening! Time to recharge 🌇';
      }
    }
    
    // Default Indonesian greetings (enhanced)
    if (day == DateTime.saturday || day == DateTime.sunday) {
      if (hour < 12) return 'Selamat Pagi! Selamat akhir pekan 🌅';
      if (hour < 17) return 'Selamat Siang! Nikmati akhir pekan Anda 🌞';
      if (hour < 20) return 'Selamat Sore! Waktu santai akhir pekan 🌇';
      return 'Selamat Malam! Istirahat yang nyenyak 🌙';
    }
    
    // Weekday greetings
    if (hour < 6) return 'Dini Hari yang Tenang 🌙';
    if (hour < 12) return 'Selamat Pagi! Semangat hari ini 🌅';
    if (hour < 17) return 'Selamat Siang! Tetap produktif 🌞';
    if (hour < 20) return 'Selamat Sore! Hampir selesai hari ini 🌇';
    return 'Selamat Malam! Waktunya istirahat 🌙';
  }

  String _getSubGreeting() {
    final hour = DateTime.now().hour;
    final greetingStyle = _userPreferences['greeting_style'] ?? 'time_based';
    final visitCount = _interactionCounts['visit'] ?? 0;
    
    // Sprint 3: Advanced personalized sub-greetings with i18n
    if (greetingStyle == 'personalized' && visitCount > 5) {
      final preferredActions = _getMostUsedFeatures();
      if (preferredActions.isNotEmpty) {
        final topAction = preferredActions.first;
        return _getPersonalizedSubGreeting(topAction);
      }
    }
    
    return _getDefaultSubGreeting(hour);
  }

  String _getPersonalizedSubGreeting(String topAction) {
    final Map<String, Map<String, String>> personalizedGreetings = {
      'quote': {
        'id': 'Siap untuk inspirasi hari ini? 💡',
        'en': 'Ready for today\'s inspiration? 💡',
      },
      'music': {
        'id': 'Saatnya musik favorit Anda? 🎵',
        'en': 'Time for your favorite tunes? 🎵',
      },
      'refresh': {
        'id': 'Konten segar menanti Anda! 🔄',
        'en': 'Fresh content awaits you! 🔄',
      },
      'journal': {
        'id': 'Bagikan momen berharga hari ini 📝',
        'en': 'Share today\'s precious moments 📝',
      },
      'scroll': {
        'id': 'Mari jelajahi lebih dalam 🌊',
        'en': 'Let\'s explore deeper 🌊',
      },
    };

    return personalizedGreetings[topAction]?[_preferredLanguage] ?? 
           _getDefaultSubGreeting(DateTime.now().hour);
  }

  String _getDefaultSubGreeting(int hour) {
    final Map<String, List<String>> motivationalMessages = {
      'id': [
        'Bagaimana perasaan Anda hari ini?',
        'Ceritakan hari Anda pada jurnal',
        'Saatnya refleksi diri',
        'Apa yang membuat Anda bahagia hari ini?',
        'Mari tuliskan momen berharga',
        'Waktunya untuk mindfulness',
        'Ekspresikan creativity Anda',
      ],
      'en': [
        'How are you feeling today?',
        'Tell your journal about your day',
        'Time for self-reflection',
        'What makes you happy today?',
        'Let\'s write down precious moments',
        'Time for mindfulness',
        'Express your creativity',
      ],
    };
    
    final messages = motivationalMessages[_preferredLanguage] ?? motivationalMessages['id']!;
    
    if (hour < 12) {
      return messages[0]; // Morning
    } else if (hour < 17) {
      return messages[1]; // Afternoon
    } else {
      return messages[2]; // Evening
    }
  }

  List<String> _getMostUsedFeatures() {
    final sortedActions = _interactionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedActions.take(3).map((e) => e.key).toList();
  }

  // Sprint 3: Advanced Adaptive Theme System (for future use)
  // ThemeData _getAdaptiveTheme(BuildContext context) {
  //   final brightness = Theme.of(context).brightness;
  //   final isOLED = _userPreferences['oled_mode'] ?? false;
  //   
  //   if (brightness == Brightness.dark || _isDarkModePreferred) {
  //     return ThemeData.dark().copyWith(
  //       scaffoldBackgroundColor: isOLED ? Colors.black : const Color(0xFF121212),
  //       cardColor: isOLED ? const Color(0xFF000000) : const Color(0xFF1E1E1E),
  //       primaryColor: const Color(0xFF4DB6AC),
  //       colorScheme: const ColorScheme.dark(
  //         primary: Color(0xFF4DB6AC),
  //         secondary: Color(0xFF80CBC4),
  //         surface: Color(0xFF121212),
  //         background: Color(0xFF121212),
  //       ),
  //     );
  //   }
  //   
  //   return Theme.of(context);
  // }

  // Enhanced color system with accessibility support
  Color _getAdaptiveTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isHighContrast = _userPreferences['high_contrast'] ?? false;
    
    if (brightness == Brightness.dark || _isDarkModePreferred) {
      return isHighContrast ? Colors.white : Colors.white.withValues(alpha: 0.95);
    }
    return isHighContrast ? Colors.black : Colors.black.withValues(alpha: 0.87);
  }

  Color _getAdaptiveSubtextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isHighContrast = _userPreferences['high_contrast'] ?? false;
    
    if (brightness == Brightness.dark || _isDarkModePreferred) {
      return isHighContrast ? Colors.white.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.7);
    }
    return isHighContrast ? Colors.black.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.6);
  }

  Color _getAdaptivePrimaryColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    if (brightness == Brightness.dark || _isDarkModePreferred) {
      return const Color(0xFF4DB6AC); // Lighter teal for dark mode
    }
    return const Color(0xFF26A69A); // Standard teal for light mode
  }

  Color _getAdaptiveBackgroundColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isOLED = _userPreferences['oled_mode'] ?? false;
    
    if (brightness == Brightness.dark || _isDarkModePreferred) {
      return isOLED ? Colors.black : const Color(0xFF121212);
    }
    return MoodColorSystem.surface;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: _getAdaptiveBackgroundColor(context),
      body: BlocListener<ImprovedHomeFeedCubit, HomeFeedState>(
        listener: (context, state) {
          // Handle state changes with user feedback and animations
          if (state.status == HomeFeedStatus.failure) {
            _triggerErrorAnimation(); // Trigger error animation
            _recordAnalyticsEvent('content_load_failed', {
              'error_message': state.errorMessage ?? 'Unknown error',
              'retry_count': _retryCount,
            });
            _showSnackBar(
              'Gagal memuat konten: ${state.errorMessage ?? "Kesalahan tidak diketahui"}',
              isError: true,
              actionCallback: () => _onRefresh(),
              actionLabel: 'Coba Lagi',
            );
          } else if (state.status == HomeFeedStatus.success && _retryCount > 0) {
            _triggerSuccessAnimation(); // Trigger success animation
            _recordAnalyticsEvent('content_load_success_after_retry', {
              'retry_count': _retryCount,
            });
            _showSnackBar('Konten berhasil dimuat! 🎉');
            _retryCount = 0;
          } else if (state.status == HomeFeedStatus.success) {
            // Gentle success animation for first load
            _triggerSuccessAnimation();
            _recordAnalyticsEvent('content_load_success', {
              'load_time_ms': _performanceStopwatch.elapsedMilliseconds,
            });
          }
        },
        child: RefreshIndicator(
          color: const Color(0xFF26A69A),
          backgroundColor: MoodColorSystem.surfaceVariant,
          onRefresh: _onRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            // Add semantic label for accessibility
            semanticChildCount: 4, // header, quote, media, footer
            slivers: [
              // App Bar with greeting
              SliverAppBar(
                expandedHeight: HomeLayoutSystem.greetingHeight,
                floating: true,
                pinned: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildGreetingHeader(),
                ),
              ),

              // Content sections with golden ratio spacing
              SliverPadding(
                padding: HomeLayoutSystem.getResponsiveSpacing(context),
                sliver: SliverList.builder(
                  itemCount: 4, // quote, spacer, media, footer
                  itemBuilder: (context, index) {
                    return _buildOptimizedContent(index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizedContent(int index) {
    switch (index) {
      case 0:
        return _buildQuoteSection();
      case 1:
        return const SizedBox(height: FibonacciSpacing.lg);
      case 2:
        return _buildMediaSection();
      case 3:
        return const SizedBox(height: FibonacciSpacing.xxl);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGreetingHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            MoodColorSystem.surface,
            MoodColorSystem.surface.withValues(alpha: 0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: FibonacciSpacing.md,
            vertical: FibonacciSpacing.sm, // Reduced vertical padding
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Network status indicator with animation - only show if needed
              if (_hasNetworkError)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  child: Container(
                    key: const ValueKey('offline_indicator'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: FibonacciSpacing.sm, 
                      vertical: FibonacciSpacing.xs
                    ),
                    margin: const EdgeInsets.only(bottom: FibonacciSpacing.xs),
                    decoration: HomeCardSystem.secondaryCard(
                      context: context,
                      backgroundColor: Colors.orange.withValues(alpha: 0.2),
                    ).copyWith(
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AccessibilityEnhanced.enhancedIcon(
                          icon: Icons.wifi_off, 
                          semanticLabel: 'Tidak ada koneksi internet',
                          size: 14, // Reduced icon size
                          color: Colors.orange,
                        ),
                        const SizedBox(width: FibonacciSpacing.xs),
              Flexible(
                child: Text(
                  'Mode Offline',
                  style: HomeTypographySystem.caption(color: Colors.orange)
                    .copyWith(fontSize: 12), // Reduced font size
                ),
              ),
                      ],
                    ),
                  ),
                ),
              
              // Animated greeting text with enhanced accessibility
              Flexible(
                child: SlideTransition(
                  position: _greetingSlideAnimation,
                  child: FadeTransition(
                    opacity: _greetingFadeAnimation,
                    child: AccessibilityEnhanced.enhancedText(
                      text: _getGreeting(),
                      style: HomeTypographySystem.primaryHeading(
                        color: _getAdaptiveTextColor(context),
                      ).copyWith(
                        fontSize: 22, // Reduced font size
                        height: 1.1, // Tighter line height
                      ),
                      backgroundColor: _getAdaptiveBackgroundColor(context),
                      semanticLabel: 'Daily greeting: ${_getGreeting()}',
                      maxLines: 1, // Limit to 1 line
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: FibonacciSpacing.xs),
              
              // Animated sub-greeting with delay and accessibility
              Flexible(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _greetingAnimationController,
                    curve: const Interval(0.5, 1.0, curve: Curves.easeOutQuart),
                  )),
                  child: FadeTransition(
                    opacity: Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(CurvedAnimation(
                      parent: _greetingAnimationController,
                      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                    )),
                    child: AccessibilityEnhanced.enhancedText(
                      text: _getSubGreeting(),
                      style: HomeTypographySystem.subGreeting(
                        color: _getAdaptiveSubtextColor(context),
                      ).copyWith(
                        fontSize: 14, // Reduced font size
                        height: 1.2, // Tighter line height
                      ),
                      backgroundColor: _getAdaptiveBackgroundColor(context),
                      semanticLabel: 'Sub greeting: ${_getSubGreeting()}',
                      maxLines: 1, // Limit to 1 line
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteSection() {
    return AnimatedBuilder(
      animation: _sectionScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _sectionScaleAnimation.value,
          child: AnimatedBuilder(
            animation: _errorShakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_errorShakeAnimation.value, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      title: 'Inspirasi Hari Ini',
                      icon: Icons.auto_awesome,
                    ),
                    const SizedBox(height: MoodColorSystem.space_md),
                    const EnhancedQuoteSection(),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMediaSection() {
    return AnimatedBuilder(
      animation: _sectionScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _sectionScaleAnimation.value,
          child: AnimatedBuilder(
            animation: _successPulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _successPulseAnimation.value,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      title: 'Media Player',
                      icon: Icons.library_music_rounded,
                      showRefreshButton: true,
                    ),
                    const SizedBox(height: MoodColorSystem.space_md),
                    const UnifiedMediaSection(),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    bool showRefreshButton = false,
  }) {
    final adaptivePrimary = _getAdaptivePrimaryColor(context);
    
    return Semantics(
      label: '$title section',
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(FibonacciSpacing.sm),
            decoration: HomeCardSystem.iconContainer(
              primaryColor: adaptivePrimary,
              isLarge: false,
            ),
            child: AccessibilityEnhanced.enhancedIcon(
              icon: icon,
              semanticLabel: '$title icon',
              color: adaptivePrimary,
              size: 20.0,
            ),
          ),
          const SizedBox(width: FibonacciSpacing.md),
          Expanded(
            child: Text(
              title,
              style: HomeTypographySystem.sectionHeader(
                color: _getAdaptiveTextColor(context),
              ),
            ),
          ),
        if (showRefreshButton)
          AccessibilityEnhanced.enhancedButton(
            semanticLabel: 'Refresh content button',
            tooltip: 'Refresh musik dan konten',
            onTap: _isRefreshing ? null : () {
              _refreshAnimationController.repeat();
              _onRefresh();
            },
            child: AnimatedBuilder(
              animation: _refreshRotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _refreshRotationAnimation.value * 6.28, // 2π for full rotation
                  child: AccessibilityEnhanced.enhancedIcon(
                    icon: Icons.refresh_rounded,
                    semanticLabel: 'Refresh icon',
                    color: _isRefreshing 
                      ? _getAdaptivePrimaryColor(context)
                      : _getAdaptiveSubtextColor(context),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}