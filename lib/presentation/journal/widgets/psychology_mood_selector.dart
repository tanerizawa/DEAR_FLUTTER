import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dear_flutter/presentation/journal/theme/enhanced_journal_theme.dart';

/// Enhanced Mood Selector dengan Psychology-Based Colors
class PsychologyMoodSelector extends StatefulWidget {
  final String selectedMood;
  final Function(String) onMoodChanged;
  final bool isCompact;
  
  const PsychologyMoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodChanged,
    this.isCompact = false,
  });

  @override
  State<PsychologyMoodSelector> createState() => _PsychologyMoodSelectorState();
}

class _PsychologyMoodSelectorState extends State<PsychologyMoodSelector>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Enhanced mood options dengan emoji yang lebih expressive
  final List<MoodOption> _moodOptions = [
    // Positive Emotions
    MoodOption('Gembira 🌟', '🌟', 'Merasa sangat bahagia dan bersemangat!'),
    MoodOption('Senang 😊', '😊', 'Perasaan positif dan ceria'),
    MoodOption('Bersyukur 🙏', '🙏', 'Merasa berterima kasih atas hidup'),
    MoodOption('Bangga 🏆', '🏆', 'Bangga dengan pencapaian hari ini'),
    MoodOption('Damai 🌸', '🌸', 'Merasa tenang dan seimbang'),
    MoodOption('Sayang 💖', '💖', 'Dipenuhi perasaan cinta dan kasih'),
    
    // Neutral Emotions
    MoodOption('Netral 😐', '😐', 'Perasaan biasa-biasa saja'),
    MoodOption('Puas 😌', '😌', 'Merasa cukup dengan hari ini'),
    MoodOption('Berpikir 🤔', '🤔', 'Sedang merenungkan banyak hal'),
    MoodOption('Lelah 😴', '😴', 'Merasa capek tapi masih oke'),
    
    // Challenging Emotions
    MoodOption('Sedih 😢', '😢', 'Merasa down dan butuh support'),
    MoodOption('Cemas 😰', '😰', 'Khawatir tentang sesuatu'),
    MoodOption('Marah 😡', '😡', 'Merasa frustrasi atau kesal'),
    MoodOption('Kecewa 😞', '😞', 'Tidak sesuai harapan hari ini'),
    MoodOption('Kewalahan 🌪️', '🌪️', 'Merasa terlalu banyak yang harus dihadapi'),
  ];
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start subtle pulse for selected mood
    _pulseController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(EnhancedJournalSpacing.md(context)),
      decoration: BoxDecoration(
        gradient: EnhancedJournalColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: EnhancedJournalColors.shadowMedium,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.psychology_outlined,
                color: EnhancedJournalColors.accentPrimary,
                size: 20,
              ),
              SizedBox(width: EnhancedJournalSpacing.xs(context)),
              Text(
                'Bagaimana perasaanmu?',
                style: EnhancedJournalTypography.journalMood(context),
              ),
            ],
          ),
          
          SizedBox(height: EnhancedJournalSpacing.md(context)),
          
          // Selected mood display
          if (!widget.isCompact) ...[
            _buildSelectedMoodDisplay(),
            SizedBox(height: EnhancedJournalSpacing.lg(context)),
          ],
          
          // Mood grid
          _buildMoodGrid(),
        ],
      ),
    );
  }
  
  Widget _buildSelectedMoodDisplay() {
    final selectedOption = _moodOptions.firstWhere(
      (option) => option.label == widget.selectedMood,
      orElse: () => _moodOptions[6], // Default to neutral
    );
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(EnhancedJournalSpacing.lg(context)),
            decoration: BoxDecoration(
              gradient: EnhancedJournalColors.moodGradient(
                EnhancedJournalColors.getMoodColor(widget.selectedMood)
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: EnhancedJournalColors.getMoodColor(widget.selectedMood),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  selectedOption.emoji,
                  style: TextStyle(
                    fontSize: EnhancedJournalTypography.displayMedium(context),
                  ),
                ),
                SizedBox(height: EnhancedJournalSpacing.xs(context)),
                Text(
                  selectedOption.label.split(' ')[0],
                  style: EnhancedJournalTypography.titleLargeStyle(context).copyWith(
                    color: EnhancedJournalColors.getMoodColor(widget.selectedMood),
                    fontWeight: EnhancedJournalTypography.weightBold,
                  ),
                ),
                SizedBox(height: EnhancedJournalSpacing.xs(context)),
                Text(
                  selectedOption.description,
                  style: EnhancedJournalTypography.bodySmallStyle(context).copyWith(
                    color: EnhancedJournalColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildMoodGrid() {
    final itemsPerRow = widget.isCompact ? 6 : 5;
    final rows = (_moodOptions.length / itemsPerRow).ceil();
    
    return Column(
      children: List.generate(rows, (rowIndex) {
        final startIndex = rowIndex * itemsPerRow;
        final endIndex = (startIndex + itemsPerRow).clamp(0, _moodOptions.length);
        final rowItems = _moodOptions.sublist(startIndex, endIndex);
        
        return Padding(
          padding: EdgeInsets.only(
            bottom: rowIndex < rows - 1 ? EnhancedJournalSpacing.sm(context) : 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: rowItems.map((mood) => _buildMoodItem(mood)).toList(),
          ),
        );
      }),
    );
  }
  
  Widget _buildMoodItem(MoodOption mood) {
    final isSelected = mood.label == widget.selectedMood;
    final moodColor = EnhancedJournalColors.getMoodColor(mood.label);
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onMoodChanged(mood.label);
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showMoodDescription(mood);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          margin: EdgeInsets.symmetric(
            horizontal: EnhancedJournalSpacing.xs(context) / 2,
          ),
          padding: EdgeInsets.all(widget.isCompact ? 8 : 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? moodColor.withOpacity(0.2)
                : EnhancedJournalColors.cardBackground,
            borderRadius: BorderRadius.circular(widget.isCompact ? 12 : 16),
            border: Border.all(
              color: isSelected 
                  ? moodColor
                  : EnhancedJournalColors.textTertiary.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: moodColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  mood.emoji,
                  style: TextStyle(
                    fontSize: widget.isCompact ? 20 : 24,
                  ),
                ),
              ),
              if (!widget.isCompact) ...[
                SizedBox(height: EnhancedJournalSpacing.xs(context) / 2),
                Text(
                  mood.label.split(' ')[0],
                  style: EnhancedJournalTypography.labelSmallStyle(context).copyWith(
                    color: isSelected 
                        ? moodColor
                        : EnhancedJournalColors.textSecondary,
                    fontWeight: isSelected 
                        ? EnhancedJournalTypography.weightSemiBold
                        : EnhancedJournalTypography.weightRegular,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  void _showMoodDescription(MoodOption mood) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: EnhancedJournalColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mood.emoji,
              style: TextStyle(
                fontSize: EnhancedJournalTypography.displayLarge(context),
              ),
            ),
            SizedBox(height: EnhancedJournalSpacing.md(context)),
            Text(
              mood.label,
              style: EnhancedJournalTypography.titleLargeStyle(context).copyWith(
                color: EnhancedJournalColors.getMoodColor(mood.label),
              ),
            ),
            SizedBox(height: EnhancedJournalSpacing.sm(context)),
            Text(
              mood.description,
              style: EnhancedJournalTypography.bodyMediumStyle(context).copyWith(
                color: EnhancedJournalColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Tutup',
              style: EnhancedJournalTypography.buttonText(context).copyWith(
                color: EnhancedJournalColors.accentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data class untuk mood options
class MoodOption {
  final String label;
  final String emoji;
  final String description;
  
  const MoodOption(this.label, this.emoji, this.description);
}
