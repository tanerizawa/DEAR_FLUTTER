// lib/presentation/home/widgets/music_section.dart

import 'dart:async';
import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/repositories/song_history_repository.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_state.dart';
import 'package:dear_flutter/services/audio_player_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeFeedCubit, HomeFeedState>(
      buildWhen: (prev, curr) =>
        prev.music != curr.music ||
        prev.status != curr.status,
      builder: (context, state) {
        final track = state.music;
        final isLoading = state.status == HomeFeedStatus.loading;
        if (isLoading && track == null) {
          return const _ShimmerMusicCard();
        }
        if (track == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
              ),
            ),
          );
        }
        final bool isActivePlayer = _currentTrack?.id == track.id;
        final bool isPlaying = isActivePlayer && _isPlaying;
        final Duration position = isActivePlayer ? _position : Duration.zero;
        final Duration duration = isActivePlayer ? _duration : Duration.zero;
        void onTap() => _handlePlayPause(track);
        Future<void> onRefresh() async => await context.read<HomeFeedCubit>().fetchHomeFeed();
        void onSeek(double value) => _seek(value);
        String _formatDuration(Duration d) {
          final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
          final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
          return "$minutes:$seconds";
        }

        // --- HAPUS AUTOPLAY: hanya play jika user klik manual ---

        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [Color(0xFF232526), Color(0xFF232526)], // Monochrome dark grey
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
              border: Border.all(color: Color(0x1A1A1A).withOpacity(0.15), width: 1.2),
              backgroundBlendMode: BlendMode.overlay,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cover Art
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: track.coverUrl != null
                          ? Image.network(track.coverUrl!, fit: BoxFit.cover)
                          : Container(
                              color: Colors.grey.shade900,
                              child: Icon(Icons.music_note, size: 48, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                            shadows: [Shadow(blurRadius: 6, color: Colors.black45)],
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Artis
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                    child: Text(
                      track.artist ?? 'Artis Tidak Diketahui',
                      key: ValueKey<String?>(track.artist),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Montserrat',
                            color: Color(0xFFD1D1D1), // Light grey for secondary text (artist, subtitle)
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            shadows: [Shadow(blurRadius: 4, color: Colors.black38)],
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Tombol Play/Pause & Refresh
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: isPlaying ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: IconButton(
                          iconSize: 44,
                          icon: isLoading
                              ? SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF2850)), // Apple Music red
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
                                    color: Color(0xFFB0B0B0), // Monochrome light grey for play/pause icon
                                    shadows: [Shadow(color: Colors.black.withOpacity(0.25), blurRadius: 8)],
                                  ),
                                ),
                          onPressed: isLoading ? null : onTap,
                          tooltip: isPlaying ? 'Pause' : 'Play',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: isLoading ? null : onRefresh,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Progress Bar
                  if (isPlaying)
                    Column(
                      children: [
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                            trackHeight: 2.0,
                            activeTrackColor: Color(0xFF888888), // Monochrome medium grey
                            inactiveTrackColor: Color(0xFFCCCCCC), // Monochrome light grey
                            thumbColor: Color(0xFF5A5D6C), // Subtle blue-grey accent for slider thumb
                          ),
                          child: Slider(
                            value: position.inMilliseconds.toDouble().clamp(0.0, duration.inMilliseconds.toDouble()),
                            max: duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1.0,
                            onChanged: isLoading ? null : onSeek,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(position),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 12,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                        shadows: [Shadow(blurRadius: 2, color: Colors.black26)],
                                      )),
                              Text(_formatDuration(duration),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 12,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                        shadows: [Shadow(blurRadius: 2, color: Colors.black26)],
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
      if (_isPlaying) {
        _startPositionTimer();
      } else {
        _stopPositionTimer();
      }
      // Tidak ada auto-next/playlist
    });
  }

  Future<void> _handlePlayPause(AudioTrack track) async {
    final isCurrentlyPlaying = _currentTrack?.id == track.id && _isPlaying;

    if (isCurrentlyPlaying) {
      await _handler.pause();
    } else {
      setState(() {
        _currentTrack = track;
      });
      await getIt<SongHistoryRepository>().addTrack(track);
      try {
        await _handler.playFromYoutubeId(track.youtubeId, track);
      } catch (e) {
        // Error handling: show snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memutar lagu: ${track.title} ("${e.toString()}")'),
              backgroundColor: Colors.red.shade400,
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

class _ShimmerMusicCard extends StatelessWidget {
  const _ShimmerMusicCard();
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        child: ListTile(
          leading: Icon(Icons.music_note, color: Colors.grey[400]), // Monochrome for shimmer icon
          title: Container(height: 20.0, color: Colors.grey[400]),
          subtitle: Container(height: 15.0, color: Colors.grey[300]),
        ),
      ),
    );
  }
}