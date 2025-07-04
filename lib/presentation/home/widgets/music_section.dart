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
  late final StreamSubscription<PlaybackState> _playSub;
  late final StreamSubscription<Duration> _posSub;
  late final StreamSubscription<Duration?> _durSub;

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  AudioTrack? _currentTrack;

  @override
  void initState() {
    super.initState();
    _handler = getIt<AudioPlayerHandler>();

    _playSub = _handler.playbackState.listen((state) {
      if (!mounted) return;
      if (state.processingState == AudioProcessingState.completed) {
        _resetState();
      } else {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });

    _posSub = _handler.positionStream.listen((d) {
      if (!mounted || !_isPlaying) return;
      setState(() => _position = d);
    });

    _durSub = _handler.durationStream.listen((d) {
      if (!mounted || !_isPlaying) return;
      if (d != null) {
        setState(() => _duration = d);
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
    _playSub.cancel();
    _posSub.cancel();
    _durSub.cancel();
    super.dispose();
  }

  Future<void> _handlePlayPause(AudioTrack track) async {
    if (_currentTrack?.id != track.id) {
      setState(() {
        _currentTrack = track;
      });
      await getIt<SongHistoryRepository>().addTrack(track);
      await _handler.playFromYoutubeId(track.youtubeId);
    } else {
      if (_isPlaying) {
        await _handler.pause();
      } else {
        await _handler.play();
      }
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
              'Rekomendasi Musik',
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

// --- REVISI UTAMA PADA _MusicCard ---
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

  // Helper untuk format durasi
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
                // Cover Art
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
                // Judul dan Artis
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
                // Tombol Play/Pause dengan animasi
                IconButton(
                  iconSize: 42,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                      key: ValueKey<bool>(isPlaying), // Penting untuk animasi
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  onPressed: onTap,
                ),
              ],
            ),
            // Tampilkan Seek Bar hanya jika lagu sedang diputar
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

// Shimmer card tidak perlu diubah
class _ShimmerMusicCard extends StatelessWidget {
  const _ShimmerMusicCard();
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 224, 224, 224)!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        child: ListTile(
          leading: Icon(Icons.music_note, color: const Color.fromARGB(255, 39, 79, 191)),
          title: Container(height: 20.0, color: Colors.grey[400]),
          subtitle: Container(height: 15.0, color: Colors.grey[300]),
        ),
      ),
    );
  }
}