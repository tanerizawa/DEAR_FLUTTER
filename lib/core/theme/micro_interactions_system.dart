// lib/core/theme/micro_interactions_system.dart
// Micro-interactions and Haptic Feedback System - Phase 2 Implementation

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_animation_system.dart';
import 'mood_color_system_v2.dart';

/// Advanced micro-interactions system for delightful user experience
/// Implements Phase 2 Visual Design Enhancement with haptic feedback
class MicroInteractionsSystem {
  
  // MARK: - Haptic Feedback Patterns
  
  /// Light haptic feedback for subtle interactions
  static void lightHaptic() {
    HapticFeedback.lightImpact();
  }
  
  /// Medium haptic feedback for standard interactions
  static void mediumHaptic() {
    HapticFeedback.mediumImpact();
  }
  
  /// Heavy haptic feedback for important interactions
  static void heavyHaptic() {
    HapticFeedback.heavyImpact();
  }
  
  /// Selection haptic feedback for picker interactions
  static void selectionHaptic() {
    HapticFeedback.selectionClick();
  }
  
  /// Custom vibration pattern for quote interactions
  static void quoteHaptic() {
    // Double light tap pattern
    lightHaptic();
    Future.delayed(const Duration(milliseconds: 100), lightHaptic);
  }
  
  /// Success haptic feedback for completed actions
  static void successHaptic() {
    // Triple light tap pattern
    lightHaptic();
    Future.delayed(const Duration(milliseconds: 80), lightHaptic);
    Future.delayed(const Duration(milliseconds: 160), lightHaptic);
  }
  
  // MARK: - Enhanced Buttons with Micro-interactions
  
  /// Primary action button with enhanced feedback
  static Widget primaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
    bool enabled = true,
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
  }) {
    return _EnhancedButton(
      text: text,
      onPressed: enabled && !isLoading ? onPressed : null,
      icon: icon,
      isLoading: isLoading,
      style: _ButtonStyle.primary,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: padding,
    );
  }
  
  /// Secondary action button with subtle feedback
  static Widget secondaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
    bool enabled = true,
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
  }) {
    return _EnhancedButton(
      text: text,
      onPressed: enabled && !isLoading ? onPressed : null,
      icon: icon,
      isLoading: isLoading,
      style: _ButtonStyle.secondary,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: padding,
    );
  }
  
  /// Floating action button with enhanced animations
  static Widget enhancedFAB({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
    Color? backgroundColor,
    Color? foregroundColor,
    String? heroTag,
    bool mini = false,
  }) {
    return _EnhancedFAB(
      icon: icon,
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      heroTag: heroTag,
      mini: mini,
    );
  }
  
  // MARK: - Interactive Cards
  
  /// Enhanced quote card with tap interactions
  static Widget interactiveQuoteCard({
    required Widget child,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    VoidCallback? onDoubleTap,
    bool enableRipple = true,
    Color? rippleColor,
    BorderRadius? borderRadius,
  }) {
    return _InteractiveCard(
      child: child,
      onTap: onTap,
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      enableRipple: enableRipple,
      rippleColor: rippleColor,
      borderRadius: borderRadius ?? BorderRadius.circular(24),
    );
  }
  
  /// Enhanced icon button with pulse animation
  static Widget pulseIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
    double size = 24.0,
    String? tooltip,
    bool enablePulse = true,
  }) {
    return _PulseIconButton(
      icon: icon,
      onPressed: onPressed,
      color: color,
      size: size,
      tooltip: tooltip,
      enablePulse: enablePulse,
    );
  }
  
  // MARK: - Loading States with Micro-interactions
  
  /// Enhanced loading button that morphs during loading
  static Widget morphingLoadingButton({
    required String text,
    required Future<void> Function() onPressed,
    IconData? icon,
    Color? backgroundColor,
    Color? foregroundColor,
    Duration morphDuration = const Duration(milliseconds: 300),
  }) {
    return _MorphingLoadingButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      morphDuration: morphDuration,
    );
  }
  
  /// Skeleton loading with shimmer effect
  static Widget shimmerSkeleton({
    required double width,
    required double height,
    BorderRadius? borderRadius,
    Color? baseColor,
    Color? highlightColor,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return _ShimmerSkeleton(
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      baseColor: baseColor ?? Colors.grey.shade300,
      highlightColor: highlightColor ?? Colors.grey.shade100,
      duration: duration,
    );
  }
  
  // MARK: - Success/Error Feedback
  
  /// Animated success checkmark
  static Widget successCheckmark({
    Color? color,
    double size = 48.0,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return _AnimatedCheckmark(
      color: color ?? Colors.green,
      size: size,
      duration: duration,
    );
  }
  
  /// Animated error indicator
  static Widget errorIndicator({
    Color? color,
    double size = 48.0,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return _AnimatedErrorIndicator(
      color: color ?? Colors.red,
      size: size,
      duration: duration,
    );
  }
  
  // MARK: - Toast and Snackbar Enhancements
  
  /// Show enhanced snackbar with haptic feedback
  static void showEnhancedSnackBar({
    required BuildContext context,
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    _SnackBarType type = _SnackBarType.info,
  }) {
    // Provide haptic feedback based on type
    switch (type) {
      case _SnackBarType.success:
        successHaptic();
        break;
      case _SnackBarType.error:
        heavyHaptic();
        break;
      case _SnackBarType.warning:
        mediumHaptic();
        break;
      case _SnackBarType.info:
        lightHaptic();
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor ?? Colors.white),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? _getTypeColor(type),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        action: action,
      ),
    );
  }
  
  /// Show success snackbar
  static void showSuccessSnackBar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    showEnhancedSnackBar(
      context: context,
      message: message,
      icon: Icons.check_circle_outline,
      type: _SnackBarType.success,
      duration: duration,
    );
  }
  
  /// Show error snackbar
  static void showErrorSnackBar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 5),
  }) {
    showEnhancedSnackBar(
      context: context,
      message: message,
      icon: Icons.error_outline,
      type: _SnackBarType.error,
      duration: duration,
    );
  }
  
  // MARK: - Private Helpers
  
  static Color _getTypeColor(_SnackBarType type) {
    switch (type) {
      case _SnackBarType.success:
        return Colors.green.shade600;
      case _SnackBarType.error:
        return Colors.red.shade600;
      case _SnackBarType.warning:
        return Colors.orange.shade600;
      case _SnackBarType.info:
        return Colors.blue.shade600;
    }
  }
}

