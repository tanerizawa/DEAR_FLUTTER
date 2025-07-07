// lib/core/theme/advanced_gesture_system.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dear_flutter/core/theme/micro_interactions_system.dart';

/// Phase 4: Advanced Gesture System
/// 
/// Provides sophisticated gesture interactions and touch feedback
/// for enhanced user experience and intuitive navigation
class AdvancedGestureSystem {
  
  // Gesture thresholds and configurations
  static const double swipeThreshold = 50.0;
  static const double velocityThreshold = 300.0;
  static const Duration longPressDelay = Duration(milliseconds: 500);
  static const Duration doubleTapTimeout = Duration(milliseconds: 300);
  static const double pinchThreshold = 0.1;
  
  // Custom gesture recognizers and handlers
  
  /// Enhanced quote card with multiple gesture interactions
  static Widget interactiveQuoteCard({
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onDoubleTap,
    VoidCallback? onLongPress,
    Function(DragEndDetails)? onSwipeLeft,
    Function(DragEndDetails)? onSwipeRight,
    Function(DragEndDetails)? onSwipeUp,
    Function(DragEndDetails)? onSwipeDown,
    Function(ScaleUpdateDetails)? onPinch,
    bool enableHaptics = true,
    bool enableAnimations = true,
  }) {
    return _InteractiveQuoteCard(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onSwipeLeft: onSwipeLeft,
      onSwipeRight: onSwipeRight,
      onSwipeUp: onSwipeUp,
      onSwipeDown: onSwipeDown,
      onPinch: onPinch,
      enableHaptics: enableHaptics,
      enableAnimations: enableAnimations,
      child: child,
    );
  }
  
  /// Smart pull-to-refresh with personalized feedback
  static Widget smartRefreshIndicator({
    required Widget child,
    required Future<void> Function() onRefresh,
    String? refreshMessage,
    Color? indicatorColor,
  }) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: indicatorColor,
      backgroundColor: Colors.white,
      strokeWidth: 3.0,
      displacement: 60.0,
      child: child,
    );
  }
  
  /// Swipe-to-action gesture for quote cards
  static Widget swipeToActionCard({
    required Widget child,
    required VoidCallback onSwipeLeft,
    required VoidCallback onSwipeRight,
    required IconData leftIcon,
    required IconData rightIcon,
    required Color leftColor,
    required Color rightColor,
    String? leftLabel,
    String? rightLabel,
  }) {
    return _SwipeToActionCard(
      onSwipeLeft: onSwipeLeft,
      onSwipeRight: onSwipeRight,
      leftIcon: leftIcon,
      rightIcon: rightIcon,
      leftColor: leftColor,
      rightColor: rightColor,
      leftLabel: leftLabel,
      rightLabel: rightLabel,
      child: child,
    );
  }
  
  /// Long press context menu for advanced actions
  static Widget contextMenuWrapper({
    required Widget child,
    required List<ContextMenuItem> menuItems,
    bool enableHaptics = true,
  }) {
    return _ContextMenuWrapper(
      menuItems: menuItems,
      enableHaptics: enableHaptics,
      child: child,
    );
  }
  
  /// Multi-directional swipe detector
  static Widget multiDirectionalSwipe({
    required Widget child,
    Function(SwipeDirection)? onSwipe,
    double sensitivity = 1.0,
  }) {
    return _MultiDirectionalSwipe(
      onSwipe: onSwipe,
      sensitivity: sensitivity,
      child: child,
    );
  }
  
  /// Pressure-sensitive touch feedback (for supported devices)
  static Widget pressureSensitiveTouch({
    required Widget child,
    Function(double pressure)? onPressureChange,
    VoidCallback? onForceTouch,
  }) {
    return _PressureSensitiveTouch(
      onPressureChange: onPressureChange,
      onForceTouch: onForceTouch,
      child: child,
    );
  }
  
  /// Smart gesture hints and tutorials
  static Widget gestureHint({
    required String message,
    required IconData icon,
    Duration displayDuration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
  }) {
    return _GestureHint(
      message: message,
      icon: icon,
      displayDuration: displayDuration,
      onDismiss: onDismiss,
    );
  }
}

