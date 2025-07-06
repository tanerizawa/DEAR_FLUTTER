// lib/presentation/home/widgets/golden_ratio_card.dart

import 'package:flutter/material.dart';
import 'package:dear_flutter/core/theme/golden_design_system.dart';
import 'dart:math' as math;

/// A card widget that implements Golden Ratio proportions, Fibonacci spacing,
/// and psychology-based color schemes for optimal visual appeal and user experience
class GoldenRatioCard extends StatefulWidget {
  final Widget child;
  final String context;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final bool isInteractive;
  final bool isGlowing;
  final double elevation;
  final bool useGoldenProportions;

  const GoldenRatioCard({
    super.key,
    required this.child,
    this.context = 'calm',
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.onTap,
    this.isInteractive = false,
    this.isGlowing = false,
    this.elevation = 1,
    this.useGoldenProportions = true,
  });

  @override
  State<GoldenRatioCard> createState() => _GoldenRatioCardState();
}

class _GoldenRatioCardState extends State<GoldenRatioCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _tapController;
  late AnimationController _glowController;
  
  late Animation<double> _hoverAnimation;
  late Animation<double> _tapAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
    
    _tapAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isGlowing) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _tapController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isInteractive) {
      _tapController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isInteractive) {
      _tapController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.isInteractive) {
      _tapController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = GoldenDesignSystem.getColorScheme(widget.context);
    final screenSize = MediaQuery.of(context).size;
    
    // Calculate optimal dimensions using golden ratio
    double cardWidth = widget.width ?? screenSize.width - (GoldenDesignSystem.space_5 * 2);
    double cardHeight = widget.height ?? 
        (widget.useGoldenProportions 
            ? GoldenDesignSystem.getGoldenRatioHeight(cardWidth)
            : GoldenDesignSystem.cardStandardHeight);
    
    // Ensure minimum height for usability
    cardHeight = math.max(cardHeight, GoldenDesignSystem.cardMinHeight);
    
    return AnimatedBuilder(
      animation: Listenable.merge([_hoverAnimation, _tapAnimation, _glowAnimation]),
      builder: (context, child) {
        return Container(
          width: cardWidth,
          height: cardHeight,
          margin: widget.margin ?? EdgeInsets.all(GoldenDesignSystem.space_3),
          child: Transform.scale(
            scale: _tapAnimation.value,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: widget.onTap,
              child: MouseRegion(
                onEnter: (_) {
                  if (widget.isInteractive) {
                    setState(() => _isHovered = true);
                    _hoverController.forward();
                  }
                },
                onExit: (_) {
                  if (widget.isInteractive) {
                    setState(() => _isHovered = false);
                    _hoverController.reverse();
                  }
                },
                child: Container(
                  decoration: _buildCardDecoration(colorScheme),
                  padding: widget.padding ?? EdgeInsets.all(GoldenDesignSystem.space_5),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildCardDecoration(PsychologyColorScheme colorScheme) {
    final baseElevation = widget.elevation;
    final hoverElevation = baseElevation + (_hoverAnimation.value * 2);
    final glowIntensity = widget.isGlowing ? _glowAnimation.value : 0.0;
    
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          GoldenDesignSystem.surfaceContainer,
          colorScheme.primary.withOpacity(0.05 + (_hoverAnimation.value * 0.05)),
        ],
      ),
      borderRadius: BorderRadius.circular(GoldenDesignSystem.radius_large),
      border: Border.all(
        color: colorScheme.primary.withOpacity(
          0.2 + (_hoverAnimation.value * 0.3) + (glowIntensity * 0.5)
        ),
        width: 1.0 + (_hoverAnimation.value * 0.5),
      ),
      boxShadow: [
        // Main shadow
        BoxShadow(
          color: Colors.black.withOpacity(0.2 + (_hoverAnimation.value * 0.1)),
          blurRadius: hoverElevation * GoldenDesignSystem.space_3,
          offset: Offset(0, hoverElevation * 2),
        ),
        // Colored shadow for depth
        BoxShadow(
          color: colorScheme.primary.withOpacity(
            0.1 + (_hoverAnimation.value * 0.2) + (glowIntensity * 0.3)
          ),
          blurRadius: hoverElevation * GoldenDesignSystem.space_2,
          offset: Offset(0, hoverElevation),
        ),
        // Glow effect
        if (widget.isGlowing || _isHovered) ...[
          BoxShadow(
            color: colorScheme.primary.withOpacity(glowIntensity * 0.4),
            blurRadius: GoldenDesignSystem.space_6,
            spreadRadius: 1,
          ),
        ],
      ],
    );
  }
}

/// Specialized quote card with golden ratio layout
class GoldenQuoteCard extends StatelessWidget {
  final String quote;
  final String author;
  final String mood;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onCopy;

  const GoldenQuoteCard({
    super.key,
    required this.quote,
    required this.author,
    this.mood = 'inspiration',
    this.onTap,
    this.onShare,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = GoldenDesignSystem.getColorScheme(mood);
    final screenWidth = MediaQuery.of(context).size.width;
    final optimalFontSize = GoldenDesignSystem.getOptimalFontSize(screenWidth);
    
    return GoldenRatioCard(
      context: mood,
      isInteractive: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mood indicator with psychology color
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: GoldenDesignSystem.space_3,
              vertical: GoldenDesignSystem.space_2,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(GoldenDesignSystem.radius_small),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.psychology_outlined,
                  size: GoldenDesignSystem.text_body2,
                  color: colorScheme.primary,
                ),
                SizedBox(width: GoldenDesignSystem.space_2),
                Text(
                  colorScheme.emotion,
                  style: GoldenDesignSystem.createOptimalTextStyle(
                    fontSize: GoldenDesignSystem.text_caption,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: GoldenDesignSystem.space_4),
          
          // Quote content with golden ratio spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quote icon
                Icon(
                  Icons.format_quote,
                  size: GoldenDesignSystem.space_6,
                  color: colorScheme.primary.withOpacity(0.7),
                ),
                
                SizedBox(height: GoldenDesignSystem.space_3),
                
                // Quote text
                Expanded(
                  child: Text(
                    quote,
                    style: GoldenDesignSystem.createOptimalTextStyle(
                      fontSize: optimalFontSize,
                      color: GoldenDesignSystem.onSurfaceDark,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                SizedBox(height: GoldenDesignSystem.space_3),
                
                // Author
                Row(
                  children: [
                    Container(
                      width: GoldenDesignSystem.space_6,
                      height: 1,
                      color: colorScheme.primary.withOpacity(0.5),
                    ),
                    SizedBox(width: GoldenDesignSystem.space_3),
                    Expanded(
                      child: Text(
                        author,
                        style: GoldenDesignSystem.createOptimalTextStyle(
                          fontSize: GoldenDesignSystem.text_body2,
                          color: GoldenDesignSystem.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: GoldenDesignSystem.space_4),
          
          // Action buttons with golden ratio spacing
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onCopy != null) ...[
                _buildActionButton(
                  icon: Icons.copy_outlined,
                  tooltip: 'Salin kutipan',
                  onPressed: onCopy!,
                  colorScheme: colorScheme,
                ),
                SizedBox(width: GoldenDesignSystem.space_3),
              ],
              if (onShare != null) ...[
                _buildActionButton(
                  icon: Icons.share_outlined,
                  tooltip: 'Bagikan kutipan',
                  onPressed: onShare!,
                  colorScheme: colorScheme,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required PsychologyColorScheme colorScheme,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(GoldenDesignSystem.radius_small),
        child: Container(
          padding: EdgeInsets.all(GoldenDesignSystem.space_2),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(GoldenDesignSystem.radius_small),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2),
              width: 1.0,
            ),
          ),
          child: Icon(
            icon,
            size: GoldenDesignSystem.text_body1,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Specialized media card with golden proportions
class GoldenMediaCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final Widget? controls;
  final String context;
  final bool isPlaying;
  final VoidCallback? onTap;

  const GoldenMediaCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.controls,
    this.context = 'entertainment',
    this.isPlaying = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = GoldenDesignSystem.getColorScheme(this.context);
    
    return GoldenRatioCard(
      context: this.context,
      isInteractive: true,
      isGlowing: isPlaying,
      onTap: onTap,
      child: Row(
        children: [
          // Album art with golden ratio sizing
          Container(
            width: GoldenDesignSystem.space_8,
            height: GoldenDesignSystem.space_8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(GoldenDesignSystem.radius_medium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: GoldenDesignSystem.space_3,
                  offset: Offset(0, GoldenDesignSystem.space_2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(GoldenDesignSystem.radius_medium),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(colorScheme),
                    )
                  : _buildPlaceholder(colorScheme),
            ),
          ),
          
          SizedBox(width: GoldenDesignSystem.space_4),
          
          // Content with golden ratio layout
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoldenDesignSystem.createOptimalTextStyle(
                    fontSize: GoldenDesignSystem.text_body1,
                    color: GoldenDesignSystem.onSurfaceDark,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                if (subtitle != null) ...[
                  SizedBox(height: GoldenDesignSystem.space_2),
                  Text(
                    subtitle!,
                    style: GoldenDesignSystem.createOptimalTextStyle(
                      fontSize: GoldenDesignSystem.text_body2,
                      color: GoldenDesignSystem.onSurfaceVariant,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                if (controls != null) ...[
                  SizedBox(height: GoldenDesignSystem.space_3),
                  controls!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(PsychologyColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colorScheme.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.music_note,
        size: GoldenDesignSystem.space_6,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }
}
