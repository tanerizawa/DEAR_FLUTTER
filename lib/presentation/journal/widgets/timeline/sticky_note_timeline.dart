import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dear_flutter/domain/entities/journal_entry.dart';
import 'package:dear_flutter/presentation/journal/widgets/timeline/sticky_note_journal_card.dart';
import 'package:dear_flutter/presentation/journal/widgets/timeline/timeline_thread_painter.dart';
import 'package:dear_flutter/presentation/journal/theme/enhanced_journal_theme.dart';
import 'package:dear_flutter/presentation/journal/animations/journal_micro_interactions.dart';

/// Timeline utama dengan sticky notes yang terhubung via thread/benang
class StickyNoteTimeline extends StatefulWidget {
  final List<JournalEntry> journals;
  final VoidCallback? onRefresh;
  final Function(JournalEntry)? onJournalTap;
  final Function(JournalEntry)? onJournalEdit;
  final Function(JournalEntry)? onJournalDelete;

  const StickyNoteTimeline({
    super.key,
    required this.journals,
    this.onRefresh,
    this.onJournalTap,
    this.onJournalEdit,
    this.onJournalDelete,
  });

  @override
  State<StickyNoteTimeline> createState() => _StickyNoteTimelineState();
}

class _StickyNoteTimelineState extends State<StickyNoteTimeline>
    with TickerProviderStateMixin {
  late AnimationController _scrollAnimationController;
  late Animation<double> _fadeInAnimation;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _timelineKey = GlobalKey();
  
  // Performance: Widget caching untuk items yang sudah di-render
  final Map<String, Widget> _widgetCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);
  
  // Layout configurations
  final double _threadWidth = 3.0;
  final double _timelineLeftPadding = 24.0;
  final double _cardSpacing = 32.0;
  final double _maxCardWidth = 280.0;

  @override
  void initState() {
    super.initState();
    
    _scrollAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scrollAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Start animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollAnimationController.forward();
    });
  }

  @override
  void didUpdateWidget(StickyNoteTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Clear cache and refresh if journals list changed
    if (widget.journals.length != oldWidget.journals.length ||
        _journalsContentChanged(oldWidget.journals)) {
      _widgetCache.clear();
      _cacheTimestamps.clear();
      
      // Restart animation for new content
      _scrollAnimationController.reset();
      _scrollAnimationController.forward();
    }
  }

  bool _journalsContentChanged(List<JournalEntry> oldJournals) {
    if (widget.journals.length != oldJournals.length) return true;
    
    for (int i = 0; i < widget.journals.length; i++) {
      if (widget.journals[i].id != oldJournals[i].id ||
          widget.journals[i].content != oldJournals[i].content ||
          widget.journals[i].mood != oldJournals[i].mood) {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    _scrollAnimationController.dispose();
    _scrollController.dispose();
    _widgetCache.clear();
    _cacheTimestamps.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.journals.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: RefreshIndicator(
            onRefresh: () async {
              JournalMicroInteractions.mediumTap();
              widget.onRefresh?.call();
            },
            color: EnhancedJournalColors.accentPrimary,
            backgroundColor: EnhancedJournalColors.cardBackground,
            child: CustomScrollView(
              key: _timelineKey,
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Timeline header
                SliverToBoxAdapter(
                  child: _buildTimelineHeader(),
                ),
                
                // Sticky notes timeline
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildCachedStickyNoteItem(index),
                    childCount: widget.journals.length,
                  ),
                ),
                
                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Row(
        children: [
          // Timeline icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_stories,
              color: Colors.white,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Header text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perjalanan Jurnal',
                  style: EnhancedJournalTypography.journalTitle(context).copyWith(
                    color: EnhancedJournalColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${widget.journals.length} catatan dalam timeline',
                  style: EnhancedJournalTypography.bodyMediumStyle(context).copyWith(
                    color: EnhancedJournalColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Stats summary
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final moodCounts = <String, int>{};
    for (final journal in widget.journals) {
      final mood = journal.mood.split(' ').first.toLowerCase();
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
    }
    
    final dominantMood = moodCounts.entries.isEmpty 
        ? 'netral' 
        : moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: EnhancedJournalColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: EnhancedJournalColors.getMoodColor(dominantMood).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: EnhancedJournalColors.getMoodColor(dominantMood),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            dominantMood.toUpperCase(),
            style: EnhancedJournalTypography.labelSmallStyle(context).copyWith(
              color: EnhancedJournalColors.getMoodColor(dominantMood),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyNoteItem(int index) {
    final journal = widget.journals[index];
    final isFirst = index == 0;
    final isLast = index == widget.journals.length - 1;
    final isEven = index % 2 == 0;
    
    // Dynamic note sizing based on content - favor larger sizes for better readability
    final contentLength = journal.content.length;
    StickyNoteSize noteSize;
    if (contentLength < 30) {
      noteSize = StickyNoteSize.medium; // Changed from small to medium
    } else if (contentLength > 150) {
      noteSize = StickyNoteSize.large;
    } else {
      noteSize = StickyNoteSize.large;  // Changed default to large for better readability
    }
    
    // Dynamic style based on mood and index
    StickyNoteStyle noteStyle = _getStickyNoteStyle(journal, index);
    
    // Calculate estimated height based on note size and content
    final double estimatedCardHeight = _getEstimatedCardHeight(noteSize, journal);
    final double stackHeight = estimatedCardHeight + _cardSpacing;
    
    return Container(
      margin: EdgeInsets.only(bottom: _cardSpacing),
      height: stackHeight, // Provide explicit height constraint
      child: Stack(
        clipBehavior: Clip.none, // Allow overflow for animations
        children: [
          // Timeline thread/benang
          if (!isLast)
            Positioned(
              left: _timelineLeftPadding + (_threadWidth / 2),
              top: 60, // Start from middle of current card
              child: TimelineThread(
                height: _cardSpacing + 40, // Extend to next card
                width: _threadWidth,
                journal: journal,
                nextJournal: index < widget.journals.length - 1 ? widget.journals[index + 1] : null,
                isAnimated: true,
                moodTransition: true,
              ),
            ),
          
          // Timeline dot/node
          Positioned(
            left: _timelineLeftPadding - 6,
            top: 30,
            child: _buildTimelineNode(journal, index),
          ),
          
          // Sticky note card
          Positioned(
            left: isEven ? _timelineLeftPadding + 40 : null,
            right: isEven ? null : _timelineLeftPadding + 40,
            top: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: _maxCardWidth,
                maxHeight: estimatedCardHeight, // Constrain height
              ),
              child: TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 400 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  // Ensure value is always within valid range to prevent opacity errors
                  final clampedValue = value.clamp(0.0, 1.0);
                  final safeOpacity = clampedValue.isNaN ? 0.0 : clampedValue;
                  
                  return Transform.translate(
                    offset: Offset((1 - clampedValue) * (isEven ? -100 : 100), 0),
                    child: Transform.scale(
                      scale: (0.8 + (0.2 * clampedValue)).clamp(0.1, 2.0),
                      child: Opacity(
                        opacity: safeOpacity,
                        child: child,
                      ),
                    ),
                  );
                },
                child: StickyNoteJournalCard(
                  journal: journal,
                  style: noteStyle,
                  noteSize: noteSize,
                  showThread: !isLast,
                  isConnected: !isFirst,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onJournalTap?.call(journal);
                  },
                  onEdit: () => widget.onJournalEdit?.call(journal),
                  onDelete: () => widget.onJournalDelete?.call(journal),
                ),
              ),
            ),
          ),
          
          // Date badge
          if (index == 0 || _isDifferentDay(journal, widget.journals[index - 1]))
            Positioned(
              top: 0,
              left: _timelineLeftPadding - 30,
              right: _timelineLeftPadding - 30,
              child: _buildDateBadge(journal),
            ),
        ],
      ),
    );
  }

  /// Performance: Build cached sticky note item dengan memoization
  Widget _buildCachedStickyNoteItem(int index) {
    final journal = widget.journals[index];
    final cacheKey = _generateCacheKey(journal, index);
    
    // Check cache validity
    if (_isValidCache(cacheKey)) {
      return _widgetCache[cacheKey]!;
    }
    
    // Build new widget and cache it
    final stickyNoteWidget = _buildStickyNoteItem(index);
    _widgetCache[cacheKey] = stickyNoteWidget;
    _cacheTimestamps[cacheKey] = DateTime.now();
    
    // Clean expired cache periodically
    _cleanExpiredCache();
    
    return stickyNoteWidget;
  }
  
  /// Generate unique cache key untuk journal entry
  String _generateCacheKey(JournalEntry journal, int index) {
    return '${journal.id}_${journal.date.millisecondsSinceEpoch}_$index';
  }
  
  /// Check apakah cache masih valid
  bool _isValidCache(String cacheKey) {
    if (!_widgetCache.containsKey(cacheKey)) return false;
    
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }
  
  /// Clean expired cache entries
  void _cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = _cacheTimestamps.entries
        .where((entry) => now.difference(entry.value) >= _cacheExpiry)
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      _widgetCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  Widget _buildTimelineNode(JournalEntry journal, int index) {
    final moodColor = EnhancedJournalColors.getMoodColor(journal.mood);
    final isSpecial = _isSpecialEntry(journal, index);
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: isSpecial ? 16 : 12,
            height: isSpecial ? 16 : 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: moodColor,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: moodColor.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: isSpecial ? 2 : 0,
                ),
              ],
            ),
            child: isSpecial
                ? const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 8,
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildDateBadge(JournalEntry journal) {
    final dateText = _formatDateBadge(journal.date);
    
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              EnhancedJournalColors.accentPrimary.withValues(alpha: 0.1),
              EnhancedJournalColors.accentPrimary.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: EnhancedJournalColors.accentPrimary.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          dateText,
          style: EnhancedJournalTypography.labelSmallStyle(context).copyWith(
            color: EnhancedJournalColors.accentPrimary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated sticky note illustration
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Transform.rotate(
                  angle: (value - 0.5) * 0.1,
                  child: Container(
                    width: 120,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF9C4), Color(0xFFFFD54F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.edit_note,
                        size: 40,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Timeline Kosong',
            style: EnhancedJournalTypography.journalTitle(context).copyWith(
              color: EnhancedJournalColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Timeline sticky note Anda akan muncul di sini',
            textAlign: TextAlign.center,
            style: EnhancedJournalTypography.bodyMediumStyle(context).copyWith(
              color: EnhancedJournalColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  StickyNoteStyle _getStickyNoteStyle(JournalEntry journal, int index) {
    final mood = journal.mood.toLowerCase();
    final hour = journal.date.hour;
    
    // Style based on mood and time
    if (mood.contains('senang') || mood.contains('bahagia')) {
      return StickyNoteStyle.classic; // Bright yellow classic
    } else if (mood.contains('sedih') || mood.contains('kecewa')) {
      return StickyNoteStyle.textured; // Paper texture for depth
    } else if (mood.contains('marah') || mood.contains('frustrasi')) {
      return StickyNoteStyle.torn; // Torn edges for intensity
    } else if (hour < 12) {
      return StickyNoteStyle.modern; // Clean morning vibe
    } else {
      return StickyNoteStyle.polaroid; // Evening photo memories
    }
  }

  bool _isSpecialEntry(JournalEntry journal, int index) {
    // Mark entry as special if it's a streak milestone or high emotion
    final content = journal.content.toLowerCase();
    return content.length > 200 || 
           content.contains('milestone') ||
           content.contains('special') ||
           journal.mood.contains('sangat');
  }

  bool _isDifferentDay(JournalEntry current, JournalEntry previous) {
    return current.date.day != previous.date.day ||
           current.date.month != previous.date.month ||
           current.date.year != previous.date.year;
  }

  String _formatDateBadge(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(date.year, date.month, date.day);
    
    if (entryDate == today) {
      return 'HARI INI';
    } else if (entryDate == today.subtract(const Duration(days: 1))) {
      return 'KEMARIN';
    } else if (now.difference(entryDate).inDays < 7) {
      return _getDayName(date.weekday);
    } else {
      return '${date.day} ${_getMonthName(date.month)}';
    }
  }

  String _getDayName(int weekday) {
    const days = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN',
      'JUL', 'AGS', 'SEP', 'OKT', 'NOV', 'DES'
    ];
    return months[month - 1];
  }
  
  /// Calculate estimated height for sticky note card based on size and content
  double _getEstimatedCardHeight(StickyNoteSize noteSize, JournalEntry journal) {
    // Base heights for different note sizes
    const double baseHeightSmall = 120.0;
    const double baseHeightMedium = 180.0;
    const double baseHeightLarge = 240.0;
    
    double baseHeight;
    switch (noteSize) {
      case StickyNoteSize.small:
        baseHeight = baseHeightSmall;
        break;
      case StickyNoteSize.medium:
        baseHeight = baseHeightMedium;
        break;
      case StickyNoteSize.large:
        baseHeight = baseHeightLarge;
        break;
      case StickyNoteSize.wide:
        baseHeight = baseHeightMedium; // Wide notes use medium height
        break;
    }
    
    // Add extra height based on content length
    final contentLength = journal.content.length;
    double extraHeight = 0.0;
    
    if (contentLength > 100) {
      extraHeight += 20.0; // Extra height for long content
    }
    if (contentLength > 200) {
      extraHeight += 20.0; // More extra height for very long content
    }
    
    // Add padding for visual elements (date, mood indicator, etc.)
    const double paddingHeight = 40.0;
    
    return baseHeight + extraHeight + paddingHeight;
  }
}
