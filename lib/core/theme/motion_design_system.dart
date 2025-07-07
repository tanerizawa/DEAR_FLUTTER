// 🎭 Motion Design System
// Micro-interactions and smooth animations for psychological comfort
// DEAR Flutter - Modern Theme UI/UX Phase 2

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// Comprehensive motion design system for natural, comfortable interactions
class MotionDesignSystem {
  // Golden ratio based timing system
  static const Duration _baseDuration = Duration(milliseconds: 300);
  static const double _goldenRatio = 1.618033988749;
  static const double _inverseGoldenRatio = 0.618033988749;
  
  // Natural timing durations based on psychological comfort
  static Duration get instant => const Duration(milliseconds: 100);
  static Duration get quick => Duration(milliseconds: (_baseDuration.inMilliseconds * _inverseGoldenRatio).round());
  static Duration get normal => _baseDuration;
  static Duration get smooth => Duration(milliseconds: (_baseDuration.inMilliseconds * _goldenRatio).round());
  static Duration get slow => Duration(milliseconds: (_baseDuration.inMilliseconds * _goldenRatio * _goldenRatio).round());
  
  // Psychological comfort curves
  static const Curve _enterCurve = Curves.easeOutCubic;
  static const Curve _exitCurve = Curves.easeInCubic;
  static const Curve _emphasizedCurve = Curves.easeInOutBack;
  static const Curve _gentleCurve = Curves.easeInOutSine;
  static const Curve _energeticCurve = Curves.easeOutQuart;
  
  /// Get motion configuration for different interaction types
  static MotionConfig getMotionConfig(MotionType type) {
    switch (type) {
      case MotionType.pageTransition:
        return MotionConfig(
          duration: smooth,
          curve: _enterCurve,
          secondaryCurve: _exitCurve,
          hapticFeedback: HapticType.light,
        );
      
      case MotionType.buttonPress:
        return MotionConfig(
          duration: instant,
          curve: _energeticCurve,
          hapticFeedback: HapticType.light,
          scaleEffect: 0.96,
        );
      
      case MotionType.cardExpand:
        return MotionConfig(
          duration: normal,
          curve: _emphasizedCurve,
          hapticFeedback: HapticType.medium,
          elevationEffect: 8.0,
        );
      
      case MotionType.modalPresent:
        return MotionConfig(
          duration: smooth,
          curve: _enterCurve,
          secondaryCurve: _exitCurve,
          hapticFeedback: HapticType.medium,
          blurEffect: 10.0,
        );
      
      case MotionType.listItemReveal:
        return MotionConfig(
          duration: quick,
          curve: _gentleCurve,
          staggerDelay: const Duration(milliseconds: 50),
        );
      
      case MotionType.loadingState:
        return MotionConfig(
          duration: slow,
          curve: Curves.linear,
          repeating: true,
        );
      
      case MotionType.errorShake:
        return MotionConfig(
          duration: Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          hapticFeedback: HapticType.heavy,
          offsetEffect: 8.0,
        );
      
      case MotionType.successPulse:
        return MotionConfig(
          duration: Duration(milliseconds: 1200),
          curve: Curves.elasticOut,
          hapticFeedback: HapticType.success,
          scaleEffect: 1.05,
        );
    }
  }
  
  /// Create animated page transition
  static PageRouteBuilder<T> createPageTransition<T>({
    required Widget child,
    required PageTransitionDirection direction,
    MotionConfig? customConfig,
  }) {
    final config = customConfig ?? getMotionConfig(MotionType.pageTransition);
    
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: config.duration,
      reverseTransitionDuration: config.duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildPageTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          direction: direction,
          config: config,
          child: child,
        );
      },
    );
  }
  
  /// Create smooth button press animation
  static Widget createPressableButton({
    required Widget child,
    required VoidCallback onPressed,
    MotionConfig? customConfig,
  }) {
    return _PressableButton(
      onPressed: onPressed,
      config: customConfig ?? getMotionConfig(MotionType.buttonPress),
      child: child,
    );
  }
  
  /// Create expandable card with smooth animation
  static Widget createExpandableCard({
    required Widget child,
    required Widget expandedChild,
    required bool isExpanded,
    MotionConfig? customConfig,
  }) {
    return _ExpandableCard(
      isExpanded: isExpanded,
      config: customConfig ?? getMotionConfig(MotionType.cardExpand),
      child: child,
      expandedChild: expandedChild,
    );
  }
  
  /// Create staggered list animation
  static Widget createStaggeredList({
    required List<Widget> children,
    required ScrollController? controller,
    MotionConfig? customConfig,
  }) {
    return _StaggeredList(
      children: children,
      controller: controller,
      config: customConfig ?? getMotionConfig(MotionType.listItemReveal),
    );
  }
  
  /// Create loading skeleton animation
  static Widget createLoadingSkeleton({
    required double width,
    required double height,
    BorderRadius? borderRadius,
    MotionConfig? customConfig,
  }) {
    return _LoadingSkeleton(
      width: width,
      height: height,
      borderRadius: borderRadius,
      config: customConfig ?? getMotionConfig(MotionType.loadingState),
    );
  }
  
  /// Trigger haptic feedback based on type
  static void triggerHaptic(HapticType type) {
    switch (type) {
      case HapticType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticType.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticType.success:
        HapticFeedback.lightImpact();
        // Additional success feedback could be implemented here
        break;
      case HapticType.error:
        HapticFeedback.heavyImpact();
        break;
    }
  }
  
  // Private helper methods
  
  static Widget _buildPageTransition({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required PageTransitionDirection direction,
    required MotionConfig config,
    required Widget child,
  }) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: config.curve,
      reverseCurve: config.secondaryCurve,
    );
    
    switch (direction) {
      case PageTransitionDirection.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      
      case PageTransitionDirection.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      
      case PageTransitionDirection.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      
      case PageTransitionDirection.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      
      case PageTransitionDirection.fade:
        return FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );
      
      case PageTransitionDirection.scale:
        return ScaleTransition(
          scale: curvedAnimation,
          child: child,
        );
      
      case PageTransitionDirection.rotation:
        return RotationTransition(
          turns: curvedAnimation,
          child: child,
        );
    }
  }
}

