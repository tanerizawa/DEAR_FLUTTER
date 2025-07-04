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

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  AudioTrack? _currentTrack;

  @override
  void initState() {
    super.initState();
    _handler = getIt<AudioPlayerHandler>();

    // --- PERBAIKAN UTAMA: Dengarkan satu stream utama untuk semua data ---
    _playbackStateSubscription = _handler.playbackState.listen((state) {
      if (!mounted) return;
      
      final currentMediaItem = _handler.mediaItem.value;
      // Tentukan apakah lagu yang sedang diputar adalah lagu di kartu ini
      final isPlayingThisTrack = _currentTrack?.id.toString() == currentMediaItem?.id;

      setState(() {
        _isPlaying = state.playing && isPlayingThisTrack;
        _position = isPlayingThisTrack ? state.updatePosition : Duration.zero;
        _duration = isPlayingThisTrack ? (currentMediaItem?.duration ?? Duration.zero) : Duration.zero;

        // Reset state jika lagu sudah selesai atau tidak ada yang diputar
        if (state.processingState == AudioProcessingState.completed) {
            _resetStateAfterDelay();
        }
      });
    });
  }

  // Memberi jeda singkat sebelum mereset agar UI tidak "lompat"
  void _resetStateAfterDelay() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      // Hanya reset jika benar-benar tidak ada yang diputar
      if (!_handler.playbackState.value.playing) {
          _resetState();
      }
    });
  }

  void _resetState() {
    if (!mounted) return;
    setState(() {
      _currentTrack = null;
      _isPlaying = false;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
  }

  @override
  void dispose() {
    _playbackStateSubscription.cancel();
    super.dispose();
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
      // Kirim objek track ke handler agar bisa membuat MediaItem
      await _handler.playFromYoutubeId(track.youtubeId, track);
    }
  }

  Future<void> _seek(double value) async {
    await _handler.seek(Duration(milliseconds: value.round()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeFeedCubit, HomeFeedState>(
      builder: (context, state) {
        if (state.status == HomeFeedStatus.loading && state.feed == null) {
          return const _ShimmerMusicCard();
        }
        final track = state.feed?.music;
        if (track == null) {
          return const SizedBox.shrink();
        }

        final bool isActivePlayer = _currentTrack?.id == track.id;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Untukmu Hari Ini', // Judul baru yang lebih personal
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _MusicCard(
              track: track,
              isPlaying: isActivePlayer && _isPlaying,
              duration: isActivePlayer ? _duration : Duration.zero,
              position: isActivePlayer ? _position : Duration.zero,
              onTap: () => _handlePlayPause(track),
              onSeek: _seek,
            ),
          ],
        );
      },
    );
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
  });

  final AudioTrack track;
  final bool isPlaying;
  final Duration duration;
  final Duration position;
  final VoidCallback onTap;
  final Function(double) onSeek;

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.music_note, size: 30, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        track.artist ?? 'Artis Tidak Diketahui',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  iconSize: 42,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                      key: ValueKey<bool>(isPlaying),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  onPressed: onTap,
                ),
              ],
            ),
            if (isPlaying)
              Column(
                children: [
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                      trackHeight: 2.0,
                    ),
                    child: Slider(
                      value: position.inMilliseconds.toDouble().clamp(0.0, duration.inMilliseconds.toDouble()),
                      max: duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1.0,
                      onChanged: onSeek,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
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