/// Interactive quote card with multiple gesture support
class _InteractiveQuoteCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final Function(DragEndDetails)? onSwipeLeft;
  final Function(DragEndDetails)? onSwipeRight;
  final Function(DragEndDetails)? onSwipeUp;
  final Function(DragEndDetails)? onSwipeDown;
  final Function(ScaleUpdateDetails)? onPinch;
  final bool enableHaptics;
  final bool enableAnimations;
  
  const _InteractiveQuoteCard({
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
    this.onPinch,
    this.enableHaptics = true,
    this.enableAnimations = true,
  });
  
  @override
  State<_InteractiveQuoteCard> createState() => _InteractiveQuoteCardState();
}

class _InteractiveQuoteCardState extends State<_InteractiveQuoteCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  Offset? _startPanPosition;
  bool _isPanning = false;
  
  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.elasticOut,
    ));
  }
  
  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }
  
  void _handleTapDown(TapDownDetails details) {
    if (widget.enableAnimations) {
      _scaleController.forward();
    }
    
    if (widget.enableHaptics) {
      MicroInteractionsSystem.lightHaptic();
    }
  }
  
  void _handleTapUp() {
    if (widget.enableAnimations) {
      _scaleController.reverse();
    }
  }
  
  void _handleTapCancel() {
    if (widget.enableAnimations) {
      _scaleController.reverse();
    }
  }
  
  void _handlePanStart(DragStartDetails details) {
    _startPanPosition = details.localPosition;
    _isPanning = true;
  }
  
  void _handlePanEnd(DragEndDetails details) {
    if (!_isPanning || _startPanPosition == null) return;
    
    final velocity = details.velocity.pixelsPerSecond;
    
    if (velocity.distance > AdvancedGestureSystem.velocityThreshold) {
      if (velocity.dx.abs() > velocity.dy.abs()) {
        // Horizontal swipe
        if (velocity.dx > 0) {
          widget.onSwipeRight?.call(details);
        } else {
          widget.onSwipeLeft?.call(details);
        }
      } else {
        // Vertical swipe
        if (velocity.dy > 0) {
          widget.onSwipeDown?.call(details);
        } else {
          widget.onSwipeUp?.call(details);
        }
      }
      
      if (widget.enableHaptics) {
        MicroInteractionsSystem.mediumHaptic();
      }
      
      if (widget.enableAnimations) {
        _rotationController.forward().then((_) {
          _rotationController.reverse();
        });
      }
    }
    
    _isPanning = false;
    _startPanPosition = null;
  }
  
  void _handleLongPress() {
    widget.onLongPress?.call();
    
    if (widget.enableHaptics) {
      MicroInteractionsSystem.heavyHaptic();
    }
    
    if (widget.enableAnimations) {
      _rotationController.forward().then((_) {
        _rotationController.reverse();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    Widget gestureChild = widget.child;
    
    if (widget.enableAnimations) {
      gestureChild = AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: child,
            ),
          );
        },
        child: gestureChild,
      );
    }
    
    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      onLongPress: _handleLongPress,
      onTapDown: _handleTapDown,
      onTapUp: (_) => _handleTapUp(),
      onTapCancel: _handleTapCancel,
      onPanStart: _handlePanStart,
      onPanEnd: _handlePanEnd,
      onScaleUpdate: widget.onPinch,
      child: gestureChild,
    );
  }
}

/// Swipe-to-action card implementation
class _SwipeToActionCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final IconData leftIcon;
  final IconData rightIcon;
  final Color leftColor;
  final Color rightColor;
  final String? leftLabel;
  final String? rightLabel;
  
  const _SwipeToActionCard({
    required this.child,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.leftIcon,
    required this.rightIcon,
    required this.leftColor,
    required this.rightColor,
    this.leftLabel,
    this.rightLabel,
  });
  
  @override
  State<_SwipeToActionCard> createState() => _SwipeToActionCardState();
}

