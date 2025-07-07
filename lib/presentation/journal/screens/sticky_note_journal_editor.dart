import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dear_flutter/domain/entities/journal_entry.dart';
import 'package:dear_flutter/data/repositories/journal_repository.dart';
import 'package:dear_flutter/presentation/journal/widgets/psychology_mood_selector.dart';
import 'package:dear_flutter/presentation/journal/theme/enhanced_journal_theme.dart';
import 'package:dear_flutter/presentation/journal/animations/journal_micro_interactions.dart';

/// Sticky Note Journal Editor - Editor yang menyerupai sticky note asli
class StickyNoteJournalEditor extends StatefulWidget {
  final JournalEntry? initialEntry;
  
  const StickyNoteJournalEditor({
    super.key,
    this.initialEntry,
  });

  @override
  State<StickyNoteJournalEditor> createState() => _StickyNoteJournalEditorState();
}

class _StickyNoteJournalEditorState extends State<StickyNoteJournalEditor>
    with TickerProviderStateMixin {
  late TextEditingController _contentController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  
  String _selectedMood = 'Netral 😐'; // Default neutral mood
  bool _isLoading = false;
  
  // Enhanced sticky note colors berdasarkan mood psychology
  final List<Color> _stickyNoteColors = [
    EnhancedJournalColors.moodJoyful.withOpacity(0.2),     // Warm Joyful
    EnhancedJournalColors.moodPeaceful.withOpacity(0.2),   // Calm Blue
    EnhancedJournalColors.moodGrateful.withOpacity(0.2),   // Growth Green
    EnhancedJournalColors.moodProud.withOpacity(0.2),      // Achievement Purple
    EnhancedJournalColors.moodLoved.withOpacity(0.2),      // Connection Pink
    EnhancedJournalColors.moodContent.withOpacity(0.2),    // Balanced Lavender
  ];
  
  int _selectedColorIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _contentController = TextEditingController(
      text: widget.initialEntry?.content ?? '',
    );
    
    if (widget.initialEntry != null) {
      _selectedMood = widget.initialEntry!.mood;
    }
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _rotateAnimation = Tween<double>(
      begin: -0.02,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      body: Stack(
        children: [
          // Background tap to close
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
          
          // Sticky note editor
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: _buildStickyNoteEditor(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyNoteEditor() {
    final selectedColor = _stickyNoteColors[_selectedColorIndex];
    
    return Container(
      margin: const EdgeInsets.all(24),
      constraints: const BoxConstraints(
        maxWidth: 350,
        maxHeight: 600, // Increased height to prevent overflow
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: selectedColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: selectedColor.withValues(alpha: 0.3),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Corner fold
              Positioned(
                top: 0,
                right: 0,
                child: CustomPaint(
                  size: const Size(24, 24),
                  painter: _CornerFoldPainter(selectedColor),
                ),
              ),
              
              // Main content
              Padding(
                padding: const EdgeInsets.all(16), // Reduced from 20 to 16
                child: SingleChildScrollView( // Added scrollable container
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.6, // Minimum height
                    ),
                    child: IntrinsicHeight( // Ensures Column takes minimum height
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header dengan close button dan color picker
                          _buildHeader(),
                          
                          const SizedBox(height: 12), // Reduced from 16 to 12
                          
                          // Date header
                          _buildDateHeader(),
                          
                          const SizedBox(height: 12), // Reduced from 16 to 12
                          
                          // Content field
                          SizedBox(
                            height: 180, // Fixed height instead of Expanded
                            child: _buildContentField(),
                          ),
                          
                          const SizedBox(height: 12), // Reduced from 16 to 12
                          
                          // Mood selector
                          _buildMoodSelector(),
                          
                          const SizedBox(height: 16), // Reduced from 20 to 16
                          
                          // Action buttons
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Color picker
        Expanded(
          child: SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _stickyNoteColors.length,
              itemBuilder: (context, index) {
                final color = _stickyNoteColors[index];
                final isSelected = index == _selectedColorIndex;
                
                return JournalMicroInteractions.bounceOnTap(
                  onTap: () {
                    setState(() {
                      _selectedColorIndex = index;
                    });
                    JournalMicroInteractions.selectionClick();
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected 
                            ? EnhancedJournalColors.accentPrimary
                            : Colors.black.withValues(alpha: 0.2),
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: EnhancedJournalColors.accentPrimary.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: isSelected ? Icon(
                      Icons.check,
                      color: EnhancedJournalColors.accentPrimary,
                      size: 16,
                    ) : null,
                  ),
                );
              },
            ),
          ),
        ),
        
        // Close button
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close,
              size: 16,
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = widget.initialEntry?.date ?? now;
    final entryDay = DateTime(entryDate.year, entryDate.month, entryDate.day);
    
    String dateText;
    if (entryDay == today) {
      dateText = 'HARI INI';
    } else if (entryDay == yesterday) {
      dateText = 'KEMARIN';
    } else {
      dateText = '${entryDate.day}/${entryDate.month}/${entryDate.year}';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        dateText,
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.6),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildContentField() {
    return Container(
      padding: EdgeInsets.all(EnhancedJournalSpacing.md(context)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: TextField(
        controller: _contentController,
        style: EnhancedJournalTypography.journalContent(context).copyWith(
          color: Colors.black.withValues(alpha: 0.8),
        ),
        decoration: InputDecoration(
          hintText: 'Tulis cerita hari ini...\n\nApa yang terjadi? Bagaimana perasaanmu?\n\nCeritakan semua yang ingin kamu ingat.',
          hintStyle: EnhancedJournalTypography.editorHint(context).copyWith(
            color: Colors.black.withValues(alpha: 0.4),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Container(
      padding: const EdgeInsets.all(10), // Reduced from 12 to 10
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Added to minimize space
        children: [
          Text(
            'Bagaimana perasaanmu?',
            style: EnhancedJournalTypography.journalMood(context).copyWith(
              fontSize: EnhancedJournalTypography.labelLarge(context),
              color: Colors.black.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: EnhancedJournalSpacing.xs(context)),
          SizedBox(
            height: 100, // Fixed height to control mood selector size
            child: PsychologyMoodSelector(
              selectedMood: _selectedMood,
              onMoodChanged: (mood) {
                setState(() {
                  _selectedMood = mood;
                });
                JournalMicroInteractions.selectionClick();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Cancel button
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                'Batal',
                textAlign: TextAlign.center,
                style: EnhancedJournalTypography.buttonText(context).copyWith(
                  color: Colors.black.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Save button
        Expanded(
          flex: 2,
          child: JournalMicroInteractions.bounceOnTap(
            onTap: _isLoading ? () {} : _saveJournal,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: _isLoading 
                    ? null
                    : LinearGradient(
                        colors: [
                          EnhancedJournalColors.getMoodColor(_selectedMood),
                          EnhancedJournalColors.getMoodColor(_selectedMood).withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: _isLoading 
                    ? Colors.black.withValues(alpha: 0.1)
                    : null,
                borderRadius: BorderRadius.circular(6),
                boxShadow: _isLoading ? null : [
                  BoxShadow(
                    color: EnhancedJournalColors.getMoodColor(_selectedMood).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      widget.initialEntry != null ? 'Update' : 'Simpan',
                      textAlign: TextAlign.center,
                      style: EnhancedJournalTypography.buttonText(context),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveJournal() async {
    if (_contentController.text.trim().isEmpty) {
      JournalMicroInteractions.errorPattern();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tulis sesuatu terlebih dahulu'),
          backgroundColor: EnhancedJournalColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    JournalMicroInteractions.mediumTap();

    try {
      final repository = JournalRepository();
      
      if (widget.initialEntry != null) {
        // Update existing entry - create new entry since copyWith doesn't exist
        final updatedEntry = JournalEntry(
          id: widget.initialEntry!.id,
          content: _contentController.text.trim(),
          mood: _selectedMood,
          date: DateTime.now(), // Update timestamp
        );
        
        await repository.update(updatedEntry);
      } else {
        // Create new entry
        final newEntry = JournalEntry(
          content: _contentController.text.trim(),
          mood: _selectedMood,
          date: DateTime.now(),
        );
        
        await repository.add(newEntry);
      }

      if (mounted) {
        JournalMicroInteractions.heavyTap();
        Navigator.of(context).pop('refresh'); // Return refresh signal
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  widget.initialEntry != null 
                      ? 'Jurnal berhasil diperbarui' 
                      : 'Jurnal berhasil disimpan',
                ),
              ],
            ),
            backgroundColor: EnhancedJournalColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        JournalMicroInteractions.errorPattern();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Gagal menyimpan jurnal: $e'),
                ),
              ],
            ),
            backgroundColor: EnhancedJournalColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _CornerFoldPainter extends CustomPainter {
  final Color baseColor;
  
  _CornerFoldPainter(this.baseColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = baseColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width - size.width * 0.7, 0)
      ..lineTo(size.width, size.height * 0.7)
      ..close();

    canvas.drawPath(path, paint);
    
    // Shadow line
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
      
    final shadowPath = Path()
      ..moveTo(size.width - size.width * 0.7, 0)
      ..lineTo(size.width, size.height * 0.7);
      
    canvas.drawPath(shadowPath, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
