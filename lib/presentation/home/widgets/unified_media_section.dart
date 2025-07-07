// lib/presentation/home/widgets/unified_media_section.dart

import 'dart:async';
import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/core/theme/mood_color_system.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/entities/radio_station.dart';
import 'package:dear_flutter/domain/repositories/song_history_repository.dart';
import 'package:dear_flutter/presentation/home/cubit/improved_home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_state.dart';
import 'package:dear_flutter/presentation/home/cubit/enhanced_radio_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/enhanced_radio_state.dart';
import 'package:dear_flutter/services/audio_player_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_service/audio_service.dart';

enum MediaMode { music, radio }

class UnifiedMediaSection extends StatefulWidget {
  const UnifiedMediaSection({super.key});

  @override
  State<UnifiedMediaSection> createState() => _UnifiedMediaSectionState();
}

class _UnifiedMediaSectionState extends State<UnifiedMediaSection> 
    with TickerProviderStateMixin {
  late final AudioPlayerHandler _handler;
  late final StreamSubscription<PlaybackState> _playbackStateSubscription;
  late final AnimationController _pulseController;
  late final AnimationController _coverRotationController;
  late final AnimationController _switchController;
  Timer? _positionTimer;

  MediaMode _currentMode = MediaMode.music;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  AudioTrack? _currentTrack;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _handler = getIt<AudioPlayerHandler>();
    
    // Animation controllers
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _coverRotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _switchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _playbackStateSubscription = _handler.playbackState.listen((state) async {
      if (!mounted) return;
      final currentMediaItem = _handler.mediaItem.value;
      final isPlayingThisTrack = _currentTrack?.id.toString() == currentMediaItem?.id;
      Duration? mediaDuration = currentMediaItem?.duration;
      
      if (mediaDuration == null) {
        try {
          mediaDuration = _handler.currentDuration;
        } catch (_) {
          mediaDuration = Duration.zero;
        }
      }
      
      setState(() {
        _isPlaying = state.playing && isPlayingThisTrack;
        _position = isPlayingThisTrack ? state.updatePosition : Duration.zero;
        _duration = isPlayingThisTrack ? (mediaDuration ?? Duration.zero) : Duration.zero;
      });
      
      // Control animations based on playback state
      if (_isPlaying) {
        _startPositionTimer();
        _coverRotationController.repeat();
      } else {
        _stopPositionTimer();
        _coverRotationController.stop();
      }
      
      // Auto-fetch removed to prevent YouTube rate limiting
    });
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _playbackStateSubscription.cancel();
    _pulseController.dispose();
    _coverRotationController.dispose();
    _switchController.dispose();
    super.dispose();
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted && _isPlaying) {
        setState(() {
          _position = _handler.playbackState.value.updatePosition;
        });
      }
    });
  }

  void _stopPositionTimer() {
    _positionTimer?.cancel();
  }

  void _switchMode(MediaMode newMode) {
    if (_currentMode == newMode) return;
    
    setState(() {
      _currentMode = newMode;
    });
    
    HapticFeedback.selectionClick();
    
    if (newMode == MediaMode.music) {
      _switchController.reverse();
    } else {
      _switchController.forward();
    }
  }

  void _hapticFeedback() {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF232526), 
            const Color(0xFF1DB954).withOpacity(0.15)
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
          if (_isPlaying) BoxShadow(
            color: Color(0xFF1DB954).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: _isPlaying 
              ? Color(0xFF1DB954).withOpacity(0.3)
              : const Color(0x1A1A1A).withOpacity(0.15), 
          width: 1.5
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mode Switcher
            _buildModeSwitcher(),
            
            const SizedBox(height: 20),
            
            // Content based on current mode
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _currentMode == MediaMode.music
                  ? _buildMusicContent()
                  : _buildRadioContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSwitcher() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeButton(
            icon: Icons.music_note_rounded,
            label: 'Musik',
            mode: MediaMode.music,
            isActive: _currentMode == MediaMode.music,
          ),
          _buildModeButton(
            icon: Icons.radio_rounded,
            label: 'Radio',
            mode: MediaMode.radio,
            isActive: _currentMode == MediaMode.radio,
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required MediaMode mode,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => _switchMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isActive 
              ? Color(0xFF1DB954).withOpacity(0.9)
              : Colors.transparent,
          boxShadow: isActive ? [
            BoxShadow(
              color: Color(0xFF1DB954).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                key: ValueKey('${mode.toString()}_$isActive'),
                color: isActive ? Colors.white : Colors.white70,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicContent() {
    return BlocBuilder<ImprovedHomeFeedCubit, HomeFeedState>(
      key: const ValueKey('music_content'),
      buildWhen: (prev, curr) =>
        prev.music != curr.music ||
        prev.status != curr.status ||
        prev.playlist != curr.playlist,
      builder: (context, state) {
        final track = state.music;
        final playlist = track != null ? [track] : <AudioTrack>[]; // Create playlist from single track
        final musicStatus = state.feed?.musicStatus ?? "done";
        final isLoading = state.status == HomeFeedStatus.loading || musicStatus == "generating";

        if (track == null) {
          return _buildEmptyMusicState(isLoading, musicStatus);
        }

        // Set current track if not already set
        if (_currentTrack?.id != track.id) {
          _currentTrack = track;
          _currentIndex = 0;
        }

        final bool isActivePlayer = _currentTrack?.id == track.id;
        final bool isPlaying = isActivePlayer && _isPlaying;
        final Duration position = isActivePlayer ? _position : Duration.zero;
        final Duration duration = isActivePlayer ? _duration : Duration.zero;

        return _buildMusicPlayer(track, playlist, isPlaying, position, duration, isLoading);
      },
    );
  }

  Widget _buildRadioContent() {
    return BlocProvider(
      key: const ValueKey('radio_content'),
      create: (_) => getIt<EnhancedRadioCubit>(),
      child: BlocBuilder<EnhancedRadioCubit, EnhancedRadioState>(
        builder: (context, state) {
          if (state.currentStation == null) {
            return _buildRadioStationSelector(context, state);
          } else {
            return _buildRadioPlayer(context, state);
          }
        },
      ),
    );
  }

  Widget _buildEmptyMusicState(bool isLoading, String musicStatus) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1DB954).withOpacity(0.2),
                  ),
                  child: CircularProgressIndicator(
                    color: Color(0xFF1DB954),
                    strokeWidth: 3,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            musicStatus == "generating" 
                ? 'Menyiapkan musik berdasarkan jurnal Anda...'
                : 'Memuat musik...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ] else ...[
          Icon(Icons.music_off_rounded, 
            size: 64, 
            color: Colors.white.withOpacity(0.3)
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada musik hari ini',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tulis jurnal untuk mendapatkan rekomendasi musik',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildMusicPlayer(AudioTrack track, List<AudioTrack> playlist, 
      bool isPlaying, Duration position, Duration duration, bool isLoading) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Enhanced playlist selector
        if (playlist.isNotEmpty) _buildPlaylistSelector(playlist),
        
        // Enhanced cover art with rotation animation
        _buildEnhancedCoverArt(track, isPlaying),
        
        const SizedBox(height: 16),
        
        // Enhanced track info
        _buildTrackInfo(track),
        
        const SizedBox(height: 20),
        
        // Enhanced controls
        _buildEnhancedControls(track, playlist, isPlaying, isLoading),
        
        // Enhanced progress bar
        if (isPlaying || position.inSeconds > 0) 
          _buildEnhancedProgressBar(position, duration, isLoading),
      ],
    );
  }

  Widget _buildRadioStationSelector(BuildContext context, EnhancedRadioState state) {
    return Column(
      children: [
        Text(
          'Pilih Stasiun Radio',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 130, // Increased height to accommodate the fixed card height
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.availableStations.take(5).length,
            itemBuilder: (context, index) {
              final station = state.availableStations[index];
              return _buildRadioStationCard(context, station);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRadioStationCard(BuildContext context, RadioStation station) {
    return Container(
      width: 100,
      height: 110, // Fixed height to prevent overflow
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          _hapticFeedback();
          context.read<EnhancedRadioCubit>().playRadioStation(station);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Color(_parseHexColor(station.color ?? '#1DB954')).withOpacity(0.1),
                Color(_parseHexColor(station.color ?? '#1DB954')).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Color(_parseHexColor(station.color ?? '#1DB954')).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(_parseHexColor(station.color ?? '#1DB954')).withOpacity(0.2),
                  ),
                  child: Center(
                    child: Text(
                      _getStationEmoji(station.category),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    station.name.replaceAll(RegExp(r'[^\w\s]'), '').trim(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people,
                      size: 9,
                      color: Colors.white60,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${station.listeners}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioPlayer(BuildContext context, EnhancedRadioState state) {
    final station = state.currentStation!;
    final isPlaying = state.status == EnhancedRadioStatus.playing;
    final isLoading = state.status == EnhancedRadioStatus.loading;
    
    return Column(
      children: [
        // Back button and station info
        Row(
          children: [
            IconButton(
              onPressed: () {
                _hapticFeedback();
                context.read<EnhancedRadioCubit>().showStationList();
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white70),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name.replaceAll(RegExp(r'[^\w\s]'), '').trim(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _getRadioStatusText(state.status),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Station icon and live indicator
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(_parseHexColor(station.color ?? '#1DB954')).withOpacity(0.2),
            border: Border.all(
              color: Color(_parseHexColor(station.color ?? '#1DB954')).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              _getStationEmoji(station.category),
              style: const TextStyle(fontSize: 40),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Live indicator and listeners
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: station.isLive ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              station.isLive ? 'LIVE' : 'OFFLINE',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: station.isLive ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.people,
              size: 14,
              color: Colors.white60,
            ),
            const SizedBox(width: 4),
            Text(
              '${station.listeners} pendengar',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white60,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Radio controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Main play/pause button
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(_parseHexColor(station.color ?? '#1DB954')),
                    Color(_parseHexColor(station.color ?? '#1DB954')).withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(_parseHexColor(station.color ?? '#1DB954')).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _hapticFeedback();
                    context.read<EnhancedRadioCubit>().togglePlayPause();
                  },
                  borderRadius: BorderRadius.circular(32),
                  child: Container(
                    width: 64,
                    height: 64,
                    child: Center(
                      child: isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 20),
            
            // Volume/Settings button
            IconButton(
              onPressed: () => _showVolumeControl(context),
              icon: Icon(
                Icons.volume_up,
                color: Colors.white70,
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper methods for music player components
  Widget _buildPlaylistSelector(List<AudioTrack> playlist) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: playlist.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final t = playlist[i];
          final isActive = i == _currentIndex;
          return GestureDetector(
            onTap: () => _playTrackAtIndex(playlist, i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isActive 
                    ? Color(0xFF1DB954).withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: isActive 
                    ? Border.all(color: Color(0xFF1DB954), width: 1.5)
                    : Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive ? Icons.play_circle_filled : Icons.music_note_rounded,
                    color: isActive ? Color(0xFF1DB954) : Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 120),
                    child: Text(
                      t.title,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.white70,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedCoverArt(AudioTrack track, bool isPlaying) {
    return AnimatedBuilder(
      animation: _coverRotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: isPlaying ? _coverRotationController.value * 2 * 3.14159 : 0,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                if (isPlaying) BoxShadow(
                  color: Color(0xFF1DB954).withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipOval(
              child: track.coverUrl != null
                  ? Image.network(
                      track.coverUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: MoodColorSystem.surfaceContainer,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: MoodColorSystem.getMoodTheme(null)['primary'],
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: MoodColorSystem.surfaceContainer,
                          child: Icon(Icons.music_note, size: 60, color: MoodColorSystem.onSurface),
                        );
                      },
                    )
                  : Container(
                      color: MoodColorSystem.surfaceContainer,
                      child: Icon(Icons.music_note, size: 60, color: MoodColorSystem.onSurface),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrackInfo(AudioTrack track) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Text(
            track.title,
            key: ValueKey<String>(track.title),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Text(
            track.artist ?? 'Unknown Artist',
            key: ValueKey<String?>(track.artist),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: 'Montserrat',
              color: const Color(0xFFD1D1D1),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedControls(AudioTrack track, List<AudioTrack> playlist, 
      bool isPlaying, bool isLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded),
          color: _currentIndex > 0 ? Colors.white : Colors.white24,
          iconSize: 32,
          onPressed: _currentIndex > 0 ? () => _handlePrev(playlist) : null,
        ),
        const SizedBox(width: 16),
        AnimatedScale(
          scale: isPlaying ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF1DB954), Color(0xFF1ed760)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1DB954).withOpacity(0.4),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: IconButton(
              iconSize: 56,
              icon: isLoading
                  ? SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                        key: ValueKey<bool>(isPlaying),
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black.withOpacity(0.25), blurRadius: 8)],
                      ),
                    ),
              onPressed: isLoading ? null : () => _handlePlayPause(track),
              tooltip: isPlaying ? 'Pause' : 'Play',
            ),
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.skip_next_rounded),
          color: _currentIndex < playlist.length - 1 ? Colors.white : Colors.white24,
          iconSize: 32,
          onPressed: _currentIndex < playlist.length - 1 ? () => _handleNext(playlist) : null,
        ),
      ],
    );
  }

  Widget _buildEnhancedProgressBar(Duration position, Duration duration, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
              trackHeight: 4.0,
              activeTrackColor: Color(0xFF1DB954),
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayColor: Color(0xFF1DB954).withOpacity(0.2),
            ),
            child: Slider(
              value: position.inMilliseconds.toDouble().clamp(
                0.0, 
                duration.inMilliseconds.toDouble()
              ),
              max: duration.inMilliseconds.toDouble() > 0 
                  ? duration.inMilliseconds.toDouble() 
                  : 1.0,
              onChanged: isLoading ? null : (value) => _seek(value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Music player methods
  Future<void> _playTrackAtIndex(List<AudioTrack> playlist, int index) async {
    if (index < 0 || index >= playlist.length) return;

    final track = playlist[index];
    _hapticFeedback();

    setState(() {
      _currentIndex = index;
      _currentTrack = track;
      _isPlaying = false;
    });

    await getIt<SongHistoryRepository>().addTrack(track);
    try {
      await _handler.playFromYoutubeId(track.youtubeId, track);
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memutar lagu: ${track.title}'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    }
  }

  Future<void> _handlePlayPause(AudioTrack track) async {
    _hapticFeedback();
    
    final isCurrentlyPlaying = _currentTrack?.id == track.id && _isPlaying;

    if (isCurrentlyPlaying) {
      await _handler.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      setState(() {
        _currentTrack = track;
        _isPlaying = false;
      });
      await getIt<SongHistoryRepository>().addTrack(track);
      try {
        await _handler.playFromYoutubeId(track.youtubeId, track);
        setState(() {
          _isPlaying = true;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memutar lagu: ${track.title}'),
              backgroundColor: Colors.red.shade400,
            ),
          );
        }
      }
    }
  }

  void _handleNext(List<AudioTrack> playlist) {
    if (_currentIndex < playlist.length - 1) {
      _playTrackAtIndex(playlist, _currentIndex + 1);
    }
  }

  void _handlePrev(List<AudioTrack> playlist) {
    if (_currentIndex > 0) {
      _playTrackAtIndex(playlist, _currentIndex - 1);
    }
  }

  Future<void> _seek(double value) async {
    await _handler.seek(Duration(milliseconds: value.round()));
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  // Radio helper methods
  String _getRadioStatusText(EnhancedRadioStatus status) {
    switch (status) {
      case EnhancedRadioStatus.initial:
        return 'Memuat stasiun...';
      case EnhancedRadioStatus.loaded:
        return 'Pilih stasiun untuk memulai';
      case EnhancedRadioStatus.loading:
        return 'Menghubungkan...';
      case EnhancedRadioStatus.playing:
        return 'Sedang diputar';
      case EnhancedRadioStatus.paused:
        return 'Dijeda';
      case EnhancedRadioStatus.stopped:
        return 'Terhenti';
      case EnhancedRadioStatus.error:
        return 'Terjadi kesalahan';
    }
  }

  String _getStationEmoji(String category) {
    final radioCategory = RadioCategory.values.firstWhere(
      (cat) => cat.id == category,
      orElse: () => RadioCategory.pop,
    );
    return radioCategory.emoji;
  }

  int _parseHexColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }

  void _showVolumeControl(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Volume Control',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Volume control akan diimplementasikan di update selanjutnya.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
