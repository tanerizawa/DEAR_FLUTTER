// lib/presentation/home/widgets/enhanced_quote_section.dart

import 'package:dear_flutter/core/theme/home_layout_system.dart';
import 'package:dear_flutter/core/theme/home_typography_system.dart';
import 'package:dear_flutter/core/theme/mood_color_system_v2.dart';
import 'package:dear_flutter/core/theme/home_animation_system.dart';
import 'package:dear_flutter/core/theme/micro_interactions_system.dart';
import 'package:dear_flutter/core/theme/skeleton_loading_system.dart';
import 'package:dear_flutter/core/theme/advanced_error_system.dart';
import 'package:dear_flutter/core/theme/content_personalization_system.dart';
import 'package:dear_flutter/core/theme/advanced_gesture_system.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/presentation/home/cubit/improved_home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EnhancedQuoteSection extends StatefulWidget {
  const EnhancedQuoteSection({super.key});

  @override
  State<EnhancedQuoteSection> createState() => _EnhancedQuoteSectionState();
}

class _EnhancedQuoteSectionState extends State<EnhancedQuoteSection> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize Phase 4 personalization system
    ContentPersonalizationSystem.initialize();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // MARK: - Enhanced Phase 2 Methods
  
  /// Enhanced quote copying with haptic feedback and improved UX
  void _copyQuoteWithFeedback(String text, String author) {
    Clipboard.setData(ClipboardData(text: '"$text" - $author'));
    MicroInteractionsSystem.successHaptic();
    
    // Track interaction for personalization
    ContentPersonalizationSystem.recordInteraction(
      contentId: text.hashCode.toString(),
      type: InteractionType.copy,
      category: ContentCategory.motivation,
      metadata: {'author': author, 'action': 'copy'},
    );
    
    if (mounted) {
      MicroInteractionsSystem.showSuccessSnackBar(
        context: context,
        message: 'Quote copied to clipboard',
      );
    }
  }
  
  /// Share quote functionality
  void _shareQuote(String text, String author) {
    MicroInteractionsSystem.mediumHaptic();
    
    // Track interaction for personalization
    ContentPersonalizationSystem.recordInteraction(
      contentId: text.hashCode.toString(),
      type: InteractionType.share,
      category: ContentCategory.motivation,
      metadata: {'author': author, 'action': 'share'},
    );
    
    // TODO: Implement share functionality
    if (mounted) {
      MicroInteractionsSystem.showEnhancedSnackBar(
        context: context,
        message: 'Share feature coming soon!',
        icon: Icons.share,
      );
    }
  }
  
  /// Favorite quote functionality
  void _favoriteQuote(MotivationalQuote quote) {
    MicroInteractionsSystem.heavyHaptic();
    
    // Track interaction for personalization
    ContentPersonalizationSystem.recordInteraction(
      contentId: quote.text.hashCode.toString(),
      type: InteractionType.favorite,
      category: ContentCategory.motivation,
      metadata: {'author': quote.author, 'action': 'favorite'},
    );
    
    // TODO: Implement favorite functionality
    if (mounted) {
      MicroInteractionsSystem.showEnhancedSnackBar(
        context: context,
        message: 'Added to favorites!',
        icon: Icons.favorite,
        backgroundColor: Colors.pink.shade600,
      );
    }
  }
  
  /// Enhanced quote icon with animations
  Widget _buildEnhancedQuoteIcon(String mood) {
    final moodColors = MoodColorSystemV2.getAnalogousColors(mood);
    
    return MicroInteractionsSystem.pulseIconButton(
      icon: Icons.format_quote_rounded,
      onPressed: () => MicroInteractionsSystem.lightHaptic(),
      color: moodColors.first,
      size: 32.0,
      tooltip: 'Quote icon',
    );
  }
  
  /// Enhanced quote footer with author styling
  Widget _buildEnhancedQuoteFooter(String author) {
    return Row(
      children: [
        Icon(
          Icons.person_outline,
          size: 16,
          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '— $author',
            style: HomeTypographySystem.bodyText().copyWith(
              fontStyle: FontStyle.italic,
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  /// Enhanced action row with micro-interactions
  Widget _buildEnhancedActionRow(MotivationalQuote quote) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Copy button
        MicroInteractionsSystem.pulseIconButton(
          icon: Icons.copy_outlined,
          onPressed: () => _copyQuoteWithFeedback(quote.text, quote.author),
          tooltip: 'Copy quote',
          size: 20,
        ),
        
        // Share button  
        MicroInteractionsSystem.pulseIconButton(
          icon: Icons.share_outlined,
          onPressed: () => _shareQuote(quote.text, quote.author),
          tooltip: 'Share quote',
          size: 20,
        ),
        
        // Favorite button
        MicroInteractionsSystem.pulseIconButton(
          icon: Icons.favorite_outline,
          onPressed: () => _favoriteQuote(quote),
          tooltip: 'Add to favorites',
          size: 20,
        ),
        
        // Refresh button
        MicroInteractionsSystem.pulseIconButton(
          icon: Icons.refresh_outlined,
          onPressed: () {
            context.read<ImprovedHomeFeedCubit>().fetchHomeFeed(forceRefresh: true);
            MicroInteractionsSystem.mediumHaptic();
          },
          tooltip: 'Get new quote',
          size: 20,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const staticQuote = MotivationalQuote(
      id: 0, 
      text: 'Setiap hari adalah kesempatan baru untuk menjadi versi terbaik dari diri Anda.', 
      author: 'Dear Diary'
    );

    return BlocBuilder<ImprovedHomeFeedCubit, HomeFeedState>(
      builder: (context, state) {
        if (state.status == HomeFeedStatus.loading) {
          return SkeletonLoadingSystem.smartLoadingState(
            contentType: 'quote',
            loadingMessage: 'Menyiapkan kutipan inspiratif...',
            isSlowConnection: false,
            isDarkMode: Theme.of(context).brightness == Brightness.dark,
          );
        }

        if (state.status == HomeFeedStatus.failure) {
          return _buildEnhancedErrorState(state.errorMessage);
        }

        final quote = state.feed?.quote ?? staticQuote;
        final mood = state.lastMood ?? 'wisdom';
        
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildOptimizedQuoteCard(quote, mood),
          ),
        );
      },
    );
  }

  /// Optimized quote card using new design system with Phase 4 enhancements
  Widget _buildOptimizedQuoteCard(MotivationalQuote quote, String mood) {
    // Track view interaction for personalization
    ContentPersonalizationSystem.recordInteraction(
      contentId: quote.text.hashCode.toString(),
      type: InteractionType.view,
      category: ContentCategory.motivation,
      metadata: {'author': quote.author, 'mood': mood},
    );
    
    return AdvancedGestureSystem.interactiveQuoteCard(
      onTap: () {
        _copyQuoteWithFeedback(quote.text, quote.author);
        ContentPersonalizationSystem.recordInteraction(
          contentId: quote.text.hashCode.toString(),
          type: InteractionType.longView,
          category: ContentCategory.motivation,
          metadata: {'action': 'tap_copy'},
        );
      },
      onLongPress: () {
        _showQuoteContextMenu(quote);
      },
      onDoubleTap: () {
        _favoriteQuote(quote);
      },
      onSwipeLeft: (_) {
        // Skip to next quote
        ContentPersonalizationSystem.recordInteraction(
          contentId: quote.text.hashCode.toString(),
          type: InteractionType.skip,
          category: ContentCategory.motivation,
          metadata: {'action': 'swipe_skip'},
        );
        context.read<ImprovedHomeFeedCubit>().fetchHomeFeed(forceRefresh: true);
        MicroInteractionsSystem.mediumHaptic();
      },
      onSwipeRight: (_) {
        // Share quote
        _shareQuote(quote.text, quote.author);
      },
      enableHaptics: true,
      enableAnimations: true,
      child: Container(
        height: HomeLayoutSystem.quoteHeight,
        constraints: HomeLayoutSystem.getCardConstraints(context),
        decoration: BoxDecoration(
          gradient: MoodColorSystemV2.getCurrentMoodGradient(mood: mood),
          borderRadius: BorderRadius.circular(FibonacciSpacing.lg),
          boxShadow: MoodColorSystemV2.getDepthShadows(
            depth: 3,
            isDarkMode: Theme.of(context).brightness == Brightness.dark,
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            // Background glassmorphism effect
            Container(
              decoration: MoodColorSystemV2.createGlassMorphism(
                blur: 15.0,
                opacity: 0.1,
              ),
            ),
            
            // Content with enhanced animations
            Padding(
              padding: const EdgeInsets.all(FibonacciSpacing.md), // Reduced from lg
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced quote icon with mood coloring
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildEnhancedQuoteIcon(mood),
                      // Gesture hint for new users - wrapped in Flexible to prevent overflow
                      if (_shouldShowGestureHints())
                        Flexible(
                          child: AdvancedGestureSystem.gestureHint(
                            message: 'Swipe for actions',
                            icon: Icons.swipe,
                            displayDuration: const Duration(seconds: 2),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: FibonacciSpacing.sm), // Reduced from md
                  
                  // Quote text with reveal animation
                  Expanded(
                    child: HomeAnimationSystem.animatedQuoteReveal(
                      text: '"${quote.text}"',
                      controller: _fadeController,
                      textStyle: HomeTypographySystem.quoteText()
                        .copyWith(
                          color: MoodColorSystemV2.getAccessibleColor(
                            background: Theme.of(context).cardColor,
                            foreground: Theme.of(context).textTheme.bodyLarge!.color!,
                          ),
                        ),
                      delay: const Duration(milliseconds: 200),
                    ),
                  ),
                  
                  const SizedBox(height: FibonacciSpacing.xs), // Reduced from sm
                  
                  // Author with enhanced styling
                  _buildEnhancedQuoteFooter(quote.author),
                  
                  const SizedBox(height: FibonacciSpacing.xs), // Reduced from sm
                  
                  // Enhanced action buttons
                  _buildEnhancedActionRow(quote),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Enhanced error state using advanced error system
  Widget _buildEnhancedErrorState(String? errorMessage) {
    return AdvancedErrorSystem.errorWidget(
      errorType: ErrorType.network,
      message: errorMessage ?? 'Failed to load inspirational quote. Please check your connection and try again.',
      severity: ErrorSeverity.medium,
      onRetry: () {
        context.read<ImprovedHomeFeedCubit>().fetchHomeFeed(forceRefresh: true);
        MicroInteractionsSystem.mediumHaptic();
      },
      retryText: 'Try Again',
      isDarkMode: Theme.of(context).brightness == Brightness.dark,
      showDetails: false,
    );
  }

  
  /// Phase 4: Show quote context menu with advanced actions
  void _showQuoteContextMenu(MotivationalQuote quote) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Quote preview
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '"${quote.text}"',
                  style: HomeTypographySystem.bodyText().copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action options
              _buildContextMenuAction(
                icon: Icons.copy_outlined,
                title: 'Copy Quote',
                subtitle: 'Copy to clipboard',
                onTap: () {
                  Navigator.pop(context);
                  _copyQuoteWithFeedback(quote.text, quote.author);
                },
              ),
              _buildContextMenuAction(
                icon: Icons.share_outlined,
                title: 'Share Quote',
                subtitle: 'Share with others',
                onTap: () {
                  Navigator.pop(context);
                  _shareQuote(quote.text, quote.author);
                },
              ),
              _buildContextMenuAction(
                icon: Icons.favorite_outline,
                title: 'Add to Favorites',
                subtitle: 'Save for later',
                onTap: () {
                  Navigator.pop(context);
                  _favoriteQuote(quote);
                },
              ),
              _buildContextMenuAction(
                icon: Icons.refresh_outlined,
                title: 'Get New Quote',
                subtitle: 'Load different quote',
                onTap: () {
                  Navigator.pop(context);
                  context.read<ImprovedHomeFeedCubit>().fetchHomeFeed(forceRefresh: true);
                  MicroInteractionsSystem.mediumHaptic();
                },
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
  
  /// Build context menu action item
  Widget _buildContextMenuAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: HomeTypographySystem.bodyText().copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: HomeTypographySystem.bodyText().copyWith(
          fontSize: 14,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
      onTap: onTap,
    );
  }
  
  /// Phase 4: Check if gesture hints should be shown to new users
  bool _shouldShowGestureHints() {
    // Show hints for first 3 app launches or if user hasn't used gestures
    return ContentPersonalizationSystem.shouldShowGestureHints();
  }
}
