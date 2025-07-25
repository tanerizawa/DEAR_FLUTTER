// lib/presentation/home/widgets/music_section.dart

import 'dart:async';
import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/core/theme/mood_color_system.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/repositories/song_history_repository.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_state.dart';
import 'package:dear_flutter/services/audio_player_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_service/audio_service.dart';

class MusicSection extends StatefulWidget {
  const MusicSection({super.key});

  @override
  State<MusicSection> createState() => _MusicSectionState();
}

class _MusicSectionState extends State<MusicSection> {
  late final AudioPlayerHandler _handler;
  late final StreamSubscription<PlaybackState> _playbackStateSubscription;
  Timer? _positionTimer;

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  AudioTrack? _currentTrack;
  int _currentIndex = 0;

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

  @override
  void dispose() {
    _positionTimer?.cancel();
    _playbackStateSubscription.cancel();
    super.dispose();
  }

  void _playTrackAtIndex(List<AudioTrack> playlist, int index) async {
    if (index < 0 || index >= playlist.length) return;
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memutar lagu: [${track.title}] ("${e.toString()}")'),
            backgroundColor: Colors.red.shade400,
          ),
        );
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading) ...[
                    const CircularProgressIndicator(color: Color(0xFF1DB954)),
                    const SizedBox(height: 16),
                    Text(
                      musicStatus == "generating" 
                          ? 'Sedang menghasilkan lagu berdasarkan jurnal Anda...'
                          : 'Memuat musik...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.blueGrey.shade700),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Icon(Icons.music_off, size: 64, color: Colors.blueGrey.shade200), // Monochrome for empty state icon
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada lagu hari ini. Coba tekan tombol refresh atau cek koneksi internet Anda.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.blueGrey.shade700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba Lagi'),
                      onPressed: () async {
                        await context.read<HomeFeedCubit>().fetchHomeFeed();
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        // Sync _currentIndex with playlist
        final idx = playlist.indexWhere((t) => t.id == track.id);
        if (idx != -1 && idx != _currentIndex) {
          _currentIndex = idx;
        }
        final bool isActivePlayer = _currentTrack?.id == track.id;
        final bool isPlaying = isActivePlayer && _isPlaying;
        final Duration position = isActivePlayer ? _position : Duration.zero;
        final Duration duration = isActivePlayer ? _duration : Duration.zero;
        void onSeek(double value) => _seek(value);
        String _formatDuration(Duration d) {
          final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
          final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
          return "$minutes:$seconds";
        }
        // UI utama
        return Center(
          child: Container(
            height: MoodColorSystem.cardHeightSecondary, // Golden ratio secondary height
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(MoodColorSystem.space_lg),
              gradient: LinearGradient(
                colors: [
                  MoodColorSystem.surfaceContainer, 
                  const Color(0xFF26A69A).withOpacity(0.15)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: MoodColorSystem.space_lg,
                  offset: Offset(0, MoodColorSystem.space_sm),
                ),
              ],
              border: Border.all(
                color: const Color(0xFF26A69A).withOpacity(0.2), 
                width: 1.5
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(MoodColorSystem.space_md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Playlist horizontal list (lebih kecil)
                  if (playlist.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: MoodColorSystem.space_sm),
                      child: SizedBox(
                        height: MoodColorSystem.space_xl, // Golden ratio based height
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: playlist.length,
                          separatorBuilder: (_, __) => SizedBox(width: MoodColorSystem.space_xs),
                          itemBuilder: (context, i) {
                            final t = playlist[i];
                            final isActive = i == _currentIndex;
                            return GestureDetector(
                              onTap: () => _playTrackAtIndex(playlist, i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(
                                  horizontal: MoodColorSystem.space_sm, 
                                  vertical: MoodColorSystem.space_xs,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive ? MoodColorSystem.onSurface.withOpacity(0.1) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(MoodColorSystem.space_sm),
                                  border: isActive ? Border.all(color: MoodColorSystem.onSurface, width: 1.2) : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.music_note, 
                                         color: isActive ? MoodColorSystem.onSurface : MoodColorSystem.onSurfaceSecondary, 
                                         size: MoodColorSystem.space_md),
                                    SizedBox(width: MoodColorSystem.space_xs),
                                    Text(
                                      t.title,
                                      style: MoodColorSystem.getTextStyle(
                                        fontSize: MoodColorSystem.text_xs,
                                        fontWeight: FontWeight.bold,
                                        color: isActive ? MoodColorSystem.onSurface : MoodColorSystem.onSurfaceVariant,
                                        letterSpacing: 0.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  // Cover Art lingkaran
                  Container(
                    width: MoodColorSystem.cardHeightCompact,
                    height: MoodColorSystem.cardHeightCompact,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MoodColorSystem.surfaceContainer,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: MoodColorSystem.space_md,
                          offset: Offset(0, MoodColorSystem.space_xs),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: track.coverUrl != null
                          ? Image.network(track.coverUrl!, fit: BoxFit.cover)
                          : Container(
                              color: MoodColorSystem.surfaceVariant,
                              child: Icon(
                                Icons.music_note, 
                                size: MoodColorSystem.space_lg, 
                                color: MoodColorSystem.onSurfaceVariant,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: MoodColorSystem.space_sm),
                  // Judul Lagu
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                    child: Text(
                      track.title,
                      key: ValueKey<String>(track.title),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        shadows: [const Shadow(blurRadius: 6, color: Colors.black45)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Artis
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                    child: Text(
                      track.artist ?? 'Artis Tidak Diketahui',
                      key: ValueKey<String?>(track.artist),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Montserrat',
                        color: const Color(0xFFD1D1D1),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        shadows: [const Shadow(blurRadius: 4, color: Colors.black38)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Tombol prev, play/pause, next
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded),
                        color: _currentIndex > 0 ? Colors.white : Colors.white24,
                        iconSize: 30,
                        onPressed: _currentIndex > 0 ? () => _handlePrev(playlist) : null,
                        tooltip: 'Sebelumnya',
                      ),
                      const SizedBox(width: 10),
                      AnimatedScale(
                        scale: isPlaying ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: IconButton(
                          iconSize: 44,
                          icon: isLoading
                              ? SizedBox(
                                  width: 26,
                                  height: 26,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded),
                        color: _currentIndex < playlist.length - 1 ? Colors.white : Colors.white24,
                        iconSize: 30,
                        onPressed: _currentIndex < playlist.length - 1 ? () => _handleNext(playlist) : null,
                        tooltip: 'Berikutnya',
                      ),
                    ],
                  ),
                  // Progress Bar
                  if (isPlaying)
                    Column(
                      children: [
                        const SizedBox(height: 6),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
                            trackHeight: 2.0,
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white38,
                            thumbColor: Colors.white,
                          ),
                          child: Slider(
                            value: position.inMilliseconds.toDouble().clamp(0.0, duration.inMilliseconds.toDouble()),
                            max: duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1.0,
                            onChanged: isLoading ? null : onSeek,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(position),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                  )),
                              Text(_formatDuration(duration),
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _handler = getIt<AudioPlayerHandler>();
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
      
      // Control timer based on playback state
      if (_isPlaying) {
        _startPositionTimer();
      } else {
        _stopPositionTimer();
      }
      
      // Trigger fetch jika sudah di akhir playlist dan playback completed
      if (state.processingState == AudioProcessingState.completed) {
        final cubit = context.read<HomeFeedCubit>();
        final playlist = cubit.state.playlist;
        if (_currentIndex >= playlist.length - 1) {
          // Sudah di akhir playlist, fetch baru
          await cubit.fetchHomeFeed();
        }
      }
    });
  }

  Future<void> _handlePlayPause(AudioTrack track) async {
    final isCurrentlyPlaying = _currentTrack?.id == track.id && _isPlaying;
    final isTrackChanged = _currentTrack?.id != track.id;

    if (isCurrentlyPlaying) {
      try {
        await _handler.pause();
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      } catch (e) {
        debugPrint('Error pausing audio: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghentikan audio: ${e.toString()}'),
              backgroundColor: Colors.red.shade400,
              action: SnackBarAction(
                label: 'Coba Lagi',
                textColor: Colors.white,
                onPressed: () => _handlePlayPause(track),
              ),
            ),
          );
        }
      }
    } else {
      // Reset state when changing tracks
      if (isTrackChanged && mounted) {
        setState(() {
          _currentTrack = track;
          _isPlaying = false;
          _position = Duration.zero;
          _duration = Duration.zero;
        });
      }
      
      await getIt<SongHistoryRepository>().addTrack(track);
      
      try {
        await _handler.playFromYoutubeId(track.youtubeId, track);
        if (mounted) {
          setState(() {
            _isPlaying = true;
          });
        }
      } catch (e) {
        debugPrint('Error playing audio: $e');
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memutar lagu: ${track.title}'),
              backgroundColor: Colors.red.shade400,
              action: SnackBarAction(
                label: 'Coba Lagi',
                textColor: Colors.white,
                onPressed: () => _handlePlayPause(track),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _seek(double value) async {
    await _handler.seek(Duration(milliseconds: value.round()));
  }
}