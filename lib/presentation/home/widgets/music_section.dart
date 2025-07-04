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

  bool _userStartedPlay = false;

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
        prev.playlist != curr.playlist ||
        prev.activeIndex != curr.activeIndex ||
        prev.status != curr.status,
      builder: (context, state) {
        final playlist = state.playlist;
        final idx = state.activeIndex;
        final isLoading = state.status == HomeFeedStatus.loading;
        if (isLoading && playlist.isEmpty) {
          return const _ShimmerMusicCard();
        }
        if (playlist.isEmpty || idx >= playlist.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.music_off, size: 64, color: Colors.blueGrey.shade200),
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
                      _userStartedPlay = false;
                      await context.read<HomeFeedCubit>().fetchPlaylist();
                    },
                  ),
                ],
              ),
            ),
          );
        }
        final track = playlist[idx];
        final bool isActivePlayer = _currentTrack?.id == track.id;

        // --- AUTO PLAY jika auto-next aktif dan track berubah ---
        if (_userStartedPlay && (!isActivePlayer || !_isPlaying)) {
          // Jangan trigger play jika sedang loading
          if (!isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handlePlayPause(track);
            });
          }
        }

        // --- HAPUS AUTOPLAY: hanya play jika user klik manual ---
        // Auto next hanya jika user sudah pernah play manual
        // (auto next di _playbackStateSubscription, bukan di build)

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Untukmu Hari Ini',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _MusicCard(
              track: track,
              isPlaying: isActivePlayer && _isPlaying,
              duration: isActivePlayer ? _duration : Duration.zero,
              position: isActivePlayer ? _position : Duration.zero,
              onTap: isLoading ? null : () async {
                _userStartedPlay = true;
                await _handlePlayPause(track);
              },
              onSeek: isLoading ? null : _seek,
              onRefresh: isLoading
                  ? null
                  : () async {
                      _userStartedPlay = false;
                      await context.read<HomeFeedCubit>().fetchPlaylist();
                    },
              isLoading: isLoading,
            ),
          ],
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
      // Auto next hanya jika user sudah pernah play manual dan playlist belum habis
      if (_userStartedPlay && state.processingState == AudioProcessingState.completed) {
        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (!mounted) return;
          final cubit = context.read<HomeFeedCubit>();
          final playlist = cubit.state.playlist;
          final idx = cubit.state.activeIndex;
          if (playlist.isNotEmpty && idx + 1 < playlist.length) {
            cubit.nextSong();
            // Tetap auto-next ke lagu berikutnya
            setState(() { _userStartedPlay = true; });
          } else {
            // Playlist habis, stop autoplay
            setState(() { _userStartedPlay = false; });
          }
        }
      }
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
        // Error handling: show snackbar, skip to next song, stop auto-play for this track
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memutar lagu: ${track.title} (\"${e.toString()}\"). Melewati ke lagu berikutnya.'),
              backgroundColor: Colors.red.shade400,
            ),
          );
          // Skip to next song if available
          final cubit = context.read<HomeFeedCubit>();
          final playlist = cubit.state.playlist;
          final idx = cubit.state.activeIndex;
          if (playlist.isNotEmpty && idx + 1 < playlist.length) {
            cubit.nextSong();
            setState(() { _userStartedPlay = true; });
          } else {
            setState(() { _userStartedPlay = false; });
          }
        }
      }
    }
  }

  Future<void> _seek(double value) async {
    await _handler.seek(Duration(milliseconds: value.round()));
  }
}

class _MusicCard extends StatelessWidget {
  const _MusicCard({
    required this.track,
    required this.isPlaying,
    required this.duration,
    required this.position,
    required this.onTap,
    required this.onSeek,
    this.onRefresh,
    this.isLoading = false,
  });

  final AudioTrack track;
  final bool isPlaying;
  final Duration duration;
  final Duration position;
  final VoidCallback? onTap;
  final Function(double)? onSeek;
  final Future<void> Function()? onRefresh;
  final bool isLoading;

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLoading ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.purple.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 72,
                      height: 72,
                      color: Colors.grey.shade300,
                      child: track.coverUrl != null
                          ? Image.network(track.coverUrl!, fit: BoxFit.cover)
                          : const Icon(Icons.music_note, size: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.blue.shade900,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          track.artist ?? 'Artis Tidak Diketahui',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.blueGrey.shade700,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      IconButton(
                        iconSize: 48,
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: Icon(
                            isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                            key: ValueKey<bool>(isPlaying),
                            color: Colors.blue.shade700,
                          ),
                        ),
                        onPressed: isLoading ? null : onTap,
                      ),
                      if (onRefresh != null)
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1DB954)),
                          tooltip: 'Ganti Lagu',
                          onPressed: isLoading ? null : onRefresh,
                        ),
                    ],
                  ),
                ],
              ),
              if (isPlaying)
                Column(
                  children: [
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                        trackHeight: 3.0,
                      ),
                      child: Slider(
                        value: position.inMilliseconds.toDouble().clamp(0.0, duration.inMilliseconds.toDouble()),
                        max: duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1.0,
                        onChanged: isLoading ? null : onSeek,
                        activeColor: Colors.blue.shade700,
                        inactiveColor: Colors.blue.shade100,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(position), style: Theme.of(context).textTheme.bodySmall),
                          Text(_formatDuration(duration), style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
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
          leading: Icon(Icons.music_note, color: Colors.grey[400]),
          title: Container(height: 20.0, color: Colors.grey[400]),
          subtitle: Container(height: 15.0, color: Colors.grey[300]),
        ),
      ),
    );
  }
}