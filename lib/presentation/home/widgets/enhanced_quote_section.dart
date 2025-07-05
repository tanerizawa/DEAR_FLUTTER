// lib/presentation/home/widgets/enhanced_quote_section.dart

import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_state.dart';
import 'package:dear_flutter/presentation/home/widgets/smart_loading_section.dart';
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

  // Get mood-based color scheme
  Map<String, dynamic> _getMoodTheme(String? mood) {
    switch (mood?.toLowerCase()) {
      case 'senang':
      case 'gembira':
      case 'bahagia':
        return {
          'gradient': [const Color(0xFFFFD700), const Color(0xFFFF8C00)],
          'accentColor': const Color(0xFFFFD700),
          'icon': Icons.sunny,
        };
      case 'sedih':
      case 'galau':
        return {
          'gradient': [const Color(0xFF4682B4), const Color(0xFF1E90FF)],
          'accentColor': const Color(0xFF4682B4),
          'icon': Icons.cloud_outlined,
        };
      case 'marah':
      case 'kesal':
        return {
          'gradient': [const Color(0xFFDC143C), const Color(0xFFFF6347)],
          'accentColor': const Color(0xFFDC143C),
          'icon': Icons.local_fire_department_outlined,
        };
      case 'tenang':
      case 'damai':
        return {
          'gradient': [const Color(0xFF20B2AA), const Color(0xFF48D1CC)],
          'accentColor': const Color(0xFF20B2AA),
          'icon': Icons.spa_outlined,
        };
      case 'excited':
      case 'antusias':
        return {
          'gradient': [const Color(0xFF9370DB), const Color(0xFFBA55D3)],
          'accentColor': const Color(0xFF9370DB),
          'icon': Icons.rocket_launch_outlined,
        };
      default:
        return {
          'gradient': [const Color(0xFF1DB954), const Color(0xFF1ed760)],
          'accentColor': const Color(0xFF1DB954),
          'icon': Icons.format_quote_rounded,
        };
    }
  }

  void _copyQuote(String text, String author) {
    Clipboard.setData(ClipboardData(text: '"$text" - $author'));
    HapticFeedback.lightImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Text('Kutipan disalin ke clipboard'),
          ],
        ),
        backgroundColor: const Color(0xFF1DB954),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final staticQuote = MotivationalQuote(
      id: 0, 
      text: 'Setiap hari adalah kesempatan baru untuk menjadi versi terbaik dari diri Anda.', 
      author: 'Dear Diary'
    );

    return BlocBuilder<HomeFeedCubit, HomeFeedState>(
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
        final mood = state.lastMood;
        final moodTheme = _getMoodTheme(mood);

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildQuoteCard(quote, moodTheme, mood),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Gagal memuat kutipan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    errorMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red.shade300,
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
    final Color accentColor = moodTheme['accentColor'];
    final IconData iconData = moodTheme['icon'];

    return GestureDetector(
      onLongPress: () => _copyQuote(quote.text, quote.author),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF232526),
              accentColor.withOpacity(0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: accentColor.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: accentColor.withOpacity(0.3), 
            width: 1.5
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header with mood indicator
              if (mood != null) _buildMoodHeader(mood, accentColor, iconData),
              
              // Quote content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quote icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.format_quote_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Quote text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: Text(
                            '"${quote.text}"',
                            key: ValueKey<String>(quote.text),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.white,
                              letterSpacing: -0.3,
                              height: 1.4,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Author with gradient text
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: ShaderMask(
                            key: ValueKey<String>(quote.author),
                            shaderCallback: (bounds) => LinearGradient(
                              colors: gradientColors,
                            ).createShader(bounds),
                            child: Text(
                              '— ${quote.author}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Action buttons
              const SizedBox(height: 16),
              _buildActionButtons(quote, accentColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodHeader(String mood, Color accentColor, IconData iconData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 16, color: accentColor),
          const SizedBox(width: 6),
          Text(
            'Mood: ${mood.toUpperCase()}',
            style: TextStyle(
              color: accentColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(MotivationalQuote quote, Color accentColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          icon: Icons.copy_outlined,
          tooltip: 'Salin kutipan',
          onPressed: () => _copyQuote(quote.text, quote.author),
          accentColor: accentColor,
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: Icons.share_outlined,
          tooltip: 'Bagikan',
          onPressed: () {
            HapticFeedback.lightImpact();
            // TODO: Implement share functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Fitur berbagi akan segera hadir!'),
                backgroundColor: accentColor,
              ),
            );
          },
          accentColor: accentColor,
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: Icons.favorite_border_outlined,
          tooltip: 'Simpan ke favorit',
          onPressed: () {
            HapticFeedback.lightImpact();
            // TODO: Implement save to favorites
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kutipan disimpan ke favorit!'),
                backgroundColor: accentColor,
              ),
            );
          },
          accentColor: accentColor,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required Color accentColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}
