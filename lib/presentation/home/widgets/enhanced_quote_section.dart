// lib/presentation/home/widgets/enhanced_quote_section.dart

import 'package:dear_flutter/core/theme/mood_color_system.dart';
import 'package:dear_flutter/core/theme/golden_design_system.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/presentation/home/cubit/improved_home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_state.dart';
import 'package:dear_flutter/presentation/home/widgets/smart_loading_section.dart';
import 'package:dear_flutter/presentation/home/widgets/golden_ratio_card.dart';
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

  // Get mood-based color scheme using MoodColorSystem
  Map<String, dynamic> _getMoodTheme(String? mood) {
    return MoodColorSystem.getMoodTheme(mood);
  }

  void _copyQuote(String text, String author) {
    Clipboard.setData(ClipboardData(text: '"$text" - $author'));
    HapticFeedback.lightImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline, 
              color: GoldenDesignSystem.onSurfaceDark,
            ),
            SizedBox(width: GoldenDesignSystem.space_3),
            Text(
              'Kutipan disalin ke clipboard',
              style: GoldenDesignSystem.createOptimalTextStyle(
                fontSize: GoldenDesignSystem.text_body2,
                color: GoldenDesignSystem.onSurfaceDark,
              ),
            ),
          ],
        ),
        backgroundColor: GoldenDesignSystem.surfaceContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GoldenDesignSystem.radius_medium),
        ),
        margin: EdgeInsets.all(GoldenDesignSystem.space_4),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareQuote(String text, String author) {
    // Implement share functionality
    HapticFeedback.selectionClick();
    // Share.share('"$text" - $author');
  }

  @override
  Widget build(BuildContext context) {
    final staticQuote = MotivationalQuote(
      id: 0, 
      text: 'Setiap hari adalah kesempatan baru untuk menjadi versi terbaik dari diri Anda.', 
      author: 'Dear Diary'
    );

    return BlocBuilder<ImprovedHomeFeedCubit, HomeFeedState>(
      builder: (context, state) {
        if (state.status == HomeFeedStatus.loading) {
          return SmartLoadingSection(
            loadingText: 'Menyiapkan kutipan inspiratif...',
            icon: Icons.format_quote_rounded,
          );
        }

        if (state.status == HomeFeedStatus.failure) {
          return _buildErrorState(state.errorMessage);
        }

        final quote = state.feed?.quote ?? staticQuote;
        final mood = state.lastMood ?? 'wisdom';
        
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: GoldenQuoteCard(
              quote: quote.text,
              author: quote.author,
              mood: mood,
              onCopy: () => _copyQuote(quote.text, quote.author),
              onShare: () => _shareQuote(quote.text, quote.author),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Container(
      padding: const EdgeInsets.all(MoodColorSystem.space_md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MoodColorSystem.space_md),
        color: MoodColorSystem.surfaceContainer,
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline, 
            color: Colors.red, 
            size: MoodColorSystem.space_lg,
          ),
          const SizedBox(width: MoodColorSystem.space_sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Gagal memuat kutipan',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: MoodColorSystem.text_lg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: MoodColorSystem.space_xs),
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red.shade300,
                      fontSize: MoodColorSystem.text_base,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(MotivationalQuote quote, Map<String, dynamic> moodTheme, String? mood) {
    final List<Color> gradientColors = moodTheme['gradient'];
    final Color primaryColor = moodTheme['primary'];
    final IconData iconData = moodTheme['icon'];

    return GestureDetector(
      onLongPress: () => _copyQuote(quote.text, quote.author),
      child: Container(
        // Golden ratio height: 144dp (cardHeightPrimary)
        height: MoodColorSystem.cardHeightPrimary,
        decoration: BoxDecoration(
          // Fibonacci border radius: 21dp
          borderRadius: BorderRadius.circular(MoodColorSystem.space_md),
          gradient: LinearGradient(
            colors: [
              MoodColorSystem.surfaceContainer,
              primaryColor.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: MoodColorSystem.space_md,
              offset: const Offset(0, MoodColorSystem.space_sm),
            ),
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
              blurRadius: MoodColorSystem.space_sm,
              offset: const Offset(0, MoodColorSystem.space_xs),
            ),
          ],
          border: Border.all(
            color: primaryColor.withOpacity(0.3), 
            width: 1.0
          ),
        ),
        child: Padding(
          // Golden ratio padding: 21dp
          padding: const EdgeInsets.all(MoodColorSystem.space_md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with mood indicator
              if (mood != null) _buildMoodHeader(mood, primaryColor, iconData),
              
              // Quote content with golden ratio spacing
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quote icon with Fibonacci sizing
                    Container(
                      width: MoodColorSystem.space_2xl, // 55dp
                      height: MoodColorSystem.space_2xl, // 55dp
                      padding: const EdgeInsets.all(MoodColorSystem.space_sm),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: MoodColorSystem.space_sm,
                            offset: const Offset(0, MoodColorSystem.space_xs),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.format_quote_rounded,
                        size: MoodColorSystem.space_md, // 21dp
                        color: MoodColorSystem.onSurface,
                      ),
                    ),
                    
                    const SizedBox(width: MoodColorSystem.space_sm),
                    
                    // Quote text with proper typography scale
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Text(
                              '"${quote.text}"',
                              key: ValueKey<String>(quote.text),
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                fontSize: MoodColorSystem.text_lg, // 20sp
                                color: MoodColorSystem.onSurface,
                                letterSpacing: -0.3,
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          const SizedBox(height: MoodColorSystem.space_sm),
                          
                          // Author with mood-based color
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Text(
                              '— ${quote.author}',
                              key: ValueKey<String>(quote.author),
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: primaryColor,
                                fontSize: MoodColorSystem.text_base, // 16sp
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action buttons with golden ratio spacing
              const SizedBox(height: MoodColorSystem.space_sm),
              _buildActionButtons(quote, primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodHeader(String mood, Color primaryColor, IconData iconData) {
    return Container(
      margin: const EdgeInsets.only(bottom: MoodColorSystem.space_sm),
      padding: const EdgeInsets.symmetric(
        horizontal: MoodColorSystem.space_sm, 
        vertical: MoodColorSystem.space_xs,
      ),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(MoodColorSystem.space_sm),
        border: Border.all(
          color: primaryColor.withOpacity(0.4),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData, 
            size: MoodColorSystem.text_base, // 16dp
            color: primaryColor,
          ),
          const SizedBox(width: MoodColorSystem.space_xs),
          Text(
            'Mood: ${mood.toUpperCase()}',
            style: TextStyle(
              color: primaryColor,
              fontSize: MoodColorSystem.text_sm, // 12sp
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(MotivationalQuote quote, Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          icon: Icons.copy_outlined,
          tooltip: 'Salin kutipan',
          onPressed: () => _copyQuote(quote.text, quote.author),
          primaryColor: primaryColor,
        ),
        const SizedBox(width: MoodColorSystem.space_sm),
        _buildActionButton(
          icon: Icons.share_outlined,
          tooltip: 'Bagikan',
          onPressed: () {
            HapticFeedback.lightImpact();
            // TODO: Implement share functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Fitur berbagi akan segera hadir!'),
                backgroundColor: primaryColor,
              ),
            );
          },
          primaryColor: primaryColor,
        ),
        const SizedBox(width: MoodColorSystem.space_sm),
        _buildActionButton(
          icon: Icons.favorite_border_outlined,
          tooltip: 'Simpan ke favorit',
          onPressed: () {
            HapticFeedback.lightImpact();
            // TODO: Implement save to favorites
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kutipan disimpan ke favorit!'),
                backgroundColor: primaryColor,
              ),
            );
          },
          primaryColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required Color primaryColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(MoodColorSystem.space_sm),
        child: Container(
          width: MoodColorSystem.space_lg, // 34dp
          height: MoodColorSystem.space_lg, // 34dp
          decoration: BoxDecoration(
            color: MoodColorSystem.surfaceVariant,
            borderRadius: BorderRadius.circular(MoodColorSystem.space_sm),
            border: Border.all(
              color: primaryColor.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: Icon(
            icon,
            size: MoodColorSystem.text_lg, // 20dp
            color: primaryColor,
          ),
        ),
      ),
    );
  }
}