// MARK: - Enums and Types

enum _ButtonStyle { primary, secondary }
enum _SnackBarType { success, error, warning, info }

// MARK: - Private Widget Implementations

class _EnhancedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final _ButtonStyle style;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  
  const _EnhancedButton({
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    required this.style,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
  });
  
  @override
  State<_EnhancedButton> createState() => _EnhancedButtonState();
}

class _EnhancedButtonState extends State<_EnhancedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: HomeAnimationSystem.fast,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: HomeAnimationSystem.acceleratedEase,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(_controller);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _controller.forward();
      MicroInteractionsSystem.lightHaptic();
    }
  }
  
  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _controller.reverse();
      widget.onPressed!();
    }
  }
  
  void _onTapCancel() {
    _controller.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.style == _ButtonStyle.primary;
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                padding: widget.padding ?? const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? 
                    (isPrimary ? theme.primaryColor : Colors.transparent),
                  borderRadius: BorderRadius.circular(12),
                  border: isPrimary ? null : Border.all(
                    color: widget.foregroundColor ?? theme.primaryColor,
                    width: 2,
                  ),
                  boxShadow: isPrimary ? MoodColorSystemV2.getDepthShadows(
                    depth: 2,
                    color: theme.primaryColor,
                  ) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.foregroundColor ?? 
                            (isPrimary ? Colors.white : theme.primaryColor),
                          ),
                        ),
                      )
                    else if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: widget.foregroundColor ?? 
                          (isPrimary ? Colors.white : theme.primaryColor),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: widget.foregroundColor ?? 
                          (isPrimary ? Colors.white : theme.primaryColor),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EnhancedFAB extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? heroTag;
  final bool mini;
  
  const _EnhancedFAB({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.heroTag,
    this.mini = false,
  });
  
  @override
  State<_EnhancedFAB> createState() => _EnhancedFABState();
}

