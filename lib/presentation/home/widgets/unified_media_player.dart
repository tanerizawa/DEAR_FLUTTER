// lib/presentation/home/widgets/unified_media_player.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audio_service/audio_service.dart';

class UnifiedMediaPlayer extends StatefulWidget {
  final MediaItem? currentMedia;
  final PlaybackState? playbackState;
  final bool isRadioMode;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onStop;
  final Function(Duration)? onSeek;

  const UnifiedMediaPlayer({
    super.key,
    this.currentMedia,
    this.playbackState,
    this.isRadioMode = false,
    this.onPlayPause,
    this.onNext,
    this.onPrevious,
    this.onStop,
    this.onSeek,
  });

  @override
  State<UnifiedMediaPlayer> createState() => _UnifiedMediaPlayerState();
}

class _UnifiedMediaPlayerState extends State<UnifiedMediaPlayer>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _pulseController;
  late Animation<double> _gradientAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _gradientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // Get mood-based colors from media metadata or content analysis
  Map<String, dynamic> _getMoodTheme() {
    if (widget.currentMedia == null) {
      return _getDefaultTheme();
    }

    // Extract mood from title, artist, or genre
    final title = widget.currentMedia!.title.toLowerCase();
    final artist = widget.currentMedia!.artist?.toLowerCase() ?? '';
    final genre = widget.currentMedia!.genre?.toLowerCase() ?? '';
    final extras = widget.currentMedia!.extras;
    
    // Check for mood in extras first
    if (extras != null && extras['mood'] != null) {
      return _getThemeFromMood(extras['mood']);
    }

    // Analyze content for mood keywords
    final content = '$title $artist $genre';
    
    if (_containsKeywords(content, ['happy', 'upbeat', 'dance', 'pop', 'energetic', 'party'])) {
      return _getHappyTheme();
    } else if (_containsKeywords(content, ['sad', 'melancholy', 'blues', 'slow', 'ballad', 'emotional'])) {
      return _getSadTheme();
    } else if (_containsKeywords(content, ['rock', 'metal', 'punk', 'aggressive', 'intense', 'hard'])) {
      return _getIntenseTheme();
    } else if (_containsKeywords(content, ['chill', 'ambient', 'relax', 'calm', 'meditation', 'peaceful'])) {
      return _getCalmTheme();
    } else if (_containsKeywords(content, ['jazz', 'smooth', 'lounge', 'sophisticated', 'classic'])) {
      return _getSophisticatedTheme();
    } else if (widget.isRadioMode) {
      return _getRadioTheme();
    }

    return _getDefaultTheme();
  }

  bool _containsKeywords(String content, List<String> keywords) {
    return keywords.any((keyword) => content.contains(keyword));
  }

  Map<String, dynamic> _getThemeFromMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'upbeat':
      case 'energetic':
        return _getHappyTheme();
      case 'sad':
      case 'melancholy':
        return _getSadTheme();
      case 'intense':
      case 'aggressive':
        return _getIntenseTheme();
      case 'calm':
      case 'peaceful':
        return _getCalmTheme();
      case 'sophisticated':
      case 'classy':
        return _getSophisticatedTheme();
      default:
        return _getDefaultTheme();
    }
  }

  Map<String, dynamic> _getHappyTheme() {
    return {
      'primaryGradient': [
        const Color(0xFFFFD700),
        const Color(0xFFFF8C00),
        const Color(0xFFFF6B6B),
      ],
      'secondaryGradient': [
        const Color(0xFFFF8C00),
        const Color(0xFFFFD700),
        const Color(0xFFFFA500),
      ],
      'accentColor': const Color(0xFFFFD700),
      'buttonColor': const Color(0xFFFF8C00),
      'textColor': Colors.white,
      'iconColor': Colors.white,
      'progressColor': const Color(0xFFFFD700),
      'mood': 'Happy',
      'icon': Icons.wb_sunny,
    };
  }

  Map<String, dynamic> _getSadTheme() {
    return {
      'primaryGradient': [
        const Color(0xFF1e3c72),
        const Color(0xFF2a5298),
        const Color(0xFF4682B4),
      ],
      'secondaryGradient': [
        const Color(0xFF2a5298),
        const Color(0xFF1e3c72),
        const Color(0xFF1E90FF),
      ],
      'accentColor': const Color(0xFF4682B4),
      'buttonColor': const Color(0xFF2a5298),
      'textColor': Colors.white,
      'iconColor': Colors.white70,
      'progressColor': const Color(0xFF4682B4),
      'mood': 'Melancholy',
      'icon': Icons.cloud,
    };
  }

  Map<String, dynamic> _getIntenseTheme() {
    return {
      'primaryGradient': [
        const Color(0xFFDC143C),
        const Color(0xFFB22222),
        const Color(0xFF8B0000),
      ],
      'secondaryGradient': [
        const Color(0xFFB22222),
        const Color(0xFFDC143C),
        const Color(0xFFFF4500),
      ],
      'accentColor': const Color(0xFFDC143C),
      'buttonColor': const Color(0xFFB22222),
      'textColor': Colors.white,
      'iconColor': Colors.white,
      'progressColor': const Color(0xFFDC143C),
      'mood': 'Intense',
      'icon': Icons.whatshot,
    };
  }

  Map<String, dynamic> _getCalmTheme() {
    return {
      'primaryGradient': [
        const Color(0xFF20B2AA),
        const Color(0xFF48D1CC),
        const Color(0xFF40E0D0),
      ],
      'secondaryGradient': [
        const Color(0xFF48D1CC),
        const Color(0xFF20B2AA),
        const Color(0xFF00CED1),
      ],
      'accentColor': const Color(0xFF20B2AA),
      'buttonColor': const Color(0xFF48D1CC),
      'textColor': Colors.white,
      'iconColor': Colors.white70,
      'progressColor': const Color(0xFF20B2AA),
      'mood': 'Calm',
      'icon': Icons.spa,
    };
  }

  Map<String, dynamic> _getSophisticatedTheme() {
    return {
      'primaryGradient': [
        const Color(0xFF9370DB),
        const Color(0xFF8A2BE2),
        const Color(0xFF6A5ACD),
      ],
      'secondaryGradient': [
        const Color(0xFF8A2BE2),
        const Color(0xFF9370DB),
        const Color(0xFFBA55D3),
      ],
      'accentColor': const Color(0xFF9370DB),
      'buttonColor': const Color(0xFF8A2BE2),
      'textColor': Colors.white,
      'iconColor': Colors.white,
      'progressColor': const Color(0xFF9370DB),
      'mood': 'Sophisticated',
      'icon': Icons.piano,
    };
  }

  Map<String, dynamic> _getRadioTheme() {
    // Check if radio station has a custom color
    if (widget.currentMedia?.extras != null && widget.currentMedia!.extras!['stationColor'] != null) {
      final stationColorHex = widget.currentMedia!.extras!['stationColor'] as String;
      final stationColor = _parseHexColor(stationColorHex);
      
      return {
        'primaryGradient': [
          Color(stationColor),
          Color(stationColor).withOpacity(0.8),
          Color(stationColor).withOpacity(0.6),
        ],
        'secondaryGradient': [
          Color(stationColor).withOpacity(0.8),
          Color(stationColor),
          Color(stationColor).withOpacity(0.9),
        ],
        'accentColor': Color(stationColor),
        'buttonColor': Color(stationColor),
        'textColor': Colors.white,
        'iconColor': Colors.white,
        'progressColor': Color(stationColor),
        'mood': 'Live Radio',
        'icon': Icons.radio,
      };
    }
    
    // Default radio theme
    return {
      'primaryGradient': [
        const Color(0xFF1DB954),
        const Color(0xFF1ed760),
        const Color(0xFF1aa34a),
      ],
      'secondaryGradient': [
        const Color(0xFF1ed760),
        const Color(0xFF1DB954),
        const Color(0xFF17a2b8),
      ],
      'accentColor': const Color(0xFF1DB954),
      'buttonColor': const Color(0xFF1ed760),
      'textColor': Colors.white,
      'iconColor': Colors.white,
      'progressColor': const Color(0xFF1DB954),
      'mood': 'Live Radio',
      'icon': Icons.radio,
    };
  }

  Map<String, dynamic> _getDefaultTheme() {
    return {
      'primaryGradient': [
        const Color(0xFF667eea),
        const Color(0xFF764ba2),
        const Color(0xFF6B73FF),
      ],
      'secondaryGradient': [
        const Color(0xFF764ba2),
        const Color(0xFF667eea),
        const Color(0xFF9472FC),
      ],
      'accentColor': const Color(0xFF667eea),
      'buttonColor': const Color(0xFF764ba2),
      'textColor': Colors.white,
      'iconColor': Colors.white,
      'progressColor': const Color(0xFF667eea),
      'mood': 'Default',
      'icon': Icons.music_note,
    };
  }

  bool get _isPlaying => widget.playbackState?.playing ?? false;
  bool get _isLoading => widget.playbackState?.processingState == AudioProcessingState.buffering ||
      widget.playbackState?.processingState == AudioProcessingState.loading;

  @override
  Widget build(BuildContext context) {
    if (widget.currentMedia == null) {
      return const SizedBox.shrink();
    }

    final theme = _getMoodTheme();
    final primaryGradient = theme['primaryGradient'] as List<Color>;
    final secondaryGradient = theme['secondaryGradient'] as List<Color>;
    final accentColor = theme['accentColor'] as Color;
    final buttonColor = theme['buttonColor'] as Color;
    final textColor = theme['textColor'] as Color;
    final iconColor = theme['iconColor'] as Color;
    final progressColor = theme['progressColor'] as Color;
    final mood = theme['mood'] as String;
    final moodIcon = theme['icon'] as IconData;

    return Container(
      margin: const EdgeInsets.all(16),
      height: 140, // Match radio station list height
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24), // Reduced from 28
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: AnimatedBuilder(
          animation: _gradientAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ...primaryGradient,
                    ...secondaryGradient,
                  ],
                  stops: [
                    0.0,
                    0.3,
                    0.5,
                    0.7,
                    0.85,
                    1.0,
                  ],
                  begin: Alignment(-1.0 + 2.0 * _gradientAnimation.value, -1.0),
                  end: Alignment(1.0 + 2.0 * _gradientAnimation.value, 1.0),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12), // Reduced from 16
                  child: Row( // Changed from Column to Row for horizontal layout
                    children: [
                      // Left side: Media info
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCompactHeader(mood, moodIcon, accentColor),
                            const SizedBox(height: 4),
                            _buildCompactMediaInfo(textColor),
                          ],
                        ),
                      ),
                      
                      // Center: Artwork
                      Container(
                        width: 70,
                        height: 70,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: _buildArtwork(),
                      ),
                      
                      // Right side: Controls
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!widget.isRadioMode) 
                              _buildCompactProgressBar(progressColor)
                            else 
                              const SizedBox(height: 4),
                            _buildCompactControls(buttonColor, iconColor, accentColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  int _parseHexColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }

  // Compact layout methods for 140px height
  Widget _buildCompactHeader(String mood, IconData moodIcon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.isRadioMode ? Icons.radio : moodIcon,
            size: 10,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            widget.isRadioMode ? 'LIVE' : mood.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMediaInfo(Color textColor) {
    final media = widget.currentMedia!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          media.title,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            height: 1.0,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        // Artist/Station
        if (media.artist != null) ...[
          const SizedBox(height: 2),
          Text(
            media.artist!,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.w500,
              height: 1.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildArtwork() {
    final media = widget.currentMedia!;
    
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: widget.isRadioMode && media.extras?['emoji'] != null
          ? Center(
              child: Text(
                media.extras!['emoji'] as String,
                style: const TextStyle(fontSize: 36),
              ),
            )
          : media.artUri != null
              ? ClipOval(
                  child: Image.network(
                    media.artUri.toString(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildCompactDefaultArtwork(),
                  ),
                )
              : _buildCompactDefaultArtwork(),
    );
  }

  Widget _buildCompactDefaultArtwork() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Icon(
            widget.isRadioMode ? Icons.radio : Icons.music_note,
            size: 32,
            color: Colors.white.withOpacity(0.8),
          ),
        );
      },
    );
  }

  Widget _buildCompactProgressBar(Color progressColor) {
    final position = widget.playbackState?.position ?? Duration.zero;
    final duration = widget.currentMedia?.duration ?? Duration.zero;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Container(
      height: 3,
      margin: const EdgeInsets.only(bottom: 8),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 2,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
          activeTrackColor: progressColor,
          inactiveTrackColor: progressColor.withOpacity(0.3),
          thumbColor: progressColor,
        ),
        child: Slider(
          value: progress.clamp(0.0, 1.0),
          onChanged: (value) {
            final newPosition = Duration(
              milliseconds: (value * duration.inMilliseconds).round(),
            );
            widget.onSeek?.call(newPosition);
          },
        ),
      ),
    );
  }

  Widget _buildCompactControls(Color buttonColor, Color iconColor, Color accentColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main play/pause button
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                accentColor,
                accentColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _isLoading ? null : widget.onPlayPause,
              child: Icon(
                _isLoading 
                    ? Icons.hourglass_empty
                    : (_isPlaying ? Icons.pause : Icons.play_arrow),
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        if (!widget.isRadioMode) ...[
          const SizedBox(height: 4),
          // Mini controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMiniButton(Icons.skip_previous, widget.onPrevious, iconColor),
              const SizedBox(width: 8),
              _buildMiniButton(Icons.skip_next, widget.onNext, iconColor),
            ],
          ),
        ] else ...[
          const SizedBox(height: 4),
          _buildMiniButton(Icons.stop, widget.onStop, iconColor),
        ],
      ],
    );
  }

  Widget _buildMiniButton(IconData icon, VoidCallback? onPressed, Color iconColor) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 14,
          color: iconColor.withOpacity(0.8),
        ),
      ),
    );
  }
}
