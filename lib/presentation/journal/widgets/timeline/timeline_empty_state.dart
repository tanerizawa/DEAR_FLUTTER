import 'package:flutter/material.dart';
import 'package:dear_flutter/presentation/journal/theme/journal_theme.dart';

/// Empty state khusus untuk timeline sticky notes
class TimelineEmptyState extends StatefulWidget {
  final VoidCallback? onCreateFirst;

  const TimelineEmptyState({
    super.key,
    this.onCreateFirst,
  });

  @override
  State<TimelineEmptyState> createState() => _TimelineEmptyStateState();
}

class _TimelineEmptyStateState extends State<TimelineEmptyState>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _floatAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Floating sticky note illustration
                Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: _buildFloatingStickyNote(),
                ),
                
                const SizedBox(height: 40),
                
                // Title
                Text(
                  'Timeline Kosong',
                  style: JournalTypography.heading1.copyWith(
                    color: JournalTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Subtitle
                Text(
                  'Mulai perjalanan jurnal Anda dengan\nsticky note pertama yang indah',
                  textAlign: TextAlign.center,
                  style: JournalTypography.body1.copyWith(
                    color: JournalTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Tips
                _buildTips(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingStickyNote() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Shadow
        Transform.translate(
          offset: const Offset(4, 6),
          child: Container(
            width: 120,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        
        // Main sticky note
        Container(
          width: 120,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF9C4), Color(0xFFFFD54F), Color(0xFFFFB74D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
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
                  size: const Size(16, 16),
                  painter: _CornerFoldPainter(),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'HARI INI',
                        style: JournalTypography.caption.copyWith(
                          color: Colors.black.withOpacity(0.6),
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Sample text
                    Text(
                      'Tulis perasaan dan\npikiran Anda...',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black.withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Mood stamp
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: JournalTheme.accentPrimary.withOpacity(0.2),
                          border: Border.all(
                            color: JournalTheme.accentPrimary.withOpacity(0.6),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '😊',
                            style: TextStyle(fontSize: 8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTips() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: JournalTheme.cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: JournalTheme.accentPrimary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: JournalTheme.accentPrimary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Tips untuk Memulai',
                style: JournalTypography.body2.copyWith(
                  color: JournalTheme.accentPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '• Tulis apa yang Anda rasakan hari ini\n'
            '• Ceritakan kejadian yang berkesan\n'
            '• Ekspresikan harapan dan impian Anda',
            style: JournalTypography.caption.copyWith(
              color: JournalTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerFoldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width - size.width * 0.6, 0)
      ..lineTo(size.width, size.height * 0.6)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