class _EnhancedFABState extends State<_EnhancedFAB>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _pressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pressController = AnimationController(
      duration: HomeAnimationSystem.fast,
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: HomeAnimationSystem.acceleratedEase,
    ));
    
    _pulseController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _pressController.dispose();
    super.dispose();
  }
  
  void _onPressed() {
    _pressController.forward().then((_) {
      _pressController.reverse();
    });
    
    MicroInteractionsSystem.mediumHaptic();
    widget.onPressed();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value * _scaleAnimation.value,
          child: FloatingActionButton(
            heroTag: widget.heroTag,
            mini: widget.mini,
            onPressed: _onPressed,
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
            tooltip: widget.tooltip,
            child: Icon(widget.icon),
          ),
        );
      },
    );
  }
}

class _InteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final bool enableRipple;
  final Color? rippleColor;
  final BorderRadius borderRadius;
  
  const _InteractiveCard({
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.enableRipple = true,
    this.rippleColor,
    required this.borderRadius,
  });
  
  @override
  State<_InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<_InteractiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: HomeAnimationSystem.fast,
      vsync: this,
    );
    
    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: HomeAnimationSystem.emphasizedEase,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    MicroInteractionsSystem.lightHaptic();
  }
  
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }
  
  void _onTapCancel() {
    _controller.reverse();
  }
  
  void _onLongPress() {
    MicroInteractionsSystem.heavyHaptic();
    widget.onLongPress?.call();
  }
  
  void _onDoubleTap() {
    MicroInteractionsSystem.quoteHaptic();
    widget.onDoubleTap?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _elevationAnimation,
      builder: (context, child) {
        return Material(
          elevation: _elevationAnimation.value,
          borderRadius: widget.borderRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onLongPress: widget.onLongPress != null ? _onLongPress : null,
            onDoubleTap: widget.onDoubleTap != null ? _onDoubleTap : null,
            borderRadius: widget.borderRadius,
            splashColor: widget.enableRipple ? 
              (widget.rippleColor ?? Theme.of(context).primaryColor.withOpacity(0.2)) : 
              Colors.transparent,
            highlightColor: widget.enableRipple ? 
              (widget.rippleColor ?? Theme.of(context).primaryColor.withOpacity(0.1)) : 
              Colors.transparent,
            child: widget.child,
          ),
        );
      },
    );
  }
}

// Placeholder implementations for remaining private widgets
class _PulseIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;
  final String? tooltip;
  final bool enablePulse;
  
  const _PulseIconButton({
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 24.0,
    this.tooltip,
    this.enablePulse = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color, size: size),
      onPressed: () {
        MicroInteractionsSystem.lightHaptic();
        onPressed();
      },
      tooltip: tooltip,
    );
  }
}

class _MorphingLoadingButton extends StatelessWidget {
  final String text;
  final Future<void> Function() onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Duration morphDuration;
  
  const _MorphingLoadingButton({
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.morphDuration = const Duration(milliseconds: 300),
  });
  
  @override
  Widget build(BuildContext context) {
    return MicroInteractionsSystem.primaryButton(
      text: text,
      onPressed: () => onPressed(),
      icon: icon,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }
}

class _ShimmerSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;
  
  const _ShimmerSkeleton({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.baseColor,
    required this.highlightColor,
    required this.duration,
  });
  
  @override
  Widget build(BuildContext context) {
    return HomeAnimationSystem.skeletonQuoteCard(
      width: width,
      height: height,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }
}

class _AnimatedCheckmark extends StatelessWidget {
  final Color color;
  final double size;
  final Duration duration;
  
  const _AnimatedCheckmark({
    required this.color,
    required this.size,
    required this.duration,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}

class _AnimatedErrorIndicator extends StatelessWidget {
  final Color color;
  final double size;
  final Duration duration;
  
  const _AnimatedErrorIndicator({
    required this.color,
    required this.size,
    required this.duration,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.close,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}
