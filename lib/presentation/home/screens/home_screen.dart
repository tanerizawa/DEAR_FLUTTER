// lib/presentation/home/screens/home_screen.dart

import 'package:dear_flutter/core/theme/mood_color_system.dart';
import 'package:dear_flutter/presentation/home/cubit/improved_home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/widgets/enhanced_quote_section.dart';
import 'package:dear_flutter/presentation/home/widgets/unified_media_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> 
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh(BuildContext context) async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });

    try {
      HapticFeedback.lightImpact();
      await context.read<ImprovedHomeFeedCubit>().fetchHomeFeed(forceRefresh: true);
      
      // Success haptic feedback
      HapticFeedback.selectionClick();
      
    } catch (e) {
      debugPrint('Failed to refresh home feed: $e');
      
      // Error haptic feedback
      HapticFeedback.heavyImpact();
      
      if (context.mounted) {
        _showErrorSnackBar(context, 'Gagal memperbarui konten: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Coba Lagi',
          textColor: Colors.white,
          onPressed: () => _onRefresh(context),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 17) {
      return 'Selamat Siang';
    } else if (hour < 20) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: MoodColorSystem.surface, // New improved background
      body: RefreshIndicator(
        color: const Color(0xFF26A69A), // Updated accent color
        backgroundColor: MoodColorSystem.surfaceVariant,
        onRefresh: () => _onRefresh(context),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // App Bar with greeting
            SliverAppBar(
              expandedHeight: 90, // Further reduced from 100 to prevent any overflow
              floating: true,
              pinned: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        MoodColorSystem.surface,
                        MoodColorSystem.surface.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate available height accounting for padding
                        final availableHeight = constraints.maxHeight;
                        final horizontalPadding = MoodColorSystem.space_md;
                        final verticalPadding = MoodColorSystem.space_xs; // Further reduced padding
                        
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: verticalPadding,
                          ),
                          child: Container(
                            height: availableHeight - (verticalPadding * 2), // Explicit height constraint
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    _getGreeting(),
                                    style: MoodColorSystem.getTextStyle(
                                      fontSize: MoodColorSystem.text_lg, // Further reduced font size
                                      fontWeight: FontWeight.bold,
                                      color: MoodColorSystem.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: MoodColorSystem.space_xs), // Minimal spacing
                                Flexible(
                                  child: Text(
                                    'Bagaimana perasaan Anda hari ini?',
                                    style: MoodColorSystem.getTextStyle(
                                      fontSize: MoodColorSystem.text_sm, // Further reduced font size
                                      color: MoodColorSystem.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Content sections
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: MoodColorSystem.space_md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Quote Section
                  _buildSection(
                    title: 'Inspirasi Hari Ini',
                    icon: Icons.auto_awesome,
                    child: const EnhancedQuoteSection(),
                  ),
                  
                  SizedBox(height: MoodColorSystem.space_2xl),
                  
                  // Unified Media Section (Music + Radio)
                  _buildSection(
                    title: 'Media Player',
                    icon: Icons.library_music_rounded,
                    child: const UnifiedMediaSection(),
                    showRefreshButton: true,
                    onRefresh: () => _onRefresh(context),
                  ),
                  
                  SizedBox(height: MoodColorSystem.space_xl),
                  
                  // Footer
                  _buildFooter(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
    bool showRefreshButton = false,
    VoidCallback? onRefresh,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(MoodColorSystem.space_sm),
              decoration: BoxDecoration(
                color: const Color(0xFF26A69A).withOpacity(0.15),
                borderRadius: BorderRadius.circular(MoodColorSystem.space_md),
                border: Border.all(
                  color: const Color(0xFF26A69A).withOpacity(0.3),
                  width: 1.0,
                ),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF26A69A),
                size: MoodColorSystem.space_md,
              ),
            ),
            SizedBox(width: MoodColorSystem.space_md),
            Expanded(
              child: Text(
                title,
                style: MoodColorSystem.getTextStyle(
                  fontSize: MoodColorSystem.text_xl,
                  fontWeight: FontWeight.bold,
                  color: MoodColorSystem.onSurface,
                ),
              ),
            ),
            if (showRefreshButton && onRefresh != null)
              IconButton(
                icon: AnimatedRotation(
                  turns: _isRefreshing ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Icon(
                    Icons.refresh_rounded,
                    color: MoodColorSystem.onSurfaceVariant,
                  ),
                ),
                onPressed: _isRefreshing ? null : onRefresh,
                tooltip: 'Refresh musik',
              ),
          ],
        ),
        
        SizedBox(height: MoodColorSystem.space_md),
        
        // Section Content
        child,
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(MoodColorSystem.space_md),
      decoration: BoxDecoration(
        color: MoodColorSystem.surfaceContainer,
        borderRadius: BorderRadius.circular(MoodColorSystem.space_md),
        border: Border.all(color: MoodColorSystem.outline),
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite,
            color: Color(0xFF26A69A),
            size: MoodColorSystem.space_lg,
          ),
          SizedBox(height: MoodColorSystem.space_sm),
          Text(
            'Dibuat dengan ❤️ untuk keseharian yang lebih bermakna',
            style: MoodColorSystem.getTextStyle(
              fontSize: MoodColorSystem.text_sm,
              color: MoodColorSystem.onSurfaceSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}