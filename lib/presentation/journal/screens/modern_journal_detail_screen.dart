import 'package:dear_flutter/domain/entities/journal_entry.dart';
import 'package:dear_flutter/presentation/journal/theme/journal_theme.dart';
import 'package:dear_flutter/presentation/journal/screens/sticky_note_journal_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modern Journal Detail Screen dengan Golden Ratio & Psychology Design
class ModernJournalDetailScreen extends StatefulWidget {
  final JournalEntry entry;
  
  const ModernJournalDetailScreen({
    super.key,
    required this.entry,
  });

  @override
  State<ModernJournalDetailScreen> createState() => _ModernJournalDetailScreenState();
}

class _ModernJournalDetailScreenState extends State<ModernJournalDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: JournalAnimations.normal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Hari ini, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      return 'Kemarin, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference < 7) {
      return '$difference hari lalu';
    }
    
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getReadingTime(String content) {
    final words = content.trim().split(RegExp(r'\s+'));
    final minutes = (words.length / 200).ceil(); // Average reading speed
    return '$minutes min baca';
  }

  @override
  Widget build(BuildContext context) {
    final moodColor = JournalTheme.getMoodColor(widget.entry.mood);
    
    return Container(
      decoration: const BoxDecoration(
        gradient: JournalTheme.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(moodColor),
        body: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: _buildBody(moodColor),
              ),
            );
          },
        ),
        floatingActionButton: _buildEditButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color moodColor) {
    return AppBar(
      title: Text(
        'Detail Jurnal',
        style: JournalTypography.heading1.copyWith(
          color: JournalTheme.textPrimary,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: JournalTheme.textPrimary,
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            // Share functionality could be added here
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Fitur berbagi akan segera hadir'),
                backgroundColor: moodColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: JournalBorderRadius.circular(FibonacciSpacing.sm),
                ),
              ),
            );
          },
          icon: const Icon(Icons.share_outlined),
          tooltip: 'Bagikan jurnal',
        ),
      ],
    );
  }

  Widget _buildBody(Color moodColor) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(FibonacciSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildMoodHeader(moodColor),
            const SizedBox(height: FibonacciSpacing.lg),
            _buildDateInfo(),
            const SizedBox(height: FibonacciSpacing.xl),
            _buildContentCard(moodColor),
            const SizedBox(height: FibonacciSpacing.lg),
            _buildMetadataCards(),
            const SizedBox(height: FibonacciSpacing.xxl), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildMoodHeader(Color moodColor) {
    final emoji = widget.entry.mood.split(' ').last;
    final label = widget.entry.mood.split(' ').first;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(FibonacciSpacing.lg),
            decoration: BoxDecoration(
              gradient: JournalTheme.moodGradient(widget.entry.mood),
              borderRadius: JournalBorderRadius.circular(FibonacciSpacing.lg),
              border: Border.all(
                color: moodColor.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: const [JournalShadows.cardShadowHover],
            ),
            child: Column(
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 64),
                ),
                const SizedBox(height: FibonacciSpacing.sm),
                Text(
                  label,
                  style: JournalTypography.heading1.copyWith(
                    color: moodColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FibonacciSpacing.md,
        vertical: FibonacciSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: JournalTheme.cardBackground,
        borderRadius: JournalBorderRadius.circular(FibonacciSpacing.lg),
        boxShadow: const [JournalShadows.cardShadow],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time_rounded,
            size: GoldenRatio.iconSize,
            color: JournalTheme.textSecondary,
          ),
          const SizedBox(width: FibonacciSpacing.xs),
          Text(
            _formatDate(widget.entry.date),
            style: JournalTypography.body2.copyWith(
              color: JournalTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(Color moodColor) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: GoldenRatio.cardHeight * 2, // Golden ratio expansion
      ),
      padding: const EdgeInsets.all(FibonacciSpacing.lg),
      decoration: BoxDecoration(
        color: JournalTheme.cardBackground,
        borderRadius: JournalBorderRadius.circular(FibonacciSpacing.md),
        border: Border.all(
          color: moodColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: const [JournalShadows.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(FibonacciSpacing.xs),
                decoration: BoxDecoration(
                  color: moodColor.withOpacity(0.1),
                  borderRadius: JournalBorderRadius.circular(FibonacciSpacing.xs),
                ),
                child: Icon(
                  Icons.article_outlined,
                  size: GoldenRatio.iconSize,
                  color: moodColor,
                ),
              ),
              const SizedBox(width: FibonacciSpacing.sm),
              Text(
                'Isi Jurnal',
                style: JournalTypography.heading2.copyWith(
                  color: moodColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: FibonacciSpacing.md),
          
          // Content text
          Text(
            widget.entry.content,
            style: JournalTypography.body1.copyWith(
              height: 1.6,
              color: JournalTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataCards() {
    final wordCount = widget.entry.content.trim().split(RegExp(r'\s+')).length;
    final readingTime = _getReadingTime(widget.entry.content);
    
    return Row(
      children: [
        Expanded(
          child: _buildMetadataCard(
            icon: Icons.format_list_numbered_rounded,
            title: 'Jumlah Kata',
            value: '$wordCount kata',
            color: JournalTheme.accentPrimary,
          ),
        ),
        const SizedBox(width: FibonacciSpacing.sm),
        Expanded(
          child: _buildMetadataCard(
            icon: Icons.schedule_rounded,
            title: 'Waktu Baca',
            value: readingTime,
            color: JournalTheme.accentSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(FibonacciSpacing.md),
      decoration: BoxDecoration(
        color: JournalTheme.cardBackground,
        borderRadius: JournalBorderRadius.circular(FibonacciSpacing.sm),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: const [JournalShadows.cardShadow],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(FibonacciSpacing.xs),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: JournalBorderRadius.circular(FibonacciSpacing.xs),
            ),
            child: Icon(
              icon,
              size: GoldenRatio.iconSize,
              color: color,
            ),
          ),
          const SizedBox(height: FibonacciSpacing.xs),
          Text(
            title,
            style: JournalTypography.caption.copyWith(
              color: JournalTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: JournalTypography.body2.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return FloatingActionButton.extended(
      onPressed: () async {
        HapticFeedback.mediumImpact();
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StickyNoteJournalEditor(
              initialEntry: widget.entry,
            ),
          ),
        );
        
        if (result == 'refresh' && mounted) {
          Navigator.of(context).pop('refresh');
        }
      },
      backgroundColor: JournalTheme.accentPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      icon: const Icon(Icons.edit_rounded),
      label: Text(
        'Edit',
        style: JournalTypography.body2.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
