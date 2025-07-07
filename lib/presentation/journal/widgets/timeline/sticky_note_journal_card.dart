import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dear_flutter/domain/entities/journal_entry.dart';
import 'package:dear_flutter/presentation/journal/theme/enhanced_journal_theme.dart';
import 'package:dear_flutter/presentation/journal/animations/journal_micro_interactions.dart';
import 'package:intl/intl.dart';
import 'dart:math';

/// Modern sticky note journal card dengan paper effects dan mood stamps
class StickyNoteJournalCard extends StatefulWidget {
  final JournalEntry journal;
  final StickyNoteStyle style;
  final StickyNoteSize noteSize;
  final bool showThread;
  final bool isConnected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const StickyNoteJournalCard({
    super.key,
    required this.journal,
    this.style = StickyNoteStyle.modern,
    this.noteSize = StickyNoteSize.medium,
    this.showThread = true,
    this.isConnected = true,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<StickyNoteJournalCard> createState() => _StickyNoteJournalCardState();
}

class _StickyNoteJournalCardState extends State<StickyNoteJournalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _rotationAnimation;
  
  bool _isPressed = false;
  double _baseRotation = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Random rotation untuk natural look
    _baseRotation = (Random().nextDouble() - 0.5) * 6; // ±3 degrees
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: _baseRotation,
      end: _baseRotation * 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
    JournalMicroInteractions.lightTap();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  Size get _cardSize {
    switch (widget.noteSize) {
      case StickyNoteSize.small:
        return const Size(160, 140);  // Increased from 120x100
      case StickyNoteSize.medium:
        return const Size(240, 180);  // Increased from 180x140  
      case StickyNoteSize.large:
        return const Size(280, 220);  // Increased from 220x180
      case StickyNoteSize.wide:
        return const Size(320, 160);  // Increased from 240x120
    }
  }

  LinearGradient get _noteGradient {
    return StickyNoteColors.getTimeBasedGradient(
      widget.journal.date,
      widget.journal.mood,
    );
  }

  String get _previewText {
    final content = widget.journal.content;
    final maxLength = widget.noteSize == StickyNoteSize.small 
        ? 100  // Increased from 60
        : widget.noteSize == StickyNoteSize.wide 
            ? 140  // Increased from 80
            : 180; // Increased from 120
    
    return content.length > maxLength 
        ? '${content.substring(0, maxLength)}...' 
        : content;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * pi / 180,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: widget.onTap,
              child: Container(
                width: _cardSize.width,
                height: _cardSize.height,
                decoration: BoxDecoration(
                  gradient: _noteGradient,
                  borderRadius: _getCornerRadius(),
                  boxShadow: _buildShadows(),
                  border: _buildBorder(),
                ),
                child: Stack(
                  children: [
                    // Paper texture overlay
                    if (widget.style == StickyNoteStyle.textured)
                      _buildPaperTexture(),
                    
                    // Main content
                    Padding(
                      padding: EdgeInsets.all(EnhancedJournalSpacing.md(context)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Time badge
                          _buildTimeBadge(),
                          
                          SizedBox(height: EnhancedJournalSpacing.sm(context)),
                          
                          // Content
                          Expanded(
                            child: Text(
                              _previewText,
                              style: _getContentTextStyle(),
                              maxLines: _getMaxLines(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          // Bottom row dengan mood stamp
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Word count atau metadata
                              if (widget.noteSize != StickyNoteSize.small)
                                Text(
                                  '${widget.journal.content.split(' ').length} words',
                                  style: EnhancedJournalTypography.labelSmallStyle(context).copyWith(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    fontSize: 10,
                                  ),
                                ),
                              
                              // Mood stamp
                              _buildMoodStamp(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Corner fold effect
                    if (widget.style == StickyNoteStyle.classic)
                      _buildCornerFold(),
                    
                    // Actions menu
                    Positioned(
                      top: 4,
                      right: 4,
                      child: _buildActionsMenu(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BorderRadius _getCornerRadius() {
    switch (widget.style) {
      case StickyNoteStyle.classic:
        return BorderRadius.circular(8);
      case StickyNoteStyle.modern:
        return BorderRadius.circular(16.0);
      case StickyNoteStyle.textured:
        return BorderRadius.circular(6);
      case StickyNoteStyle.polaroid:
        return BorderRadius.circular(4);
      case StickyNoteStyle.torn:
        return BorderRadius.only(
          topLeft: Radius.circular(Random().nextInt(8) + 4.0),
          topRight: Radius.circular(Random().nextInt(8) + 4.0),
          bottomLeft: Radius.circular(Random().nextInt(8) + 4.0),
          bottomRight: Radius.circular(Random().nextInt(8) + 4.0),
        );
    }
  }

  List<BoxShadow> _buildShadows() {
    final baseElevation = _isPressed ? 2.0 : 6.0;
    final animatedElevation = baseElevation + _elevationAnimation.value;
    
    return [
      // Main shadow
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: animatedElevation * 2,
        offset: Offset(0, animatedElevation),
        spreadRadius: 0,
      ),
      // Secondary shadow untuk depth
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: animatedElevation,
        offset: Offset(animatedElevation * 0.5, animatedElevation * 0.5),
        spreadRadius: 0,
      ),
    ];
  }

  Border? _buildBorder() {
    switch (widget.style) {
      case StickyNoteStyle.polaroid:
        return Border.all(
          color: Colors.white,
          width: 8,
        );
      case StickyNoteStyle.torn:
        return Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1,
        );
      default:
        return null;
    }
  }

  Widget _buildPaperTexture() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: _getCornerRadius(),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.02),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeBadge() {
    final isToday = _isToday(widget.journal.date);
    final timeText = _formatTime();
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        timeText,        style: EnhancedJournalTypography.labelSmallStyle(context).copyWith(
          color: isToday
              ? EnhancedJournalColors.accentPrimary
              : Colors.black.withValues(alpha: 0.6),
          fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
          fontSize: widget.noteSize == StickyNoteSize.small ? 9 : 10,
        ),
      ),
    );
  }

  Widget _buildMoodStamp() {
    final moodColor = EnhancedJournalColors.getMoodColor(widget.journal.mood);
    final stampSize = widget.noteSize == StickyNoteSize.small ? 20.0 : 24.0;
    
    return Transform.rotate(
      angle: (Random().nextDouble() - 0.5) * 0.5, // Slight rotation
      child: Container(
        width: stampSize,
        height: stampSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: moodColor.withValues(alpha: 0.2),
          border: Border.all(
            color: moodColor.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            widget.journal.mood.split(' ').last, // Emoji part
            style: TextStyle(
              fontSize: widget.noteSize == StickyNoteSize.small ? 10 : 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCornerFold() {
    return Positioned(
      top: 0,
      right: 0,
      child: CustomPaint(
        size: const Size(20, 20),
        painter: CornerFoldPainter(
          foldColor: Colors.black.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  Widget _buildActionsMenu() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz,
        color: Colors.black.withValues(alpha: 0.4),
        size: 16,
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            widget.onEdit?.call();
            break;
          case 'delete':
            widget.onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 16, color: Colors.black54),
              const SizedBox(width: 8),
              const Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 16, color: Colors.red),
              const SizedBox(width: 8),
              const Text('Hapus'),
            ],
          ),
        ),
      ],
    );
  }

  TextStyle _getContentTextStyle() {
    final baseFontSize = widget.noteSize == StickyNoteSize.small 
        ? 13.0   // Increased from 11.0
        : widget.noteSize == StickyNoteSize.large 
            ? 16.0   // Increased from 14.0
            : 14.0;  // Increased from 12.0
    
    return TextStyle(
      fontSize: baseFontSize,
      color: Colors.black.withValues(alpha: 0.85), // Increased opacity for better readability
      height: 1.5, // Increased line height for better readability
      fontWeight: FontWeight.w400,
      fontFamily: 'inter', // Use a more readable font if available
    );
  }

  int _getMaxLines() {
    switch (widget.noteSize) {
      case StickyNoteSize.small:
        return 4;  // Increased from 3
      case StickyNoteSize.medium:
        return 6;  // Increased from 5  
      case StickyNoteSize.large:
        return 8;  // Increased from 7
      case StickyNoteSize.wide:
        return 4;  // Increased from 3
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(date.year, date.month, date.day);
    return entryDate == today;
  }

  String _formatTime() {
    final now = DateTime.now();
    final diff = now.difference(widget.journal.date);
    
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('dd/MM').format(widget.journal.date);
    }
  }
}

/// Enums untuk sticky note variations
enum StickyNoteStyle {
  classic,     // Traditional yellow note
  modern,      // Flat design dengan gradient
  textured,    // Paper texture effect
  polaroid,    // Photo-like dengan border
  torn,        // Irregular edges effect
}

enum StickyNoteSize {
  small,       // 120x100 - Quick notes
  medium,      // 180x140 - Normal entries  
  large,       // 220x180 - Long content
  wide,        // 240x120 - Quote-style
}

/// Color system untuk sticky notes
class StickyNoteColors {
  static const Map<String, List<Color>> moodGradients = {
    'senang': [Color(0xFFFFF9C4), Color(0xFFFFD54F), Color(0xFFFFB74D)],
    'sedih': [Color(0xFFE3F2FD), Color(0xFF64B5F6), Color(0xFF42A5F5)],
    'marah': [Color(0xFFFFEBEE), Color(0xFFEF5350), Color(0xFFE53935)],
    'cemas': [Color(0xFFF3E5F5), Color(0xFFCE93D8), Color(0xFFBA68C8)],
    'netral': [Color(0xFFF5F5F5), Color(0xFFE0E0E0), Color(0xFFBDBDBD)],
    'bersyukur': [Color(0xFFE8F5E8), Color(0xFF81C784), Color(0xFF66BB6A)],
    'bangga': [Color(0xFFFFF3E0), Color(0xFFFFB74D), Color(0xFFFF9800)],
    'takut': [Color(0xFFE1F5FE), Color(0xFF4FC3F7), Color(0xFF29B6F6)],
    'kecewa': [Color(0xFFFFF8E1), Color(0xFFFFB74D), Color(0xFFFFA726)],
  };
  
  static LinearGradient getTimeBasedGradient(DateTime dateTime, String mood) {
    final hour = dateTime.hour;
    final baseColors = moodGradients[_getMoodKey(mood)] ?? moodGradients['netral']!;
    
    if (hour >= 6 && hour < 12) {      // Morning - lighter
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [baseColors[0], baseColors[1]],
      );
    } else if (hour >= 12 && hour < 18) { // Afternoon - normal
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [baseColors[1], baseColors[2]],
      );
    } else {                           // Evening/Night - warmer
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [baseColors[0], baseColors[2]],
      );
    }
  }
  
  static String _getMoodKey(String mood) {
    final key = mood.toLowerCase();
    for (final moodKey in moodGradients.keys) {
      if (key.contains(moodKey)) return moodKey;
    }
    return 'netral';
  }
}

/// Custom painter untuk corner fold effect
class CornerFoldPainter extends CustomPainter {
  final Color foldColor;
  
  CornerFoldPainter({required this.foldColor});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = foldColor
      ..style = PaintingStyle.fill;
    
    final path = Path()
      ..moveTo(size.width - 15, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, 15)
      ..lineTo(size.width - 7.5, 7.5)
      ..close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