class _SwipeToActionCardState extends State<_SwipeToActionCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  double _dragExtent = 0.0;
  bool _dragUnderway = false;
  
  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.3, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }
  
  void _handleDragStart(DragStartDetails details) {
    _dragUnderway = true;
  }
  
  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_dragUnderway) return;
    
    final delta = details.primaryDelta ?? 0;
    _dragExtent += delta;
    
    final progress = (_dragExtent.abs() / 100.0).clamp(0.0, 1.0);
    _slideController.value = progress;
  }
  
  void _handleDragEnd(DragEndDetails details) {
    if (!_dragUnderway) return;
    
    final velocity = details.primaryVelocity ?? 0;
    
    if (_dragExtent.abs() > 50.0 || velocity.abs() > 300.0) {
      if (_dragExtent > 0) {
        widget.onSwipeRight();
      } else {
        widget.onSwipeLeft();
      }
      
      MicroInteractionsSystem.successHaptic();
    }
    
    _slideController.reverse();
    _dragExtent = 0.0;
    _dragUnderway = false;
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Context menu wrapper for long press actions
class _ContextMenuWrapper extends StatelessWidget {
  final Widget child;
  final List<ContextMenuItem> menuItems;
  final bool enableHaptics;
  
  const _ContextMenuWrapper({
    required this.child,
    required this.menuItems,
    this.enableHaptics = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (enableHaptics) {
          MicroInteractionsSystem.heavyHaptic();
        }
        _showContextMenu(context);
      },
      child: child,
    );
  }
  
  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ...menuItems.map((item) => ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              onTap: () {
                Navigator.pop(context);
                item.onTap();
              },
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Multi-directional swipe detector
class _MultiDirectionalSwipe extends StatelessWidget {
  final Widget child;
  final Function(SwipeDirection)? onSwipe;
  final double sensitivity;
  
  const _MultiDirectionalSwipe({
    required this.child,
    this.onSwipe,
    this.sensitivity = 1.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanEnd: (details) {
        final velocity = details.velocity.pixelsPerSecond;
        final threshold = AdvancedGestureSystem.velocityThreshold * sensitivity;
        
        if (velocity.distance > threshold) {
          if (velocity.dx.abs() > velocity.dy.abs()) {
            onSwipe?.call(velocity.dx > 0 ? SwipeDirection.right : SwipeDirection.left);
          } else {
            onSwipe?.call(velocity.dy > 0 ? SwipeDirection.down : SwipeDirection.up);
          }
        }
      },
      child: child,
    );
  }
}

/// Pressure-sensitive touch detector
class _PressureSensitiveTouch extends StatelessWidget {
  final Widget child;
  final Function(double pressure)? onPressureChange;
  final VoidCallback? onForceTouch;
  
  const _PressureSensitiveTouch({
    required this.child,
    this.onPressureChange,
    this.onForceTouch,
  });
  
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        onPressureChange?.call(event.pressure);
        if (event.pressure > 0.8) {
          onForceTouch?.call();
        }
      },
      child: child,
    );
  }
}

/// Gesture hint overlay
class _GestureHint extends StatefulWidget {
  final String message;
  final IconData icon;
  final Duration displayDuration;
  final VoidCallback? onDismiss;
  
  const _GestureHint({
    required this.message,
    required this.icon,
    this.displayDuration = const Duration(seconds: 3),
    this.onDismiss,
  });
  
  @override
  State<_GestureHint> createState() => _GestureHintState();
}

class _GestureHintState extends State<_GestureHint>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward();
    
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss?.call();
        });
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Context menu item data class
class ContextMenuItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  
  const ContextMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

/// Swipe direction enum
enum SwipeDirection {
  up,
  down,
  left,
  right,
}
