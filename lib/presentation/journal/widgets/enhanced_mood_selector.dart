import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnhancedMoodSelector extends StatefulWidget {
  final String selectedMood;
  final Function(String) onMoodChanged;
  final List<String> moods;

  const EnhancedMoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodChanged,
    this.moods = const [
      'Senang 😊',
      'Sedih 😢',
      'Marah 😡',
      'Cemas 😰',
      'Netral 😐',
      'Bersyukur 🙏',
      'Bangga 😎',
      'Takut 😱',
      'Kecewa 😞',
    ],
  });

  @override
  State<EnhancedMoodSelector> createState() => _EnhancedMoodSelectorState();
}

class _EnhancedMoodSelectorState extends State<EnhancedMoodSelector>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  String? _highlightedMood;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Start the glow animation for selected mood
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Color _getMoodColor(String mood) {
    if (mood.contains('Senang')) return const Color(0xFFFFD600);
    if (mood.contains('Sedih')) return const Color(0xFF64B5F6);
    if (mood.contains('Marah')) return const Color(0xFFE57373);
    if (mood.contains('Cemas')) return const Color(0xFFFFB300);
    if (mood.contains('Netral')) return const Color(0xFFB4B8C5);
    if (mood.contains('Bersyukur')) return const Color(0xFF81C784);
    if (mood.contains('Bangga')) return const Color(0xFFBA68C8);
    if (mood.contains('Takut')) return const Color(0xFF90A4AE);
    if (mood.contains('Kecewa')) return const Color(0xFF8D6E63);
    return const Color(0xFFB4B8C5);
  }

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF2C2F34);
    const textColor = Colors.white;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bagaimana perasaanmu hari ini?',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        // Mood selector grid with enhanced animations
        SizedBox(
          height: 140,
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
            ),
            itemCount: widget.moods.length,
            itemBuilder: (context, index) {
              final mood = widget.moods[index];
              final emoji = mood.split(' ').last;
              final label = mood.split(' ').first;
              final isSelected = widget.selectedMood == mood;
              final isHighlighted = _highlightedMood == mood;
              final moodColor = _getMoodColor(mood);

              return AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      widget.onMoodChanged(mood);
                      _scaleController.forward().then((_) {
                        _scaleController.reverse();
                      });
                    },
                    onTapDown: (_) {
                      setState(() => _highlightedMood = mood);
                    },
                    onTapUp: (_) {
                      setState(() => _highlightedMood = null);
                    },
                    onTapCancel: () {
                      setState(() => _highlightedMood = null);
                    },
                    onLongPress: () {
                      HapticFeedback.heavyImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Mood: $label'),
                          duration: const Duration(milliseconds: 800),
                        ),
                      );
                    },
                    child: AnimatedScale(
                      scale: isHighlighted ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    moodColor.withOpacity(0.8),
                                    moodColor.withOpacity(0.6),
                                  ],
                                )
                              : null,
                          color: isSelected ? null : cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected 
                              ? Border.all(
                                  color: moodColor.withOpacity(_glowAnimation.value), 
                                  width: 2
                                ) 
                              : Border.all(
                                  color: isHighlighted 
                                      ? moodColor.withOpacity(0.5) 
                                      : Colors.transparent,
                                  width: 1,
                                ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: moodColor.withOpacity(0.4 * _glowAnimation.value),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : isHighlighted 
                                  ? [
                                      BoxShadow(
                                        color: moodColor.withOpacity(0.2),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: isSelected ? 32 : 28,
                                height: 1.0,
                              ),
                              child: Text(emoji),
                            ),
                            const SizedBox(height: 6),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                color: isSelected ? Colors.white : textColor.withOpacity(0.8),
                                fontSize: isSelected ? 12 : 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Selected mood indicator with breathing animation
        if (widget.selectedMood.isNotEmpty)
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              final selectedMoodColor = _getMoodColor(widget.selectedMood);
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selectedMoodColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedMoodColor.withOpacity(0.3 + (0.4 * _glowAnimation.value)),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selectedMoodColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.selectedMood.split(' ').last,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mood saat ini',
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            widget.selectedMood.split(' ').first,
                            style: TextStyle(
                              color: selectedMoodColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: selectedMoodColor,
                      size: 20,
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