/// Motion type classification for different interactions
enum MotionType {
  pageTransition,
  buttonPress,
  cardExpand,
  modalPresent,
  listItemReveal,
  loadingState,
  errorShake,
  successPulse,
}

/// Page transition directions
enum PageTransitionDirection {
  slideUp,
  slideDown,
  slideLeft,
  slideRight,
  fade,
  scale,
  rotation,
}

/// Haptic feedback types
enum HapticType {
  light,
  medium,
  heavy,
  selection,
  success,
  error,
}

/// Motion configuration for different animation types
class MotionConfig {
  final Duration duration;
  final Curve curve;
  final Curve? secondaryCurve;
  final HapticType? hapticFeedback;
  final Duration? staggerDelay;
  final bool repeating;
  final double? scaleEffect;
  final double? elevationEffect;
  final double? blurEffect;
  final double? offsetEffect;
  
  const MotionConfig({
    required this.duration,
    required this.curve,
    this.secondaryCurve,
    this.hapticFeedback,
    this.staggerDelay,
    this.repeating = false,
    this.scaleEffect,
    this.elevationEffect,
    this.blurEffect,
    this.offsetEffect,
  });
}

/// Pressable button widget with scale animation
class _PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final MotionConfig config;
  
  const _PressableButton({
    required this.child,
    required this.onPressed,
    required this.config,
  });
  
  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.config.duration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.config.scaleEffect ?? 0.96,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.config.curve,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleTapDown() {
    _controller.forward();
    if (widget.config.hapticFeedback != null) {
      MotionDesignSystem.triggerHaptic(widget.config.hapticFeedback!);
    }
  }
  
  void _handleTapUp() {
    _controller.reverse();
    widget.onPressed();
  }
  
  void _handleTapCancel() {
    _controller.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _handleTapDown(),
      onTapUp: (_) => _handleTapUp(),
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Expandable card with smooth animation
class _ExpandableCard extends StatefulWidget {
  final Widget child;
  final Widget expandedChild;
  final bool isExpanded;
  final MotionConfig config;
  
  const _ExpandableCard({
    required this.child,
    required this.expandedChild,
    required this.isExpanded,
    required this.config,
  });
  
  @override
  State<_ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<_ExpandableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _elevationAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.config.duration,
      vsync: this,
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.config.curve,
    );
    
    _elevationAnimation = Tween<double>(
      begin: 1.0,
      end: widget.config.elevationEffect ?? 4.0,
    ).animate(_expandAnimation);
    
    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }
  
  @override
  void didUpdateWidget(_ExpandableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
        if (widget.config.hapticFeedback != null) {
          MotionDesignSystem.triggerHaptic(widget.config.hapticFeedback!);
        }
      } else {
        _controller.reverse();
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Card(
          elevation: _elevationAnimation.value,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.child,
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: widget.expandedChild,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Staggered list animation
class _StaggeredList extends StatefulWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final MotionConfig config;
  
  const _StaggeredList({
    required this.children,
    required this.controller,
    required this.config,
  });
  
  @override
  State<_StaggeredList> createState() => _StaggeredListState();
}

class _StaggeredListState extends State<_StaggeredList>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startStaggeredAnimation();
  }
  
  void _initializeAnimations() {
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        duration: widget.config.duration,
        vsync: this,
      ),
    );
    
    _animations = _controllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: widget.config.curve,
      );
    }).toList();
  }
  
  void _startStaggeredAnimation() {
    for (int i = 0; i < _controllers.length; i++) {
      final delay = (widget.config.staggerDelay ?? Duration.zero) * i;
      Future.delayed(delay, () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }
  
  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.controller,
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - _animations[index].value)),
              child: Opacity(
                opacity: _animations[index].value,
                child: widget.children[index],
              ),
            );
          },
        );
      },
    );
  }
}

/// Loading skeleton animation
class _LoadingSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final MotionConfig config;
  
  const _LoadingSkeleton({
    required this.width,
    required this.height,
    this.borderRadius,
    required this.config,
  });
  
  @override
  State<_LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<_LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.config.duration,
      vsync: this,
    );
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.config.curve,
    ));
    
    if (widget.config.repeating) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4.0),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                math.max(0.0, _shimmerAnimation.value - 0.3),
                _shimmerAnimation.value,
                math.min(1.0, _shimmerAnimation.value + 0.3),
              ],
              colors: [
                Theme.of(context).colorScheme.surfaceContainer,
                Theme.of(context).colorScheme.surfaceVariant,
                Theme.of(context).colorScheme.surfaceContainer,
              ],
            ),
          ),
        );
      },
    );
  }
}
