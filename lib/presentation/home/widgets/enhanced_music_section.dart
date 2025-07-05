// lib/presentation/home/widgets/enhanced_music_section.dart

import 'dart:async';
import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/repositories/song_history_repository.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_state.dart';
import 'package:dear_flutter/services/audio_player_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_service/audio_service.dart';

class EnhancedMusicSection extends StatefulWidget {
  const EnhancedMusicSection({super.key});

  @override
  State<EnhancedMusicSection> createState() => _EnhancedMusicSectionState();
}

class _EnhancedMusicSectionState extends State<EnhancedMusicSection> 
    with TickerProviderStateMixin {
  late final AudioPlayerHandler _handler;
  late final StreamSubscription<PlaybackState> _playbackStateSubscription;
  late final AnimationController _pulseController;
  late final AnimationController _coverRotationController;
  Timer? _positionTimer;

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  AudioTrack? _currentTrack;
  int _currentIndex = 0;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _handler = getIt<AudioPlayerHandler>();
    
    // Animation controllers for enhanced UI
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _coverRotationController = AnimationController(
      duration: const Duration(seconds: 20),
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
      
      // Auto-fetch new music when playlist ends
      if (state.processingState == AudioProcessingState.completed) {
        final cubit = context.read<HomeFeedCubit>();
        final playlist = cubit.state.playlist;
        if (_currentIndex >= playlist.length - 1) {
          await cubit.fetchHomeFeed();
        }
      }
    });
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _playbackStateSubscription.cancel();
    _pulseController.dispose();
    _coverRotationController.dispose();
    super.dispose();
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 200), (_) async {
      if (!mounted || !_isPlaying) return;
      final pos = _handler.player.position;
      final dur = _handler.player.duration;
      setState(() {
        _position = pos;
        _duration = dur ?? _duration;
      });
    });
  }

  void _stopPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }

  // Enhanced haptic feedback
  void _hapticFeedback() {
    HapticFeedback.lightImpact();
  }

  // Enhanced track controls with haptic feedback
  void _playTrackAtIndex(List<AudioTrack> playlist, int index) async {
    if (index < 0 || index >= playlist.length) return;
    _hapticFeedback();
    
    final track = playlist[index];
    setState(() {
      _currentTrack = track;
      _currentIndex = index;
    });
    
    await getIt<SongHistoryRepository>().addTrack(track);
    
    try {
      await _handler.playFromYoutubeId(track.youtubeId, track);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Gagal memutar lagu: ${track.title}');
      }
    }
  }

  // Enhanced error feedback
  void _showErrorSnackBar(String message) {
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
      ),
    );
  }

  // Enhanced success feedback
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Color(0xFF1DB954),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 2),
      ),
    );
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
        _showSuccessSnackBar('Memutar: ${track.title}');
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Gagal memutar: ${track.title}');
        }
      }
    }
  }

  Future<void> _seek(double value) async {
    await _handler.seek(Duration(milliseconds: value.round()));
  }

  void _toggleLike() {
    _hapticFeedback();
    setState(() {
      _isLiked = !_isLiked;
    });
    _showSuccessSnackBar(_isLiked ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit');
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeFeedCubit, HomeFeedState>(
      buildWhen: (prev, curr) =>
        prev.music != curr.music ||
        prev.status != curr.status ||
        prev.playlist != curr.playlist,
      builder: (context, state) {
        final track = state.music;
        final playlist = state.playlist;
        final musicStatus = state.feed?.musicStatus ?? "done";
        final isLoading = state.status == HomeFeedStatus.loading || musicStatus == "generating";

        if (track == null) {
          return _buildEmptyState(isLoading, musicStatus);
        }

        // Sync current index with playlist
        final idx = playlist.indexWhere((t) => t.id == track.id);
        if (idx != -1 && idx != _currentIndex) {
          _currentIndex = idx;
        }

        final bool isActivePlayer = _currentTrack?.id == track.id;
        final bool isPlaying = isActivePlayer && _isPlaying;
        final Duration position = isActivePlayer ? _position : Duration.zero;
        final Duration duration = isActivePlayer ? _duration : Duration.zero;

        return _buildMusicPlayer(track, playlist, isPlaying, position, duration, isLoading);
      },
    );
  }

  Widget _buildEmptyState(bool isLoading, String musicStatus) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
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
                'Tekan tombol refresh atau tulis jurnal untuk mendapatkan rekomendasi musik',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Muat Musik'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1DB954),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  _hapticFeedback();
                  await context.read<HomeFeedCubit>().fetchHomeFeed();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMusicPlayer(AudioTrack track, List<AudioTrack> playlist, 
      bool isPlaying, Duration position, Duration duration, bool isLoading) {
    return Center(
      child: Container(
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
            if (isPlaying) BoxShadow(
              color: Color(0xFF1DB954).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: isPlaying 
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
              
              // Additional controls (like, share, etc.)
              _buildAdditionalControls(track),
            ],
          ),
        ),
      ),
    );
  }

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
                          color: Colors.grey.shade800,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF1DB954),
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade800,
                          child: Icon(Icons.music_note, size: 60, color: Colors.white),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade800,
                      child: Icon(Icons.music_note, size: 60, color: Colors.white),
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
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        key: ValueKey<bool>(isPlaying),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
              onPressed: isLoading ? null : () => _handlePlayPause(track),
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

  Widget _buildAdditionalControls(AudioTrack track) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              child: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                key: ValueKey<bool>(_isLiked),
                color: _isLiked ? Colors.red : Colors.white54,
                size: 24,
              ),
            ),
            onPressed: _toggleLike,
            tooltip: _isLiked ? 'Hapus dari favorit' : 'Tambah ke favorit',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white54, size: 24),
            onPressed: () {
              _hapticFeedback();
              // TODO: Implement share functionality
              _showSuccessSnackBar('Fitur berbagi akan segera hadir!');
            },
            tooltip: 'Bagikan',
          ),
          IconButton(
            icon: const Icon(Icons.queue_music_outlined, color: Colors.white54, size: 24),
            onPressed: () {
              _hapticFeedback();
              // TODO: Implement queue/playlist view
              _showSuccessSnackBar('Fitur playlist akan segera hadir!');
            },
            tooltip: 'Lihat playlist',
          ),
        ],
      ),
    );
  }
}
